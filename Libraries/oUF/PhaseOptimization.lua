local parent, ns = ...
local oUF = ns.oUF

local lastUpdateTimes = {}
local UPDATE_THROTTLE = 0.3

hooksecurefunc(oUF, 'Spawn', function(self, unit, overrideName, ignoreOUFDB)
	local name = overrideName or unit
	local object = _G[name]
	
	if not object or object.__phaseOptimized then return end
	object.__phaseOptimized = true
	
	local originalUpdate = object.UpdateAllElements
	
	object.UpdateAllElements = function(self, ...)
		local currentTime = GetTime()
		local objectName = self:GetName() or tostring(self)
		
		if lastUpdateTimes[objectName] and (currentTime - lastUpdateTimes[objectName]) < UPDATE_THROTTLE then
			return
		end
		
		lastUpdateTimes[objectName] = currentTime
		
		return originalUpdate(self, ...)
	end
end)

C_Timer:NewTicker(300, function()
	local currentTime = GetTime()
	for name, time in pairs(lastUpdateTimes) do
		if currentTime - time > 300 then
			lastUpdateTimes[name] = nil
		end
	end
end)
