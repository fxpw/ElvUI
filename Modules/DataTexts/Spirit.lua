local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local UnitStat = UnitStat

local ITEM_MOD_SPIRIT_SHORT = ITEM_MOD_SPIRIT_SHORT

local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, UnitStat("player", 5))
end

local function ValueColorUpdate(hex)
	displayString = join("", ITEM_MOD_SPIRIT_SHORT, ": ", hex, "%.f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Spirit", {"UNIT_STATS", "UNIT_AURA"}, OnEvent, nil, nil, nil, nil, ITEM_MOD_SPIRIT_SHORT)
