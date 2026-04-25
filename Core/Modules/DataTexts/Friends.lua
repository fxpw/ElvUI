local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local ipairs = ipairs
local sort, next, wipe = sort, next, wipe
local format, gsub, strfind, strjoin = format, gsub, strfind, strjoin

local MouseIsOver = MouseIsOver
local EasyMenu = EasyMenu
local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local IsAltKeyDown = IsAltKeyDown
local SendChatMessage = SendChatMessage
local SetItemRef = SetItemRef
local ToggleFriendsFrame = ToggleFriendsFrame
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid

local GetNumFriends = GetNumFriends
local GetFriendInfo = GetFriendInfo
local InviteUnit = InviteUnit

local menuList = {
	{ text = _G.OPTIONS_MENU, isTitle = true, notCheckable=true},
	{ text = _G.INVITE, hasArrow = true, notCheckable=true, },
	{ text = _G.CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable=true, },
	{ text = _G.PLAYER_STATUS, hasArrow = true, notCheckable=true,
		menuList = {
			{ text = '|cff2BC226'.._G.AVAILABLE..'|r', notCheckable=true, func = function() if UnitIsAFK('player') then SendChatMessage('', 'AFK') elseif UnitIsDND('player') then SendChatMessage('', 'DND') end end },
			{ text = '|cffE7E716'.._G.DND..'|r', notCheckable=true, func = function() if not UnitIsDND('player') then SendChatMessage('', 'DND') end end },
			{ text = '|cffFF0000'.._G.AFK..'|r', notCheckable=true, func = function() if not UnitIsAFK('player') then SendChatMessage('', 'AFK') end end },
		},
	},
}

local function inviteClick(_, name)
	E.EasyMenu:Hide()

	if not (name and name ~= '') then return end

	InviteUnit(name)
end

local function whisperClick(_, name)
	E.EasyMenu:Hide()

	SetItemRef( 'player:'..name, format('|Hplayer:%1$s|h[%1$s]|h',name), 'LeftButton' )
end

local levelNameString = '|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r'
local levelNameClassString = '|cff%02x%02x%02x%d|r %s%s%s'
local characterFriend = _G.CHARACTER_FRIEND
local totalOnlineString = strjoin('', _G.FRIENDS_LIST_ONLINE, ': %s/%s')
local tthead = {r=0.4, g=0.78, b=1}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString, db = ''
local friendTable, info = {}, {}
local friendOnline, friendOffline = gsub(_G.ERR_FRIEND_ONLINE_SS,'|Hplayer:%%s|h%[%%s%]|h',''), gsub(_G.ERR_FRIEND_OFFLINE_S,'%%s','')
local dataValid = false
local statusTable = {
	AFK = ' |cffFFFFFF[|r|cffFF9900'..L["AFK"]..'|r|cffFFFFFF]|r',
	DND = ' |cffFFFFFF[|r|cffFF3333'..L["DND"]..'|r|cffFFFFFF]|r'
}

local function inGroup(name, realmName)
	if realmName and realmName ~= '' and realmName ~= E.myrealm then
		name = name..'-'..realmName
	end

	return (UnitInParty(name) or UnitInRaid(name)) and '|cffaaaaaa*|r' or ''
end

local function SortAlphabeticName(a, b)
	if a.name and b.name then
		return a.name < b.name
	end
end



local function BuildFriendTable(total)
	wipe(friendTable)

	if total == 0 then return end

	for i = 1, total do
		info.name, info.level, info.className, info.area, info.connected, info.status, info.notes = GetFriendInfo(i)
		info.afk = strfind(info.status, _G.AFK) and true or false
		info.dnd = strfind(info.status, _G.DND) and true or false
		if info and info.connected then
			local className = E:UnlocalizedClassName(info.className) or ''
			local status = (info.afk and statusTable.AFK) or (info.dnd and statusTable.DND) or ''
			friendTable[i] = {
				name = info.name,			--1
				level = info.level,			--2
				class = className,			--3
				zone = info.area,			--4
				online = info.connected,	--5
				status = status,			--6
				notes = info.notes,			--7
			}
		end
	end
	if next(friendTable) then
		sort(friendTable, SortAlphabeticName)
	end
