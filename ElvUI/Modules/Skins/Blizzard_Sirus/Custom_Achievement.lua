local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

local function SkinSearchButton(self)
	self:StripTextures()

	if self.icon then
		S:HandleIcon(self.icon)
	end

	self:CreateBackdrop("Transparent")
	self:SetHighlightTexture(E.media.normTex)

	local hl = self:GetHighlightTexture()
	hl:SetVertexColor(1, 1, 1, 0.3)
	hl:Point("TOPLEFT", 1, -1)
	hl:Point("BOTTOMRIGHT", -1, 1)
end

S:AddCallbackForAddon("Blizzard_AchievementUI", "Skin_Custom_AchievementUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.achievement then return end

	AchievementFrameFilterDropDown:ClearAllPoints()
	AchievementFrameFilterDropDown:Point("TOPLEFT", AchievementFrame, "TOPLEFT", 220, -6)

	S:HandleEditBox(AchievementFrame.searchBox)
	AchievementFrame.searchBox.backdrop:Point("TOPLEFT", AchievementFrame.searchBox, "TOPLEFT", -3, -3)
	AchievementFrame.searchBox.backdrop:Point("BOTTOMRIGHT", AchievementFrame.searchBox, "BOTTOMRIGHT", 0, 3)
	AchievementFrame.searchBox:ClearAllPoints()
	AchievementFrame.searchBox:Point("TOPLEFT", AchievementFrame, "TOPLEFT", 604, -6)
	AchievementFrame.searchBox:Size(107, 25)

	AchievementFrame.searchResults:StripTextures()
	AchievementFrame.searchResults:CreateBackdrop("Transparent")
	AchievementFrame.searchPreviewContainer:StripTextures()
	AchievementFrame.searchPreviewContainer:ClearAllPoints()
	AchievementFrame.searchPreviewContainer:Point("TOPLEFT", AchievementFrame, "TOPRIGHT", 2, -1)

	for i = 1, 5 do
		SkinSearchButton(AchievementFrame.searchPreviewContainer["searchPreview"..i])
	end
	SkinSearchButton(AchievementFrame.searchPreviewContainer.showAllSearchResults)

	hooksecurefunc("AchievementFrame_UpdateFullSearchResults", function()
		local numResults = GetNumFilteredAchievements()

		local scrollFrame = AchievementFrame.searchResults.scrollFrame
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local results = scrollFrame.buttons
		local result, index

		for i = 1, #results do
			result = results[i]
			index = offset + i

			if index <= numResults then
				if not result.styled then
					result:SetNormalTexture("")
					result:SetPushedTexture("")
					result:GetRegions():SetAlpha(0)

					result.resultType:SetTextColor(1, 1, 1)
					result.path:SetTextColor(1, 1, 1)

					result.styled = true
				end

				if result.icon:GetTexCoord() == 0 then
					result.icon:SetTexCoord(unpack(E.TexCoords))
				end
			end
		end
	end)

	hooksecurefunc(AchievementFrame.searchResults.scrollFrame, "update", function(self)
		for i = 1, #self.buttons do
			local result = self.buttons[i]

			if result.icon:GetTexCoord() == 0 then
				result.icon:SetTexCoord(unpack(E.TexCoords))
			end
		end
	end)

	S:HandleCloseButton(AchievementFrame.searchResults.closeButton)
	S:HandleScrollBar(AchievementFrameSearchResultsScrollFrameScrollBar)
end)