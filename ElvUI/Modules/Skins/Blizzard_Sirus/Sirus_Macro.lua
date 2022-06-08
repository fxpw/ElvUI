local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.macro ~= true then return end

	S:HandlePortraitFrame(MacroFrame)
	MacroFrameInset:StripTextures()
	MacroFrame.Art:StripTextures()

	S:HandleScrollBar(MacroButtonScrollFrameScrollBar)
	S:HandleScrollBar(MacroFrameScrollFrameScrollBar)
	S:HandleScrollBar(MacroPopupScrollFrameScrollBar)

	local Buttons = { "MacroFrameTab1", "MacroFrameTab2", "MacroDeleteButton", "MacroNewButton", "MacroExitButton", "MacroEditButton", "MacroPopupOkayButton", "MacroPopupCancelButton" }
	for i = 1, #Buttons do
		_G[Buttons[i]]:StripTextures()
		S:HandleButton(_G[Buttons[i]])
	end

	for i = 1, 2 do
		local tab = _G["MacroFrameTab"..i]
		tab:Height(22)
	end

	MacroFrameTab2:Point("LEFT", MacroFrameTab1, "RIGHT", 4, 0)

	MacroFrameTextBackground:StripTextures()
	MacroFrameTextBackground:CreateBackdrop("Default")
	MacroFrameTextBackground.backdrop:Point("TOPLEFT", 6, -3)
	MacroFrameTextBackground.backdrop:Point("BOTTOMRIGHT", -2, 3)

	MacroButtonScrollFrame:StripTextures()
	MacroButtonScrollFrame:CreateBackdrop()

	S:HandleScrollBar(MacroButtonScrollFrame)

	MacroEditButton:ClearAllPoints()
	MacroEditButton:Point("BOTTOMLEFT", MacroFrameSelectedMacroButton, "BOTTOMRIGHT", 10, 0)

	MacroFrameSelectedMacroButton:StripTextures()
	MacroFrameSelectedMacroButton:StyleButton(nil, true)
	MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture(nil)
	MacroFrameSelectedMacroButton:SetTemplate("Default")
	MacroFrameSelectedMacroButtonIcon:SetTexCoord(unpack(E.TexCoords))
	MacroFrameSelectedMacroButtonIcon:SetInside()

	for i = 1, MAX_ACCOUNT_MACROS do
		local Button = _G["MacroButton"..i]
		local ButtonIcon = _G["MacroButton"..i.."Icon"]

		if Button then
			Button:StripTextures()
			Button:StyleButton(nil, true)

			Button:SetTemplate("Default", true)
		end

		if ButtonIcon then
			ButtonIcon:SetTexCoord(unpack(E.TexCoords))
			ButtonIcon:SetInside()
		end
	end

	S:HandleIconSelectionFrame(MacroPopupFrame, NUM_MACRO_ICONS_SHOWN, "MacroPopupButton", "MacroPopup")
	MacroPopupFrame.BorderBox:StripTextures()
	S:HandleEditBox(MacroPopupSearchBox)
end

S:AddCallback("Sirus_Macro", LoadSkin)