local E, _, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local next = next
local gsub = gsub
local ipairs = ipairs
local format = format
local unpack = unpack
local tinsert = tinsert
local strmatch = strmatch

--WoW API / Variables
local UIParent = UIParent
local RaiseFrameLevel = RaiseFrameLevel
local LowerFrameLevel = LowerFrameLevel
local hooksecurefunc = hooksecurefunc
local getmetatable = getmetatable
local setmetatable = setmetatable
local rawset = rawset

-- these do *not* need to match the current lib minor version
-- these numbers are used to not attempt skinning way older
-- versions of AceGUI and AceConfigDialog.
local minorGUI, minorConfigDialog = 36, 76

function S:Ace3_BackdropColor()
	self:SetBackdropColor(0, 0, 0, 0.25)
end

function S:Ace3_SkinDropdown()
	if self and self.obj then
		local pullout = self.obj.dropdown -- Don't ask questions.. Just FUCKING ACCEPT IT
		if pullout then
			if pullout.frame then
				pullout.frame:SetTemplate(nil, true)
			else
				pullout:SetTemplate(nil, true)
			end

			if pullout.slider then
				pullout.slider:SetTemplate()
				pullout.slider:SetThumbTexture(E.Media.Textures.White8x8)

				local t = pullout.slider:GetThumbTexture()
				t:SetVertexColor(1, .82, 0, 0.8)
			end
		end
	end
end

function S:Ace3_CheckBoxIsEnable(widget)
	local text = widget and widget.text and widget.text:GetText()
	if text and S.Ace3_EnableMatch then return strmatch(text, S.Ace3_EnableMatch) end
end

-- Make sure the "Enable" label coloring data is available before any hook
-- that uses it runs. Widgets can be created before the skin module finished
-- initializing (early AceGUI widgets), in which case the hook must not
-- silently skip styling the Enable checkbox.
local function Ace3_EnsureEnableColoring()
	if S.Ace3_L then return end

	pcall(function()
		local locale = (E.global and E.global.general and E.global.general.locale) or 'enUS'
		local ACL = E.Libs and E.Libs.ACL
		if ACL then
			S:Ace3_ColorizeEnable(ACL:GetLocale('ElvUI', locale))
		end
	end)

	if not S.Ace3_L then
		S:Ace3_ColorizeEnable({ Enable = 'Enable' })
	end
end

function S:Ace3_CheckBoxSetDesaturated(value)
	local widget = self:GetParent():GetParent().obj
	if value == true then
		self:SetVertexColor(.6, .6, .6, .8)
	elseif S:Ace3_CheckBoxIsEnable(widget) then
		if widget.checked then
			self:SetVertexColor(0.2, 1.0, 0.2, 1.0)
		else
			self:SetVertexColor(1.0, 0.2, 0.2, 1.0)
		end
	else
		self:SetVertexColor(1, .82, 0, 0.8)
	end
end

function S:Ace3_CheckBoxSetDisabled(disabled)
	Ace3_EnsureEnableColoring()
	if S:Ace3_CheckBoxIsEnable(self) then
		local tristateOrDisabled = disabled or (self.tristate and self.checked == nil)
		self:SetLabel((tristateOrDisabled and S.Ace3_L.Enable) or (self.checked and S.Ace3_EnableOn) or S.Ace3_EnableOff)
	end
end

function S:Ace3_EditBoxSetTextInsets(l, r, t, b)
	if l == 0 then self:SetTextInsets(3, r, t, b) end
end

function S:Ace3_EditBoxSetPoint(a, b, c, d, e)
	if d == 7 then
		self:Point(a, b, c, 0, e)
	end
end

function S:Ace3_CheckBoxSetType(type)
	if type == 'radio' then
		self.checkbg:SetSize(20, 20)
	end
end

