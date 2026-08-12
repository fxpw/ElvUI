local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local select, wipe = select, wipe
local format, join, strmatch = string.format, string.join, string.match
--WoW API / Variables
local GetAuctionItemSubClasses = GetAuctionItemSubClasses
local GetItemInfo = GetItemInfo
local GetItemCount = GetItemCount
local GetInventoryItemCount = GetInventoryItemCount
local GetInventoryItemID = GetInventoryItemID
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerItemInfo = GetContainerItemInfo
local GetItemQualityColor = GetItemQualityColor

local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local INVTYPE_AMMO = INVTYPE_AMMO
local INVSLOT_RANGED = INVSLOT_RANGED
local INVSLOT_AMMO = INVSLOT_AMMO
local NOT_APPLICABLE = NOT_APPLICABLE
local CURRENTLY_EQUIPPED = CURRENTLY_EQUIPPED

local QUIVER = select(1, GetAuctionItemSubClasses(8))
local POUCH = select(2, GetAuctionItemSubClasses(8))
local SOULBAG = select(2, GetAuctionItemSubClasses(3))

local iconString = "|T%s:24:24:0:0:64:64:4:55:4:55|t"
local displayString = ""
local itemName = {}

local waitingItemID
local function OnEvent(self, event, ...)
	local name, count, itemID, itemEquipLoc

	if event == "GET_ITEM_INFO_RECEIVED" then
		itemID = ...

		if itemID ~= waitingItemID then return end
		waitingItemID = nil

		if not itemName[itemID] then
			itemName[itemID] = GetItemInfo(itemID)
		end

		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	end

	if E.myclass == "WARLOCK" then
		itemID = 6265 -- осколок души
		name, count = itemName[itemID] or GetItemInfo(itemID), GetItemCount(itemID)

		if name and not itemName[itemID] then
			itemName[itemID] = name
		end

		self.text:SetFormattedText(displayString, name or "Soul Shard", count or 0)
	else
		local RangeItemID = GetInventoryItemID("player", INVSLOT_RANGED)
		if RangeItemID then
			itemEquipLoc = select(9, GetItemInfo(RangeItemID))
		end

		if itemEquipLoc == "INVTYPE_THROWN" then
			itemID, count = RangeItemID, GetInventoryItemCount("player", INVSLOT_RANGED)
		else
			itemID, count = GetInventoryItemID("player", INVSLOT_AMMO), GetInventoryItemCount("player", INVSLOT_AMMO)
		end

		if (itemID and itemID > 0) and (count and count > 0) then
			if itemID then
				name = itemName[itemID] or GetItemInfo(itemID)
			end
			if name and not itemName[itemID] then
				itemName[itemID] = name
			end
			self.text:SetFormattedText(displayString, name or INVTYPE_AMMO, count or 0)
		else
			self.text:SetFormattedText(displayString, INVTYPE_AMMO, 0)
		end
	end

	if not name then
		waitingItemID = itemID
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	end
end

local itemCount = {}
local totalItemCount = 0
local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:ClearLines()

	if E.myclass == "HUNTER" or E.myclass == "ROGUE" or E.myclass == "WARRIOR" then
		wipe(itemCount)
		totalItemCount = 0
		DT.tooltip:AddLine(INVTYPE_AMMO)

		for containerIndex = 0, NUM_BAG_FRAMES do
			for slotIndex = 1, GetContainerNumSlots(containerIndex) do
				local texture, count, _, _, _, _, link = GetContainerItemInfo(containerIndex, slotIndex)
				if link then
					local name, _, quality, _, _, _, _, _, equipLoc = GetItemInfo(link)
					local itemID = strmatch(link, "item:(%d+)")
					if equipLoc == "INVTYPE_AMMO" or equipLoc == "INVTYPE_THROWN" then
						if not itemCount[itemID] then
							DT.tooltip:AddDoubleLine(join("", format(iconString, texture), " ", name), count or 0, GetItemQualityColor(quality or 1))
							itemCount[itemID] = count or 0
							totalItemCount = totalItemCount + 1
						end
					end
				end
			end
		end

		if totalItemCount == 0 then
			DT.tooltip:AddLine(NOT_APPLICABLE)
		end

		local itemID = GetInventoryItemID("player", 18) -- оружие дальнего боя
		if itemID then
			local name, _, quality, _, _, _, _, _, equipLoc, texture = GetItemInfo(itemID)
			local count = GetItemCount(itemID)
			itemCount[itemID] = count
			if equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_THROWN" then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(CURRENTLY_EQUIPPED)
				DT.tooltip:AddDoubleLine(join("", format(iconString, texture), " ", name), count, GetItemQualityColor(quality or 1))
			end
		end
	end

	for i = 1, NUM_BAG_SLOTS do
		local itemID = GetInventoryItemID("player", ContainerIDToInventoryID(i))
		if itemID then
			local name, _, quality, _, _, itemType, itemSubType, _, _, texture = GetItemInfo(itemID)
			if (itemSubType == QUIVER or itemSubType == POUCH or itemSubType == SOULBAG) or (itemType == "Container" and (itemSubType == QUIVER or itemSubType == POUCH or itemSubType == SOULBAG)) then
				local free, total = GetContainerNumFreeSlots(i), GetContainerNumSlots(i)
				local used = total - free

				DT.tooltip:AddLine(itemSubType)
				DT.tooltip:AddDoubleLine(join("", format(iconString, texture), "  ", name), format("%d / %d", used, total), GetItemQualityColor(quality or 1))
			end
		end
	end

	DT.tooltip:Show()
end

local function OnClick(_, btn)
	if btn == "LeftButton" then
		if not E.private.bags.enable then
			for i = 1, NUM_BAG_SLOTS do
				local itemID = GetInventoryItemID("player", ContainerIDToInventoryID(i))
				if itemID then
					local itemType, itemSubType = select(6, GetItemInfo(itemID))
					if (itemSubType == QUIVER or itemSubType == POUCH or itemSubType == SOULBAG) or (itemType == "Container" and (itemSubType == QUIVER or itemSubType == POUCH or itemSubType == SOULBAG)) then
						_G.ToggleBag(i)
					end
				end
			end
		else
			_G.ToggleAllBags()
		end
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d|r")
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Ammo", {"BAG_UPDATE", "UNIT_INVENTORY_CHANGED"}, OnEvent, nil, OnClick, OnEnter, nil, L["Ammo/Shard Counter"])
