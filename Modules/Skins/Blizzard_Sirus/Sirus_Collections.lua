local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local ipairs = ipairs
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.collections then return end
	--tab for mount pet and transmog
	for i = 1, 5 do
		local tab = _G["CollectionsJournalTab" .. i]
		if tab then
			S:HandleTab(tab)
			tab.HighlightLeft:StripTextures()
			tab.HighlightMiddle:StripTextures()
			tab.HighlightRight:StripTextures()
		end
	end
	S:HandlePortraitFrame(CollectionsJournal)

	MountJournal.navBar:StripTextures()
	MountJournal.navBar.overlay:StripTextures()

	S:HandleButton(MountJournal.navBar.home, true)
	MountJournal.navBar.home.xoffset = 1

	MountJournal.navBar:ClearAllPoints()
	MountJournal.navBar:SetPoint("TOPLEFT", 6, -22)

	hooksecurefunc("NavBar_AddButton", function(self, buttonData)
		if self ~= MountJournal.navBar then return end
		local navButton = self.navList[#self.navList]
		if navButton and not navButton.isSkinned then
			S:HandleButton(navButton, true)
			navButton.xoffset = 1
			navButton.isSkinned = true
		end
	end)

	for i = 1, #MountJournal.navBar.navList do
		local navButton = MountJournal.navBar.navList[i]
		if navButton and not navButton.isSkinned then
			S:HandleButton(navButton, true)
			navButton.xoffset = 1
			navButton.isSkinned = true
		end
	end

	S:HandleEditBox(MountJournal.searchBox)

	MountJournal.FilterButton:StripTextures(true)
	S:HandleButton(MountJournal.FilterButton)

	MountJournal.ListScrollFrame:StripTextures()
	S:HandleScrollBar(MountJournal.ListScrollFrame.scrollBar)

	for _, button in ipairs(MountJournal.ListScrollFrame.buttons) do
		button.icon:Size(40)
		button.icon:SetDrawLayer("BORDER")
		S:HandleIcon(button.icon)

		local highlight = button:GetHighlightTexture()
		button:SetHighlightTexture(E.Media.Textures.Highlight)
		highlight:SetTexCoord(0, 1, 0, 1)
		highlight:SetVertexColor(1, 1, 1, .35)
		highlight:SetAllPoints()

		button.iconBorder:SetTexture()
		button.background:SetTexture()

		button.selectedTexture:SetTexture(E.Media.Textures.Highlight)
		button.selectedTexture:SetTexCoord(0, 1, 0, 1)
		button.selectedTexture:SetVertexColor(1, .8, .1, .35)
		button.selectedTexture:SetAllPoints()

		button.favorite:SetParent(button.backdrop)
	end

	for _, button in ipairs(MountJournal.CategoryScrollFrame.buttons) do
		button:SetHighlightTexture(E.Media.Textures.Highlight)
		button:GetHighlightTexture():SetVertexColor(1, 1, 1)
		button:GetHighlightTexture().SetAlpha = E.noop

		button.Background:SetTexture()

		button.Icon:SetDrawLayer("BORDER")
		S:HandleIcon(button.Icon)
	end

	hooksecurefunc("MountJournal_CategoryDisplayButton", function(button, element)
		if element then
			button.backdrop:SetShown(element.isCategory)
			local highlight = button:GetHighlightTexture()
			highlight:SetTexCoord(0, 1, 0, 1)
			highlight:SetAllPoints()
		end
	end)

	MountJournal.CategoryScrollFrame:StripTextures()
	S:HandleScrollBar(MountJournal.CategoryScrollFrame.scrollBar)

	MountJournal.LeftInset:StripTextures()

	MountJournal.RightTopInset:StripTextures()

	MountJournal.RightBottomInset:StripTextures()

	MountJournal.MountCount:StripTextures()

	MountJournal.MountDisplay:StripTextures()

	MountJournal.MountDisplay.ShadowOverlay:Hide()

	S:HandleRotateButton(MountDisplayModelSceneRotateLeftButton)
	S:HandleRotateButton(MountDisplayModelSceneRotateRightButton)
	S:HandleCheckBox(MountDisplayModelSceneTogglePlayer)

	-- Не нашел отдельного метода под ActionButton.
	S:HandleItemButton(MountJournal.SummonRandomFavoriteButton)

	S:HandleIcon(MountJournal.MountDisplay.ModelScene.InfoButton.Icon)
	S:HandleButton(MountJournal.MountDisplay.ModelScene.buyFrame.buyButton)

	S:HandleButton(MountJournal.MountButton, true)

	-- путеводитель
	S:HandleButton(MountDisplayModelSceneEJFrameOpenEJButton)
	S:HandleButton(PetJournalPetDisplayModelSceneEJFrameOpenEJButton)
	-- pet tab
	S:HandleRotateButton(PetJournalPetDisplayModelSceneRotateLeftButton)
	S:HandleRotateButton(PetJournalPetDisplayModelSceneRotateRightButton)
	S:HandleButton(PetJournalSummonButton, true)

	S:HandleScrollBar(PetJournalListScrollFrameScrollBar)

	PetJournalFilterButton:StripTextures(true)
	S:HandleButton(PetJournalFilterButton)

	S:HandleEditBox(PetJournalSearchBox)

	--pet tab ListScrollFrame
	for _, button in ipairs(PetJournal.ListScrollFrame.buttons) do
		local highlight = button:GetHighlightTexture()
		button:SetHighlightTexture(E.Media.Textures.Highlight)
		highlight:SetTexCoord(0, 1, 0, 1)
		highlight:SetVertexColor(1, 1, 1, .35)
		highlight:SetAllPoints()
		-- print(highlight)
		button.Background:SetTexture()

		button.Icon:SetDrawLayer("BORDER")
		S:HandleIcon(button.Icon)

		button.DragButton.Favorite:SetParent(button.backdrop)
	end

	-- right frame
	PetJournal.LeftInset:StripTextures()
	PetJournal.RightInset:StripTextures()
	PetJournal.PetDisplay:StripTextures()
	PetJournal.PetDisplay.ShadowOverlay:Hide()
	--pet count
	PetJournal.PetCount:StripTextures()
	-- pet icon
	S:HandleIcon(PetJournal.PetDisplay.InfoButton.Icon)
	S:HandleItemButton(_G.PetJournal.SummonRandomFavoritePetButton, true)
end

S:AddCallback("Skin_Collections", LoadSkin)