function S:Ace3_TabSetSelected(selected)
	local bd = self.backdrop
	if not bd then return end

	if selected then
		bd:SetBackdropBorderColor(1, .82, 0, 1)
		bd:SetBackdropColor(1, .82, 0, 0.4)

		if not self.wasRaised then
			RaiseFrameLevel(self)
			self.wasRaised = true
		end
	else
		local br, bg, bb = unpack(E.media.bordercolor)
		bd:SetBackdropBorderColor(br, bg, bb, 1)

		local bdr, bdg, bdb = unpack(E.media.backdropcolor)
		bd:SetBackdropColor(bdr, bdg, bdb, 1)

		if self.wasRaised then
			LowerFrameLevel(self)
			self.wasRaised = nil
		end
	end
end

local buttonSetPointInProgress
function S:Ace3_ButtonSetPoint(point, anchor, point2, xOffset, yOffset, skip)
	-- Sirus' toolkit Point only forwards 5 args to SetPoint, so the `skip`
	-- flag used by dev would be dropped and this hook would re-fire forever
	-- (C stack overflow). Guard with a re-entrancy flag instead.
	if not skip and point2 == 'TOPRIGHT' and not buttonSetPointInProgress then
		buttonSetPointInProgress = true
		pcall(function()
			self:Point(point, anchor, point2, xOffset + 2, yOffset)
		end)
		buttonSetPointInProgress = nil
	end
end

function S:Ace3_SkinButton(button)
	if not button.isSkinned then
		S:HandleButton(button, true)

		hooksecurefunc(button, 'SetPoint', S.Ace3_ButtonSetPoint)
	end
end

function S:Ace3_SkinCheckBox(widget, check, checkbg, highlight)
	if not checkbg.backdrop then
		checkbg:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, true)
		checkbg.backdrop:SetInside(widget.checkbg, 4, 4)

		checkbg:SetTexture()
		highlight:SetTexture()

		check:SetParent(checkbg.backdrop)

		hooksecurefunc(widget, 'SetDisabled', S.Ace3_CheckBoxSetDisabled)
		hooksecurefunc(widget, 'SetType', S.Ace3_CheckBoxSetType)

		-- AceConfigDialog may set the label after SetDisabled, so also recolor
		-- the "Enable" label whenever the label text changes. The colored label
		-- itself still matches the Enable pattern, so a re-entrancy flag stops
		-- the SetLabel -> SetLabel cycle.
		if not widget.__ace3LabelHooked then
			widget.__ace3LabelHooked = true
			local coloring
			hooksecurefunc(widget, 'SetLabel', function(_, label)
				if coloring then return end
				Ace3_EnsureEnableColoring()
				if S:Ace3_CheckBoxIsEnable(widget) then
					coloring = true
					local disabled = widget.disabled
					local tristateOrDisabled = disabled or (widget.tristate and widget.checked == nil)
					widget:SetLabel((tristateOrDisabled and S.Ace3_L.Enable) or (widget.checked and S.Ace3_EnableOn) or S.Ace3_EnableOff)
					coloring = nil
				end
			end)
		end

		if E.private.skins.checkBoxSkin then
			S.Ace3_CheckBoxSetDesaturated(check, check:GetDesaturation())
			hooksecurefunc(check, 'SetDesaturated', S.Ace3_CheckBoxSetDesaturated)

			checkbg.backdrop:SetInside(widget.checkbg, 5, 5)
			check:SetInside(widget.checkbg.backdrop)

			check:SetTexture(E.Media.Textures.Melli)
			check.SetTexture = E.noop
		else
			check:SetOutside(checkbg.backdrop, 3, 3)
		end

		checkbg.SetTexture = E.noop
		highlight.SetTexture = E.noop
	end
end

function S:Ace3_SkinTab(tab)
	if not tab.backdrop then
		tab:StripTextures()
		tab:CreateBackdrop(nil, true, true)
		tab.backdrop:Point('TOPLEFT', 10, -3)
		tab.backdrop:Point('BOTTOMRIGHT', -10, 0)

		if tab.text and tab.text.Point then -- possible issue with Pally Power
			-- center the label inside the tab (dev keeps the TabGroup's
			-- LEFT+RIGHT span and relies on centered justification; do it
			-- explicitly here so the Sirus vanilla ButtonText never hugs left)
			tab.text:ClearAllPoints()
			tab.text:SetJustifyH('CENTER')
			tab.text:SetJustifyV('MIDDLE')
			tab.text:Point('CENTER', tab, 'CENTER', 0, -1)
		end

		hooksecurefunc(tab, 'SetSelected', S.Ace3_TabSetSelected)
	end
