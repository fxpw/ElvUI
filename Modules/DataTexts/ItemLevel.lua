local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local ipairs = ipairs
local format = string.format
--WoW API / Variables
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemTexture = GetInventoryItemTexture
local GetAverageItemLevel = GetAverageItemLevel
local GetItemLevelColor = GetItemLevelColor
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor

local GMSURVEYRATING3 = GMSURVEYRATING3

local displayString = ""
local iconString = "|T%s:24:24:0:0:50:50:4:46:4:46|t %s"
local slotID = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }
local r, g, b, avg = 1, 1, 1, 0
local lastPanel

local function OnEvent(self)
	lastPanel = self

	avg = GetAverageItemLevel()
	r, g, b = GetItemLevelColor(avg):GetRGB()

	self.text:SetFormattedText(displayString, avg or 0)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L["Item Level"], format("%0.2f", avg), 1, 1, 1, r, g, b)
	DT.tooltip:AddLine(" ")

	for _, k in ipairs(slotID) do
		local link = GetInventoryItemLink("player", k)
		if link then
			local _, _, rarity, ilvl = GetItemInfo(link)
			if ilvl then
				local icon = GetInventoryItemTexture("player", k)
				local slotR, slotG, slotB = GetItemQualityColor(rarity or 1)
				DT.tooltip:AddDoubleLine(format(iconString, icon, link), ilvl, 1, 1, 1, slotR, slotG, slotB)
			end
		end
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = format("|cFFFFFFFF%s|r: %s%%s|r", L["iLvL"], hex)

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Item Level", {"UNIT_INVENTORY_CHANGED", "PLAYER_EQUIPMENT_CHANGED"}, OnEvent, nil, nil, OnEnter, nil, L["Item Level"])
