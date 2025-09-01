local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables
local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.hardcore then return end
	local HardcoreFrame = HardcoreFrame
	S:HandlePortraitFrame(HardcoreFrame)
	for i = 1, 3 do
		if _G["HardcoreFrameTab"..i] then
			local tab = _G["HardcoreFrameTab"..i]
			tab.HighlightLeft:StripTextures()
			tab.HighlightMiddle:StripTextures()
			tab.HighlightRight:StripTextures()
			S:HandleTab(tab)
		end
	end
	S:HandleButton(HardcoreFrameNavBarHomeButton)
	S:HandleButton(HardcoreFrameSuggestTab, true)
	S:HandleButton(HardcoreFrameChallengeListTab, true)
	S:HandleButton(HardcoreFrameParticipantsTab, true)
	S:HandleButton(HardcoreFrameLadderTab, true)
	S:HandleButton(HardcoreFrameSuggestFrameSuggestion2CenterDisplayButton)
	S:HandleButton(HardcoreFrameSuggestFrameSuggestion3CenterDisplayButton)
	HardcoreFrameNavBar:StripTextures()
	HardcoreFrameNavBarOverlay:StripTextures()
end

S:AddCallback("Sirus_Hardcore", LoadSkin)