end

function S:Ace3_SkinEditBox(editbox, button, frame)
	if not editbox.backdrop then
		S:HandleEditBox(editbox)
		S:HandleButton(button)

		button:Point('RIGHT', editbox.backdrop, 'RIGHT', -2, 0)

		hooksecurefunc(editbox, 'SetTextInsets', S.Ace3_EditBoxSetTextInsets)
		hooksecurefunc(editbox, 'SetPoint', S.Ace3_EditBoxSetPoint)

		editbox.backdrop:Point('TOPLEFT', 0, -2)
		editbox.backdrop:Point('BOTTOMRIGHT', -1, 0)

		editbox.backdrop:SetParent(frame)
		editbox:SetParent(editbox.backdrop)
	end
end

local nextPrevColor = {1, .8, 0}
function S:Ace3_RegisterAsWidget(widget)
	local TYPE = widget.type
	if TYPE == 'MultiLineEditBox' or TYPE == 'MultiLineEditBox-ElvUI' then
		local scrollbar = widget.scrollBar
		if scrollbar then
			S:HandleButton(widget.button)
			S:HandleScrollBar(scrollbar)

			local bg = widget.scrollBG
			if bg then
				bg:SetTemplate()
				bg:Point('TOPRIGHT', scrollbar, 'TOPLEFT', -2, 19)
				bg:Point('BOTTOMLEFT', widget.button, 'TOPLEFT')

				scrollbar:Point('RIGHT', widget.frame, 'RIGHT', -4)
				widget.scrollFrame:Point('BOTTOMRIGHT', bg, 'BOTTOMRIGHT', -4, 8)
			end
		end
	elseif TYPE == 'CheckBox' then
		S:Ace3_SkinCheckBox(widget, widget.check, widget.checkbg, widget.highlight)
	elseif TYPE == 'Dropdown' or TYPE == 'Dropdown-ElvUI' or TYPE == 'LQDropdown' then
		local frame = widget.dropdown

		frame:StripTextures()
		frame:CreateBackdrop()
		frame.backdrop:Point('TOPLEFT', 15, -2)
		frame.backdrop:Point('BOTTOMRIGHT', -21, 0)

		local label = widget.label
		if label then
			label:ClearAllPoints()
			label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)
		end

		local button = widget.button
		if button then
			S:HandleNextPrevButton(button, nil, nextPrevColor)

			button:ClearAllPoints()
			button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
			button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)
			button:SetParent(frame.backdrop)
		end

		local text = widget.text
		if text then
			text:ClearAllPoints()
			text:SetJustifyH('RIGHT')
			text:Point('RIGHT', button, 'LEFT', -3, 0)
			text:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
			text:SetParent(frame.backdrop)
		end
	elseif TYPE == 'LSM30_Font' or TYPE == 'LSM30_Sound' or TYPE == 'LSM30_Border' or TYPE == 'LSM30_Background' or TYPE == 'LSM30_Statusbar' then
		local frame = widget.frame

		frame:StripTextures()
		frame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, true)
		frame.backdrop:Point('TOPLEFT', 0, -21)
		frame.backdrop:Point('BOTTOMRIGHT', -4, -1)

		local label = frame.label
		if label then
			label:ClearAllPoints()
			label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)
		end

		local button = frame.dropButton
		if button then
			local text = frame.text
			if text then
				text:ClearAllPoints()
				text:Point('RIGHT', button, 'LEFT', -2, 0)
				text:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
				text:SetParent(frame.backdrop)
			end

			if TYPE == 'LSM30_Statusbar' then
				S:HandleNextPrevButton(button, nil, nextPrevColor, true)

				local bar = widget.bar
				if bar then
					bar:SetParent(frame.backdrop)
					bar:ClearAllPoints()
					bar:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 1, -1)
					bar:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -1, 1)
				end
			else
				S:HandleNextPrevButton(button, nil, nextPrevColor)

				local soundbutton = TYPE == 'LSM30_Sound' and widget.soundbutton
				if soundbutton then
					soundbutton:SetParent(frame.backdrop)
					soundbutton:ClearAllPoints()
					soundbutton:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
				end
			end

			button:ClearAllPoints()
			button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
			button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)
			button:SetParent(frame.backdrop)
			button:HookScript('OnClick', S.Ace3_SkinDropdown)
		end
	elseif TYPE == 'EditBox' or TYPE == 'EditBox-ElvUI' then
		S:Ace3_SkinEditBox(widget.editbox, widget.button, widget.frame)
	elseif TYPE == 'Button' or TYPE == 'Button-ElvUI' then
		S:Ace3_SkinButton(widget.frame)
	elseif TYPE == 'Slider' or TYPE == 'Slider-ElvUI' then
		local slider = widget.slider
		S:HandleSliderFrame(slider)

		local editbox = widget.editbox
		if editbox then
			editbox:SetTemplate()
			editbox:Height(15)
			editbox:Point('TOP', slider, 'BOTTOM', 0, -1)
		end

		local lowtext = widget.lowtext
		if lowtext then
			lowtext:Point('TOPLEFT', slider, 'BOTTOMLEFT', 2, -2)
		end

		local hightext = widget.hightext
		if hightext then
			hightext:Point('TOPRIGHT', slider, 'BOTTOMRIGHT', -2, -2)
		end

		hooksecurefunc(widget, 'SetDisabled', function(w, disabled)
			local thumbTex = w.slider:GetThumbTexture()
			if disabled then
				thumbTex:SetVertexColor(0.6, 0.6, 0.6, 0.8)
			else
				thumbTex:SetVertexColor(1, 0.82, 0, 0.8)
			end
		end)
	elseif TYPE == 'Keybinding' then
		local button = widget.button
		if button then
			S:HandleButton(button, true)
		end

		local msgframe = widget.msgframe
		if msgframe then
			msgframe:StripTextures()
			msgframe:SetTemplate('Transparent')

			local msg = msgframe.msg
			if msg then
				msg:ClearAllPoints()
				msg:Point('CENTER')
			end
		end
	elseif TYPE == 'ColorPicker' or TYPE == 'ColorPicker-ElvUI' then
		local frame = widget.frame
		frame:CreateBackdrop()
		frame.backdrop:Size(24, 16)
		frame.backdrop:ClearAllPoints()
		frame.backdrop:Point('LEFT', frame, 'LEFT', 4, 0)

		local colorSwatch = widget.colorSwatch
		if colorSwatch then
			colorSwatch:SetTexture(E.Media.Textures.White8x8)
			colorSwatch:ClearAllPoints()
			colorSwatch:SetParent(frame.backdrop)
			colorSwatch:SetInside(frame.backdrop)

			local bg = colorSwatch.background
			if bg then
				bg:SetTexture(0, 0, 0, 0)
			end

			local checkers = colorSwatch.checkers
			if checkers then
				checkers:ClearAllPoints()
				checkers:SetParent(frame.backdrop)
				checkers:SetInside(frame.backdrop)
			end
		end
	elseif TYPE == 'Icon' then
		widget.frame:StripTextures()
	elseif TYPE == 'Dropdown-Pullout' then
		local frame = widget.frame
		if frame then
			frame:SetTemplate(nil, true)
		end

		local slider = widget.slider
		if slider then
			slider:SetTemplate()
			slider:SetThumbTexture(E.Media.Textures.White8x8)

			local thumb = slider:GetThumbTexture()
			if thumb then
				thumb:SetVertexColor(1, .82, 0, 0.8)
			end
		end
	end
