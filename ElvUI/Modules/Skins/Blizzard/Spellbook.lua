local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
--local SpellBook_GetCurrentPage = SpellBook_GetCurrentPage
--local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local MAX_SKILLLINE_TABS = MAX_SKILLLINE_TABS

-- S:AddCallback("Skin_Spellbook", function()
-- 	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.spellbook then return end

-- 	SpellBookFrame:StripTextures(true)
-- 	SpellBookFrame:CreateBackdrop("Transparent")
-- 	SpellBookFrame.backdrop:Point("TOPLEFT", 11, -12)
-- 	SpellBookFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

-- 	S:SetUIPanelWindowInfo(SpellBookFrame, "width", nil, 31)
-- 	S:SetBackdropHitRect(SpellBookFrame)

-- --[[
-- 	SpellBookFrame:EnableMouseWheel(true)
-- 	SpellBookFrame:SetScript("OnMouseWheel", function(_, value)
-- 		--do nothing if not on an appropriate book type
-- 		if SpellBookFrame.bookType ~= BOOKTYPE_SPELL then
-- 			return
-- 		end

-- 		local currentPage, maxPages = SpellBook_GetCurrentPage()

-- 		if value > 0 then
-- 			if currentPage > 1 then
-- 				SpellBookPrevPageButton_OnClick()
-- 			end
-- 		else
-- 			if currentPage < maxPages then
-- 				SpellBookNextPageButton_OnClick()
-- 			end
-- 		end
-- 	end)
-- ]]

-- 	for i = 1, 3 do
-- 		local tab = _G["SpellBookFrameTabButton"..i]
-- 		tab:Size(122, 32)
-- 		tab:GetNormalTexture():SetTexture(nil)
-- 		tab:GetDisabledTexture():SetTexture(nil)
-- 		tab:GetRegions():SetPoint("CENTER", 0, 2)
-- 		S:HandleTab(tab)
-- 	end

-- 	SpellBookFrameTabButton1:Point("CENTER", SpellBookFrame, "BOTTOMLEFT", 72, 62)
-- 	SpellBookFrameTabButton2:Point("LEFT", SpellBookFrameTabButton1, "RIGHT", -15, 0)
-- 	SpellBookFrameTabButton3:Point("LEFT", SpellBookFrameTabButton2, "RIGHT", -15, 0)

-- 	S:HandleNextPrevButton(SpellBookPrevPageButton, nil, nil, true)
-- 	S:HandleNextPrevButton(SpellBookNextPageButton, nil, nil, true)

-- 	S:HandleCloseButton(SpellBookCloseButton, SpellBookFrame.backdrop)

-- 	S:HandleCheckBox(ShowAllSpellRanksCheckBox)

-- 	for i = 1, SPELLS_PER_PAGE do
-- 		local button = _G["SpellButton"..i]
-- 		local autoCast = _G["SpellButton"..i.."AutoCastable"]
-- 		button:StripTextures()

-- 		autoCast:SetTexture("Interface\\Buttons\\UI-AutoCastableOverlay")
-- 		autoCast:SetOutside(button, 16, 16)

-- 		button:CreateBackdrop("Default", true)

-- 		_G["SpellButton"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))

-- 		E:RegisterCooldown(_G["SpellButton"..i.."Cooldown"])
-- 	end

-- 	hooksecurefunc("SpellButton_UpdateButton", function(self)
-- 		local name = self:GetName()
-- 		_G[name.."SpellName"]:SetTextColor(1, 0.80, 0.10)
-- 		_G[name.."SubSpellName"]:SetTextColor(1, 1, 1)
-- 		_G[name.."Highlight"]:SetTexture(1, 1, 1, 0.3)
-- 	end)

-- 	for i = 1, MAX_SKILLLINE_TABS do
-- 		local tab = _G["SpellBookSkillLineTab"..i]

-- 		tab:StripTextures()
-- 		tab:StyleButton(nil, true)
-- 		tab:SetTemplate("Default", true)

-- 		tab:GetNormalTexture():SetInside()
-- 		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
-- 	end

-- 	SpellBookSkillLineTab1:Point("TOPLEFT", SpellBookFrame, "TOPRIGHT", -33, -65)

-- 	SpellBookPageText:SetTextColor(1, 1, 1)
-- end)

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
			_G["SpellButton"..i.."Highlight"]:SetTexture(1, 1, 1, 0.3)
		end
	end)

	for i = 1, 8 do
		local button = _G["SpellBookSkillLineTab"..i]
		button:GetRegions():SetAlpha(0)
		button:SetTemplate()
		button:StyleButton(nil, true)

		button:GetNormalTexture():SetInside()
		button:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
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
end

-- S:RemoveCallback("Skin_Spellbook")
S:AddCallback("Skin_Spellbook", LoadSkin)