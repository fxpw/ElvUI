local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local LCG = E.Libs.CustomGlow
local LC = E.Libs.Compat

local _G = _G
local unpack, select = unpack, select

local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootSlotInfo = LC.GetLootSlotInfo
local IsFishingLoot = IsFishingLoot
local LootSlotIsCoin = LootSlotIsCoin
local LootSlotIsItem = LootSlotIsItem
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName

local ITEMS = ITEMS
local LOOT = LOOT
local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS

function S:LootFrame()
	if E.private.general.loot then return end
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.loot then return end

	local LootFrame = _G.LootFrame
	S:HandleFrame(LootFrame, true)
	LootFrame:Height(LootFrame:GetHeight() - 30)
	_G.LootFramePortraitOverlay:SetParent(E.HiddenFrame)

	for _, region in next, { LootFrame:GetRegions() } do
		if region:IsObjectType('FontString') and region:GetText() == ITEMS then
			LootFrame.Title = region
		end
	end

	LootFrame.Title:ClearAllPoints()
	LootFrame.Title:Point('TOPLEFT', LootFrame, 'TOPLEFT', 4, -4)
	LootFrame.Title:SetJustifyH('LEFT')

	for i = 1, _G.LOOTFRAME_NUMBUTTONS do
		local button = _G['LootButton'..i]
		_G['LootButton'..i..'NameFrame']:Hide()

		S:HandleItemButton(button, true)
		S:HandleIconBorder(button.IconBorder, button.backdrop)

		button:NudgePoint(nil, 30, nil, nil, true)
	end

	hooksecurefunc('LootFrame_UpdateButton', function(index)
		local numLootItems = LootFrame.numLootItems
		--Logic to determine how many items to show per page
		local numLootToShow = _G.LOOTFRAME_NUMBUTTONS
		if LootFrame.AutoLootTable then
			numLootItems = #LootFrame.AutoLootTable
		end
		if numLootItems > _G.LOOTFRAME_NUMBUTTONS then
			numLootToShow = numLootToShow - 1 -- Make space for the page buttons
		end

		local button = _G['LootButton'..index]
		local slot = (numLootToShow * (LootFrame.page - 1)) + index
		if button and button:IsShown() then
			local texture, _, isQuestItem, questId, isActive
			if LootFrame.AutoLootTable then
				local entry = LootFrame.AutoLootTable[slot]
				if entry.hide then
					button:Hide()
					return
				else
					texture = entry.texture
					isQuestItem = entry.isQuestItem
					questId = entry.questId
					isActive = entry.isActive
				end
			else
				texture, _, _, _, _, _, isQuestItem, questId, isActive = GetLootSlotInfo(slot)
			end

			if texture then
				if questId and not isActive then
					LCG.ShowOverlayGlow(button)
				elseif questId or isQuestItem then
					LCG.ShowOverlayGlow(button)
				else
					LCG.HideOverlayGlow(button)
				end
			end
		end
	end)

	LootFrame:HookScript('OnShow', function(frame)
		if IsFishingLoot() then
			frame.Title:SetText(L["Fishy Loot"])
		elseif not UnitIsFriend('player', 'target') and UnitIsDead('target') then
			frame.Title:SetText(UnitName('target'))
		else
			frame.Title:SetText(LOOT)
		end
	end)

	S:HandleNextPrevButton(_G.LootFrameDownButton)
	S:HandleNextPrevButton(_G.LootFrameUpButton)
end

S:AddCallback('LootFrame')