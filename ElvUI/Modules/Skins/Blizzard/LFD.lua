local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select, unpack = select, unpack
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetLFGDungeonRewardLink = GetLFGDungeonRewardLink
local GetLFGDungeonRewards = GetLFGDungeonRewards
local hooksecurefunc = hooksecurefunc
local find = string.find


local function SkinMiniGameLoot(frame)
	if frame.isSkinned then return end

	local nameFrame = _G[frame:GetName().."NameFrame"]

	frame:StripTextures()

	nameFrame:SetSize(118, 39)

	frame.isSkinned = true
end


local function updateMiniGames()
	MiniGamesParentFrameBottomInset:StripTextures()
	MiniGamesParentFrameBottomInsetScrollFrame:StripTextures()
	MiniGamesParentFrameTopInset:StripTextures()
	S:HandleButton(MiniGamesParentFrameFindGroupButton,true)
	S:HandleScrollBar(MiniGamesParentFrameBottomInsetScrollFrameScrollBar)

	for i = 1,LFD_MAX_REWARDS do
		local butt  = _G["MiniGamesParentFrameBottomInsetScrollFrameChildFramePoolFrameMiniGameLootTemplate"..i]
		if butt then

				SkinMiniGameLoot(butt)

			local link = butt.itemLink
			if link then
				local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
				if quality then
					local a = _G["MiniGamesParentFrameBottomInsetScrollFrameChildFramePoolFrameMiniGameLootTemplate"..i.."IconTexture"]
					local name = _G["MiniGamesParentFrameBottomInsetScrollFrameChildFramePoolFrameMiniGameLootTemplate"..i.."Name"]
					
					if butt.Icon then
						butt.Icon:StripTextures()
						butt.Icon:CreateBackdrop("Transparent")
						
						
						butt.Icon:SetTexCoord(unpack(E.TexCoords))
						butt.Icon:SetDrawLayer("BORDER")

						butt.Icon.backdrop:SetOutside(butt.Icon)
						butt.Icon:SetParent(butt.Icon.backdrop)

						a:SetTexture(texture)
					end
					butt.Icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					name:SetTextColor(GetItemQualityColor(quality))
				end
			else
				butt.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				name:SetTextColor(1, 1, 1)
			end
		end
	end
end

-- S:AddCallback("Skin_LFD", function()
-- 	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfd then return end

-- 	LFDQueueFrame:StripTextures(true)
-- 	LFDQueueFrame:CreateBackdrop("Transparent")
-- 	LFDQueueFrame.backdrop:Point("TOPLEFT", 11, -12)
-- 	LFDQueueFrame.backdrop:Point("BOTTOMRIGHT", -3, 4)

-- 	S:HookScript(LFDParentFrame, "OnShow", function(self)
-- 		S:SetUIPanelWindowInfo(self, "width", 341)
-- 		S:SetBackdropHitRect(self, LFDQueueFrame.backdrop)
-- 		S:Unhook(self, "OnShow")
-- 	end)

-- 	S:HandleCloseButton((LFDParentFrame:GetChildren()), LFDQueueFrame.backdrop)

-- 	LFDParentFramePortrait:Kill()

-- 	S:HandleCheckBox(LFDQueueFrameRoleButtonTank.checkButton)
-- 	LFDQueueFrameRoleButtonTank.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonTank.checkButton:GetFrameLevel() + 2)
-- 	S:HandleCheckBox(LFDQueueFrameRoleButtonHealer.checkButton)
-- 	LFDQueueFrameRoleButtonHealer.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonHealer.checkButton:GetFrameLevel() + 2)
-- 	S:HandleCheckBox(LFDQueueFrameRoleButtonDPS.checkButton)
-- 	LFDQueueFrameRoleButtonDPS.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonDPS.checkButton:GetFrameLevel() + 2)
-- 	S:HandleCheckBox(LFDQueueFrameRoleButtonLeader.checkButton)
-- 	LFDQueueFrameRoleButtonLeader.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonLeader.checkButton:GetFrameLevel() + 2)

