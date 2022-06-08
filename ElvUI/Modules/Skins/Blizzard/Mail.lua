local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs = ipairs
local select = select
local unpack = unpack
--WoW API / Variables
local GetInboxHeaderInfo = GetInboxHeaderInfo
local GetInboxItemLink = GetInboxItemLink
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetSendMailItem = GetSendMailItem

local INBOXITEMS_TO_DISPLAY = INBOXITEMS_TO_DISPLAY
local ATTACHMENTS_MAX_SEND = ATTACHMENTS_MAX_SEND
local ATTACHMENTS_MAX_RECEIVE = ATTACHMENTS_MAX_RECEIVE
local hooksecurefunc = hooksecurefunc

-- S:AddCallback("Skin_Mail", function()
-- 	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.mail then return end

-- 	-- Inbox Frame
-- 	MailFrame:StripTextures(true)
-- 	MailFrame:CreateBackdrop("Transparent")
-- 	MailFrame.backdrop:Point("TOPLEFT", 11, -12)
-- 	MailFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

-- 	S:SetUIPanelWindowInfo(MailFrame, "width")
-- 	S:SetBackdropHitRect(MailFrame)
-- 	S:SetBackdropHitRect(SendMailFrame, MailFrame.backdrop)

-- 	MailFrame:EnableMouseWheel(true)

-- 	MailFrame:SetScript("OnMouseWheel", function(_, value)
-- 		if value > 0 then
-- 			if InboxPrevPageButton:IsEnabled() == 1 then
-- 				InboxPrevPage()
-- 			end
-- 		else
-- 			if InboxNextPageButton:IsEnabled() == 1 then
-- 				InboxNextPage()
-- 			end
-- 		end
-- 	end)

-- 	for i = 1, INBOXITEMS_TO_DISPLAY do
-- 		local mail = _G["MailItem"..i]
-- 		local button = _G["MailItem"..i.."Button"]
-- 		local icon = _G["MailItem"..i.."ButtonIcon"]

-- 		mail:StripTextures()
-- 		mail:CreateBackdrop("Transparent")
-- 		mail.backdrop:SetParent(button)
-- 		mail.backdrop:SetFrameLevel(mail:GetFrameLevel() - 1)
-- 		mail.backdrop:Point("TOPLEFT", mail, 44, -2)
-- 		mail.backdrop:Point("BOTTOMRIGHT", mail, 3, 9)

-- 		button:StripTextures()
-- 		button:CreateBackdrop()
-- 		button:Point("TOPLEFT", 8, -3)
-- 		button:Size(32)
-- 		button:StyleButton()
-- 		button.hover:SetAllPoints()

-- 		icon:SetTexCoord(unpack(E.TexCoords))
-- 		icon:SetInside(button.backdrop)
-- 	end

-- 	hooksecurefunc("InboxFrame_Update", function()
-- 		local numItems = GetInboxNumItems()
-- 		local index = (InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY

-- 		for i = 1, INBOXITEMS_TO_DISPLAY do
-- 			index = index + 1

-- 			if index <= numItems then
-- 				local button = _G["MailItem"..i.."Button"]
-- 				local packageIcon, _, _, _, _, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(index)

-- 				if packageIcon and not isGM then
-- 					local itemLink = GetInboxItemLink(index, 1)

-- 					if itemLink then
-- 						local quality = select(3, GetItemInfo(itemLink))

-- 						if quality then
-- 							button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
-- 						else
-- 							button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
-- 						end
-- 					end
-- 				elseif isGM then
-- 					button.backdrop:SetBackdropBorderColor(0, 0.56, 0.94)
-- 				else
-- 					button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
-- 				end
-- 			end
-- 		end
-- 	end)

-- 	InboxTitleText:Point("CENTER", 0, 231)
-- 	SendMailTitleText:Point("CENTER", 0, 231)

-- 	S:HandleNextPrevButton(InboxPrevPageButton, nil, nil, true)
-- 	InboxPrevPageButton:Size(32)

-- 	S:HandleNextPrevButton(InboxNextPageButton, nil, nil, true)
-- 	InboxNextPageButton:Size(32)

-- 	S:HandleCloseButton(InboxCloseButton, MailFrame.backdrop)

-- 	for i = 1, 2 do
-- 		local tab = _G["MailFrameTab"..i]
-- 		tab:StripTextures()
-- 		S:HandleTab(tab)
-- 	end

-- 	MailItem1:Point("TOPLEFT", 24, -80)

-- 	MailFrameTab1:Point("BOTTOMLEFT", 11, 46)
-- 	MailFrameTab2:Point("LEFT", MailFrameTab1, "RIGHT", -15, 0)

-- 	-- Send Mail Frame
-- 	SendMailFrame:StripTextures()

-- 	SendMailScrollFrame:StripTextures(true)

-- 	hooksecurefunc("SendMailFrame_Update", function()
-- 		for i = 1, ATTACHMENTS_MAX_SEND do
-- 			local button = _G["SendMailAttachment"..i]
-- 			local name = GetSendMailItem(i)

-- 			if not button.skinned then
-- 				button:StripTextures()
-- 				button:SetTemplate("Default", true)
-- 				button:StyleButton(nil, true)

-- 				button.skinned = true
-- 			end

-- 			if name then
-- 				local icon = button:GetNormalTexture()
-- 				local quality = select(3, GetItemInfo(name))

-- 				if quality then
-- 					button:SetBackdropBorderColor(GetItemQualityColor(quality))
-- 				else
-- 					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
-- 				end

-- 				icon:SetTexCoord(unpack(E.TexCoords))
-- 				icon:SetInside()
-- 			else
-- 				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
-- 			end
-- 		end
-- 	end)

-- 	S:HandleScrollBar(SendMailScrollFrameScrollBar)

-- 	S:HandleEditBox(SendMailNameEditBox)
-- 	S:HandleEditBox(SendMailSubjectEditBox)
-- 	S:HandleEditBox(SendMailMoneyGold)
-- 	S:HandleEditBox(SendMailMoneySilver)
-- 	S:HandleEditBox(SendMailMoneyCopper)

-- 	S:HandleButton(SendMailMailButton)
-- 	S:HandleButton(SendMailCancelButton)

-- 	for i = 1, 5 do
-- 		_G["AutoCompleteButton"..i]:StyleButton()
-- 	end

-- 	SendMailScrollFrame:CreateBackdrop()
-- 	SendMailScrollFrame.backdrop:Point("TOPLEFT", 0, 5)
-- 	SendMailScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -5)

-- 	SendMailScrollFrameScrollBar:Point("TOPLEFT", SendMailScrollFrame, "TOPRIGHT", 3, -14)
-- 	SendMailScrollFrameScrollBar:Point("BOTTOMLEFT", SendMailScrollFrame, "BOTTOMRIGHT", 3, 14)

-- 	SendMailBodyEditBox:SetTextColor(1, 1, 1)
-- 	SendMailBodyEditBox:Width(291)
-- 	SendMailBodyEditBox:Point("TOPLEFT", 5, -5)

-- 	SendMailScrollFrame:Width(304)
-- 	SendMailScrollFrame:Point("TOPLEFT", 19, -97)

-- 	SendMailNameEditBox:Height(18)
-- 	SendMailNameEditBox:Point("TOPLEFT", 75, -43)

-- 	SendMailSubjectEditBox:Size(247, 18)
-- 	SendMailSubjectEditBox:Point("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -5)

-- 	SendMailCostMoneyFrame:Point("TOPRIGHT", -27, -45)

-- 	SendMailMoneyText:Point("TOPLEFT", 0, 3)
-- 	SendMailMoney:Point("TOPLEFT", SendMailMoneyText, "BOTTOMLEFT", 2, -3)

-- 	SendMailMoneyFrame:Point("BOTTOMRIGHT", SendMailFrame, "BOTTOMLEFT", 164, 88)
-- 	SendMailMailButton:Point("RIGHT", SendMailCancelButton, "LEFT", -3, 0)

-- 	SendMailCancelButton:Point("BOTTOMRIGHT", -40, 84)

-- 	-- Open Mail Frame
-- 	OpenMailFrame:StripTextures(true)
-- 	OpenMailFrame:CreateBackdrop("Transparent")
-- 	OpenMailFrame.backdrop:Point("TOPLEFT", 11, -12)
-- 	OpenMailFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)
-- 	OpenMailFrame:Point("TOPLEFT", InboxFrame, "TOPRIGHT", -44, 0)

-- 	for i = 1, ATTACHMENTS_MAX_SEND do
-- 		local button = _G["OpenMailAttachmentButton"..i]
-- 		local icon = _G["OpenMailAttachmentButton"..i.."IconTexture"]
-- 		local count = _G["OpenMailAttachmentButton"..i.."Count"]

-- 		button:StripTextures()
-- 		button:SetTemplate("Default", true)
-- 		button:StyleButton()

-- 		if icon then
-- 			icon:SetTexCoord(unpack(E.TexCoords))
-- 			icon:SetDrawLayer("ARTWORK")
-- 			icon:SetInside()

-- 			count:SetDrawLayer("OVERLAY")
-- 		end
-- 	end

-- 	hooksecurefunc("OpenMailFrame_UpdateButtonPositions", function()
-- 		for i = 1, ATTACHMENTS_MAX_RECEIVE do
-- 			local itemLink = GetInboxItemLink(InboxFrame.openMailID, i)
-- 			local button = _G["OpenMailAttachmentButton"..i]

-- 			if itemLink then
-- 				local quality = select(3, GetItemInfo(itemLink))

-- 				if quality then
-- 					button:SetBackdropBorderColor(GetItemQualityColor(quality))
-- 				else
-- 					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
-- 				end
-- 			else
-- 				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
-- 			end
-- 		end
-- 	end)

-- 	hooksecurefunc("OpenMail_Update", function()
-- 		if not InboxFrame.openMailID then return end

-- 		local point, relativeTo, relativePoint, x, y = OpenMailAttachmentText:GetPoint()
-- 		OpenMailAttachmentText:Point(point, relativeTo, relativePoint, x + 1, y + 8)

-- 		for i, button in ipairs(OpenMailFrame.activeAttachmentButtons) do
-- 			point, relativeTo, relativePoint, x, y = button:GetPoint()
-- 			button:Point(point, relativeTo, relativePoint, x + 1, y + 5)
-- 		end
-- 	end)

-- 	S:HandleCloseButton(OpenMailCloseButton, OpenMailFrame.backdrop)

-- 	S:HandleButton(OpenMailReportSpamButton)

-- 	S:HandleButton(OpenMailReplyButton)
-- 	S:HandleButton(OpenMailDeleteButton)
-- 	S:HandleButton(OpenMailCancelButton)

-- 	OpenMailScrollFrame:StripTextures(true)
-- 	OpenMailScrollFrame:CreateBackdrop("Default")
-- 	OpenMailScrollFrame.backdrop:Point("TOPLEFT", -1, 3)
-- 	OpenMailScrollFrame.backdrop:Point("BOTTOMRIGHT", 1, -2)

-- 	S:HandleScrollBar(OpenMailScrollFrameScrollBar)

-- 	OpenMailBodyText:SetTextColor(1, 1, 1)
-- 	InvoiceTextFontNormal:SetFont(E.media.normFont, 13)
-- 	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
-- 	OpenMailInvoiceBuyMode:SetTextColor(1, 0.80, 0.10)

-- 	OpenMailArithmeticLine:Kill()

-- 	OpenMailLetterButton:StripTextures()
-- 	OpenMailLetterButton:SetTemplate("Default", true)
-- 	OpenMailLetterButton:StyleButton()

-- 	OpenMailLetterButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
-- 	OpenMailLetterButtonIconTexture:SetDrawLayer("ARTWORK")
-- 	OpenMailLetterButtonIconTexture:SetInside()

-- 	OpenMailLetterButtonCount:SetDrawLayer("OVERLAY")

-- 	OpenMailMoneyButton:StripTextures()
-- 	OpenMailMoneyButton:SetTemplate("Default", true)
-- 	OpenMailMoneyButton:StyleButton()

-- 	OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
-- 	OpenMailMoneyButtonIconTexture:SetDrawLayer("ARTWORK")
-- 	OpenMailMoneyButtonIconTexture:SetInside()

-- 	OpenMailMoneyButtonCount:SetDrawLayer("OVERLAY")

-- 	OpenMailBodyText:Width(288)
-- 	OpenMailBodyText:Point("TOPLEFT", 5, -3)

-- 	OpenMailScrollFrame:Width(302)
-- 	OpenMailScrollFrame:Point("TOPLEFT", 20, -91)

-- 	OpenMailScrollFrameScrollBar:Point("TOPLEFT", OpenMailScrollFrame, "TOPRIGHT", 4, -16)
-- 	OpenMailScrollFrameScrollBar:Point("BOTTOMLEFT", OpenMailScrollFrame, "BOTTOMRIGHT", 4, 17)

-- 	OpenMailSenderLabel:Point("TOPRIGHT", OpenMailFrame, "TOPLEFT", 85, -45)
-- 	OpenMailSubjectLabel:Point("TOPRIGHT", OpenMailFrame, "TOPLEFT", 85, -65)
-- 	OpenMailSender:Point("LEFT", OpenMailSenderLabel, "RIGHT", 5, -1)
-- 	OpenMailSubject:Point("TOPLEFT", OpenMailSubjectLabel, "TOPRIGHT", 5, -1)

-- 	OpenMailReportSpamButton:Point("TOPRIGHT", -40, -43)
-- 	OpenMailCancelButton:Point("BOTTOMRIGHT", -40, 84)
-- 	OpenMailDeleteButton:Point("RIGHT", OpenMailCancelButton, "LEFT", -3, 0)
-- 	OpenMailReplyButton:Point("RIGHT", OpenMailDeleteButton, "LEFT", -3, 0)
-- end)

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mail ~= true then return end

	-- Inbox Frame
	S:HandlePortraitFrame(MailFrame)
	MailFrame.Inset:StripTextures()
	MailFrame.NineSlice:StripTextures()

	MailFrame:EnableMouseWheel(true)
	MailFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if InboxPrevPageButton:IsEnabled() == 1 then
				InboxPrevPage()
			end
		else
			if InboxNextPageButton:IsEnabled() == 1 then
				InboxNextPage()
			end
		end
	end)

	local function OpenMail_Delete(self)
		DeleteInboxItem(self:GetParent().Button.index)
	end

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local mail = _G["MailItem"..i]
		local button = _G["MailItem"..i.."Button"]
		local icon = _G["MailItem"..i.."ButtonIcon"]

		mail:StripTextures(true)
		mail:CreateBackdrop("Default")
		mail.backdrop:Point("TOPLEFT", 45, 0)
		mail.backdrop:Point("BOTTOMRIGHT", 0, 0)

		button:Size(45)
		button:ClearAllPoints()
		button:Point("LEFT", mail, -1, 0)
		button:StripTextures()
		button:SetTemplate("Default", true)
		button:StyleButton()

		icon:SetDrawLayer("BORDER")
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		_G["MailItem"..i.."ExpireTime"]:Point("TOPRIGHT", -4, -5)

		local deleteButton = CreateFrame("Button", "$parentDeleteButton", mail)
		deleteButton:Size(16, 16)
		deleteButton:Point("BOTTOMRIGHT", -4, 5)
		deleteButton:SetScript("OnClick", OpenMail_Delete)

		deleteButton.Texture = deleteButton:CreateTexture(nil, "OVERLAY")
		deleteButton.Texture:Size(12)
		deleteButton.Texture:Point("CENTER")
		deleteButton.Texture:SetTexture(E.Media.Textures.Close)
	end

	InboxFrame.WaitFrame:StripTextures()
	InboxFrame.LeftContainer:StripTextures()
	InboxFrame.LeftContainer.ClassLogo:Kill()
	InboxFrame.LeftContainer.ShadowOverlay:StripTextures()
