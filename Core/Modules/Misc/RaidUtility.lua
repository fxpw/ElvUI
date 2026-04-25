local E, L, V, P, G = unpack(ElvUI)
local RU = E:GetModule('RaidUtility')
local S = E:GetModule('Skins')
local LC = E.Libs.Compat

local _G = _G
local unpack, next, mod, floor = unpack, next, mod, floor
local strsub, format, gsub, tostring, type = strsub, format, gsub, tostring, type
local strfind, tinsert, wipe, sort = strfind, tinsert, wipe, sort

local CloseDropDownMenus = CloseDropDownMenus
local ConvertToRaid = ConvertToRaid
local CreateFrame = CreateFrame
local DoReadyCheck = DoReadyCheck
local GameTooltip_Hide = GameTooltip_Hide
local GetDungeonDifficulty = GetDungeonDifficulty
local GetInstanceInfo = GetInstanceInfo
local GetRaidDifficulty = GetRaidDifficulty
local GetRaidRosterInfo = GetRaidRosterInfo
local GetTexCoordsByGrid = GetTexCoordsByGrid
local InCombatLockdown = InCombatLockdown
local SendChatMessage = SendChatMessage
local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef
local SecureHandler_OnClick = SecureHandler_OnClick
local ToggleFriendsFrame = ToggleFriendsFrame
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local SetDungeonDifficulty = SetDungeonDifficulty
local SetRaidDifficulty = SetRaidDifficulty
local SetRaidTarget = SetRaidTarget
local ResetInstances = ResetInstances
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitName = UnitName

local IsInGroup = LC.IsInGroup
local IsInRaid = LC.IsInRaid
local GetNumGroupMembers = LC.GetNumGroupMembers
local UnitIsGroupLeader = LC.UnitIsGroupLeader
local UnitIsGroupAssistant = LC.UnitIsGroupAssistant

local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local NUM_RAID_GROUPS = NUM_RAID_GROUPS
local PANEL_HEIGHT = 152
local PANEL_WIDTH = 250
local BUTTON_HEIGHT = 20
local TARGET_SIZE = 22

local countdownInProgress = false
local countdownTimer = nil

local groupMenuList = {
	{ text = _G.DUNGEON_DIFFICULTY, isTitle = true, notCheckable = true },
	{ text = _G.DUNGEON_DIFFICULTY1, checked = function() return GetDungeonDifficulty() == 1 end, func = function() SetDungeonDifficulty(1) end },
	{ text = _G.DUNGEON_DIFFICULTY2, checked = function() return GetDungeonDifficulty() == 2 end, func = function() SetDungeonDifficulty(2) end },
	{ text = '', isTitle = true, notCheckable = true },
	{ text = _G.RESET_INSTANCES, notCheckable = true, func = function() ResetInstances() end},
}

local raidMenuList = {
	{ text = _G.RAID_DIFFICULTY, isTitle = true, notCheckable = true},
    { text = _G.RAID_DIFFICULTY1, checked = function() return GetRaidDifficulty() == 1 end, func = function() SetRaidDifficulty(1) end },
    { text = _G.RAID_DIFFICULTY2, checked = function() return GetRaidDifficulty() == 2 end, func = function() SetRaidDifficulty(2) end },
    { text = _G.RAID_DIFFICULTY3, checked = function() return GetRaidDifficulty() == 3 end, func = function() SetRaidDifficulty(3) end },
    { text = _G.RAID_DIFFICULTY4, checked = function() return GetRaidDifficulty() == 4 end, func = function() SetRaidDifficulty(4) end },
	{ text = '', isTitle = true, notCheckable = true },
	{ text = _G.RESET_INSTANCES, notCheckable = true, func = function() ResetInstances() end},
}

local roleIcons = {
	TANK = E:TextureString(E.Media.Textures.Tank, ':15:15:0:0:64:64:2:56:2:56'),
	HEALER = E:TextureString(E.Media.Textures.Healer, ':15:15:0:0:64:64:2:56:2:56'),
	DAMAGER = E:TextureString(E.Media.Textures.DPS, ':15:15')
}

local openMenu = {}
local raidMarkers = {}
local roleRoster = {}
local roleCount = {}
local roles = {
	{ role = 'TANK' },
	{ role = 'HEALER' },
	{ role = 'DAMAGER' }
}

local buttonEvents = {
	'RAID_ROSTER_UPDATE',
	'PARTY_LEADER_CHANGED'
}

