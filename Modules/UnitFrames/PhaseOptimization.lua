local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

local hasEnteredWorld = false
local lastPhaseChangeTime = 0
local PHASE_CHANGE_COOLDOWN = 0.5
local UPDATE_DELAY = 0.05

do
	local original_PLAYER_ENTERING_WORLD = UF.PLAYER_ENTERING_WORLD
	
	function UF:PLAYER_ENTERING_WORLD()
		local currentTime = GetTime()
		
		if currentTime - lastPhaseChangeTime < PHASE_CHANGE_COOLDOWN then
			return
		end
		
		lastPhaseChangeTime = currentTime
		
		if not hasEnteredWorld then
		C_Timer:After(0.1, function()
			if not InCombatLockdown() then
				UF:Update_AllFrames()
				hasEnteredWorld = true
			end
		end)
	else
		local _, instanceType = IsInInstance()
		if instanceType ~= "none" then
			C_Timer:After(UPDATE_DELAY, function()
				if not InCombatLockdown() then
					UF:UpdateAllHeaders()
				end
			end)
		end
	end
	end
end

local original_Update_AllFrames = UF.Update_AllFrames

function UF:Update_AllFrames()
	if InCombatLockdown() then 
		self:RegisterEvent("PLAYER_REGEN_ENABLED") 
		return 
	end
	
	if E.private.unitframe.enable ~= true then return end

	self:UpdateColors()
	self:Update_FontStrings()
	self:Update_StatusBars()

	local frameIndex = 0
	local UPDATE_BATCH_SIZE = 3
	
	local framesToUpdate = {}
	for unit in pairs(self.units) do
		table.insert(framesToUpdate, {type = "unit", key = unit})
	end
	for unit, group in pairs(self.groupunits) do
		table.insert(framesToUpdate, {type = "group", key = unit, group = group})
	end
	
	local function UpdateNextBatch()
		local batchEnd = math.min(frameIndex + UPDATE_BATCH_SIZE, #framesToUpdate)
		
		for i = frameIndex + 1, batchEnd do
			local frameData = framesToUpdate[i]
			
			if frameData.type == "unit" then
				local unit = frameData.key
				if self.db.units[unit].enable then
					self[unit]:Update()
					self[unit]:Enable()
					E:EnableMover(self[unit].mover:GetName())
				else
					self[unit]:Update()
					self[unit]:Disable()
					E:DisableMover(self[unit].mover:GetName())
				end
			elseif frameData.type == "group" then
				local unit = frameData.key
				local group = frameData.group
				if self.db.units[group].enable then
					self[unit]:Enable()
					self[unit]:Update()
					E:EnableMover(self[unit].mover:GetName())
				else
					self[unit]:Disable()
					E:DisableMover(self[unit].mover:GetName())
				end
			end
		end
		
		frameIndex = batchEnd
		
		if frameIndex < #framesToUpdate then
			C_Timer:After(0.01, UpdateNextBatch)
		end
	end
	
	UpdateNextBatch()
end
