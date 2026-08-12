local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local format = string.format
--WoW API / Variables
local ToggleCharacter = ToggleCharacter
local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetFactionInfo = GetFactionInfo
local GetNumFactions = GetNumFactions

local NOT_APPLICABLE = NOT_APPLICABLE
local REPUTATION = REPUTATION
local STANDING = STANDING

-- в WotLK нет GetWatchedFactionIndex(); ищем индекс, сверяя имя
-- отслеживаемой фракции из GetWatchedFactionInfo() со списком фракций
local function GetWatchedFactionIndex()
	local name = GetWatchedFactionInfo()
	if not name then return end

	for i = 1, GetNumFactions() do
		if GetFactionInfo(i) == name then
			return i
		end
	end
end

local function GetWatchedFactionData()
	local index = GetWatchedFactionIndex()
	if not index then return end

	local name, _, reaction, min, max, value = GetFactionInfo(index)
	return name, reaction, min, max, value
end

local function OnEvent(self)
	local name, reaction, min, max, value = GetWatchedFactionData()
	if not name then
		self.text:SetText(NOT_APPLICABLE)
		return
	end

	local isCapped = reaction == 8

	local color = _G.FACTION_BAR_COLORS[reaction]
	local	standingLabel = E:RGBToHex(color.r, color.g, color.b).._G["FACTION_STANDING_LABEL"..reaction].."|r"

	-- защита от деления на ноль
	local maxMinDiff = max - min
	if maxMinDiff == 0 then
		maxMinDiff = 1
	end

	local text
	if isCapped then
		text = format("%s: [%s]", name, standingLabel)
	else
		text = format("%s: %d%% [%s]", name, ((value - min) / (maxMinDiff) * 100), standingLabel)
	end

	self.text:SetText(text)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local name, reaction, min, max, value = GetWatchedFactionData()
	if name then
		DT.tooltip:AddLine(name)
		DT.tooltip:AddLine(" ")

		DT.tooltip:AddDoubleLine(STANDING..":", _G["FACTION_STANDING_LABEL"..reaction], 1, 1, 1)
		if reaction ~= 8 then
			DT.tooltip:AddDoubleLine(REPUTATION..":", format("%d / %d (%d%%)", value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
		end
		DT.tooltip:Show()
	end
end

local function OnClick()
	ToggleCharacter("ReputationFrame")
end

DT:RegisterDatatext("Reputation", {"UPDATE_FACTION", "COMBAT_TEXT_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, REPUTATION)