local function SetGrabCoords(data, xOffset, yOffset)
	data.texA, data.texB, data.texC, data.texD = GetTexCoordsByGrid(xOffset, yOffset, 256, 256, 67, 67)
end

SetGrabCoords(roles[1], 1, 2)
SetGrabCoords(roles[2], 2, 1)
SetGrabCoords(roles[3], 2, 2)

local ShowButton = CreateFrame('Button', 'RaidUtility_ShowButton', E.UIParent, 'SecureHandlerClickTemplate')
ShowButton:SetMovable(true)
ShowButton:SetClampedToScreen(true)
ShowButton:SetClampRectInsets(0, 0, -1, 1)
ShowButton:Hide()

function RU:FixSecureClicks(button)
	button:RegisterForClicks('AnyDown', 'AnyUp')
end

function RU:SetEnabled(button, enabled, isLeader)
	if button.SetChecked then
		button:SetChecked(enabled)
	else
		button.enabled = enabled
	end

	if button.Text then -- show text grey when isLeader is false, nil and true should be white
		button.Text:SetFormattedText('%s%s|r', ((isLeader ~= nil and isLeader) or (isLeader == nil and enabled)) and '|cFFffffff' or '|cFF888888', button.label)
	end
end

function RU:CleanButton(button)
	button.BottomLeft:SetAlpha(0)
	button.BottomRight:SetAlpha(0)
	button.BottomMiddle:SetAlpha(0)
	button.TopMiddle:SetAlpha(0)
	button.TopLeft:SetAlpha(0)
	button.TopRight:SetAlpha(0)
	button.MiddleLeft:SetAlpha(0)
	button.MiddleRight:SetAlpha(0)
	button.MiddleMiddle:SetAlpha(0)

	button:SetHighlightTexture(E.ClearTexture)
	button:SetDisabledTexture(E.ClearTexture)
end

function RU:NotInPVP()
	local _, instanceType = GetInstanceInfo()
	return instanceType ~= 'pvp' and instanceType ~= 'arena'
end

function RU:IsLeader()
	return UnitIsGroupLeader('player') and RU:NotInPVP()
end

function RU:HasPermission()
	return (UnitIsGroupLeader('player') or UnitIsGroupAssistant('player')) and RU:NotInPVP()
end

function RU:InGroup()
	return IsInGroup() and RU:NotInPVP()
end

-- Change border when mouse is inside the button
function RU:OnEnter_Button()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
end

-- Change border back to normal when mouse leaves button
function RU:OnLeave_Button()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

function RU:CreateDropdown(name, parent, template, width, point, relativeto, point2, xOfs, yOfs, label, text, events, eventFunc, func, menuList)
    local data = type(name) == 'table' and name or nil
    local dropdown = data or CreateFrame('Button', name, parent, template)

    if events then
        dropdown:UnregisterAllEvents()

        for _, event in next, events do
            dropdown:RegisterEvent(event)
        end
    end

    dropdown:SetScript('OnEvent', eventFunc)

    if not dropdown:GetPoint() then
        dropdown:SetPoint(point, relativeto, point2, xOfs, yOfs)
    end

	if eventFunc then
		eventFunc(dropdown)
	end

    if not dropdown.label then -- stuff to do once
        dropdown.label = dropdown:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        dropdown.label:SetPoint('LEFT', dropdown, 'RIGHT', 4, 3)
		dropdown.label:SetText(label or '')
		dropdown.label:FontTemplate(nil, E.db.general.fontSize, 'SHADOW')

		S:HandleDropDownBox(dropdown, width)

		func(dropdown)
    end

    if not dropdown.text then -- stuff to do once
        dropdown.text = dropdown:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        dropdown.text:SetPoint('CENTER', dropdown, 'CENTER', 4, 3)
		dropdown.text:SetTextColor(1, 1, 1)
		dropdown.text:SetText(text or '')
		dropdown.text:FontTemplate(nil, E.db.general.fontSize, 'SHADOW')
    end

	dropdown.menuList = menuList

    dropdown:SetScript('OnClick', function(self)
		RU:ToggleDropdownMenu(self)
    end)

	-- Add click handler for the arrow button
	local button = _G[dropdown:GetName()..'Button']
	if button then
		button:SetScript('OnClick', function()
			RU:ToggleDropdownMenu(dropdown)
		end)
	end

    -- Ensure the label text is set
    self:OnSelect_DungeonDifficulty(dropdown, text)

    return dropdown
