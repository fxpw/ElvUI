local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format, gsub, strjoin = format, gsub, strjoin
local wipe = wipe

local GetActiveTalentGroup = GetActiveTalentGroup
local GetTalentTabInfo = GetTalentTabInfo
local GetNumTalentGroups = GetNumTalentGroups
local SetActiveTalentGroup = SetActiveTalentGroup
local ToggleTalentFrame = ToggleTalentFrame
local IsShiftKeyDown = IsShiftKeyDown
local LoadAddOn = LoadAddOn

local MAX_TALENT_TABS = MAX_TALENT_TABS
local FACTION_INACTIVE = FACTION_INACTIVE
local PRIMARY = PRIMARY
local SECONDARY = SECONDARY

local displayString = '|cffFFFFFF%s|r'
local displayStrings = '|cffFFFFFF%s:|r %s'
local displayGreen = '|cff00FF00%s|r'
local displayRed = '|cffFF0000%s|r'
local activeString = strjoin('', '|cff00FF00', L["Active"], '|r')
local inactiveString = strjoin('', '|cffFF0000', FACTION_INACTIVE, '|r')

local mainSize = 16
local mainIcon = '|T%s:%d:%d:0:0:64:64:4:60:4:60|t'
local listIcon = '|T%s:20:20:0:0:50:50:4:46:4:46|t'

local hasDualSpec, activeSpec, activeGroup
local activeGroupText

-- Cache for spec info
local TALENT_INFO_CACHE = {}

local function GetActiveSpec()
    -- Clear cache before updating
    wipe(TALENT_INFO_CACHE)

    hasDualSpec = GetNumTalentGroups() == 2
    activeGroup = GetActiveTalentGroup()

    local activeSpec, maxPoints = nil, 0
    for i = 1, MAX_TALENT_TABS do
        local name, icon, pointsSpent = GetTalentTabInfo(i)
        if name and icon then
            if pointsSpent > maxPoints then
                activeSpec = { name = name, icon = icon, points = pointsSpent }
                maxPoints = pointsSpent
            end
            -- Cache spec info
            TALENT_INFO_CACHE[i] = { name = name, icon = icon, points = pointsSpent }
        else
            return nil  -- Return nil if we don't have valid data yet
        end
    end
    return activeSpec
end

local function UpdateDisplay(self, activeSpec)
    local db = E.global.datatexts.settings["Talent Specialization"]
    local size = db.iconSize or mainSize
    activeGroupText = format(displayString, activeGroup == 1 and PRIMARY or SECONDARY)

    if activeSpec and activeSpec.icon then
        local text
        if db.iconOnly then
            text = format(mainIcon, activeSpec.icon, size, size)
        else
            text = format('%s %s', format(mainIcon, activeSpec.icon, size, size), activeSpec.name)
        end
        self.text:SetFormattedText(displayStrings, activeGroupText, text)
    else
        self.text:SetFormattedText(displayStrings, activeGroupText, format(displayRed, L["No Talents Selected"]))
    end
end

local function OnEvent(self, event)
    activeSpec = GetActiveSpec()
    if activeSpec then
        UpdateDisplay(self, activeSpec)
    else
        E:Delay(0.5, function()
            activeSpec = GetActiveSpec()
            UpdateDisplay(self, activeSpec)
        end)
    end
end

local function OnEnter(self)
    DT:SetupTooltip(self)

    for i = 1, MAX_TALENT_TABS do
        local spec = TALENT_INFO_CACHE[i]
        if spec.name then
            local iconString = spec.icon and format(listIcon, spec.icon) or ""
            local specText = format('%s %s |cffFFFFFF%s|r', iconString, spec.name, spec.points)
            local activeText = (activeSpec and activeSpec.name == spec.name) and activeString or inactiveString
            DT.tooltip:AddLine(format('%s - %s', specText, activeText))
        end
    end

    if hasDualSpec then
        DT.tooltip:AddLine(' ')
        DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s %s', L["Talent Specialization Active"], activeGroupText, activeSpec and format('(%s)', activeSpec.name) or ''))
        DT.tooltip:AddLine(' ')
        DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Talent Specialization"])
    end

    if not hasDualSpec then
        DT.tooltip:AddLine(' ')
    end

    DT.tooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI"])
    DT.tooltip:Show()
end

local function OnClick(self, button)
    if button == 'LeftButton' then
        if not _G.PlayerTalentFrame then
            LoadAddOn('Blizzard_TalentUI')
        end

        if IsShiftKeyDown() then
            if not E:AlertCombat() then
                ToggleTalentFrame()
            end
        else
            local specGroup = activeGroup == 1 and 2 or 1
            SetActiveTalentGroup(specGroup)
        end
    end
end

DT:RegisterDatatext('Talent Specialization', nil, { 'CHARACTER_POINTS_CHANGED', 'PLAYER_TALENT_UPDATE', 'ACTIVE_TALENT_GROUP_CHANGED' }, OnEvent, nil, OnClick, OnEnter, nil, L["Talent Specialization"])