local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')

local _G = _G
local ipairs, pairs, next, unpack = ipairs, pairs, next, unpack
local format, gsub, strsplit, strfind, strupper = format, gsub, strsplit, strfind, strupper

local ClearOverrideBindings = ClearOverrideBindings
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsPossessBarVisible = IsPossessBarVisible
local PetDismiss = PetDismiss
local RegisterStateDriver = RegisterStateDriver
local SetModifiedClick = SetModifiedClick
local SetOverrideBindingClick = SetOverrideBindingClick
local UnitAffectingCombat = UnitAffectingCombat
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnregisterStateDriver = UnregisterStateDriver
local VehicleExit = VehicleExit
local UIParent = UIParent
local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef

local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS

local LAB = E.Libs.LAB
local LSM = E.Libs.LSM
local Masque = E.Masque
local VehicleMasqueGroup = Masque and Masque:Group('ElvUI', 'ActionBar Leave Vehicle')

local buttonDefaults = {
	hideElements = {},
	colors = {},
	text = {
		hotkey = { font = {}, color = {}, position = {} },
		count = { font = {}, color = {}, position = {} },
		macro = { font = {}, color = {}, position = {} },
	},
}

AB.RegisterCooldown = E.RegisterCooldown
AB.handledBars = {} --List of all bars
AB.handledbuttons = {} --List of all buttons that have been modified.
AB.barDefaults = {
	bar1 = { page = 1, bindButtons = 'ACTIONBUTTON', position = 'BOTTOM,ElvUIParent,BOTTOM,-1,191' },
	bar2 = { page = 2, bindButtons = 'ELVUIBAR2BUTTON', position = 'BOTTOM,ElvUIParent,BOTTOM,0,4' },
	bar3 = { page = 3, bindButtons = 'MULTIACTIONBAR3BUTTON', position = 'BOTTOM,ElvUIParent,BOTTOM,-1,139' },
	bar4 = { page = 4, bindButtons = 'MULTIACTIONBAR4BUTTON', position = 'RIGHT,ElvUIParent,RIGHT,-4,0' },
	bar5 = { page = 5, bindButtons = 'MULTIACTIONBAR2BUTTON', position = 'BOTTOM,ElvUIParent,BOTTOM,-279,4' },
	bar6 = { page = 6, bindButtons = 'MULTIACTIONBAR1BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,264' },
	bar7 = { page = 7, bindButtons = 'ELVUIBAR7BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,298' },
	bar8 = { page = 8, bindButtons = 'ELVUIBAR8BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,332' },
	bar9 = { page = 9, bindButtons = 'ELVUIBAR9BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,366' },
	bar10 = { page = 10, bindButtons = 'ELVUIBAR10BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,400' },
	bar13 = { page = 13, bindButtons = 'MULTIACTIONBAR5BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,400' },
	bar14 = { page = 14, bindButtons = 'MULTIACTIONBAR6BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,400' },
	bar15 = { page = 15, bindButtons = 'MULTIACTIONBAR7BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,400' }
}

function AB:UpdateBar1Paging()
	if AB.db.bar6.enabled then
		AB.barDefaults.bar1.conditions = '[bonusbar:5] 11; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;'
	else
		AB.barDefaults.bar1.conditions = '[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;'
	end
end

AB.customExitButton = {
	func = function()
		if UnitExists('vehicle') then
			VehicleExit()
		else
			PetDismiss()
		end
	end,
	texture = [[Interface\Icons\Spell_Shadow_SacrificialShield]],
	tooltip = _G.LEAVE_VEHICLE
}

function AB:HandleBackdropMultiplier(bar, backdropSpacing, buttonSpacing, widthMult, heightMult, anchorUp, anchorLeft, horizontal, lastShownButton, anchorRowButton)
	if not bar.backdrop:IsShown() then return end

	local useWidthMult = widthMult > 1
	local useHeightMult = heightMult > 1
	if useWidthMult or useHeightMult then
		local oldWidth, oldHeight = bar.backdrop:GetSize()
		if useHeightMult then
			local offset = ((oldHeight - backdropSpacing + buttonSpacing) * (heightMult - 1)) - (backdropSpacing * (heightMult - 2))
			local anchorPoint = anchorUp and 'TOP' or 'BOTTOM'
			bar.backdrop:Point(anchorPoint, lastShownButton, anchorPoint, 0, anchorUp and offset or -offset)
		end
		if useWidthMult then
			local offset = ((oldWidth - backdropSpacing + buttonSpacing) * (widthMult - 1)) - (backdropSpacing * (widthMult - 2))
			bar.backdrop:Point(horizontal, anchorRowButton, horizontal, anchorLeft and -offset or offset, 0)
		end
	end
end

function AB:HandleBackdropMover(bar, backdropSpacing)
	local width, height = bar.backdrop:GetSize()
	if not bar.backdrop:IsShown() then
		local spacing = backdropSpacing * 2
		bar:SetSize(width - spacing, height - spacing)
	else
		bar:SetSize(width, height)
	end
end