-- 	S:HandleDropDownBox(LFDQueueFrameTypeDropDown)
-- 	LFDQueueFrameTypeDropDown:HookScript("OnShow", function(self) self:Width(200) end)

-- 	for i = 1, NUM_LFD_CHOICE_BUTTONS do
-- 		local button = _G["LFDQueueFrameSpecificListButton"..i]
-- 		button.enableButton:StripTextures()
-- 		button.enableButton:CreateBackdrop("Default")
-- 		button.enableButton.backdrop:SetInside(nil, 4, 4)

-- 		S:HandleCollapseExpandButton(button.expandOrCollapseButton, "+")
-- 	end

-- 	LFDQueueFrameSpecificListScrollFrame:StripTextures()
-- 	S:HandleScrollBar(LFDQueueFrameRandomScrollFrameScrollBar)
-- 	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)

-- 	S:HandleButton(LFDQueueFrameFindGroupButton)
-- 	S:HandleButton(LFDQueueFrameCancelButton)

-- 	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton)
-- 	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton)

-- 	S:HandleButton(LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)

-- 	LFDQueueFrameRandomScrollFrameScrollBar:Point("TOPLEFT", LFDQueueFrameRandomScrollFrame, "TOPRIGHT", 5, -22)
-- 	LFDQueueFrameRandomScrollFrameScrollBar:Point("BOTTOMLEFT", LFDQueueFrameRandomScrollFrame, "BOTTOMRIGHT", 5, 19)

-- 	LFDQueueFrameSpecificListScrollFrameScrollBar:Point("TOPLEFT", LFDQueueFrameSpecificListScrollFrame, "TOPRIGHT", 5, -17)
-- 	LFDQueueFrameSpecificListScrollFrameScrollBar:Point("BOTTOMLEFT", LFDQueueFrameSpecificListScrollFrame, "BOTTOMRIGHT", 5, 17)

-- 	LFDQueueFrameFindGroupButton:Point("BOTTOMLEFT", 19, 12)
-- 	LFDQueueFrameCancelButton:Point("BOTTOMRIGHT", -11, 12)

-- 	LFDQueueFrameTypeDropDown:Point("TOPLEFT", 152, -119)

-- 	LFDQueueFrameSpecificListButton1:Point("TOPLEFT", 25, -154)
-- 	LFDQueueFrameRandomScrollFrame:Point("BOTTOMRIGHT", -34, 41)

-- 	LFDQueueFrameCooldownFrame:Size(325, 259)
-- 	LFDQueueFrameCooldownFrame:Point("BOTTOMRIGHT", LFDQueueFrame, "BOTTOMRIGHT", -11, 37)

-- 	LFDQueueFrameCooldownFrame:HookScript("OnShow", function(self)
-- 		self:SetFrameLevel(self:GetParent():GetFrameLevel() + 5)
-- 	end)

-- 	local function skinLFDRandomDungeonLoot(frame)
-- 		if frame.isSkinned then return end

-- 		local icon = _G[frame:GetName().."IconTexture"]
-- 		local nameFrame = _G[frame:GetName().."NameFrame"]
-- 		local count = _G[frame:GetName().."Count"]

-- 		frame:StripTextures()
-- 		frame:CreateBackdrop("Transparent")
-- 		frame.backdrop:SetOutside(icon)

-- 		icon:SetTexCoord(unpack(E.TexCoords))
-- 		icon:SetDrawLayer("BORDER")
-- 		icon:SetParent(frame.backdrop)

-- 		nameFrame:SetSize(118, 39)

-- 		count:SetParent(frame.backdrop)

-- 		frame.isSkinned = true
-- 	end

-- 	local function getLFGDungeonRewardLinkFix(dungeonID, rewardIndex)
-- 		local _, link = GetLFGDungeonRewardLink(dungeonID, rewardIndex)

