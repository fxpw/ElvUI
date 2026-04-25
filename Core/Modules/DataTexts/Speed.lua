local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local LC = E.Libs.Compat

local format, strjoin = format, strjoin

local BreakUpLargeNumbers = LC.BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local UnitAttackSpeed = UnitAttackSpeed

local SPEED = SPEED
local CR_HIT_TAKEN_SPELL = CR_HIT_TAKEN_SPELL
local CR_SPEED_TOOLTIP = SPEED..': %s [+%.2f%%]'
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT

local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, SPEED)..' '..format('%.2f%%', UnitAttackSpeed('player'))..FONT_COLOR_CODE_CLOSE, nil, 1, 1, 1)
	DT.tooltip:AddLine(format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_HIT_TAKEN_SPELL)), GetCombatRatingBonus(CR_HIT_TAKEN_SPELL)), nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	local speed = UnitAttackSpeed('player')
	if db.NoLabel then
		self.text:SetFormattedText(displayString, speed)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or SPEED, speed)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s:', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Speed', L["Enhancements"], { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS' }, OnEvent, nil, nil, OnEnter, nil, SPEED, nil, ApplySettings)