function AB:HandleButton(bar, button, index, lastButton, lastColumnButton)
	local db = bar.db

	local numButtons = db.buttons
	local buttonsPerRow = db.buttonsPerRow
	local buttonWidth = db.buttonSize
	local buttonHeight = db.keepSizeRatio and db.buttonSize or db.buttonHeight

	if bar.LastButton then
		if numButtons > bar.LastButton then numButtons = bar.LastButton end
		if buttonsPerRow > bar.LastButton then buttonsPerRow = bar.LastButton end
	end

	if numButtons < buttonsPerRow then buttonsPerRow = numButtons end

	local _, horizontal, anchorUp, anchorLeft = AB:GetGrowth(db.point)
	local point, relativeFrame, relativePoint, x, y
	if index == 1 then
		local firstButtonSpacing = db.backdrop and (E.Border + db.backdropSpacing) or E.Spacing
		if db.point == 'BOTTOMLEFT' then
			x, y = firstButtonSpacing, firstButtonSpacing
		elseif db.point == 'TOPRIGHT' then
			x, y = -firstButtonSpacing, -firstButtonSpacing
		elseif db.point == 'TOPLEFT' then
			x, y = firstButtonSpacing, -firstButtonSpacing
		else
			x, y = -firstButtonSpacing, firstButtonSpacing
		end

		point, relativeFrame, relativePoint = db.point, bar, db.point
	elseif (index - 1) % buttonsPerRow == 0 then
		point, relativeFrame, relativePoint, x, y = 'TOP', lastColumnButton, 'BOTTOM', 0, -db.buttonSpacing
		if anchorUp then
			point, relativePoint, y = 'BOTTOM', 'TOP', db.buttonSpacing
		end
	else
		point, relativeFrame, relativePoint, x, y = 'LEFT', lastButton, 'RIGHT', db.buttonSpacing, 0
		if anchorLeft then
			point, relativePoint, x = 'RIGHT', 'LEFT', -db.buttonSpacing
		end
	end

	button:SetParent(bar)
	button:ClearAllPoints()
	button:SetAttribute('showgrid', 1)
	button:EnableMouse(not db.clickThrough)
	button:Size(buttonWidth, buttonHeight)
	button:Point(point, relativeFrame, relativePoint, x, y)

	if index == 1 then
		bar.backdrop:Point(point, button, point, anchorLeft and db.backdropSpacing or -db.backdropSpacing, anchorUp and -db.backdropSpacing or db.backdropSpacing)
	elseif index == buttonsPerRow then
		bar.backdrop:Point(horizontal, button, horizontal, anchorLeft and -db.backdropSpacing or db.backdropSpacing, 0)
	end

	if button.handleBackdrop then
		local anchorPoint = anchorUp and 'TOP' or 'BOTTOM'
		bar.backdrop:Point(anchorPoint, button, anchorPoint, 0, anchorUp and db.backdropSpacing or -db.backdropSpacing)
	end
end

function AB:TrimIcon(button, masque)
	local icon = button.icon or button.Icon or _G[button:GetName()..'Icon']
	if not icon then return end

	if button.db and not button.db.keepSizeRatio then
		local width, height = button:GetSize()
		local left, right, top, bottom = E:CropRatio(width, height)
		icon:SetTexCoord(left, right, top, bottom)
	elseif not masque then
		icon:SetTexCoords()
	end
end

function AB:GetGrowth(point)
	local vertical = (point == 'TOPLEFT' or point == 'TOPRIGHT') and 'DOWN' or 'UP'
	local horizontal = (point == 'BOTTOMLEFT' or point == 'TOPLEFT') and 'RIGHT' or 'LEFT'
	local anchorUp, anchorLeft = vertical == 'UP', horizontal == 'LEFT'

	return vertical, horizontal, anchorUp, anchorLeft
end

function AB:MoverMagic(bar) -- ~Simpy
	local _, _, anchorUp, anchorLeft = AB:GetGrowth(bar.db.point)

	bar:ClearAllPoints()
	if not bar.backdrop:IsShown() then
		bar:SetPoint('BOTTOMLEFT', bar.mover)
	elseif anchorUp then
		bar:SetPoint('BOTTOMLEFT', bar.mover, 'BOTTOMLEFT', anchorLeft and E.Border or -E.Border, -E.Border)
	else
		bar:SetPoint('TOPLEFT', bar.mover, 'TOPLEFT', anchorLeft and E.Border or -E.Border, E.Border)
	end
end

function AB:ActivePages(page)
	local pages = {}
	local clean = gsub(page, '%[.-]', '')

	for _, index in next, { strsplit(';', clean) } do
		local num = tonumber(index)
		if num then
			pages[num] = true
		end
	end

	return pages
end

function AB:HandleButtonState(button, index, vehicleIndex, pages)
	for k = 1, 18 do
		if pages and pages[k] then
			button:SetState(k, 'action', (k - 1) * 12 + index)
		else
			button:SetState(k, 'empty')
		end
	end

	if pages and vehicleIndex and index == 12 then
		button:SetState(vehicleIndex, 'custom', AB.customExitButton)
	end
end

function AB:PositionAndSizeBar(barName)
	local db = AB.db[barName]
	local bar = AB.handledBars[barName]

	local enabled = db.enabled
	local buttonSpacing = db.buttonSpacing
	local backdropSpacing = db.backdropSpacing
	local buttonsPerRow = db.buttonsPerRow
	local numButtons = db.buttons
	local point = db.point

	bar.db = db
	bar.mouseover = db.mouseover

	if numButtons < buttonsPerRow then buttonsPerRow = numButtons end

	bar:SetParent(db.inheritGlobalFade and AB.fadeParent or E.UIParent)
	bar:EnableMouse(not db.clickThrough)
	bar:SetAlpha(bar.mouseover and 0 or db.alpha)
	bar:SetFrameStrata(db.frameStrata or 'LOW')
	bar:SetFrameLevel(db.frameLevel)

	bar.backdrop:SetShown(db.backdrop)
	bar.backdrop:SetFrameStrata(db.frameStrata or 'LOW')
	bar.backdrop:SetFrameLevel(db.frameLevel - 1)
	bar.backdrop:ClearAllPoints()

	AB:MoverMagic(bar)

	local _, horizontal, anchorUp, anchorLeft = AB:GetGrowth(point)
	local button, lastButton, lastColumnButton, anchorRowButton, lastShownButton

	-- paging needs to be updated even if the bar is disabled
	local defaults = AB.barDefaults[barName]
	local page = AB:GetPage(barName, defaults.page, defaults.conditions)
	RegisterStateDriver(bar, 'page', page)
	bar:SetAttribute('page', page)

	local pages = enabled and AB:ActivePages(page) or nil
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		lastButton = bar.buttons[i-1]
		lastColumnButton = bar.buttons[i-buttonsPerRow]
		button = bar.buttons[i]
		button.db = db

		if i == 1 or i == buttonsPerRow then
			anchorRowButton = button
		end

		if i > numButtons then
			button:Hide()
			button.handleBackdrop = nil
		else
			button:Show()
			button.handleBackdrop = true -- keep over HandleButton
			lastShownButton = button
		end

		AB:HandleButtonState(button, i, 11, pages)
		AB:HandleButton(bar, button, i, lastButton, lastColumnButton)
		AB:StyleButton(button, nil, MasqueGroup and E.private.actionbar.masque.actionbars)
	end

	AB:HandleBackdropMultiplier(bar, backdropSpacing, buttonSpacing, db.widthMult, db.heightMult, anchorUp, anchorLeft, horizontal, lastShownButton, anchorRowButton)
	AB:HandleBackdropMover(bar, backdropSpacing)

	if Masque and E.private.actionbar.masque.actionbars then
		AB:UpdateMasque(bar)
	end

	if enabled then
		E:EnableMover(bar.mover.name)
		bar:Show()

		local visibility = gsub(db.visibility, '[\n\r]', '')
		RegisterStateDriver(bar, 'visibility', visibility)
	else
		E:DisableMover(bar.mover.name)
		bar:Hide()

		UnregisterStateDriver(bar, 'visibility')
	end

	E:SetMoverSnapOffset('ElvAB_'..bar.id, db.buttonSpacing * 0.5)
