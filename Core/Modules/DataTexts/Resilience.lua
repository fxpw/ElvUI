local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local min = min
local strjoin = strjoin
local format = format

local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetMaxCombatRatingBonus = GetMaxCombatRatingBonus

local STAT_RESILIENCE = STAT_RESILIENCE
local RESILIENCE_TOOLTIP = RESILIENCE_TOOLTIP
local COMBAT_RATING_RESILIENCE_CRIT_TAKEN = COMBAT_RATING_RESILIENCE_CRIT_TAKEN
local RESILIENCE_CRIT_CHANCE_TO_DAMAGE_REDUCTION_MULTIPLIER = RESILIENCE_CRIT_CHANCE_TO_DAMAGE_REDUCTION_MULTIPLIER
local RESILIENCE_CRIT_CHANCE_TO_CONSTANT_DAMAGE_REDUCTION_MULTIPLIER = RESILIENCE_CRIT_CHANCE_TO_CONSTANT_DAMAGE_REDUCTION_MULTIPLIER

local displayString = ''
local bonus, maxBonus = 0, 0

local function OnEvent(self)
	local melee = GetCombatRating(CR_CRIT_TAKEN_MELEE)
	local ranged = GetCombatRating(CR_CRIT_TAKEN_RANGED)
	local spell = GetCombatRating(CR_CRIT_TAKEN_SPELL)

	local resilience = min(melee, ranged)
	resilience = min(resilience, spell)

	local lowestRating = CR_CRIT_TAKEN_MELEE
	if ( melee == minResilience ) then
		lowestRating = CR_CRIT_TAKEN_MELEE
	elseif ( ranged == minResilience ) then
		lowestRating = CR_CRIT_TAKEN_RANGED
	else
		lowestRating = CR_CRIT_TAKEN_SPELL
	end

	bonus = GetCombatRatingBonus(lowestRating)
	maxBonus = GetMaxCombatRatingBonus(lowestRating)

	self.text:SetFormattedText(displayString, resilience)
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine(format(RESILIENCE_TOOLTIP, bonus, min(bonus * RESILIENCE_CRIT_CHANCE_TO_DAMAGE_REDUCTION_MULTIPLIER, maxBonus), bonus * RESILIENCE_CRIT_CHANCE_TO_CONSTANT_DAMAGE_REDUCTION_MULTIPLIER))

	DT.tooltip:Show()
end

local function ApplySettings(_, hex)
	displayString = strjoin('', STAT_RESILIENCE, ': ', hex, '%d|r')
end

DT:RegisterDatatext('Resilience', L["Enhancements"], { 'COMBAT_RATING_UPDATE' }, OnEvent, nil, nil, OnEnter, nil, STAT_RESILIENCE, nil, ApplySettings)
