local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format

local GetDungeonDifficulty = GetDungeonDifficulty
local GetRaidDifficulty = GetRaidDifficulty
local SetDungeonDifficulty = SetDungeonDifficulty
local SetRaidDifficulty = SetRaidDifficulty
local GetInstanceInfo = GetInstanceInfo
local GetZoneText = GetZoneText
local ResetInstances = ResetInstances

local heroicTex = [[|Tinterface\lfgframe\ui-lfg-icon-heroic:20:20:0:0:64:64:0:36:0:36|t]]
local dungTex = [[|Tinterface\icons\spell_arcane_teleportstormwind:20:20:0:0:64:64:4:60:4:60|t]]
local raidTex = [[|Tinterface\icons\spell_arcane_teleportshattrath:20:20:0:0:64:64:4:60:4:60|t]]

local RightClickMenu = {
    { text = _G.DUNGEON_DIFFICULTY, isTitle = true, notCheckable = true },
    { text = _G.DUNGEON_DIFFICULTY1, checked = function() return GetDungeonDifficulty() == 1 end, func = function() SetDungeonDifficulty(1) end },
    { text = _G.DUNGEON_DIFFICULTY2, checked = function() return GetDungeonDifficulty() == 2 end, func = function() SetDungeonDifficulty(2) end },
    { text = '', isTitle = true, notCheckable = true },
    { text = _G.RAID_DIFFICULTY, isTitle = true, notCheckable = true},
    { text = _G.RAID_DIFFICULTY1, checked = function() return GetRaidDifficulty() == 1 end, func = function() SetRaidDifficulty(1) end },
    { text = _G.RAID_DIFFICULTY2, checked = function() return GetRaidDifficulty() == 2 end, func = function() SetRaidDifficulty(2) end },
    { text = _G.RAID_DIFFICULTY3, checked = function() return GetRaidDifficulty() == 3 end, func = function() SetRaidDifficulty(3) end },
    { text = _G.RAID_DIFFICULTY4, checked = function() return GetRaidDifficulty() == 4 end, func = function() SetRaidDifficulty(4) end },
    { text = '', isTitle = true, notCheckable = true },
    { text = _G.RESET_INSTANCES, notCheckable = true, func = function() ResetInstances()  end},
}

local function OnEvent(self)
    local _, instanceType, difficultyID, _, maxPlayers = GetInstanceInfo()

    if instanceType == 'none' then
        self.text:SetFormattedText('%s %s %s %s', dungTex, E:GetDifficultyText(), raidTex, E:GetDifficultyText(true))
    else
        self.text:SetFormattedText('%s: %s %s %s', GetZoneText(), maxPlayers, _G.PLAYER, difficultyID > 1 and heroicTex or '')
    end
end

local function OnClick(self)
    E:SetEasyMenuAnchor(E.EasyMenu, self)
	_G.EasyMenu(RightClickMenu, E.EasyMenu, nil, nil, nil, 'MENU')
end

local function OnEnter()
    DT.tooltip:ClearLines()

    DT.tooltip:AddLine(L["Current Difficulty"])
    DT.tooltip:AddLine(' ')
    DT.tooltip:AddDoubleLine(_G.DUNGEON_DIFFICULTY, E:GetDifficultyText(), 1, 1, 1)
    DT.tooltip:AddDoubleLine(_G.RAID_DIFFICULTY, E:GetDifficultyText(true), 1, 1, 1)

    DT.tooltip:Show()
end

DT:RegisterDatatext('Difficulty', nil, { 'CHAT_MSG_SYSTEM', 'ZONE_CHANGED', 'ZONE_CHANGED_INDOORS', 'ZONE_CHANGED_NEW_AREA' }, OnEvent, nil, OnClick, OnEnter, nil, 'Difficulty')