end

function AB:CreateBar(id)
	local barName = 'ElvUI_Bar'..id
	local bar = CreateFrame('Frame', barName, E.UIParent, 'SecureHandlerStateTemplate')
	SecureHandlerSetFrameRef(bar, 'MainMenuBarArtFrame', _G.MainMenuBarArtFrame)

	bar.MasqueGroup = Masque and Masque:Group('ElvUI', format('ActionBar %d', id))

	local barKey = 'bar'..id
	AB.handledBars[barKey] = bar

	local defaults = AB.barDefaults[barKey]
	local point, anchor, attachTo, x, y = strsplit(',', defaults.position)
	bar:Point(point, anchor, attachTo, x, y)
	bar.id = id

	bar:CreateBackdrop(AB.db.transparent and 'Transparent', nil, nil, nil, nil, nil, nil, nil, 0)

	bar.buttons = {}
	bar.bindButtons = defaults.bindButtons
	AB:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
	AB:HookScript(bar, 'OnLeave', 'Bar_OnLeave')

	for i = 1, 12 do
		local button = LAB:CreateButton(i, format('%sButton%d', barName, i), bar)

		button.cooldown.targetAura = true
		E:RegisterCooldown(button.cooldown, 'actionbar')

		button.MasqueSkinned = true -- skip LAB styling (we handle it and masque as well)

		if Masque and E.private.actionbar.masque.actionbars then
			button:AddToMasque(bar.MasqueGroup)
		end

		AB:HookScript(button, 'OnEnter', 'Button_OnEnter')
		AB:HookScript(button, 'OnLeave', 'Button_OnLeave')

		button.parentName = barName
		bar.buttons[i] = button
	end

	if defaults.conditions and strfind(defaults.conditions, '[form,noform]') then
		bar:SetAttribute('newCondition', gsub(defaults.conditions, ' %[form,noform%] 0; ', ''))
		bar:SetAttribute('hasTempBar', true)
	else
		bar:SetAttribute('hasTempBar', false)
	end

	bar:SetAttribute('_onstate-page', [[
		if newstate ~= 0 then
			self:SetAttribute('state', newstate)
			control:ChildUpdate('state', newstate)
		else
			local newCondition = self:GetAttribute('newCondition')
			if newCondition then
				newstate = SecureCmdOptionParse(newCondition)
				self:SetAttribute('state', newstate)
				control:ChildUpdate('state', newstate)
			end
		end
	]])

	E:CreateMover(bar, 'ElvAB_'..id, L["Bar "]..id, nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,playerBars,bar'..id)

	return bar
end

function AB:PLAYER_REGEN_ENABLED()
	if AB.NeedsUpdateButtonSettings then
		AB:UpdateButtonSettings()
		AB.NeedsUpdateButtonSettings = nil
	end
	if AB.NeedsUpdateMicroBarVisibility then
		AB:UpdateMicroBarVisibility()
		AB.NeedsUpdateMicroBarVisibility = nil
	end
	if AB.NeedsAdjustMaxStanceButtons then
		AB:AdjustMaxStanceButtons(AB.NeedsAdjustMaxStanceButtons) --sometimes it holds the event, otherwise true. pass it before we nil it.
		AB.NeedsAdjustMaxStanceButtons = nil
	end
	if AB.NeedsPositionAndSizeTotemBar then
		AB:PositionAndSizeTotemBar()
		AB.NeedsPositionAndSizeTotemBar = nil
	end
	if AB.NeedsRecallButtonUpdate then
		AB:MultiCastRecallSpellButton_Update()
		AB.NeedsRecallButtonUpdate = nil
	end

	AB:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function AB:CreateVehicleLeave()
	local db = E.db.actionbar.vehicleExitButton
	if not db.enable then return end

	local button = _G.MainMenuBarVehicleLeaveButton
	local holder = CreateFrame('Frame', 'VehicleLeaveButtonHolder', E.UIParent)
	holder:Point('BOTTOM', E.UIParent, 0, 300)
	holder:Size(button:GetSize())
	E:CreateMover(holder, 'VehicleLeaveButton', L["VehicleLeaveButton"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraButtons,vehicleExitButton')

	button:ClearAllPoints()
	button:SetParent(UIParent)
	button:Point('CENTER', holder)

	-- taints because of EditModeManager, in UpdateBottomActionBarPositions
	button:SetScript('OnShow', nil)
	button:SetScript('OnHide', nil)

	if Masque and E.private.actionbar.masque.actionbars then
		button:StyleButton(true, true, true)
		VehicleMasqueGroup:AddButton(button)
	else
		button:CreateBackdrop(nil, true)
		button:GetNormalTexture():SetTexCoord(0.140625 + .08, 0.859375 - .06, 0.140625 + .08, 0.859375 - .08)
		button:GetPushedTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
		button:StyleButton(nil, true, true)

		hooksecurefunc(button, 'SetHighlightTexture', function(btn, tex)
			if tex ~= btn.hover then
				button:SetHighlightTexture(btn.hover)
			end
		end)
	end

	hooksecurefunc(button, 'SetPoint', function(_, _, parent)
		if parent ~= holder then
			button:ClearAllPoints()
			button:SetParent(UIParent)
			button:Point('CENTER', holder)
		end
	end)

	AB:UpdateVehicleLeave()
end

function AB:UpdateVehicleLeave()
	local db = E.db.actionbar.vehicleExitButton
	_G.MainMenuBarVehicleLeaveButton:Size(db.size)
	_G.MainMenuBarVehicleLeaveButton:SetFrameStrata(db.strata)
	_G.MainMenuBarVehicleLeaveButton:SetFrameLevel(db.level)
	_G.VehicleLeaveButtonHolder:Size(db.size)

	if Masque and E.private.actionbar.masque.actionbars then
		AB:UpdateMasque(nil, VehicleMasqueGroup)
	end
end

function AB:UpdateVehicleShown(event)
	local button = _G.MainMenuBarVehicleLeaveButton
	if event == "UNIT_ENTERED_VEHICLE" then
		button:Show()
	elseif event == "UNIT_EXITED_VEHICLE" then
		button:Hide()
	end
end

function AB:ReassignBindings(event)
	if event == 'UPDATE_BINDINGS' then
		AB:UpdatePetBindings()
		AB:UpdateStanceBindings()

		if E.myclass == 'SHAMAN' then
			AB:UpdateTotemBindings()
		end
	end

	AB:UnregisterEvent('PLAYER_REGEN_DISABLED')

	if InCombatLockdown() then return end

	for _, bar in pairs(AB.handledBars) do
		if bar then
			ClearOverrideBindings(bar)

			for _, button in ipairs(bar.buttons) do
				if button.keyBoundTarget then
					for _, key in next, { GetBindingKey(button.keyBoundTarget) } do
						if key ~= '' then
							SetOverrideBindingClick(bar, false, key, button:GetName())
						end
					end
				end
			end
		end
	end
end

function AB:RemoveBindings()
	if InCombatLockdown() then return end

	for _, bar in pairs(AB.handledBars) do
		if bar then
			ClearOverrideBindings(bar)
		end
	end

	AB:RegisterEvent('PLAYER_REGEN_DISABLED', 'ReassignBindings')
end

do
	local texts = { 'hotkey', 'macro', 'count' }
	local bars = { 'barPet', 'stanceBar', 'vehicleExitButton' }

	local function saveSetting(option, value)
		for i = 1, 10 do
			E.db.actionbar['bar'..i][option] = value
		end

		for _, bar in pairs(bars) do
			E.db.actionbar[bar][option] = value
		end
	end

	function AB:ApplyTextOption(option, value, fonts)
		if fonts then
			local upperOption = gsub(option, '^%w', strupper) -- font>Font, fontSize>FontSize, fontOutline>FontOutline
			for _, object in pairs(texts) do
				saveSetting(object..upperOption, value)
			end
		else
			saveSetting(option, value)
		end

		AB:UpdateButtonSettings()
	end
end

function AB:UpdateButtonSettings(specific)
	if not E.private.actionbar.enable then return end

	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	for barName, bar in pairs(AB.handledBars) do
		if not specific or specific == barName then
			AB:UpdateButtonConfig(barName, bar.bindButtons) -- config them first
			AB:PositionAndSizeBar(barName) -- db is set here, button style also runs here
		end
	end

	if not specific then
		AB:AdjustMaxStanceButtons()
		AB:PositionAndSizeBarPet()
		AB:PositionAndSizeBarShapeShift()

		AB:UpdatePetBindings()
		AB:UpdateStanceBindings() -- call after AdjustMaxStanceButtons

		if E.myclass == 'SHAMAN' and AB.db.totemBar.enable then
			AB:PositionAndSizeTotemBar()
		end
	end
end

function AB:GetPage(bar, defaultPage, condition)
	if not condition then condition = '' end

	local page = AB.db[bar].paging[E.myclass]
	if page then condition = condition..' '..gsub(page, '[\n\r]', '') end

	return condition..' '..defaultPage
end

function AB:StyleButton(button, noBackdrop, useMasque, ignoreNormal)
	local name = button:GetName()
	local icon = button.icon or _G[name..'Icon']
	local hotkey = button.HotKey or _G[name..'HotKey']
	local shine = button.AutoCastShine or _G[name..'Shine']
	local flash = button.Flash or _G[name..'Flash']
	local border = button.Border or _G[name..'Border']
	local normal = button.NormalTexture or _G[name..'NormalTexture']
	local normal2 = button:GetNormalTexture()
	local cooldown = _G[name..'Cooldown']

	button.noBackdrop = noBackdrop
	button.useMasque = useMasque
	button.ignoreNormal = ignoreNormal

	icon:SetDrawLayer('ARTWORK', -1)
	hotkey:SetDrawLayer('OVERLAY')
	hotkey:SetParent(button) -- otherwise its on level 500 thanks to ActionButtonTextOverlayContainerMixin

	if normal and not ignoreNormal then normal:SetTexture() normal:Hide() normal:SetAlpha(0) end
	if normal2 then normal2:SetTexture() normal2:Hide() normal2:SetAlpha(0) end
	if border and not button.useMasque then border:Kill() end

	if not button.noBackdrop and not button.useMasque then
		button:SetTemplate(AB.db.transparent and 'Transparent', true)
	end

	if flash then
		if AB.db.flashAnimation then
			local flashOffset = E.PixelMode and 2 or 4

			flash:SetTexture(1.0, 0.2, 0.2, 0.45)
			flash:ClearAllPoints()
			flash:SetOutside(icon, flashOffset, flashOffset)
			flash:SetDrawLayer('BACKGROUND', -1)
		else
			flash:SetTexture()
		end
	end

	if useMasque then -- note: trim handled after masque messes with it
		button:StyleButton(true, true, true)
	else
		button:StyleButton()
		AB:TrimIcon(button)
		icon:SetInside()
	end

	if shine then
		shine:SetAllPoints()
	end

	if not ignoreNormal then -- stance buttons dont need this
		button.FlyoutUpdateFunc = AB.StyleFlyout
	end

	if not AB.handledbuttons[button] then
		E:RegisterCooldown(cooldown, 'actionbar')
		AB.handledbuttons[button] = true
	end

	AB:FixKeybindText(button)
end

function AB:UpdateMasque(bar, masqueGroup)
	local masque = (bar and bar.MasqueGroup) or masqueGroup
	masque:ReSkin()

	if bar and bar.buttons then -- masque retrims them all so we have to too
		for _, btn in next, bar.buttons do
			AB:TrimIcon(btn, true)
		end
	end
end

function AB:ColorSwipeTexture(cooldown)
	if not cooldown then return end

	local color = AB.db.colorSwipeNormal
	cooldown:SetSwipeColor(color.r, color.g, color.b, color.a)
end

function AB:Bar_OnEnter(bar)
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha or 1)
	end
end

function AB:Bar_OnLeave(bar)
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		local a = 1 - (AB.db.globalFadeAlpha or 0)
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha or 1)
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		local a = 1 - (AB.db.globalFadeAlpha or 0)
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:BlizzardOptionsPanel_OnEvent()
	_G.InterfaceOptionsActionBarsPanelBottomRightText:SetFormattedText(L["Remove Bar %d Action Page"], 2)
	_G.InterfaceOptionsActionBarsPanelBottomLeftText:SetFormattedText(L["Remove Bar %d Action Page"], 3)
	_G.InterfaceOptionsActionBarsPanelRightTwoText:SetFormattedText(L["Remove Bar %d Action Page"], 4)
	_G.InterfaceOptionsActionBarsPanelRightText:SetFormattedText(L["Remove Bar %d Action Page"], 5)

	_G.InterfaceOptionsActionBarsPanelBottomRight:SetScript('OnEnter', nil)
	_G.InterfaceOptionsActionBarsPanelBottomLeft:SetScript('OnEnter', nil)
	_G.InterfaceOptionsActionBarsPanelRightTwo:SetScript('OnEnter', nil)
	_G.InterfaceOptionsActionBarsPanelRight:SetScript('OnEnter', nil)

	_G.InterfaceOptionsActionBarsPanelRightTwo:PointXY(0, -8)

	_G.InterfaceOptionsActionBarsPanelSecureAbilityToggle:ClearAllPoints()
	_G.InterfaceOptionsActionBarsPanelSecureAbilityToggle:Point('TOPLEFT', _G.InterfaceOptionsActionBarsPanelRightTwo, 'BOTTOMLEFT', 0, -8)
end

do
	function AB:FadeParent_OnEvent()
		if UnitCastingInfo('player') or UnitChannelInfo('player') or UnitExists('target') or UnitExists('focus') or UnitExists('vehicle')
		or UnitAffectingCombat('player') or (UnitHealth('player') ~= UnitHealthMax('player')) or IsPossessBarVisible() then
			self.mouseLock = true
			E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
		else
			self.mouseLock = false
			local a = 1 - (AB.db.globalFadeAlpha or 0)
			E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), a)
		end
	end
