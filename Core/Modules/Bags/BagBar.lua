local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Bags')
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local _G = _G
local gsub = gsub
local ipairs = ipairs
local unpack = unpack
local tinsert = tinsert

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver

local BACKPACK_CONTAINER = BACKPACK_CONTAINER
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local commandNames = {
	[-1] = 'TOGGLEBACKPACK',
	[0] = 'TOGGLEBAG4',
	'TOGGLEBAG3',	-- 1
	'TOGGLEBAG2',	-- 2
	'TOGGLEBAG1'	-- 3
}

local function CalculateTotalNumberOfFreeBagSlots()
	local totalFree, freeSlots, bagFamily = 0
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		freeSlots, bagFamily = GetContainerNumFreeSlots(i)
		if bagFamily == 0 then
			totalFree = totalFree + freeSlots
		end
	end

	return totalFree
end

function B:BagBar_OnEnter()
	return B.BagBar.db.mouseover and E:UIFrameFadeIn(B.BagBar, 0.2, B.BagBar:GetAlpha(), 1)
end

function B:BagBar_OnLeave()
	return B.BagBar.db.mouseover and E:UIFrameFadeOut(B.BagBar, 0.2, B.BagBar:GetAlpha(), 0)
end

function B:BagButton_OnEnter()
	-- bag keybind support from actionbar module
	if E.private.actionbar.enable then
		AB:BindUpdate(self)
	end

	if not B.BagBar.db.justBackpack and B.BagFrame and B:IsBagShown(self.BagID) then
		B:SetSlotAlphaForBag(B.BagFrame, self.BagID)
	end

	B:BagBar_OnEnter()
end

function B:BagButton_OnLeave()
	if not B.BagBar.db.justBackpack and B.BagFrame then
		B:ResetSlotAlphaForBags(B.BagFrame)
	end

	B:BagBar_OnLeave()
end

function B:KeyRing_OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	GameTooltip:AddLine(_G.KEYRING, 1, 1, 1)
	GameTooltip:Show()

	if B.BagFrame and B:IsBagShown(self.BagID) then
		B:SetSlotAlphaForBag(B.BagFrame, self.BagID)
	end

	B:BagBar_OnEnter()
end

function B:BagBar_OnEvent(event)
	B:BagBar_UpdateVisibility()
	B.BagBar:UnregisterEvent(event)
end

function B:KeyRing_OnLeave()
	GameTooltip:Hide()

	if B.BagFrame then
		B:ResetSlotAlphaForBags(B.BagFrame)
	end

	B:BagBar_OnEnter()
end

function B:SkinBag(bag)
	local icon = bag.icon or _G[bag:GetName()..'IconTexture']
	bag.oldTex = icon:GetTexture()

	bag:StripTextures(false)
	bag:SetTemplate()
	bag:StyleButton(true)

	if bag.searchOverlay then
		bag.searchOverlay:SetColorTexture(0, 0, 0, 0.6)
	end

	if icon then
		icon:SetInside()
		icon:SetTexture((not bag.oldTex or bag.oldTex == [[Interface\MainMenuBar\UI-MainMenuBar-Dwarf]]) and E.Media.Textures.Backpack or bag.oldTex)
		icon:SetTexCoords()
	end
end

function B:BagBar_UpdateVisibility()
	local visibility = gsub(B.BagBar.db.visibility, '[\n\r]', '')
	RegisterStateDriver(B.BagBar, 'visibility', visibility)
end

