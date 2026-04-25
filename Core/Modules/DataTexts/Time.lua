local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local LC = E.Libs.Compat

local _G = _G
local next, unpack = next, unpack
local format, strjoin = format, strjoin
local wipe, sort, tinsert = wipe, sort, tinsert
local utf8sub = string.utf8sub

local ToggleFrame = ToggleFrame
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local RequestRaidInfo = RequestRaidInfo
local SecondsToTime = SecondsToTime
local IsInInstance = IsInInstance

local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE
local TIMEMANAGER_TOOLTIP_LOCALTIME = TIMEMANAGER_TOOLTIP_LOCALTIME
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME
local VOICE_CHAT_BATTLEGROUND = VOICE_CHAT_BATTLEGROUND
local WINTERGRASP_IN_PROGRESS = WINTERGRASP_IN_PROGRESS

local APM = { _G.TIMEMANAGER_PM, _G.TIMEMANAGER_AM }
local lockoutColorExtended = { r = 0.3, g = 1, b = 0.3 }
local lockoutColorNormal = { r = .8, g = .8, b = .8 }
local lockoutInfoFormat = '%s%s %s |cffaaaaaa(%s, %s/%s)'
local lockoutInfoFormatNoEnc = '%s%s %s |cffaaaaaa(%s)'
local formatBattleGroundInfo = '%s: '
local enteredFrame = false
local updateTime = 5
local displayFormats = {
	na_nocolor = '',
	eu_nocolor = '',
	na_color = '',
	eu_color = ''
}

local OnUpdate, db

local function ToTime(start, seconds)
	return SecondsToTime(start, not seconds, nil, 3)
end

local function ConvertTime(h, m, s)
	local secs = db.seconds and s or ''
	if db.time24 then
		return h, m, secs, -1
	elseif h >= 12 then
		if h > 12 then h = h - 12 end
		return h, m, secs, 1
	else
		if h == 0 then h = 12 end
		return h, m, secs, 2
	end
end

local function GetTimeValues(tooltip)
	local dateTable = E:GetDateTime((tooltip and not db.localTime) or (not tooltip and db.localTime))
	return ConvertTime(dateTable.hour, dateTable.min, dateTable.sec)
end

local function OnClick(_, btn)
	if E:AlertCombat() then return end

	if btn == 'RightButton' then
		ToggleFrame(_G.TimeManagerFrame)
	else
		_G.GameTimeFrame:Click()
	end
end

local function OnLeave()
	enteredFrame = false
end

local lfgIcon = [[Interface\LFGFrame\LFGIcon-]]
local instanceIconByName = {}
local function GetInstanceImages(...)
	local numTextures = select('#', ...) / 4

	local argn, name, texture = 1
	for i = 1, numTextures do
		name, texture = select(argn, ...)
		if texture ~= '' then
			instanceIconByName[name] = lfgIcon..texture
		end
		argn = argn + 4
	end
end

local krcntw = E.locale == 'koKR' or E.locale == 'zhCN' or E.locale == 'zhTW'
local difficultyTag = { -- RNormal, Heroic
	(krcntw and _G.PLAYER_DIFFICULTY1) or utf8sub(_G.PLAYER_DIFFICULTY1, 1, 1),	-- N
	(krcntw and _G.PLAYER_DIFFICULTY2) or utf8sub(_G.PLAYER_DIFFICULTY2, 1, 1),	-- H
}

local function sortFunc(a,b) return a[1] < b[1] end

