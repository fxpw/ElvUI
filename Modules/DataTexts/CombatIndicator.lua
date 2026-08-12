local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions

local inCombat, outOfCombat = "", ""

local function OnEvent(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		self.text:SetText(inCombat)
	else
		self.text:SetText(outOfCombat)
	end
end

local function ValueColorUpdate()
	-- строки с фиксированными цветами, как в стандартном ElvUI (зеленый/красный)
	inCombat = E:RGBToHex(1, 0.13, 0.13)..L["In Combat"].."|r"
	outOfCombat = E:RGBToHex(0.2, 1, 0.2)..L["Out of Combat"].."|r"
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

ValueColorUpdate()

DT:RegisterDatatext("CombatIndicator", {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"}, OnEvent, nil, nil, nil, nil, L["Combat Indicator"])
