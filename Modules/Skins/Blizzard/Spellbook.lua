local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.spellbook then return end

	S:HandlePortraitFrame(SpellBookFrame)
	SpellBookPage1:SetAlpha(0)
	SpellBookPage2:SetAlpha(0)

	for i = 1, 5 do
		local tab = _G["SpellBookFrameTabButton"..i]
		tab:StripTextures()
		S:HandleTab(tab)
		tab.backdrop:Point("TOPLEFT", 12, E.PixelMode and -17 or -19)
		tab.backdrop:Point("BOTTOMRIGHT", -12, 19)
	end

	S:HandleCheckBox(ShowAllSpellRanksCheckBox)
	S:HandleCheckBox(ShowUnassignedSpellBorderCheckBox)
	ShowUnassignedSpellBorderCheckBox:SetPoint("BOTTOMLEFT", 95, 28)

	S:HandleEditBox(SpellBookSearchBox)

	SpellBookPageText:SetTextColor(1, 1, 1)
	SpellBookPageText:SetPoint("BOTTOMRIGHT", -110, 36)
	S:HandleNextPrevButton(SpellBookPrevPageButton, nil, nil, true)
	SpellBookPrevPageButton:Size(32)
	S:HandleNextPrevButton(SpellBookNextPageButton, nil, nil, true)
	SpellBookNextPageButton:Size(32)

	for i = 1, 12 do
		local button = _G["SpellButton"..i]
		local autoCast = _G["SpellButton"..i.."AutocastAutoCastable"]
		button:StripTextures()
		button:CreateBackdrop("Default", true)

		autoCast:SetOutside(button, 16, 16)

		_G["SpellButton"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))

		E:RegisterCooldown(_G["SpellButton"..i.."Cooldown"])
	end

	hooksecurefunc("SpellButton_UpdateButton", function()
		for i = 1, 12 do
			_G["SpellButton"..i.."SpellName"]:SetTextColor(1, 0.80, 0.10)
			_G["SpellButton"..i.."SubSpellName"]:SetTextColor(1, 1, 1)
			_G["SpellButton"..i.."RequiredLevelString"]:SetTextColor(1, 1, 1)
			_G["SpellButton"..i.."Highlight"]:SetTexture(1, 1, 1, 0.3)
		end
	end)
	local nt
	for i = 1, 10 do
		local button = _G["SpellBookSkillLineTab"..i]
		if button then
			button:GetRegions():SetAlpha(0)
			button:SetTemplate()
			button:StyleButton(nil, true)
			nt = button:GetNormalTexture()
			if nt then
				nt:SetInside()
				nt:SetTexCoord(unpack(E.TexCoords))
			end
		end
		-- button:GetNormalTexture():SetInside()
		-- button:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	end

	-- SpellBookCompanionsFrame
	SpellBookCompanionsModelFrame:SetAlpha(0)
	SpellBookCompanionModelFrame:CreateBackdrop("Transparent")
	SpellBookCompanionModelFrameShadowOverlay:SetAlpha(0)

	S:HandleRotateButton(SpellBookCompanionModelFrameRotateLeftButton)
	S:HandleRotateButton(SpellBookCompanionModelFrameRotateRightButton)
	SpellBookCompanionModelFrameRotateRightButton:SetPoint("TOPLEFT", SpellBookCompanionModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	S:HandleButton(SpellBookCompanionSummonButton)

	for i = 1, 12 do
		local button = _G["SpellBookCompanionButton"..i]
		button:StripTextures()
		button:SetTemplate()
		button:StyleButton()

		button.IconTexture:SetInside()
		button.IconTexture:SetTexCoord(unpack(E.TexCoords))
	end

	-- SpellBookProfessionFrame
	local function SkinProfessionButton(button)
		button:StripTextures()
		button:SetTemplate()
		button:StyleButton()

		button.iconTexture:SetInside()
		button.iconTexture:SetTexCoord(unpack(E.TexCoords))
	end

	local function StatusBarColor(self, value)
		local _, maxValue = self:GetMinMaxValues()
		S:StatusBarColorGradient(self, value, maxValue)
	end

	for i = 1, 4 do
		local prof = _G["PrimaryProfession"..i]
		prof.Missing.missingText:SetTextColor(1, 1, 1)

		SkinProfessionButton(prof.Learn.button2)
		SkinProfessionButton(prof.Learn.button1)


		prof.Learn.statusBar:StripTextures()
		prof.Learn.statusBar:Size(188, 12)
		prof.Learn.statusBar:CreateBackdrop()
		prof.Learn.statusBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(prof.Learn.statusBar)
		prof.Learn.statusBar.rankText:SetPoint("CENTER")
		hooksecurefunc(prof.Learn.statusBar, "SetValue", StatusBarColor)
	end

	for i = 1, 3 do
		local prof = _G["SecondaryProfession"..i]
		prof.Missing.missingText:SetTextColor(1, 1, 1)

		SkinProfessionButton(prof.Learn.button1)
		SkinProfessionButton(prof.Learn.button2)

		prof.Learn.statusBar:StripTextures()
		prof.Learn.statusBar:Size(123, 12)
		prof.Learn.statusBar:Point("TOPLEFT", prof.Learn.rank, "BOTTOMLEFT", 2, -5)
		prof.Learn.statusBar:CreateBackdrop()
		prof.Learn.statusBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(prof.Learn.statusBar)
		prof.Learn.statusBar.rankText:SetPoint("CENTER")
		hooksecurefunc(prof.Learn.statusBar, "SetValue", StatusBarColor)
	end
	-- local _HookFunc = PrimaryProfession_Update
	-- function PrimaryProfession_Update()
	-- 	if not InCombatLockdown() then
	-- 		_HookFunc()
	-- 	end
	-- end
end

-- S:RemoveCallback("Skin_Spellbook")
S:AddCallback("Skin_Spellbook", LoadSkin)