end

local noops = { 'ClearAllPoints', 'SetPoint', 'SetScale', 'SetShown' }
function AB:SetNoopsi(frame)
	if not frame then return end
	for _, func in pairs(noops) do
		if frame[func] ~= E.noop then
			frame[func] = E.noop
		end
	end
end

do
	local untaint = {
		ShapeshiftBarFrame = true,
		MainMenuBarArtFrame = true,
		ReputationWatchBar = true,
		MainMenuExpBar = true,
		MultiBarLeft = true,
		VehicleMenuBar = true,
		MultiBarRight = true,
		MultiBarBottomLeft = true,
		MultiBarBottomRight = true,
		MainMenuBar = true,
		BonusActionBarFrame = true,
		PetActionBarFrame = true,
		PossessBarFrame = true
	}

	_G.UIPARENT_MANAGED_FRAME_POSITIONS.MultiCastActionBarFrame = nil -- TotemBar needs to be handled by us

	function AB:DisableBlizzard()
		for name in next, untaint do
			_G.UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil

			local frame = _G[name]
			if frame then
				frame:SetParent(E.HiddenFrame)
				frame:UnregisterAllEvents()

				AB:SetNoopsi(frame)
			end
		end

		-- Spellbook open in combat taint, only happens sometimes
		MultiActionBar_HideAllGrids = E.noop
		MultiActionBar_ShowAllGrids = E.noop

		-- Hide MultiBar Buttons, but keep the bars alive
		local buttons = {
			'ActionButton',
			'MultiBarBottomLeftButton',
			'MultiBarBottomRightButton',
			'MultiBarRightButton',
			'MultiBarLeftButton',
			'BonusActionButton',
			'VehicleMenuBarActionButton',
		}

		for i = 1, 12 do
			for _, buttonPrefix in ipairs(buttons) do
				local button = _G[buttonPrefix..i]
				if button then
					button:Hide()
					button:UnregisterAllEvents()
					button:SetAttribute('statehidden', true)
				end
			end
		end

		_G.InterfaceOptionsActionBarsPanelRightTwoText:SetTextColor(1,1,1) -- no yellow
		_G.InterfaceOptionsActionBarsPanelRightTwoText.SetTextColor = E.noop -- i said no yellow
		_G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
		_G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
		_G.InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
		_G.InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)
		_G.InterfaceOptionsStatusTextPanelXP:SetAlpha(0)
		_G.InterfaceOptionsStatusTextPanelXP:SetScale(0.0001)
		_G.InterfaceOptionsCombatPanelAutoSelfCast:Hide()
		_G.InterfaceOptionsCombatPanelSelfCastKeyDropDown:Hide()
		_G.InterfaceOptionsCombatPanelFocusCastKeyDropDown:Hide()

		AB:SecureHook('BlizzardOptionsPanel_OnEvent')

		if E.myclass ~= 'SHAMAN' then
			for i = 1, 12 do
				local button = _G['MultiCastActionButton'..i]
				button:Hide()
				button:UnregisterAllEvents()
				button:SetAttribute('statehidden', true)
			end
		end

		if _G.PlayerTalentFrame then
			_G.PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		else
			hooksecurefunc('TalentFrame_LoadUI', function()
				_G.PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
			end)
		end
	end
