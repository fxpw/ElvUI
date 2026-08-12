local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local format = string.format
local join = string.join
--WoW API / Variables
local UnitXPMax = UnitXPMax
local MouseIsOver = MouseIsOver
local IsShiftKeyDown = IsShiftKeyDown
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLogRewardXP = GetQuestLogRewardXP
local SelectQuestLogEntry = SelectQuestLogEntry
local GetQuestLogRewardMoney = GetQuestLogRewardMoney
local GetNumQuestLogEntries = GetNumQuestLogEntries
local BreakUpLargeNumbers = BreakUpLargeNumbers

local MAX_QUESTLOG_QUESTS = MAX_QUESTLOG_QUESTS -- 25 в WotLK
local QUESTS_LABEL = QUESTS_LABEL
local COMPLETE = COMPLETE
local INCOMPLETE = INCOMPLETE

local displayString = ""
local numEntries, numQuests, xpToLevel = 0, 0, 0

local function GetQuestInfo(questIndex)
	local info = {}
	info.title, info.level, info.questTag, info.suggestedGroup, info.isHeader, info.isCollapsed, info.isComplete, info.isDaily, info.questID = GetQuestLogTitle(questIndex)
	SelectQuestLogEntry(questIndex)

	return info
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local totalMoney, totalXP, completedXP = 0, 0, 0
	local isShiftDown = IsShiftKeyDown()

	DT.tooltip:AddLine(QUESTS_LABEL)
	DT.tooltip:AddLine(" ")

	for questIndex = 1, numEntries do
		local info = GetQuestInfo(questIndex)
		if info and not info.isHeader then
			local xp = GetQuestLogRewardXP()
			local money = GetQuestLogRewardMoney()
			local isComplete = info.isComplete

			totalMoney = totalMoney + money
			totalXP = totalXP + xp
			completedXP = completedXP + (isComplete and xp or 0)

			DT.tooltip:AddDoubleLine(info.title, isShiftDown and format("%s (%.2f%%)", BreakUpLargeNumbers(xp), (xpToLevel > 0 and (xp / xpToLevel) * 100) or 0) or (isComplete and COMPLETE or INCOMPLETE), 1, 1, 1, isComplete and .2 or 1, isComplete and 1 or .2, .2)
		end
	end

	if completedXP > 0 then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddDoubleLine(L["Completed XP:"], format("%s (%.2f%%)", BreakUpLargeNumbers(completedXP), (xpToLevel > 0 and (completedXP / xpToLevel) * 100) or 0), nil, nil, nil, 1, 1, 1)
	end

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(L["Total Gold:"], E:FormatMoney(totalMoney, "SMART"), nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Total XP:"], format("%s (%.2f%%)", BreakUpLargeNumbers(totalXP), (xpToLevel > 0 and (totalXP / xpToLevel) * 100) or 0), nil, nil, nil, 1, 1, 1)
	DT.tooltip:Show()
end

local function OnClick()
	_G.ToggleFrame(_G.QuestLogFrame)
end

local function OnEvent(self)
	numEntries, numQuests = GetNumQuestLogEntries()
	xpToLevel = UnitXPMax("player")

	self.text:SetFormattedText(displayString, numQuests, MAX_QUESTLOG_QUESTS)

	if MouseIsOver(self) then
		OnEnter(self)
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", QUESTS_LABEL, ": ", hex, "%d|r", "/", hex, "%d|r")
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Quests", {"QUEST_ACCEPTED", "QUEST_LOG_UPDATE", "MODIFIER_STATE_CHANGED"}, OnEvent, nil, OnClick, OnEnter, nil, L["Quest Log"])