-- 		if not link then
-- 			E.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
-- 			E.ScanTooltip:SetLFGDungeonReward(dungeonID, rewardIndex)
-- 			_, link = E.ScanTooltip:GetItem()
-- 			E.ScanTooltip:Hide()
-- 		end

-- 		return link
-- 	end

-- 	hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", function()
-- 		local dungeonID = LFDQueueFrame.type
-- 		if not dungeonID then return end

-- 		local _, _, _, _, _, numRewards = GetLFGDungeonRewards(dungeonID)
-- 		for i = 1, numRewards do
-- 			local frame = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
-- 			local name = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Name"]

-- 			skinLFDRandomDungeonLoot(frame)

-- 			local link = getLFGDungeonRewardLinkFix(dungeonID, i)
-- 			if link then
-- 				local _, _, quality = GetItemInfo(link)
-- 				if quality then
-- 					local r, g, b = GetItemQualityColor(quality)
-- 					frame.backdrop:SetBackdropBorderColor(r, g, b)
-- 					name:SetTextColor(r, g, b)
-- 				end
-- 			else
-- 				frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
-- 				name:SetTextColor(1, 1, 1)
-- 			end
-- 		end
-- 	end)

-- 	-- LFDDungeonReadyStatus
-- 	LFDDungeonReadyStatus:SetTemplate("Transparent")
-- 	S:HandleCloseButton(LFDDungeonReadyStatusCloseButton, nil, "-")

-- 	LFDSearchStatus:SetTemplate("Transparent")

-- 	-- LFDRoleCheckPopup
-- 	LFDRoleCheckPopup:SetTemplate("Transparent")

-- 	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonTank.checkButton)
-- 	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonHealer.checkButton)
-- 	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonDPS.checkButton)

-- 	S:HandleButton(LFDRoleCheckPopupAcceptButton)
-- 	S:HandleButton(LFDRoleCheckPopupDeclineButton)

-- 	-- LFDDungeonReadyDialog
-- 	LFDDungeonReadyDialog:SetTemplate("Transparent")

-- 	LFDDungeonReadyDialog.label:Size(280, 0)
-- 	LFDDungeonReadyDialog.label:Point("TOP", 0, -10)

-- 	LFDDungeonReadyDialog:CreateBackdrop("Default")
-- 	LFDDungeonReadyDialog.backdrop:Point("TOPLEFT", 10, -35)
-- 	LFDDungeonReadyDialog.backdrop:Point("BOTTOMRIGHT", -10, 40)

-- 	LFDDungeonReadyDialog.backdrop:SetFrameLevel(LFDDungeonReadyDialog:GetFrameLevel())
-- 	LFDDungeonReadyDialog.background:SetInside(LFDDungeonReadyDialog.backdrop)

-- 	LFDDungeonReadyDialogFiligree:SetTexture("")
-- 	LFDDungeonReadyDialogBottomArt:SetTexture("")

-- 	S:HandleCloseButton(LFDDungeonReadyDialogCloseButton, nil, "-")

-- 	LFDDungeonReadyDialogEnterDungeonButton:Point("BOTTOMRIGHT", LFDDungeonReadyDialog, "BOTTOM", -7, 10)
-- 	S:HandleButton(LFDDungeonReadyDialogEnterDungeonButton)
-- 	LFDDungeonReadyDialogLeaveQueueButton:Point("BOTTOMLEFT", LFDDungeonReadyDialog, "BOTTOM", 7, 10)
-- 	S:HandleButton(LFDDungeonReadyDialogLeaveQueueButton)