end

function S:Ace3_CreateTab(id)
	local tab = self.old_CreateTab(self, id)
	S:Ace3_SkinTab(tab)

	return tab
end

function S:Ace3_RefreshTree(scrollToSelection)
	self.old_RefreshTree(self, scrollToSelection)

	local tree = self.tree
	if not tree then return end

	local border = self.border
	local treeframe = self.treeframe
	if border and treeframe then
		border:ClearAllPoints()

		local userdata = self.userdata
		local dataoption = userdata and userdata.option
		if dataoption and dataoption.childGroups == 'ElvUI_HiddenTree' then
			border:Point('TOPLEFT', treeframe, 'TOPRIGHT', 1, 13)
			border:Point('BOTTOMRIGHT', self.frame, 'BOTTOMRIGHT', 6, 0)

			treeframe:Point('TOPLEFT', 0, 0)

			if treeframe:IsShown() then
				treeframe:Hide()
			end

			return -- dont proceed
		else
			border:Point('TOPLEFT', treeframe, 'TOPRIGHT')
			border:Point('BOTTOMRIGHT', self.frame)

			treeframe:Point('TOPLEFT', 0, -2)

			if not treeframe:IsShown() then
				treeframe:Show()
			end
		end
	end

	if not E.private.skins.ace3.enable then return end

	local lines = self.lines
	local buttons = self.buttons
	if lines and buttons then
		local status = self.status or self.localstatus
		local offset = status.scrollvalue
		local groupstatus = status.groups

		for i = offset + 1, #lines do
			local button = buttons[i - offset]
			if button then
				if button.highlight then
					button.highlight:SetVertexColor(1.0, 0.9, 0.0, 0.8)
				end

				local line = lines[i]
				local unique = line and line.uniquevalue
				if unique and groupstatus[unique] then
					button.toggle:SetNormalTexture(E.Media.Textures.Minus)
					button.toggle:SetPushedTexture(E.Media.Textures.Minus)
				else
					button.toggle:SetNormalTexture(E.Media.Textures.Plus)
					button.toggle:SetPushedTexture(E.Media.Textures.Plus)
				end

				button.toggle:SetHighlightTexture(E.ClearTexture)
			end
		end
	end
