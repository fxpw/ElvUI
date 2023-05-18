local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guild ~= true then return end

	-- Guild Frame
	S:HandlePortraitFrame(GuildFrame)

	GuildXPBar:StripTextures()
	GuildXPBar.progress:SetTexture(E.media.normTex)
	E:RegisterStatusBar(GuildXPBar.progress)
	GuildXPBar.cap:SetTexture(E.media.normTex)
	E:RegisterStatusBar(GuildXPBar.cap)
	GuildXPBarArt:StripTextures()
	GuildXPBar:CreateBackdrop()
	GuildXPBar.backdrop:SetOutside(GuildXPBarBG)

	for i = 1, 5 do
		local tab = _G["GuildFrameRightTab"..i]
		if i == 1 then
			tab:Point("TOPLEFT", GuildFrame, "TOPRIGHT", -E.Border, -36)
		end
		tab:GetRegions():Hide()
		tab:StyleButton()
		tab:SetTemplate("Default", true)

		tab.Icon:SetInside()
		tab.Icon:SetTexCoord(unpack(E.TexCoords))
	end

	-- top tab
	for i = 1, 3 do
		local tab = _G["GuildInfoFrameTab"..i]
		S:HandleTab(tab)
	end

	S:HandleButton(GuildRecruitmentInviteButton, true)
	S:HandleButton(GuildRecruitmentMessageButton, true)
	S:HandleButton(GuildRecruitmentDeclineButton, true)

	-- GuildPerks Frame
	GuildAllPerksFrame:StripTextures()
	S:HandleScrollBar(GuildPerksContainerScrollBar)

	for i = 1, #GuildPerksContainer.buttons do
		local button = GuildPerksContainer.buttons[i]
		button:StripTextures()

		button.icon:CreateBackdrop()
		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:SetParent(button.icon.backdrop)
	end

	-- GuildRewards Frame
	GuildRewardsFrame:StripTextures()
	S:HandleScrollBar(GuildRewardsContainerScrollBar)

	for i = 1, #GuildRewardsContainer.buttons do
		local button = GuildRewardsContainer.buttons[i]
		button:StripTextures()

		button.icon:CreateBackdrop()
		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:SetParent(button.icon.backdrop)
	end

	-- GuildRoster Frame
	S:HandleDropDownBox(GuildRosterViewDropdown)

	for i = 1, 5 do
		_G["GuildRosterColumnButton"..i]:StripTextures()
		_G["GuildRosterColumnButton"..i]:StyleButton()
	end

	S:HandleScrollBar(GuildRosterContainerScrollBar)

	S:HandleCheckBox(GuildRosterShowOfflineButton)

	-- GuildMemberDetail Frame
	GuildMemberDetailFrame:StripTextures()
	GuildMemberDetailFrame:SetTemplate("Transparent")

	S:HandleCloseButton(GuildMemberDetailCloseButton)

	S:HandleButton(GuildMemberRemoveButton)
	S:HandleButton(GuildMemberGroupInviteButton)

	GuildMemberRankDropdown:Point("LEFT", GuildMemberDetailRankLabel, "RIGHT", -18, -3)
	S:HandleDropDownBox(GuildMemberRankDropdown)

	GuildMemberNoteBackground:SetTemplate("Transparent")
	GuildMemberOfficerNoteBackground:SetTemplate("Transparent")

	-- GuildInfo Frame
	GuildInfoFrame:StripTextures()

	S:HandleScrollBar(GuildInfoFrameInfoMOTDScrollFrameScrollBar)

	GuildInfoFrameInfo:StripTextures()
	GuildInfoFrameInfo:SetTemplate("Transparent")

	S:HandleButton(GuildInfoEditMOTDButton)
	S:HandleButton(GuildInfoEditDetailsButton)
	S:HandleScrollBar(GuildInfoDetailsFrameScrollBar)
	S:HandleButton(GuildAddMemberButton, true)
	S:HandleButton(GuildControlButton, true)
	S:HandleButton(GuildViewLogButton, true)
	S:HandleButton(GuildRenameButton, true)

	-- GuildTextEditFrame
	GuildTextEditFrame:StripTextures()
	GuildTextEditFrame:SetTemplate("Transparent")
	S:HandleCloseButton(GuildTextEditFrameCloseButton)
	GuildTextEditContainer:StripTextures()
	GuildTextEditContainer:SetBackdrop(nil)

	S:HandleScrollBar(GuildTextEditScrollFrameScrollBar)

	S:HandleButton(GuildTextEditFrameAcceptButton)
	S:HandleButton(GuildTextEditFrameCloseButton)

	-- GuildLogFrame not work for now
	GuildLogFrame:StripTextures()
	GuildLogFrame:SetTemplate("Transparent")

	local CloseButton, _, CloseButton2 = GuildLogFrame:GetChildren()
	S:HandleCloseButton(CloseButton)
	GuildLogContainer:SetBackdrop(nil)

	S:HandleScrollBar(GuildLogScrollFrameScrollBar)

	S:HandleButton(CloseButton2)

	--controltab
	--frame
		GuildControlPopupFrame:StripTextures()
		GuildControlPopupFrame:SetTemplate("Transparent")
		GuildControlPopupFrameCheckboxes:StripTextures()


	-- ddb

		S:HandleDropDownBox(GuildControlPopupFrameDropDown,200)
		GuildControlPopupFrameDropDown:Height(30)
	--editbox

		S:HandleEditBox(GuildControlPopupFrameEditBox)
		GuildControlPopupFrameEditBox:Width(100)
		GuildControlPopupFrameEditBox:Height(25)
	--buttons
		S:HandleButton(GuildControlPopupAcceptButton)
		S:HandleButton(GuildControlPopupFrameCancelButton)

