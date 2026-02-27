local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables
-- local function HookSubButtons()

-- 	if StoreRefreshTransmogListButton then
-- 		S:HandleButton(StoreRefreshTransmogListButton)
-- 	end
-- 	for _,v in pairs(StoreFrame.SubCategoryFrames or {}) do
-- 		S:HandleButton(v,true)
-- 		v.SelectedTexture:SetTexture(.9, .8, .1, .3)
-- 	end
-- end
local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.store ~= true then return end

	StoreFrame:HookScript("OnShow", function()
		StoreFrame:SetScale(UIParent:GetScale())
	end)
	StoreFrame:EnableMouse(true)
	StoreFrame:SetMovable(true)
	StoreFrame:RegisterForDrag("LeftButton")
	StoreFrame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	StoreFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local frame_x, frame_y = self:GetCenter()
		frame_x = frame_x*UIParent:GetScale() - GetScreenWidth() / 2
		frame_y = frame_y*UIParent:GetScale() - GetScreenHeight() / 2
		self:ClearAllPoints()
		self:SetPoint("CENTER", UIParent, "CENTER", frame_x, frame_y)
	end)


	if true then return end
	-- 	local goldBorderList = {
	-- 		"TopLeft",
	-- 		"TopRight",
	-- 		"BottomLeft",
	-- 		"BottomRight",
	-- 		"Top",
	-- 		"Left",
	-- 		"Right",
	-- 		"Bottom",
	-- 	}

	-- 	local function RemoveGoldBorder(frame)
	-- 		for _, parentKey in pairs(goldBorderList) do
	-- 			local region = frame[parentKey]
	-- 			if region then
	-- 				region:Hide()
	-- 			end
	-- 		end
	-- 	end

	-- 	StoreFrame:SetParent(UIParent)
	-- 	StoreFrame:SetScale(1)

	-- 	StoreFrame:StripTextures()
	-- 	StoreFrame:SetTemplate("Transparent")
	-- 	StoreFrame:SetFrameStrata("DIALOG")

	-- 	StoreFrameLeftInset:StripTextures()
	-- --	StoreFrameLeftInset:SetTemplate("Transparent")

	-- 	StoreFrameRightInset:StripTextures()
	-- --	StoreFrameRightInset:SetTemplate("Transparent")

	-- 	StoreFrameTopInset:StripTextures()
	-- 	--StoreFrameTopInset:SetTemplate("Transparent")

	-- 	StoreRefundButton:SetPoint("BOTTOM", 0, 8)
	-- 	S:HandleButton(StoreRefundButton)

	-- 	for i = 1, 4 do
	-- 		local button = _G["StoreMoneyButton"..i]
	-- 		button:CreateBackdrop("Transparent")
	-- 		button.backdrop:Point("TOPLEFT", 28, -7)
	-- 		button.backdrop:Point("BOTTOMRIGHT", -10, 7)

	-- 		button.Background:SetAlpha(0)
	-- 		button.Highlight:SetTexture(1, 1, 1)
	-- 		button.Highlight:SetVertexColor(1, 1, 1, .3)
	-- 		button.Highlight:SetInside(button.backdrop)
	-- 		button.Selected:SetTexture(0.9, 0.8, 0.1)
	-- 		button.Selected:SetVertexColor(1, 1, 1, .3)
	-- 		button.Selected:SetInside(button.backdrop)

	-- 		button.Icon:Size(20)
	-- 		button.Icon:ClearAllPoints()
	-- 		button.Icon:Point("LEFT", 6, 0)
	-- 		button.Icon:SetDrawLayer("BORDER")
	-- 		button.Icon:SetTexCoord(0.296875, 0.703125, 0.3125, 0.71875)

	-- 		button.iconBackdrop = CreateFrame("Frame", nil, button)
	-- 		button.iconBackdrop:SetTemplate()
	-- 		button.iconBackdrop:SetOutside(button.Icon)
	-- 		button.Icon:SetParent(button.iconBackdrop)
	-- 	end

	-- 	StorePremiumButtons:SetSize(143, 36)
	-- 	StorePremiumButtons:ClearAllPoints()
	-- 	StorePremiumButtons:SetPoint("LEFT", StoreMoneyButton4, "RIGHT", 1, 0)
	-- 	StorePremiumButtons:CreateBackdrop("Transparent")
	-- 	StorePremiumButtons.backdrop:Point("TOPLEFT", 28, -7)
	-- 	StorePremiumButtons.backdrop:Point("BOTTOMRIGHT", -10, 7)

	-- 	StorePremiumButtons.Background:SetAlpha(0)
	-- 	StorePremiumButtons.Border:SetAlpha(0)
	-- 	StorePremiumButtons.BorderHighlight:SetAlpha(0)
	-- 	StorePremiumButtons.IconBorder:SetAlpha(0)
	-- 	StorePremiumButtons.IconBorderHighlight:SetAlpha(0)
	-- 	StorePremiumButtons.Text:SetPoint("CENTER", 6, 0)

	-- 	StorePremiumButtons.Icon:Size(20)
	-- 	StorePremiumButtons.Icon:Point("LEFT", 6, 0)
	-- 	StorePremiumButtons.Icon:SetTexture("INTERFACE\\ICONS\\VIP")
	-- 	StorePremiumButtons.Icon:SetTexCoord(unpack(E.TexCoords))

	-- 	StorePremiumButtons.iconBackdrop = CreateFrame("Frame", nil, StorePremiumButtons)
	-- 	StorePremiumButtons.iconBackdrop:SetTemplate()
	-- 	StorePremiumButtons.iconBackdrop:SetOutside(StorePremiumButtons.Icon)
	-- 	StorePremiumButtons.Icon:SetParent(StorePremiumButtons.iconBackdrop)

	-- 	S:HandleCloseButton(StoreFrameCloseButton)

	-- 	-- StoreItemListFrame
	-- 	S:HandleScrollBar(StoreItemListScrollFrameScrollBar)
	-- 	StoreItemListScrollFrameScrollBar.BG:SetAlpha(0)

	-- 	for i = 1, #StoreItemListScrollFrame.buttons do
	-- 		local button = StoreItemListScrollFrame.buttons[i]

	-- 		button.Background:SetAlpha(0)
	-- 		button.Shadow:SetAlpha(0)
	-- 		button.IconBorder:SetAlpha(0)

	-- 		button:SetTemplate("Transparent")

	-- 		S:HandleIcon(button.Icon)
	-- 		button.Count:SetParent(button.backdrop)

	-- 		button.Highlight = button:GetHighlightTexture()
	-- 		button.Highlight:SetTexture(E.Media.Textures.Highlight)
	-- 		button.Highlight:SetTexCoord(0, 1, 0, 1)
	-- 		button.Highlight:SetInside()
	-- 	end

	-- 	local function StoreFrame_UpdateItemList()
	-- 		local buttons = StoreItemListScrollFrame.buttons

	-- 		for i = 1, #buttons do
	-- 			local button = buttons[i]
	-- 			local data = button.data
	-- 			if data then
	-- 				if data.Quality then
	-- 					local r, g, b = GetItemQualityColor(data.Quality)
	-- 					button.backdrop:SetBackdropBorderColor(r, g, b)
	-- 					button.Highlight:SetVertexColor(r, g, b, .35)
	-- 				else
	-- 					button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	-- 					button.Highlight:SetVertexColor(1, 1, 1, .35)
	-- 				end

	-- 				SetPortraitToTexture(button.Icon, "")
	-- 				button.Icon:SetTexture(data.Texture)
	-- 				button.Icon:SetTexCoord(unpack(E.TexCoords))
	-- 			else
	-- 				-- local r, g, b = GetItemQualityColor(data.Quality)
	-- 				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	-- 				button.Highlight:SetVertexColor(1, 1, 1, .35)
	-- 			end
	-- 		end
	-- 	end
	-- 	hooksecurefunc(StoreItemListScrollFrame, "update", StoreFrame_UpdateItemList)
	-- 	hooksecurefunc("StoreFrame_UpdateItemList", StoreFrame_UpdateItemList)

	-- 	S:HandleCheckBox(StoreShowAllItemCheckButton)

	-- 	local sortButtons = {
	-- 		"StoreItemListFrameContainerResetSort",
	-- 		"StoreItemListFrameContainerSortName",
	-- 		"StoreItemListFrameContainerSortDiscount",
	-- 		"StoreItemListFrameContainerSortItemlevel",
	-- 		"StoreItemListFrameContainerSortPVP",
	-- 		"StoreItemListFrameContainerSortPrice"
	-- 	}

	-- 	for i = 1, #sortButtons do
	-- 		local button = _G[sortButtons[i]]
	-- 		if button then
	-- 			button:StripTextures()
	-- 			button:StyleButton()
	-- 			button:CreateBackdrop()
	-- 			button.backdrop:Point("TOPLEFT", 3, -1)
	-- 			button.backdrop:Point("BOTTOMRIGHT", -3, 5)
	-- 			button.hover:SetInside(button.backdrop)
	-- 			button.pushed:SetInside(button.backdrop)
	-- 		end
	-- 	end

	-- 	-- StoreSpecialOfferFrame
	-- 	StoreSpecialOfferTopFrame:StripTextures()
	-- 	StoreSpecialOfferBanner:SetTemplate()
	-- 	S:HandleButton(StoreSpecialOfferBanner.LeftPanel.BuyButton)
	-- 	if SpecialOfferCustomBanners then
	-- 		for _, frame in pairs(SpecialOfferCustomBanners) do
	-- 			frame = _G[frame]
	-- 			if frame and frame.BuyButton then
	-- 				S:HandleButton(frame.BuyButton)
	-- 			end
	-- 		end
	-- 	end

	-- 	S:HandleNextPrevButton(StoreSpecialOfferBanner.NavigationBar.PrevPageButton, nil, nil, true)
	-- 	StoreSpecialOfferBanner.NavigationBar.PrevPageButton:Size(32)
	-- 	S:HandleNextPrevButton(StoreSpecialOfferBanner.NavigationBar.NextPageButton, nil, nil, true)
	-- 	StoreSpecialOfferBanner.NavigationBar.NextPageButton:Size(32)

	-- 	StoreSpecialOfferBottomFrame:StripTextures()

	-- --	for i = 1, 4 do
	-- --		local button = _G["StoreSpecialOfferCardButton"..i]
	-- --		if button then
	-- --
	-- --		end
	-- --	end

	-- 	-- StoreSubCategorySelectFrame
	-- 	StoreSubCategorySelectFrame:StripTextures()

	-- 	StoreSubCategorySelectContainer.Background:SetAlpha(0)
	-- 	StoreSubCategorySelectContainer.HeaderText:SetTextColor(1, 1, 1)

	-- 	local slots = {"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot",
	-- 		"HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Trinket0Slot",
	-- 		"MainHandSlot", "SecondaryHandSlot", "RangedSlot"
	-- 	}

	-- 	for _, slot in pairs(slots) do
	-- 		local button = _G["StoreSubCategorySelectContainer"..slot]
	-- 		S:HandleIcon(button.Icon)
	-- 		button.backdrop:SetFrameLevel(button:GetFrameLevel() + 2)

	-- 		button.Background:SetWidth(124)
	-- 		button.Background:SetTexture(E.Media.Textures.Highlight)
	-- 		button.Background:SetVertexColor(1, 1, 1, .3)

	-- 		button.IconBorder:SetAlpha(0)
	-- 		button.IconBorderHighlight:SetAlpha(0)

	-- 		button.BackgroundHighlight:SetWidth(124)
	-- 		button.BackgroundHighlight:SetTexture(E.Media.Textures.Highlight)
	-- 		button.BackgroundHighlight:SetVertexColor(.9, .8, .1, .3)

	-- 		button.Text:ClearAllPoints()

	-- 		local id = button:GetID()
	-- 		if id >= 7 and id <= 13 then
	-- 			button.Background:SetTexCoord(0, .7, 0, 1)
	-- 			button.BackgroundHighlight:SetTexCoord(0, .7, 0, 1)
	-- 			button.Text:SetJustifyH("RIGHT")
	-- 			button.Text:SetPoint("RIGHT", button.Icon, "LEFT", -5, 0)
	-- 		else
	-- 			button.Background:SetTexCoord(.3, 1, 0, 1)
	-- 			button.BackgroundHighlight:SetTexCoord(.3, 1, 0, 1)
	-- 			button.Text:SetJustifyH("LEFT")
	-- 			button.Text:SetPoint("LEFT", button.Icon, "RIGHT", 5, 0)
	-- 		end
	-- 	end

	-- 	-- StoreItemCardFrame
	-- 	S:HandleNextPrevButton(StoreItemCardFrameNavigationBarPrevPageButton, nil, nil, true)
	-- 	StoreItemCardFrameNavigationBarPrevPageButton:Size(32)
	-- 	S:HandleNextPrevButton(StoreItemCardFrameNavigationBarNextPageButton, nil, nil, true)
	-- 	StoreItemCardFrameNavigationBarNextPageButton:Size(32)

	-- 	S:HandleButton(StoreRefreshMountListButton)

	-- 	-- StoreModelPreviewFrame
	-- 	StoreModelPreviewFrame:StripTextures()
	-- 	StoreModelPreviewFrame.Inset:StripTextures()
	-- 	StoreModelPreviewFrame:SetTemplate("Transparent")

	-- 	StoreModelPreviewFrame.Display:StripTextures()
	-- 	StoreModelPreviewFrame.Display.ShadowOverlay:SetAlpha(0)
	-- 	StoreModelPreviewFrame.Display:SetTemplate()

	-- 	S:HandleRotateButton(StorePreviewModelFrameRotateLeftButton)
	-- 	S:HandleRotateButton(StorePreviewModelFrameRotateRightButton)
	-- 	StorePreviewModelFrameRotateRightButton:SetPoint("TOPLEFT", StorePreviewModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	-- 	S:HandleCloseButton(StoreModelPreviewFrameCloseButton) -- WTF?
	-- 	S:HandleButton(StoreModelPreviewFrame.CloseButton, true) -- WTF?

	-- 	--StoreConfirmationFrame
	-- 	RemoveGoldBorder(StoreConfirmationFrame)
	-- 	S:HandleCloseButton(StoreConfirmationFrame.CloseButton)

	-- 	S:HandleIcon(StoreConfirmationFrame.Art.Icon)
	-- 	StoreConfirmationFrame.Art.IconBorder:SetAlpha(0)
	-- 	StoreConfirmationFrame.Art.backdrop:SetFrameLevel(StoreConfirmationFrame.Art:GetFrameLevel() + 5)
	-- 	StoreConfirmationFrame.Art.Icon:SetDrawLayer("OVERLAY")

	-- 	S:HandleCheckBox(StoreConfirmationSendGiftCheckButton)
	-- 	StoreConfirmationSendGiftCheckButton.Text:Point("LEFT", StoreConfirmationSendGiftCheckButton, "RIGHT", -2, 0)

	-- 	StoreConfirmationGiftFrameCharacterName:Height(18)
	-- 	S:HandleEditBox(StoreConfirmationGiftFrameCharacterName)
	-- 	StoreConfirmationGiftFrame.CharacterName.Left:SetAlpha(0)
	-- 	StoreConfirmationGiftFrame.CharacterName.Right:SetAlpha(0)
	-- 	StoreConfirmationGiftFrame.CharacterName.Middle:SetAlpha(0)
	-- 	select(10, StoreConfirmationGiftFrame.CharacterName:GetRegions()):SetAlpha(0)

	-- 	S:HandleDropDownBox(StoreConfirmationGiftFrameSelectedStyleDropDown)

	-- 	StoreConfirmationGiftFrame.MessageFrame:StripTextures()
	-- 	StoreConfirmationGiftFrame.MessageFrame:CreateBackdrop()

	-- 	StoreConfirmationFrame:CreateBackdrop("Transparent")
	-- 	StoreConfirmationFrame.backdrop:SetOutside(StoreConfirmationFrame.ParchmentTop, nil, nil, StoreConfirmationFrame.BlueGlow)

	-- 	S:HandleButton(StoreConfirmationFrame.BuyButton)
	-- 	S:HandleButton(StoreConfirmationFrame.BackButton)

	-- 	StoreConfirmationFrame:HookScript("OnShow", function(self)
	-- 		SetPortraitToTexture(self.Art.Icon, "")
	-- 		self.Art.Icon:SetTexture(self.data.Texture)
	-- 	end)

	-- 	-- StoreErrorFrame
	-- 	RemoveGoldBorder(StoreErrorFrame)
	-- 	StoreErrorFrame:CreateBackdrop("Transparent")
	-- 	StoreErrorFrame.backdrop:SetOutside(StoreErrorFrame.ParchmentMiddle)

	-- 	S:HandleButton(StoreErrorFrame.AcceptButton)

	-- 	-- StoreBuyPremiumFrame
	-- 	RemoveGoldBorder(StoreBuyPremiumFrame)
	-- 	S:HandleCloseButton(StoreBuyPremiumFrame.CloseButton)

	-- 	StoreBuyPremiumFrame:CreateBackdrop("Transparent")
	-- 	StoreBuyPremiumFrame.backdrop:SetOutside(StoreBuyPremiumFrame.ParchmentTop, nil, nil, StoreBuyPremiumFrame.BlueGlow)

	-- 	for i = 1, 4 do
	-- 		local button = _G["SelectPremiumButton"..i]
	-- 		if button then
	-- 			button:Size(24)
	-- 			button:SetFrameLevel(StoreBuyPremiumFrame:GetFrameLevel() + 5)
	-- 			S:HandleCheckBox(button)
	-- 		end
	-- 	end

	-- 	S:HandleButton(StoreBuyPremiumFrame.BuyButton)

	-- 	-- StoreSubscribeFrame
	-- 	StoreSubscribeFrame:StripTextures()
	-- 	StoreSubscribeContainer.HeaderBackground:SetAlpha(0)
	-- 	StoreSubscribeContainer.BackgroundColor:SetAlpha(0)
	-- 	StoreSubscribeContainer.HeaderBackgroundAlpha:SetAlpha(0)
	-- 	StoreSubscribeContainer.HeaderText:SetTextColor(1, 1, 1)

	-- 	local function StoreSubscribeItemTemplate(button)
	-- 		if button then
	-- 			button:SetTemplate()
	-- 			button:StyleButton()

	-- 			button.iconTexture:SetDrawLayer("BORDER")
	-- 			button.iconTexture:SetTexCoord(unpack(E.TexCoords))
	-- 			button.iconTexture:SetInside()

	-- 			button.slotFrameCollected:Kill()
	-- 			button.glow:Kill()
	-- 			button.glow2:Kill()
	-- 			button.CountBackground:Kill()
	-- 			button.count:FontTemplate(nil, nil, "OUTLINE")
	-- 			button.count:ClearAllPoints()
	-- 			button.count:SetPoint("BOTTOMRIGHT", button, 5, 0)
	-- 		end
	-- 	end

	-- 	for i = 1, 3 do
	-- 		local button = _G["StoreSubscribeItemButton"..i]
	-- 		StoreSubscribeItemTemplate(button)
	-- 	end

	-- 	StoreSubscribeItemTemplate(StoreSubscribeSubItemButton1)

	-- 	hooksecurefunc("StoreSubscribeSetup", function()
	-- 		for i = 1, 3 do
	-- 			local button = _G["StoreSubscribeItemButton"..i]
	-- 			if button and button.Link then
	-- 				local _, _, quality = GetItemInfo(button.Link)

	-- 				if quality then
	-- 					button:SetBackdropBorderColor(GetItemQualityColor(quality))
	-- 				else
	-- 					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	-- 				end
	-- 			end
	-- 		end

	-- 		local subItemButton = StoreSubscribeSubItemButton1
	-- 		if subItemButton and subItemButton.Link then
	-- 			local _, _, quality = GetItemInfo(subItemButton.Link)

	-- 			if quality then
	-- 				subItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
	-- 			else
	-- 				subItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
	-- 			end
	-- 		end
	-- 	end)

	-- 	S:HandleButton(StoreSubscribeContainer.BuyButton1)
	-- 	S:HandleButton(StoreSubscribeContainer.BuyButton2)
	-- 	S:HandleButton(StoreSubscribeContainer.BuyButton3)

	-- 	-- StoreDressUPFrame
	-- 	StoreDressUPFrame:StripTextures()
	-- 	StoreDressUPFrame.Inset:StripTextures()
	-- 	StoreDressUPFrame:SetTemplate("Transparent")
	-- 	S:HandleCloseButton(StoreDressUPFrameCloseButton)
	-- 	StoreDressUPFrame.Display.YesMountsTex:SetAlpha(0)
	-- 	StoreDressUPFrame.Display.ShadowOverlay:StripTextures()
	-- 	StoreDressUPFrame.Display.DressUPModel:SetTemplate("Transparent")
	-- 	S:HandleControlFrame(StoreDressUPFrame.Display.DressUPModel.controlFrame)

	-- 	S:HandleButton(StoreDressUPFrame.CloseButton, true)
	-- 	S:HandleButton(StoreDressUPFrame.ResetButton, true)
	-- 	S:HandleButton(StoreFrameLeftInsetInviteFriendButton, true)
	-- 	S:HandleButton(StoreFrameLeftInsetReferDetailsButton, true)
	-- 	StoreReferDetailsFrame:HookScript("OnShow", function()
	-- 		S:HandleButton(StoreReferDetailsFrameBanner1InviteFriendButton, true)
	-- 		S:HandleCloseButton(StoreReferDetailsFrame.CloseButton)
	-- 	end)
	-- 	-- StoreTransmogrifyFrame
	-- 	S:HandleEditBox(StoreTransmogrifyFrame.LeftContainer.searchBox)

	-- 	StoreTransmogrifyFrame.LeftContainer:StripTextures()
	-- 	S:HandleButton(StoreTransmogrifyFrame.LeftContainer.FilterButton)
	-- 	StoreTransmogrifyFrame.LeftContainer.FilterButton:Point("LEFT", StoreTransmogrifyFrame.LeftContainer.searchBox, "RIGHT", 3, 0)
	-- 	StoreTransmogrifyFrame.LeftContainer.FilterButton:StripTextures(nil, true)
	-- 	StoreTransmogrifyFrame.LeftContainer.FilterButton.Icon:SetAlpha(1)

	-- 	S:HandleScrollBar(StoreTransmogrifyFrameLeftContainerScrollFrameScrollBar)
	-- 	local up = StoreTransmogrifyFrameLeftContainerScrollFrameScrollBarScrollUpButton
	-- 	local upNormal, upDisabled, upPushed = up:GetNormalTexture(), up:GetDisabledTexture(), up:GetPushedTexture()
	-- 	upNormal:SetRotation(S.ArrowRotation.up)
	-- 	upPushed:SetRotation(S.ArrowRotation.up)
	-- 	upDisabled:SetRotation(S.ArrowRotation.up)
	-- 	local down = StoreTransmogrifyFrameLeftContainerScrollFrameScrollBarScrollDownButton
	-- 	local downNormal, downDisabled, downPushed = down:GetNormalTexture(), down:GetDisabledTexture(), down:GetPushedTexture()
	-- 	downNormal:SetRotation(S.ArrowRotation.down)
	-- 	downPushed:SetRotation(S.ArrowRotation.down)
	-- 	downDisabled:SetRotation(S.ArrowRotation.down)

	-- 	for i = 1, #StoreTransmogrifyFrameLeftContainerScrollFrame.buttons do
	-- 		local button = StoreTransmogrifyFrameLeftContainerScrollFrame.buttons[i]
	-- 		button.Background:SetAlpha(0)
	-- 		button.IconBorder:SetAlpha(0)
	-- 		S:HandleIcon(button.Icon)
	-- 		button.Icon:SetDrawLayer("BORDER")
	-- 		button.NewItems:SetParent(button.backdrop)

	-- 		local highlight = button:GetHighlightTexture()
	-- 		button:SetHighlightTexture(E.Media.Textures.Highlight)
	-- 		highlight:SetTexCoord(0, 1, 0, 1)
	-- 		highlight:SetVertexColor(1, 1, 1, .35)
	-- 		highlight:SetInside()

	-- 		button.selectedTexture:SetTexture(E.Media.Textures.Highlight)
	-- 		button.selectedTexture:SetTexCoord(0, 1, 0, 1)
	-- 		button.selectedTexture:SetVertexColor(1, .8, .1, .35)
	-- 		button.selectedTexture:SetInside()
	-- 	end

	-- 	StoreTransmogrifyFrame.RightContainer:StripTextures()
	-- 	StoreTransmogrifyFrame.RightContainer.Background:Kill()
	-- 	StoreTransmogrifyFrame.RightContainer.ShadowOverlay:StripTextures()
	-- 	StoreTransmogrifyFrame.RightContainer.ContentFrame.OverlayElements.IconRowBackground:SetAlpha(0)
	-- 	S:HandleCheckBox(StoreTransmogrifyFrame.RightContainer.ContentFrame.OverlayElements.ShowShoulders)

	-- 	S:HandleButton(StoreTransmogrifyFrame.RightContainer.ContentFrame.BuyButton)

	-- 	for i = 1, 9 do
	-- 		local button = StoreTransmogrifyFrame.RightContainer.ContentFrame["ItemButton"..i]
	-- 		button:SetTemplate()
	-- 		button.IconBorder:Hide()
	-- 		button.Icon:SetTexCoord(unpack(E.TexCoords))
	-- 		button.Icon:SetInside()
	-- 	end

	-- 	hooksecurefunc("StoreTransmogrifyButtonSetIconBorder", function(button, quality)
	-- 		local backdrop = button.backdrop or button
	-- 		backdrop:SetBackdropBorderColor(GetItemQualityColor(quality or 1))
	-- 	end)

	-- 	-- StoreTransmogrifySubCategoryFrame
	-- 	StoreTransmogrifySubCategoryFrame.Background:SetAlpha(0)

	-- 	for i = 1, 4 do
	-- 		local frame = _G["StoreTransmogrifySubCategoryFrameCategory"..i]
	-- 		frame:SetTemplate("Transparent")
	-- 		frame.BackgroundTexture:SetAlpha(0)
	-- 		S:HandleButton(frame.Button)
	-- 	end

	-- 	-- Temp
	-- 	local categoryIcons = {
	-- 		[1] = "Interface\\Icons\\achievement_guildperk_mrpopularity",
	-- 		[2] = "Interface\\Icons\\inv_helmet_25",
	-- 		[3] = "Interface\\Icons\\Ability_Mount_RidingHorse",
	-- 		[4] = "Interface\\Icons\\inv_egg_03",
	-- 		[5] = "Interface\\Icons\\Spell_Fire_Fire",
	-- 		[6] = "Interface\\Icons\\INV_Scroll_03",
	-- 		[7] = "Interface\\Icons\\inv_misc_note_02",
	-- 		[8] = "Interface\\Icons\\inv_misc_bag_10",
	-- 		[9] = "Interface\\Icons\\inv_crate_01",
	-- 		[10] = "Interface\\Icons\\INV_Shirt_Blue_01",
	-- 	}

	-- 	hooksecurefunc("StoreFrame_UpdateCategories", function(self)
	-- 		for i, button in pairs(self.CategoryFrames) do
	-- 			if not button.isElvUI then
	-- 				button:Size(176 + 10, 36 + 2)
	-- 				button:SetTemplate("Transparent")
	-- 				button:StyleButton()

	-- 				button.SelectedTexture:SetTexture(.9, .8, .1, .3)
	-- 				button.SelectedTexture:SetInside()
	-- 				button.HighlightTexture:SetTexture(1, 1, 1, .3)
	-- 				button.HighlightTexture:SetInside()
	-- 				button.ColoredTexture:SetTexture(.9, .1, .1, .3)
	-- 				button.ColoredTexture:SetInside()

	-- 				button.Category:Hide()
	-- 				button.PulseTexture:Hide()
	-- 				button.NewItems:Hide()
	-- 				button.Text:Point("LEFT", 37, 0)

	-- 				button.Icon:Point("LEFT", 5, 0)
	-- 				button.Icon:Size(28)
	-- 				S:HandleIcon(button.Icon)
	-- 				button.backdrop:SetFrameLevel(button:GetFrameLevel() + 1)

	-- 				if i == 1 then
	-- 					button:Point("TOP", 0, -9)
	-- 				else
	-- 					button:Point("TOPLEFT", self.CategoryFrames[i - 1], "BOTTOMLEFT", 0, -3)
	-- 				end

	-- 				button.isElvUI = true
	-- 			end

	-- 			if categoryIcons[i] then
	-- 				button.Icon:SetTexture(categoryIcons[i])
	-- 				button.Icon:SetTexCoord(unpack(E.TexCoords))
	-- 			else
	-- 				button.Icon:SetTexCoord(0.38, 0.60, 0.38, 0.60)
	-- 			end
	-- 		end
	-- 	end)

	-- 	PromoCodeFrame:HookScript("OnShow",function()
	-- 		PromoCodeFrame:StripTextures()
	-- 		PromoCodeFrame:CreateBackdrop("Transparent")
	-- 		S:HandleButton(PromoCodeFrameActionButton)
	-- 		S:HandleEditBox(PromoCodeFrameContainerPromoCodeEditBoxFrame)
	-- 		S:HandleCloseButton(PromoCodeFrame.CloseButton)
	-- 		PromoCodeFrameHeaderFrame.description:SetTextColor(1, 1, 1)

	-- 	end)

	-- 	hooksecurefunc("StoreSelectCategory",HookSubButtons)

	-- 	LootCasePreviewFrame:HookScript("OnShow",function()
	-- 		LootCasePreviewFrame:StripTextures()

	-- 		LootCasePreviewFrame:CreateBackdrop("Transparent")
	-- 		LootCasePreviewFrameScrollFrame:StripTextures()
	-- 		LootCasePreviewFrameScrollFrame:CreateBackdrop("Transparent")
	-- 		LootCasePreviewFrameScrollFrameScrollChild:StripTextures()
	-- 		LootCasePreviewFrameInset:StripTextures()
	-- 		-- LootCasePreviewFrameScrollFrame:CreateBackdrop("Transparent")
	-- 		S:HandleScrollBar(LootCasePreviewFrameScrollFrameScrollBar)
	-- 		S:HandleCloseButton(LootCasePreviewFrameCloseButton)
	-- 		LootCasePreviewFrameCloseButton:Show()
	-- 		for _, v in pairs(LootCasePreviewFrameScrollFrame.buttons) do
	-- 			if v then
	-- 				S:HandleButton(v,true)
	-- 				v.Icon:SetTexCoord(unpack(E.TexCoords))
	-- 			end
	-- 		end
	-- 	end)
end
S:AddCallback("Sirus_Store", LoadSkin)