end

function AB:ToggleCountDownNumbers(bar, button, cd)
	if cd then -- ref: E:CreateCooldownTimer
		local b = cd.GetParent and cd:GetParent()
		if cd.timer and (b and b.config) then
			-- update the new cooldown timer button config with the new setting
			b.config.disableCountDownNumbers = not not E:ToggleBlizzardCooldownText(cd, cd.timer, true)
		end
	elseif button then -- ref: AB:UpdateButtonConfig
		if button.cooldown and button.cooldown.timer and (bar and bar.buttonConfig) then
			-- button.config will get updated from `button:UpdateConfig` in `AB:UpdateButtonConfig`
			bar.buttonConfig.disableCountDownNumbers = not not E:ToggleBlizzardCooldownText(button.cooldown, button.cooldown.timer, true)
		end
	elseif bar then -- ref: E:UpdateCooldownOverride
		if bar.buttons then
			for _, btn in ipairs(bar.buttons) do
				if btn and btn.config and (btn.cooldown and btn.cooldown.timer) then
					-- update the buttons config
					btn.config.disableCountDownNumbers = not not E:ToggleBlizzardCooldownText(btn.cooldown, btn.cooldown.timer, true)
				end
			end
			if bar.buttonConfig then
				-- we can actually clear this variable because it wont get used when this code runs
				bar.buttonConfig.disableCountDownNumbers = nil
			end
		end
	end
