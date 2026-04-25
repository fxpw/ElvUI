local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local LC = E.Libs.Compat

local ipairs = ipairs
local format = format

local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemTexture = GetInventoryItemTexture
local GetAverageItemLevel = LC.GetAverageItemLevel
local GetItemLevelColor = LC.GetItemLevelColor

local GMSURVEYRATING3 = GMSURVEYRATING3

local sameString = '%s: %s%0.2f|r'
local bothString = '%s: %s%0.2f|r / %s%0.2f|r'
local iconString = '|T%s:24:24:0:0:50:50:4:46:4:46|t %s'
local slotID = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }
local r, g, b, avg, avgEquipped, avgPvp = 1, 1, 1, 0, 0, 0
local db

local function OnEvent(self)
	avg, avgEquipped, avgPvp = GetAverageItemLevel()
	r, g, b = E:ColorizeItemLevel(avg)

	local hex = db.rarityColor and E:RGBToHex(r, g, b) or '|cFFFFFFFF'

	self.text:SetFormattedText((db.onlyEquipped or avg == avgEquipped) and sameString or bothString, L["iLvL"], hex, avgEquipped or 0, hex, avg or 0)
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddDoubleLine(L["Item Level"], format('%0.2f', avg), 1, 1, 1, r, g, b)
	DT.tooltip:AddDoubleLine(GMSURVEYRATING3, format('%0.2f', avgEquipped), 1, 1, 1, E:ColorizeItemLevel(avgEquipped - avg))
	DT.tooltip:AddDoubleLine(L["PVP Item Level"], format('%0.2f', avgPvp), 1, 1, 1, E:ColorizeItemLevel(avgPvp - avg))
	DT.tooltip:AddLine(" ")

	for _, k in ipairs(slotID) do
		local info = E:GetGearSlotInfo('player', k)
		local ilvl = (info and info ~= 'tooSoon') and info.iLvl
		if ilvl then
			local link = GetInventoryItemLink('player', k)
			local icon = GetInventoryItemTexture('player', k)
			DT.tooltip:AddDoubleLine(format(iconString, icon, link), ilvl, 1, 1, 1, E:ColorizeItemLevel(ilvl - avg))
		end
	end

	DT.tooltip:Show()
end

local function ApplySettings(self)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end
end

DT:RegisterDatatext('Item Level', 'Stats', { 'UNIT_INVENTORY_CHANGED', 'PLAYER_EQUIPMENT_CHANGED' }, OnEvent, nil, nil, OnEnter, nil, L["Item Level"], nil, ApplySettings)