local collectedInstanceImages = false
local lockedInstances = {raids = {}, dungeons = {}}
local function OnEnter()
	DT.tooltip:ClearLines()

	if not enteredFrame then
		enteredFrame = true
		RequestRaidInfo()
	end

	if not collectedInstanceImages then
		GetInstanceImages(_G.CalendarEventGetTextures(1)) -- Populate for dungeon icons
		GetInstanceImages(_G.CalendarEventGetTextures(2)) -- Populate for raid icons

		collectedInstanceImages = true
	end

	local addedHeader = false
	local startTime = _G.GetWintergraspWaitTime()
	local _, instanceType = IsInInstance()

	if startTime == nil then
		startTime = WINTERGRASP_IN_PROGRESS
	elseif instanceType ~= "none" then
		startTime = QUEUE_TIME_UNAVAILABLE
	elseif startTime ~= 0 then
		startTime = ToTime(startTime)
	end

	if _G.WintergraspTimer.canQueue and startTime ~= 0 then
		if not addedHeader then
			DT.tooltip:AddLine(VOICE_CHAT_BATTLEGROUND)
			addedHeader = true
		end

		DT.tooltip:AddDoubleLine(format(formatBattleGroundInfo, L["Wintergrasp"]), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	wipe(lockedInstances.raids)
	wipe(lockedInstances.dungeons)

	for i = 1, GetNumSavedInstances() do
		local info = { GetSavedInstanceInfo(i) } -- we want to send entire info
		local name, _, _, difficulty, locked, extended, _, isRaid = unpack(info)
		if name and (locked or extended) then
			local isDungeon = difficulty == 2
			if isRaid or isDungeon then
				local sortName = name..difficulty
				local difficultyLetter = difficultyTag[difficulty]
				local buttonImg = instanceIconByName[name] and format('|T%s:20:20:0:0:96:96:0:64:0:64|t ', instanceIconByName[name]) or ''

				tinsert(lockedInstances[isRaid and 'raids' or 'dungeons'], { sortName, difficultyLetter, buttonImg, info })
			end
		end
	end

	if next(lockedInstances.raids) then
		if DT.tooltip:NumLines() > 0 then
			DT.tooltip:AddLine(' ')
		end
		DT.tooltip:AddLine(L["Saved Raid(s)"])

		sort(lockedInstances.raids, sortFunc)

		for _, info in next, lockedInstances.raids do
			local difficultyLetter, buttonImg = info[2], info[3]
			local name, _, reset, _, _, extended, _, _, maxPlayers = unpack(info[4])

			local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
			DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, buttonImg, maxPlayers, difficultyLetter, name), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
		end
	end

	if next(lockedInstances.dungeons) then
		if DT.tooltip:NumLines() > 0 then
			DT.tooltip:AddLine(' ')
		end
		DT.tooltip:AddLine(L["Saved Dungeon(s)"])

		sort(lockedInstances.dungeons, sortFunc)

		for _, info in next, lockedInstances.dungeons do
			local difficultyLetter, buttonImg = info[2], info[3]
			local name, _, reset, _, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(info[4])

			local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
			if numEncounters and numEncounters > 0 and (encounterProgress and encounterProgress > 0) then
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, buttonImg, maxPlayers, difficultyLetter, name, encounterProgress, numEncounters), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			else
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, buttonImg, maxPlayers, difficultyLetter, name), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			end
		end
	end

	local Hr, Min, Sec, AmPm = GetTimeValues(true)
	if DT.tooltip:NumLines() > 0 then
		DT.tooltip:AddLine(' ')
	end

	local dailyReset = _G.GetQuestResetTime()
	if dailyReset then
		DT.tooltip:AddDoubleLine(L["Daily Reset"], ToTime(dailyReset), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	DT.tooltip:AddDoubleLine(db.localTime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME, format(displayFormats[AmPm == -1 and 'eu_nocolor' or 'na_nocolor'], Hr, Min, Sec, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	DT.tooltip:Show()
end

local function OnEvent(self, event)
	if event == 'LOADING_SCREEN_ENABLED' and enteredFrame then
		OnLeave()
	elseif event == 'UPDATE_INSTANCE_INFO' and enteredFrame then
		OnEnter(self)
	end
end

function OnUpdate(self, t)
	self.timeElapsed = (self.timeElapsed or updateTime) - t
	if self.timeElapsed > 0 then return end
	self.timeElapsed = updateTime

	if db.flashInvite and _G.GameTimeFrame.flashInvite then
		E:Flash(self, 0.5, true)
	else
		E:StopFlash(self)
	end

	if enteredFrame then
		OnEnter(self)
	end

	local Hr, Min, Sec, AmPm = GetTimeValues()
	self.text:SetFormattedText(displayFormats[AmPm == -1 and 'eu_color' or 'na_color'], Hr, Min, Sec, APM[AmPm])
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	updateTime = db.seconds and 1 or 5

	local sec = db.seconds and ':|r%02d' or '|r%s'
	displayFormats.eu_nocolor = strjoin('', '%02d', ':|r%02d', sec)
	displayFormats.na_nocolor = strjoin('', '', '%d', ':|r%02d', sec, ' %s|r')
	displayFormats.eu_color = strjoin('', '%02d', hex, ':|r%02d', hex, sec)
	displayFormats.na_color = strjoin('', '', '%d', hex, ':|r%02d', hex, sec, hex, ' %s|r')


	OnUpdate(self, 20000)
end

DT:RegisterDatatext('Time', nil, { 'UPDATE_INSTANCE_INFO', 'LOADING_SCREEN_ENABLED' }, OnEvent, OnUpdate, OnClick, OnEnter, OnLeave, nil, nil, ApplySettings)
