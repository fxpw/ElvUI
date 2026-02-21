local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")

if not NP then return end

local lastPhaseUpdate = 0
local PHASE_UPDATE_COOLDOWN = 0.5

local original_OnEvent = NP.OnEvent

function NP:OnEvent(event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_ENTERING_WORLD" then
		local currentTime = GetTime()
		
		if currentTime - lastPhaseUpdate < PHASE_UPDATE_COOLDOWN then
			return
		end
		
		lastPhaseUpdate = currentTime
		
		C_Timer:After(0.05, function()
			original_OnEvent(self, event, arg1, arg2, arg3, arg4)
		end)
		
		return
	end
	
	original_OnEvent(self, event, arg1, arg2, arg3, arg4)
end
