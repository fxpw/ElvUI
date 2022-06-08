local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.roulette ~= true then return end

	Custom_RouletteFrame:SetParent(UIParent)
	Custom_RouletteFrame:SetScale(1)
	Custom_RouletteFrame:SetFrameStrata("HIGH")

	Custom_RouletteFrame:StripTextures(true)
	Custom_RouletteFrame:SetTemplate("Transparent")
	Custom_RouletteFrame:SetSize(804, 600)

	S:HandleCloseButton(Custom_RouletteFrame.closeButton)

	Custom_RouletteFrame.HeaderFrame.Background:Hide()
	Custom_RouletteFrame.HeaderFrame:SetPoint("TOP", 0, 6)
	Custom_RouletteFrame.HeaderFrame.TitleText:FontTemplate(nil, 18, "NONE")

	Custom_RouletteFrame.ToggleCurrencyFrame.Background:SetTexture(E.Media.Textures.Highlight)
	Custom_RouletteFrame.ToggleCurrencyFrame.Background:SetTexCoord(1, 0, 1, 0)
	Custom_RouletteFrame.ToggleCurrencyFrame.Background:SetAlpha(0.3)

	local function OnEnter(button)
		button.Text:SetTextColor(1, 1, 1)
	end

	local function OnLeave(button)
		if not button.active then
			button.Text:SetTextColor(unpack(E.media.rgbvaluecolor))
		end
	end

	local function OnClick(self)
		for _, button in pairs(self:GetParent().currencyButtons) do
			if button.active then
				button.Text:SetTextColor(1, 1, 1)
			else
				button.Text:SetTextColor(unpack(E.media.rgbvaluecolor))
			end
		end
	end

	local function SkinRouletteCurrencyButto(button)
		button.Text:FontTemplate(nil, 14, "NONE")

		if button:GetID() == Custom_RouletteFrame.selectedCurrency then
			button.Text:SetTextColor(1, 1, 1)
			button.active = true
		else
			button.Text:SetTextColor(unpack(E.media.rgbvaluecolor))
		end

		button:HookScript("OnEnter", OnEnter)
		button:HookScript("OnLeave", OnLeave)
		button:HookScript("OnClick", OnClick)

		button:SetFrameLevel(Custom_RouletteFrame.ToggleCurrencyFrame:GetFrameLevel() + 3)
	end

	SkinRouletteCurrencyButto(Custom_RouletteFrame.ToggleCurrencyFrame.CurrencyBonus)
	SkinRouletteCurrencyButto(Custom_RouletteFrame.ToggleCurrencyFrame.CurrencyLuckCoins)

	Custom_RouletteFrame.ToggleCurrencyFrame.CurrencySelector.Selector:SetSize(200, 48)
	Custom_RouletteFrame.ToggleCurrencyFrame.CurrencySelector.Selector:ClearAllPoints()
	Custom_RouletteFrame.ToggleCurrencyFrame.CurrencySelector.Selector:SetPoint("CENTER")
	Custom_RouletteFrame.ToggleCurrencyFrame.CurrencySelector.Selector:SetTexture(E.Media.Textures.Highlight)
	Custom_RouletteFrame.ToggleCurrencyFrame.CurrencySelector.Selector:SetVertexColor(unpack(E.media.rgbvaluecolor))
	Custom_RouletteFrame.ToggleCurrencyFrame.CurrencySelector.Selector:SetTexCoord(1, 0, 1, 0)
	Custom_RouletteFrame.ToggleCurrencyFrame.CurrencySelector.Selector:SetAlpha(0.5)
	Custom_RouletteFrame.ToggleCurrencyFrame.CurrencySelector:SetFrameLevel(Custom_RouletteFrame.ToggleCurrencyFrame:GetFrameLevel() + 1)

	Custom_RouletteFrame.OverlayFrame:SetPoint("CENTER", -2, 140)
	Custom_RouletteFrame.OverlayFrame.Background:SetAlpha(0)
	Custom_RouletteFrame.OverlayFrame.ArtOverlay:StripTextures()

	S:HandleCheckBox(Custom_RouletteFrameSkipAnimation)

	local lineTexture = Custom_RouletteFrame.OverlayFrame.ArtOverlay:CreateTexture()
	lineTexture:Size(3, 122)
	lineTexture:SetPoint("CENTER")
	lineTexture:SetTexture(0.8, 0, 0)

	Custom_RouletteFrame.SpinButton:StripTextures(true)
	Custom_RouletteFrame.SpinButton:SetHeight(48)
	Custom_RouletteFrame.SpinButton:SetPoint("CENTER", 0, 44)
	S:HandleButton(Custom_RouletteFrame.SpinButton)

	for i = 1, #Custom_RouletteFrame.itemButtons do
		local button = Custom_RouletteFrame.itemButtons[i]
		button.OverlayFrame.ChildFrame.ItemName:FontTemplate(nil, 12, "NONE")
	end

	Custom_RouletteFrame.RewardItemsFrame:SetHeight(304)
	Custom_RouletteFrame.RewardItemsFrame.TitleFrame.Background:SetTexture(E.Media.Textures.Highlight)
	Custom_RouletteFrame.RewardItemsFrame.TitleFrame.Background:SetTexCoord(1, 0, 1, 0)
	Custom_RouletteFrame.RewardItemsFrame.TitleFrame.Background:SetAlpha(0.3)
	Custom_RouletteFrame.RewardItemsFrame.TitleFrame.Text:FontTemplate(nil, 16, "NONE")
	Custom_RouletteFrame.RewardItemsFrame.TitleFrame.Text:SetTextColor(1, 1, 1)

	for i = 1, #Custom_RouletteFrame.rewardButtons do
		local button = Custom_RouletteFrame.rewardButtons[i]
		button.Background:SetDrawLayer("BORDER")
		button.Background:SetInside()
		button.Border:SetAlpha(0)
		button:SetTemplate()
		button.OverlayFrame.ChildFrame.ItemName:FontTemplate(nil, 12, "NONE")

		local r, g, b = button.Border:GetVertexColor()
		button:SetBackdropBorderColor(r, g, b)
	end
end

S:AddCallback("Custom_Roulette", LoadSkin)