end

function S:Ace3_RegisterAsContainer(widget)
	local TYPE = widget.type
	if TYPE == 'ScrollFrame' then
		S:HandleScrollBar(widget.scrollbar)
	elseif TYPE == 'InlineGroup' or TYPE == 'TreeGroup' or TYPE == 'TabGroup' or TYPE == 'Frame' or TYPE == 'DropdownGroup' or TYPE == 'Window' then
		local frame = widget.content:GetParent()
		if TYPE == 'Frame' then
			frame:StripTextures()

			for _, child in next, { frame:GetChildren() } do
				if child:IsObjectType('Button') and child:GetText() then
					S:HandleButton(child)
				else
					child:StripTextures()
				end
			end
		elseif TYPE == 'Window' then
			frame:StripTextures()

			S:HandleCloseButton(frame.obj.closebutton)
		end

		frame:SetTemplate('Transparent')

		if TYPE == 'InlineGroup' then -- 'Window' is another type
			frame.ignoreBackdropColors = true
			S.Ace3_BackdropColor(frame)
		end

		if widget.treeframe then
			widget.treeframe:SetTemplate('Transparent')
		end

		if TYPE == 'TabGroup' then
			if not widget.old_CreateTab then
				widget.old_CreateTab = widget.CreateTab
				widget.CreateTab = S.Ace3_CreateTab
			end

			if widget.tabs then
				for _, n in next, widget.tabs do
					S:Ace3_SkinTab(n)
				end
			end
		end

		if widget.scrollbar then
			S:HandleScrollBar(widget.scrollbar)
		end
	elseif TYPE == 'SimpleGroup' then
		local frame = widget.content:GetParent()
		frame:SetTemplate('Transparent', nil, true)
		frame.ignoreBackdropColors = true
		frame:SetBackdropColor(0, 0, 0, 0.25)
	end

	if widget.sizer_se then
		for _, Region in next, { widget.sizer_se:GetRegions() } do
			if Region:IsObjectType('Texture') then
				Region:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
			end
		end
	end
end

function S:Ace3_StyleTooltip()
	if E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip then
		self:SetTemplate('Transparent')
	end
end

function S:Ace3_StylePopup()
	if E.private.skins.ace3.enable then
		self:SetTemplate('Transparent', nil, true)
		self:GetChildren():StripTextures()

		S:HandleButton(self.accept, true)
		S:HandleButton(self.cancel, true)
	end
