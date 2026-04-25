local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format
local tinsert = tinsert
local pairs = pairs
local wipe = wipe

local GetNumEquipmentSets = GetNumEquipmentSets
local GetEquipmentSetInfo = GetEquipmentSetInfo
local GetEquipmentSetItemIDs = GetEquipmentSetItemIDs
local GetInventoryItemID = GetInventoryItemID
local UseEquipmentSet = UseEquipmentSet

local eqSets = {}
local hexColor = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine('Equipment Sets')
	DT.tooltip:AddLine(' ')

	for _, set in pairs(eqSets) do
		DT.tooltip:AddLine(set.text, set.isEquipped and .2 or 1, set.isEquipped and 1 or .2, .2)
	end

	DT.tooltip:Show()
end

local function OnClick(self)
	E:SetEasyMenuAnchor(E.EasyMenu, self)
	_G.EasyMenu(eqSets, E.EasyMenu, nil, nil, nil, 'MENU')
end

local function OnEvent(self, event)
	if event == 'ELVUI_FORCE_UPDATE' or event == 'EQUIPMENT_SETS_CHANGED' or event == 'PLAYER_EQUIPMENT_CHANGED' then
		wipe(eqSets)
	end

    local numSets = GetNumEquipmentSets()
	local activeSetIndex
	for i = 1, numSets do
		local name, iconFileID, setID = GetEquipmentSetInfo(i)
        local items = GetEquipmentSetItemIDs(name)
		local isEquipped = true

		for slot, itemID in pairs(items) do
            if itemID then
                local equippedItemID = GetInventoryItemID('player', slot)
				equippedItemID = equippedItemID == nil and 0 or equippedItemID
                if equippedItemID ~= itemID then
                    isEquipped = false
                    break
                end
            end
        end

		if event == 'ELVUI_FORCE_UPDATE' or event == 'EQUIPMENT_SETS_CHANGED' or event == 'PLAYER_EQUIPMENT_CHANGED' then
			tinsert(eqSets, { text = format('|T%s:20:20:0:0:64:64:4:60:4:60|t  %s', iconFileID, name), checked = isEquipped, func = function() UseEquipmentSet(name) end, setID = setID, name = name, iconFileID = iconFileID, isEquipped = isEquipped })
		end

		if isEquipped then
			activeSetIndex = i
		end
	end

	local set = eqSets[activeSetIndex]
	if not activeSetIndex then
		self.text:SetText('No Set Equipped')
	elseif set then
		self.text:SetFormattedText('Set: %s%s|r |T%s:16:16:0:0:64:64:4:60:4:60|t', hexColor, set.name, set.iconFileID)
	end
end

local function ApplySettings(_, hex)
	hexColor = hex
end

DT:RegisterDatatext('Equipment Sets', nil, { 'EQUIPMENT_SETS_CHANGED', 'PLAYER_EQUIPMENT_CHANGED', 'EQUIPMENT_SWAP_FINISHED' }, OnEvent, nil, OnClick, OnEnter, nil, nil, nil, ApplySettings)
