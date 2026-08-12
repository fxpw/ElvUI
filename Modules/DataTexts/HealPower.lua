local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local GetSpellBonusHealing = GetSpellBonusHealing

local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, L["HP"], GetSpellBonusHealing())
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("HealPower", {"UNIT_STATS", "UNIT_AURA"}, OnEvent, nil, nil, nil, nil, L["Heal Power"])