end

function RU:CreateCheckBox(name, parent, template, size, point, relativeto, point2, xOfs, yOfs, label, events, eventFunc, clickFunc)
	local checkbox = type(name) == 'table' and name
	local box = checkbox or CreateFrame('CheckButton', name, parent, template)
	box:Size(size)
	box.label = label or ''

	if events then
		box:UnregisterAllEvents()

		for _, event in next, events do
			box:RegisterEvent(event)
		end
	end

	box:SetScript('OnEvent', eventFunc)
	box:SetScript('OnClick', clickFunc)

	if not box.IsSkinned then
		S:HandleCheckBox(box)
	end

	if box.Text then
		box.Text:Point('LEFT', box, 'RIGHT', 2, 0)
		box.Text:SetText(box.label)
	end

	if not box:GetPoint() then
		box:Point(point, relativeto, point2, xOfs, yOfs)
	end

	if eventFunc then
		eventFunc(box)
	end

	RU.CheckBoxes[name] = box

	return box
end

-- Function to create buttons in this module
function RU:CreateUtilButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, label, texture, events, eventFunc, mouseFunc)
	local button = type(name) == 'table' and name
	local btn = button or CreateFrame('Button', name, parent, template)
	btn:HookScript('OnEnter', RU.OnEnter_Button)
	btn:HookScript('OnLeave', RU.OnLeave_Button)
	btn:Size(width, height)
	btn:SetTemplate(nil, true)
	btn.label = label or ''

	if events then
		btn:UnregisterAllEvents()

		for _, event in next, events do
			btn:RegisterEvent(event)
		end
	end

	btn:SetScript('OnEvent', eventFunc)
	btn:SetScript('OnMouseUp', mouseFunc)

	if not btn:GetPoint() then
		btn:Point(point, relativeto, point2, xOfs, yOfs)
	end

	if label then
		local text = btn:CreateFontString(nil, 'OVERLAY')
		text:FontTemplate()
		text:Point('CENTER', btn, 'CENTER', 0, -1)
		text:SetJustifyH('CENTER')
		text:SetText(btn.label)
		btn:SetFontString(text)
		btn.Text = text
	elseif texture then
		local tex = btn:CreateTexture(nil, 'OVERLAY')
		tex:SetTexture(texture)
		tex:Point('TOPLEFT', btn, 'TOPLEFT', 1, -1)
		tex:Point('BOTTOMRIGHT', btn, 'BOTTOMRIGHT', -1, 1)
		tex.tex = texture
		btn.texture = tex
	end

	if eventFunc then
		eventFunc(btn)
	end

	RU.Buttons[name] = btn

	return btn
end

function RU:CreateRoleIcons()
	local RoleIcons = CreateFrame('Frame', 'RaidUtilityRoleIcons', _G.RaidUtilityPanel)
	RoleIcons:Size(PANEL_WIDTH * 0.4, BUTTON_HEIGHT + 8)
	RoleIcons:SetTemplate('Transparent')
	RoleIcons:RegisterEvent('PLAYER_ENTERING_WORLD')
	RoleIcons:RegisterEvent('RAID_ROSTER_UPDATE')
	RoleIcons:SetScript('OnEvent', RU.OnEvent_RoleIcons)
	RoleIcons.icons = {}

	for i, data in next, roles do
		local frame = CreateFrame('Frame', '$parent_'..data.role, RoleIcons)

		if i == 1 then
			frame:Point('TOPLEFT', 3, -1)
		else
			local previous = roles[i-1]
			if previous and previous.role then
				frame:Point('LEFT', _G['RaidUtilityRoleIcons_'..previous.role], 'RIGHT', 6, 0)
			end
		end

		local texture = frame:CreateTexture(nil, 'OVERLAY')
		texture:SetTexture(E.Media.Textures.RoleIcons) -- 337499
		texture:SetTexCoord(data.texA, data.texB, data.texC, data.texD)
		texture:Point('TOPLEFT', frame, 'TOPLEFT', -2, 2)
		texture:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 2, -2)
		frame.texture = texture

		local Count = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
		Count:Point('BOTTOMRIGHT', -2, 2)
		Count:SetText(0)
		frame.count = Count

		frame.role = data.role
		frame:EnableMouse()
		frame:SetScript('OnEnter', RU.OnEnter_Role)
		frame:SetScript('OnLeave', GameTooltip_Hide)
		frame:Size(28)

		RoleIcons.icons[data.role] = frame
	end

	return RoleIcons
