local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local ipairs = ipairs
local join = string.join
local format = string.format
local tinsert = table.insert
local tconcat = table.concat
--WoW API / Variables
local GetArenaRating = GetArenaRating
local GetRatedBattlegroundRankInfo = GetRatedBattlegroundRankInfo
local TogglePVPUIFrame = TogglePVPUIFrame

local displayNumberString = ""
local lastPanel

local brackets = {
	[1] = "Solo",
	[2] = "2x2",
	[3] = "3x3",
	[4] = "RBG",
}

local tbl = {}

local function OnEvent(self)
	lastPanel = self

	table.wipe(tbl)

	local _, _, _, _, currRating = GetRatedBattlegroundRankInfo()
	for i, enabled in ipairs(E.db.datatexts.ArenaRating) do
		if enabled then
			tinsert(tbl, format(displayNumberString, brackets[i], (i == 4 and currRating or GetArenaRating(i)) or 0))
		end
	end

	self.text:SetText(tconcat(tbl, " "))
end

local function OnClick()
	TogglePVPUIFrame()
end

local textFormat = "|cff00ff00%d|r |cffff0000%d|r %d%%"

local function OnEnter(self)
	DT:SetupTooltip(self)

	local pvpStats = C_CacheInstance:Get("ASMSG_PVP_STATS", {})
	for i, enabled in ipairs(E.db.datatexts.ArenaRating) do
		if enabled then
			DT.tooltip:AddLine(brackets[i])

			if i == 4 then
				local _, _, _, _, _, _, _, _, _, weekWins, weekGames, seasonWins, seasonGames = GetRatedBattlegroundRankInfo()
				local weekPerc, seasonPerc = weekGames == 0 and 0 or math.ceil(weekWins / weekGames * 100), seasonGames == 0 and 0 or math.ceil(seasonWins / seasonGames * 100)

				DT.tooltip:AddDoubleLine(PVP_LADDER_WEEK, format(textFormat, weekWins, weekGames - weekWins, weekPerc), 1, 1, 1, weekPerc >= 50 and 0 or 1, weekPerc >= 50 and 1 or 0, 0)
				DT.tooltip:AddDoubleLine(PVP_LADDER_SEASON, format(textFormat, seasonWins, seasonGames - seasonWins, seasonPerc), 1, 1, 1, seasonPerc >= 50 and 0 or 1, seasonPerc >= 50 and 1 or 0, 0)
			else
				local todayWins, todayGames, weekWins, weekGames, seasonWins, seasonGames = pvpStats[i] and pvpStats[i].TodayWins or 0, pvpStats[i] and pvpStats[i].TodayGames or 0, pvpStats[i] and pvpStats[i].weekWins or 0, pvpStats[i] and pvpStats[i].weekGames or 0,pvpStats[i] and pvpStats[i].seasonWins or 0, pvpStats[i] and pvpStats[i].seasonGames or 0
				local todayPerc, weekPerc, seasonPerc = todayGames == 0 and 0 or math.ceil(todayWins / todayGames * 100), weekGames == 0 and 0 or math.ceil(weekWins / weekGames * 100), seasonGames == 0 and 0 or math.ceil(seasonWins / seasonGames * 100)

				DT.tooltip:AddDoubleLine(PVP_LADDER_DAY, format(textFormat, todayWins, todayGames - todayWins, todayPerc), 1, 1, 1, todayPerc >= 50 and 0 or 1, todayPerc >= 50 and 1 or 0, 0)
				DT.tooltip:AddDoubleLine(PVP_LADDER_WEEK, format(textFormat, weekWins, weekGames - weekWins, weekPerc), 1, 1, 1, weekPerc >= 50 and 0 or 1, weekPerc >= 50 and 1 or 0, 0)
				DT.tooltip:AddDoubleLine(PVP_LADDER_SEASON, format(textFormat, seasonWins, seasonGames - seasonWins, seasonPerc), 1, 1, 1, seasonPerc >= 50 and 0 or 1, seasonPerc >= 50 and 1 or 0, 0)
			end
		end
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("ArenaRating", {"PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA"}, OnEvent, nil, OnClick, OnEnter, nil, PVP_YOUR_RATING)