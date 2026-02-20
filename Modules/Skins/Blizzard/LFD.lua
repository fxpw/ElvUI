local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select, unpack = select, unpack
--WoW API / Variables
local GetItemInfo = C_Item.GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetLFGDungeonRewardLink = GetLFGDungeonRewardLink
local GetLFGDungeonRewards = GetLFGDungeonRewards
local hooksecurefunc = hooksecurefunc
local find = string.find


local function SkinMiniGameReward(frame)
	local icon = frame.Icon or _G[frame:GetName().."IconTexture"]
	if not icon then return end

	if not frame.isSkinned then
		if frame.NameFrame then
			frame.NameFrame:Kill()
		end

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:ClearAllPoints()
		icon:Point("TOPLEFT", 2, -2)
		icon:Size(frame:GetHeight() - 4)
		icon:SetDrawLayer("ARTWORK")

		frame:CreateBackdrop("Default")
		frame.backdrop:SetOutside(icon)
		icon:SetParent(frame.backdrop)

		frame.Icon = icon

		if frame.Name then
			frame.Name:ClearAllPoints()
			frame.Name:Point("LEFT", frame.backdrop, "RIGHT", 10, 0)
		end

		local count = frame.Count or _G[frame:GetName().."Count"]
		if count then
			count:SetParent(frame.backdrop)
			count:SetDrawLayer("OVERLAY")
			count:ClearAllPoints()
			count:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, 2)
			frame.Count = count
		end

		frame.isSkinned = true
	end
end

