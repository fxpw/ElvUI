local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local format, join = string.format, string.join
local toggle = false
--WoW API / Variables
local displayString = ""
local lastPanel

local Premium
local curLvL
local lvlXP
local maxXP
local unclaimed

local function CollectAllQuestReward()
	for i = 1, C_BattlePass.GetNumQuests(1) do
		local _, _, _, _, progressValue, progressMaxValue = C_BattlePass.GetQuestInfo(1, i)
		if progressValue == progressMaxValue then
			C_BattlePass.CollectQuestReward(1, i)
		end
	end

	for i = 1, C_BattlePass.GetNumQuests(2) do
		local _, _, _, _, progressValue, progressMaxValue = C_BattlePass.GetQuestInfo(2, i)
		if progressValue == progressMaxValue then
			C_BattlePass.CollectQuestReward(2, i)
		end
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local dailyCount = C_BattlePass.GetNumQuests(1)
	if dailyCount > 0 then
		DT.tooltip:AddLine(format("|cFFFF8000%s: %d|r", "Ежедневные квесты", dailyCount), 1, 1, 1)
		for i = 1, dailyCount do
			local _, description, _, _, progressValue, progressMaxValue = C_BattlePass.GetQuestInfo(1, i)
			local isComplete = progressValue == progressMaxValue
			if isComplete then
				DT.tooltip:AddLine(format("Выполнен - %s", description), .31, .99, .46)
			else
				DT.tooltip:AddLine(format("|cFFFFFF00%d|r/|cFF00FF00%d|r - %s", progressValue, progressMaxValue, description), 1, 1, 1)
			end
		end
		DT.tooltip:AddLine(" ")
	end

	local weeklyCount = C_BattlePass.GetNumQuests(2)
	if weeklyCount > 0 then
		DT.tooltip:AddLine(format("|cFFFF8000%s: %d|r", "Еженедельные квесты", weeklyCount), 1, 1, 1)
		for i = 1, weeklyCount do
			local _, description, _, _, progressValue, progressMaxValue = C_BattlePass.GetQuestInfo(2, i)
			local isComplete = progressValue == progressMaxValue
			if isComplete then
				DT.tooltip:AddLine(format("Выполнен - %s", description), .31, .99, .46)
			else
				DT.tooltip:AddLine(format("|cFFFFFF00%d|r/|cFF00FF00%d|r - %s", progressValue, progressMaxValue, description), 1, 1, 1)
			end
		end
		DT.tooltip:AddLine(" ")
	end

	DT.tooltip:AddDoubleLine(L["Left Click:"], "Открыть боевой пропуск", 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Middle Click:"], "Собрать все выполненые квесты", 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Right Click:"], "Забрать все награды за уровни", 1, 1, 1)

	DT.tooltip:Show()
end

local function OnClick(self, button)
	if button == "LeftButton" then
		if BattlePassFrame then
			if BattlePassFrame:IsShown() then
				HideUIPanel(BattlePassFrame)
			else
				ShowUIPanel(BattlePassFrame)
			end
		end
	elseif button == "RightButton" then
		C_BattlePass.TakeAllLevelRewards()
	elseif button == "MiddleButton" then
		CollectAllQuestReward()
	end
end

local function OnEvent(self, event)
	lastPanel = self

	if not self.customEventsRegistered then
		if self.RegisterCustomEvent then
			self:RegisterCustomEvent("BATTLEPASS_EXPERIENCE_UPDATE")
			self:RegisterCustomEvent("BATTLEPASS_ACCOUNT_UPDATE")
			self:RegisterCustomEvent("BATTLEPASS_QUEST_LIST_UPDATE")
			self:RegisterCustomEvent("BATTLEPASS_CARD_UPDATE_BUCKET")
		end
		self.customEventsRegistered = true
	end

	Premium = C_BattlePass.IsPremiumActive()
	curLvL, lvlXP, maxXP = C_BattlePass.GetLevelInfo()
	unclaimed = C_BattlePass.HasUnclaimedReward()

	-- Avoid error if GetLevelInfo returns nil (e.g. not initialized)
	curLvL = curLvL or 0
	lvlXP = lvlXP or 0
	maxXP = maxXP or 1

	if Premium then
		self.text:SetFormattedText(displayString, "|cfff5cf00БП (P)|r", curLvL, lvlXP, maxXP, unclaimed and "!" or "")
	else
		self.text:SetFormattedText(displayString, "БП", curLvL, lvlXP, maxXP, unclaimed and "!" or "")
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d|r (", hex, "%.0f/%.0f|r) %s")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Боевой пропуск", { "PLAYER_ENTERING_WORLD", "BATTLEPASS_EXPERIENCE_UPDATE", "BATTLEPASS_ACCOUNT_UPDATE", "BATTLEPASS_QUEST_LIST_UPDATE" }, OnEvent, nil, OnClick, OnEnter, nil, "Боевой пропуск")