local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars")

--Lua functions
local _G = _G
local unpack = unpack
-- local gsub, match = string.gsub, string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver

local MICRO_BUTTONS = SHARED_MICROMENU_BUTTONS
local set_atlas;
do
	local uimicromenu2x = [[Interface\AddOns\ElvUI\Media\Textures\uimicromenu2x]];
	local atlasinfo = {
		['ui-hud-micromenu-achievement-disabled-2x'] = { uimicromenu2x, nil, nil, 201 / 256, 239 / 256, 109 / 512, 161 / 512 },
		['ui-hud-micromenu-achievement-down-2x'] = { uimicromenu2x, nil, nil, 161 / 256, 199 / 256, 55 / 512, 107 / 512 },
		['ui-hud-micromenu-achievement-mouseover-2x'] = { uimicromenu2x, nil, nil, 201 / 256, 239 / 256, 55 / 512, 107 / 512 },
		['ui-hud-micromenu-achievement-up-2x'] = { uimicromenu2x, nil, nil, 161 / 256, 199 / 256, 109 / 512, 161 / 512 },
		['ui-hud-micromenu-pvp-disabled-2x'] = { uimicromenu2x, nil, nil, 81 / 256, 119 / 256, 163 / 512, 215 / 512 },
		['ui-hud-micromenu-pvp-down-2x'] = { uimicromenu2x, nil, nil, 201 / 256, 239 / 256, 163 / 512, 215 / 512 },
		['ui-hud-micromenu-pvp-mouseover-2x'] = { uimicromenu2x, nil, nil, 161 / 256, 199 / 256, 163 / 512, 215 / 512 },
		['ui-hud-micromenu-pvp-up-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 271 / 512, 323 / 512 },
		['ui-hud-micromenu-character-disabled-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 217 / 512, 269 / 512 },
		['ui-hud-micromenu-character-down-2x'] = { uimicromenu2x, nil, nil, 121 / 256, 159 / 256, 163 / 512, 215 / 512 },
		['ui-hud-micromenu-character-mouseover-2x'] = { uimicromenu2x, nil, nil, 81 / 256, 119 / 256, 217 / 512, 269 / 512 },
		['ui-hud-micromenu-character-up-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 325 / 512, 377 / 512 },
		['ui-hud-micromenu-collections-disabled-2x'] = { uimicromenu2x, nil, nil, 121 / 256, 159 / 256, 1 / 512, 53 / 512 },
		['ui-hud-micromenu-collections-down-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 379 / 512, 431 / 512 },
		['ui-hud-micromenu-collections-mouseover-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 433 / 512, 485 / 512 },
		['ui-hud-micromenu-collections-up-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 163 / 512, 215 / 512 },
		-- ['ui-hud-micromenu-communities-icon-notification-2x'] = { uimicromenu2x, nil, nil, 1/256, 21/256, 487/512, 509/512 },
		['ui-hud-micromenu-mainmenu-disabled-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 217 / 512, 269 / 512 },
		['ui-hud-micromenu-mainmenu-down-2x'] = { uimicromenu2x, nil, nil, 121 / 256, 159 / 256, 217 / 512, 269 / 512 },
		['ui-hud-micromenu-mainmenu-mouseover-2x'] = { uimicromenu2x, nil, nil, 161 / 256, 199 / 256, 217 / 512, 269 / 512 },
		['ui-hud-micromenu-mainmenu-up-2x'] = { uimicromenu2x, nil, nil, 201 / 256, 239 / 256, 217 / 512, 269 / 512 },
		['ui-hud-micromenu-lfd-disabled-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 271 / 512, 323 / 512 },
		['ui-hud-micromenu-lfd-down-2x'] = { uimicromenu2x, nil, nil, 81 / 256, 119 / 256, 109 / 512, 161 / 512 },
		['ui-hud-micromenu-lfd-mouseover-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 109 / 512, 161 / 512 },
		['ui-hud-micromenu-lfd-up-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 163 / 512, 215 / 512 },
		['ui-hud-micromenu-socials-disabled-2x'] = { uimicromenu2x, nil, nil, 201 / 256, 239 / 256, 1 / 512, 53 / 512 },
		['ui-hud-micromenu-socials-down-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 1 / 512, 53 / 512 },
		['ui-hud-micromenu-socials-mouseover-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 1 / 512, 53 / 512 },
		['ui-hud-micromenu-socials-up-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 55 / 512, 107 / 512 },
		['ui-hud-micromenu-guild-disabled-2x'] = { uimicromenu2x, nil, nil, 201 / 256, 239 / 256, 1 / 512, 53 / 512 },
		['ui-hud-micromenu-guild-down-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 1 / 512, 53 / 512 },
		['ui-hud-micromenu-guild-mouseover-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 1 / 512, 53 / 512 },
		['ui-hud-micromenu-guild-up-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 55 / 512, 107 / 512 },
		['ui-hud-micromenu-encounterjournal-disabled-2x'] = { uimicromenu2x, nil, nil, 39 / 256, 1 / 256, 55 / 512, 107 / 512 },
		['ui-hud-micromenu-encounterjournal-down-2x'] = { uimicromenu2x, nil, nil, 119 / 256, 81 / 256, 433 / 512, 485 / 512 },
		['ui-hud-micromenu-encounterjournal-mouseover-2x'] = { uimicromenu2x, nil, nil, 227 / 256, 189 / 256, 433 / 512, 485 / 512 },
		['ui-hud-micromenu-encounterjournal-up-2x'] = { uimicromenu2x, nil, nil, 159 / 256, 121 / 256, 55 / 512, 107 / 512 },
		-- ['ui-hud-micromenu-highlightalert-2x'] = { uimicromenu2x, nil, nil, 121/256, 187/256, 379/512, 459/512 },
		['ui-hud-micromenu-questlog-disabled-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 379 / 512, 431 / 512 },
		['ui-hud-micromenu-questlog-down-2x'] = { uimicromenu2x, nil, nil, 121 / 256, 159 / 256, 271 / 512, 323 / 512 },
		['ui-hud-micromenu-questlog-mouseover-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 433 / 512, 485 / 512 },
		['ui-hud-micromenu-questlog-up-2x'] = { uimicromenu2x, nil, nil, 201 / 256, 239 / 256, 271 / 512, 323 / 512 },
		['ui-hud-micromenu-store-disabled-2x'] = { uimicromenu2x, nil, nil, 41 / 256, 79 / 256, 325 / 512, 377 / 512 },
		['ui-hud-micromenu-store-mouseover-2x'] = { uimicromenu2x, nil, nil, 121 / 256, 159 / 256, 325 / 512, 377 / 512 },
		['ui-hud-micromenu-store-down-2x'] = { uimicromenu2x, nil, nil, 161 / 256, 199 / 256, 271 / 512, 323 / 512 },
		['ui-hud-micromenu-store-up-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 109 / 512, 161 / 512 },
		['ui-hud-micromenu-talent-disabled-2x'] = { uimicromenu2x, nil, nil, 81 / 256, 119 / 256, 55 / 512, 107 / 512 },
		['ui-hud-micromenu-talent-down-2x'] = { uimicromenu2x, nil, nil, 81 / 256, 119 / 256, 271 / 512, 323 / 512 },
		['ui-hud-micromenu-talent-mouseover-2x'] = { uimicromenu2x, nil, nil, 81 / 256, 119 / 256, 1 / 512, 53 / 512 },
		['ui-hud-micromenu-talent-up-2x'] = { uimicromenu2x, nil, nil, 161 / 256, 199 / 256, 1 / 512, 53 / 512 },
		['ui-hud-micromenu-spellbook-disabled-2x'] = { uimicromenu2x, nil, nil, 1 / 256, 39 / 256, 55 / 512, 107 / 512 },
		['ui-hud-micromenu-spellbook-down-2x'] = { uimicromenu2x, nil, nil, 81 / 256, 119 / 256, 433 / 512, 485 / 512 },
		['ui-hud-micromenu-spellbook-mouseover-2x'] = { uimicromenu2x, nil, nil, 189 / 256, 227 / 256, 433 / 512, 485 / 512 },
		['ui-hud-micromenu-spellbook-up-2x'] = { uimicromenu2x, nil, nil, 121 / 256, 159 / 256, 55 / 512, 107 / 512 }
	}
	local function atlas_unpack(atlas)
		assert(atlasinfo[atlas], 'Atlas [' .. atlas .. ']: failed to unpack')
		return unpack(atlasinfo[atlas])
	end
	function set_atlas(self, atlas, size)
		if not atlas then
			self:SetTexture(nil)
			return
		end

		local origWidth, origHeight = self:GetSize()
		local tex, width, height, left, right, top, bottom, horizTile, vertTile = atlas_unpack(atlas)

		self:SetTexture(tex)
		self:SetTexCoord(left, right, top, bottom)
		self:SetHorizTile(horizTile or false)
		self:SetVertTile(vertTile or false)

		if size then
			self:SetWidth(width)
			self:SetHeight(height)
		else
			self:SetWidth(origWidth)
			self:SetHeight(origHeight)
		end
	end
end
-- if E.private.actionbar.enable then
-- 	for _, frame in pairs({"ShapeshiftBarFrame", "PossessBarFrame", "PETACTIONBAR_YPOS", "MULTICASTACTIONBAR_YPOS", "MultiBarBottomLeft", "MultiCastActionBarFrame"}) do
-- 		if UIPARENT_MANAGED_FRAME_POSITIONS[frame] then
-- 			UIPARENT_MANAGED_FRAME_POSITIONS[frame].ignoreFramePositionManager = true
-- 		end
-- 	end
-- end

local function onEnter(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeIn(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha)
	end

	if button and button ~= ElvUI_MicroBar and button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end
end

local function onLeave(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), 0)
	end

	if button and button ~= ElvUI_MicroBar and button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function UpdateDFTextures(button)
	local buttonName = button:GetName():gsub('MicroButton', '')
	local name = strlower(buttonName);
	button:StripTextures()
	set_atlas(button:GetHighlightTexture(), 'ui-hud-micromenu-' .. name .. '-mouseover-2x')
	button:GetHighlightTexture():SetBlendMode('ADD')
	set_atlas(button:GetNormalTexture(), 'ui-hud-micromenu-' .. name .. '-up-2x')
	set_atlas(button:GetPushedTexture(), 'ui-hud-micromenu-' .. name .. '-down-2x')
	if button:GetDisabledTexture() then
		set_atlas(button:GetDisabledTexture(), 'ui-hud-micromenu-' .. name .. '-disabled-2x')
	end
end

function AB:HandleMicroButton(button)
	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	button:SetParent(ElvUI_MicroBar)
	button:HookScript("OnEnter", onEnter)
	button:HookScript("OnLeave", onLeave)
	button:SetHitRectInsets(0, 0, 0, 0)

	if self.db.microbar.dfskin then
		UpdateDFTextures(button)
	else
		local f = CreateFrame("Frame", nil, button)
		f:SetFrameLevel(button:GetFrameLevel() - 1)
		f:SetTemplate("Default", true)
		f:SetOutside(button)
		button.backdrop = f
		button:GetHighlightTexture():Kill()
		pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		pushed:SetInside(f)
		normal:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		normal:SetInside(f)
		if disabled then
			disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908)
			disabled:SetInside(f)
		end
	end

	if button.Flash then
		button.Flash:Kill()
	end
end

function AB:UpdateMicroButtonsParent()
	if CharacterMicroButton:GetParent() == ElvUI_MicroBar then return end

	for i = 1, #MICRO_BUTTONS do
		_G[MICRO_BUTTONS[i]]:SetParent(ElvUI_MicroBar)
	end
end

function AB:UpdateMicroBarVisibility()
	if InCombatLockdown() then
		AB.NeedsUpdateMicroBarVisibility = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local visibility = self.db.microbar.visibility
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]", "")
	end

	RegisterStateDriver(ElvUI_MicroBar.visibility, "visibility", (self.db.microbar.enabled and visibility) or "hide")
end

function AB:UpdateMicroPositionDimensions()
	if not ElvUI_MicroBar then return end

	local numRows = 1
	local prevButton = ElvUI_MicroBar
	local offset = E:Scale(E.PixelMode and 1 or 3)
	local spacing = E:Scale(offset + self.db.microbar.buttonSpacing)

	for i = 1, #MICRO_BUTTONS do
		local button = _G[MICRO_BUTTONS[i]]
		local lastColumnButton = i - self.db.microbar.buttonsPerRow
		lastColumnButton = _G[MICRO_BUTTONS[lastColumnButton]]

		button:Size(self.db.microbar.buttonSize, self.db.microbar.buttonSize * 1.4)
		button:ClearAllPoints()

		if prevButton == ElvUI_MicroBar then
			button:Point("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
		elseif (i - 1) % self.db.microbar.buttonsPerRow == 0 then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, -spacing)
			numRows = numRows + 1
		else
			button:Point("LEFT", prevButton, "RIGHT", spacing, 0)
		end

		prevButton = button
	end

	if AB.db.microbar.mouseover and not ElvUI_MicroBar:IsMouseOver() then
		ElvUI_MicroBar:SetAlpha(0)
	else
		ElvUI_MicroBar:SetAlpha(self.db.microbar.alpha)
	end

	AB.MicroWidth = (((_G["CharacterMicroButton"]:GetWidth() + spacing) * self.db.microbar.buttonsPerRow) - spacing) + (offset * 2)
	AB.MicroHeight = (((_G["CharacterMicroButton"]:GetHeight() + spacing) * numRows) - spacing) + (offset * 2)
	ElvUI_MicroBar:Size(AB.MicroWidth, AB.MicroHeight)

	if ElvUI_MicroBar.mover then
		if self.db.microbar.enabled then
			E:EnableMover(ElvUI_MicroBar.mover:GetName())
		else
			E:DisableMover(ElvUI_MicroBar.mover:GetName())
		end
	end

	self:UpdateMicroBarVisibility()
end

function AB:UpdateMicroButtons()
	self:UpdateMicroPositionDimensions()
	if self.db.microbar.dfskin then
		GuildMicroButton.Spinner:SetAlpha(0)
		GuildMicroButtonTabard.emblem:SetAlpha(0)
		GuildMicroButtonTabard.background:SetAlpha(0)
	else
		GuildMicroButton.Spinner:SetAlpha(1)
		GuildMicroButtonTabard.emblem:SetAlpha(1)
		GuildMicroButtonTabard.background:SetAlpha(1)
		GuildMicroButtonTabard.emblem:ClearAllPoints()
		GuildMicroButtonTabard.emblem:SetAllPoints(GuildMicroButton)
		GuildMicroButtonTabard.background:ClearAllPoints()
		GuildMicroButtonTabard.background:SetAllPoints(GuildMicroButtonTabard.emblem)
	end
	-- GuildMicroButtonTabard:SetPoint("TOPLEFT", -5, 24)
	-- for k,v in pairs(GuildMicroButtonTabard) do
	-- 	print(k, v)
	-- end
	-- local a,d = GuildMicroButton:GetSize()
	-- GuildMicroButtonTabard.background:Size(a,d)
end

function AB:DFEvent(event)
	UpdateDFTextures(CollectionsMicroButton)
	if event == "PLAYER_GUILD_UPDATE" or event == "GUILD_ROSTER_UPDATE" then
		UpdateDFTextures(GuildMicroButton)
	end
end

function AB:SetupMicroBar()
	local microBar = CreateFrame("Frame", "ElvUI_MicroBar", E.UIParent)
	microBar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -48)
	microBar:EnableMouse(true)
	microBar:SetScript("OnEnter", onEnter)
	microBar:SetScript("OnLeave", onLeave)

	microBar.visibility = CreateFrame("Frame", nil, E.UIParent, "SecureHandlerStateTemplate")
	microBar.visibility:SetScript("OnShow", function() microBar:Show() end)
	microBar.visibility:SetScript("OnHide", function() microBar:Hide() end)

	for i = 1, #MICRO_BUTTONS do
		self:HandleMicroButton(_G[MICRO_BUTTONS[i]])
	end

	if self.db.microbar.dfskin then
		hooksecurefunc('CharacterMicroButton_SetPushed', function()
			MicroButtonPortrait:SetTexCoord(0, 0, 0, 0);
			MicroButtonPortrait:SetAlpha(0);
		end)

		hooksecurefunc('CharacterMicroButton_SetNormal', function()
			MicroButtonPortrait:SetTexCoord(0, 0, 0, 0);
			MicroButtonPortrait:SetAlpha(0);
		end)
		self:RegisterEvent("PLAYER_GUILD_UPDATE", "DFEvent")
		self:RegisterEvent("GUILD_ROSTER_UPDATE", "DFEvent")
	else
		MicroButtonPortrait:SetInside(CharacterMicroButton.backdrop)
	end


	self:SecureHook("VehicleMenuBar_MoveMicroButtons", "UpdateMicroButtonsParent")
	self:SecureHook("UpdateMicroButtons")

	self:UpdateMicroPositionDimensions()

	E:CreateMover(microBar, "MicrobarMover", L["Micro Bar"], nil, nil, nil, "ALL,ACTIONBARS", nil, "actionbar,microbar")
end