end

function AB:GetTextJustify(anchor)
	return (anchor == 'TOPLEFT' or anchor == 'BOTTOMLEFT') and 'LEFT' or (anchor == 'TOP' or anchor == 'BOTTOM') and 'CENTER' or 'RIGHT'
end

function AB:GetHotkeyConfig(db)
	local font = LSM:Fetch('font', db and db.hotkeyFont or AB.db.font)
	local size = db and db.hotkeyFontSize or AB.db.fontSize
	local flags = db and db.hotkeyFontOutline or AB.db.font

	local anchor = db and db.hotkeyTextPosition or 'TOPRIGHT'
	local offsetX = db and db.hotkeyTextXOffset or 0
	local offsetY = db and db.hotkeyTextYOffset or -3

	local color = db and db.useHotkeyColor and db.hotkeyColor or AB.db.fontColor
	local show = not (db and not db.hotkeytext)

	return font, size, flags, anchor, offsetX, offsetY, AB:GetTextJustify(anchor), { color.r or 1, color.g or 1, color.b or 1 }, show
end

do
	local fixBars = {}
	function AB:GetKeyTarget(buttonName, id)
		return format('%s%d', fixBars[buttonName] or buttonName, id)
	end
end

function AB:UpdateButtonConfig(barName, buttonName)
	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local bar = AB.handledBars[barName]
	if not bar.buttonConfig then
		bar.buttonConfig = E:CopyTable({}, buttonDefaults)
	end

	local config = bar.buttonConfig
	local text = config.text
	local db = AB.db[barName]

	do -- hotkey text
		local font, size, flags, anchor, offsetX, offsetY, justify, color = AB:GetHotkeyConfig(db)
		text.hotkey.color = color
		text.hotkey.font.font = font
		text.hotkey.font.size = size
		text.hotkey.font.flags = flags
		text.hotkey.position.anchor = anchor
		text.hotkey.position.relAnchor = false
		text.hotkey.position.offsetX = offsetX
		text.hotkey.position.offsetY = offsetY
		text.hotkey.justifyH = justify
	end

	do -- count text
		text.count.font.font = LSM:Fetch('font', db and db.countFont or AB.db.font)
		text.count.font.size = db and db.countFontSize or AB.db.fontSize
		text.count.font.flags = db and db.countFontOutline or AB.db.font
		text.count.position.anchor = db and db.countTextPosition or 'BOTTOMRIGHT'
		text.count.position.relAnchor = false
		text.count.position.offsetX = db and db.countTextXOffset or 0
		text.count.position.offsetY = db and db.countTextYOffset or 2
		text.count.justifyH = AB:GetTextJustify(text.count.position.anchor)

		local c = db and db.useCountColor and db.countColor or AB.db.fontColor
		text.count.color = { c.r, c.g, c.b }
	end

	do -- macro text
		text.macro.font.font = LSM:Fetch('font', db and db.macroFont or AB.db.font)
		text.macro.font.size = db and db.macroFontSize or AB.db.fontSize
		text.macro.font.flags = db and db.macroFontOutline or AB.db.font
		text.macro.position.anchor = db and db.macroTextPosition or 'BOTTOM'
		text.macro.position.relAnchor = false
		text.macro.position.offsetX = db and db.macroTextXOffset or 0
		text.macro.position.offsetY = db and db.macroTextYOffset or 1
		text.macro.justifyH = AB:GetTextJustify(text.macro.position.anchor)

		local c = db and db.useMacroColor and db.macroColor or AB.db.fontColor
		text.macro.color = { c.r, c.g, c.b }
	end

	config.hideElements.count = not db.counttext
	config.hideElements.macro = not db.macrotext
	config.hideElements.hotkey = not db.hotkeytext

	config.showGrid = db.showGrid
	config.clickOnDown = AB.db.keyDown
	config.outOfRangeColoring = (AB.db.useRangeColorText and 'hotkey') or 'button'
	config.colors.range = E:SetColorTable(config.colors.range, AB.db.noRangeColor)
	config.colors.mana = E:SetColorTable(config.colors.mana, AB.db.noPowerColor)
	config.colors.usable = E:SetColorTable(config.colors.usable, AB.db.usableColor)
	config.colors.notUsable = E:SetColorTable(config.colors.notUsable, AB.db.notUsableColor)
	config.handleOverlay = AB.db.handleOverlay
	SetModifiedClick('PICKUPACTION', AB.db.movementModifier)

	if not buttonName then
		buttonName = bar.bindButtons
	end

	for i, button in ipairs(bar.buttons) do
		AB:ToggleCountDownNumbers(bar, button)

		local keyTarget = AB:GetKeyTarget(buttonName, i)
		config.keyBoundTarget = keyTarget -- for LAB
		button.keyBoundTarget = keyTarget -- for bind mode
		button.postKeybind = AB.FixKeybindText

		button:SetAttribute('buttonlock', AB.db.lockActionBars or nil)
		button:SetAttribute('checkselfcast', AB.db.checkSelfCast or nil)
		button:SetAttribute('checkfocuscast', AB.db.checkFocusCast or nil)
		button:SetAttribute('unit2', AB.db.rightClickSelfCast and 'player' or nil)

		button:UpdateConfig(bar.buttonConfig)
	end
