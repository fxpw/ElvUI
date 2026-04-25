local E, L, V, P, G = unpack(ElvUI)

local _G = _G
local ipairs, next, select = ipairs, next, select
local tinsert = tinsert

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local ToggleFrame = ToggleFrame
local UIParent = UIParent

local GetRaidRosterInfo = GetRaidRosterInfo
local IsPartyLeader = IsPartyLeader
local IsRaidOfficer = IsRaidOfficer
local UIDropDownMenu_Refresh = UIDropDownMenu_Refresh

local hooksecurefunc = hooksecurefunc

local function OnClick(btn)
	if btn.func then
		btn.func()
	end

	btn:GetParent():Hide()
end

local function OnEnter(btn)
	if btn.hoverTex then
		btn.hoverTex:Show()
	end
end

local function OnLeave(btn)
	if btn.hoverTex then
		btn.hoverTex:Hide()
	end
end

local function CreateButton(frame, i)
	local button = CreateFrame('Button', nil, frame)
	button:SetScript('OnEnter', OnEnter)
	button:SetScript('OnLeave', OnLeave)
	frame.buttons[i] = button

	local hover = button:CreateTexture(nil, 'OVERLAY')
	hover:SetAllPoints()
	hover:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]]) -- Interface\QuestFrame\UI-QuestTitleHighlight
	hover:SetBlendMode('ADD')
	hover:Hide()
	button.hoverTex = hover

	local text = button:CreateFontString(nil, 'BORDER')
	text:SetAllPoints()
	text:FontTemplate(nil, nil, 'SHADOW')
	text:SetJustifyH('LEFT')
	button.text = text

	return button
end

function E:DropDown(list, frame, width, height, padding, xOffset, yOffset)
	if not width then width = 135 end
	if not height then height = 16 end
	if not padding then padding = 10 end

	if not frame.buttons then
		frame.buttons = {}

		frame:SetFrameStrata('DIALOG')
		frame:SetClampedToScreen(true)
		frame:Hide()

		tinsert(_G.UISpecialFrames, frame:GetName())
	end

	for _, button in next, frame.buttons do
		button:Hide()
	end

	local numEntries = #list
	for i = 1, numEntries do
		local entry = list[i]
		local button = frame.buttons[i] or CreateButton(frame, i)
		button.text:SetText(entry.text)
		button.func = entry.func

		button:Show()
		button:ClearAllPoints()
		button:SetScript('OnClick', OnClick)
		button:Size(width, height)

		if i == 1 then
			button:Point('TOPLEFT', frame, 'TOPLEFT', padding, -padding)
		else
			button:Point('TOPLEFT', frame.buttons[i-1], 'BOTTOMLEFT')
		end
	end

	local x, y = GetCursorPosition()
	local SPACING = padding * 2

	frame:ClearAllPoints()
	frame:Point('TOPLEFT', UIParent, 'BOTTOMLEFT', (x / E.uiscale) + (xOffset or 0), (y / E.uiscale) + (yOffset or 0))
	frame:Size(width + SPACING, (numEntries * height) + SPACING)

	ToggleFrame(frame)
end

local function CreateSecurePromoteButton(name, role)
    local button = CreateFrame('Button', name, E.UIParent, 'SecureActionButtonTemplate')
    button:SetFrameStrata('TOOLTIP')
    button:Hide()

    button:SetAttribute('type', role)
    button:SetAttribute('unit', 'target')
    button:SetAttribute('action', 'toggle')

    button:RegisterEvent('PLAYER_REGEN_DISABLED')
    button:RegisterEvent('PLAYER_REGEN_ENABLED')

    button.role = role

    return button
end

local function CopyScript(scriptName, sourceButton, targetButton)
    local originalScript = sourceButton:GetScript(scriptName)
    targetButton:SetScript(scriptName, function(...)
        if originalScript then
            originalScript(sourceButton, ...)
        end
    end)
end

local function SetButton(unit, button, newButton)
    newButton:SetAllPoints(button)
    newButton:SetAttribute('unit', unit or 'target')

    CopyScript('OnEnter', button, newButton)
    CopyScript('OnLeave', button, newButton)
    CopyScript('OnClick', button, newButton)

    newButton:SetScript('OnMouseDown', function() button:SetButtonState('PUSHED') end)
    newButton:SetScript('OnMouseUp', function() button:SetButtonState('NORMAL') end)

    newButton:SetScript('OnEvent', function(self, event)
        local isDisabled = event == 'PLAYER_REGEN_DISABLED'
        self:SetAttribute('type', isDisabled and nil or self.role)
        button:SetAlpha(isDisabled and 0.5 or 1)
    end)

    newButton:Show()
end

local secureTankButton = CreateSecurePromoteButton('ElvUI_SecureTankButton', 'maintank')
local secureAssistButton = CreateSecurePromoteButton('ElvUI_SecureAssistButton', 'mainassist')

local function RefreshDropdown(button)
    if button == 'RAID_MAINTANK' or button == 'RAID_MAINASSIST' then
        UIDropDownMenu_Refresh(_G.UIDROPDOWNMENU_INIT_MENU, nil, 1)
    end
end

hooksecurefunc('UnitPopup_OnClick', function(self)
    RefreshDropdown(self.value)
end)

hooksecurefunc('UnitPopup_ShowMenu', function(_, _, unit)
    if _G.UIDROPDOWNMENU_MENU_LEVEL ~= 1 then return end

    for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
        local button = _G['DropDownList1Button'..i]
        if button and button:IsShown() then
            if button.value == 'RAID_MAINTANK' then
                SetButton(unit, button, secureTankButton)
            elseif button.value == 'RAID_MAINASSIST' then
                SetButton(unit, button, secureAssistButton)
            end
        end
    end
end)

hooksecurefunc('UnitPopup_HideButtons', function()
    local dropdownMenu = _G.UIDROPDOWNMENU_INIT_MENU
    if dropdownMenu.which ~= 'RAID' or not (IsPartyLeader() or IsRaidOfficer()) then return end

    for index, value in ipairs(_G.UnitPopupMenus[dropdownMenu.which]) do
        if value == 'RAID_MAINTANK' or value == 'RAID_MAINASSIST' then
            local role = select(10, GetRaidRosterInfo(dropdownMenu.userData))
            if role ~= value:sub(6) or not dropdownMenu.name then
                _G.UnitPopupShown[_G.UIDROPDOWNMENU_MENU_LEVEL][index] = 1
            end
        end
    end
end)

_G.DropDownList1:HookScript('OnHide', function()
    secureTankButton:Hide()
    secureAssistButton:Hide()
end)