end

-- The latest raw implementations of the AceGUI registration methods. The
-- wrappers below always call the CURRENT implementation, so a newer lib copy
-- (loaded by another addon after a LibStub minor bump) keeps working.
S.Ace3_Impl = {}

S.Ace3_Wrappers = {
	RegisterAsContainer = function(s, w, ...)
		local impl = S.Ace3_Impl.RegisterAsContainer
		if impl then
			-- The skin must never break the underlying library call. Capture the
			-- FULL argument list (self + widget): S.Ace3_RegisterAsContainer is
			-- declared with a colon, so it expects (self, widget).
			local rest = { s, w, ... }
			pcall(function()
				if E.private and E.private.skins and E.private.skins.ace3.enable then
					S.Ace3_RegisterAsContainer(unpack(rest))
				end

				if w and w.treeframe and not w.old_RefreshTree then
					w.old_RefreshTree = w.RefreshTree
					w.RefreshTree = S.Ace3_RefreshTree
				end
			end)

			return impl(s, w, ...)
		end
	end,
	RegisterAsWidget = function(...)
		local impl = S.Ace3_Impl.RegisterAsWidget
		if impl then
			local rest = { ... }
			pcall(function()
				if E.private and E.private.skins and E.private.skins.ace3.enable then
					S.Ace3_RegisterAsWidget(unpack(rest))
				end
			end)

			return impl(...)
		end
	end,
}

function S:Ace3_MetaTable(lib)
	local t = getmetatable(lib)
	if t then
		t.__newindex = S.Ace3_MetaIndex
	else
		setmetatable(lib, {__newindex = S.Ace3_MetaIndex})
	end
end

function S:Ace3_SkinTooltip(lib, minor) -- lib: AceConfigDialog or AceGUI
	-- we only check `minor` here when checking an instance of AceConfigDialog
	-- we can safely ignore it when checking AceGUI because we minor check that
	-- inside of its own function.
	if not lib or (minor and minor < minorConfigDialog) then return end

	if not lib.tooltip then
		S:Ace3_MetaTable(lib)
	else
		if lib.tooltip and not S:IsHooked(lib.tooltip, 'OnShow') then -- Tooltip
			S:SecureHookScript(lib.tooltip, 'OnShow', S.Ace3_StyleTooltip)
		end
		if lib.popup and not S:IsHooked(lib.popup, 'OnShow') then -- StaticPopup
			S:SecureHookScript(lib.popup, 'OnShow', S.Ace3_StylePopup)
		end
	end
end

function S:Ace3_MetaIndex(k, v)
	if k == 'tooltip' then
		rawset(self, k, v)

		S:SecureHookScript(v, 'OnShow', S.Ace3_StyleTooltip)
	elseif k == 'popup' then
		rawset(self, k, v)

		S:SecureHookScript(v, 'OnShow', S.Ace3_StylePopup)
	elseif k == 'RegisterAsContainer' or k == 'RegisterAsWidget' then
		-- Refresh the implementation the wrapper should call. A nil assignment
		-- (the temporary nil-out in HookAce3) must never leave a broken wrapper
		-- behind -- the methods have to stay callable for every addon sharing
		-- the AceGUI library (Gladdy, Spy, Details, ...).
		-- NOTE: the Sirus client does not allow attaching fields to functions,
		-- so the wrappers are identified by identity (they are singletons).
		if type(v) == 'function' and v ~= S.Ace3_Wrappers[k] then
			S.Ace3_Impl[k] = v
		end

		rawset(self, k, S.Ace3_Impl[k] and S.Ace3_Wrappers[k] or v)
	else
		rawset(self, k, v)
	end
end

function S:Ace3_ColorizeEnable(L)
	S.Ace3_L = L

	-- Special Enable Coloring
	S.Ace3_EnableMatch = '^|?c?[Ff]?[Ff]?%x?%x?%x?%x?%x?%x?' .. E:EscapeString(S.Ace3_L.Enable) .. '|?r?$'
	S.Ace3_EnableOff = format('|cffff3333%s|r', S.Ace3_L.Enable)
	S.Ace3_EnableOn = format('|cff33ff33%s|r', S.Ace3_L.Enable)
