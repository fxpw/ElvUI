local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetDodgeChance = GetDodgeChance

local DODGE = DODGE
local DEFENSE = DEFENSE

local displayString = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, DODGE, GetDodgeChance())
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%s: ', hex, '%.f|r')
end

DT:RegisterDatatext('Dodge', DEFENSE, { 'UNIT_STATS', 'UNIT_AURA', 'SKILL_LINES_CHANGED' }, OnEvent, nil, nil, nil, nil, DODGE, nil, ApplySettings)

