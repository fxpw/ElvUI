local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
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
		local _, _, _, progressValue, progressMaxValue = C_BattlePass.GetQuestInfo(1,
			i)
		local isComplete = progressValue == progressMaxValue
		if isComplete then
			C_BattlePass.CollectQuestReward(1, i)
		end
	end
end


local function OnEnter(self)
	DT:SetupTooltip(self)
	DT.tooltip:AddLine(string.format("|cFFFF8000Ежедневные квесты: %d|r", C_BattlePass.GetNumQuests(1)), 1, 1, 1)
	for i = 1, C_BattlePass.GetNumQuests(1) do
		-- if i == 1 then
		-- DT.tooltip:AddLine(" ")
		-- end
		local _, description, _,_, progressValue, progressMaxValue = C_BattlePass.GetQuestInfo(1, i)
		local isComplete = progressValue == progressMaxValue
		if isComplete then
			DT.tooltip:AddLine(string.format("Выполнен - %s", description), .31, .99, .46)
		else
			DT.tooltip:AddLine(
				string.format("|cFFFFFF00%d|r/|cFF00FF00%d|r - %s", progressValue, progressMaxValue, description), 1, 1,
				1)
		end
		-- DT.tooltip:AddLine(" ")
	end
	DT.tooltip:AddLine(" ")
	DT.tooltip:AddLine(string.format("|cFFFF8000Еженедельные квесты: %d|r", C_BattlePass.GetNumQuests(2)), 1, 1, 1)
	for i = 1, C_BattlePass.GetNumQuests(2) do
		-- if i == 1 then
		-- DT.tooltip:AddLine(" ")
		-- end
		local _, description, _,_, progressValue, progressMaxValue = C_BattlePass.GetQuestInfo(2, i)
		local isComplete = progressValue == progressMaxValue
		if isComplete then
			DT.tooltip:AddLine(string.format("Выполнен - %s", description), .31, .99, .46)
		else
			DT.tooltip:AddLine(
			string.format("|cFFFFFF00%d|r/|cFF00FF00%d|r - %s", progressValue, progressMaxValue, description), 1, 1, 1)
		end
		-- DT.tooltip:AddLine(" ")
	end
	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(L["Left Click:"], "Открыть боевой пропуск", 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Middle Click:"], "Собрать все выполненые квесты", 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Right Click:"], "Забрать все награды за уровни", 1, 1, 1)

	DT.tooltip:Show()
end


local function OnClick(_, button)
	if button == "LeftButton" then
		ToggleFrame(BattlePassFrame)
	elseif button == "RightButton" then
		SendServerMessage("ACMSG_BATTLEPASS_TAKE_ALL_REWARDS")
	elseif button == "MiddleButton" then
		CollectAllQuestReward()
	end
end
local function OnEvent(self, event)
	lastPanel            = self
	Premium              = C_BattlePass:IsPremiumActive()
	curLvL, lvlXP, maxXP = C_BattlePass.GetLevelInfo()
	unclaimed            = C_BattlePass.HasUnclaimedReward()
	self.text:SetFormattedText(displayString, curLvL, lvlXP, maxXP, unclaimed and "!" or "")
end

local function ValueColorUpdate(hex)
	if Premium == true then
		displayString = join("", "|cfff5cf00БП (%s)|r: ", hex, "%.0f/%.0f|r", " %s")
	else
		displayString = join("", "БП (%s): ", hex, "%.0f/%.0f |r", " %s")
	end

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Боевой пропуск",
	{ "SPELL_UPDATE_USABLE", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "COMBAT_RATING_UPDATE" }, OnEvent,
	nil, OnClick, OnEnter, nil, "Боевой пропуск")