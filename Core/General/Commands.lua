local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local AB = E:GetModule('ActionBars')

local _G = _G
local type, tonumber = type, tonumber
local lower, wipe, next, print = strlower, wipe, next, print
local format = format
local split = strsplit

local ReloadUI = ReloadUI

local DisableAddOn = DisableAddOn
local EnableAddOn = EnableAddOn
local GetAddOnInfo = GetAddOnInfo
local GetNumAddOns = GetNumAddOns

local CreateFrame = CreateFrame
local GetAddOnCPUUsage = GetAddOnCPUUsage
local GetCVarBool = GetCVarBool
local GuildControlGetRankName = GuildControlGetRankName
local GuildControlGetNumRanks = GuildControlGetNumRanks
local GetGuildRosterInfo = GetGuildRosterInfo
local GetGuildRosterLastOnline = GetGuildRosterLastOnline
local GuildUninvite = GuildUninvite
local GetNumGuildMembers = GetNumGuildMembers
local ResetCPUUsage = ResetCPUUsage
local SendChatMessage = SendChatMessage
local UpdateAddOnCPUUsage = UpdateAddOnCPUUsage

local debugprofilestop = debugprofilestop

function E:Grid(msg)
	msg = msg and tonumber(msg)
	if type(msg) == 'number' and (msg <= 256 and msg >= 4) then
		E.db.gridSize = msg
		E:Grid_Show()
	elseif ElvUIGrid and ElvUIGrid:IsShown() then
		E:Grid_Hide()
	else
		E:Grid_Show()
	end
end

function E:HDCheck(msg)
	E:Print(E:IsHDPatch() and L["You have the HD patch 'Interface Windows' Enabled. Disable the Interface patch (patch-xxxx-9.mpq) if you are experiencing any interface issues."] or L["HD patch 'Interface Windows' (patch-xxxx-9.mpq) Disabled"])
end

function E:LuaError(msg)
	local switch = lower(msg)
	if switch == 'on' or switch == '1' then
		local addon = E.Status_Addons
		local bugsack = E.Status_Bugsack

		for i = 1, GetNumAddOns() do
			local name = GetAddOnInfo(i)
			if (not addon[name] and (switch == '1' or not bugsack[name])) and E:IsAddOnEnabled(name) then
				DisableAddOn(name, E.myguid)
				ElvDB.DisabledAddOns[name] = i
			end
		end

		E:SetCVar('scriptErrors', 1)
		ReloadUI()
	elseif switch == 'off' or switch == '0' then
		if switch == 'off' then
			E:SetCVar('scriptProfile', 0)
			E:SetCVar('scriptErrors', 0)
			E:Print('Lua errors off.')

			if E:IsAddOnEnabled('ElvUI_CPU') then
				DisableAddOn('ElvUI_CPU')
			end
		end

		if next(ElvDB.DisabledAddOns) then
			for name in pairs(ElvDB.DisabledAddOns) do
				EnableAddOn(name, E.myname)
			end

			wipe(ElvDB.DisabledAddOns)
			ReloadUI()
		end
	else
		E:Print('/edebug on - /edebug off')
	end
end

function E:DisplayCommands()
	print(L["EHELP_COMMANDS"])
end

local function OnCallback(command)
	_G.MacroEditBox:GetScript('OnEvent')(_G.MacroEditBox, 'EXECUTE_CHAT_LINE', command)
end