-- --[[
-- 	LFDDungeonReadyDialogRoleIcon:Size(57)
-- 	LFDDungeonReadyDialogRoleIcon:Point("BOTTOM", 1, 54)
-- 	LFDDungeonReadyDialogRoleIcon:SetTemplate("Default")
-- 	LFDDungeonReadyDialogRoleIconTexture:SetInside()

-- 	function GetTexCoordsForRole(role)
-- 		if role == "GUIDE" then
-- 			return 0.0625, 0.1953125, 0.05859375, 0.19140625
-- 		elseif role == "TANK" then
-- 			return 0.0625, 0.1953125, 0.3203125, 0.453125
-- 		elseif role == "HEALER" ) then
-- 			return 0.32421875, 0.45703125, 0.0546875, 0.1875
-- 		elseif role == "DAMAGER" then
-- 			return 0.32421875, 0.453125, 0.31640625, 0.4453125
-- 		end
-- 	end
-- 	GameTooltip:SetLFGDungeonReward(287, 1)
-- --]]

-- 	local function skinLFDDungeonReadyDialogReward(button)
-- 		if button.isSkinned then return end

-- 		button:Size(28)
-- 		button:SetTemplate("Default")
-- 		button.texture:SetInside()
-- 		button.texture:SetTexCoord(unpack(E.TexCoords))
-- 		button:DisableDrawLayer("OVERLAY")

-- 		button.isSkinned = true
-- 	end

-- 	hooksecurefunc("LFDDungeonReadyDialogReward_SetMisc", function(button)
-- 		skinLFDDungeonReadyDialogReward(button)

-- 		SetPortraitToTexture(button.texture, "")
-- 		button.texture:SetTexture("Interface\\Icons\\inv_misc_coin_02")
-- 	end)

-- 	hooksecurefunc("LFDDungeonReadyDialogReward_SetReward", function(button, dungeonID, rewardIndex)
-- 		skinLFDDungeonReadyDialogReward(button)

-- 		local link = getLFGDungeonRewardLinkFix(dungeonID, rewardIndex)
-- 		if link then
-- 			local _, _, quality = GetItemInfo(link)
-- 			button:SetBackdropBorderColor(GetItemQualityColor(quality))
-- 		else
-- 			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
-- 		end

-- 		local texturePath = button.texture:GetTexture()
-- 		if texturePath then
-- 			SetPortraitToTexture(button.texture, "")
-- 			button.texture:SetTexture(texturePath)
-- 		end
-- 	end)
-- end)

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
		S:HandleTab(_G["LFDParentFrameTab"..i])
	end
	local tabstorem ={
		"LFDParentFrameTab",
		"PVPUIFrameTab",
		"PVPLadderFrameTab",
		"RenegadeLadderFrameTab",
	}
	for i = 1,4 do
		for _,tab in pairs(tabstorem) do
		tab = _G[tab..1]
			if tab then
				tab:ClearAllPoints()
				tab:SetPoint("BOTTOMLEFT", 2, -30)
			end
		end
	end

	-- LFDParentFrameTab1:ClearAllPoints()
	-- LFDParentFrameTab1:SetPoint("BOTTOMLEFT", 2, -30)

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

		local icon = _G[frame:GetName().."IconTexture"]
		local nameFrame = _G[frame:GetName().."NameFrame"]
		local count = _G[frame:GetName().."Count"]

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
			local frame = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
			local name = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Name"]
			SkinLFDRandomDungeonLoot(frame)

			local link = GetLFGDungeonRewardLinkFix(dungeonID, i)
			if link then
				local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
				if quality then
					_G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"]:SetTexture(texture)
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
		local button = _G["LFDQueueFrameSpecificListButton"..i]
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
	PVPUIFrame.Art.portraitFrame:Kill()
	S:HandleCloseButton(PVPUIFrameCloseButton)
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
		S:HandleTab(_G["PVPUIFrameTab"..i])
	end

	for i = 1, 3 do
		local b = PVPQueueFrame["CategoryButton"..i]
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
	PVPQueueFrameBattlePassToggleButton.Icon.backdrop:SetFrameLevel(PVPQueueFrameBattlePassToggleButton:GetFrameLevel() + 2)
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
--	PVPQueueFrame.StepBottomFrame.backdrop:SetOutside(PVPQueueFrame.StepBottomFrame.Step1.Background, nil, nil, PVPQueueFrame.StepBottomFrame.StepEnd.Background)

