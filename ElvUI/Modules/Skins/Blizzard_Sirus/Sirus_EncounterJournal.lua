local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.encounterjournal then return end

	local EncounterJournal = EncounterJournal
	S:HandlePortraitFrame(EncounterJournal)

	S:HandleEditBox(EncounterJournal.searchBox)

	EncounterJournal.searchBox.searchPreviewContainer:StripTextures()

	for i = 1, 5 do
		local button = EncounterJournal.searchBox["sbutton"..i]
		S:HandleButton(button)
		button.icon:SetTexCoord(unpack(E.TexCoords))

		if i ~= 1 then
			button:Point("TOPLEFT",  EncounterJournal.searchBox["sbutton"..i-1], "BOTTOMLEFT", 0, -E.Border)
			button:Point("TOPRIGHT", EncounterJournal.searchBox["sbutton"..i-1] , "BOTTOMRIGHT", 0, -E.Border)
		end
	end

	S:HandleButton(EncounterJournalSearchBox.showAllResults)
	EncounterJournalSearchBox.showAllResults:Point("TOP", EncounterJournal.searchBox.sbutton5, "BOTTOM", 0, -E.Border)
--	EncounterJournalSearchBox.searchProgress
--	EncounterJournalSearchBox.searchProgress.bar

	EncounterJournal.searchResults:StripTextures()
	EncounterJournal.searchResults:CreateBackdrop()
	S:HandleCloseButton(EncounterJournalSearchResultsCloseButton)
	S:HandleScrollBar(EncounterJournal.searchResults.scrollFrame.scrollBar)

	EncounterJournal.navBar:StripTextures()
	EncounterJournal.navBar.overlay:StripTextures()

	S:HandleButton(EncounterJournal.navBar.home, true)
	EncounterJournal.navBar.home.xoffset = 1

	EncounterJournal.inset:StripTextures()

	EncounterJournal.instanceSelect:StripTextures(true)

	local function SkinTierTab(tab)
		tab:StripTextures(nil, true)
		tab.grayBox:SetAlpha(0)

		tab:SetTemplate("Default", true)

		tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	SkinTierTab(EncounterJournal.instanceSelect.suggestTab)
	SkinTierTab(EncounterJournal.instanceSelect.dungeonsTab)
	SkinTierTab(EncounterJournal.instanceSelect.raidsTab)
	SkinTierTab(EncounterJournal.instanceSelect.LootJournalTab)

	S:HandleDropDownBox(EncounterJournal.instanceSelect.tierDropDown)

	S:HandleScrollBar(EncounterJournal.instanceSelect.scroll.ScrollBar)

	EncounterJournal.encounter.instance.loreBG:SetSize(350, 256)
	EncounterJournal.encounter.instance.loreBG:SetPoint("TOP", 0, -45)
	EncounterJournal.encounter.instance.loreBG:SetTexCoord(0.06, 0.71, 0.08, 0.582)
	EncounterJournal.encounter.instance.loreBG:CreateBackdrop()
	EncounterJournal.encounter.instance.title:SetPoint("TOP", 0, -65)
	EncounterJournal.encounter.instance.titleBG:SetPoint("TOP", EncounterJournal.encounter.instance.loreBG)

	EncounterJournal.encounter.instance.mapButton:StripTextures()
	EncounterJournal.encounter.instance.mapButton:ClearAllPoints()
	EncounterJournal.encounter.instance.mapButton:Point("BOTTOMLEFT", EncounterJournal.encounter.instance.loreBG.backdrop, 5, 5)
	EncounterJournal.encounter.instance.mapButton:StripTextures()
	S:HandleButton(EncounterJournal.encounter.instance.mapButton)

	EncounterJournal.encounter.instance.mapButton.Text:ClearAllPoints()
	EncounterJournal.encounter.instance.mapButton.Text:Point("CENTER")
	EncounterJournal.encounter.instance.mapButton.Text:SetText(SHOW_MAP)
	EncounterJournal.encounter.instance.mapButton:Size(EncounterJournal.encounter.instance.mapButton.Text:GetStringWidth() * 1.5, 25)

	S:HandleScrollBar(EncounterJournal.encounter.instance.loreScroll.ScrollBar)
	EncounterJournal.encounter.instance.loreScroll.child.lore:SetTextColor(1, 1, 1)

	EncounterJournal.encounter.info:StripTextures(nil, true)

	local function SkinEncounterTab(tab)
		tab:Size(48)
		tab:SetTemplate("Default", true)

		tab:SetNormalTexture("")
		tab:SetPushedTexture("")
		tab:SetHighlightTexture("")
		tab:SetDisabledTexture("")

		tab.unselected:SetAllPoints()
		tab.selected:SetAllPoints()

		tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	SkinEncounterTab(EncounterJournal.encounter.info.overviewTab)
	EncounterJournal.encounter.info.overviewTab:Point("TOPLEFT", EncounterJournal.encounter.info, "TOPRIGHT", 9, -35)
	SkinEncounterTab(EncounterJournal.encounter.info.lootTab)
	EncounterJournal.encounter.info.lootTab:Point("TOP", EncounterJournal.encounter.info.overviewTab, "BOTTOM", 0, -1)
	SkinEncounterTab(EncounterJournal.encounter.info.bossTab)
	EncounterJournal.encounter.info.bossTab:Point("TOP", EncounterJournal.encounter.info.lootTab, "BOTTOM", 0, -1)
	SkinEncounterTab(EncounterJournal.encounter.info.modelTab)
	EncounterJournal.encounter.info.modelTab:Point("TOP", EncounterJournal.encounter.info.bossTab, "BOTTOM", 0, -1)

	S:HandleScrollBar(EncounterJournal.encounter.info.bossesScroll.ScrollBar)
	EncounterJournal.encounter.info.bossesScroll.child.description:SetTextColor(1, 1, 1)

	S:HandleButton(EncounterJournal.encounter.info.difficulty, true)
	S:HandleButton(EncounterJournal.encounter.info.reset)

	S:HandleScrollBar(EncounterJournal.encounter.info.detailsScroll.ScrollBar)
	EncounterJournal.encounter.info.detailsScroll.child.description:SetTextColor(1, 1, 1)
	S:HandleScrollBar(EncounterJournal.encounter.info.overviewScroll.ScrollBar)
	EncounterJournal.encounter.info.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)

	S:HandleButton(EncounterJournal.encounter.info.lootScroll.filter, true)
	S:HandleButton(EncounterJournal.encounter.info.lootScroll.slotFilter, true)

	S:HandleScrollBar(EncounterJournal.encounter.info.lootScroll.scrollBar)

	for i = 1, #EncounterJournal.encounter.info.lootScroll.buttons do
		local item = EncounterJournal.encounter.info.lootScroll.buttons[i]
		item.icon:SetDrawLayer("BORDER")
		S:HandleIcon(item.icon)

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)

		item.armorType:SetTextColor(1, 1, 1)
		item.slot:SetTextColor(1, 1, 1)
		item.boss:SetTextColor(1, 1, 1)

		item.IconBorder:SetAlpha(0)
		hooksecurefunc(item.IconBorder, "SetVertexColor", function(_, r, g, b) item.backdrop:SetBackdropBorderColor(r, g, b) end)
		hooksecurefunc(item.IconBorder, "Hide", function() item.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	end

	EncounterJournal.LootJournal:StripTextures()
	S:HandleButton(EncounterJournal.LootJournal.ItemSetsScrollFrame.ClassButton, true)
	S:HandleScrollBar(EncounterJournalLootJournalScrollFrameScrollBar)

	for i = 1, #EncounterJournal.LootJournal.ItemSetsScrollFrame.buttons do
		local set = EncounterJournal.LootJournal.ItemSetsScrollFrame.buttons[i]
		set.Background:Hide()
		set.ItemLevel:SetTextColor(1, 1, 1)

		for j = 1, 8 do
			local button = set["ItemButton"..j]
			button:SetTemplate()
			button.Icon:SetDrawLayer("BORDER")
			button.Icon:SetInside()
			button.Icon:SetTexCoord(unpack(E.TexCoords))

			button.Border:SetAlpha(0)
		end

		hooksecurefunc(set.SetName, "SetTextColor", function(_, r, g, b)
			for j = 1, 8 do
				local button = set["ItemButton"..j]
				button:SetBackdropBorderColor(r, g, b)
			end
		end)
	end

	for i = 1, 2 do
		S:HandleTab(_G["EncounterJournalTab"..i])
	end

	hooksecurefunc("EncounterJournal_ListInstances", function()
		local scrollFrame = EncounterJournal.instanceSelect.scroll.child

		local index = 1
		local instanceButton = scrollFrame["instance"..index]

		while instanceButton do
			if not instanceButton.isSkinned then
				S:HandleButton(instanceButton)

				instanceButton.bgImage:SetInside()
				instanceButton.bgImage:SetTexCoord(.08, .6, .08, .6)
				instanceButton.bgImage:SetDrawLayer("BORDER")

				instanceButton.name:SetTextColor(1, 1, 1)

				instanceButton.isSkinned = true
			end

			index = index + 1
			instanceButton = scrollFrame["instance"..index]
		end
	end)

	hooksecurefunc("EncounterJournal_DisplayInstance", function(instanceID)
		local self = EncounterJournal.encounter
		if EncounterJournal_SearchForOverview(instanceID) then
			self.info.modelTab:SetPoint("TOP", self.info.bossTab, "BOTTOM", 0, -1)
		else
			self.info.modelTab:SetPoint("TOP", self.info.lootTab, "BOTTOM", 0, -1)
		end

		local bossIndex = 1
		local bossButton = _G["EncounterJournalBossButton"..bossIndex]
		while bossButton do
			if not bossButton.isSkinned then
				S:HandleButton(bossButton)
				bossButton:SetTemplate("Transparent")

				bossButton.creature:ClearAllPoints()
				bossButton.creature:Point("TOPLEFT", 1, -4)

				bossButton.text:SetTextColor(1, 1, 1)

				bossButton.isSkinned = true
			end

			bossIndex = bossIndex + 1
			bossButton = _G["EncounterJournalBossButton"..bossIndex]
		end
	end)

	hooksecurefunc("EncounterJournal_ToggleHeaders", function()
		local headerCount = 1
		local header = _G["EncounterJournalInfoHeader"..headerCount]
		while header do
			if not header.isSkinned then
				header.descriptionBG:SetAlpha(0)
				header.descriptionBGBottom:SetAlpha(0)

				for i = 4, 18 do
					select(i, header.button:GetRegions()):SetTexture()
				end

				S:HandleButton(header.button)
				header.button:SetTemplate("Transparent")

				header.button.title:SetTextColor(unpack(E.media.rgbvaluecolor))
				header.button.title.SetTextColor = E.noop
				header.button.expandedIcon:SetTextColor(1, 1, 1)
				header.button.expandedIcon.SetTextColor = E.noop

				header.description:SetTextColor(1, 1, 1)
				header.description.SetTextColor = E.noop

				header.isSkinned = true
			end

			headerCount = headerCount + 1
			header = _G["EncounterJournalInfoHeader"..headerCount]
		end
	end)

	hooksecurefunc("EncounterJournal_SetBullets", function(object)
		local parent = object:GetParent()
		if parent.Bullets then
			for _, bullet in pairs(parent.Bullets) do
				if not bullet.isSkinned then
					bullet.Text:SetTextColor(1, 1, 1)
					bullet.isSkinned = true
				end
			end
		end
	end)
end

S:AddCallback("Sirus_EncounterJournal", LoadSkin)