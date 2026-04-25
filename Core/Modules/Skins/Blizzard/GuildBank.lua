local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local select, unpack = select, unpack

local CreateFrame = CreateFrame
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetGuildBankItemLink = GetGuildBankItemLink
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon("Blizzard_GuildBankUI", "Skin_Blizzard_GuildBankUI", function()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gbank) then return end

	local GuildBankFrame = GuildBankFrame
	GuildBankFrame:Width(639)
	GuildBankFrame:StripTextures()
	GuildBankFrame:CreateBackdrop("Transparent")
	GuildBankFrame.backdrop:Point("TOPLEFT", 11, -12)
	GuildBankFrame.backdrop:Point("BOTTOMRIGHT", 0, 8)

	S:HookScript(GuildBankFrame, "OnShow", function(self)
		S:SetUIPanelWindowInfo(self, "width", nil, 35)
		S:SetBackdropHitRect(self)
		S:Unhook(self, "OnShow")
	end)

	GuildBankFrame.inset = CreateFrame("Frame", nil, GuildBankFrame)
	GuildBankFrame.inset:SetTemplate("Default")
	GuildBankFrame.inset:Point("TOPLEFT", 19, -64)
	GuildBankFrame.inset:Point("BOTTOMRIGHT", -8, 62)

	GuildBankEmblemFrame:StripTextures(true)

	S:HandleCloseButton((select(13, GuildBankFrame:GetChildren())), GuildBankFrame.backdrop)

	S:HandleButton(GuildBankFrameDepositButton)
	S:HandleButton(GuildBankFrameWithdrawButton)
	S:HandleButton(GuildBankInfoSaveButton)
	S:HandleButton(GuildBankFramePurchaseButton)

	GuildBankInfoScrollFrame:StripTextures()

	S:HandleScrollBar(GuildBankInfoScrollFrameScrollBar)

	GuildBankTransactionsScrollFrame:StripTextures()

	S:HandleScrollBar(GuildBankTransactionsScrollFrameScrollBar)

	for i = 1, 4 do
		local tab = _G['GuildBankFrameTab'..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:Point('BOTTOMLEFT', GuildBankFrame, 'BOTTOMLEFT', -2, -26)
		end
	end

	for i = 1, MAX_GUILDBANK_TABS do
		local tab = _G["GuildBankTab"..i]
		local button = _G["GuildBankTab"..i.."Button"]
		local texture = _G["GuildBankTab"..i.."ButtonIconTexture"]

		tab:StripTextures(true)

		button:StripTextures()
		button:SetTemplate()
		button:StyleButton()

		button:GetCheckedTexture():SetTexture(1, 1, 1, 0.3)
		button:GetCheckedTexture():SetInside()

		texture:SetInside()
		texture:SetTexCoords()
		texture:SetDrawLayer("ARTWORK")
	end

	for i = 1, NUM_GUILDBANK_COLUMNS do
		local column = _G["GuildBankColumn"..i]
		column:StripTextures()

		for x = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = _G["GuildBankColumn"..i.."Button"..x]
			local icon = _G["GuildBankColumn"..i.."Button"..x.."IconTexture"]
			button:StripTextures()
			button:StyleButton()
			button:SetTemplate('Transparent')

			icon:SetInside()
			icon:SetTexCoords()
		end
	end

	GuildBankLimitLabel:ClearAllPoints()
	GuildBankLimitLabel:Point("BOTTOMLEFT", GuildBankMoneyLimitLabel, "TOPLEFT", -1, 11)

	GuildBankFrameDepositButton:Point("BOTTOMRIGHT", -8, 36)
	GuildBankFrameWithdrawButton:Point("RIGHT", GuildBankFrameDepositButton, "LEFT", -3, 0)

	GuildBankFrameTab1:Point("BOTTOMLEFT", 11, -22)
	GuildBankFrameTab2:Point("LEFT", GuildBankFrameTab1, "RIGHT", -15, 0)
	GuildBankFrameTab3:Point("LEFT", GuildBankFrameTab2, "RIGHT", -15, 0)
	GuildBankFrameTab4:Point("LEFT", GuildBankFrameTab3, "RIGHT", -15, 0)

	-- Log + Money Log tabs
	GuildBankMessageFrame:Size(575, 302)
	GuildBankMessageFrame:Point("TOPLEFT", 27, -72)

	GuildBankTransactionsScrollFrame:Size(591, 318)
	GuildBankTransactionsScrollFrame:Point("TOPRIGHT", GuildBankFrame, "TOPRIGHT", -29, -64)

	GuildBankTransactionsScrollFrameScrollBar:Point("TOPLEFT", GuildBankTransactionsScrollFrame, "TOPRIGHT", 3, -19)
	GuildBankTransactionsScrollFrameScrollBar:Point("BOTTOMLEFT", GuildBankTransactionsScrollFrame, "BOTTOMRIGHT", 3, 19)

	-- Info tab
	GuildBankInfo:Point("TOPLEFT", 26, -72)

	GuildBankInfoScrollFrame:Size(575, 302)

	GuildBankInfoScrollFrameScrollBar:Point("TOPLEFT", GuildBankInfoScrollFrame, "TOPRIGHT", 12, -11)
	GuildBankInfoScrollFrameScrollBar:Point("BOTTOMLEFT", GuildBankInfoScrollFrame, "BOTTOMRIGHT", 12, 11)

	GuildBankTabInfoEditBox:Width(575)

	GuildBankInfoSaveButton:Point("BOTTOMLEFT", GuildBankFrame, "BOTTOMLEFT", 19, 35)

	-- Popup
	S:HandleIconSelectionFrame(GuildBankPopupFrame, NUM_GUILDBANK_ICONS_SHOWN, "GuildBankPopupButton", "GuildBankPopup")
	S:SetBackdropHitRect(GuildBankPopupFrame)

	S:HandleScrollBar(GuildBankPopupScrollFrameScrollBar)

	GuildBankPopupFrame:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", 24, 0)

	local nameLable, iconLable = select(5, GuildBankPopupFrame:GetRegions())
	nameLable:Point("TOPLEFT", 24, -18)
	iconLable:Point("TOPLEFT", 24, -60)

	GuildBankPopupEditBox:Point("TOPLEFT", 32, -35)

	GuildBankPopupScrollFrame:CreateBackdrop("Transparent")
	GuildBankPopupScrollFrame.backdrop:Point("TOPLEFT", 91, -10)
	GuildBankPopupScrollFrame.backdrop:Point("BOTTOMRIGHT", -19, 5)
	GuildBankPopupScrollFrame:Point("TOPRIGHT", -30, -66)

	GuildBankPopupScrollFrameScrollBar:Point("TOPLEFT", GuildBankPopupScrollFrame, "TOPRIGHT", -16, -29)
	GuildBankPopupScrollFrameScrollBar:Point("BOTTOMLEFT", GuildBankPopupScrollFrame, "BOTTOMRIGHT", -16, 24)

	GuildBankPopupButton1:Point("TOPLEFT", 24, -82)

	GuildBankPopupCancelButton:Point("BOTTOMRIGHT", -28, 35)
	GuildBankPopupOkayButton:Point("RIGHT", GuildBankPopupCancelButton, "LEFT", -3, 0)

	-- Reposition
	GuildBankTab1:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", E.PixelMode and -3 or -1, -36)
	GuildBankTab2:Point("TOPLEFT", GuildBankTab1, "BOTTOMLEFT", 0, 7)
	GuildBankTab3:Point("TOPLEFT", GuildBankTab2, "BOTTOMLEFT", 0, 7)
	GuildBankTab4:Point("TOPLEFT", GuildBankTab3, "BOTTOMLEFT", 0, 7)
	GuildBankTab5:Point("TOPLEFT", GuildBankTab4, "BOTTOMLEFT", 0, 7)
	GuildBankTab6:Point("TOPLEFT", GuildBankTab5, "BOTTOMLEFT", 0, 7)

	GuildBankColumn1:Point("TOPLEFT", 25, -70)
	GuildBankColumn2:Point("TOPLEFT", GuildBankColumn1, "TOPRIGHT", -14, 0)
	GuildBankColumn3:Point("TOPLEFT", GuildBankColumn2, "TOPRIGHT", -14, 0)
	GuildBankColumn4:Point("TOPLEFT", GuildBankColumn3, "TOPRIGHT", -14, 0)
	GuildBankColumn5:Point("TOPLEFT", GuildBankColumn4, "TOPRIGHT", -14, 0)
	GuildBankColumn6:Point("TOPLEFT", GuildBankColumn5, "TOPRIGHT", -14, 0)
	GuildBankColumn7:Point("TOPLEFT", GuildBankColumn6, "TOPRIGHT", -14, 0)

	GuildBankColumn1Button8:Point("TOPLEFT", GuildBankColumn1Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn2Button8:Point("TOPLEFT", GuildBankColumn2Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn3Button8:Point("TOPLEFT", GuildBankColumn3Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn4Button8:Point("TOPLEFT", GuildBankColumn4Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn5Button8:Point("TOPLEFT", GuildBankColumn5Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn6Button8:Point("TOPLEFT", GuildBankColumn6Button1, "TOPRIGHT", 6, 0)
	GuildBankColumn7Button8:Point("TOPLEFT", GuildBankColumn7Button1, "TOPRIGHT", 6, 0)
end)