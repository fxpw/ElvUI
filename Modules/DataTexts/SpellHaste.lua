local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local GetCombatRatingBonus = GetCombatRatingBonus
local CR_HASTE_SPELL = CR_HASTE_SPELL

local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, GetCombatRatingBonus(CR_HASTE_SPELL) or 0)
end

local function ValueColorUpdate(hex)
	displayString = join("", L["Spell Haste"], ": ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Spell Haste", {"UNIT_STATS", "UNIT_AURA"}, OnEvent, nil, nil, nil, nil, L["Spell Haste"])
