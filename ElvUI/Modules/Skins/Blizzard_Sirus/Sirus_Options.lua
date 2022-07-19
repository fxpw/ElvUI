local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
-- local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.BlizzardOptions then return end

	--checkbox
	local checkboxes = {
	"InterfaceOptionsControlsPanelBlockGuildInvites",
	"InterfaceOptionsCombatPanelLossOfControll",
	"InterfaceOptionsSocialPanelAutoJoinToLFG",
	"InterfaceOptionsHelpPanelShowAchievementTooltip",
	"InterfaceOptionsNotificationPanelShowSocialToast",
	"InterfaceOptionsNotificationPanelBattlePassToast",
	"InterfaceOptionsNotificationPanelToggleMove",
	"InterfaceOptionsNotificationPanelAuctionHouseToast",
	}
	for _, checkbox in ipairs(checkboxes) do
		checkbox = _G[checkbox]
		if checkbox then
			S:HandleCheckBox(checkbox)
		end
	end
	--optframes
--		local optionFrames = {
--		
--		}
--		for _, frame in ipairs(optionFrames) do
--			frame = _G[frame]
--			if frame then
--				frame:StripTextures()
--				frame:CreateBackdrop("Transparent")
--
--				if frame == VideoOptionsFramePanelContainer or frame == InterfaceOptionsFramePanelContainer then
--					frame.backdrop:Point("TOPLEFT", 0, 0)
--					frame.backdrop:Point("BOTTOMRIGHT", 0, 0)
--				else
--					frame.backdrop:Point("TOPLEFT", -1, 0)
--					frame.backdrop:Point("BOTTOMRIGHT", 0, 1)
--				end
--			end
--		end
	--sliders
	local sliders = {
		"SpellOverlay_SpellHighlightAlphaSlider",
		"SpellOverlay_OverlayArtAlphaSlider",
		"InterfaceOptionsNotificationPanelNumDisplayToastsSlider",
		"InterfaceOptionsCombatPanelLossOfControlScale"
		}
	for _, slider in ipairs(sliders) do
		S:HandleSliderFrame(_G[slider])
	end
	--buttons
	local buttons = {
		"InterfaceOptionsNotificationPanelResetPosition",
		}
	for _, button in ipairs(buttons) do
		S:HandleButton(_G[button])
	end
	--dropdowns
	local dropdowns = {
		"InterfaceOptionsSocialPanelWhisperMode",
		"InterfaceOptionsStatusTextPanelDisplayDropDown",

		}
	for _, dropdown in ipairs(dropdowns) do
		dropdown = _G[dropdown]
		if dropdown then
			S:HandleDropDownBox(dropdown)
		end
	end
end
S:AddCallback("Sirus_Options", LoadSkin)