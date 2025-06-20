local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local strjoin = strjoin
local format = format

local CR_ARMOR_PENETRATION = CR_ARMOR_PENETRATION

local GetCombatRating = GetCombatRating

local displayString = ''
local APRating = 0

local function OnEvent(self)
	APRating = GetCombatRating(CR_ARMOR_PENETRATION)

	self.text:SetFormattedText(displayString, APRating)

	lastPanel = self
end

local function ApplySettings(_, hex)
	displayString = strjoin('', 'РПБ: ', '%d')
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end

E.valueColorUpdateFuncs[ApplySettings] = true

DT:RegisterDatatext("Armor Penetration", { "UNIT_STATS", "UNIT_AURA", "PLAYER_EQUIPMENT_CHANGED" }, OnEvent, nil, nil, nil, nil, 'Armor Penetration')