end

do
	local stockFont, stockFontSize, stockFontOutline
	if E.locale == 'koKR' then
		stockFont, stockFontSize, stockFontOutline = [[Fonts\2002.TTF]], 11, 'MONOCHROME, THICKOUTLINE'
	elseif E.locale == 'zhTW' then
		stockFont, stockFontSize, stockFontOutline = [[Fonts\arheiuhk_bd.TTF]], 11, 'MONOCHROME, THICKOUTLINE'
	elseif E.locale == 'zhCN' then
		stockFont, stockFontSize, stockFontOutline = [[Fonts\FRIZQT__.TTF]], 11, 'MONOCHROME, OUTLINE'
	else
		stockFont, stockFontSize, stockFontOutline = [[Fonts\ARIALN.TTF]], 12, 'MONOCHROME, THICKOUTLINE'
	end

	-- handle for pet/stance/etc not main bars
	function AB:FixKeybindColor(button)
		local hotkey = _G[button:GetName()..'HotKey']
		if not hotkey then return end

		local font, size, flags, anchor, offsetX, offsetY, justify, color, show = AB:GetHotkeyConfig(button:GetParent().db)

		hotkey:SetShown(show)

		local text = hotkey:GetText()
		if text == _G.RANGE_INDICATOR then
			hotkey:SetFont(stockFont, stockFontSize, stockFontOutline)
			hotkey:SetTextColor(0.9, 0.9, 0.9)
		elseif text then
			hotkey:FontTemplate(font, size, flags)
			hotkey:SetTextColor(unpack(color))
		end

		if not button.useMasque then
			hotkey:SetJustifyH(justify)
			hotkey:ClearAllPoints()
			hotkey:Point(anchor, offsetX, offsetY)
		end
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName()..'HotKey']
	local text = hotkey:GetText()
	if text and text ~= _G.RANGE_INDICATOR then
		text = gsub(text, 'SHIFT%-', L["KEY_SHIFT"])
		text = gsub(text, 'ALT%-', L["KEY_ALT"])
		text = gsub(text, 'CTRL%-', L["KEY_CTRL"])
		text = gsub(text, 'BUTTON', L["KEY_MOUSEBUTTON"])
		text = gsub(text, 'MOUSEWHEELUP', L["KEY_MOUSEWHEELUP"])
		text = gsub(text, 'MOUSEWHEELDOWN', L["KEY_MOUSEWHEELDOWN"])
		text = gsub(text, 'NUMPAD', L["KEY_NUMPAD"])
		text = gsub(text, 'PAGEUP', L["KEY_PAGEUP"])
		text = gsub(text, 'PAGEDOWN', L["KEY_PAGEDOWN"])
		text = gsub(text, 'SPACE', L["KEY_SPACE"])
		text = gsub(text, 'INSERT', L["KEY_INSERT"])
		text = gsub(text, 'HOME', L["KEY_HOME"])
		text = gsub(text, 'DELETE', L["KEY_DELETE"])
		text = gsub(text, 'NMULTIPLY', L["KEY_NMULTIPLY"])
		text = gsub(text, 'NMINUS', L["KEY_NMINUS"])
		text = gsub(text, 'NPLUS', L["KEY_NPLUS"])
		text = gsub(text, 'NEQUALS', L["KEY_NEQUALS"])

		hotkey:SetText(text)
	end
end

function AB:UpdateAuraCooldown(button, duration)
	local cd = button and button.AuraCooldown
	if not cd then return end

	local oldstate = cd.hideText
	cd.hideText = (not E.db.cooldown.targetAura) or (duration and duration > 1.5) or nil
	if cd.timer and (oldstate ~= cd.hideText) then
		E:ToggleBlizzardCooldownText(cd, cd.timer)
		E:Cooldown_TimerUpdate(cd.timer)
	end
end

function AB:SetAuraCooldownDuration(value)
	LAB:SetAuraCooldownDuration(value)
end

function AB:SetAuraCooldowns(enabled)
	local enable, reverse = E.db.cooldown.enable, E.db.actionbar.cooldown.reverse
	LAB:SetAuraCooldowns(enabled and (enable and not reverse) or (not enable and reverse))
end

function AB:ToggleCooldownOptions()
	for button in pairs(LAB.actionButtons) do
		if button._state_type == 'action' then
			local _, duration = button:GetCooldown()
			AB:SetButtonDesaturation(button, duration)
			AB:UpdateAuraCooldown(button, duration)
		end
	end
end

