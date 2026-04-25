local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitStat = UnitStat

local ITEM_MOD_STAMINA_SHORT = ITEM_MOD_STAMINA_SHORT

local displayString, db = ''

local function OnEvent(self)
	if db.NoLabel then
		self.text:SetFormattedText(displayString, UnitStat('player', 3))
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or ITEM_MOD_STAMINA_SHORT..': ', UnitStat('player', 3))
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
end

DT:RegisterDatatext('Stamina', L["Attributes"], { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, ITEM_MOD_STAMINA_SHORT, nil, ApplySettings)