end

local function Click(self, btn)
	if btn == 'RightButton' then
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		for _, info in ipairs(friendTable) do
			if info.online then
				local shouldSkip = false
				if (info.status == statusTable.AFK) and db.hideAFK then
					shouldSkip = true
				elseif (info.status == statusTable.DND) and db.hideDND then
					shouldSkip = true
				end
				if not shouldSkip then
					local classc, levelc = E:ClassColor(info.class), GetQuestDifficultyColor(info.level)
					if not classc then classc = levelc end

					menuCountWhispers = menuCountWhispers + 1
					menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.name), arg1 = info.name, notCheckable=true, func = whisperClick}

					if inGroup(info.name) == '' then
						menuCountInvites = menuCountInvites + 1
						menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,classc.r*255,classc.g*255,classc.b*255,info.name), arg1 = info.name, notCheckable=true, func = inviteClick}
					end
				end
			end
		end

		E:SetEasyMenuAnchor(E.EasyMenu, self)
		EasyMenu(menuList, E.EasyMenu, nil, nil, nil, 'MENU')
	elseif not E:AlertCombat() then
		ToggleFriendsFrame(1)
	end
end

local lastTooltipXLineHeader
local function TooltipAddXLine(X, header, ...)
	X = (X == true and 'AddDoubleLine') or 'AddLine'
	if lastTooltipXLineHeader ~= header then
		DT.tooltip[X](DT.tooltip, ' ')
		DT.tooltip[X](DT.tooltip, header)
		lastTooltipXLineHeader = header
	end
	DT.tooltip[X](DT.tooltip, ...)
end

local function OnEnter()
	DT.tooltip:ClearLines()
	lastTooltipXLineHeader = nil

	local numberOfFriends, onlineFriends = GetNumFriends()

	-- no friends online, quick exit
	if onlineFriends == 0 then return end

	if not dataValid then
		-- only retrieve information for all on-line members when we actually view the tooltip
		if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
		dataValid = true
	end

	local zonec, classc, levelc

	DT.tooltip:AddDoubleLine(L["Friends List"], format(totalOnlineString, onlineFriends, numberOfFriends),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
	if onlineFriends > 0 then
		for _, info in ipairs(friendTable) do
			if info.online then
				local shouldSkip = false
				if (info.status == statusTable.AFK) and db.hideAFK then
					shouldSkip = true
				elseif (info.status == statusTable.DND) and db.hideDND then
					shouldSkip = true
				end
				if not shouldSkip then
					if E.MapInfo.zoneText and (E.MapInfo.zoneText == info.zone) then zonec = activezone else zonec = inactivezone end
					classc, levelc = E:ClassColor(info.class), GetQuestDifficultyColor(info.level)
					if not classc then classc = levelc end

					TooltipAddXLine(true, characterFriend, format(levelNameClassString,levelc.r*255,levelc.g*255,levelc.b*255,info.level,info.name,inGroup(info.name),info.status),info.zone,classc.r,classc.g,classc.b,zonec.r,zonec.g,zonec.b)
				end
			end
		end
	end

	DT.tooltip:Show()
end

local function OnEvent(self, event, message)
	local _, onlineFriends = GetNumFriends()

	-- special handler to detect friend coming online or going offline
	-- when this is the case, we invalidate our buffered table and update the
	-- datatext information
	if event == 'CHAT_MSG_SYSTEM' then
		if not (strfind(message, friendOnline) or strfind(message, friendOffline)) then return end
	end
	-- force update when showing tooltip
	dataValid = false

	if not IsAltKeyDown() and event == 'MODIFIER_STATE_CHANGED' and MouseIsOver(self) then
		OnEnter(self)
	end

	if db.NoLabel then
		self.text:SetFormattedText(displayString, onlineFriends)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or _G.FRIENDS..': ', onlineFriends)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
end

DT:RegisterDatatext('Friends', _G.SOCIAL_LABEL, { 'FRIENDLIST_UPDATE', 'CHAT_MSG_SYSTEM', 'MODIFIER_STATE_CHANGED' }, OnEvent, nil, Click, OnEnter, nil, _G.FRIENDS, nil, ApplySettings)
