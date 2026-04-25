local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format, strjoin = format, strjoin

local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local UnitAttackSpeed = UnitAttackSpeed
local UnitRangedDamage = UnitRangedDamage

local ATTACK_SPEED = ATTACK_SPEED
local CR_HASTE_MELEE = CR_HASTE_MELEE
local CR_HASTE_RANGED = CR_HASTE_RANGED
local CR_HASTE_RATING_TOOLTIP = CR_HASTE_RATING_TOOLTIP
local CR_HASTE_SPELL = CR_HASTE_SPELL
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local SPELL_HASTE = SPELL_HASTE
local SPELL_HASTE_ABBR = SPELL_HASTE_ABBR
local SPELL_HASTE_TOOLTIP = SPELL_HASTE_TOOLTIP

local haste
local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local text, tooltip
	if E.Role == 'Caster' then
		text = format('%s %d', SPELL_HASTE, haste)
		tooltip = format(SPELL_HASTE_TOOLTIP, GetCombatRatingBonus(CR_HASTE_SPELL))
	elseif E.myclass == 'HUNTER' then
		text = format('%s %.2f', format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED), UnitRangedDamage('player'))
		tooltip = format(CR_HASTE_RATING_TOOLTIP, haste, GetCombatRatingBonus(CR_HASTE_RANGED))
	else
		local speed, offhandSpeed = UnitAttackSpeed('player')

		if offhandSpeed then
			text = format('%s %.2f / %.2f', format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED), speed, offhandSpeed)
		else
			text = format('%s %.2f', format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED), speed)
		end

		tooltip = format(CR_HASTE_RATING_TOOLTIP, haste, GetCombatRatingBonus(CR_HASTE_MELEE))
	end

	DT.tooltip:AddLine(text, 1, 1, 1)
	DT.tooltip:AddLine(tooltip, nil, nil, nil, 1)

	DT.tooltip:Show()
end

local function OnEvent(self)
	if E.Role == 'Caster' then
		haste = GetCombatRating(CR_HASTE_SPELL)
	elseif E.myclass == 'HUNTER' then
		haste = GetCombatRating(CR_HASTE_RANGED)
	else
		haste = GetCombatRating(CR_HASTE_MELEE)
	end

	if db.NoLabel then
		self.text:SetFormattedText(displayString, haste)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or SPELL_HASTE_ABBR..': ', haste)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext(SPELL_HASTE_ABBR, L["Enhancements"], { 'SPELL_UPDATE_USABLE', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'UNIT_ATTACK_SPEED', 'UNIT_SPELL_HASTE' }, OnEvent, nil, nil, OnEnter, nil, SPELL_HASTE, nil, ApplySettings)