local function UpdateMiniGameRewards(self)
	self.BottomInset.Background:Kill()
	if self.TopInset.TopTileStreaks then self.TopInset.TopTileStreaks:Kill() end

	if self.lootPool then
		for frame in self.lootPool:EnumerateActive() do
			SkinMiniGameReward(frame)

			if frame.itemLink and frame.backdrop then
				local _, _, quality = GetItemInfo(frame.itemLink)
				if quality then
					frame.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					if frame.Name then
						frame.Name:SetTextColor(GetItemQualityColor(quality))
					end
				else
					frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					if frame.Name then
						frame.Name:SetTextColor(1, 1, 1)
					end
				end
			end
		end
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfd ~= true then return end

	S:HandlePortraitFrame(LFDParentFrame)
	S:HandleCloseButton(LFDParentFrameCloseButton)
	LFDParentFrame:SetTemplate("Transparent")
	LFDParentFrame.LeftInset:StripTextures()
	LFDParentFrame.Shadows:StripTextures()

	for i = 1, LFDParentFrame:GetNumChildren() do
		local child = select(i, LFDParentFrame:GetChildren())
		if child and child:GetName() and find(child:GetName(), "Art") then
			child:StripTextures()
		end
	end


	for i = 1, 4 do
		local tab = _G["LFDParentFrameTab" .. i]
		if tab then
			if tab.HighlightLeft then tab.HighlightLeft:StripTextures() end
			if tab.HighlightMiddle then tab.HighlightMiddle:StripTextures() end
			if tab.HighlightRight then tab.HighlightRight:StripTextures() end
			S:HandleTab(tab)
		end
	end
	local tabstorem = {
		"LFDParentFrameTab",
		"PVPUIFrameTab",
		"ChallengesFrameTab",
		"LadderFrameTab",
	}
	for _, tab in pairs(tabstorem) do
		tab = _G[tab .. 1]
		if tab then
			tab:ClearAllPoints()
			tab:SetPoint("BOTTOMLEFT", 2, -30)
		end
	end

	LFDParentFrameGroupButton1.ring:Kill()
	LFDParentFrameGroupButton1.bg:Kill()
	S:HandleButton(LFDParentFrameGroupButton1)
	LFDParentFrameGroupButton1.icon:Size(45)
	LFDParentFrameGroupButton1.icon:ClearAllPoints()
	LFDParentFrameGroupButton1.icon:Point("LEFT", 10, 0)
	LFDParentFrameGroupButton1.icon:SetTexCoord(unpack(E.TexCoords))
	LFDParentFrameGroupButton1.icon:CreateBackdrop()
	LFDParentFrameGroupButton1.icon:SetParent(LFDParentFrameGroupButton1.icon.backdrop)
	LFDParentFrameGroupButton1.icon.backdrop:SetFrameLevel(LFDParentFrameGroupButton1:GetFrameLevel() + 2)

	LFDParentFrameGroupButton2.ring:Kill()
	LFDParentFrameGroupButton2.bg:Kill()
	S:HandleButton(LFDParentFrameGroupButton2)
	LFDParentFrameGroupButton2.icon:Size(45)
	LFDParentFrameGroupButton2.icon:ClearAllPoints()
	LFDParentFrameGroupButton2.icon:Point("LEFT", 10, 0)
	LFDParentFrameGroupButton2.icon:SetTexCoord(unpack(E.TexCoords))
	LFDParentFrameGroupButton2.icon:CreateBackdrop()
	LFDParentFrameGroupButton2.icon:SetParent(LFDParentFrameGroupButton2.icon.backdrop)
	LFDParentFrameGroupButton2.icon.backdrop:SetFrameLevel(LFDParentFrameGroupButton2:GetFrameLevel() + 2)

	if LFDParentFrameGroupButton3 then
		LFDParentFrameGroupButton3.ring:Kill()
		LFDParentFrameGroupButton3.bg:Kill()
		S:HandleButton(LFDParentFrameGroupButton3)
		LFDParentFrameGroupButton3.icon:Size(45)
		LFDParentFrameGroupButton3.icon:ClearAllPoints()
		LFDParentFrameGroupButton3.icon:Point("LEFT", 10, 0)
		LFDParentFrameGroupButton3.icon:SetTexCoord(unpack(E.TexCoords))
		LFDParentFrameGroupButton3.icon:CreateBackdrop()
		LFDParentFrameGroupButton3.icon:SetParent(LFDParentFrameGroupButton3.icon.backdrop)
		LFDParentFrameGroupButton3.icon.backdrop:SetFrameLevel(LFDParentFrameGroupButton3:GetFrameLevel() + 2)
	end

	LFDQueueParentFrame:StripTextures()
	LFDQueueParentFrameInset:StripTextures()

	LFDQueueFrame:StripTextures(true)

	S:HandleCheckBox(LFDQueueFrameRoleButtonTank.checkButton)
	LFDQueueFrameRoleButtonTank.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonTank.checkButton:GetFrameLevel() + 2)
	S:HandleCheckBox(LFDQueueFrameRoleButtonHealer.checkButton)
	LFDQueueFrameRoleButtonHealer.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonHealer.checkButton:GetFrameLevel() + 2)
	S:HandleCheckBox(LFDQueueFrameRoleButtonDPS.checkButton)
	LFDQueueFrameRoleButtonDPS.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonDPS.checkButton:GetFrameLevel() + 2)
	S:HandleCheckBox(LFDQueueFrameRoleButtonLeader.checkButton)
	LFDQueueFrameRoleButtonLeader.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonLeader.checkButton:GetFrameLevel() + 2)

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown, 150)

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown)
	LFDQueueFrameTypeDropDown:ClearAllPoints()
	LFDQueueFrameTypeDropDown:Point("TOPLEFT", 110, -125)

	LFDQueueFrameRandomScrollFrame:StripTextures()
	S:HandleScrollBar(LFDQueueFrameRandomScrollFrameScrollBar)
	LFDQueueFrameRandomScrollFrameScrollBar:ClearAllPoints()
	LFDQueueFrameRandomScrollFrameScrollBar:SetPoint("TOPLEFT", LFDQueueFrameRandomScrollFrame, "TOPRIGHT", 5, -15)
	LFDQueueFrameRandomScrollFrameScrollBar:SetPoint("BOTTOMLEFT", LFDQueueFrameRandomScrollFrame, "BOTTOMRIGHT", 5, 0)

	local function SkinLFDRandomDungeonLoot(frame)
		if frame.isSkinned then return end

		local icon = _G[frame:GetName() .. "IconTexture"]
		local nameFrame = _G[frame:GetName() .. "NameFrame"]
		local count = _G[frame:GetName() .. "Count"]

		frame:StripTextures()
		frame:CreateBackdrop("Transparent")
		frame.backdrop:SetOutside(icon)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer("BORDER")
		icon:SetParent(frame.backdrop)

		nameFrame:SetSize(118, 39)

		count:SetParent(frame.backdrop)
		frame.isSkinned = true
	end

	local scan
	local function GetLFGDungeonRewardLinkFix(dungeonID, rewardIndex)
		local _, link = GetLFGDungeonRewardLink(dungeonID, rewardIndex)
		if not link then
			if not scan then
				scan = CreateFrame("GameTooltip", "DungeonRewardLinkScan", nil, "GameTooltipTemplate")
				scan:SetOwner(UIParent, "ANCHOR_NONE")
			end
			scan:ClearLines()
			scan:SetLFGDungeonReward(dungeonID, rewardIndex)
			_, link = scan:GetItem()
		end
		return link
	end

	hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", function()
		local dungeonID = LFDQueueFrame.type
		if not dungeonID then return end

		local _, _, _, _, _, numRewards = GetLFGDungeonRewards(dungeonID)
		for i = 1, numRewards do
			local frame = _G["LFDQueueFrameRandomScrollFrameChildFrameItem" .. i]
			local name = _G["LFDQueueFrameRandomScrollFrameChildFrameItem" .. i .. "Name"]
			SkinLFDRandomDungeonLoot(frame)

			local link = GetLFGDungeonRewardLinkFix(dungeonID, i)
			if link then
				local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
				if quality then
					_G["LFDQueueFrameRandomScrollFrameChildFrameItem" .. i .. "IconTexture"]:SetTexture(texture)
					frame.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					name:SetTextColor(GetItemQualityColor(quality))
				end
			else
				frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				name:SetTextColor(1, 1, 1)
			end
		end
	end)

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameSpecificListButton" .. i]
		button.enableButton:StripTextures()
		button.enableButton:CreateBackdrop("Default")
		button.enableButton.backdrop:SetInside(nil, 4, 4)

		button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.Plus)
		button.expandOrCollapseButton.SetNormalTexture = E.noop
		button.expandOrCollapseButton:GetNormalTexture():Size(16)

		button.expandOrCollapseButton:SetHighlightTexture(nil)

		hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
			end
		end)
	end

	LFDQueueFrameSpecificListScrollFrame:StripTextures()
	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)

	S:HandleButton(LFDQueueFrameFindGroupButton, true)

	hooksecurefunc("LFDQueueFrameRandomCooldownFrame_Update", function()
		if LFDQueueFrameCooldownFrame:IsShown() then
			LFDQueueFrameCooldownFrame:SetFrameLevel(LFDQueueFrameCooldownFrame:GetParent():GetFrameLevel() + 5)
		end
	end)

	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton)

	S:HandleButton(LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)

	-- ElvUI
	LFDDungeonReadyStatus:SetTemplate("Transparent")

	S:HandleCloseButton(LFDDungeonReadyStatusCloseButton, nil, "-")

	LFDDungeonReadyDialog:SetTemplate("Transparent")

	LFDDungeonReadyDialog.label:Size(280, 0)
	LFDDungeonReadyDialog.label:Point("TOP", 0, -10)

	LFDDungeonReadyDialog:CreateBackdrop("Default")
	LFDDungeonReadyDialog.backdrop:Point("TOPLEFT", 10, -35)
	LFDDungeonReadyDialog.backdrop:Point("BOTTOMRIGHT", -10, 40)

	LFDDungeonReadyDialog.backdrop:SetFrameLevel(LFDDungeonReadyDialog:GetFrameLevel())
	LFDDungeonReadyDialog.background:SetInside(LFDDungeonReadyDialog.backdrop)

	LFDDungeonReadyDialogFiligree:SetTexture("")
	LFDDungeonReadyDialogBottomArt:SetTexture("")

	S:HandleCloseButton(LFDDungeonReadyDialogCloseButton, nil, "-")

	LFDDungeonReadyDialogEnterDungeonButton:Point("BOTTOMRIGHT", LFDDungeonReadyDialog, "BOTTOM", -7, 10)
	S:HandleButton(LFDDungeonReadyDialogEnterDungeonButton)
	LFDDungeonReadyDialogLeaveQueueButton:Point("BOTTOMLEFT", LFDDungeonReadyDialog, "BOTTOM", 7, 10)
	S:HandleButton(LFDDungeonReadyDialogLeaveQueueButton)

	local function SkinLFDDungeonReadyDialogReward(button)
		if button.isSkinned or not button.texture then return end

		button:Size(28)
		button:SetTemplate("Default")
		button.texture:SetInside()
		button.texture:SetTexCoord(unpack(E.TexCoords))
		button:DisableDrawLayer("OVERLAY")
		button.isSkinned = true
	end

	hooksecurefunc("LFDDungeonReadyDialogReward_SetMisc", function(button)
		SkinLFDDungeonReadyDialogReward(button)

		SetPortraitToTexture(button.texture, "")
		button.texture:SetTexture("Interface\\Icons\\inv_misc_coin_02")
	end)

	hooksecurefunc("LFDDungeonReadyDialogReward_SetReward", function(button, dungeonID, rewardIndex)
		if button and not button.texture then return end

		SkinLFDDungeonReadyDialogReward(button)

		local link = GetLFGDungeonRewardLinkFix(dungeonID, rewardIndex)
		if link then
			local _, _, quality = GetItemInfo(link)
			button:SetBackdropBorderColor(GetItemQualityColor(quality))
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end

		local texturePath = button.texture:GetTexture()
		if texturePath then
			SetPortraitToTexture(button.texture, "")
			button.texture:SetTexture(texturePath)
		end
	end)

	LFDRoleCheckPopup:SetTemplate("Transparent")

	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonTank.checkButton)
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonHealer.checkButton)
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonDPS.checkButton)

	S:HandleButton(LFDRoleCheckPopupAcceptButton)
	S:HandleButton(LFDRoleCheckPopupDeclineButton)

	LFDSearchStatus:SetTemplate("Transparent")
	-- End ElvUI

	S:HandlePortraitFrame(PVPUIFrame)
	if PVPUIFrame.CloseButton or PVPUIFrameCloseButton then
		S:HandleCloseButton(PVPUIFrame.CloseButton or PVPUIFrameCloseButton)
	end
	PVPUIFrame:SetTemplate("Transparent")
	PVPUIFrame.LeftInset:StripTextures()
	PVPUIFrame.Shadows:StripTextures()
	S:HandleCheckBox(PVPHonorFrameBottomInsetBonusBattlegroundRadioButton)
	S:HandleCheckBox(PVPHonorFrameBottomInsetSpecificBattlegroundRadioButton)


	for i = 1, PVPUIFrame:GetNumChildren() do
		local child = select(i, PVPUIFrame:GetChildren())
		if child and child:GetName() and find(child:GetName(), "Art") then
			child:StripTextures()
		end
	end

	for i = 1, 4 do
		local tab = _G["PVPUIFrameTab" .. i]
		if (tab) then
			if tab.HighlightLeft then tab.HighlightLeft:StripTextures() end
			if tab.HighlightMiddle then tab.HighlightMiddle:StripTextures() end
			if tab.HighlightRight then tab.HighlightRight:StripTextures() end
			S:HandleTab(tab)
		end
	end

	for i = 1, 3 do
		local b = PVPQueueFrame["CategoryButton" .. i]
		b.Ring:Kill()
		b.Background:Kill()
		S:HandleButton(b)
		b.Icon:Size(45)
		b.Icon:ClearAllPoints()
		b.Icon:Point("LEFT", 10, 0)
		b.Icon:SetTexCoord(unpack(E.TexCoords))
		b.Icon:CreateBackdrop()
		b.Icon:SetParent(b.Icon.backdrop)
		b.Icon.backdrop:SetFrameLevel(b:GetFrameLevel() + 2)
	end

	PVPQueueFrameBattlePassToggleButton.Ring:Kill()
	PVPQueueFrameBattlePassToggleButton.Background:Kill()
	S:HandleButton(PVPQueueFrameBattlePassToggleButton)
	PVPQueueFrameBattlePassToggleButton.Icon:Size(45)
	PVPQueueFrameBattlePassToggleButton.Icon:ClearAllPoints()
	PVPQueueFrameBattlePassToggleButton.Icon:Point("LEFT", 10, 0)
	PVPQueueFrameBattlePassToggleButton.Icon:SetTexCoord(0.15, .85, .15, .85)
	PVPQueueFrameBattlePassToggleButton.Icon:CreateBackdrop()
	PVPQueueFrameBattlePassToggleButton.Icon:SetParent(PVPQueueFrameBattlePassToggleButton.Icon.backdrop)
	PVPQueueFrameBattlePassToggleButton.Name:SetParent(PVPQueueFrameBattlePassToggleButton.Icon.backdrop)
	PVPQueueFrameBattlePassToggleButton.Icon.backdrop:SetFrameLevel(PVPQueueFrameBattlePassToggleButton:GetFrameLevel() +
	2)
	PVPQueueFrameBattlePassToggleButton.LevelFrame:SetFrameLevel(PVPQueueFrameBattlePassToggleButton:GetFrameLevel() + 3)

	PVPQueueFrame.CapTopFrame:StripTextures()

	PVPQueueFrame.CapTopFrame.StatusBar:CreateBackdrop()
	PVPQueueFrame.CapTopFrame.StatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(PVPQueueFrame.CapTopFrame.StatusBar)
	PVPQueueFrame.CapTopFrame.StatusBar.Left:Kill()
	PVPQueueFrame.CapTopFrame.StatusBar.Right:Kill()
	PVPQueueFrame.CapTopFrame.StatusBar.Middle:Kill()
	PVPQueueFrame.CapTopFrame.StatusBar.Background:Kill()

	hooksecurefunc(PVPQueueFrame.CapTopFrame.StatusBar, "SetBarValue", function(self, value)
		if value then
			local _, maxValue = self:GetMinMaxValues()
			S:StatusBarColorGradient(self, value, maxValue)
		end
	end)

	PVPQueueFrame.StepBottomFrame:StripTextures()
	PVPQueueFrame.StepBottomFrame:CreateBackdrop()
	PVPQueueFrame.StepBottomFrame.backdrop:SetInside(PVPQueueFrame.StepBottomFrame.ShadowOverlay)

	PVPQueueFrame.StepBottomFrame.ShadowOverlay:StripTextures()

	ConquestFrame.BottomInset:StripTextures()

	S:HandleDropDownBox(ConquestFrameBottomInsetTypeDropDown)
	ConquestFrame.BottomInset.ShadowOverlay:StripTextures()

	local function StyleButton(button, icon)
		button:StripTextures()
		button:SetTemplate("Default", true)
		button:StyleButton()

		button:GetHighlightTexture():SetTexture(1, 1, 1, 0.1)
		button:GetHighlightTexture():SetInside()

		button.SelectedTexture:SetAlpha(0)

		hooksecurefunc(button.SelectedTexture, "Show", function()
			button:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		end)
		hooksecurefunc(button.SelectedTexture, "Hide", function()
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)

		if icon then
			button.Icon:ClearAllPoints()
			button.Icon:Point("LEFT", 10, 0)
			button.Icon:SetTexCoord(unpack(E.TexCoords))
			button.Icon:CreateBackdrop()
			button.Icon:SetParent(button.Icon.backdrop)
			button.Icon.backdrop:SetFrameLevel(button:GetFrameLevel() + 2)
		end
	end

	local function StyleRewardFrame(frame)
		frame.CurrencyReward:StripTextures()
		frame.CurrencyReward:SetTemplate()
		frame.LootReward.Background:SetAlpha(0)
	end

	ConquestFrame.BottomInset.ArenaContainer:StripTextures()
	ConquestFrame.BottomInset.ArenaContainer.Header:StripTextures()
	StyleRewardFrame(ConquestFrame.BottomInset.ArenaContainer.Header.RewardFrame)

	StyleButton(ConquestFrame.BottomInset.ArenaContainer.Arena2v2)
	ConquestFrame.BottomInset.ArenaContainer.Arena2v2:Point("TOP", ConquestFrame.BottomInset.ArenaContainer.Header,
		"BOTTOM", 0, 10)
	StyleButton(ConquestFrame.BottomInset.ArenaContainer.Arena1v1)
	ConquestFrame.BottomInset.ArenaContainer.Arena1v1:Point("TOP", ConquestFrame.BottomInset.ArenaContainer.Arena2v2,
		"BOTTOM", 0, -(E.Border * 2))

	ConquestFrame.BottomInset.SoloArenaContainer:StripTextures()
	ConquestFrame.BottomInset.SoloArenaContainer.Header:StripTextures()
	StyleRewardFrame(ConquestFrame.BottomInset.SoloArenaContainer.Header.RewardFrame)

	StyleButton(ConquestFrame.BottomInset.SoloArenaContainer.ArenaSolo)

	ConquestFrame.BottomInset.ArenaSkirmishContainer:StripTextures()
	ConquestFrame.BottomInset.ArenaSkirmishContainer.Header:StripTextures()
	StyleRewardFrame(ConquestFrame.BottomInset.ArenaSkirmishContainer.Header.RewardFrame)

	StyleButton(ConquestFrame.BottomInset.ArenaSkirmishContainer.ArenaSkirmish2v2)
	StyleButton(ConquestFrame.BottomInset.ArenaSkirmishContainer.ArenaSkirmish1v1)

	S:HandleButton(ConquestFrame.JoinButton, true)

	S:HandleButton(PVPHonorFrame.SoloQueueButton, true)
	S:HandleButton(PVPHonorFrame.GroupQueueButton, true)

	PVPHonorFrame.BottomInset:StripTextures()

	S:HandleDropDownBox(PVPHonorFrameBottomInsetTypeDropDown)

	PVPHonorFrame.BottomInset.BonusBattlefieldContainer:StripTextures()
	PVPHonorFrame.BottomInset.BonusBattlefieldContainer.Header:StripTextures()
	StyleRewardFrame(PVPHonorFrame.BottomInset.BonusBattlefieldContainer.Header.RewardFrame)

	StyleButton(PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton)
	PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton:Point("TOP",
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.Header, "BOTTOM", 0, 10)
	StyleButton(PVPHonorFrame.BottomInset.BonusBattlefieldContainer.CallToArmsButton)
	PVPHonorFrame.BottomInset.BonusBattlefieldContainer.CallToArmsButton:Point("TOP",
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton, "BOTTOM", 0, -(E.Border * 2))

	PVPHonorFrame.BottomInset.WorldPVPContainer:StripTextures()
	PVPHonorFrame.BottomInset.WorldPVPContainer.Header:StripTextures()
	StyleRewardFrame(PVPHonorFrame.BottomInset.WorldPVPContainer.Header.RewardFrame)

	StyleButton(PVPHonorFrame.BottomInset.WorldPVPContainer.WorldPVP2Button)

	PVPHonorFrameSpecificFrame:StripTextures()
	S:HandleScrollBar(PVPHonorFrameSpecificFrameScrollBar)

	for i = 1, #PVPHonorFrameSpecificFrame.buttons do
		local button = PVPHonorFrameSpecificFrame.buttons[i]
		button:Width(309)
		if i == 1 then
			button:SetPoint("TOPLEFT", PVPHonorFrameSpecificFrame.scrollChild, "TOPLEFT", E.Border, -E.Border)
		else
			button:SetPoint("TOPLEFT", PVPHonorFrameSpecificFrame.buttons[i - 1], "BOTTOMLEFT", 0, -E.Border)
		end

		StyleButton(button, true)
	end

	PVPHonorFrameSpecificFrame.buttonHeight = PVPHonorFrameSpecificFrame.buttonHeight - 4
	PVPHonorFrameSpecificFrame.scrollChild:SetHeight(#PVPHonorFrameSpecificFrame.buttons *
	PVPHonorFrameSpecificFrame.buttonHeight)
	PVPHonorFrameSpecificFrame.scrollBar:SetMinMaxValues(0,
		#PVPHonorFrameSpecificFrame.buttons * PVPHonorFrameSpecificFrame.buttonHeight)

	PVPHonorFrame.BottomInset.ShadowOverlay:StripTextures()

	RatedBattlegroundFrameInset:StripTextures()
	RatedBattlegroundFrame.Container:StripTextures()

	RatedBattlegroundProgressBarFrame:CreateBackdrop()
	RatedBattlegroundProgressBarFrame.Progress:SetTexture(E.media.normTex)
	E:RegisterStatusBar(RatedBattlegroundProgressBarFrame.Progress)
	RatedBattlegroundProgressBarFrame.backdrop:Point("TOPLEFT", RatedBattlegroundProgressBarFrame.Progress, -1, 1)
	RatedBattlegroundProgressBarFrame.backdrop:Point("BOTTOMRIGHT", RatedBattlegroundProgressBarFrame.Background, -21, 0)
	RatedBattlegroundProgressBarFrame.Frame:Kill()
	RatedBattlegroundProgressBarFrame.Level:SetPoint("CENTER", 0, 1)
	RatedBattlegroundProgressBarFrame.Background:Kill()

	hooksecurefunc("RateBattleground_SetProgress", function(bar, value)
		if value then
			local r, g, b = E:ColorGradient(value * 100, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)
			bar.backdrop:SetBackdropColor(r * 0.25, g * 0.25, b * 0.25)
			bar.Progress:SetVertexColor(r, g, b)
		end
	end)

	PVPUIHonorLabel:StripTextures()

	RatedBattlegroundStatisticsScrollFrame:StripTextures()
	S:HandleScrollBar(RatedBattlegroundStatisticsScrollFrameScrollBar)

	RatedBattlegroundStatisticsScrollFrame:HookScript("OnShow", function()
		for i = 1, #RatedBattlegroundStatisticsScrollFrame.buttons do
			local button = RatedBattlegroundStatisticsScrollFrame.buttons[i]
			if not button.isSkinned then
				button:SetTemplate("Transparent")

				button.Background:SetDrawLayer("BORDER")
				button.Background:SetInside()
				button.Background:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 1, 1, 1, 1)

				S:HandleButton(button.TogglePlus)
				button.TogglePlus:SetNormalTexture(E.Media.Textures.Plus)
				button.TogglePlus:SetPushedTexture(E.Media.Textures.Plus)
				button.TogglePlus:SetHighlightTexture("")
				S:HandleButton(button.ToggleMinus)
				button.ToggleMinus:SetNormalTexture(E.Media.Textures.Minus)
				button.ToggleMinus:SetPushedTexture(E.Media.Textures.Minus)
				button.ToggleMinus:SetHighlightTexture("")

				button.isSkinned = true
			end
		end
	end)

	S:HandleButton(RatedBattlegroundFrame.SoloQueueButton, true)
	S:HandleButton(RatedBattlegroundFrame.GroupQueueButton, true)
	S:HandleButton(RatedBattlegroundFrame.StatisticsButton, true)

	ConquestTooltip:SetTemplate("Transparent")

	PVPUI_ArenaTeamDetails:StripTextures()
	PVPUI_ArenaTeamDetails:SetTemplate("Transparent")
	PVPUI_ArenaTeamDetailsHbar:StripTextures()

	S:HandleTab(PVPUI_ArenaTeamDetailsTab1)
	S:HandleTab(PVPUI_ArenaTeamDetailsTab2)

	S:HandleCloseButton(PVPUI_ArenaTeamDetailsCloseButton)
	S:HandleDropDownBox(PVPDropDown)

	for i = 1, 5 do
		_G["PVPUI_ArenaTeamDetailsColumnHeader" .. i]:StripTextures()
	end
	for i = 1, 10 do
		_G["PVPUI_ArenaTeamDetailsButton" .. i]:StripTextures()
	end

	S:HandleButton(PVPUI_ArenaTeamDetailsAddTeamMember)

	S:HandlePortraitFrame(LadderFrame)
	if LadderFrame.CloseButton or LadderFrameCloseButton then
		S:HandleCloseButton(LadderFrame.CloseButton or LadderFrameCloseButton)
	end
	LadderFrame:SetTemplate("Transparent")
	if LadderFrame.Inset then LadderFrame.Inset:StripTextures() end

	for i = 1, LadderFrame:GetNumChildren() do
		local child = select(i, LadderFrame:GetChildren())
		if child and child:GetName() and find(child:GetName(), "Art") then
			child:StripTextures()
		end
	end

	for i = 1, 4 do
		local tab = _G["LadderFrameTab" .. i]
		if tab then
			if tab.HighlightLeft then tab.HighlightLeft:StripTextures() end
			if tab.HighlightMiddle then tab.HighlightMiddle:StripTextures() end
			if tab.HighlightRight then tab.HighlightRight:StripTextures() end
			S:HandleTab(tab)
		end
	end

	-- Skin LadderFrame card buttons
	if LadderFrame.CardButtons then
		local function SkinLadderCardButtons()
			for i = 1, LadderFrame.CardButtons:GetNumChildren() do
				local child = select(i, LadderFrame.CardButtons:GetChildren())
				if child and not child.isSkinned then
					if child.Shadow then child.Shadow:Kill() end
					S:HandleButton(child)
					if child.Artwork then
						child.Artwork:SetInside()
						child.Artwork:SetDrawLayer("ARTWORK")
						child.Artwork:Show()
					end
					child.isSkinned = true
				end
			end
		end
		LadderFrame.CardButtons:HookScript("OnShow", SkinLadderCardButtons)
		LadderFrame:HookScript("OnShow", SkinLadderCardButtons)
	end

	S:HandleCheckBox(ConquestFrameBottomInsetRatedConquestRadioButton)
	S:HandleCheckBox(ConquestFrameBottomInsetSkirmishConquestRadioButton)

	local c = .035
	local tc = {
		{ .253906 + c, 0.503906 - c, 0.507813 + c, 0.757813 - c },
		{ c,           0.25 - c,     c,            0.25 - c },
		{ c,           0.250000 - c, 0.253906 + c, 0.503906 - c },
		{ .507813 + c, 0.757813 - c, c,            0.25 - c },
	}

	local function SkinCategoryButton(b, i)
		if not b then return end
		if b.Ring then b.Ring:SetAlpha(0) end
		if b.Background then b.Background:SetAlpha(0) end
		S:HandleButton(b)
		b.Icon:Size(45)
		b.Icon:ClearAllPoints()
		b.Icon:Point("LEFT", 10, 0)
		local texture = b.Icon:GetTexture()
		SetPortraitToTexture(b.Icon, "")
		b.Icon:SetTexture(texture)
		if tc[i] then
			b.Icon:SetTexCoord(unpack(tc[i]))
		end
		b.Icon:CreateBackdrop()
		b.Icon:SetParent(b.Icon.backdrop)
		b.Icon.backdrop:SetFrameLevel(b:GetFrameLevel() + 2)
		if b.Name then b.Name:FontTemplate(nil, 16) end
	end

	local function SkinLadderSubPanel(frame)
		if not frame then return end

		if frame.LeftInset then
			frame.LeftInset:StripTextures()

			local leftArtName = frame:GetName() and (frame:GetName() .. "LeftArt")
			local leftArt = leftArtName and _G[leftArtName]
			if leftArt then leftArt:StripTextures() end

			if frame.LeftInset.BackButton then
				frame.LeftInset.BackButton:StripTextures()
				S:HandleButton(frame.LeftInset.BackButton)
			end
		end
		if frame.Shadows then frame.Shadows:StripTextures() end

		if frame.Container then
			if frame.Container.RightBigTab1 then
				for i = 1, 2 do
					local tab = frame.Container["RightBigTab" .. i]
					if tab then
						tab:SetTemplate()
						tab:StyleButton()
						tab:GetRegions():Hide()
						tab.Icon:SetTexCoord(unpack(E.TexCoords))
						tab.Icon:SetInside()
					end
				end
				frame.Container.RightBigTab1:Point("TOPLEFT", frame.Container, "TOPRIGHT", -E.Border, -34)
			end

			if frame.Container.RightSmallTab1 then
				for i = 1, 10 do
					local tab = frame.Container["RightSmallTab" .. i]
					if tab then
						tab:SetTemplate()
						tab:StyleButton()
						tab:GetRegions():Hide()
						tab.Icon:SetTexCoord(unpack(E.TexCoords))
						tab.Icon:SetInside()
					end
				end
				frame.Container.RightSmallTab1:Point("TOPLEFT", frame.Container, "TOPRIGHT", -E.Border, -130)
			end

			if frame.Container.RightContainer then
				if frame.Container.RightContainer.BottomContainer then
					frame.Container.RightContainer.BottomContainer:StripTextures()
				end
				if frame.Container.RightContainer.CentralContainer then
					frame.Container.RightContainer.CentralContainer:StripTextures(true)
					if frame.Container.RightContainer.CentralContainer.ScrollFrame then
						if frame.Container.RightContainer.CentralContainer.ScrollFrame.ShadowOverlay then
							frame.Container.RightContainer.CentralContainer.ScrollFrame.ShadowOverlay:StripTextures()
						end
						local scrollBarName = frame:GetName() and (frame:GetName() .. "ContainerRightContainerCentralContainerScrollFrameScrollBar")
						if scrollBarName and _G[scrollBarName] then
							S:HandleScrollBar(_G[scrollBarName])
						end
						local scrollUpName = scrollBarName and (scrollBarName .. "ScrollUpButton")
						if scrollUpName and _G[scrollUpName] then
							S:SetNextPrevButtonDirection(_G[scrollUpName], "up")
						end
						local scrollDownName = scrollBarName and (scrollBarName .. "ScrollDownButton")
						if scrollDownName and _G[scrollDownName] then
							S:SetNextPrevButtonDirection(_G[scrollDownName], "down")
						end
					end
				end
				if frame.Container.RightContainer.TopContainer then
					frame.Container.RightContainer.TopContainer:StripTextures()
					if frame.Container.RightContainer.TopContainer.RegionMask and frame.Container.RightContainer.TopContainer.RegionMask.TextureMask then
						frame.Container.RightContainer.TopContainer.RegionMask.TextureMask:StripTextures()
					end
					if frame.Container.RightContainer.TopContainer.SearchBox then
						S:HandleEditBox(frame.Container.RightContainer.TopContainer.SearchBox)
					end
					if frame.Container.RightContainer.TopContainer.SearchButton then
						S:HandleButton(frame.Container.RightContainer.TopContainer.SearchButton)
					end
					if frame.Container.RightContainer.TopContainer.SearchFrame then
						if frame.Container.RightContainer.TopContainer.SearchFrame.SearchBox then
							S:HandleEditBox(frame.Container.RightContainer.TopContainer.SearchFrame.SearchBox)
						end
						if frame.Container.RightContainer.TopContainer.SearchFrame.SearchButton then
							S:HandleButton(frame.Container.RightContainer.TopContainer.SearchFrame.SearchButton)
						end
					end
					if frame.Container.RightContainer.TopContainer.FilterDropDown then
						S:HandleDropDownBox(frame.Container.RightContainer.TopContainer.FilterDropDown)
					end
					if frame.Container.RightContainer.TopContainer.TitleFrame then
						frame.Container.RightContainer.TopContainer.TitleFrame:StripTextures()
					end
					if frame.Container.RightContainer.TopContainer.ShadowOverlay then
						frame.Container.RightContainer.TopContainer.ShadowOverlay:StripTextures()
					end
				end
			end
		end

		if frame.categoryButtons then
			for i = 1, #frame.categoryButtons do
				SkinCategoryButton(frame.categoryButtons[i], i)
			end
		end

		if frame.kingFrames then
			for i = 1, #frame.kingFrames do
				local kf = frame.kingFrames[i]
				if kf then
					if kf.Background then kf.Background:SetAlpha(0) end
					if kf.Crown then kf.Crown:Point("LEFT", 6, 0) end
					S:HandleButton(kf)
				end
			end
		end
	end

	if PVPLadderFrame then
		SkinLadderSubPanel(PVPLadderFrame)

		PVPLadderFrame:HookScript("OnShow", function(self)
			if self.Container and self.Container.RightContainer and self.Container.RightContainer.CentralContainer then
				local scrollFrame = self.Container.RightContainer.CentralContainer.ScrollFrame
				if scrollFrame and scrollFrame.buttons and scrollFrame.buttons[1] and scrollFrame.ScrollChild then
					local childFrameLevel = scrollFrame.ScrollChild:GetFrameLevel()
					if scrollFrame.buttons[1]:GetFrameLevel() < childFrameLevel then
						for i = 1, #scrollFrame.buttons do
							scrollFrame.buttons[i]:SetFrameLevel(childFrameLevel + 1)
						end
					end
				end
			end
		end)
	end

	if PVPLadderInfoFrame then
		S:HandlePortraitFrame(PVPLadderInfoFrame)
		if PVPLadderInfoFrame.CentralContainer then
			PVPLadderInfoFrame.CentralContainer:StripTextures()
			if PVPLadderInfoFrame.CentralContainer.ScrollFrame then
				if PVPLadderInfoFrame.CentralContainer.ScrollFrame.ScrollBar then
					S:HandleScrollBar(PVPLadderInfoFrame.CentralContainer.ScrollFrame.ScrollBar)
				end
				if PVPLadderInfoFrame.CentralContainer.ScrollFrame.ShadowOverlay then
					PVPLadderInfoFrame.CentralContainer.ScrollFrame.ShadowOverlay:StripTextures()
				end
			end
		end
		if PVPLadderInfoFrame.TopContainer then
			if PVPLadderInfoFrame.TopContainer.ShadowOverlay then
				PVPLadderInfoFrame.TopContainer.ShadowOverlay:StripTextures()
			end
			if PVPLadderInfoFrame.TopContainer.StatisticsFrame then
				PVPLadderInfoFrame.TopContainer.StatisticsFrame:StripTextures()
			end
		end
	end

	if RenegadeLadderFrame then
		SkinLadderSubPanel(RenegadeLadderFrame)
	end

	if LadderDummyFrame then
		SkinLadderSubPanel(LadderDummyFrame)
	end

	if LadderMythicPlusFrame then
		SkinLadderSubPanel(LadderMythicPlusFrame)
	end

	if ChallengesFrame then
		S:HandlePortraitFrame(ChallengesFrame)
		if ChallengesFrame.CloseButton or ChallengesFrameCloseButton then
			S:HandleCloseButton(ChallengesFrame.CloseButton or ChallengesFrameCloseButton)
		end
		ChallengesFrame:SetTemplate("Transparent")

		for i = 1, ChallengesFrame:GetNumChildren() do
			local child = select(i, ChallengesFrame:GetChildren())
			if child and child:GetName() and find(child:GetName(), "Art") then
				child:StripTextures()
			end
		end

		for i = 1, 4 do
			local tab = _G["ChallengesFrameTab" .. i]
			if tab then
				if tab.HighlightLeft then tab.HighlightLeft:StripTextures() end
				if tab.HighlightMiddle then tab.HighlightMiddle:StripTextures() end
				if tab.HighlightRight then tab.HighlightRight:StripTextures() end
				S:HandleTab(tab)
			end
		end

		local function SkinAffixFrame(frame)
			if not frame or frame.isSkinned then return end

			if frame.Border then
				frame.Border:Kill()
			end

			if frame.Portrait then
				frame.Portrait:SetTexCoord(unpack(E.TexCoords))
				frame.Portrait:SetInside(frame, 2, 2)
			end

			frame:CreateBackdrop("Default")
			if frame.Portrait then
				frame.Portrait:SetParent(frame.backdrop)
			end

			if frame.Percent then
				frame.Percent:SetParent(frame.backdrop)
				frame.Percent:SetDrawLayer("OVERLAY")
			end

			frame.isSkinned = true
		end

		hooksecurefunc(ChallengesKeystoneFrameAffixMixin, "SetUp", function(self)
			SkinAffixFrame(self)
		end)

		if ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child then
			local chest = ChallengesFrame.WeeklyInfo.Child.WeeklyChest
			if chest then
				if chest.RunStatus then
					chest.RunStatus:FontTemplate(nil, 13)
				end
			end
		end
	end

	if ChallengesKeystoneFrame then
		ChallengesKeystoneFrame:StripTextures()
		ChallengesKeystoneFrame:SetTemplate("Transparent")

		if ChallengesKeystoneFrame.CloseButton then
			S:HandleCloseButton(ChallengesKeystoneFrame.CloseButton)
		end
		if ChallengesKeystoneFrame.StartButton then
			S:HandleButton(ChallengesKeystoneFrame.StartButton)
		end

		if ChallengesKeystoneFrame.InstructionBackground then
			ChallengesKeystoneFrame.InstructionBackground:SetAlpha(0)
		end

		local keystoneDecor = {
			"RuneBG", "SlotBG", "BgBurst2", "PentagonLines",
			"LargeCircleGlow", "SmallCircleGlow",
			"RunesLarge", "GlowBurstLarge", "RunesSmall", "GlowBurstSmall",
			"RuneCircleT", "RuneCircleR", "RuneCircleBR", "RuneCircleBL", "RuneCircleL",
			"RuneT", "RuneR", "RuneBR", "RuneBL", "RuneL",
			"LargeRuneGlow", "SmallRuneGlow", "KeystoneSlotGlow",
		}
		for _, key in ipairs(keystoneDecor) do
			if ChallengesKeystoneFrame[key] then
				ChallengesKeystoneFrame[key]:SetAlpha(0)
			end
		end

		if ChallengesKeystoneFrame.KeystoneFrame then
			ChallengesKeystoneFrame.KeystoneFrame:SetAlpha(0)
		end

		if ChallengesKeystoneFrame.KeystoneSlot then
			local slot = ChallengesKeystoneFrame.KeystoneSlot
			slot:CreateBackdrop("Default")
			slot:Size(52, 52)
			if slot.Texture then
				slot.Texture:SetTexCoord(unpack(E.TexCoords))
				slot.Texture:SetInside(slot.backdrop)
				slot.Texture:SetParent(slot.backdrop)
			end
		end
	end

	if ChallengesInspectFrame then
		S:HandlePortraitFrame(ChallengesInspectFrame)
		if ChallengesInspectFrame.CloseButton or ChallengesInspectFrameCloseButton then
			S:HandleCloseButton(ChallengesInspectFrame.CloseButton or ChallengesInspectFrameCloseButton)
		end
		ChallengesInspectFrame:SetTemplate("Transparent")

		ChallengesInspectFrame:SetMovable(true)
		ChallengesInspectFrame:RegisterForDrag("LeftButton")
		ChallengesInspectFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
		ChallengesInspectFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

		for i = 1, ChallengesInspectFrame:GetNumChildren() do
			local child = select(i, ChallengesInspectFrame:GetChildren())
			if child and child:GetName() and find(child:GetName(), "Art") then
				child:StripTextures()
			end
		end

		if ChallengesInspectFrame.PlayerInfo and ChallengesInspectFrame.PlayerInfo.Child then
			local child = ChallengesInspectFrame.PlayerInfo.Child
			local runeKeys = {"RuneBG", "RunesLarge", "RunesSmall", "LargeRuneGlow", "SmallRuneGlow"}
			for _, key in ipairs(runeKeys) do
				if child[key] then
					child[key]:SetAlpha(0)
				end
			end
		end

		local function SkinInspectDungeonIcon(self)
			if self.isSkinned then return end

			if self.Border then
				self.Border:Kill()
			end

			if self.Icon then
				self.Icon:SetTexCoord(unpack(E.TexCoords))
				self.Icon:SetInside(self, 2, 2)
			end

			self:CreateBackdrop("Default")
			if self.Icon then
				self.Icon:SetParent(self.Content or self)
				self.Icon:SetDrawLayer("BACKGROUND", 1)
			end

			if self.Shadow then
				self.Shadow:Kill()
			end

			if self.Content and self.Content.Level then
				self.Content.Level:FontTemplate(nil, 24, "OUTLINE")
			end

			self.isSkinned = true
		end

		local function SkinInspectMemberIcon(self)
			if self.isSkinned then return end

			if self.Border then
				self.Border:Kill()
			end

			if self.Icon then
				self.Icon:SetTexCoord(unpack(E.TexCoords))
				self.Icon:SetDrawLayer("ARTWORK")
				self.Icon:SetInside(self, 2, 2)
			end

			self:CreateBackdrop("Default")
			if self.Icon then
				self.Icon:SetParent(self.backdrop)
			end

			self.isSkinned = true
		end

		hooksecurefunc(ChallengesInspectIconDungeonIconMixin, "SetUp", function(self)
			SkinInspectDungeonIcon(self)
			if self.Content and self.Content.MembersContainer and self.Content.MembersContainer.Members then
				for _, member in pairs(self.Content.MembersContainer.Members) do
					SkinInspectMemberIcon(member)
				end
			end
		end)

		hooksecurefunc(ChallengesInspectMemberIconMixin, "OnLoad", function(self)
			SkinInspectMemberIcon(self)
		end)
	end

	----------------- mini games frame
	MiniGamesParentFrame:StripTextures()
	MiniGamesParentFrame.TopInset:StripTextures()
	MiniGamesParentFrame.BottomInset:StripTextures()
	MiniGamesParentFrame.BottomInset.Background:Kill()
	S:HandleButton(MiniGamesParentFrameFindGroupButton, true)

	if _G.LFDParentFrameArt then _G.LFDParentFrameArt:StripTextures() end
	if _G.LFDParentFrameLeftArt then _G.LFDParentFrameLeftArt:StripTextures() end

	hooksecurefunc(MiniGamesParentFrame, "UpdateGames", function(self)
		if self.gameButtonPool then
			for button in self.gameButtonPool:EnumerateActive() do
				if not button.isSkinned then
					S:HandleButton(button)
					button:StyleButton()
					if button.Icon then
						button.Icon:SetTexCoord(unpack(E.TexCoords))
						button.Icon:SetInside()
					end
					button.isSkinned = true
				end
			end
		end
	end)

	hooksecurefunc(MiniGamesParentFrame, "SetSelectedGame", UpdateMiniGameRewards)
	MiniGamesParentFrame:HookScript("OnShow", function(self)
		UpdateMiniGameRewards(self)
	end)

	MiniGameReadyDialog:HookScript("OnShow", function()
		MiniGameReadyDialog:StripTextures()
		MiniGameReadyDialog:CreateBackdrop("Transparent")
		S:HandleButton(MiniGameReadyDialogEnterButton)
		S:HandleButton(MiniGameReadyDialogLeaveQueueButton)
		S:HandleCloseButton(MiniGameReadyDialogCloseButton)
	end)
	MiniGameScoreFrame:HookScript("OnShow", function()
		if MiniGameScoreFrame then
			MiniGameScoreFrame:StripTextures()
		end
		MiniGameScoreFrameInset:StripTextures()
		MiniGameScoreFrame:CreateBackdrop("Transparent")
		if MiniGameScoreFrameContentScrollFrame then
			MiniGameScoreFrameContentScrollFrame:StripTextures()
			MiniGameScoreFrameContentScrollFrame:CreateBackdrop("Transparent")
		end
		S:HandleCloseButton(MiniGameScoreFrameCloseButton)
		S:HandleButton(MiniGameScoreFrameLeaveButton)
		if MiniGameScoreFrameContentScrollFrameScrollBar then
			S:HandleScrollBar(MiniGameScoreFrameContentScrollFrameScrollBar)
		end
	end)
	MiniGameReadyStatus:HookScript("OnShow", function()
		MiniGameReadyStatus:StripTextures()
		MiniGameReadyStatus:CreateBackdrop("Transparent")
		S:HandleCloseButton(MiniGameReadyStatusCloseButton)
	end)

	if LFGListFrame then
		local categorySelection = LFGListFrame.CategorySelection
		if categorySelection then
			if categorySelection.Inset then
				categorySelection.Inset:StripTextures()
				if categorySelection.Inset.CustomBG then
					categorySelection.Inset.CustomBG:Kill()
				end
			end

			local function SkinLFGListCategoryButton(button)
				if button and not button.isSkinned then
					if button.Icon then button.Icon:SetAlpha(0) end
					if button.Cover then button.Cover:Kill() end
					if button.GetHighlightTexture and button:GetHighlightTexture() then
						button:GetHighlightTexture():Kill()
					end

					S:HandleButton(button)

					if button.Label then
						button.Label:ClearAllPoints()
						button.Label:Point("CENTER", 0, 0)
						button.Label:SetJustifyH("CENTER")
					end

					if button.SelectedTexture then
						button.SelectedTexture:SetAlpha(0)

						hooksecurefunc(button.SelectedTexture, "Show", function()
							button:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
						end)
						hooksecurefunc(button.SelectedTexture, "Hide", function()
							button:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end)

						if button.SelectedTexture:IsShown() then
							button:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
						end
					end

					button.isSkinned = true
				end
			end

			if _G.LFGListFrameCategorySelectionCategoryButton1 then
				SkinLFGListCategoryButton(_G.LFGListFrameCategorySelectionCategoryButton1)
			end

			if categorySelection.CategoryButtons then
				for _, button in pairs(categorySelection.CategoryButtons) do
					SkinLFGListCategoryButton(button)
				end
			end

			if categorySelection.buttonList then
				for _, button in pairs(categorySelection.buttonList) do
					SkinLFGListCategoryButton(button)
				end
			end

			categorySelection:HookScript("OnShow", function(self)
				if self.CategoryButtons then
					for _, button in pairs(self.CategoryButtons) do
						SkinLFGListCategoryButton(button)
					end
				end
				for i = 1, 10 do
					local button = _G["LFGListFrameCategorySelectionCategoryButton"..i]
					if button then
						SkinLFGListCategoryButton(button)
					end
				end
			end)

			if categorySelection.FindGroupButton then
				categorySelection.FindGroupButton:StripTextures()
				S:HandleButton(categorySelection.FindGroupButton)
			end
			if categorySelection.StartGroupButton then
				categorySelection.StartGroupButton:StripTextures()
				S:HandleButton(categorySelection.StartGroupButton)
			end
		end

		local nothingAvailable = LFGListFrame.NothingAvailable
		if nothingAvailable then
			if nothingAvailable.Inset then
				nothingAvailable.Inset:StripTextures()
				if nothingAvailable.Inset.CustomBG then
					nothingAvailable.Inset.CustomBG:Kill()
				end
			end
		end

		local searchPanel = LFGListFrame.SearchPanel
		if searchPanel then
			if searchPanel.ResultsInset then
				searchPanel.ResultsInset:StripTextures()
			end

			if searchPanel.SearchBox then
				S:HandleEditBox(searchPanel.SearchBox)
			end

			if searchPanel.FilterButton then
				S:HandleButton(searchPanel.FilterButton)
			end

			if searchPanel.AutoCompleteFrame then
				if searchPanel.AutoCompleteFrame.BottomLeftBorder then searchPanel.AutoCompleteFrame.BottomLeftBorder:Kill() end
				if searchPanel.AutoCompleteFrame.BottomRightBorder then searchPanel.AutoCompleteFrame.BottomRightBorder:Kill() end
				if searchPanel.AutoCompleteFrame.BottomBorder then searchPanel.AutoCompleteFrame.BottomBorder:Kill() end
				if searchPanel.AutoCompleteFrame.LeftBorder then searchPanel.AutoCompleteFrame.LeftBorder:Kill() end
				if searchPanel.AutoCompleteFrame.RightBorder then searchPanel.AutoCompleteFrame.RightBorder:Kill() end
				searchPanel.AutoCompleteFrame:CreateBackdrop("Transparent")
				if searchPanel.AutoCompleteFrame.backdrop then
					searchPanel.AutoCompleteFrame.backdrop:Point("TOPLEFT", 0, 0)
					searchPanel.AutoCompleteFrame.backdrop:Point("BOTTOMRIGHT", 0, 0)
				end
			end

			if searchPanel.RefreshButton then
				S:HandleButton(searchPanel.RefreshButton)
				if searchPanel.RefreshButton.Icon then
					searchPanel.RefreshButton.Icon:SetTexCoord(0, 1, 0, 1)
				end
			end

			if searchPanel.ScrollFrame then
				if searchPanel.ScrollFrame.scrollBar then
					S:HandleScrollBar(searchPanel.ScrollFrame.scrollBar)
				end
				if searchPanel.ScrollFrame.StartGroupButton then
					searchPanel.ScrollFrame.StartGroupButton:StripTextures()
					S:HandleButton(searchPanel.ScrollFrame.StartGroupButton)
				end
				if searchPanel.ScrollFrame.ScrollChild and searchPanel.ScrollFrame.ScrollChild.StartGroupButton then
					searchPanel.ScrollFrame.ScrollChild.StartGroupButton:StripTextures()
					S:HandleButton(searchPanel.ScrollFrame.ScrollChild.StartGroupButton)
				end
			end

			if searchPanel.BackButton then
				S:HandleButton(searchPanel.BackButton, true)
			end
			if searchPanel.BackToGroupButton then
				S:HandleButton(searchPanel.BackToGroupButton, true)
			end
			if searchPanel.SignUpButton then
				S:HandleButton(searchPanel.SignUpButton, true)
			end
		end

		local appViewer = LFGListFrame.ApplicationViewer
		if appViewer then
			if appViewer.InfoBackground then
				appViewer.InfoBackground:Kill()
			end

			if appViewer.Inset then
				appViewer.Inset:StripTextures()
			end

			if appViewer.NameColumnHeader then
				appViewer.NameColumnHeader:StripTextures()
				S:HandleButton(appViewer.NameColumnHeader)
			end
			if appViewer.RoleColumnHeader then
				appViewer.RoleColumnHeader:StripTextures()
				S:HandleButton(appViewer.RoleColumnHeader)
			end
			if appViewer.ItemLevelColumnHeader then
				appViewer.ItemLevelColumnHeader:StripTextures()
				S:HandleButton(appViewer.ItemLevelColumnHeader)
			end
			if appViewer.RatingColumnHeader then
				appViewer.RatingColumnHeader:StripTextures()
				S:HandleButton(appViewer.RatingColumnHeader)
			end

			if appViewer.AutoAcceptButton then
				S:HandleCheckBox(appViewer.AutoAcceptButton)
			end

			if appViewer.RefreshButton then
				S:HandleButton(appViewer.RefreshButton)
				if appViewer.RefreshButton.Icon then
					appViewer.RefreshButton.Icon:SetTexCoord(0, 1, 0, 1)
				end
			end

			if appViewer.ScrollFrame and appViewer.ScrollFrame.scrollBar then
				S:HandleScrollBar(appViewer.ScrollFrame.scrollBar)
			end

			if appViewer.RemoveEntryButton then
				S:HandleButton(appViewer.RemoveEntryButton)
			end
			if appViewer.EditButton then
				S:HandleButton(appViewer.EditButton)
			end
			if appViewer.BrowseGroupsButton then
				S:HandleButton(appViewer.BrowseGroupsButton)
			end
		end

		local entryCreation = LFGListFrame.EntryCreation
		if entryCreation then
			if entryCreation.Inset then
				entryCreation.Inset:StripTextures()
			end

			if entryCreation.Name then
				S:HandleEditBox(entryCreation.Name)
			end
			if entryCreation.Description then
				if entryCreation.Description.Bg then
					entryCreation.Description.Bg:Kill()
				end
				for _, region in pairs({entryCreation.Description:GetRegions()}) do
					if region:IsObjectType("Texture") then
						local textureName = region:GetName()
						if textureName and (textureName:find("Left") or textureName:find("Right") or
						   textureName:find("Top") or textureName:find("Bottom") or textureName:find("Middle")) then
							region:Kill()
						end
					end
				end
				entryCreation.Description:CreateBackdrop("Transparent")
				if entryCreation.Description.EditBox then
					entryCreation.Description.EditBox:SetTextInsets(4, 4, 4, 4)
				end
			end

			if entryCreation.ActivityDropDown then
				S:HandleDropDownBox(entryCreation.ActivityDropDown)
			end
			if entryCreation.GroupDropDown then
				S:HandleDropDownBox(entryCreation.GroupDropDown)
			end
			if entryCreation.PlayStyleDropdown then
				S:HandleDropDownBox(entryCreation.PlayStyleDropdown)
			end
			if entryCreation.CategoryDropdown then
				S:HandleDropDownBox(entryCreation.CategoryDropdown)
			end

			if entryCreation.ItemLevel then
				if entryCreation.ItemLevel.CheckButton then
					S:HandleCheckBox(entryCreation.ItemLevel.CheckButton)
				end
				if entryCreation.ItemLevel.EditBox then
					S:HandleEditBox(entryCreation.ItemLevel.EditBox)
				end
			end

			if entryCreation.VoiceChat then
				if entryCreation.VoiceChat.CheckButton then
					S:HandleCheckBox(entryCreation.VoiceChat.CheckButton)
				end
				if entryCreation.VoiceChat.EditBox then
					S:HandleEditBox(entryCreation.VoiceChat.EditBox)
				end
			end

			if entryCreation.PrivateGroup then
				if entryCreation.PrivateGroup.CheckButton then
					S:HandleCheckBox(entryCreation.PrivateGroup.CheckButton)
				end
			end

			if entryCreation.RaidRules then
				if entryCreation.RaidRules.CheckButton then
					S:HandleCheckBox(entryCreation.RaidRules.CheckButton)
				end
			end

			if entryCreation.RaidRulesDescription then
				entryCreation.RaidRulesDescription:StripTextures()
				if entryCreation.RaidRulesDescription.EditBox then
					entryCreation.RaidRulesDescription:CreateBackdrop("Transparent")
					entryCreation.RaidRulesDescription.EditBox:SetTextInsets(4, 4, 4, 4)
				else
					S:HandleEditBox(entryCreation.RaidRulesDescription)
				end
			end

			if entryCreation.PVPRating then
				if entryCreation.PVPRating.CheckButton then
					S:HandleCheckBox(entryCreation.PVPRating.CheckButton)
				end
				if entryCreation.PVPRating.EditBox then
					S:HandleEditBox(entryCreation.PVPRating.EditBox)
				end
			end

			if entryCreation.MythicPlusRating then
				if entryCreation.MythicPlusRating.CheckButton then
					S:HandleCheckBox(entryCreation.MythicPlusRating.CheckButton)
				end
				if entryCreation.MythicPlusRating.EditBox then
					S:HandleEditBox(entryCreation.MythicPlusRating.EditBox)
				end
			end

			if entryCreation.ListGroupButton then
				S:HandleButton(entryCreation.ListGroupButton, true)
			end
			if entryCreation.CancelButton then
				S:HandleButton(entryCreation.CancelButton, true)
			end
		end

		hooksecurefunc("LFGListSearchEntry_Update", function(button)
			if button and not button.isSkinned then
				button:SetTemplate("Transparent")
				button:StyleButton()
				if button.HighlightTexture then
					button.HighlightTexture:SetTexture(1, 1, 1, 0.1)
					button.HighlightTexture:SetInside()
				end
				if button.Selected then
					button.Selected:SetTexture(E.media.normTex)
					button.Selected:SetVertexColor(1, 1, 1)
					button.Selected:SetAlpha(0.2)
					button.Selected:SetInside()
				end
				if button.ExpirationTime and button.ExpirationTime.pointed then
					button.ExpirationTime.pointed:Kill()
				end

				if button.Selected then
					hooksecurefunc(button.Selected, "Show", function()
						if button.backdrop then
							button.backdrop:SetBackdropColor(0.3, 0.3, 0.3, 0.8)
						end
						button:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
					end)
					hooksecurefunc(button.Selected, "Hide", function()
						if button.backdrop then
							button.backdrop:SetBackdropColor(unpack(E.media.backdropcolor))
						end
						button:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end)
					if button.Selected:IsShown() then
						if button.backdrop then
							button.backdrop:SetBackdropColor(0.3, 0.3, 0.3, 0.8)
						end
						button:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
					end
				end

				button.isSkinned = true
			end
		end)

		hooksecurefunc("LFGListApplicantMember_OnEnter", function(button)
			if button and not button.isSkinned then
				button:SetTemplate("Transparent")
				button.isSkinned = true
			end
		end)
	end

	if LFGListInviteDialog then
		LFGListInviteDialog:StripTextures()
		LFGListInviteDialog:SetTemplate("Transparent")
		if LFGListInviteDialog.AcceptButton then
			S:HandleButton(LFGListInviteDialog.AcceptButton)
		end
		if LFGListInviteDialog.DeclineButton then
			S:HandleButton(LFGListInviteDialog.DeclineButton)
		end
		if LFGListInviteDialog.AcknowledgeButton then
			S:HandleButton(LFGListInviteDialog.AcknowledgeButton)
		end
	end

	if LFGListApplicationDialog then
		LFGListApplicationDialog:StripTextures()
		LFGListApplicationDialog:SetTemplate("Transparent")
		if LFGListApplicationDialog.Description then
			LFGListApplicationDialog.Description:StripTextures()
			if LFGListApplicationDialog.Description.EditBox then
				S:HandleEditBox(LFGListApplicationDialog.Description.EditBox)
			end
		end
		if LFGListApplicationDialog.SignUpButton then
			S:HandleButton(LFGListApplicationDialog.SignUpButton)
		end
		if LFGListApplicationDialog.CancelButton then
			S:HandleButton(LFGListApplicationDialog.CancelButton)
		end
	end

end

S:AddCallback("Skin_LFD", LoadSkin)
