local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local UnitStat = UnitStat

local ITEM_MOD_AGILITY_SHORT = ITEM_MOD_AGILITY_SHORT
local LE_UNIT_STAT_AGILITY = 2

local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, UnitStat("player", LE_UNIT_STAT_AGILITY))
end

local function ValueColorUpdate(hex)
	displayString = join("", ITEM_MOD_AGILITY_SHORT, ": ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Agility", {"UNIT_STATS", "UNIT_AURA"}, OnEvent, nil, nil, nil, nil, ITEM_MOD_AGILITY_SHORT)