--	InboxFrame.LeftContainer.ShadowOverlay:SetTemplate("Transparent")
	S:HandleButton(OpenAllMailButton)
	S:HandleNextPrevButton(AdditionalMailFunctionalButton)
	AdditionalMailFunctionalButton:Size(28)
	AdditionalMailFunctionalButton:Point("LEFT", OpenAllMailButton, "RIGHT", 4, 0)

	InboxFrame.RightContainer:StripTextures()
	InboxFrame.RightContainer.FactionLogo:Kill()
	InboxFrame.RightContainer.ShadowOverlay:StripTextures()
--	InboxFrame.RightContainer.ShadowOverlay:SetTemplate("Transparent")
	S:HandleButton(UpdateMailButton)

	InboxTooMuchMail:StripTextures()

	hooksecurefunc("InboxFrame_Update", function()
		local numItems = GetInboxNumItems()
		local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1

		for i = 1, INBOXITEMS_TO_DISPLAY do
			if index <= numItems then
				local packageIcon, _, _, _, money, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(index)
				local button = _G["MailItem"..i.."Button"]
				local deleteButton = _G["MailItem"..i.."DeleteButton"]
				local expireTime = _G["MailItem"..i.."ExpireTime"]

				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				if packageIcon and not isGM then
					local ItemLink = GetInboxItemLink(index, 1)

					if ItemLink then
						local quality = select(3, GetItemInfo(ItemLink))

						if quality then
							button:SetBackdropBorderColor(GetItemQualityColor(quality))
						else
							button:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end
				elseif isGM then
					button:SetBackdropBorderColor(0, 0.56, 0.94)
				end

				if expireTime.returnicon then
					deleteButton:Hide()
				elseif InboxItemCanDelete(index) and money == 0 and not GetInboxItem(index, 1) then
					deleteButton:Show()
				else
					deleteButton:Hide()
				end
			end

			index = index + 1
		end
	end)

	S:HandleNextPrevButton(InboxPrevPageButton, nil, nil, true)
	InboxPrevPageButton:Size(28)
	InboxPrevPageButton:Point("BOTTOMLEFT", 8, 8)
	S:HandleNextPrevButton(InboxNextPageButton, nil, nil, true)
	InboxNextPageButton:Size(28)
	InboxNextPageButton:Point("BOTTOMRIGHT", -8, 8)

	for i = 1, 2 do
		local tab = _G["MailFrameTab"..i]

		tab:StripTextures()
		S:HandleTab(tab)
	end

	-- Send Mail Frame
	SendMailFrame.Content:StripTextures()

	SendMailScrollFrame:StripTextures(true)
	SendMailScrollFrame:SetTemplate("Default")

	SendMailMoneyInset:StripTextures()
	SendMailMoneyBg:StripTextures()

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = _G["SendMailAttachment"..i]
			local texture = button:GetNormalTexture()
			local itemName = GetSendMailItem(i)

			if not button.skinned then
				button:StripTextures()
				button:SetTemplate("Default", true)
				button:StyleButton(nil, true)

				button.skinned = true
			end

			if itemName then
				local quality = select(3, GetItemInfo(itemName))

				if quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end

				texture:SetTexCoord(unpack(E.TexCoords))
				texture:SetInside()
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	SendMailBodyEditBox:SetTextColor(1, 1, 1)

	S:HandleScrollBar(SendMailScrollFrameScrollBar)

	SendMailNameEditBox:Height(20)
	S:HandleEditBox(SendMailNameEditBox)

	S:HandleEditBox(SendMailSubjectEditBox)
	SendMailSubjectEditBox:Point("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -4)

	S:HandleEditBox(SendMailMoneyGold)
	S:HandleEditBox(SendMailMoneySilver)
	S:HandleEditBox(SendMailMoneyCopper)

	S:HandleButton(SendMailMailButton)
	SendMailMailButton:Point("RIGHT", SendMailCancelButton, "LEFT", -2, 0)

	S:HandleButton(SendMailCancelButton)

	for i = 1, 5 do
		_G["AutoCompleteButton"..i]:StyleButton()
	end

	-- Open Mail Frame
	S:HandlePortraitFrame(OpenMailFrame)
	OpenMailFrame.Inset:StripTextures()
	OpenMailFrame.NineSlice:StripTextures()
	OpenMailFrame.Content:StripTextures()

	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["OpenMailAttachmentButton"..i]
		local icon = _G["OpenMailAttachmentButton"..i.."IconTexture"]
		local count = _G["OpenMailAttachmentButton"..i.."Count"]

		button:StripTextures()
		button:SetTemplate("Default", true)
		button:StyleButton()

		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("ARTWORK")
			icon:SetInside()

			count:SetDrawLayer("OVERLAY")
		end
	end

	hooksecurefunc("OpenMailFrame_UpdateButtonPositions", function()
		for i = 1, ATTACHMENTS_MAX_RECEIVE do
			local ItemLink = GetInboxItemLink(InboxFrame.openMailID, i)
			local button = _G["OpenMailAttachmentButton"..i]

			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			if ItemLink then
				local quality = select(3, GetItemInfo(ItemLink))

				if quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)

	S:HandleButton(OpenMailReportSpamButton)

	S:HandleButton(OpenMailReplyButton, true)
	OpenMailReplyButton:Point("RIGHT", OpenMailDeleteButton, "LEFT", -2, 0)

	S:HandleButton(OpenMailDeleteButton, true)
	OpenMailDeleteButton:Point("RIGHT", OpenMailCancelButton, "LEFT", -2, 0)

	S:HandleButton(OpenMailCancelButton, true)

	OpenMailScrollFrame:StripTextures(true)
	OpenMailScrollFrame:SetTemplate("Default")

	S:HandleScrollBar(OpenMailScrollFrameScrollBar)

	OpenMailBodyText:SetTextColor(1, 1, 1)
	InvoiceTextFontNormal:SetFont(E.media.normFont, 13)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	OpenMailInvoiceBuyMode:SetTextColor(1, 0.80, 0.10)

	OpenMailArithmeticLine:Kill()

	OpenMailLetterButton:StripTextures()
	OpenMailLetterButton:SetTemplate("Default", true)
	OpenMailLetterButton:StyleButton()

	OpenMailLetterButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailLetterButtonIconTexture:SetDrawLayer("ARTWORK")
	OpenMailLetterButtonIconTexture:SetInside()

	OpenMailLetterButtonCount:SetDrawLayer("OVERLAY")

	OpenMailMoneyButton:StripTextures()
	OpenMailMoneyButton:SetTemplate("Default", true)
	OpenMailMoneyButton:StyleButton()

	OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailMoneyButtonIconTexture:SetDrawLayer("ARTWORK")
	OpenMailMoneyButtonIconTexture:SetInside()

	OpenMailMoneyButtonCount:SetDrawLayer("OVERLAY")
	S:HandleCheckBox(SendMailSendMoneyButton)
	SendMailSendMoneyButton:SetSize(20,20)
	S:HandleCheckBox(SendMailCODButton)
	SendMailCODButton:SetSize(20,20)
end

-- S:RemoveCallback("Skin_Mail")
S:AddCallback("Skin_Mail", LoadSkin)