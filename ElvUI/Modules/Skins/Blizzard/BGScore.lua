local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local format, split = string.format, string.split
--WoW API / Variables
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetBattlefieldScore = GetBattlefieldScore
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- S:AddCallback("Skin_WorldStateScore", function()
-- 	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bgscore then return end

-- 	WorldStateScoreFrame:StripTextures()
-- 	WorldStateScoreFrame:CreateBackdrop("Transparent")
-- 	WorldStateScoreFrame.backdrop:Point("TOPLEFT", 10, -15)
-- 	WorldStateScoreFrame.backdrop:Point("BOTTOMRIGHT", -113, 67)

-- 	WorldStateScoreFrame:EnableMouse(true)
-- 	S:SetBackdropHitRect(WorldStateScoreFrame)

-- 	S:HandleCloseButton(WorldStateScoreFrameCloseButton, WorldStateScoreFrame.backdrop)

-- 	WorldStateScoreScrollFrame:StripTextures()
-- 	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar)

-- 	WorldStateScoreFrameKB:StyleButton()
-- 	WorldStateScoreFrameDeaths:StyleButton()
-- 	WorldStateScoreFrameHK:StyleButton()
-- 	WorldStateScoreFrameDamageDone:StyleButton()
-- 	WorldStateScoreFrameHealingDone:StyleButton()
-- 	WorldStateScoreFrameHonorGained:StyleButton()
-- 	WorldStateScoreFrameName:StyleButton()
-- 	WorldStateScoreFrameClass:StyleButton()
-- 	WorldStateScoreFrameTeam:StyleButton()
-- --	WorldStateScoreFrameRatingChange:StyleButton()

-- 	S:HandleButton(WorldStateScoreFrameLeaveButton)

-- 	for i = 1, 3 do
-- 		S:HandleTab(_G["WorldStateScoreFrameTab"..i])
-- 		_G["WorldStateScoreFrameTab"..i.."Text"]:Point("CENTER", 0, 2)
-- 	end

-- 	WorldStateScoreFrameTab2:Point("LEFT", WorldStateScoreFrameTab1, "RIGHT", -15, 0)
-- 	WorldStateScoreFrameTab3:Point("LEFT", WorldStateScoreFrameTab2, "RIGHT", -15, 0)

-- 	WorldStateScoreScrollFrameScrollBar:Point("TOPLEFT", WorldStateScoreScrollFrame, "TOPRIGHT", 8, -21)
-- 	WorldStateScoreScrollFrameScrollBar:Point("BOTTOMLEFT", WorldStateScoreScrollFrame, "BOTTOMRIGHT", 8, 38)

-- 	for i = 1, 5 do
-- 		_G["WorldStateScoreColumn"..i]:StyleButton()
-- 	end

-- 	local myName = format("> %s <", E.myname)

-- 	hooksecurefunc("WorldStateScoreFrame_Update", function()
-- 		local inArena = IsActiveBattlefieldArena()
-- 		local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)

-- 		local _, name, faction, classToken, realm, classTextColor, nameText

-- 		for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
-- 			name, _, _, _, _, faction, _, _, _, classToken = GetBattlefieldScore(offset + i)

-- 			if name then
-- 				name, realm = split("-", name, 2)

-- 				if name == E.myname then
-- 					name = myName
-- 				end

-- 				if realm then
-- 					local color

-- 					if inArena then
-- 						if faction == 1 then
-- 							color = "|cffffd100"
-- 						else
-- 							color = "|cff19ff19"
-- 						end
-- 					else
-- 						if faction == 1 then
-- 							color = "|cff00adf0"
-- 						else
-- 							color = "|cffff1919"
-- 						end
-- 					end

-- 					name = format("%s|cffffffff - |r%s%s|r", name, color, realm)
-- 				end

-- 				classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken] or RAID_CLASS_COLORS[classToken]

-- 				nameText = _G["WorldStateScoreButton"..i.."NameText"]
-- 				nameText:SetText(name)
-- 				nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
-- 			end
-- 		end
-- 	end)
-- end)

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgscore ~= true then return; end

	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:SetTemplate("Transparent")

	BattlegroundBalanceProgressBar:CreateBackdrop()
	BattlegroundBalanceProgressBar.backdrop:SetOutside(BattlegroundBalanceProgressBar.Alliance, nil, nil, BattlegroundBalanceProgressBar.Horde)
	BattlegroundBalanceProgressBar.Border:SetAlpha(0)

	WorldStateScoreFrame.Container.FactionGlow:SetPoint("TOPLEFT", 1, 12)
	WorldStateScoreFrame.Container.Separator:SetAlpha(0)
	WorldStateScoreFrame.Container.Bg:SetAlpha(0)
	WorldStateScoreFrame.Container.TopRightCorner:SetAlpha(0)
	WorldStateScoreFrame.Container.TopLeftCorner:SetAlpha(0)
	WorldStateScoreFrame.Container.TopBorder:SetAlpha(0)
	WorldStateScoreFrame.Container.BotLeftCorner:SetAlpha(0)
	WorldStateScoreFrame.Container.BotRightCorner:SetAlpha(0)
	WorldStateScoreFrame.Container.BottomBorder:SetAlpha(0)
	WorldStateScoreFrame.Container.LeftBorder:SetAlpha(0)
	WorldStateScoreFrame.Container.RightBorder:SetAlpha(0)
	WorldStateScoreFrame.Container.Inset:StripTextures()

	WorldStateScoreScrollFrame:StripTextures()
	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar)

	S:HandleCloseButton(WorldStateScoreFrameCloseButton)

	for i = 1, 3 do
		S:HandleTab(_G["WorldStateScoreFrameTab"..i])
	end

	S:HandleButton(WorldStateScoreFrameLeaveButton)

	WorldStateScoreFrame.EfficiencyFrame.EfficiencyBar:CreateBackdrop()
	WorldStateScoreFrame.EfficiencyFrame.EfficiencyBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(WorldStateScoreFrame.EfficiencyFrame.EfficiencyBar)
	WorldStateScoreFrame.EfficiencyFrame.EfficiencyBar.Border:SetAlpha(0)

	WorldStateScoreFrame.EfficiencyFrame.EfficiencyBar:HookScript("OnValueChanged", function(self, value)
		local r, g, b = E:ColorGradient(value, .65,0,0, .65,.65,0, 0,.65,0)
		self:SetStatusBarColor(r, g, b)
		self.Background:SetTexture(r * 0.25, g * 0.25, b * 0.25)
	end)
end

-- S:RemoveCallback("Skin_WorldStateScore")
S:AddCallback("Skin_WorldStateScore", LoadSkin)