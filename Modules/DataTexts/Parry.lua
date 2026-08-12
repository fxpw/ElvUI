local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local GetParryChance = GetParryChance

local PARRY = PARRY

local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, GetParryChance())
end

local function ValueColorUpdate(hex)
	displayString = join("", PARRY, ": ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Parry", {"UNIT_STATS", "UNIT_AURA", "SKILL_LINES_CHANGED"}, OnEvent, nil, nil, nil, nil, PARRY)