--[[
	for i = 1, 4 do
		local step = PVPQueueFrame.StepBottomFrame["Step"..i]
		step.Background:SetTexture(E.media.normTex)
		step.Background.SetAtlas = E.noop
		step.Background.SetDesaturated = E.noop
		step.Arrow:Kill()

		hooksecurefunc(step, "SetState", function(self, state)
			if state == 2 then
				self.Background:SetVertexColor(0, 1, 0)
			elseif state == 1 then
				self.Background:SetVertexColor(1, 0, 0)
			else
				self.Background:SetVertexColor(unpack(E.media.backdropcolor))
			end
		end)
	end

	PVPQueueFrame.StepBottomFrame.StepEnd.Background:SetTexture(E.media.normTex)
	PVPQueueFrame.StepBottomFrame.StepEnd.Background.SetAtlas = E.noop
	PVPQueueFrame.StepBottomFrame.StepEnd.Background.SetDesaturated = E.noop
]]

	PVPQueueFrame.StepBottomFrame.ShadowOverlay:StripTextures()

	ConquestFrame.BottomInset:StripTextures()

	S:HandleDropDownBox(ConquestFrameBottomInsetTypeDropDown)
	ConquestFrame.BottomInset.ShadowOverlay:StripTextures()

	local function StyleButton(button, icon)
		--S:HandleButton(button)
		button:StripTextures()
		button:SetTemplate("Default", true)
		button:StyleButton()
		--button.Icon:SetDrawLayer("BACKGROUND", 2)
		--button.Icon:SetTexCoord(unpack(E.TexCoords))
		--button.Icon:SetInside()
		--button.Cover:Hide()
		button:GetHighlightTexture():SetTexture(1, 1, 1, 0.1)
		button:GetHighlightTexture():SetInside()

		--button.SelectedTexture:SetTexture(.9, .8, .1, .3)
		--button.SelectedTexture:SetInside()
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
	ConquestFrame.BottomInset.ArenaContainer.Arena2v2:Point("TOP", ConquestFrame.BottomInset.ArenaContainer.Header, "BOTTOM", 0, 10)
	StyleButton(ConquestFrame.BottomInset.ArenaContainer.Arena1v1)
	ConquestFrame.BottomInset.ArenaContainer.Arena1v1:Point("TOP", ConquestFrame.BottomInset.ArenaContainer.Arena2v2, "BOTTOM", 0, -(E.Border*2))

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
	PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton:Point("TOP", PVPHonorFrame.BottomInset.BonusBattlefieldContainer.Header, "BOTTOM", 0, 10)
	StyleButton(PVPHonorFrame.BottomInset.BonusBattlefieldContainer.CallToArmsButton)
	PVPHonorFrame.BottomInset.BonusBattlefieldContainer.CallToArmsButton:Point("TOP", PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton, "BOTTOM", 0, -(E.Border*2))

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
			button:SetPoint("TOPLEFT", PVPHonorFrameSpecificFrame.buttons[i-1], "BOTTOMLEFT", 0, -E.Border)
		end

		StyleButton(button, true)
	end

	PVPHonorFrameSpecificFrame.buttonHeight = PVPHonorFrameSpecificFrame.buttonHeight - 4
	PVPHonorFrameSpecificFrame.scrollChild:SetHeight(#PVPHonorFrameSpecificFrame.buttons * PVPHonorFrameSpecificFrame.buttonHeight)
	PVPHonorFrameSpecificFrame.scrollBar:SetMinMaxValues(0, #PVPHonorFrameSpecificFrame.buttons * PVPHonorFrameSpecificFrame.buttonHeight)

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
			local r, g, b = E:ColorGradient(value * 100, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
			bar.backdrop:SetBackdropColor(r*0.25, g*0.25, b*0.25)
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
		_G["PVPUI_ArenaTeamDetailsColumnHeader"..i]:StripTextures()
	end
	for i = 1, 10 do
		_G["PVPUI_ArenaTeamDetailsButton"..i]:StripTextures()
	end

	S:HandleButton(PVPUI_ArenaTeamDetailsAddTeamMember)

--	BattlegroundInviteFrame:SetTemplate("Transparent")
--	BattlegroundInviteFrame.Background:SetAlpha(0)

--	S:HandleButton(BattlegroundInviteFrame.PopupFrame.EnterButton)
--	S:HandleButton(BattlegroundInviteFrame.PopupFrame.CancelButton)

	S:HandlePortraitFrame(PVPLadderFrame)
	S:HandleCloseButton(PVPLadderFrameCloseButton)
	PVPLadderFrame:SetTemplate("Transparent")
	PVPLadderFrame.LeftInset:StripTextures()
	PVPLadderFrame.Shadows:StripTextures()

	for i = 1, PVPLadderFrame:GetNumChildren() do
		local child = select(i, PVPLadderFrame:GetChildren())
		if child and child:GetName() and find(child:GetName(), "Art") then
			child:StripTextures()
		end
	end

	for i = 1, 4 do
		S:HandleTab(_G["PVPLadderFrameTab"..i])
	end

	local c = .035
	local tc = {
		{.253906 + c, 0.503906 - c, 0.507813 + c, 0.757813 - c},
		{c, 0.25 - c, c, 0.25 - c},
		{c, 0.250000 - c, 0.253906 + c, 0.503906 - c},
		{.507813 + c, 0.757813 - c, c, 0.25 - c},
	}

	local function SkinCategoryButton(b, i)
		b.Ring:SetAlpha(0)
		b.Background:SetAlpha(0)
		S:HandleButton(b)
		b.Icon:Size(45)
		b.Icon:ClearAllPoints()
		b.Icon:Point("LEFT", 10, 0)
		local texture = b.Icon:GetTexture()
		SetPortraitToTexture(b.Icon, "")
		b.Icon:SetTexture(texture)
		b.Icon:SetTexCoord(unpack(tc[i]))
		b.Icon:CreateBackdrop()
		b.Icon:SetParent(b.Icon.backdrop)
		b.Icon.backdrop:SetFrameLevel(b:GetFrameLevel() + 2)
		b.Name:FontTemplate(nil, 16)
	end

	for i = 1, #PVPLadderFrame.categoryButtons do
		SkinCategoryButton(PVPLadderFrame.categoryButtons[i], i)
	end

	for i = 1, 2 do
		local tab = PVPLadderFrame.Container["RightBigTab"..i]
		tab:SetTemplate()
		tab:StyleButton()
		tab:GetRegions():Hide()
		tab.Icon:SetTexCoord(unpack(E.TexCoords))
		tab.Icon:SetInside()
	end
	PVPLadderFrame.Container.RightBigTab1:Point("TOPLEFT", PVPLadderFrame.Container, "TOPRIGHT", -E.Border, -34)
	for i = 1, 10 do
		local tab = PVPLadderFrame.Container["RightSmallTab"..i]
		tab:SetTemplate()
		tab:StyleButton()
		tab:GetRegions():Hide()
		tab.Icon:SetTexCoord(unpack(E.TexCoords))
		tab.Icon:SetInside()
	end
	PVPLadderFrame.Container.RightSmallTab1:Point("TOPLEFT", PVPLadderFrame.Container, "TOPRIGHT", -E.Border, -130)

	PVPLadderFrame.Container.RightContainer.BottomContainer:StripTextures()

	PVPLadderFrame.Container.RightContainer.CentralContainer:StripTextures(true)

	S:HandleScrollBar(PVPLadderFrameContainerRightContainerCentralContainerScrollFrameScrollBar)
	S:SetNextPrevButtonDirection(PVPLadderFrameContainerRightContainerCentralContainerScrollFrameScrollBarScrollUpButton, "up")
	S:SetNextPrevButtonDirection(PVPLadderFrameContainerRightContainerCentralContainerScrollFrameScrollBarScrollDownButton, "down")
	S:HandleCheckBox(ConquestFrameBottomInsetRatedConquestRadioButton)
	S:HandleCheckBox(ConquestFrameBottomInsetSkirmishConquestRadioButton)

	PVPLadderFrame.Container.RightContainer.CentralContainer.ScrollFrame.ShadowOverlay:StripTextures()

	PVPLadderFrame.Container.RightContainer.TopContainer:StripTextures()
	PVPLadderFrame.Container.RightContainer.TopContainer.RegionMask.TextureMask:StripTextures()

	S:HandleEditBox(PVPLadderFrame.Container.RightContainer.TopContainer.SearchBox)
	S:HandleButton(PVPLadderFrame.Container.RightContainer.TopContainer.SearchButton)

	PVPLadderFrame.Container.RightContainer.TopContainer.TitleFrame:StripTextures()
	PVPLadderFrame.Container.RightContainer.TopContainer.ShadowOverlay:StripTextures()

	S:HandlePortraitFrame(PVPLadderInfoFrame)
	PVPLadderInfoFrame.CentralContainer:StripTextures()
	PVPLadderInfoFrame.CentralContainer.BackgroundOverlay:SetAlpha(0)
	S:HandleScrollBar(PVPLadderInfoFrame.CentralContainer.ScrollFrame.ScrollBar)
	PVPLadderInfoFrame.CentralContainer.ScrollFrame.ShadowOverlay:StripTextures()
	PVPLadderInfoFrame.TopContainer.ShadowOverlay:StripTextures()
	PVPLadderInfoFrame.TopContainer.StatisticsFrame:StripTextures()

	PVPLadderFrame:HookScript("OnShow", function(self)
		local buttons = self.Container.RightContainer.CentralContainer.ScrollFrame.buttons
		local childFrameLevel = self.Container.RightContainer.CentralContainer.ScrollFrame.ScrollChild:GetFrameLevel()
		if buttons[1]:GetFrameLevel() < childFrameLevel then
			for i = 1, #buttons do
				buttons[i]:SetFrameLevel(childFrameLevel + 1)
			end
		end
	end)

	S:HandlePortraitFrame(RenegadeLadderFrame)
	S:HandleCloseButton(RenegadeLadderFrameCloseButton)
	RenegadeLadderFrame:SetTemplate("Transparent")
	RenegadeLadderFrame.LeftInset:StripTextures()
	RenegadeLadderFrameArt:StripTextures()
	RenegadeLadderFrame.Shadows:StripTextures()

	for i = 1, RenegadeLadderFrame:GetNumChildren() do
		local child = select(i, RenegadeLadderFrame:GetChildren())
		if child and child:GetName() and find(child:GetName(), "Art") then
			child:StripTextures()
		end
	end

	for i = 1, 4 do
		S:HandleTab(_G["RenegadeLadderFrameTab"..i])
	end

	SkinCategoryButton(RenegadeLadderFrame.Container.CategoryButton1, 1)

	for i = 1, #RenegadeLadderFrame.kingFrames do
		local frame = RenegadeLadderFrame.kingFrames[i]
		frame.Background:SetAlpha(0)
		frame.Crown:Point("LEFT", 6, 0)
		S:HandleButton(frame)
	end

	for i = 1, 2 do
		local tab = RenegadeLadderFrame.Container["RightBigTab"..i]
		tab:SetTemplate()
		tab:StyleButton()
		tab:GetRegions():Hide()
		tab.Icon:SetTexCoord(unpack(E.TexCoords))
		tab.Icon:SetInside()
	end
	RenegadeLadderFrame.Container.RightBigTab1:Point("TOPLEFT", RenegadeLadderFrame.Container, "TOPRIGHT", -E.Border, -34)
	for i = 1, 10 do
		local tab = RenegadeLadderFrame.Container["RightSmallTab"..i]
		tab:SetTemplate()
		tab:StyleButton()
		tab:GetRegions():Hide()
		tab.Icon:SetTexCoord(unpack(E.TexCoords))
		tab.Icon:SetInside()
	end
	RenegadeLadderFrame.Container.RightSmallTab1:Point("TOPLEFT", RenegadeLadderFrame.Container, "TOPRIGHT", -E.Border, -130)

	RenegadeLadderFrame.Container.RightContainer.BottomContainer:StripTextures()
	RenegadeLadderFrame.Container.RightContainer.CentralContainer:StripTextures(true)
	RenegadeLadderFrame.Container.RightContainer.CentralContainer.ScrollFrame.ShadowOverlay:StripTextures()

	S:HandleScrollBar(RenegadeLadderFrameContainerRightContainerCentralContainerScrollFrameScrollBar)
	S:SetNextPrevButtonDirection(RenegadeLadderFrameContainerRightContainerCentralContainerScrollFrameScrollBarScrollUpButton, "up")
	S:SetNextPrevButtonDirection(RenegadeLadderFrameContainerRightContainerCentralContainerScrollFrameScrollBarScrollDownButton, "down")

	RenegadeLadderFrame.Container.RightContainer.TopContainer:StripTextures()
	RenegadeLadderFrame.Container.RightContainer.TopContainer.RegionMask.TextureMask:StripTextures()

	S:HandleEditBox(RenegadeLadderFrame.Container.RightContainer.TopContainer.SearchFrame.SearchBox)
	S:HandleButton(RenegadeLadderFrame.Container.RightContainer.TopContainer.SearchFrame.SearchButton)

	RenegadeLadderFrame.Container.RightContainer.TopContainer.TitleFrame:StripTextures()
	RenegadeLadderFrame.Container.RightContainer.TopContainer.ShadowOverlay:StripTextures()


	----------------- mini games frame

	MiniGamesParentFrame:HookScript("OnEvent",function(...) -------- first check
		updateMiniGames()
		end)
	MiniGamesParentFrame:HookScript("OnShow",function() -------- ye i now but its maxin
		for i = 1,5 do
			local but = _G["MiniGamesParentFrameTopInsetScrollFrameChildFramePoolFrameMiniGameButtonTemplate"..i]
			if but then
				but:HookScript("OnClick",updateMiniGames)
			end
		end

		updateMiniGames()
		
	end)

	MiniGameReadyDialog:HookScript("OnShow",function()
		MiniGameReadyDialog:StripTextures()
		MiniGameReadyDialog:CreateBackdrop("Transparent")
		S:HandleButton(MiniGameReadyDialogEnterButton)
		S:HandleButton(MiniGameReadyDialogLeaveQueueButton)
		S:HandleCloseButton(MiniGameReadyDialogCloseButton)
	
	end)

	MiniGameScoreFrame:HookScript("OnShow",function()
		MiniGameScoreFrame:StripTextures()
		MiniGameScoreFrameInset:StripTextures()
		MiniGameScoreFrame:CreateBackdrop("Transparent")
		MiniGameScoreFrameContentScrollFrame:StripTextures()
		MiniGameScoreFrameContentScrollFrame:CreateBackdrop("Transparent")
		S:HandleCloseButton(MiniGameScoreFrameCloseButton)
		S:HandleButton(MiniGameScoreFrameLeaveButton)
		S:HandleScrollBar(MiniGameScoreFrameContentScrollFrameScrollBar)
	
	end)
	MiniGameReadyStatus:HookScript("OnShow",function()
		MiniGameReadyStatus:StripTextures()
		MiniGameReadyStatus:CreateBackdrop("Transparent")
		S:HandleCloseButton(MiniGameReadyStatusCloseButton)
	end)
end

-- S:RemoveCallback("Skin_LFD")
S:AddCallback("Skin_LFD", LoadSkin)