--			S:HandleButton(GuildControlPopupFrameAddRankButton,true)
		GuildControlPopupFrameAddRankButton:ClearAllPoints()
		GuildControlPopupFrameAddRankButton:Point("RIGHT", GuildControlPopupFrameDropDown,"RIGHT", 10, 5)
		GuildControlPopupFrameAddRankButton:GetNormalTexture():SetTexture(E.Media.Textures.Plus)


		--S:HandleButton(GuildControlPopupFrameRemoveRankButton,true)
		GuildControlPopupFrameRemoveRankButton:ClearAllPoints()
		GuildControlPopupFrameRemoveRankButton:Point("RIGHT", GuildControlPopupFrameAddRankButton,"RIGHT", 20, 0)
		GuildControlPopupFrameRemoveRankButton:GetNormalTexture():SetTexture(E.Media.Textures.Minus)

	--hook
		local function guildcontrol_OnShow(self)
			for i = 1,13 do
				S:HandleCheckBox(_G["GuildControlPopupFrameCheckbox"..i])
			end
		end
		local function for17_OnShow(self)
			for i = 15,17 do
				S:HandleCheckBox(_G["GuildControlPopupFrameCheckbox"..i])
			end
		end

		local gcontl = GuildControlPopupFrameCheckboxes
			gcontl:HookScript("OnShow", guildcontrol_OnShow)
		local gcontl2 = GuildControlPopupFrameCheckbox17
			gcontl2:HookScript("OnShow", for17_OnShow)

		local function ebWithdrawGold(self)
			S:HandleEditBox(GuildControlWithdrawGoldEditBox)
			GuildControlWithdrawGoldEditBox:Width(70)
			GuildControlWithdrawGoldEditBox:Height(20)
		end

		GuildControlWithdrawGold:HookScript("OnShow", ebWithdrawGold)

		local function tabandhand(self)
			for i = 1,6 do
				_G["GuildBankTabPermissionsTab"..i]:StripTextures()
				S:HandleTab(_G["GuildBankTabPermissionsTab"..i])
				_G["GuildBankTabPermissionsTab"..i]:Width(35)
				_G["GuildBankTabPermissionsTab"..i]:Height(25)
			end
			local xoff = -95
			for i = 1,6 do
				_G["GuildBankTabPermissionsTab"..i]:ClearAllPoints()
				_G["GuildBankTabPermissionsTab"..i]:Point("TOPRIGHT", xoff, 17)
				xoff = xoff + 21
			end
			S:HandleCheckBox(GuildControlTabPermissionsViewTab)
			S:HandleCheckBox(GuildControlTabPermissionsDepositItems)
			S:HandleCheckBox(GuildControlTabPermissionsUpdateText)
			GuildControlWithdrawItemsEditBox:StripTextures()
			S:HandleEditBox(GuildControlWithdrawItemsEditBox)
			GuildControlWithdrawItemsEditBox:Width(70)
			GuildControlWithdrawItemsEditBox:Height(20)
		end

		GuildControlPopupFrameTabPermissions:HookScript("OnShow", tabandhand)
		GuildControlPopupFrameTabPermissions:StripTextures()