end

function RU:TargetIcons_GetCoords(button)
	local index = button:GetID()
	local idx = (index - 1) * 0.25

	local left = mod(idx, 1)
	local right = left + 0.25
	local top = floor(idx) * 0.25
	local bottom = top + 0.25

	local tex = button:GetNormalTexture()
	tex:SetTexCoord(left, right, top, bottom)
end

function RU:CreateTargetIcons()
	local TargetIcons = CreateFrame('Frame', 'RaidUtilityTargetIcons', _G.RaidUtilityPanel)
	TargetIcons:Size(PANEL_WIDTH, BUTTON_HEIGHT + 8)
	TargetIcons:SetTemplate('Transparent')
	TargetIcons.icons = {}

	local num, previous = 8 + 1 -- include clear
	for i = 1, num do
		local id = num - i
		local button = CreateFrame('Button', '$parent_TargetIcon'..i, TargetIcons, 'SecureActionButtonTemplate')
		button:SetScript('OnMouseDown', RU.TargetIcons_MouseDown)
		button:SetScript('OnMouseUp', RU.TargetIcons_MouseUp)
		button:SetScript('OnEnter', RU.TargetIcons_OnEnter)
		button:SetScript('OnLeave', RU.TargetIcons_OnLeave)
		button:SetScript('OnClick', RU.TargetIcons_OnClick)
		button:RegisterForClicks('AnyUp')
		button:SetNormalTexture(i == num and [[Interface\Buttons\UI-GroupLoot-Pass-Up]] or [[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		button:SetID(id)
		button:Size(TARGET_SIZE)
		button.keys = {}

		raidMarkers[id] = button

		if i == 1 then
			button:SetPoint('TOPLEFT', TargetIcons, 6, -3)
		else
			button:SetPoint('LEFT', previous, 'RIGHT', 6, 0)
		end

		previous = button

		local tex = button:GetNormalTexture()
		tex:ClearAllPoints()
		tex:SetPoint('CENTER', button)
		tex:Size(TARGET_SIZE)

		if i ~= num then
			RU:TargetIcons_GetCoords(button)
		end
	end

	return TargetIcons
end

function RU:UpdateMedia()
	for _, btn in next, RU.Buttons do
		if btn.Text then btn.Text:FontTemplate() end
		if btn.texture then btn.texture:SetTexture(btn.texture.tex) end
		btn:SetTemplate(nil, true)
	end

	if RU.MarkerButton then
		RU.MarkerButton:SetTemplate(nil, true)
	end
end

function RU:ToggleRaidUtil(event)
	if InCombatLockdown() then
		RU:RegisterEvent('PLAYER_REGEN_ENABLED', 'ToggleRaidUtil')
		return
	end

	local panel = _G.RaidUtilityPanel
	local status = RU:InGroup()
	ShowButton:SetShown(status and not panel.toggled)
	panel:SetShown(status and panel.toggled)

	if event == 'PLAYER_REGEN_ENABLED' then
		RU:UnregisterEvent('PLAYER_REGEN_ENABLED', 'ToggleRaidUtil')
	elseif RU.updateMedia and event == 'PLAYER_ENTERING_WORLD' then
		RU:UpdateMedia()
		RU.updateMedia = nil
	end
end

function RU:TargetIcons_OnEnter()
	if not E.db.general.raidUtility.showTooltip then return end

	_G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM')
	_G.GameTooltip:SetText(L["Click to mark the target."])
	_G.GameTooltip:Show()
end

function RU:TargetIcons_OnLeave()
	_G.GameTooltip:Hide()
end

function RU:TargetIcons_MouseDown()
	local tex = self:GetNormalTexture()
	local width, height = self:GetSize()
	tex:SetSize(width-4, height-4)
end

function RU:TargetIcons_MouseUp()
	local tex = self:GetNormalTexture()
	tex:SetSize(self:GetSize())
end

function RU:TargetIcons_OnClick()
	SetRaidTarget('target', self:GetID())
end

function RU:OnClick_RaidUtilityPanel(...)
	SecureHandler_OnClick(self, '_onclick', ...)
end

function RU:DragStart_ShowButton()
	if InCombatLockdown() then return end

	self:StartMoving()
end

function RU:DragStop_ShowButton()
	if InCombatLockdown() then return end

	self:StopMovingOrSizing()

	local point = self:GetPoint()
	local xOffset = self:GetCenter()
	local screenWidth = E.UIParent:GetWidth() * 0.5
	xOffset = xOffset - screenWidth

	self:ClearAllPoints()
	if strfind(point, 'BOTTOM') then
		self:Point('BOTTOM', E.UIParent, 'BOTTOM', xOffset, -1)
	else
		self:Point('TOP', E.UIParent, 'TOP', xOffset, 1)
	end
end

function RU:OnClick_ShowButton()
	_G.RaidUtilityPanel.toggled = true

	RU:PositionSections()
end

function RU:OnClick_CloseButton()
	_G.RaidUtilityPanel.toggled = false
end

function RU:OnClick_DisbandRaidButton()
	if RU:InGroup() then
		E:StaticPopup_Show('DISBAND_RAID')
	end
end

function RU:OnEvent_ReadyCheckButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:OnClick_ReadyCheckButton()
	if self.enabled and RU:InGroup() then
		DoReadyCheck()
	end
end

function RU:OnEvent_RoleCheckButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:OnClick_RoleCheckButton()
	if self.enabled and RU:InGroup() then
		local tank, healer, damager = RU:GetRoleCount()
		local total = tank + healer + damager
		E:Print(format("%s %s: %d | %s %s: %d | %s %s: %d", roleIcons.TANK, _G.TANK, tank, roleIcons.HEALER, _G.HEALER, healer, roleIcons.DAMAGER, _G.DAMAGER, damager))
		E:Print(format('%s: %d', L["Total"], total))
	end
end

function RU:OnClick_RaidCountdownButton()
    if RU:InGroup() and (RU:IsLeader() or RU:HasPermission()) and not countdownInProgress then
        RU:DoCountdown(10)
    end
end

function RU:OnEvent_RaidCountdownButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:OnClick_RaidControlButton()
	ToggleFriendsFrame(5)
end

function RU:OnEvent_MainTankButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:OnEvent_MainAssistButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:UpdateDifficultyDropdown()
    local dropdown = _G.RaidUtility_DungeonDifficulty
    if IsInRaid() then
        dropdown.menuList = raidMenuList
    else
        dropdown.menuList = groupMenuList
    end

    -- Update the dropdown text
    RU:OnSelect_DungeonDifficulty(dropdown)

    -- Force an update of the dropdown options
    if dropdown.initialize then
        dropdown.initialize(dropdown)
    end
end

function RU:ToggleDropdownMenu(dropdown)
    if not dropdown.menuList then return end
    if openMenu == dropdown then
        CloseDropDownMenus()
		openMenu = nil
    else
        E:SetEasyMenuAnchor(E.EasyMenu, dropdown)
        _G.EasyMenu(dropdown.menuList, E.EasyMenu, nil, nil, nil, 'MENU')
		openMenu = dropdown
    end
end

function RU:OnSelect_DungeonDifficulty(dropdown, text)
    if not dropdown or not dropdown.label then return end

    dropdown.text:SetText(E:GetDifficultyText(IsInRaid()) or text or '')
end

function RU.OnEvent_DungeonDifficulty(self, event, ...)
	RU:UpdateDifficultyDropdown()
end

function RU:OnClick_ModeControl()
	if RU:IsLeader() and RU:InGroup() and not IsInRaid() then
		ConvertToRaid()

		RU:UpdateDifficultyDropdown()
	end
end

function RU:OnEvent_ModeControl()
	RU:SetEnabled(self, not IsInRaid() and RU:HasPermission())
end

function RU:RoleIcons_SortNames(b) -- self is a
	return strsub(self, 11) < strsub(b, 11)
end

function RU:RoleIcons_AddNames(tbl, name, unitClass)
	local color = E:ClassColor(unitClass, true) or PRIEST_COLOR
	tinsert(tbl, format('|cff%02x%02x%02x%s', color.r * 255, color.g * 255, color.b * 255, gsub(name, '%-.+', '*')))
end

function RU:RoleIcons_AddPartyUnit(unit, iconRole)
	local name = UnitExists(unit) and UnitName(unit)
	local unitRole = name and UnitGroupRolesAssigned(unit)
	if unitRole == iconRole then
		local _, unitClass = UnitClass(unit)
		RU:RoleIcons_AddNames(roleRoster[0], name, unitClass)
	end
end

-- Credits oRA3 for the RoleIcons
function RU:OnEnter_Role()
	wipe(roleRoster)

	for i = 0, NUM_RAID_GROUPS do -- use 0 for party
		roleRoster[i] = {}
	end

	local iconRole = self.role
	local isRaid = IsInRaid()
	if RU:InGroup() and not isRaid then
		RU:RoleIcons_AddPartyUnit('player', iconRole)
	end

	for i = 1, GetNumGroupMembers() do
		if isRaid then
			local name, _, group, _, _, unitClass = GetRaidRosterInfo(i)
			local tankCount, healCount, damageCount = RU:GetRoleCount()
			local unitRole = (tankCount > 0 and 'TANK') or (healCount > 0 and 'HEALER') or (damageCount > 0 and 'DAMAGER')

			if name and unitRole == iconRole then
				RU:RoleIcons_AddNames(roleRoster[group], name, unitClass)
			end
		else
			RU:RoleIcons_AddPartyUnit('party'..i, iconRole)
		end
	end

	local point = E:GetScreenQuadrant(ShowButton)
	local bottom = point and strfind(point, 'BOTTOM')
	local left = point and strfind(point, 'LEFT')

	local anchor1 = (bottom and left and 'BOTTOMLEFT') or (bottom and 'BOTTOMRIGHT') or (left and 'TOPLEFT') or 'TOPRIGHT'
	local anchor2 = (bottom and left and 'BOTTOMRIGHT') or (bottom and 'BOTTOMLEFT') or (left and 'TOPRIGHT') or 'TOPLEFT'
	local anchorX = left and 2 or -2

	local GameTooltip = _G.GameTooltip
	GameTooltip:SetOwner(E.UIParent, 'ANCHOR_NONE')
	GameTooltip:Point(anchor1, self, anchor2, anchorX, 0)
	GameTooltip:SetText(roleIcons[iconRole] .. _G[iconRole])

	for group, list in next, roleRoster do
		sort(list, RU.RoleIcons_SortNames)

		for _, name in next, list do
			GameTooltip:AddLine((group == 0 and name) or format('[%d] %s', group, name), 1, 1, 1)
		end

		roleRoster[group] = nil
	end

	GameTooltip:Show()
end

function RU:ReanchorSection(section, bottom, target)
	if section then
		section:ClearAllPoints()

		if bottom then
			section:Point('BOTTOMLEFT', target, 'TOPLEFT', 0, 1)
		else
			section:Point('TOPLEFT', target, 'BOTTOMLEFT', 0, -1)
		end
	end
end

function RU:PositionSections()
	local point = E:GetScreenQuadrant(ShowButton)
	local bottom = point and strfind(point, 'BOTTOM')

	RU:ReanchorSection(_G.RaidUtilityTargetIcons, bottom)
	RU:ReanchorSection(_G.RaidUtilityRoleIcons, bottom, _G.RaidUtilityTargetIcons)
end

function RU:OnEvent_RoleIcons(event)
	RU:PositionSections()

	if event ~= 'PLAYER_ENTERING_WORLD' then
		wipe(roleCount)

		-- lets populate the counter
		for _, role in next, E.GroupRoles do
			if role ~= 'NONE' then
				roleCount[role] = (roleCount[role] or 0) + 1
			end
		end

		-- we only need to add this when not in a raid
		local myrole = IsInGroup() and not IsInRaid() and E.myrole
		if myrole and myrole ~= 'NONE' then
			roleCount[myrole] = (roleCount[myrole] or 0) + 1
		end

		-- update the text
		for role, icon in next, _G.RaidUtilityRoleIcons.icons do
			icon.count:SetText(roleCount[role] or 0)
		end
	end
end

function RU:SendMessageCount(message)
	local message = type(message) == 'number' and tostring(message) or L[message]

	if IsInRaid() then
		SendChatMessage(message, 'RAID_WARNING')
	elseif RU:InGroup() then
		SendChatMessage(message, 'PARTY')
	else
		E:GetRoleCount(message)
	end
end

function RU:DoCountdown(duration)
    if countdownInProgress then return end

	local target = GetRaidTargetIndex('target')
    local count = duration
    local function countdown()
        if count > 0 then
			if count == 10 then
				RU:SendMessageCount(format(L["Pulling %s in %d seconds!"], target and format('{rt%s}', target) or '', count))
			elseif count == 5 then
				RU:SendMessageCount(format(L["%d more seconds!"], count))
			elseif count <= 3 then
				RU:SendMessageCount(count)
			end
            count = count - 1
            countdownTimer = E:ScheduleTimer(countdown, 1)
        else
			RU:SendMessageCount(L["Pulling!"])

            countdownInProgress = false
            countdownTimer = nil
        end
    end

    countdown()
end

function RU:GetRoleCount()
	local tanks, healers, damage = 0, 0, 0
    local numMembers = GetNumGroupMembers()
    local isRaid = (numMembers > 0) and IsInRaid()

    local function checkRole(unit)
        if GetPartyAssignment('MAINTANK', unit) then
            tanks = tanks + 1
        elseif GetPartyAssignment('MAINASSIST', unit) then
            tanks = tanks + 1  -- Often, main assist is a second tank
        else
            -- Check if it's a healer class
            local _, class = UnitClass(unit)
            if class == 'PRIEST' or class == 'DRUID' or class == 'SHAMAN' or class == 'PALADIN' then
                healers = healers + 1
            else
                damage = damage + 1
            end
        end
    end

    if isRaid then
        for i = 1, numMembers do
            checkRole('raid'..i)
        end
    else
        for i = 1, numMembers do
            checkRole('party'..i)
        end
        checkRole('player')  -- Don't forget to check the player in a party
    end

    return tanks, healers, damage
end

function RU:Initialize()
	if not E.private.general.raidUtility then return end

	RU.Initialized = true
	RU.updateMedia = true -- update fonts and textures on entering world once, used to set the custom media from a plugin

	RU.Buttons = {}
	RU.CheckBoxes = {}

	local RaidUtilityPanel = CreateFrame('Frame', 'RaidUtilityPanel', E.UIParent, 'SecureHandlerBaseTemplate')
	RaidUtilityPanel:SetScript('OnMouseUp', RU.OnClick_RaidUtilityPanel)
	RaidUtilityPanel:SetTemplate('Transparent')
	RaidUtilityPanel:Size(PANEL_WIDTH, PANEL_HEIGHT - 25)
	RaidUtilityPanel:Point('TOP', E.UIParent, 'TOP', -400, 1)
	RaidUtilityPanel:SetFrameLevel(3)
	RaidUtilityPanel.toggled = false
	RaidUtilityPanel:SetFrameStrata('HIGH')
	E.FrameLocks.RaidUtilityPanel = true

	RU:CreateUtilButton(ShowButton, nil, nil, 136, BUTTON_HEIGHT, 'TOP', E.UIParent, 'TOP', -400, E.Border, _G.RAID_CONTROL, nil, nil, nil, RU.OnClick_ShowButton)
	SecureHandlerSetFrameRef(ShowButton, 'RaidUtilityPanel', RaidUtilityPanel)
	ShowButton:RegisterForDrag('RightButton')
	ShowButton:SetFrameStrata('HIGH')
	ShowButton:SetAttribute('_onclick', format([=[
		local utility = self:GetFrameRef('RaidUtilityPanel')
		local close = utility:GetFrameRef('RaidUtility_CloseButton')

		self:Hide()
		utility:Show()
		utility:ClearAllPoints()
		close:ClearAllPoints()

		local x, y = %d, %d
		local point = self:GetPoint()
		if point and strfind(point, 'BOTTOM') then
			utility:SetPoint('BOTTOM', self)
			close:SetPoint('BOTTOMRIGHT', utility, 'TOPRIGHT', -x, y)
		else
			utility:SetPoint('TOP', self)
			close:SetPoint('TOPRIGHT', utility, 'BOTTOMRIGHT', -x, -y)
		end
	]=], E:Scale(1), E:Scale(30), 0))
	ShowButton:SetScript('OnDragStart', RU.DragStart_ShowButton)
	ShowButton:SetScript('OnDragStop', RU.DragStop_ShowButton)
	E.FrameLocks.RaidUtility_ShowButton = true

	RU:CreateTargetIcons()

	local CloseButton = RU:CreateUtilButton('RaidUtility_CloseButton', RaidUtilityPanel, 'SecureHandlerClickTemplate', PANEL_WIDTH * 0.6, BUTTON_HEIGHT + 8, 'TOP', RaidUtilityPanel, 'BOTTOM', 0, 0, _G.CLOSE, nil, nil, nil, RU.OnClick_CloseButton)
	SecureHandlerSetFrameRef(CloseButton, 'RaidUtility_ShowButton', ShowButton)
	CloseButton:SetAttribute('_onclick', [=[self:GetParent():Hide(); self:GetFrameRef('RaidUtility_ShowButton'):Show()]=])
	SecureHandlerSetFrameRef(RaidUtilityPanel, 'RaidUtility_CloseButton', CloseButton)

	local BUTTON_WIDTH = PANEL_WIDTH - 20
	local RaidControlButton = RU:CreateUtilButton('RaidUtility_RaidControlButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', RaidUtilityPanel, 'TOPLEFT', 5, -4, L["Raid Menu"], nil, nil, nil, RU.OnClick_RaidControlButton)
	local ReadyCheckButton = RU:CreateUtilButton('RaidUtility_ReadyCheckButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', RaidControlButton, 'BOTTOMLEFT', 0, -5, _G.READY_CHECK, nil, buttonEvents, RU.OnEvent_ReadyCheckButton, RU.OnClick_ReadyCheckButton)
	RU:CreateUtilButton('RaidUtility_DisbandRaidButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', RaidControlButton, 'TOPRIGHT', 5, 0, L["Disband Group"], nil, nil, nil, RU.OnClick_DisbandRaidButton)

	local MainTankButton = RU:CreateUtilButton('RaidUtility_MainTankButton', RaidUtilityPanel, 'SecureActionButtonTemplate', BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', ReadyCheckButton, 'BOTTOMLEFT', 0, -5, _G.MAINTANK, nil, buttonEvents, RU.OnEvent_MainTankButton)
	MainTankButton:SetAttribute('type', 'maintank')
	MainTankButton:SetAttribute('unit', 'target')
	MainTankButton:SetAttribute('action', 'toggle')
	RU:FixSecureClicks(MainTankButton)

	local MainAssistButton = RU:CreateUtilButton('RaidUtility_MainAssistButton', RaidUtilityPanel, 'SecureActionButtonTemplate', BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', MainTankButton, 'TOPRIGHT', 5, 0, _G.MAINASSIST, nil, buttonEvents, RU.OnEvent_MainAssistButton)
	MainAssistButton:SetAttribute('type', 'mainassist')
	MainAssistButton:SetAttribute('unit', 'target')
	MainAssistButton:SetAttribute('action', 'toggle')
	RU:FixSecureClicks(MainAssistButton)

	local RaidCountdownButton = RU:CreateUtilButton('RaidUtility_CountdownButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', MainTankButton, 'BOTTOMLEFT', 0, -5, L["Countdown"], nil, buttonEvents, RU.OnEvent_RaidCountdownButton, RU.OnClick_RaidCountdownButton)
	RaidCountdownButton:SetScript('OnClick', RU.OnClick_CountdownButton)

	RU:CreateUtilButton('RaidUtility_ModeControl', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', RaidCountdownButton, 'TOPRIGHT', 5, 0, _G.CONVERT_TO_RAID, nil, buttonEvents, RU.OnEvent_ModeControl, RU.OnClick_ModeControl)

	RU:CreateUtilButton('RaidUtility_RoleCheckButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', ReadyCheckButton, 'TOPRIGHT', 5, 0, L["Role Check"], nil, buttonEvents, RU.OnEvent_RoleCheckButton, RU.OnClick_RoleCheckButton)
	RU:CreateRoleIcons()

	local menuList = IsInRaid() and raidMenuList or groupMenuList
	RU:CreateDropdown('RaidUtility_DungeonDifficulty', RaidUtilityPanel, 'UIDropDownMenuTemplate', BUTTON_WIDTH * 0.5 + 28.5, 'TOPLEFT', RaidCountdownButton, 'BOTTOMLEFT', -20, -2, L["Difficulty"], E:GetDifficultyText(IsInRaid()), { 'CHAT_MSG_SYSTEM', 'RAID_ROSTER_UPDATE' }, RU.OnEvent_DungeonDifficulty, RU.OnSelect_DungeonDifficulty, menuList)
	RU:UpdateDifficultyDropdown() -- Ensure the correct menu is set initially

	-- Automatically show/hide the frame if we have RaidLeader or RaidOfficer
	RU:RegisterEvent('RAID_ROSTER_UPDATE', 'ToggleRaidUtil')
	RU:RegisterEvent('PARTY_MEMBERS_CHANGED', 'ToggleRaidUtil')
	RU:RegisterEvent('PLAYER_ENTERING_WORLD', 'ToggleRaidUtil')
end

E:RegisterModule(RU:GetName())
