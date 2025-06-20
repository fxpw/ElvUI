local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local strjoin = strjoin

local displayString = ''
local APRating = 0

local function OnEvent(self)
	APRating = GetCombatRating(25)

	self.text:SetFormattedText(displayString, APRating)
end

local function ApplySettings(_, hex)
	displayString = strjoin('', 'РПБ: ', '%d')
end

E.valueColorUpdateFuncs[ApplySettings] = true

DT:RegisterDatatext("Armor Penetration", { "UNIT_STATS", "UNIT_AURA", "PLAYER_EQUIPMENT_CHANGED" }, OnEvent, nil, nil, nil, nil, 'РПБ')
