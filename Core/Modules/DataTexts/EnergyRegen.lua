local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetPowerRegen = GetPowerRegen

local displayString = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, L["Energy Regen"], GetPowerRegen())
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%s: ', hex, '%.f|r')
end

DT:RegisterDatatext('EnergyRegen', L["Enhancements"], { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, L["Energy Regen"], nil, ApplySettings)
