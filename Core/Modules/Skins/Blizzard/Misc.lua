local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local select = select
local type = type
local unpack = unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

S:AddCallback('Skin_Misc', function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.misc then return end

	-- reskin all esc/menu buttons
	local GameMenuFrame = _G.GameMenuFrame
	for _, Button in next, { GameMenuFrame:GetChildren() } do
		if Button.IsObjectType and Button:IsObjectType('Button') then
			S:HandleButton(Button)
		end
	end

	GameMenuFrame:StripTextures()
	GameMenuFrame:SetTemplate('Transparent')
	_G.GameMenuFrameHeader:SetTexture()
	_G.GameMenuFrameHeader:ClearAllPoints()
	_G.GameMenuFrameHeader:Point('TOP', GameMenuFrame, 0, 7)

	-- Static Popups
	for i = 1, 4 do
		local staticPopup = _G['StaticPopup'..i]
		local itemFrame = _G['StaticPopup'..i..'ItemFrame']
		local itemFrameBox = _G['StaticPopup'..i..'EditBox']
		local itemFrameTexture = _G['StaticPopup'..i..'ItemFrameIconTexture']
		local itemFrameNormal = _G['StaticPopup'..i..'ItemFrameNormalTexture']
		local itemFrameName = _G['StaticPopup'..i..'ItemFrameNameFrame']
		local closeButton = _G['StaticPopup'..i..'CloseButton']
		local wideBox = _G['StaticPopup'..i..'WideEditBox']

		staticPopup:SetTemplate('Transparent')

		S:HandleEditBox(itemFrameBox)
		itemFrameBox.backdrop:Point('TOPLEFT', -2, -4)
		itemFrameBox.backdrop:Point('BOTTOMRIGHT', 2, 4)

		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameGold'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameSilver'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameCopper'])

		for j = 1, itemFrameBox:GetNumRegions() do
			local region = select(j, itemFrameBox:GetRegions())
			if region and region:IsObjectType('Texture') then
				if region:GetTexture() == [[Interface\ChatFrame\UI-ChatInputBorder-Left]] or region:GetTexture() == [[Interface\ChatFrame\UI-ChatInputBorder-Right]] then
					region:Kill()
				end
			end
		end

		closeButton:StripTextures()
		S:HandleCloseButton(closeButton, staticPopup)

		itemFrame:GetNormalTexture():Kill()
		itemFrame:SetTemplate()
		itemFrame:StyleButton()

		hooksecurefunc('StaticPopup_Show', function(which, _, _, data)
			local info = _G.StaticPopupDialogs[which]
			if not info then return nil end

			if info.hasItemFrame then
				if data and type(data) == 'table' then
					if data.color then
						itemFrame:SetBackdropBorderColor(unpack(data.color))
					else
						itemFrame:SetBackdropBorderColor(1, 1, 1, 1)
					end
				end
			end
		end)

		itemFrameTexture:SetTexCoords()
		itemFrameTexture:SetInside()

		itemFrameNormal:SetAlpha(0)
		itemFrameName:Kill()

		select(8, wideBox:GetRegions()):Hide()
		S:HandleEditBox(wideBox)
		wideBox:Height(22)

		for j = 1, 3 do
			S:HandleButton(_G['StaticPopup'..i..'Button'..j])
		end
	end

	--DropDownMenu
	S:SkinDropDownMenu('DropDownList')

	-- Other Frames
	_G.TicketStatusFrameButton:SetTemplate('Transparent')
	_G.AutoCompleteBox:SetTemplate('Transparent')
	_G.ConsolidatedBuffsTooltip:SetTemplate('Transparent')

	-- Basic Script Errors
	_G.BasicScriptErrors:SetScale(E.global.general.UIScale)
	_G.BasicScriptErrors:SetTemplate('Transparent')
	S:HandleButton(_G.BasicScriptErrorsButton)

	-- BNToast Frame
	_G.BNToastFrame:SetTemplate('Transparent')

	_G.BNToastFrameCloseButton:Size(32)
	S:HandleCloseButton(_G.BNToastFrameCloseButton, _G.BNToastFrame)

	-- Ready Check Frame
	local ReadyCheckFrame = _G.ReadyCheckFrame
	ReadyCheckFrame:EnableMouse(true)
	ReadyCheckFrame:SetTemplate('Transparent')

	S:HandleButton(_G.ReadyCheckFrameYesButton)
	_G.ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameYesButton:ClearAllPoints()
	_G.ReadyCheckFrameYesButton:Point('TOPRIGHT', ReadyCheckFrame, 'CENTER', -3, -5)

	S:HandleButton(_G.ReadyCheckFrameNoButton)
	_G.ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameNoButton:ClearAllPoints()
	_G.ReadyCheckFrameNoButton:Point('TOPLEFT', ReadyCheckFrame, 'CENTER', 4, -5)

	_G.ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameText:Point('TOP', 0, -15)
	_G.ReadyCheckFrameText:SetTextColor(1, 1, 1)

	_G.ReadyCheckListenerFrame:SetAlpha(0)

	-- Coin PickUp Frame
	_G.CoinPickupFrame:StripTextures()
	_G.CoinPickupFrame:SetTemplate('Transparent')

	S:HandleButton(_G.CoinPickupOkayButton)
	S:HandleButton(_G.CoinPickupCancelButton)

	-- Zone Text Frame
	_G.ZoneTextFrame:ClearAllPoints()
	_G.ZoneTextFrame:Point('TOP', 0, -128)

	-- Stack Split Frame
	local StackSplitFrame = _G.StackSplitFrame
	StackSplitFrame:SetTemplate('Transparent')
	StackSplitFrame:GetRegions():Hide()
	StackSplitFrame:SetFrameStrata('DIALOG')

	StackSplitFrame.bg1 = CreateFrame('Frame', nil, StackSplitFrame)
	StackSplitFrame.bg1:OffsetFrameLevel(-1)
	StackSplitFrame.bg1:SetTemplate('Transparent')
	StackSplitFrame.bg1:Point('TOPLEFT', 10, -15)
	StackSplitFrame.bg1:Point('BOTTOMRIGHT', -10, 55)

	S:HandleButton(_G.StackSplitOkayButton)
	S:HandleButton(_G.StackSplitCancelButton)

	-- Opacity Frame
	_G.OpacityFrame:StripTextures()
	_G.OpacityFrame:SetTemplate('Transparent')

	S:HandleSliderFrame(_G.OpacityFrameSlider)

	-- Channel Pullout Frame
	_G.ChannelPullout:SetTemplate('Transparent')

	_G.ChannelPulloutBackground:Kill()

	S:HandleTab(_G.ChannelPulloutTab)
	_G.ChannelPulloutTab:Size(107, 26)
	_G.ChannelPulloutTabText:Point('LEFT', _G.ChannelPulloutTabLeft, 'RIGHT', 0, 4)

	S:HandleCloseButton(_G.ChannelPulloutCloseButton, _G.ChannelPullout)
	_G.ChannelPulloutCloseButton:Size(32)

	-- Chat Menu
	do
		local menuBackdrop = function(s)
			s:SetTemplate('Transparent')
		end

		local chatMenuBackdrop = function(s)
			s:SetTemplate('Transparent')

			s:ClearAllPoints()
			s:Point('BOTTOMLEFT', _G.ChatFrame1, 'TOPLEFT', 0, 30)
		end

		for index, menu in next, { _G.ChatMenu, _G.EmoteMenu, _G.LanguageMenu, _G.VoiceMacroMenu } do
			menu:StripTextures()

			if index == 1 then -- ChatMenu
				menu:HookScript('OnShow', chatMenuBackdrop)
			else
				menu:HookScript('OnShow', menuBackdrop)
			end

			local name = menu:GetName()
			for _, child in next, { menu:GetChildren() } do
				if child:GetName() and child:GetName():find(name..'Button') then
					S:HandleButtonHighlight(child, unpack(E.media.rgbvaluecolor))
				end
			end
		end
	end

	-- Localization specific frames
	if E.locale == 'koKR' then
		S:HandleButton(_G.GameMenuButtonRatings)

		-- RatingMenuFrame
		_G.RatingMenuFrame:SetTemplate('Transparent')
		_G.RatingMenuFrameHeader:SetTexture()
		S:HandleButton(_G.RatingMenuButtonOkay)

		_G.RatingMenuButtonOkay:Point('BOTTOMRIGHT', -8, 8)
	elseif E.locale == 'ruRU' then
		-- Declension Frame
		local DeclensionFrame = _G.DeclensionFrame
		DeclensionFrame:SetTemplate('Transparent')

		S:HandleNextPrevButton(_G.DeclensionFrameSetPrev, 'left')
		S:HandleNextPrevButton(_G.DeclensionFrameSetNext, 'right')
		S:HandleButton(_G.DeclensionFrameOkayButton)
		S:HandleButton(_G.DeclensionFrameCancelButton)

		_G.DeclensionFrameSet:Point('BOTTOM', 0, 40)
		_G.DeclensionFrameOkayButton:Point('RIGHT', DeclensionFrame, 'BOTTOM', -3, 19)
		_G.DeclensionFrameCancelButton:Point('LEFT', DeclensionFrame, 'BOTTOM', 3, 19)

		hooksecurefunc('DeclensionFrame_Update', function()
			for i = 1, _G.RUSSIAN_DECLENSION_PATTERNS do
				_G['DeclensionFrameDeclension'..i..'Edit']:SetTemplate('Default')
			end
		end)
	end
end)