--			GuildControlPopupFrameTabPermissions:SetTemplate("Transparent")

		local function handlelvl(self)
			GuildLevelFrame:StripTextures()
--				GuildLevelFrame:SetTemplate("Transparent")
			GuildLevelFrame:ClearAllPoints()
			GuildLevelFrame:Point("TOPLEFT", 20, -30)

		end
		GuildFrame:HookScript("OnShow", handlelvl)

		-- 2 tab nabor
		GuildRecruitmentInterestFrame:StripTextures()
		GuildRecruitmentInterestFrame:SetTemplate("Transparent")
		GuildRecruitmentAvailabilityFrame:StripTextures()
		GuildRecruitmentAvailabilityFrame:SetTemplate("Transparent")
		GuildRecruitmentRolesFrame:StripTextures()
		GuildRecruitmentRolesFrame:SetTemplate("Transparent")
		GuildRecruitmentLevelFrame:StripTextures()
		GuildRecruitmentLevelFrame:SetTemplate("Transparent")
		GuildRecruitmentCommentFrame:StripTextures()
		GuildRecruitmentCommentFrame:SetTemplate("Transparent")
		-- buttin 2 tab
		GuildRecruitmentListGuildButton:StripTextures()
		S:HandleButton(GuildRecruitmentListGuildButton)

		--checkbox
		S:HandleCheckBox(GuildRecruitmentQuestButton)
		S:HandleCheckBox(GuildRecruitmentPvPButton)
		S:HandleCheckBox(GuildRecruitmentDungeonButton)
		S:HandleCheckBox(GuildRecruitmentRPButton)
		S:HandleCheckBox(GuildRecruitmentRaidButton)
		-- S:HandleCheckBox(GuildRecruitmentWeekdaysButton)
		-- S:HandleCheckBox(GuildRecruitmentWeekendsButton)

		S:HandleCheckBox(GuildRecruitmentLevelAnyButton)
		S:HandleCheckBox(GuildRecruitmentLevelMaxButton)

		GuildRecruitmentCommentInputFrameScrollFrameFocusButton:StripTextures()
		GuildRecruitmentCommentInputFrameScrollFrame:StripTextures()
		GuildRecruitmentCommentInputFrame:StripTextures()



		--guild fraction
		GuildFactionFrame:ClearAllPoints()
		GuildFactionFrame:SetPoint("TOPLEFT",GuildFrame, "TOPLEFT", 0, 0)

		--look for guild
		LookingForGuildFrame:StripTextures();
		LookingForGuildFrame:CreateBackdrop("Transparent");
		S:HandleCloseButton(LookingForGuildFrameCloseButton);
		S:HandleButton(LookingForGuildFrameOptionsListSearch)
		S:HandleDropDownBox(LookingForGuildFrameOptionsListFilterDropdown)
		S:HandleDropDownBox(LookingForGuildFrameOptionsListSizeDropdown)
		S:HandleEditBox(LookingForGuildFrameOptionsListSearchBox)
		LookingForGuildFrameOptionsListSearch:ClearAllPoints()
		LookingForGuildFrameOptionsListSearch:SetPoint("BOTTOM", LookingForGuildFrameOptionsListSearchBox, "BOTTOM", -5, -25)

		LookingForGuildFrameOptionsListSearchBox:SetSize(145,20)
		LookingForGuildFrameInsetFrame:StripTextures()

		local chchbx = {
			"Tank",
			"Healer",
			"Dps"
		}
		for _,checkbox in ipairs(chchbx) do
			local frame = _G["LookingForGuildFrameOptionsList"..checkbox.."RoleFrameCheckBox"]
			if frame then
				S:HandleCheckBox(frame)
			end
		end
		for i = 1,15 do
			local btn = _G["GuildRosterContainerButton"..i]
			if btn then
				btn.CategoryIcon:SetTexCoord(unpack(E.TexCoords))

			end

		end
		local tabs ={
			"LookingForGuildFrameSearchTab",
			"LookingForGuildFramePendingTab"
		}
		for k,tabToSkin in ipairs(tabs) do
			local tab = _G[tabToSkin]
			if k == 1 then
				tab:Point("TOPLEFT", LookingForGuildFrame, "TOPRIGHT", -E.Border, -36)
			end
			tab:GetRegions():Hide()
			tab:StyleButton()
			tab:SetTemplate("Default", true)
			tab.Icon:SetInside()
			tab.Icon:SetTexCoord(unpack(E.TexCoords))
		end
		-- S:HandleTab(LookingForGuildFrameSearchTab)
		-- S:HandleTab(LookingForGuildFramePendingTab)
		S:HandleButton(LookingForGuildFrameGuildCardsFirstCardRequestJoin)
		S:HandleButton(LookingForGuildFrameGuildCardsSecondCardRequestJoin)
		S:HandleButton(LookingForGuildFrameGuildCardsThirdCardRequestJoin)

		LookingForGuildFrameRequestToJoinFrame:HookScript("OnShow",function()
			LookingForGuildFrameRequestToJoinFrame:StripTextures()
			LookingForGuildFrameRequestToJoinFrame:CreateBackdrop("Transparent")
			S:HandleButton(LookingForGuildFrameRequestToJoinFrameApply)
			S:HandleButton(LookingForGuildFrameRequestToJoinFrameCancel)
			LookingForGuildFrameRequestToJoinFrame.BG:Hide()
			LookingForGuildFrameRequestToJoinFrameMessageFrame:StripTextures()
			LookingForGuildFrameRequestToJoinFrameMessageFrameMessageScroll:StripTextures()
			LookingForGuildFrameRequestToJoinFrameMessageFrameMessageScroll:CreateBackdrop("Trasparent")
			S:HandleScrollBar(LookingForGuildFrameRequestToJoinFrameMessageFrameMessageScrollScrollBar)
		end)

	--guild frame move

	GuildFrame:EnableMouse(true)
	GuildFrame:SetMovable(true)
	GuildFrame:RegisterForDrag("LeftButton")
	GuildFrame:SetScript("OnDragStart", function(self)
		self:StartMoving()
		end)
	GuildFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local frame_x,frame_y = self:GetCenter()
		frame_x = frame_x - GetScreenWidth() / 2
		frame_y = frame_y - GetScreenHeight() / 2
		self:ClearAllPoints()
		self:SetPoint("CENTER", UIParent,"CENTER",frame_x,frame_y)
	end)
	-- LFRBrowseFrame:SetScript("OnShow", function(self)
	-- 	self:ClearAllPoints()
	-- 	self:SetPoint("TOPLEFT", 15, -114)
	-- end)

	-- Point 1: "TOPLEFT", 15, -114
end

S:AddCallback("Guild", LoadSkin)

