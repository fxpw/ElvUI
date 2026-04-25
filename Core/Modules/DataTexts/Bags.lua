local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local B = E:GetModule('Bags')

local _G = _G
local format, gsub, match = format, string.gsub, string.match
local strjoin = strjoin

local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture

local GetBagName = GetBagName
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local ContainerIDToInventoryID = ContainerIDToInventoryID

local CURRENCY = CURRENCY
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS or 3
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local displayString, db = ''
local iconString = '|T%s:20:20:0:0:64:64:4:60:4:60|t  %s'
local BAG_TYPES = {
	[0x0001] = 'Quiver',
	[0x0002] = 'Ammo Pouch',
	[0x0004] = 'Soul Bag',
}

local function OnEvent(self)
	local freeNormal, totalNormal = 0, 0
	for i = 0, NUM_BAG_SLOTS do
		local freeSlots, bagType = GetContainerNumFreeSlots(i)
		if not bagType or bagType == 0 then
			local totalSlots = GetContainerNumSlots(i)
			totalNormal = totalNormal + totalSlots
			freeNormal = freeNormal + freeSlots
		end
	end

	local textFormat = db.textFormat
	if textFormat == 'FREE' then
		self.text:SetFormattedText(displayString, freeNormal)
	elseif textFormat == 'USED' then
		self.text:SetFormattedText(displayString, totalNormal - freeNormal)
	elseif textFormat == 'USED_TOTAL' then
		self.text:SetFormattedText(displayString, totalNormal - freeNormal, totalNormal)
	else -- FREE_TOTAL
		self.text:SetFormattedText(displayString, freeNormal, totalNormal)
	end
end

local function OnClick()
	_G.ToggleAllBags()
end

local function OnEnter()
	DT.tooltip:ClearLines()

	for i = 0, NUM_BAG_SLOTS do
		local bagName = GetBagName(i)
		if bagName then
			local numSlots = GetContainerNumSlots(i)
			local freeSlots, bagType = GetContainerNumFreeSlots(i)
			local usedSlots = numSlots - freeSlots
			local r, g, b, r2, g2, b2, icon

			if BAG_TYPES[bagType] then -- reverse for ammo bags
				r2, g2, b2 = E:ColorGradient(usedSlots/numSlots, 1,.1,.1, 1,1,.1, .1,1,.1) -- red, yellow, green
			else
				r2, g2, b2 = E:ColorGradient(usedSlots/numSlots, .1,1,.1, 1,1,.1, 1,.1,.1) -- green, yellow, red
			end

			if i > 0 then
				local id = ContainerIDToInventoryID(i)
				r, g, b = E:GetItemQualityColor(GetInventoryItemQuality('player', id) or 1)
				icon = GetInventoryItemTexture('player', id)
			end

			DT.tooltip:AddDoubleLine(format(iconString, icon or E.Media.Textures.Backpack, bagName), format('%d / %d', usedSlots, numSlots), r or 1, g or 1, b or 1, r2, g2, b2)
		end
	end

	for i = 1, MAX_WATCHED_TOKENS do
		local info, name = DT:BackpackCurrencyInfo(i)
		if not name then break end

		if i == 1 then
			DT.tooltip:AddLine(' ')
			DT.tooltip:AddLine(CURRENCY)
			DT.tooltip:AddLine(' ')
		end

		if info.quantity then
			iconString = match(info and info.iconFileID or '', E.myfaction) ~= nil and gsub(iconString, '4:60:4:60', '4:38:2:36') or iconString
			DT.tooltip:AddDoubleLine(format(iconString, info.iconFileID, name), info.quantity, 1, 1, 1, 1, 1, 1)
		end
	end

	DT.tooltip:Show()
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	local name = (db.NoLabel and '') or (db.Label ~= '' and db.Label) or strjoin('', L["Bags"], ': ')
	if db.textFormat == 'FREE' or db.textFormat == 'USED' then
		displayString = strjoin('', name, hex, '%d|r')
	else
		displayString = strjoin('', name, hex, '%d/%d|r')
	end
end

DT:RegisterDatatext('Bags', nil, { 'BAG_UPDATE' }, OnEvent, nil, OnClick, OnEnter, nil, L["Bags"], nil, ApplySettings)
