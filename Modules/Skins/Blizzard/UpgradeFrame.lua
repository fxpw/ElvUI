local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallback("Skin_UpgradeFrame", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.upgrade then return end
	-- print("da")
	S:HandleFrame(ItemUpgradeFrame);
	ItemUpgradeFrameNineSlice:StripTextures();
	ItemUpgradeFrameNineSliceTutorialButton:ClearAllPoints();
	ItemUpgradeFrameNineSliceTutorialButton:SetPoint("TOPLEFT",0,0);
	S:HandleCloseButton(ItemUpgradeFrameCloseButton);
	S:HandleButton(ItemUpgradeFrameUpgradeButton);
	ItemUpgradeFrameLeftItemPreviewFrame:HookScript("OnShow",function(self)
		self:StripTextures()
	end)
	ItemUpgradeFrameRightItemPreviewFrame:HookScript("OnShow",function(self)
		self:StripTextures()
	end)
	for i =1,4 do
		_G["ItemUpgradeFrameItemsListPreviewFrameItemButton"..i]:HookScript("OnShow",function(self)
			S:HandleButton(self)
		end)
	end

	local frameForIter
	hooksecurefunc("EquipmentFlyout_UpdateItems",function()
		EquipmentFlyoutFrameButtons.isSkinned = false
		EquipmentFlyoutFrameNavigationFrame.isSkinned = false
		S:HandleFrame(EquipmentFlyoutFrameButtons)
		S:HandleFrame(EquipmentFlyoutFrameNavigationFrame)
		EquipmentFlyoutFrameNavigationFrame:StripTextures()

		for i =1,20 do
			frameForIter = G["EquipmentFlyoutFrameButton"..i]
			if frameForIter then
				S:HandleIcon(frameForIter.icon)
			else
				break
			end
		end
		S:HandleNextPrevButton(EquipmentFlyoutFrameNavigationFrameNextButton,"right")
		S:HandleNextPrevButton(EquipmentFlyoutFrameNavigationFramePrevButton,"left")

		S:HandleNextPrevButton(ItemUpgradeFramePagingFrameNextPageButton,"right")
		S:HandleNextPrevButton(ItemUpgradeFramePagingFramePrevPageButton,"left")
	end)

end)