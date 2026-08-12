local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local GetDodgeChance = GetDodgeChance

local DODGE = DODGE

local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, GetDodgeChance())
end

local function ValueColorUpdate(hex)
	displayString = join("", DODGE, ": ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Dodge", {"UNIT_STATS", "UNIT_AURA", "SKILL_LINES_CHANGED"}, OnEvent, nil, nil, nil, nil, DODGE)
