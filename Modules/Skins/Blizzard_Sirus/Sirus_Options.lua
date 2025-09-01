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
		"InterfaceOptionsCombatPanelAssistModeCheckButton",
		"InterfaceOptionsSocialPanelAutoJoinToLFG",
		"InterfaceOptionsHelpPanelShowAchievementTooltip",
		"InterfaceOptionsNotificationPanelShowSocialToast",
		"InterfaceOptionsNotificationPanelBattlePassToast",
		"InterfaceOptionsNotificationPanelToggleMove",
		"InterfaceOptionsNotificationPanelAuctionHouseToast",
		"InterfaceOptionsNotificationPanelToastSound",
		"InterfaceOptionsNotificationPanelSocialToastSound",
		"InterfaceOptionsNotificationPanelHeadHuntingToastSound",
		"InterfaceOptionsNotificationPanelBattlePassToastSound",
		"InterfaceOptionsNotificationPanelQueueToastSound",
		"InterfaceOptionsNotificationPanelAuctionHouseToastSound",
		"InterfaceOptionsNotificationPanelFlashClientIcon",
		"InterfaceOptionsNotificationPanelShowToasts",
		"InterfaceOptionsNotificationPanelCallOfAdventureToast",
		"InterfaceOptionsNotificationPanelCallOfAdventureToastSound",
		"InterfaceOptionsNotificationPanelMiscToast",
		"InterfaceOptionsNotificationPanelMiscToastSound",
		"InterfaceOptionsHardcorePanelNotificationSound",
		"InterfaceOptionsCombatPanelActionButtonUseKeyDown",
	}
	for _, checkbox in ipairs(checkboxes) do
		checkbox = _G[checkbox]
		if checkbox then
			S:HandleCheckBox(checkbox)
		end
	end

	local sliders = {
		"SpellOverlay_SpellHighlightAlphaSlider",
		"SpellOverlay_OverlayArtAlphaSlider",
		"InterfaceOptionsNotificationPanelNumDisplayToastsSlider",
		"InterfaceOptionsCombatPanelLossOfControlScale",
		"InterfaceOptionsHardcorePanelNotificationScaleSlider",
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
		"InterfaceOptionsHardcorePanelNotificationTypeDropDown",
		"InterfaceOptionsHardcorePanelNotificationLevelDropDown",
	}
	for _, dropdown in ipairs(dropdowns) do
		dropdown = _G[dropdown]
		if dropdown then
			S:HandleDropDownBox(dropdown)
		end
	end
end
S:AddCallback("Sirus_Options", LoadSkin)
