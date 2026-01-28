local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

S:AddCallbackForAddon("Blizzard_TalentUI", "Skin_Blizzard_TalentUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.talent then return end

	PlayerTalentFrame:StripTextures(nil, true)
	PlayerTalentFrame:CreateBackdrop("Transparent")
	-- PlayerTalentFrame.backdrop:Point("TOPLEFT", 11, -12)
	-- PlayerTalentFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetBackdropHitRect(PlayerTalentFrame)

	do
		local offset

		local talentGroups = GetNumTalentGroups(false, false)
		local petTalentGroups = GetNumTalentGroups(false, true)

		if talentGroups + petTalentGroups > 1 then
			S:SetUIPanelWindowInfo(PlayerTalentFrame, "width", nil, 31)
			offset = true
		else
			S:SetUIPanelWindowInfo(PlayerTalentFrame, "width")
		end

		hooksecurefunc("PlayerTalentFrame_UpdateSpecs", function(activeTalentGroup, numTalentGroups)
			if offset and numTalentGroups <= 1 then
				S:SetUIPanelWindowInfo(PlayerTalentFrame, "width")
				offset = nil
			elseif not offset and numTalentGroups > 1 then
				S:SetUIPanelWindowInfo(PlayerTalentFrame, "width", nil, 31)
				offset = true
			end
		end)
	end

	S:HandleCloseButton(PlayerTalentFrameCloseButton, PlayerTalentFrame.backdrop)

	local function glyphFrameOnShow(self)
		if GlyphFrame and GlyphFrame:IsShown() then
			self:Hide()
		end
	end

	PlayerTalentFrameStatusFrame:HookScript("OnShow", glyphFrameOnShow)
	PlayerTalentFrameActivateButton:HookScript("OnShow", glyphFrameOnShow)

	PlayerTalentFrameStatusFrame:StripTextures()
	PlayerTalentFramePointsBar:StripTextures()
	PlayerTalentFramePreviewBar:StripTextures()

	S:HandleButton(PlayerTalentFrameActivateButton)
	S:HandleButton(PlayerTalentFrameResetButton)
	S:HandleButton(PlayerTalentFrameLearnButton)

	PlayerTalentFramePreviewBarFiller:StripTextures()

	-- PlayerTalentFrameScrollFrame:StripTextures()
	-- PlayerTalentFrameScrollFrame:CreateBackdrop("Default")
	-- S:HandleScrollBar(PlayerTalentFrameScrollFrameScrollBar)

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["PlayerTalentFrameTalent" .. i]
		local icon = _G["PlayerTalentFrameTalent" .. i .. "IconTexture"]
		local rank = _G["PlayerTalentFrameTalent" .. i .. "Rank"]

		if talent then
			talent:StripTextures()
			talent:SetTemplate("Default")
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("ARTWORK")

			rank:SetFont(E.LSM:Fetch("font", E.db.general.font), 12, "OUTLINE")
		end
	end

	for i = 1, 4 do
		local tab = _G["PlayerTalentFrameTab" .. i]
		if tab then
			tab.HighlightLeft:StripTextures()
			tab.HighlightMiddle:StripTextures()
			tab.HighlightRight:StripTextures()
			S:HandleTab(tab)
		end
	end

	for i = 1, C_Talent.GetNumTalentGroups() do
		local tab = _G["PlayerSpecTab" .. i]
		if tab then
			tab:GetRegions():Hide()

			tab:SetTemplate("Default")
			tab:StyleButton(nil, true)

			tab:GetNormalTexture():SetInside()
			tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		end
	end

	PlayerTalentFrameStatusFrame:Point("TOPLEFT", 57, -40)
	PlayerTalentFrameActivateButton:Point("TOP", 0, -40)

	-- PlayerTalentFrameScrollFrame:Width(302)
	-- PlayerTalentFrameScrollFrame:Point("TOPRIGHT", PlayerTalentFrame, "TOPRIGHT", -62, -77)
	-- PlayerTalentFrameScrollFrame:SetPoint("BOTTOM", PlayerTalentFramePointsBar, "TOP", 0, 0)

	-- PlayerTalentFrameScrollFrameScrollBar:Point("TOPLEFT", PlayerTalentFrameScrollFrame, "TOPRIGHT", 4, -18)
	-- PlayerTalentFrameScrollFrameScrollBar:Point("BOTTOMLEFT", PlayerTalentFrameScrollFrame, "BOTTOMRIGHT", 4, 18)

	S:HandleButton(PlayerTalentFrameResetTalentGroupButton)
	PlayerTalentFrameResetTalentGroupButton:Point("RIGHT", -4, 1)
	PlayerTalentFrameResetButton:Point("RIGHT", PlayerTalentFrameResetTalentGroupButton, "LEFT", -3, 0)
	PlayerTalentFrameLearnButton:Point("RIGHT", PlayerTalentFrameResetButton, "LEFT", -3, 0)
	S:HandleButton(PlayerTalentFrameToggleSummariesButton)
	PlayerTalentFrameToggleSummariesButton:Point("RIGHT", PlayerTalentFrameLearnButton, "LEFT", -3, 0)

	-- PlayerSpecTab1:Point("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", -33, -65)
	-- PlayerSpecTab1.ClearAllPoints = E.noop
	-- PlayerSpecTab1.SetPoint = E.noop

	PlayerTalentFrameTab1:Point("BOTTOMLEFT", 11, 46)

	-- S:HandleButton(PlayerTalentFrameImportButton)
	local importButton = PlayerTalentFrame.ImportFrameButton and PlayerTalentFrame.ImportFrameButton.ImportButton
	if importButton then
		importButton:StripTextures()
		local importTexture = importButton:CreateTexture("PlayerTalentFrameImportButtonTexture")
		-- PlayerTalentFrameImportFrameButton:SetParent(PlayerTalentLinkButton)
		-- PlayerTalentFrameImportFrameButton:ClearAllPoints()
		-- PlayerTalentFrameImportFrameButton:SetPoint("LEFT", PlayerTalentLinkButton, "LEFT",-30,0)
		importTexture:Size(28, 28)
		importTexture:SetPoint("CENTER", 0, 0)
		-- importtexture:SetAllPoints(PlayerTalentFrameImportButton)
		importTexture:SetTexture([[Interface\AddOns\ElvUI\Media\Textures\copy]])
	end
end)