function E:DelayScriptCall(msg)
	local secs, command = msg:match('^(%S+)%s+(.*)$')
	secs = tonumber(secs)
	if not secs or (#command == 0) then
		self:Print('usage: /in <seconds> <command>')
		self:Print('example: /in 1.5 /say hi')
	else
		E:Delay(secs, OnCallback, command)
	end
end


local BLIZZARD_ADDONS = {
	'Blizzard_AchievementUI',
	'Blizzard_ArenaUI',
	'Blizzard_AuctionUI',
	'Blizzard_BarbershopUI',
	'Blizzard_BattlefieldMinimap',
	'Blizzard_BindingUI',
	'Blizzard_Calendar',
	'Blizzard_CombatLog',
	'Blizzard_CombatText',
	'Blizzard_DebugTools',
	'Blizzard_GlyphUI',
	'Blizzard_GMChatUI',
	'Blizzard_GMSurveyUI',
	'Blizzard_GuildBankUI',
	'Blizzard_InspectUI',
	'Blizzard_ItemSocketingUI',
	'Blizzard_MacroUI',
	'Blizzard_RaidUI',
	'Blizzard_TalentUI',
	'Blizzard_TimeManager',
	'Blizzard_TokenUI',
	'Blizzard_TradeSkillUI',
	'Blizzard_TrainerUI'
}

do
	local function Enable(addon)
		local _, _, _, _, _, reason = GetAddOnInfo(addon)
		if reason == 'DISABLED' then
			EnableAddOn(addon)
			E:Print('The following addon was re-enabled:', addon)
		end
	end

	function E:EnableBlizzardAddOns()
		for _, addon in pairs(BLIZZARD_ADDONS) do
			Enable(addon)
		end
	end
end

function E:DBConvertProfile()
	E.db.dbConverted = nil
	E:DBConversions()
	ReloadUI()
end

function E:BGStats()
	DT.ForceHideBGStats = nil
	DT:LoadDataTexts()

	E:Print(L["Battleground datatexts will now show again if you are inside a battleground."])
end

-- make this a locale later?
local MassKickMessage = 'Guild Cleanup Results: Removed all guild members below rank %s, that have a minimal level of %s, and have not been online for at least: %s days.'
function E:MassGuildKick(msg)
	local minLevel, minDays, minRankIndex = split(',', msg)
	minRankIndex = tonumber(minRankIndex)
	minLevel = tonumber(minLevel)
	minDays = tonumber(minDays)

	if not minLevel or not minDays then
		E:Print('Usage: /cleanguild <minLevel>, <minDays>, [<minRankIndex>]')
		return
	end

	if minDays > 31 then
		E:Print('Maximum days value must be below 32.')
		return
	end

	if not minRankIndex then minRankIndex = GuildControlGetNumRanks() - 1 end

	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex, level, _, _, note, officerNote, connected, _, classFileName = GetGuildRosterInfo(i)
		local minLevelx = minLevel

		if classFileName == 'DEATHKNIGHT' then
			minLevelx = minLevelx + 55
		end

		if not connected then
			local years, months, days = GetGuildRosterLastOnline(i)
			if days ~= nil and ((years > 0 or months > 0 or days >= minDays) and rankIndex >= minRankIndex)
			and note ~= nil and officerNote ~= nil and (level <= minLevelx) then
				GuildUninvite(name)
			end
		end
	end

	SendChatMessage(format(MassKickMessage, GuildControlGetRankName(minRankIndex), minLevel, minDays), 'GUILD')
end

local num_frames = 0
local function OnUpdate()
	num_frames = num_frames + 1
end
local f = CreateFrame('Frame')
f:Hide()
f:SetScript('OnUpdate', OnUpdate)

local toggleMode, debugTimer, cpuImpactMessage = false, 0, 'Consumed %sms per frame. Each frame took %sms to render.'
function E:GetCPUImpact()
	if not GetCVarBool('scriptProfile') then
		E:Print('For `/cpuimpact` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.')
		return
	end

	if not toggleMode then
		ResetCPUUsage()
		toggleMode, num_frames, debugTimer = true, 0, debugprofilestop()
		E:Print('CPU Impact being calculated, type /cpuimpact to get results when you are ready.')
		f:Show()
	else
		f:Hide()
		local ms_passed = debugprofilestop() - debugTimer
		UpdateAddOnCPUUsage()

		local per, passed =
			((num_frames == 0 and 0) or (GetAddOnCPUUsage('ElvUI') / num_frames)),
			((num_frames == 0 and 0) or (ms_passed / num_frames))
		E:Print(format(cpuImpactMessage, per and per > 0 and format('%.3f', per) or 0, passed and passed > 0 and format('%.3f', passed) or 0))
		toggleMode = false
	end
end

function E:LoadCommands()
	if E.private.actionbar.enable then
		E:RegisterChatCommand('kb', AB.ActivateBindMode)
	end

	E:RegisterChatCommand('in', 'DelayScriptCall')
	E:RegisterChatCommand('ec', 'ToggleOptions')
	E:RegisterChatCommand('elvui', 'ToggleOptions')

	E:RegisterChatCommand('bgstats', DT.ToggleBattleStats)

	E:RegisterChatCommand('moveui', 'ToggleMoveMode')
	E:RegisterChatCommand('resetui', 'ResetUI')

	E:RegisterChatCommand('emove', 'ToggleMoveMode')
	E:RegisterChatCommand('ereset', 'ResetUI')
	E:RegisterChatCommand('edebug', 'LuaError')


	E:RegisterChatCommand('ehelp', 'DisplayCommands')
	E:RegisterChatCommand('ecommands', 'DisplayCommands')
	E:RegisterChatCommand('estatus', 'ShowStatusReport')
	E:RegisterChatCommand('efixdb', 'DBConvertProfile')
	E:RegisterChatCommand('egrid', 'Grid')

	-- custom commands
	E:RegisterChatCommand('ishd', 'HDCheck')

	-- older commands
	E:RegisterChatCommand('bgstats', 'BGStats')
	E:RegisterChatCommand('cleanguild', 'MassGuildKick')
	E:RegisterChatCommand('eblizzard', 'EnableBlizzardAddOns')

	E:RegisterChatCommand('cpuimpact', 'GetCPUImpact')
	E:RegisterChatCommand('cpuusage', 'GetTopCPUFunc')
	-- args: module, showall, delay, minCalls
	-- Example1: /cpuusage all
	-- Example2: /cpuusage Bags true
	-- Example3: /cpuusage UnitFrames nil 50 25
	-- Note: showall, delay, and minCalls will default if not set
	-- arg1 can be 'all' this will scan all registered modules!
end