function AB:SetButtonDesaturation(button, duration)
	if AB.db.desaturateOnCooldown and (duration and duration > 1.5) then
		button.icon:SetDesaturated(true)
		AB:LAB_CooldownDone(button)
	else
		button.icon:SetDesaturated(false)
	end
end

function AB:LAB_MouseUp()
	if self.config.clickOnDown then
		self:GetPushedTexture():SetAlpha(0)
	end
end

function AB:LAB_MouseDown()
	if self.config.clickOnDown then
		self:GetPushedTexture():SetAlpha(1)
	end
end

function AB:LAB_ButtonCreated(button)
	-- this fixes Key Down getting the pushed texture stuck
	button:HookScript('OnMouseUp', AB.LAB_MouseUp)
	button:HookScript('OnMouseDown', AB.LAB_MouseDown)
end

function AB:LAB_ButtonUpdate(button)
	if button.SetBackdropBorderColor then
		local border = (AB.db.equippedItem and button:IsEquipped() and AB.db.equippedItemColor) or E.db.general.bordercolor
		button:SetBackdropBorderColor(border.r, border.g, border.b)
	end
end

function AB:LAB_CooldownDone(button)
	local cd = button.cooldown
	if not cd then return end

	if not cd.cooldownDoneHooked then
		cd:HookScript("OnHide", function(self)
			local parent = self:GetParent()
			if parent and parent.icon then
				parent.icon:SetDesaturated(false)
			end
		end)

		cd.cooldownDoneHooked = true
	end
end

function AB:LAB_CooldownUpdate(button, _, duration)
	if button._state_type == 'action' then
		AB:SetButtonDesaturation(button, duration)
		AB:UpdateAuraCooldown(button, duration)
	end

	if button.cooldown then
		AB:ColorSwipeTexture(button.cooldown)
	end
end

function AB:PLAYER_ENTERING_WORLD(event)
	AB:AdjustMaxStanceButtons(event)

	if not AB:IsHooked('ShowMultiCastActionBar') and E.myclass == 'SHAMAN' and AB.db.totemBar.enable then
		AB:SecureHook('ShowMultiCastActionBar', 'PositionAndSizeTotemBar')
		AB:PositionAndSizeTotemBar()
	end
end

function AB:RegisterMacro(addon)
	if addon == 'Blizzard_MacroUI' then
		for i = 1, MAX_ACCOUNT_MACROS do
			local button = _G['MacroButton'..i]
			button:HookScript('OnEnter', function(b) AB:BindUpdate(b, 'MACRO') end)
		end
	end
end

function AB:Initialize()
	_G.BINDING_HEADER_ELVUI = E.title

	for _, barNumber in pairs({2, 7, 8, 9, 10}) do
		for slot = 1, 12 do
			_G[format('BINDING_NAME_ELVUIBAR%dBUTTON%d', barNumber, slot)] = format('ActionBar %d Button %d', barNumber, slot)
		end
	end

	if not E.private.actionbar.enable then return end
	AB.Initialized = true

	LAB.RegisterCallback(AB, 'OnButtonUpdate', AB.LAB_ButtonUpdate)
	LAB.RegisterCallback(AB, 'OnButtonCreated', AB.LAB_ButtonCreated)
	LAB.RegisterCallback(AB, 'OnCooldownUpdate', AB.LAB_CooldownUpdate)

	AB.fadeParent = CreateFrame('Frame', 'Elv_ABFade', UIParent)
	AB.fadeParent:SetAlpha(1 - AB.db.globalFadeAlpha)
	AB.fadeParent:RegisterEvent('PLAYER_REGEN_DISABLED')
	AB.fadeParent:RegisterEvent('PLAYER_REGEN_ENABLED')
	AB.fadeParent:RegisterEvent('PLAYER_TARGET_CHANGED')
	AB.fadeParent:RegisterEvent('UNIT_SPELLCAST_START')
	AB.fadeParent:RegisterEvent('UNIT_SPELLCAST_STOP')
	AB.fadeParent:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START')
	AB.fadeParent:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')
	AB.fadeParent:RegisterEvent('UNIT_HEALTH')
	AB.fadeParent:RegisterEvent('PLAYER_FOCUS_CHANGED')
	AB.fadeParent:RegisterEvent('VEHICLE_UPDATE')

	AB.fadeParent:SetScript('OnEvent', AB.FadeParent_OnEvent)

	AB:DisableBlizzard()
	AB:SetupMicroBar()
	AB:UpdateBar1Paging()

	for i = 1, 10 do
		AB:CreateBar(i)
	end

	AB:CreateBarPet()
	AB:CreateBarShapeShift()
	AB:CreateVehicleLeave()
	AB:UpdateButtonSettings()
	AB:UpdatePetCooldownSettings()
	AB:ToggleCooldownOptions()
	AB:LoadKeyBinder()

	if not IsAddOnLoaded('Blizzard_MacroUI') then
		AB:SecureHook('LoadAddOn', 'RegisterMacro')
	else
		AB:RegisterMacro('Blizzard_MacroUI')
	end

	AB:RegisterEvent('PLAYER_ENTERING_WORLD')
	AB:RegisterEvent('UPDATE_BINDINGS', 'ReassignBindings')
	AB:RegisterEvent('UNIT_ENTERED_VEHICLE', 'UpdateVehicleShown')
	AB:RegisterEvent('UNIT_EXITED_VEHICLE', 'UpdateVehicleShown')

	if E.myclass == 'SHAMAN' and AB.db.totemBar.enable then
		AB:CreateTotemBar()
	end

	AB:ReassignBindings()

	-- We handle actionbar lock for regular bars, but the lock on PetBar needs to be handled by WoW so make some necessary updates
	E:SetCVar('lockActionBars', (AB.db.lockActionBars == true and 1 or 0))
	_G.LOCK_ACTIONBAR = (AB.db.lockActionBars == true and '1' or '0') -- Keep an eye on this, in case it taints
end

E:RegisterModule(AB:GetName())