function B:SizeAndPositionBagBar()
	if not B.BagBar then return end

	local db = B.BagBar.db
	local bagBarSize = db.size
	local buttonSpacing = db.spacing
	local growthDirection = db.growthDirection
	local sortDirection = db.sortDirection
	local showBackdrop = db.showBackdrop
	local justBackpack = db.justBackpack
	local backdropSpacing = not showBackdrop and 0 or db.backdropSpacing

	if InCombatLockdown() then
		B.BagBar:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		B:BagBar_UpdateVisibility()
	end

	B.BagBar:SetAlpha(db.mouseover and 0 or 1)

	_G.MainMenuBarBackpackButtonCount:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)

	local firstButton, lastButton
	for i, button in ipairs(B.BagBar.buttons) do
		button:Size(bagBarSize)
		button:ClearAllPoints()
		button:SetShown(not justBackpack or i == 1)

		if sortDirection == 'ASCENDING'then
			if i == 1 then firstButton = button else lastButton = button end
		else
			if i == 1 then lastButton = button else firstButton = button end
		end

		local prevButton = B.BagBar.buttons[i-1]
		if growthDirection == 'HORIZONTAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('LEFT', B.BagBar, 'LEFT', backdropSpacing, 0)
			elseif prevButton then
				button:Point('LEFT', prevButton, 'RIGHT', buttonSpacing, 0)
			end
		elseif growthDirection == 'VERTICAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('TOP', B.BagBar, 'TOP', 0, -backdropSpacing)
			elseif prevButton then
				button:Point('TOP', prevButton, 'BOTTOM', 0, -buttonSpacing)
			end
		elseif growthDirection == 'HORIZONTAL' and sortDirection == 'DESCENDING' then
			if i == 1 then
				button:Point('RIGHT', B.BagBar, 'RIGHT', -backdropSpacing, 0)
			elseif prevButton then
				button:Point('RIGHT', prevButton, 'LEFT', -buttonSpacing, 0)
			end
		else
			if i == 1 then
				button:Point('BOTTOM', B.BagBar, 'BOTTOM', 0, backdropSpacing)
			elseif prevButton then
				button:Point('BOTTOM', prevButton, 'TOP', 0, buttonSpacing)
			end
		end
	end

	local btnSize = bagBarSize * (NUM_BAG_FRAMES + 1)
	local btnSpace = buttonSpacing * NUM_BAG_FRAMES
	local bdpDoubled = backdropSpacing * 2

	B.BagBar.backdrop:ClearAllPoints()
	B.BagBar.backdrop:Point('TOPLEFT', firstButton, 'TOPLEFT', -backdropSpacing, backdropSpacing)
	B.BagBar.backdrop:Point('BOTTOMRIGHT', justBackpack and firstButton or lastButton, 'BOTTOMRIGHT', backdropSpacing, -backdropSpacing)
	B.BagBar.backdrop:SetShown(showBackdrop)

	if growthDirection == 'HORIZONTAL' then
		B.BagBar:Size(btnSize + btnSpace + bdpDoubled, bagBarSize + bdpDoubled)
	else
		B.BagBar:Size(bagBarSize + bdpDoubled, btnSize + btnSpace + bdpDoubled)
	end

	B.BagBar.mover:SetSize(B.BagBar.backdrop:GetSize())
	B:UpdateMainButtonCount()
end

function B:UpdateMainButtonCount()
	local mainCount = _G[B.BagBar.buttons[1]:GetName()..'Count']
	mainCount:SetShown(B.BagBar.db.showCount)
	mainCount:SetText(CalculateTotalNumberOfFreeBagSlots())
end

function B:BackpackButton_OnClick()
	if IsModifiedClick('OPENALLBAGS') then
		_G.ToggleAllBags() -- dont cache, see below
	elseif not PutItemInBackpack() then
		_G.ToggleBag(self.BagID) -- dont cache, bag module hooks
	end
end

function B:BagButton_UpdateTextures()
	local pushed = self:GetPushedTexture()
	pushed:SetInside()
	pushed:SetTexture(0.9, 0.8, 0.1, 0.3)

	if self.SlotHighlightTexture then
		self.SlotHighlightTexture:SetTexture(1, 1, 1, 0.3)
		self.SlotHighlightTexture:SetInside()
	end
end