end

local lastMinor = 0
function S:HookAce3(lib, minor, early) -- lib: AceGUI
	if not lib or (not minor or minor < minorGUI) then return end

	-- Refresh the implementations our wrappers call. A newer lib copy may have
	-- overwritten our wrapper after a LibStub minor bump.
	local curContainer, curWidget = lib.RegisterAsContainer, lib.RegisterAsWidget
	if curContainer and curContainer ~= S.Ace3_Wrappers.RegisterAsContainer then
		S.Ace3_Impl.RegisterAsContainer = curContainer
	end
	if curWidget and curWidget ~= S.Ace3_Wrappers.RegisterAsWidget then
		S.Ace3_Impl.RegisterAsWidget = curWidget
	end

	local oldMinor = lastMinor
	if lastMinor < minor then
		lastMinor = minor
	end
	if early or oldMinor ~= minor then
		lib.RegisterAsContainer = nil
		lib.RegisterAsWidget = nil
	end

	if not lib.RegisterAsWidget then
		S:Ace3_MetaTable(lib)
	end

	if not S.Ace3_L then
		-- E.global is only populated in OnInitialize, so this can run before it
		-- exists. Never let the locale setup abort the hook, or the AceGUI
		-- registration methods would be left missing for every other addon.
		local locale = E.global and E.global.general and E.global.general.locale or "enUS"
		pcall(function()
			S.Ace3_L = E.Libs.ACL:GetLocale("ElvUI", locale)
			S:Ace3_ColorizeEnable(S.Ace3_L)
		end)
	end

	-- Never leave the registration methods missing: (re)install our wrappers.
	-- RegisterAsContainer/RegisterAsWidget are called by every AceGUI widget
	-- constructor, so a nil value crashes all AceGUI users (Gladdy, Spy, ...).
	if S.Ace3_Impl.RegisterAsContainer then
		lib.RegisterAsContainer = S.Ace3_Wrappers.RegisterAsContainer
	end
	if S.Ace3_Impl.RegisterAsWidget then
		lib.RegisterAsWidget = S.Ace3_Wrappers.RegisterAsWidget
	end
end

do -- Early Skin Loading
	local Libraries = {
		['AceGUI'] = true,
		['AceConfigDialog'] = true,
		['AceConfigDialog-3.0-ElvUI'] = true,
	}

	S.EarlyAceWidgets = {}
	S.EarlyAceTooltips = {}

	local LibStub = LibStub
	local numEnding = '%-[%d%.]+$'
	function S:LibStub_NewLib(major)
		local early = not E.initialized
		local n = gsub(major, numEnding, '')
		if Libraries[n] then
			if n == 'AceGUI' then
				S:HookAce3(LibStub.libs[major], LibStub.minors[major], early)
				if early then
					tinsert(S.EarlyAceTooltips, major)
				else
					S:Ace3_SkinTooltip(LibStub.libs[major])
				end
			elseif n == 'AceConfigDialog' or n == 'AceConfigDialog-3.0-ElvUI' then
				if early then
					tinsert(S.EarlyAceTooltips, major)
				else
					S:Ace3_SkinTooltip(LibStub.libs[major], LibStub.minors[major])
				end
			end
		end
	end

	local findWidget
	local function earlyWidget(y)
		if y.children then findWidget(y.children) end
		if y.frame and (y.base and y.base.Release) then
			tinsert(S.EarlyAceWidgets, y)
		end
	end

	findWidget = function(x)
		for _, y in ipairs(x) do
			earlyWidget(y)
		end
	end

	for n in next, LibStub.libs do
		if n == 'AceGUI-3.0' then
			for _, x in next, { UIParent:GetChildren() } do
				if x and x.obj then earlyWidget(x.obj) end
			end
		end
		if Libraries[gsub(n, numEnding, '')] then
			S:LibStub_NewLib(n)
		end
	end

	hooksecurefunc(LibStub, 'NewLibrary', S.LibStub_NewLib)
end
