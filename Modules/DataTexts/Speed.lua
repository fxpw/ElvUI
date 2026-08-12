local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local format, join = string.format, string.join
--WoW API / Variables
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local UnitAttackSpeed = UnitAttackSpeed

local SPEED = SPEED
local CR_HIT_TAKEN_SPELL = CR_HIT_TAKEN_SPELL
local CR_SPEED_TOOLTIP = CR_SPEED_TOOLTIP
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT

local displayString = ""
local lastPanel

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, SPEED).." "..format("%.2f%%", UnitAttackSpeed("player"))..FONT_COLOR_CODE_CLOSE, nil, 1, 1, 1)
	DT.tooltip:AddLine(format(CR_SPEED_TOOLTIP, GetCombatRating(CR_HIT_TAKEN_SPELL), GetCombatRatingBonus(CR_HIT_TAKEN_SPELL)), nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, UnitAttackSpeed("player"))
end

local function ValueColorUpdate(hex)
	displayString = join("", SPEED, ": ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Speed", {"UNIT_STATS", "UNIT_AURA", "PLAYER_DAMAGE_DONE_MODS"}, OnEvent, nil, nil, OnEnter, nil, SPEED)
