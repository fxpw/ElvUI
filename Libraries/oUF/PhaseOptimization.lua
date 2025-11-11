local parent, ns = ...
local oUF = ns.oUF

local lastUpdateTimes = {}
local UPDATE_THROTTLE = 0.3

local originalSpawn = oUF.Spawn

function oUF:Spawn(unit, overrideName)
	local object = originalSpawn(self, unit, overrideName)
	
	if not object or object.__phaseOptimized then 
		return object 
	end
	
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
	
	return object
end

C_Timer:NewTicker(300, function()
	local currentTime = GetTime()
	for name, time in pairs(lastUpdateTimes) do
		if currentTime - time > 300 then
			lastUpdateTimes[name] = nil
		end
	end
end)

