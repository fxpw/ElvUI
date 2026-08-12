local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
-- WotLK has no GetSpellHitModifier(); the rating bonus is the full spell-hit
-- value the client exposes (same as the character sheet's Spell Hit row).
local GetCombatRatingBonus = GetCombatRatingBonus
local CR_HIT_SPELL = CR_HIT_SPELL

local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, GetCombatRatingBonus(CR_HIT_SPELL))
end

local function ValueColorUpdate(hex)
	displayString = join("", L["Spell Hit"], ": ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Spell Hit", {"UNIT_STATS", "UNIT_AURA"}, OnEvent, nil, nil, nil, nil, L["Spell Hit"])