function B:BagBar_UpdateDesaturated(inactive)
	if inactive == nil then -- Determine if we are in a "partial" state (not all bags shown, but not zero either)
		inactive = B:AnyBagsShown() and not B:AllBagsShown()
	end

	-- Now, apply the appearance to each button
	for _, button in ipairs(B.BagBar.buttons) do
		local shown = B:IsBagShown(button.BagID)
		local desaturate = inactive and not shown

		local icon = button.icon or _G[button:GetName()..'IconTexture']
		if icon then
			icon:SetDesaturated(desaturate)
		end

		if button.searchOverlay then
			button.searchOverlay:SetShown(desaturate)
		end
	end
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then return end

	B.BagBar = CreateFrame('Frame', 'ElvUIBagBar', E.UIParent)
	B.BagBar:Point('TOPRIGHT', _G.RightChatPanel, 'TOPLEFT', -4, 0)
	B.BagBar:CreateBackdrop(E.db.bags.transparent and 'Transparent', nil, nil, nil, nil, nil, nil, true)
	B.BagBar:SetScript('OnEnter', B.BagBar_OnEnter)
	B.BagBar:SetScript('OnLeave', B.BagBar_OnLeave)
	B.BagBar:SetScript('OnEvent', B.BagBar_OnEvent)
	B.BagBar:EnableMouse(true)
	B.BagBar.db = E.db.bags.bagBar
	B.BagBar.buttons = {}

	_G.MainMenuBarBackpackButton:SetParent(B.BagBar)
	_G.MainMenuBarBackpackButton:ClearAllPoints()
	_G.MainMenuBarBackpackButton:HookScript('OnEnter', B.BagButton_OnEnter)
	_G.MainMenuBarBackpackButton:HookScript('OnLeave', B.BagButton_OnLeave)

	_G.MainMenuBarBackpackButtonCount:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:Point('BOTTOMRIGHT', _G.MainMenuBarBackpackButton, 0, 1)
	_G.MainMenuBarBackpackButtonCount:FontTemplate(LSM:Fetch('font', B.BagBar.db.font), B.BagBar.db.fontSize, B.BagBar.db.fontOutline)

	_G.MainMenuBarBackpackButton.commandName = commandNames[-1]

	if _G.BagBarExpandToggle then
		_G.BagBarExpandToggle:Kill()
	end

	tinsert(B.BagBar.buttons, _G.MainMenuBarBackpackButton)
	B:SkinBag(_G.MainMenuBarBackpackButton)
	B.BagButton_UpdateTextures(_G.MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES-1 do
		local b = _G['CharacterBag'..i..'Slot']
		b:HookScript('OnEnter', B.BagButton_OnEnter)
		b:HookScript('OnLeave', B.BagButton_OnLeave)
		b:SetParent(B.BagBar)
		B:SkinBag(b)

		B.BagButton_UpdateTextures(b)

		b.commandName = commandNames[i]

		tinsert(B.BagBar.buttons, b)
	end

	local KeyRing = _G.KeyRingButton
	if KeyRing then
		KeyRing:SetParent(B.BagBar)
		KeyRing:SetScript('OnEnter', B.KeyRing_OnEnter)
		KeyRing:SetScript('OnLeave', B.KeyRing_OnLeave)

		KeyRing:StripTextures()
		KeyRing:SetTemplate(nil, true)
		KeyRing:StyleButton(true)

		B:SetButtonTexture(KeyRing, [[Interface\ICONS\INV_Misc_Key_03]])

		KeyRing.icon = KeyRing:GetNormalTexture()

		if not KeyRing.searchOverlay then
			KeyRing.searchOverlay = KeyRing:CreateTexture(nil, 'OVERLAY', nil, 1)
			KeyRing.searchOverlay:SetInside()
			KeyRing.searchOverlay:Hide()
		end

		KeyRing.searchOverlay:SetTexture(0, 0, 0, 0.6)

		tinsert(B.BagBar.buttons, KeyRing)
	end

	for i, button in ipairs(B.BagBar.buttons) do
		if button == KeyRing then
			button.BagID = KEYRING_CONTAINER
		else
			local bagID = i - 1
			button.BagID = bagID

			if button.BagID == BACKPACK_CONTAINER then
				button:SetScript('OnClick', B.BackpackButton_OnClick)
			end
		end
	end

	E:CreateMover(B.BagBar, 'BagsMover', L["Bag Bar"], nil, nil, nil, nil, nil, 'bags,general')
	B.BagBar:SetPoint('BOTTOMLEFT', B.BagBar.mover)
	B:RegisterEvent('BAG_UPDATE', 'UpdateMainButtonCount')
	B:SizeAndPositionBagBar()
end
