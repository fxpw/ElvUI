local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	local PlayerTalentFrame = _G.PlayerTalentFrame
	S:HandlePortraitFrame(PlayerTalentFrame)

	PlayerTalentFrameTitleGlowLeft:SetAlpha(0)
	PlayerTalentFrameTitleGlowRight:SetAlpha(0)
	PlayerTalentFrameTitleGlowCenter:SetAlpha(0)

	hooksecurefunc(PlayerTalentFrameTitleGlowCenter, "SetTexture", function(_, texture)
		if texture == "Interface\\TalentFrame\\TalentFrame-Horizontal-purple" then
			PlayerTalentFrame:SetBackdropBorderColor(0.64, 0.19, 0.79)
		else
			PlayerTalentFrame:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	PlayerTalentFrameInset:StripTextures()
	PlayerTalentFrameTalents:StripTextures()

	S:HandleButton(PlayerTalentFrameActivateButton)

	S:HandleButton(PlayerTalentFrameToggleSummariesButton, true)

	PlayerTalentFrameImportFrameButton.OuterBorderButton:SetAlpha(0)


	PlayerTalentLinkButton:GetNormalTexture():SetTexCoord(6 / 32, 24 / 32, 12 / 32, 24 / 32)
	PlayerTalentLinkButton:GetPushedTexture():SetTexCoord(6 / 32, 24 / 32, 14 / 32, 26 / 32)
	PlayerTalentLinkButton:GetHighlightTexture():Kill()
	PlayerTalentLinkButton:CreateBackdrop()
	PlayerTalentLinkButton:SetSize(19, 14)
	PlayerTalentLinkButton:SetPoint("TOPRIGHT", -16, -36)

	local function StripTalentFramePanelTextures(object)
		for i = 1, object:GetNumRegions() do
			local region = select(i, object:GetRegions())
			if region:GetObjectType() == "Texture" then
				if region:GetName() and region:GetName():find("Branch") then
					region:SetDrawLayer("OVERLAY")
				else
					region:SetTexture(nil)
				end
			end
		end
	end

	for i = 1, 3 do
		local panel = _G["PlayerTalentFramePanel"..i]
		local summary = _G["PlayerTalentFramePanel"..i.."Summary"]
		local summaryIcon = _G["PlayerTalentFramePanel"..i.."SummaryIcon"]
		local header = _G["PlayerTalentFramePanel"..i.."HeaderIcon"]
		local headerIcon = _G["PlayerTalentFramePanel"..i.."HeaderIconIcon"]
		local headerText = _G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpent"]
		--local roleIcon = _G["PlayerTalentFramePanel"..i.."SummaryRoleIcon"]
		--local treeButton = _G["PlayerTalentFramePanel"..i.."SelectTreeButton"]
		local activeBonus = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1"]
		local activeBonusIcon = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1Icon"]
		local arrow = _G["PlayerTalentFramePanel"..i.."Arrow"]
		local tab = _G["PlayerTalentFrameTab"..i]

		StripTalentFramePanelTextures(panel)

		panel:CreateBackdrop("Transparent")
		panel.backdrop:Point("TOPLEFT", 4, -4)
		panel.backdrop:Point("BOTTOMRIGHT", -4, 4)

		summary:StripTextures()
		summary:CreateBackdrop()
		summary:SetFrameLevel(summary:GetFrameLevel() + 2)

		summaryIcon:SetTexCoord(unpack(E.TexCoords))

		header:StripTextures()
		header:CreateBackdrop()
		header.backdrop:SetOutside(headerIcon)
		header:SetFrameLevel(header:GetFrameLevel() + 1)
		header:Point("TOPLEFT", panel, "TOPLEFT", 4, -4)

		headerIcon:Size(E.PixelMode and 34 or 30)
		headerIcon:SetTexCoord(unpack(E.TexCoords))
		headerIcon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))

		headerText:FontTemplate(nil, 13, "OUTLINE")
		headerText:Point("BOTTOMRIGHT", header, "BOTTOMRIGHT", 125, 11)

		activeBonus:StripTextures()
		activeBonus:CreateBackdrop()
		activeBonus.backdrop:SetOutside(activeBonusIcon)
		activeBonus:SetFrameLevel(activeBonus:GetFrameLevel() + 1)

		activeBonusIcon:SetTexCoord(unpack(E.TexCoords))

		arrow:SetFrameLevel(arrow:GetFrameLevel() + 2)

		for j = 1, 4 do
			local summaryBonus = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j]
			local summaryBonusIcon = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j.."Icon"]

			summaryBonus:StripTextures()
			summaryBonus:CreateBackdrop()
			summaryBonus.backdrop:SetOutside(summaryBonusIcon)
			summaryBonus:SetFrameLevel(summaryBonus:GetFrameLevel() + 1)

			summaryBonusIcon:SetTexCoord(unpack(E.TexCoords))
		end

		S:HandleTab(tab)
	end

	hooksecurefunc("PlayerTalentFramePanel_UpdateSummary", function(self)
		if self.Summary then
			if PlayerTalentFrame.primaryTree and self.talentTree == PlayerTalentFrame.primaryTree then
				self.Summary.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
			else
				self.Summary.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	local function TalentButtons(i, j)
		local button = _G["PlayerTalentFramePanel"..i.."Talent"..j]
		button:StripTextures()
		button:CreateBackdrop()
		button:StyleButton()

		button.SetHighlightTexture = E.noop
		button:GetHighlightTexture():SetAllPoints()
		button.SetPushedTexture = E.noop
		button:GetPushedTexture():SetAllPoints()
		button:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		button:SetNormalTexture("")

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:SetAllPoints()

		button.Rank:FontTemplate()
	end

	for i = 1, 3 do
		for j = 1, 40 do
			TalentButtons(i, j)
		end
	end

	PlayerTalentFramePanel2SummaryRoleIcon2:Kill()
	PlayerTalentFramePetShadowOverlay:Kill()

	-- Side Tabs
	PlayerTalentFrame:HookScript("OnShow", function(self)
		for _, tab in ipairs(self.specTabs) do
			if not tab.isSkinned then
				tab:GetRegions():Hide()
				tab:SetTemplate()
				tab:StyleButton(nil, true)
				tab:GetHighlightTexture().SetTexture = E.noop
				tab:GetCheckedTexture().SetTexture = E.noop
				tab:GetNormalTexture():SetInside()
				tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

				tab.isSkinned = true
			end

			if tab.EtherealBorder:IsShown() then
				tab:SetBackdropBorderColor(0.64, 0.19, 0.79)
				tab.EtherealBorder:Hide()
			end
		end
	end)

	-- Pet Talents
	PlayerTalentFramePetTalents:StripTextures()

	PlayerTalentFramePetModel:CreateBackdrop("Transparent")
	PlayerTalentFramePetModel:Height(319)

	PlayerTalentFramePetModelRotateLeftButton:Kill()
	PlayerTalentFramePetModelRotateRightButton:Kill()

	S:HandleButton(PlayerTalentFrameLearnButton, true)
	S:HandleButton(PlayerTalentFrameBackButton, true)
	S:HandleButton(PlayerTalentFrameScreenshotButton, true)
	S:HandleButton(PlayerTalentFrameResetButton, true)

	PlayerTalentFramePetInfo:StripTextures()
	PlayerTalentFramePetInfo:CreateBackdrop()
	PlayerTalentFramePetInfo.backdrop:SetOutside(PlayerTalentFramePetIcon)
	PlayerTalentFramePetInfo:SetFrameLevel(PlayerTalentFramePetInfo:GetFrameLevel() + 1)
	PlayerTalentFramePetInfo:ClearAllPoints()
	PlayerTalentFramePetInfo:Point("BOTTOMLEFT", PlayerTalentFramePetModel, "TOPLEFT", -3, 9)

	PlayerTalentFramePetIcon:SetTexCoord(unpack(E.TexCoords))

	PlayerTalentFramePetDiet:StripTextures()
	PlayerTalentFramePetDiet:CreateBackdrop()
	PlayerTalentFramePetDiet:Point("TOPRIGHT", 2, -2)
	PlayerTalentFramePetDiet:Size(40)

	PlayerTalentFramePetDiet.icon = PlayerTalentFramePetDiet:CreateTexture(nil, "OVERLAY")
	PlayerTalentFramePetDiet.icon:SetTexture("Interface\\Icons\\Ability_Hunter_BeastTraining")
	PlayerTalentFramePetDiet.icon:SetAllPoints()
	PlayerTalentFramePetDiet.icon:SetTexCoord(unpack(E.TexCoords))

	PlayerTalentFramePetTypeText:Point("BOTTOMRIGHT", -45, 10)

	StripTalentFramePanelTextures(PlayerTalentFramePetPanel)

	PlayerTalentFramePetPanelHeaderIcon:StripTextures()
	PlayerTalentFramePetPanelHeaderIcon:CreateBackdrop()
	PlayerTalentFramePetPanelHeaderIcon.backdrop:SetOutside(PlayerTalentFramePetPanelHeaderIconIcon)
	PlayerTalentFramePetPanelHeaderIcon:SetFrameLevel(PlayerTalentFramePetPanelHeaderIcon:GetFrameLevel() + 1)
	PlayerTalentFramePetPanelHeaderIcon:Point("TOPLEFT", PlayerTalentFramePetPanel, "TOPLEFT", 5, -5)

	PlayerTalentFramePetPanelHeaderIconIcon:Size(E.PixelMode and 46 or 42)
	PlayerTalentFramePetPanelHeaderIconIcon:SetTexCoord(unpack(E.TexCoords))
	PlayerTalentFramePetPanelHeaderIconIcon:Point("TOPLEFT", E.PixelMode and 0 or 3, E.PixelMode and 0 or -3)

	local petPoints = select(4, PlayerTalentFramePetPanelHeaderIcon:GetRegions())
	petPoints:FontTemplate(nil, 13, "OUTLINE")
	petPoints:ClearAllPoints()
	petPoints:Point("BOTTOMRIGHT", PlayerTalentFramePetPanelHeaderIcon, "BOTTOMRIGHT", 150, 15)

	PlayerTalentFramePetPanelArrow:SetFrameStrata("HIGH")

	PlayerTalentFramePetPanel:CreateBackdrop("Transparent")
	PlayerTalentFramePetPanel.backdrop:Point("TOPLEFT", 4, -4)
	PlayerTalentFramePetPanel.backdrop:Point("BOTTOMRIGHT", -4, 4)

	PlayerTalentFramePetPanel:HookScript("OnShow", function()
		for i = 1, GetNumTalents(1, false, true) do
			local button = _G["PlayerTalentFramePetPanelTalent"..i]
			local icon = _G["PlayerTalentFramePetPanelTalent"..i.."IconTexture"]
			if not button.isSkinned then

				button:StripTextures()
				button:CreateBackdrop()
				button:StyleButton()
				button:SetFrameLevel(button:GetFrameLevel() + 1)

				button.SetHighlightTexture = E.noop
				button:GetHighlightTexture():SetAllPoints(icon)
				button.SetPushedTexture = E.noop
				local gpt = button:GetPushedTexture()
				if gpt then
					gpt:SetAllPoints(icon)
					-- button:GetPushedTexture():SetAllPoints(icon)
					button:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
				end
				local gnt = button:GetNormalTexture()
				if gnt then
					-- gnt:SetAllPoints(icon)
					-- button:GetPushedTexture():SetAllPoints(icon)
					button:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
				end
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetAllPoints()

				if button.Rank then
					button.Rank:FontTemplate(nil, 12, "OUTLINE")
					button.Rank:ClearAllPoints()
					button.Rank:Point("BOTTOMRIGHT", 9, -12)
				end

				button.isSkinned = true
			end
		end
	end)

	PlayerGlyphPreviewFrame:StripTextures()
	PlayerGlyphPreviewFrame:SetTemplate("Transparent")
	PlayerGlyphPreviewFrameHbar:Hide()

	local slots = {
		"MajorSlot1",
		"MajorSlot2",
		"MajorSlot3",
		"MinorSlot1",
		"MinorSlot2",
		"MinorSlot3"
	}

	for i = 1, #slots do
		local slot = PlayerGlyphPreviewFrame[slots[i]]
		slot:CreateBackdrop()
		slot.backdrop:SetOutside(slot.Icon)
		slot.Icon:SetTexCoord(unpack(E.TexCoords))
		slot.NameFrame:SetAlpha(0)
	end
	-- PlayerTalentPopupFrame:HookScript("OnUpdate",function()
		PlayerTalentPopupFrame:StripTextures()
		PlayerTalentPopupFrame.BG:StripTextures()
		PlayerTalentPopupFrame.BorderBox:StripTextures()
		-- PlayerTalentPopupFrame.backdrop:StripTextures()
		PlayerTalentPopupFrame.ScrollFrame:StripTextures()
		-- PlayerTalentPopupFrameScrollFrameScrollBar.thumbTexture:StripTextures()
		-- PlayerTalentPopupFrameScrollFrameScrollBar.backdrop:StripTextures()
		PlayerTalentPopupFrame:CreateBackdrop("Transparent")
		S:HandleButton(PlayerTalentPopupFrameOkayButton)
		S:HandleButton(PlayerTalentPopupFrameCancelButton)
		S:HandleEditBox(PlayerTalentPopupFrameEditBox)
		S:HandleEditBox(PlayerTalentPopupFrameSearchBox)
		S:HandleScrollBar(PlayerTalentPopupFrameScrollFrameScrollBar)
		for k,v in pairs(PlayerTalentPopupFrame.buttons) do
			v:StripTextures()
			-- S:HandleButton(v)
			v:StyleButton(nil, true)
			-- v.glossTex = "ElvUI Norm"
			v:SetTemplate("Default", true)
			v.Icon:SetTexCoord(unpack(E.TexCoords))
			v.Icon:SetInside()
			-- v.border:StripTextures()
		end
	-- end)
end

S:AddCallback("Sirus_Talent", LoadSkin)