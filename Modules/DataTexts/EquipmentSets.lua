local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local format = string.format
local tinsert = table.insert
local pairs = pairs
local wipe = table.wipe
--WoW API / Variables
local GetNumEquipmentSets = GetNumEquipmentSets
local GetEquipmentSetInfo = GetEquipmentSetInfo
local GetEquipmentSetItemIDs = GetEquipmentSetItemIDs
local GetInventoryItemID = GetInventoryItemID
local UseEquipmentSet = UseEquipmentSet
local CreateFrame = CreateFrame

local eqSets = {}
local displayString = ""
local hexColor = ""
local lastPanel

local dropdown = CreateFrame("Frame", "ElvUI_EquipmentSetsDropDown", E.UIParent)

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddLine(L["Equipment Sets"])
	DT.tooltip:AddLine(" ")

	for _, set in pairs(eqSets) do
		DT.tooltip:AddLine(set.text, set.isEquipped and .2 or 1, set.isEquipped and 1 or .2, .2)
	end

	DT.tooltip:Show()
end

local function OnClick(self, button)
	if button == "LeftButton" then
		E:DropDown(eqSets, dropdown)
	end
end

local function OnEvent(self, event)
	lastPanel = self

	if event == "ELVUI_FORCE_UPDATE" or event == "ELVUI_FORCE_RUN" or event == "EQUIPMENT_SETS_CHANGED" or event == "PLAYER_EQUIPMENT_CHANGED" then
		wipe(eqSets)
	end

	local numSets = GetNumEquipmentSets()
	local activeSetIndex
	for i = 1, numSets do
		local name, iconFileID = GetEquipmentSetInfo(i)
		local items = GetEquipmentSetItemIDs(name)
		local isEquipped = true

		for slot, itemID in pairs(items) do
			if itemID then
				local equippedItemID = GetInventoryItemID("player", slot)
				equippedItemID = equippedItemID == nil and 0 or equippedItemID
				if equippedItemID ~= itemID then
					isEquipped = false
					break
				end
			end
		end

		if event == "ELVUI_FORCE_UPDATE" or event == "ELVUI_FORCE_RUN" or event == "EQUIPMENT_SETS_CHANGED" or event == "PLAYER_EQUIPMENT_CHANGED" then
			tinsert(eqSets, { text = format("|T%s:20:20:0:0:64:64:4:60:4:60|t  %s", iconFileID, name), func = function() UseEquipmentSet(name) end, isEquipped = isEquipped })
		end

		if isEquipped then
			activeSetIndex = i
		end
	end

	local set = eqSets[activeSetIndex]
	if not activeSetIndex then
		self.text:SetText(L["No Set Equipped"])
	elseif set then
		self.text:SetFormattedText(displayString, set.text)
	end
end

local function ValueColorUpdate(hex)
	hexColor = hex
	displayString = hexColor.."%s|r"

	if lastPanel ~= nil then
		OnEvent(lastPanel, "ELVUI_COLOR_UPDATE")
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Equipment Sets", {"EQUIPMENT_SETS_CHANGED", "PLAYER_EQUIPMENT_CHANGED", "EQUIPMENT_SWAP_FINISHED"}, OnEvent, nil, OnClick, OnEnter, nil, L["Equipment Sets"])
