local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs = ipairs
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect then return end

	S:HandlePortraitFrame(InspectFrame)

	for i = 1, 4 do
		S:HandleTab(_G["InspectFrameTab"..i])
	end

	-- InspectPaperDollFrame
	InspectLevelText:SetPoint("TOP", 0, -20)

	S:HandleButton(InspectPaperDollFrame.ViewButton)

	InspectModelFrame:CreateBackdrop()
	InspectModelFrame.backdrop:SetOutside(InspectModelFrameBackgroundOverlay)
	InspectModelFrame:DisableDrawLayer("OVERLAY")

	S:HandleControlFrame(InspectModelFrame.controlFrame)

	local slots = {
		InspectHeadSlot,
		InspectNeckSlot,
		InspectShoulderSlot,
		InspectBackSlot,
		InspectChestSlot,
		InspectShirtSlot,
		InspectTabardSlot,
		InspectWristSlot,
		InspectHandsSlot,
		InspectWaistSlot,
		InspectLegsSlot,
		InspectFeetSlot,
		InspectFinger0Slot,
		InspectFinger1Slot,
		InspectTrinket0Slot,
		InspectTrinket1Slot,
		InspectMainHandSlot,
		InspectSecondaryHandSlot,
		InspectRangedSlot
	}

	for _, slot in ipairs(slots) do
		slot:StripTextures()
		slot:SetTemplate()
		slot:StyleButton()

		slot.icon:SetTexCoord(unpack(E.TexCoords))
		slot.icon:SetInside()

		hooksecurefunc(slot.IconBorder, "SetVertexColor", function(_, r, g, b) slot:SetBackdropBorderColor(r, g, b) end)
		hooksecurefunc(slot.IconBorder, "Hide", function() slot:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	end

	-- InspectPVPFrame
	for i = 1, 3 do
		_G["InspectPVPFrameTab"..i]:StripTextures()
	end

	InspectPVPFrame.Service.Inset:StripTextures()

	InspectPVPFrame.Rating.Inset:StripTextures()
	InspectPVPFrame.Rating.Container.Background:SetAlpha(0)

	for i = 1, 3 do
		_G["InspectPVPTeam"..i]:StripTextures()
		_G["InspectPVPTeam"..i]:SetTemplate()
	end

	InspectPVPFrame.Statistics.Inset:StripTextures()

	InspectBattlegroundStatisticsScrollFrameScrollBar:StripTextures()
	S:HandleScrollBar(InspectBattlegroundStatisticsScrollFrameScrollBar)

	InspectBattlegroundStatisticsScrollFrame:HookScript("OnShow", function()
		for i = 1, #InspectBattlegroundStatisticsScrollFrame.buttons do
			local button = InspectBattlegroundStatisticsScrollFrame.buttons[i]
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

	InspectPVPFrame.Ladder.CentralContainer:StripTextures()
	InspectPVPFrame.Ladder.CentralContainer.BackgroundOverlay:SetAlpha(0)

	S:HandleScrollBar(InspectPVPFrameLadderCentralContainerScrollFrameScrollBar)

	InspectPVPFrame.Ladder.CentralContainer.ScrollFrame.ShadowOverlay:StripTextures()

	InspectPVPFrame.Ladder.TopContainer.StatisticsFrame:StripTextures()

	for i = 1, 4 do
		local tab = InspectPVPFrame.Ladder["RightTab"..i]
		tab:SetTemplate()
		tab:StyleButton()
		tab:GetRegions():Hide()
		tab.Icon:SetTexCoord(unpack(E.TexCoords))
		tab.Icon:SetInside()
	end

	S:HandleButton(InspectPVPFrameToggleStatisticsButton, true)

	-- InspectTalentFrame
	for i = 1, 3 do
		_G["InspectTalentFrameTab"..i]:StripTextures()
	end

	InspectTalentFramePointsBar:StripTextures()

	InspectTalentFrameScrollFrame:StripTextures()
	S:HandleScrollBar(InspectTalentFrameScrollFrameScrollBar)

	for i = 1, 40 do
		local talent = _G["InspectTalentFrameTalent"..i]
		talent:StripTextures()
		talent:SetTemplate("Default")
		talent:StyleButton()

		talent.icon:SetInside()
		talent.icon:SetTexCoord(unpack(E.TexCoords))
		talent.icon:SetDrawLayer("ARTWORK")

		talent.Rank:FontTemplate()
	end

	-- InspectGuildFrame
	InspectGuildFrameBG:SetAlpha(0)
end

S:AddCallback("Sirus_Inspect", LoadSkin)