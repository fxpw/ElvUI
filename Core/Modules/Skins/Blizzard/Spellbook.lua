local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local IsPassiveSpell = IsPassiveSpell

S:AddCallback('Skin_Spellbook', function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.spellbook then return end

	_G.SpellBookFrame:StripTextures(true)
	_G.SpellBookFrame:CreateBackdrop('Transparent')
	_G.SpellBookFrame.backdrop:Point('TOPLEFT', 11, -12)
	_G.SpellBookFrame.backdrop:Point('BOTTOMRIGHT', -32, 76)

	S:SetUIPanelWindowInfo(_G.SpellBookFrame, 'width', nil, E:IsHDPatch() and 50 or 31)
	S:SetBackdropHitRect(_G.SpellBookFrame)

	S:HandleNextPrevButton(_G.SpellBookPrevPageButton, nil, nil, true)
	S:HandleNextPrevButton(_G.SpellBookNextPageButton, nil, nil, true)

	_G.SpellBookPageText:ClearAllPoints()
	_G.SpellBookPageText:Point('RIGHT', _G.SpellBookPrevPageButton, 'LEFT', -5, -1)

	if E.private.skins.parchmentRemoverEnable then
		_G.SpellBookPageText:SetTextColor(0.6, 0.6, 0.6)
	else
		_G.SpellBookPageText:SetTextColor(1, 1, 1)
	end

	S:HandleCloseButton(_G.SpellBookFrameCloseButton or _G.SpellBookCloseButton, _G.SpellBookFrame.backdrop)

	S:HandleCheckBox(_G.ShowAllSpellRanksCheckBox)

	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		local autoCast = _G['SpellButton'..i..'AutoCastable']
		local cooldown = _G['SpellButton'..i..'Cooldown']
		local icon = _G['SpellButton'..i..'IconTexture']
		button:StripTextures()

		autoCast:SetTexture([[Interface\Buttons\UI-AutoCastableOverlay]])
		autoCast:SetOutside(button, 16, 16)

		button:CreateBackdrop('Default', true)

		icon:SetTexCoords()

		E:RegisterCooldown(cooldown)
	end

	hooksecurefunc('SpellButton_UpdateButton', function(self)
		local name = self:GetName()
		_G[name..'SpellName']:SetTextColor(1, 0.80, 0.10)
		_G[name..'SubSpellName']:SetTextColor(0.5, 0.5, 0.5)
		_G[name..'Highlight']:SetTexture(1, 1, 1, 0.3)
	end)

	for i = 1, _G.MAX_SKILLLINE_TABS do
		local tab = _G['SpellBookSkillLineTab'..i]

		tab:StripTextures()
		tab:StyleButton(nil, true)
		tab:SetTemplate('Default', true)

		tab:GetNormalTexture():SetInside()
		tab:GetNormalTexture():SetTexCoords()
	end

	_G.SpellBookSkillLineTab1:Point('TOPLEFT', '$parent', 'TOPRIGHT', -33, -46)

	-- Bottom Tabs
	for i = 1, 3 do
		local tab = _G['SpellBookFrameTabButton'..i]
		tab:Size(122, 32)
		tab:GetNormalTexture():SetTexture(nil)
		tab:GetDisabledTexture():SetTexture(nil)
		tab:GetRegions():SetPoint('CENTER', 0, 2)
		S:HandleTab(tab)
	end

	-- Reposition Tabs
	hooksecurefunc('SpellBookFrame_Update', function()
		local tab = _G.SpellBookFrameTabButton1
		local index, lastTab = 1, tab
		while tab do
			tab:ClearAllPoints()
			S:SetBackdropHitRect(tab)

			if index == 1 then
				tab:Point('TOPLEFT', _G.SpellBookFrame, 'BOTTOMLEFT', 10, 78)
			else
				tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -15.5, 0)
				lastTab = tab
			end

			index = index + 1
			tab = _G['SpellBookFrameTabButton'..index]
		end
	end)

	if E:IsHDPatch() then
		local spellFrame = _G.SpellBookFrame
		spellFrame:Height(spellFrame:GetHeight() + 85)

		_G.SpellButton1:PointXY(100, -80)
		_G.ShowAllSpellRanksCheckBox:PointXY(30, -30)
		_G.SpellBookPrevPageButton:PointXY(-95, 100)
		_G.SpellBookNextPageButton:PointXY(-60, 100)
		_G.SpellBookTitleText:PointXY(5, 280)
	end
end)