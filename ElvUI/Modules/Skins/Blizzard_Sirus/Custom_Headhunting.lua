local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.headhunting then return end

	local HeadHuntingFrame = HeadHuntingFrame
	S:HandlePortraitFrame(HeadHuntingFrame)

	for i = 1, 3 do
		local popup = HeadHuntingFrame["PopupFrame"..i]
		popup:SetTemplate("Transparent")
		S:HandleButton(popup.Button1)
	end

	HeadHuntingFrame.navBar:StripTextures()
	HeadHuntingFrame.navBar.overlay:StripTextures()

	S:HandleButton(HeadHuntingFrame.navBar.home, true)
	HeadHuntingFrame.navBar.home.xoffset = 1

	HeadHuntingFrame.inset:StripTextures()

	S:HandleButton(HeadHuntingFrame.Container.HomeTab, true)
	S:HandleButton(HeadHuntingFrame.Container.AllTargetsTab, true)
	S:HandleButton(HeadHuntingFrame.Container.YouTargetsTab, true)

	local function Panel_OnShow(self)
		for _, button in ipairs(HeadHuntingFrame.columnButtons) do
			if not button.isSkinned then
				button:StripTextures()
				button:StyleButton()
				button.isSkinned = true
			end
		end
	end

	local HomePanel = HeadHuntingFrame.Container.HomePanel
	HomePanel:HookScript("OnShow", Panel_OnShow)
--	HomePanel:SetTemplate("Transparent")
	S:HandleButton(HomePanel.SuggestionFrameRightTop.CenterDisplay.ButtonLeft)
	S:HandleButton(HomePanel.SuggestionFrameRightTop.CenterDisplay.ButtonRight)
	S:HandleButton(HomePanel.SuggestionFrameRightBottom.CenterDisplay.ButtonLeft)
	S:HandleButton(HomePanel.SuggestionFrameRightBottom.CenterDisplay.ButtonRight)

	local AllTargetsPanel = HeadHuntingFrame.Container.AllTargetsPanel
	AllTargetsPanel:HookScript("OnShow", Panel_OnShow)
--	AllTargetsPanel:SetTemplate("Transparent")
	AllTargetsPanel.ScrollFrame.Background:SetAlpha(0)
	S:HandleScrollBar(HeadHuntingFrameContainerAllTargetsPanelScrollFrameScrollBar)
	AllTargetsPanel.ScrollFrame.ShadowOverlay:SetAlpha(0)

	AllTargetsPanel.InfoFrame:SetTemplate("Transparent")
	AllTargetsPanel.InfoFrame.BackgroundTile:SetAlpha(0)
	AllTargetsPanel.InfoFrame.ShadowOverlay:SetAlpha(0)
	S:HandleScrollBar(HeadHuntingFrameContainerAllTargetsPanelInfoFrameContainerScrollFrameScrollBar)

	local closseButton = select(3, AllTargetsPanel.InfoFrame:GetChildren())
	S:HandleCloseButton(closseButton)
	closseButton.Corner:SetAlpha(0)

	AllTargetsPanel.ContractOnPlayer:StripTextures()

	local YouTargetsPanel = HeadHuntingFrame.Container.YouTargetsPanel
	YouTargetsPanel:HookScript("OnShow", Panel_OnShow)
--	YouTargetsPanel:SetTemplate("Transparent")

	S:HandleButton(YouTargetsPanel.SetRewardButton)
	YouTargetsPanel.ScrollFrame.Background:SetAlpha(0)
	S:HandleScrollBar(HeadHuntingFrameContainerYouTargetsPanelScrollFrameScrollBar)
	YouTargetsPanel.ScrollFrame.ShadowOverlay:SetAlpha(0)

	YouTargetsPanel.DetailsFrame:SetTemplate("Transparent")
	YouTargetsPanel.DetailsFrame.CloseCorner:SetAlpha(0)
	YouTargetsPanel.DetailsFrame.Divider:SetAlpha(0)
	S:HandleCheckBox(YouTargetsPanel.DetailsFrame.Container.NotifyWhenKilling)
	S:HandleCheckBox(YouTargetsPanel.DetailsFrame.Container.NotifyWhenComplete)
	S:HandleCloseButton(YouTargetsPanel.DetailsFrame.CloseButton)
	S:HandleButton(YouTargetsPanel.DetailsFrame.RemoveContractButton)

	local function SkinRewardFrame(frame)
		S:HandlePortraitFrame(frame)
		S:HandleEditBox(frame.SearchFrame.SearchBox) --??
		S:HandleButton(frame.SearchFrame.SearchButton) --??
		frame.CentralContainer:StripTextures()
		frame.CentralContainer.ScrollFrame.ShadowOverlay:SetAlpha(0)
		S:HandleScrollBar(_G[frame:GetName().."CentralContainerScrollFrameScrollBar"])
		S:HandleEditBox(frame.NumKills)
		S:HandleEditBox(frame.GoldPerKillsEditBox)
		S:HandleButton(frame.SetRewardButton)
	end

	SkinRewardFrame(YouTargetsPanel.SetRewardFrame)

	for i = 1, 2 do
		S:HandleTab(_G["HeadHuntingFrameTab"..i])
	end

	HeadHuntingSetRewardExternalFrame:SetParent(UIParent)
	SkinRewardFrame(HeadHuntingSetRewardExternalFrame)
	--SearchBox and button 
	S:HandleEditBox(HeadHuntingFrame.Container.AllTargetsPanel.SearchFrame.SearchBox)
	S:HandleButton(HeadHuntingFrame.Container.AllTargetsPanel.SearchFrame.SearchButton)
	HeadHuntingFrameContainerAllTargetsPanelFilterDropDownMenu:StripTextures(true)	
	S:HandleButton(HeadHuntingFrameContainerAllTargetsPanelFilterDropDownMenu)
end

S:AddCallback("Custom_Headhunting", LoadSkin)