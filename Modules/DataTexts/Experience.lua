local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local format = string.format
--WoW API / Variables
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local GetXPExhaustion = GetXPExhaustion

local CurrentXP, XPToLevel, RestedXP, PercentRested
local PercentXP, RemainXP, RemainTotal, RemainBars
local displayString = ""

local function OnEvent(self)
	if E.mylevel >= MAX_PLAYER_LEVEL then
		self.text:SetText(L["Max Level"])
		return
	end

	CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()

	local remainXP = XPToLevel - CurrentXP
	local remainPercent = E:Round(remainXP / XPToLevel, 4)

	-- values we also use in OnEnter
	RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
	PercentXP, RemainXP = E:Round(CurrentXP / XPToLevel, 4) * 100, E:ShortValue(remainXP)

	displayString = format("%s - %.2f%%", E:ShortValue(CurrentXP), PercentXP)

	if RestedXP and RestedXP > 0 then
		PercentRested = E:Round(RestedXP / XPToLevel, 4) * 100
		displayString = displayString..format(" R:%s [%.2f%%]", E:ShortValue(RestedXP), PercentRested)
	end

	self.text:SetText(displayString)
end

local function OnEnter(self)
	if E.mylevel >= MAX_PLAYER_LEVEL then return end

	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L["Experience"], format("%s %d", L["Level"], E.mylevel))
	DT.tooltip:AddLine(" ")

	DT.tooltip:AddDoubleLine(L["XP:"], format(" %s / %s (%.2f%%)", E:ShortValue(CurrentXP), E:ShortValue(XPToLevel), PercentXP), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Remaining:"], format(" %s (%.2f%% - %.2f "..L["Bars"]..")", RemainXP, RemainTotal, RemainBars), 1, 1, 1)

	if RestedXP and RestedXP > 0 then
		DT.tooltip:AddDoubleLine(L["Rested:"], format("+%s (%.2f%%)", E:ShortValue(RestedXP), PercentRested), 1, 1, 1)
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext("Experience", {"PLAYER_XP_UPDATE", "DISABLE_XP_GAIN", "ENABLE_XP_GAIN", "UPDATE_EXHAUSTION", "PLAYER_LEVEL_UP", "PLAYER_ENTERING_WORLD"}, OnEvent, nil, nil, OnEnter, nil, _G.COMBAT_XP_GAIN)
