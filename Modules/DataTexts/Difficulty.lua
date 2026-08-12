local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local format = string.format
--WoW API / Variables
local GetDungeonDifficulty = GetDungeonDifficulty
local GetRaidDifficulty = GetRaidDifficulty
local SetDungeonDifficulty = SetDungeonDifficulty
local SetRaidDifficulty = SetRaidDifficulty
local GetInstanceInfo = GetInstanceInfo
local GetZoneText = GetZoneText
local ResetInstances = ResetInstances
local CreateFrame = CreateFrame

local heroicTex = [[|Tinterface\lfgframe\ui-lfg-icon-heroic:20:20:0:0:64:64:0:36:0:36|t]]
local dungTex = [[|Tinterface\icons\spell_arcane_teleportstormwind:20:20:0:0:64:64:4:60:4:60|t]]
local raidTex = [[|Tinterface\icons\spell_arcane_teleportshattrath:20:20:0:0:64:64:4:60:4:60|t]]

local dropdown = CreateFrame("Frame", "ElvUI_DifficultyDropDown", E.UIParent)

local lastPanel

local Refresh

local function GetDifficultyText(isRaid)
	local difficulty = isRaid and GetRaidDifficulty() or GetDungeonDifficulty()
	return _G["PLAYER_DIFFICULTY"..difficulty] or ""
end

local RightClickMenu = {
	{ text = _G.DUNGEON_DIFFICULTY.." - ".._G.PLAYER_DIFFICULTY1, func = function() SetDungeonDifficulty(1) Refresh() end },
	{ text = _G.DUNGEON_DIFFICULTY.." - ".._G.PLAYER_DIFFICULTY2, func = function() SetDungeonDifficulty(2) Refresh() end },
	{ text = _G.DUNGEON_DIFFICULTY.." - ".._G.PLAYER_DIFFICULTY3, func = function() SetDungeonDifficulty(3) Refresh() end },
	{ text = "" },
	{ text = _G.RAID_DIFFICULTY.." - ".._G.PLAYER_DIFFICULTY1, func = function() SetRaidDifficulty(1) Refresh() end },
	{ text = _G.RAID_DIFFICULTY.." - ".._G.PLAYER_DIFFICULTY2, func = function() SetRaidDifficulty(2) Refresh() end },
	{ text = _G.RAID_DIFFICULTY.." - ".._G.PLAYER_DIFFICULTY3, func = function() SetRaidDifficulty(3) Refresh() end },
	{ text = "" },
	{ text = _G.RESET_INSTANCES, func = function() ResetInstances() end },
}

local function OnEvent(self)
	lastPanel = self

	local _, instanceType, difficultyID, _, maxPlayers = GetInstanceInfo()

	if instanceType == "none" then
		self.text:SetFormattedText("%s %s %s %s", dungTex, GetDifficultyText(false), raidTex, GetDifficultyText(true))
	else
		self.text:SetFormattedText("%s: %s %s %s", GetZoneText(), maxPlayers, _G.PLAYER, difficultyID > 1 and heroicTex or "")
	end
end

Refresh = function()
	if lastPanel then
		OnEvent(lastPanel)
	end
end

local function OnClick(self, button)
	if button == "RightButton" then
		E:DropDown(RightClickMenu, dropdown)
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddLine(L["Current Difficulty"])
	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(_G.DUNGEON_DIFFICULTY, GetDifficultyText(false), 1, 1, 1)
	DT.tooltip:AddDoubleLine(_G.RAID_DIFFICULTY, GetDifficultyText(true), 1, 1, 1)

	DT.tooltip:Show()
end

DT:RegisterDatatext("Difficulty", {"CHAT_MSG_SYSTEM", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD"}, OnEvent, nil, OnClick, OnEnter, nil, "Difficulty")
