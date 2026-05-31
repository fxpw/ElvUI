local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
local ipairs, next, pairs, select, setmetatable, tonumber, type, unpack, tostring = ipairs, next, pairs, select, setmetatable, tonumber, type, unpack, tostring
local tinsert, tremove, sort, wipe = table.insert, table.remove, table.sort, (wipe or table.wipe)
local strmatch = string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local GetRaidTargetIndex = GetRaidTargetIndex
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local UnitInVehicle = UnitInVehicle
local UnitIsUnit = UnitIsUnit
local IsResting = IsResting
local UnitAffectingCombat = UnitAffectingCombat
local UnitAura = UnitAura
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitIsTapDenied = UnitIsTapped -- 3.3.5a fallback (tap-denied semantics absorbed by tapped flag)

mod.StyleFilterStackPattern = '([^\n:]+):?(%d*)$'

-- Sirus 3.3.5a C_Timer.NewTimer is dot-style (only :After / :NewTicker use colon)
local function C_Timer_NewTimer(delay, cb)
	return C_Timer.NewTimer(delay, cb)
end

local function StyleFilterGetColor(color, fallback)
	if type(color) == 'table' then
		return color.r or fallback.r, color.g or fallback.g, color.b or fallback.b, color.a or fallback.a
	end
	return fallback.r, fallback.g, fallback.b, fallback.a
end

local function StyleFilterHideTargetVisuals(frame)
	local ti = frame and frame.TargetIndicator
	if not ti then return end
	if ti.TopIndicator then ti.TopIndicator:Hide() end
	if ti.LeftIndicator then ti.LeftIndicator:Hide() end
	if ti.RightIndicator then ti.RightIndicator:Hide() end
	if ti.Shadow then ti.Shadow:Hide() end
	if ti.Spark then ti.Spark:Hide() end
end

mod.TriggerConditions = {
	raidTargets = {
		-- GetRaidTargetIndex() returns 1..8; map to the action subkey used in DB.
		[1] = "star",
		[2] = "circle",
		[3] = "diamond",
		[4] = "triangle",
		[5] = "moon",
		[6] = "square",
		[7] = "cross",
		[8] = "skull",
	},
	frameTypes = {
		["FRIENDLY_PLAYER"] = "friendlyPlayer",
		["FRIENDLY_NPC"] = "friendlyNPC",
		["ENEMY_PLAYER"] = "enemyPlayer",
		["ENEMY_NPC"] = "enemyNPC",
	},
	roles = {
		["TANK"] = "tank",
		["HEALER"] = "healer",
		["DAMAGER"] = "damager"
	},
	difficulties = {
		-- WotLK GetInstanceInfo difficultyIDs, per instanceType (party: 1=N,2=H; raid: 1/2=10/25N, 3/4=10/25H)
		party = {
			[1] = "normal",
			[2] = "heroic",
		},
		raid = {
			[1] = "normal",
			[2] = "normal",
			[3] = "heroic",
			[4] = "heroic",
		},
	},
}

-- Sirus-only totem/uniqueUnit tracking removed in 4g.

--[==[ DEAD-CODE BLOCK BELOW (totem/uniqueUnit data tables, retained as comment for historical reference; safe to delete):
local _UNUSED_totemTypes = {
	air = { -- Air Totems
		[8177] = "a1",	-- Grounding Totem
		[10595] = "a2",	-- Nature Resistance Totem I
		[10600] = "a2",	-- Nature Resistance Totem II
		[10601] = "a2",	-- Nature Resistance Totem III
		[25574] = "a2",	-- Nature Resistance Totem IV
		[58746] = "a2",	-- Nature Resistance Totem V
		[58749] = "a2",	-- Nature Resistance Totem VI
		[6495] = "a3",	-- Sentry Totem
		[8512] = "a4",	-- Windfury Totem
		[3738] = "a5",	-- Wrath of Air Totem
	},
	earth = { -- Earth Totems
		[2062] = "e1",	-- Earth Elemental Totem
		[2484] = "e2",	-- Earthbind Totem
		[5730] = "e3",	-- Stoneclaw Totem I
		[6390] = "e3",	-- Stoneclaw Totem II
		[6391] = "e3",	-- Stoneclaw Totem III
		[6392] = "e3",	-- Stoneclaw Totem IV
		[10427] = "e3",	-- Stoneclaw Totem V
		[10428] = "e3",	-- Stoneclaw Totem VI
		[25525] = "e3",	-- Stoneclaw Totem VII
		[58580] = "e3",	-- Stoneclaw Totem VIII
		[58581] = "e3",	-- Stoneclaw Totem IX
		[58582] = "e3",	-- Stoneclaw Totem X
		[8071] = "e4",	-- Stoneskin Totem I -- Faction Champs
		[8154] = "e4",	-- Stoneskin Totem II
		[8155] = "e4",	-- Stoneskin Totem III
		[10406] = "e4",	-- Stoneskin Totem IV
		[10407] = "e4",	-- Stoneskin Totem V
		[10408] = "e4",	-- Stoneskin Totem VI
		[25508] = "e4",	-- Stoneskin Totem VII
		[25509] = "e4",	-- Stoneskin Totem VIII
		[58751] = "e4",	-- Stoneskin Totem IX
		[58753] = "e4",	-- Stoneskin Totem X
		[8075] = "e5",	-- Strength of Earth Totem I -- Faction Champs
		[8160] = "e5",	-- Strength of Earth Totem II
		[8161] = "e5",	-- Strength of Earth Totem III
		[10442] = "e5",	-- Strength of Earth Totem IV
		[25361] = "e5",	-- Strength of Earth Totem V
		[25528] = "e5",	-- Strength of Earth Totem VI
		[57622] = "e5",	-- Strength of Earth Totem VII
		[58643] = "e5",	-- Strength of Earth Totem VIII
		[8143] = "e6",	-- Tremor Totem
	},
	fire = { -- Fire Totems
		[2894] = "f1",	-- Fire Elemental Totem
		[8227] = "f2",	-- Flametongue Totem I -- Faction Champs
		[8249] = "f2",	-- Flametongue Totem II
		[10526] = "f2",	-- Flametongue Totem III
		[16387] = "f2",	-- Flametongue Totem IV
		[25557] = "f2",	-- Flametongue Totem V
		[58649] = "f2",	-- Flametongue Totem VI
		[58652] = "f2",	-- Flametongue Totem VII
		[58656] = "f2",	-- Flametongue Totem VIII
		[8181] = "f3",	-- Frost Resistance Totem I
		[10478] = "f3",	-- Frost Resistance Totem II
		[10479] = "f3",	-- Frost Resistance Totem III
		[25560] = "f3",	-- Frost Resistance Totem IV
		[58741] = "f3",	-- Frost Resistance Totem V
		[58745] = "f3",	-- Frost Resistance Totem VI
		[8190] = "f4",	-- Magma Totem I
		[10585] = "f4",	-- Magma Totem II
		[10586] = "f4",	-- Magma Totem III
		[10587] = "f4",	-- Magma Totem IV
		[25552] = "f4",	-- Magma Totem V
		[58731] = "f4",	-- Magma Totem VI
		[58734] = "f4",	-- Magma Totem VII
		[3599] = "f5",	-- Searing Totem I -- Faction Champs
		[6363] = "f5",	-- Searing Totem II
		[6364] = "f5",	-- Searing Totem III
		[6365] = "f5",	-- Searing Totem IV
		[10437] = "f5",	-- Searing Totem V
		[10438] = "f5",	-- Searing Totem VI
		[25533] = "f5",	-- Searing Totem VII
		[58699] = "f5",	-- Searing Totem VIII
		[58703] = "f5",	-- Searing Totem IX
		[58704] = "f5",	-- Searing Totem X
		[30706] = "f6",	-- Totem of Wrath I
		[57720] = "f6",	-- Totem of Wrath II
		[57721] = "f6",	-- Totem of Wrath III
		[57722] = "f6",	-- Totem of Wrath IV
	},
	water = { -- Water Totems
		[8170] = "w1",	-- Cleansing Totem
		[8184] = "w2",	-- Fire Resistance Totem I
		[10537] = "w2",	-- Fire Resistance Totem II
		[10538] = "w2",	-- Fire Resistance Totem III
		[25563] = "w2",	-- Fire Resistance Totem IV
		[58737] = "w2",	-- Fire Resistance Totem V
		[58739] = "w2",	-- Fire Resistance Totem VI
		[5394] = "w3",	-- Healing Stream Totem I -- Faction Champs
		[6375] = "w3",	-- Healing Stream Totem II
		[6377] = "w3",	-- Healing Stream Totem III
		[10462] = "w3",	-- Healing Stream Totem IV
		[10463] = "w3",	-- Healing Stream Totem V
		[25567] = "w3",	-- Healing Stream Totem VI
		[58755] = "w3",	-- Healing Stream Totem VII
		[58756] = "w3",	-- Healing Stream Totem VIII
		[58757] = "w3",	-- Healing Stream Totem IX
		[5675] = "w4",	-- Mana Spring Totem I
		[10495] = "w4",	-- Mana Spring Totem II
		[10496] = "w4",	-- Mana Spring Totem III
		[10497] = "w4",	-- Mana Spring Totem IV
		[25570] = "w4",	-- Mana Spring Totem V
		[58771] = "w4",	-- Mana Spring Totem VI
		[58773] = "w4",	-- Mana Spring Totem VII
		[58774] = "w4",	-- Mana Spring Totem VIII
		[16190] = "w5"	-- Mana Tide Totem
	},
	other = {
		[724] = "o1"	-- Lightwell
	}
}
]==]
-- end dead-code block

function mod:StyleFilterTickerCallback(frame, ticker, timer)
	if frame and frame:IsShown() then
		mod:StyleFilterUpdate(frame, 'FAKE_AuraWaitTimer')
	end

	if ticker[timer] then
		ticker[timer]:Cancel()
		ticker[timer] = nil
	end
end

function mod:StyleFilterTickerCreate(delay, frame, ticker, timer)
	return C_Timer_NewTimer(delay, function() mod:StyleFilterTickerCallback(frame, ticker, timer) end)
end

function mod:StyleFilterAuraWait(frame, ticker, timer, timeLeft, mTimeLeft)
	if not ticker[timer] then
		local updateIn = timeLeft - mTimeLeft
		if updateIn > 0 then -- add a tenth of a second to prevent firing on the same second
			ticker[timer] = mod:StyleFilterTickerCreate(updateIn + 0.1, frame, ticker, timer)
		end
	end
end

-- Reusable scratch buckets (temp map, per-spell info, per-index data) to avoid hot-path allocations.
local styleFilterTempPool = {}
local styleFilterInfoPool = {}
local styleFilterInfoInUse = {}
local styleFilterDataPool = {}

local function acquireInfoTable()
	local t = tremove(styleFilterInfoPool) or {}
	styleFilterInfoInUse[#styleFilterInfoInUse + 1] = t
	return t
end

local function acquireDataTable(count, expiration, source)
	local t = tremove(styleFilterDataPool) or {}
	t.count = count
	t.expiration = expiration
	t.source = source
	t.modRate = 1
	return t
end

function mod:StyleFilterReleaseAuraData(temp)
	if not temp then return end
	wipe(temp)
	styleFilterTempPool[#styleFilterTempPool + 1] = temp
	for i = #styleFilterInfoInUse, 1, -1 do
		local info = styleFilterInfoInUse[i]
		for index, data in pairs(info) do
			wipe(data)
			styleFilterDataPool[#styleFilterDataPool + 1] = data
			info[index] = nil
		end
		wipe(info) -- defensive: clear any non-data keys
		styleFilterInfoPool[#styleFilterInfoPool + 1] = info
		styleFilterInfoInUse[i] = nil
	end
end

function mod:StyleFilterAuraData(frame, filter, unit)
	local temp = tremove(styleFilterTempPool) or {}
	wipe(temp)

	if unit then
		-- 3.3.5a positions: 1 name, 4 count, 7 expirationTime, 8 source, 11 spellID
		local index = 1
		local name, _, _, count, _, _, expiration, source, _, _, spellID = UnitAura(unit, index, filter)
		while name do
			local info = temp[name] or temp[spellID]
			if not info then info = acquireInfoTable() end

			temp[name] = info
			temp[spellID] = info

			info[index] = acquireDataTable(count, expiration, source)

			index = index + 1
			name, _, _, count, _, _, expiration, source, _, _, spellID = UnitAura(unit, index, filter)
		end
	end

	return temp
end

function mod:StyleFilterAuraCheck(frame, names, tickers, filter, mustHaveAll, missing, minTimeLeft, maxTimeLeft, fromMe, fromPet, onMe, onPet)
	if type(tickers) ~= 'table' then
		tickers = {}
	end

	if not filter then filter = 'HELPFUL' end

	local total, matches, now = 0, 0, GetTime()
	local temp -- data of current auras

	for key, value in pairs(names) do
		if value then -- only if they are turned on
			total = total + 1

			if not temp then
				temp = mod:StyleFilterAuraData(frame, filter, (onMe and 'player') or (onPet and 'pet') or frame.unit)
			end

			local spell, count = strmatch(key, mod.StyleFilterStackPattern)
			local info = temp[spell] or temp[tonumber(spell)]

			if info then
				local stacks = tonumber(count)
				local hasMinTime = minTimeLeft and minTimeLeft ~= 0
				local hasMaxTime = maxTimeLeft and maxTimeLeft ~= 0

				for _, data in pairs(info) do
					if not stacks or (data.count and data.count >= stacks) then
						local isMe, isPet = data.source == 'player' or data.source == 'vehicle', data.source == 'pet'
						if (fromMe and fromPet and (isMe or isPet)) or (fromMe and isMe) or (fromPet and isPet) or (not fromMe and not fromPet) then
							local timeLeft = (hasMinTime or hasMaxTime) and data.expiration and ((data.expiration - now) / (data.modRate or 1))
							local minTimeAllow = not hasMinTime or (timeLeft and timeLeft > minTimeLeft)
							local maxTimeAllow = not hasMaxTime or (timeLeft and timeLeft < maxTimeLeft)

							if minTimeAllow and maxTimeAllow then
								matches = matches + 1
							end

							if timeLeft then
								if not tickers[matches] then tickers[matches] = {} end
								if hasMinTime then mod:StyleFilterAuraWait(frame, tickers[matches], 'hasMinTimer', timeLeft, minTimeLeft) end
								if hasMaxTime then mod:StyleFilterAuraWait(frame, tickers[matches], 'hasMaxTimer', timeLeft, maxTimeLeft) end
							end
						end
					end
				end
			end

			local stale = matches + 1
			local ticker = tickers[stale]
			while ticker and (ticker.hasMinTimer or ticker.hasMaxTimer) do -- cancel stale timers
				if ticker.hasMinTimer then ticker.hasMinTimer:Cancel() ticker.hasMinTimer = nil end
				if ticker.hasMaxTimer then ticker.hasMaxTimer:Cancel() ticker.hasMaxTimer = nil end

				stale = stale + 1
				ticker = tickers[stale]
			end
		end
	end

	if temp then
		mod:StyleFilterReleaseAuraData(temp)
	end

	if total == 0 then
		return nil
	else
		return ((mustHaveAll and not missing) and total == matches)
			or ((not mustHaveAll and not missing) and matches > 0)
			or ((not mustHaveAll and missing) and matches == 0)
			or ((mustHaveAll and missing) and total ~= matches)
	end
end

function mod:StyleFilterCooldownCheck(names, mustHaveAll)
	local _, gcd = GetSpellCooldown(61304)
	local total, count = 0, 0

	for name, value in pairs(names) do
		if GetSpellInfo(name) then -- only valid spells
			if value == "ONCD" or value == "OFFCD" then
				total = total + 1
				local _, duration = GetSpellCooldown(name)

				if (duration > gcd and value == "ONCD")
				or (duration <= gcd and value == "OFFCD") then
					count = count + 1
				end
			end
		end
	end

	if total == 0 then
		return nil
	else
		return (mustHaveAll and total == count) or (not mustHaveAll and count > 0)
	end
end

-- Helpers backing the retail-style Set/ClearChanges path.
function mod:StyleFilterHiddenState(c)
	return c and ((c.NameOnly and c.Visibility and 3) or (c.NameOnly and 2) or (c.Visibility and 1))
end

function mod:StyleFilterBorderLock(backdrop, r, g, b, a)
	if not backdrop then return end
	if r then
		backdrop.forcedBorderColors = {r, g, b, a}
		if backdrop.SetBackdropBorderColor then
			backdrop:SetBackdropBorderColor(r, g, b, a)
		end
	else
		backdrop.forcedBorderColors = nil
		if backdrop.SetBackdropBorderColor then
			backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end
end

function mod:StyleFilterBaseUpdate(frame, state)
	if not frame.StyleFilterBaseAlreadyUpdated then -- skip updates from UpdatePlateBase
		mod:UpdatePlate(frame, true) -- enable elements back
	end

	local db = mod:PlateDB(frame) -- keep this after UpdatePlate
	if not db.nameOnly then
		if db.power and db.power.enable and frame.Power and frame.Power.ForceUpdate then frame.Power:ForceUpdate() end
		if db.health and db.health.enable and frame.Health and frame.Health.ForceUpdate then frame.Health:ForceUpdate() end
		if db.castbar and db.castbar.enable and frame.Castbar and frame.Castbar.ForceUpdate then frame.Castbar:ForceUpdate() end

		if mod.db.threat and mod.db.threat.enable and mod.db.threat.useThreatColor and frame.ThreatIndicator and frame.ThreatIndicator.ForceUpdate then
			if not UnitIsTapDenied(frame.unit) then
				frame.ThreatIndicator:ForceUpdate() -- accounts for threat health colour
			end
		end

		if frame:IsElementEnabled('TargetIndicator') and mod:StyleFilterChanges(frame).ShowTargetIndicator then
			frame.TargetIndicator:ForceUpdate()
		end
	end

	if frame.isTarget and mod.SetupTarget then
		mod:SetupTarget(frame, db.nameOnly) -- so the classbar/target glow reappears
	end

	if state and not mod.SkipFading and mod.PlateFade then
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, 0, 1) -- fade those back in so it looks clean
	end
end

function mod:StyleFilterClearVisibility(frame, previous)
	local state = mod:StyleFilterHiddenState(frame.StyleFilterChanges)

	if (previous == 1 or previous == 3) and (state ~= 1 and state ~= 3) then
		frame:ClearAllPoints() -- pull the frame back in
		frame:SetPoint('CENTER')
	end

	if previous and not state then
		mod:StyleFilterBaseUpdate(frame, previous == 1)
	end
end

-- Returns the default tag format string for a given element (`name`, `level`,
-- `health.text`, `power.text`, `title`) on `frame` based on its UnitType DB.
-- Used by StyleFilterClearChanges to restore the tag after a Name/Level/Health/
-- Power/TitleTag action is rolled back.
local STYLEFILTER_DEFAULT_TAGS = {
	name   = '[name:long]',
	level  = '[smartlevel]',
	health = '',
	power  = '',
	title  = '',
}

function mod:StyleFilterDefaultTag(frame, kind)
	local unitDB = frame.UnitType and mod.db.units and mod.db.units[frame.UnitType]
	if unitDB then
		local section
		if kind == 'health' or kind == 'power' then
			section = unitDB[kind] and unitDB[kind].text
		else
			section = unitDB[kind]
		end
		if section then
			local fmt = section.textFormat or section.format
			if fmt and fmt ~= '' then return fmt end
		end
	end
	return STYLEFILTER_DEFAULT_TAGS[kind] or ''
end

local function StyleFilterSetTag(frame, fontString, tagFormat)
	if not (frame and fontString) then return end
	if tagFormat and tagFormat ~= '' then
		frame:Tag(fontString, tagFormat)
		fontString:Show()
	else
		frame:Untag(fontString)
		fontString:Hide()
	end
end

function mod:StyleFilterSetChanges(frame, actions, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged, ShowHealthChanged, NameTagChanged, LevelTagChanged, PowerTagChanged, TargetIndicatorChanged, MouseoverHighlightChanged)
	if VisibilityChanged then
		frame.StyleChanged = true
		frame.VisibilityChanged = true
		frame.StyleFilterChanges.Visibility = true
		frame.StyleFilterChanges.Hidden = true
		frame:Hide()
		return --We hide it. Lets not do other things (no point)
	end
	if FrameLevelChanged then
		frame.StyleChanged = true
		frame.FrameLevelChanged = actions.frameLevel
		frame.pendingFrameLevelReset = nil -- cancel deferred reset
		local boost = actions.frameLevel * 100
		if frame.appliedFrameLevelBoost ~= boost then
			frame.appliedFrameLevelBoost = boost
			local base = frame._npBase or frame:GetFrameLevel()
			frame.Health:SetFrameLevel(base + 1 + boost)
			mod:Health_SyncBorderLevel(frame.Health) -- keep border glued above the bar
			if frame.Castbar then frame.Castbar:SetFrameLevel(base + 2 + boost) end
			if frame.Auras then
				if frame.Auras.Buffs  then frame.Auras.Buffs:SetFrameLevel(base + 2 + boost)  end
				if frame.Auras.Debuffs then frame.Auras.Debuffs:SetFrameLevel(base + 2 + boost) end
			end
		end
	end
	if HealthColorChanged then
		frame.StyleChanged = true
		frame.HealthColorChanged = true
		local hc = actions.color.healthColor
		local hr, hg, hb, ha = StyleFilterGetColor(hc, { r = 1, g = 1, b = 1, a = 1 })
		if actions.color.healthClass then
			local classColor = frame.classFile and ((CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[frame.classFile]) or RAID_CLASS_COLORS[frame.classFile])
			if classColor then hr, hg, hb = classColor.r, classColor.g, classColor.b end
		end
		frame.StyleFilterChanges.HealthColor = {r = hr, g = hg, b = hb, a = ha}
		frame.Health:SetStatusBarColor(hr, hg, hb, ha)
		local cutawayHealth = (frame.Cutaway and frame.Cutaway.Health) or frame.CutawayHealth
		if cutawayHealth then
			cutawayHealth:SetStatusBarColor(hr * 1.5, hg * 1.5, hb * 1.5, ha)
		end
	end
	if BorderChanged then --Lets lock this to the values we want (needed for when the media border color changes)
		frame.StyleChanged = true
		frame.BorderChanged = true
		local bc = actions.color.borderColor
		local br, bg, bb, ba = StyleFilterGetColor(bc, { r = 1, g = 1, b = 1, a = 1 })
		if actions.color.borderClass then
			local classColor = frame.classFile and ((CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[frame.classFile]) or RAID_CLASS_COLORS[frame.classFile])
			if classColor then br, bg, bb = classColor.r, classColor.g, classColor.b end
		end
		mod:StyleFilterBorderLock(frame.Health.backdrop, br, bg, bb, ba)
	end
	if FlashingHealth then
		frame.StyleChanged = true
		frame.FlashingHealth = true
		if not TextureChanged then
			frame.FlashTexture:SetTexture(LSM:Fetch("statusbar", mod.db.statusbar))
		end
		frame.FlashTexture:SetVertexColor(actions.flash.color.r, actions.flash.color.g, actions.flash.color.b)
		frame.FlashTexture:SetAlpha(actions.flash.color.a)
		frame.FlashTexture:Show()
		E:Flash(frame.FlashTexture, actions.flash.speed * 0.1, true)
	end
	if TextureChanged then
		frame.StyleChanged = true
		frame.TextureChanged = true
		local tex = LSM:Fetch("statusbar", actions.texture.texture)
		if frame.Health.Highlight then frame.Health.Highlight:SetTexture(tex) end
		frame.Health:SetStatusBarTexture(tex)
		if FlashingHealth then
			frame.FlashTexture:SetTexture(tex)
		end
	end
	if ScaleChanged then
		frame.StyleChanged = true
		frame.ScaleChanged = true
		frame.StyleFilterChanges.Scale = actions.scale
		local scale = (frame.ThreatScale or 1)
		frame.ActionScale = actions.scale
		if frame.isTarget and mod.db.useTargetScale then
			scale = scale * mod.db.targetScale
		end
		mod:SetFrameScale(frame, scale * actions.scale)
	end
	if AlphaChanged then
		frame.StyleChanged = true
		frame.AlphaChanged = true
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, frame:GetAlpha(), actions.alpha / 100)
	end
	if NameColorChanged then
		frame.StyleChanged = true
		frame.NameColorChanged = true
		local nameText = frame.Name and frame.Name:GetText()
		if nameText and nameText ~= "" then
			local nc = actions.color.nameColor
			local nr, ng, nb, na = StyleFilterGetColor(nc, { r = 1, g = 1, b = 1, a = 1 })
			if actions.color.nameClass then
				local classColor = frame.classFile and ((CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[frame.classFile]) or RAID_CLASS_COLORS[frame.classFile])
				if classColor then nr, ng, nb = classColor.r, classColor.g, classColor.b end
			end
			frame.Name:SetTextColor(nr, ng, nb, na)
			if mod.db.nameColoredGlow then
				frame.Name.NameOnlyGlow:SetVertexColor(nr - 0.1, ng - 0.1, nb - 0.1, 1)
			end
		end
	end
	if NameTagChanged then
		frame.StyleChanged = true
		frame.NameTagChanged = true
		frame.StyleFilterChanges.NameTag = actions.text.nameTag
		StyleFilterSetTag(frame, frame.Name, actions.text.nameTag)
	end
	if LevelTagChanged then
		frame.StyleChanged = true
		frame.LevelTagChanged = true
		frame.StyleFilterChanges.LevelTag = actions.text.levelTag
		StyleFilterSetTag(frame, frame.Level, actions.text.levelTag)
	end
	if PowerTagChanged and frame.Power and frame.Power.Text then
		frame.StyleChanged = true
		frame.PowerTagChanged = true
		frame.StyleFilterChanges.PowerTag = actions.text.powerTag
		StyleFilterSetTag(frame, frame.Power.Text, actions.text.powerTag)
	end
	if NameOnlyChanged then
		frame.StyleChanged = true
		frame.NameOnlyChanged = true
		frame.StyleFilterChanges.NameOnly = true
		--hide the bars (Health stays Shown but visually transparent so children keep framelevel)
		if frame:IsElementEnabled('Castbar') then
			frame.StyleFilterChanges.CastbarByNameOnly = true
			frame:DisableElement('Castbar')
		end
		if frame.Castbar then
			frame.Castbar:Hide()
		end
		mod:Health_SetTransparent(frame, true)
		if frame:IsElementEnabled('Power') then
			frame.StyleFilterChanges.PowerByNameOnly = true
			frame:DisableElement('Power')
		end
		if frame.Power then
			frame.Power:Hide()
		end
		if frame.Cutaway and frame.Cutaway.Health then
			frame.Cutaway.Health:Hide()
		elseif frame.CutawayHealth then
			frame.CutawayHealth:Hide()
		end
		if frame.FlashTexture then
			E:StopFlash(frame.FlashTexture)
			frame.FlashTexture:Hide()
		end
		-- hide any target arrows/glow unless explicitly enabled by style-filter action
		StyleFilterHideTargetVisuals(frame)

		-- StyleFilter NameOnly should match regular NameOnly visuals: keep only name text.
		mod:Update_Tags(frame, true)
		-- Update_Tags() reapplies default name tag, so force custom style-filter tag again.
		if NameTagChanged then
			StyleFilterSetTag(frame, frame.Name, actions.text.nameTag)
		end
		mod:Update_PvPIndicator(frame)
		mod:Update_TargetIndicator(frame)
	end
	if ShowHealthChanged then
		frame.StyleChanged = true
		frame.ShowHealthChanged = true
		frame.StyleFilterChanges.ShowHealth = true
		local base = mod.db.units and mod.db.units[frame.UnitType]
		if base then
			frame.plateDBOverride = setmetatable({nameOnly = false}, {__index = base})
		end
		mod:UpdatePlate(frame, true)
	end
	if TargetIndicatorChanged then
		frame.StyleChanged = true
		frame.TargetIndicatorChanged = true
		if actions.showTargetIndicator then
			frame.StyleFilterChanges.ShowTargetIndicator = true
			frame.StyleFilterChanges.TargetIndicatorStyle = actions.targetIndicatorStyle or 'style4'
			frame.StyleFilterChanges.TargetIndicatorArrow = actions.targetIndicatorArrow or 'ArrowUp'
			frame.StyleFilterChanges.TargetIndicatorArrowSize = actions.targetIndicatorArrowSize or 20
			frame.StyleFilterChanges.TargetIndicatorArrowXOffset = actions.targetIndicatorArrowXOffset or 3
			frame.StyleFilterChanges.TargetIndicatorArrowYOffset = actions.targetIndicatorArrowYOffset or 0
		end
	end
	if MouseoverHighlightChanged then
		frame.StyleChanged = true
		frame.MouseoverHighlightChanged = true
		if frame.isMouseover then
			frame.StyleFilterChanges.ShowMouseoverHighlight = true
		else
			frame.StyleFilterChanges.ShowMouseoverHighlight = nil
		end
	end
end

function mod:StyleFilterClearChanges(frame, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged, ShowHealthChanged, NameTagChanged, LevelTagChanged, PowerTagChanged, TargetIndicatorChanged, MouseoverHighlightChanged)
	frame.StyleChanged = nil
	if VisibilityChanged then
		frame.VisibilityChanged = nil
		frame.StyleFilterChanges.Visibility = nil
		frame.StyleFilterChanges.Hidden = nil
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, 0, 1) -- fade those back in so it looks clean
		frame:Show()
	end
	if FrameLevelChanged then
		frame.FrameLevelChanged = nil
		frame.pendingFrameLevelReset = true -- deferred: applied at end of StyleFilterUpdate
	end
	if HealthColorChanged then
		frame.HealthColorChanged = nil
		frame.StyleFilterChanges.HealthColor = nil
		frame.Health:SetStatusBarColor(frame.Health.r, frame.Health.g, frame.Health.b)
		local cutawayHealth = (frame.Cutaway and frame.Cutaway.Health) or frame.CutawayHealth
		if cutawayHealth then
			cutawayHealth:SetStatusBarColor(frame.Health.r * 1.5, frame.Health.g * 1.5, frame.Health.b * 1.5, 1)
		end
	end
	if BorderChanged then
		frame.BorderChanged = nil
		mod:StyleFilterBorderLock(frame.Health.backdrop)
	end
	if FlashingHealth then
		frame.FlashingHealth = nil
		E:StopFlash(frame.FlashTexture)
		frame.FlashTexture:Hide()
	end
	if TextureChanged then
		frame.TextureChanged = nil
		local tex = LSM:Fetch("statusbar", mod.db.statusbar)
		if frame.Health.Highlight then frame.Health.Highlight:SetTexture(tex) end
		frame.Health:SetStatusBarTexture(tex)
	end
	if ScaleChanged then
		frame.ScaleChanged = nil
		frame.StyleFilterChanges.Scale = nil
		frame.ActionScale = nil
		local scale = frame.ThreatScale or 1
		if frame.isTarget and mod.db.useTargetScale then
			scale = scale * mod.db.targetScale
		end
		mod:SetFrameScale(frame, scale)
	end
	if AlphaChanged then
		frame.AlphaChanged = nil
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, (frame.FadeObject and frame.FadeObject.endAlpha) or 0.5, 1)
	end
	if NameColorChanged then
		frame.NameColorChanged = nil
		-- Names on this engine are driven by oUF tags (no Update_Name pre-pass),
		-- so frame.Name.r/g/b can be nil. Falling back to nil tints the text black.
		local nr, ng, nb = frame.Name.r or 1, frame.Name.g or 1, frame.Name.b or 1
		frame.Name:SetTextColor(nr, ng, nb)
	end
	if NameOnlyChanged then
		frame.NameOnlyChanged = nil
		local hadPowerByNameOnly = frame.StyleFilterChanges.PowerByNameOnly
		local hadCastbarByNameOnly = frame.StyleFilterChanges.CastbarByNameOnly
		frame.StyleFilterChanges.NameOnly = nil
		frame.StyleFilterChanges.PowerByNameOnly = nil
		frame.StyleFilterChanges.CastbarByNameOnly = nil
		frame.TopLevelFrame = nil --We can safely clear this here because it is set upon `UpdateElement_Auras` if needed
		if mod.db.units[frame.UnitType].health.enable or (frame.isTarget and mod.db.alwaysShowTargetHealth) then
			mod:Health_SetTransparent(frame, false)
			mod:Configure_Glow(frame)
			mod:Update_Glow(frame)
		end
		frame.Name:ClearAllPoints()
		frame.Level:ClearAllPoints()
		if mod.db.units[frame.UnitType].name.enable then
			mod:Update_Name(frame)
			local nr, ng, nb = frame.Name.r or 1, frame.Name.g or 1, frame.Name.b or 1
			frame.Name:SetTextColor(nr, ng, nb)
		else
			frame.Name:SetText()
		end
		if mod.db.units[frame.UnitType].level.enable then
			mod:Update_Level(frame)
		end
		mod:Update_Tags(frame)
		if hadPowerByNameOnly then
			mod:Update_Power(frame)
		end
		if hadCastbarByNameOnly then
			mod:Update_Castbar(frame)
		end
		mod:Update_PvPIndicator(frame)
		mod:Update_TargetIndicator(frame)
	end
	if ShowHealthChanged then
		frame.ShowHealthChanged = nil
		frame.StyleFilterChanges.ShowHealth = nil
		frame.plateDBOverride = nil
		mod:UpdatePlate(frame, true)
	end
	if TargetIndicatorChanged then
		frame.TargetIndicatorChanged = nil
		frame.StyleFilterChanges.ShowTargetIndicator = nil
		frame.StyleFilterChanges.TargetIndicatorStyle = nil
		frame.StyleFilterChanges.TargetIndicatorArrow = nil
		frame.StyleFilterChanges.TargetIndicatorArrowSize = nil
		frame.StyleFilterChanges.TargetIndicatorArrowXOffset = nil
		frame.StyleFilterChanges.TargetIndicatorArrowYOffset = nil
	end
	if MouseoverHighlightChanged then
		frame.MouseoverHighlightChanged = nil
		frame.StyleFilterChanges.ShowMouseoverHighlight = nil
	end
end

function mod:StyleFilterConditionCheck(frame, filter, trigger)
	local passed -- skip StyleFilterPass when triggers are empty

	-- Class (matches against the UNIT'S class on the nameplate, not the player's class).
	-- Non-player units (NPCs, pets without classFile) never pass this trigger.
	if trigger.class and next(trigger.class) then
		local unitClass = frame.classFile or frame.UnitClass
		if not (unitClass and trigger.class[unitClass]) then
			return
		else
			passed = true
		end
	end

	-- Health
	if trigger.healthThreshold then
		local healthUnit = (trigger.healthUsePlayer and 'player') or frame.unit
		local health = (healthUnit and UnitHealth(healthUnit)) or frame.Health:GetValue() or 0
		local maxHealth = (healthUnit and UnitHealthMax(healthUnit)) or select(2, frame.Health:GetMinMaxValues()) or 0
		local percHealth = (maxHealth and (maxHealth > 0) and health/maxHealth) or 0

		local underHealth = trigger.underHealthThreshold and (trigger.underHealthThreshold ~= 0)
		local overHealth = trigger.overHealthThreshold and (trigger.overHealthThreshold ~= 0)

		local underThreshold = underHealth and (trigger.underHealthThreshold > percHealth)
		local overThreshold = overHealth and (trigger.overHealthThreshold < percHealth)

		if underHealth and overHealth then
			if underThreshold and overThreshold then passed = true else return end
		elseif underThreshold or overThreshold then passed = true else return end
	end

	-- Power
	if trigger.powerThreshold then
		local powerUnit = (trigger.powerUsePlayer and 'player') or frame.unit
		local power = (powerUnit and UnitPower(powerUnit)) or 0
		local maxPower = (powerUnit and UnitPowerMax(powerUnit)) or 0
		local percPower = (maxPower and (maxPower > 0) and power/maxPower) or 0

		local underPower = trigger.underPowerThreshold and (trigger.underPowerThreshold ~= 0)
		local overPower = trigger.overPowerThreshold and (trigger.overPowerThreshold ~= 0)

		local underThreshold = underPower and (trigger.underPowerThreshold > percPower)
		local overThreshold = overPower and (trigger.overPowerThreshold < percPower)

		if underPower and overPower then
			if underThreshold and overThreshold then passed = true else return end
		elseif underThreshold or overThreshold then passed = true else return end
	end

	-- Level
	if trigger.level then
		local myLevel = E.mylevel
		local level = mod:UnitLevel(frame)
		level = level == "??" and -1 or tonumber(level)
		local curLevel = (trigger.curlevel and trigger.curlevel ~= 0 and (trigger.curlevel == level))
		local minLevel = (trigger.minlevel and trigger.minlevel ~= 0 and (trigger.minlevel <= level))
		local maxLevel = (trigger.maxlevel and trigger.maxlevel ~= 0 and (trigger.maxlevel >= level))
		local matchMyLevel = trigger.mylevel and (level == myLevel)
		if curLevel or minLevel or maxLevel or matchMyLevel then passed = true else return end
	end

	-- Quest Boss (Retail only)
	if E.Retail and trigger.questBoss then
		if UnitIsQuestBoss(frame.unit) then passed = true else return end
	end

	-- Resting State
	if trigger.isResting or trigger.notResting then
		local resting = IsResting()
		if (trigger.isResting and resting) or (trigger.notResting and not resting) then passed = true else return end
	end

	-- Target Existence
	if trigger.requireTarget or trigger.noTarget then
		local target = UnitExists('target')
		if (trigger.requireTarget and target) or (trigger.noTarget and not target) then passed = true else return end
	end

	-- Player Combat
	if trigger.inCombat or trigger.outOfCombat then
		local inCombat = UnitAffectingCombat('player')
		if (trigger.inCombat and inCombat) or (trigger.outOfCombat and not inCombat) then passed = true else return end
	end

	-- Unit Combat
	if trigger.inCombatUnit or trigger.outOfCombatUnit then
		local inCombat = frame.unit and UnitAffectingCombat(frame.unit)
		if (trigger.inCombatUnit and inCombat) or (trigger.outOfCombatUnit and not inCombat) then passed = true else return end
	end

	-- Player Target
	if trigger.isTarget or trigger.notTarget then
		if (trigger.isTarget and frame.isTarget) or (trigger.notTarget and not frame.isTarget) then passed = true else return end
	end

	-- Mouseover
	if trigger.isMouseover or trigger.notMouseover then
		if (trigger.isMouseover and frame.isMouseover) or (trigger.notMouseover and not frame.isMouseover) then passed = true else return end
	end

	-- Unit Target (3.3.5a/Retail)
	if trigger.targetMe or trigger.notTargetMe or trigger.targetPet or trigger.notTargetPet then
		local targetsMe = frame.isTargetingMe
		local targetsPet = frame.isTargetingPet
		if (trigger.targetMe and targetsMe)
		or (trigger.notTargetMe and not targetsMe)
		or (trigger.targetPet and targetsPet)
		or (trigger.notTargetPet and not targetsPet) then
			passed = true
		else
			return
		end
	end

	-- Unit Focus (Retail only)
	if E.Retail and (trigger.isFocus or trigger.notFocus) then
		if (trigger.isFocus and frame.isFocused) or (trigger.notFocus and not frame.isFocused) then passed = true else return end
	end

	-- Unit Pet (Retail only)
	if E.Retail and (trigger.isPet or trigger.isNotPet) then
		if (trigger.isPet and frame.isPet) or (trigger.isNotPet and not frame.isPet) then passed = true else return end
	end

	-- Player Vehicle (Wrath/Retail)
	if (E.Retail or E.Wrath) and (trigger.inVehicle or trigger.outOfVehicle) then
		local inVehicle = UnitInVehicle and UnitInVehicle('player')
		if (trigger.inVehicle and inVehicle) or (trigger.outOfVehicle and not inVehicle) then passed = true else return end
	end

	-- Unit Vehicle (Wrath/Retail)
	if (E.Retail or E.Wrath) and (trigger.inVehicleUnit or trigger.outOfVehicleUnit) then
		if (trigger.inVehicleUnit and frame.inVehicle) or (trigger.outOfVehicleUnit and not frame.inVehicle) then passed = true else return end
	end

	-- Group Role
	if trigger.role and (trigger.role.tank or trigger.role.healer or trigger.role.damager) then
		if trigger.role[mod.TriggerConditions.roles[E:GetPlayerRole()]] then passed = true else return end
	end

	-- Instance Type
	if trigger.instanceType and (trigger.instanceType.none or trigger.instanceType.party or trigger.instanceType.raid or trigger.instanceType.arena or trigger.instanceType.pvp) then
		local _, instanceType, difficultyID = GetInstanceInfo()
		if trigger.instanceType[instanceType] then
			passed = true

			-- Instance Difficulty
			if instanceType == "raid" or instanceType == "party" then
				local D = trigger.instanceDifficulty[(instanceType == "party" and "dungeon") or instanceType]
				local difficultyMap = mod.TriggerConditions.difficulties[instanceType]
				local currentDifficulty = difficultyMap and difficultyMap[difficultyID]
				for _, value in pairs(D) do
					if value and not D[currentDifficulty] then return end
				end
			end
		else return end
	elseif trigger.instanceType and trigger.instanceType.sanctuary then
		if UnitIsPVPSanctuary("player") then passed = true else return end
	end

	-- Unit Type
	if trigger.nameplateType and trigger.nameplateType.enable then
		if trigger.nameplateType[mod.TriggerConditions.frameTypes[frame.UnitType]] then passed = true else return end
	end

	-- Reaction Type
	if trigger.reactionType and trigger.reactionType.enable then
		local reaction = frame.UnitReaction
		if ((reaction == 1 or reaction == 2 or reaction == 3) and trigger.reactionType.hostile) or (reaction == 4 and trigger.reactionType.neutral) or (reaction >= 5 and trigger.reactionType.friendly) then passed = true else return end
	end

	-- Unit Faction (Alliance / Horde / Neutral / Renegade)
	-- frame.faction = UnitFactionGroup(unit): "Alliance", "Horde", "" (no faction)
	if trigger.faction and (trigger.faction.Alliance or trigger.faction.Horde or trigger.faction.Neutral or trigger.faction.Renegade) then
		local fac = frame.faction or (frame.unit and UnitFactionGroup(frame.unit)) or ""
		local ok
		if fac == "Alliance" and trigger.faction.Alliance then ok = true
		elseif fac == "Horde" and trigger.faction.Horde then ok = true
		elseif (fac == "Neutral" or fac == "") and trigger.faction.Neutral then ok = true
		elseif fac == "Renegade" and trigger.faction.Renegade then ok = true
		end
		if ok then passed = true else return end
	end

	-- Raid Target
	if trigger.raidTarget and (trigger.raidTarget.star or trigger.raidTarget.circle or trigger.raidTarget.diamond or trigger.raidTarget.triangle or trigger.raidTarget.moon or trigger.raidTarget.square or trigger.raidTarget.cross or trigger.raidTarget.skull) then
		-- frame.RaidTargetIndex is refreshed by RAID_TARGET_UPDATE / StyleFilterEventFunctions; fall back to a live lookup just in case.
		local idx = frame.RaidTargetIndex or (frame.unit and GetRaidTargetIndex(frame.unit))
		local markName = idx and mod.TriggerConditions.raidTargets[idx]
		if markName and trigger.raidTarget[markName] then passed = true else return end
	end

	-- Casting
	if trigger.casting and (trigger.casting.isCasting or trigger.casting.isChanneling or trigger.casting.notCasting or trigger.casting.notChanneling or trigger.casting.interruptible or trigger.casting.notInterruptible or (trigger.casting.spells and next(trigger.casting.spells))) then
		local b, c = frame.Castbar, trigger.casting
		if not b then return end -- castbar not yet constructed

		-- Spell
		if b.spellName then
			if c.spells and next(c.spells) then
				for _, value in pairs(c.spells) do
					if value then -- only run if at least one is selected
						local _, _, _, _, _, _, spellID = GetSpellInfo(b.spellName)
						local castingSpell = (spellID and c.spells[tostring(spellID)]) or c.spells[b.spellName]
						if (c.notSpell and not castingSpell) or (castingSpell and not c.notSpell) then passed = true else return end
						break -- we can execute this once on the first enabled option then kill the loop
					end
				end
			end
		end

		-- Status
		if c.isCasting or c.isChanneling or c.notCasting or c.notChanneling then
			if (c.isCasting and b.casting) or (c.isChanneling and b.channeling)
			or (c.notCasting and not b.casting) or (c.notChanneling and not b.channeling) then passed = true else return end
		end

		-- Interruptible
		if c.interruptible or c.notInterruptible then
			if (b.casting or b.channeling) and ((c.interruptible and not b.notInterruptible)
			or (c.notInterruptible and b.notInterruptible)) then passed = true else return end
		end
	end

	-- Cooldown
	if trigger.cooldowns and trigger.cooldowns.names and next(trigger.cooldowns.names) then
		local cooldown = mod:StyleFilterCooldownCheck(trigger.cooldowns.names, trigger.cooldowns.mustHaveAll)
		if cooldown ~= nil then -- ignore if none are set to ONCD or OFFCD
			if cooldown then passed = true else return end
		end
	end

	-- Buffs
	if trigger.buffs and trigger.buffs.names and next(trigger.buffs.names) then
		local buffsEl = frame.Buffs_ or frame.Buffs
		local buffTickers = (buffsEl and buffsEl.tickers) or {}
		local buff = mod:StyleFilterAuraCheck(frame, trigger.buffs.names, buffTickers, 'HELPFUL', trigger.buffs.mustHaveAll, trigger.buffs.missing, trigger.buffs.minTimeLeft, trigger.buffs.maxTimeLeft, trigger.buffs.fromMe, trigger.buffs.fromPet, trigger.buffs.onMe, trigger.buffs.onPet)
		if buff ~= nil then -- ignore if none are selected
			if buff then passed = true else return end
		end
	end

	-- Debuffs
	if trigger.debuffs and trigger.debuffs.names and next(trigger.debuffs.names) then
		local debuffsEl = frame.Debuffs_ or frame.Debuffs
		local debuffTickers = (debuffsEl and debuffsEl.tickers) or {}
		local debuff = mod:StyleFilterAuraCheck(frame, trigger.debuffs.names, debuffTickers, 'HARMFUL', trigger.debuffs.mustHaveAll, trigger.debuffs.missing, trigger.debuffs.minTimeLeft, trigger.debuffs.maxTimeLeft, trigger.debuffs.fromMe, trigger.debuffs.fromPet, trigger.debuffs.onMe, trigger.debuffs.onPet)
		if debuff ~= nil then -- ignore if none are selected
			if debuff then passed = true else return end
		end
	end

	-- Name (or NPC ID)
	if trigger.names and next(trigger.names) then
		for _, value in pairs(trigger.names) do
			if value then -- only run if at least one is selected
				local npcID = frame.npcID
				local name = trigger.names[frame.UnitName]
					or (npcID and (trigger.names[npcID] or trigger.names[tonumber(npcID)] or trigger.names[tostring(npcID)]))
				if (not trigger.negativeMatch and name) or (trigger.negativeMatch and not name) then passed = true else return end
				break -- we can execute this once on the first enabled option then kill the loop
			end
		end
	end

	-- Plugin Callback
	if mod.StyleFilterCustomChecks then
		for _, customCheck in pairs(mod.StyleFilterCustomChecks) do
			local custom = customCheck(frame, filter, trigger)
			if custom ~= nil then -- ignore if nil return
				if custom then passed = true else return end
			end
		end
	end

	-- Pass it along
	if passed then
		mod:StyleFilterPass(frame, filter.actions)
	end
end

function mod:StyleFilterPass(frame, actions)
	local healthBarEnabled = (frame.UnitType and mod.db.units[frame.UnitType].health.enable) or (frame.isTarget and mod.db.alwaysShowTargetHealth)
	-- When showHealth is active the health bar will be shown by ShowHealthChanged even if currently hidden
	local healthBarShown = healthBarEnabled and (mod:Health_IsVisible(frame) or actions.showHealth)
	local textActions = actions.text

	mod:StyleFilterSetChanges(frame, actions,
		(healthBarShown and actions.color and actions.color.health), --HealthColorChanged
		(healthBarShown and actions.color and actions.color.border and frame.Health.backdrop), --BorderChanged
		(healthBarShown and actions.flash and actions.flash.enable and frame.FlashTexture), --FlashingHealth
		(healthBarShown and actions.texture and actions.texture.enable), --TextureChanged
		(healthBarShown and actions.scale and actions.scale ~= 1), --ScaleChanged
		(actions.frameLevel and actions.frameLevel ~= 0), --FrameLevelChanged
		(actions.alpha and actions.alpha ~= -1), --AlphaChanged
		(actions.color and actions.color.name), --NameColorChanged
		(actions.nameOnly and not actions.showHealth), --NameOnlyChanged
		(actions.hide), --VisibilityChanged
		(actions.showHealth), --ShowHealthChanged
		(textActions and textActions.enableName and textActions.nameTag and textActions.nameTag ~= ''), --NameTagChanged
		(textActions and textActions.enableLevel and textActions.levelTag and textActions.levelTag ~= ''), --LevelTagChanged
		(textActions and textActions.enablePower and textActions.powerTag and textActions.powerTag ~= ''), --PowerTagChanged
		(actions.showTargetIndicator), --TargetIndicatorChanged
		(actions.showMouseoverHighlight) --MouseoverHighlightChanged
	)
end

function mod:StyleFilterClear(frame)
	if frame and frame.StyleChanged then
		mod:StyleFilterClearChanges(frame, frame.HealthColorChanged, frame.BorderChanged, frame.FlashingHealth, frame.TextureChanged, frame.ScaleChanged, frame.FrameLevelChanged, frame.AlphaChanged, frame.NameColorChanged, frame.NameOnlyChanged, frame.VisibilityChanged, frame.ShowHealthChanged, frame.NameTagChanged, frame.LevelTagChanged, frame.PowerTagChanged, frame.TargetIndicatorChanged, frame.MouseoverHighlightChanged)
	end
end

function mod:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] --Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

function mod:StyleFilterVehicleFunction(_, unit)
	unit = unit or self.unit
	self.inVehicle = (E.Retail or E.Wrath) and UnitInVehicle and UnitInVehicle(unit) or nil
end

function mod:StyleFilterTargetFunction(_, unit)
	unit = unit or self.unit
	self.isTargetingMe = unit and UnitIsUnit(unit..'target', 'player') or nil
	self.isTargetingPet = unit and UnitIsUnit(unit..'target', 'pet') or nil
end

mod.StyleFilterEventFunctions = { -- a prefunction to the injected oUF watch
	PLAYER_TARGET_CHANGED = function(self)
		self.isTarget = self.unit and UnitIsUnit(self.unit, 'target') or nil
	end,
	PLAYER_FOCUS_CHANGED = function(self)
		self.isFocused = self.unit and UnitIsUnit(self.unit, 'focus') or nil
	end,
	RAID_TARGET_UPDATE = function(self)
		self.RaidTargetIndex = self.unit and GetRaidTargetIndex(self.unit) or nil
	end,
	UNIT_TARGET = mod.StyleFilterTargetFunction,
	UNIT_THREAT_LIST_UPDATE = mod.StyleFilterTargetFunction,
	UNIT_ENTERED_VEHICLE = mod.StyleFilterVehicleFunction,
	UNIT_EXITED_VEHICLE = mod.StyleFilterVehicleFunction,
	VEHICLE_UPDATE = mod.StyleFilterVehicleFunction
}

mod.StyleFilterSetVariablesIgnored = {
	UNIT_THREAT_LIST_UPDATE = true,
	UNIT_ENTERED_VEHICLE = true,
	UNIT_EXITED_VEHICLE = true
}

function mod:StyleFilterSetVariables(nameplate)
	if nameplate == _G.ElvNP_Test then return end

	for event, func in pairs(mod.StyleFilterEventFunctions) do
		if not mod.StyleFilterSetVariablesIgnored[event] then
			func(nameplate)
		end
	end
end

function mod:StyleFilterClearVariables(nameplate)
	if nameplate == _G.ElvNP_Test then return end

	nameplate.isTarget = nil
	nameplate.isMouseover = nil
	nameplate.isFocused = nil
	nameplate.inVehicle = nil
	nameplate.isTargetingMe = nil
	nameplate.isTargetingPet = nil
	nameplate.RaidTargetIndex = nil
	nameplate.ActionScale = nil
	nameplate.ThreatScale = nil
end

mod.StyleFilterTriggerList = {} -- configured filters enabled with sorted priority
mod.StyleFilterTriggerEvents = {} -- events required by the filter that we need to watch for
mod.StyleFilterPlateEvents = {} -- events watched inside of oUF, called on the nameplate itself, updated by StyleFilterWatchEvents
mod.StyleFilterDefaultEvents = { -- list of events style filter uses (true if unitless). Sirus 3.3.5a-compatible only.
	-- existing oUF/UF events:
	UNIT_AURA = false,
	UNIT_DISPLAYPOWER = false,
	UNIT_MAXHEALTH = false,
	UNIT_NAME_UPDATE = false,
	UNIT_PET = false,
	UNIT_HEALTH = false,
	-- WotLK power events (no UNIT_POWER_UPDATE on 3.3.5a):
	UNIT_MANA = false,
	UNIT_RAGE = false,
	UNIT_ENERGY = false,
	UNIT_FOCUS = false,
	UNIT_RUNIC_POWER = false,
	-- mod events:
	GROUP_ROSTER_UPDATE = true,
	MODIFIER_STATE_CHANGED = true,
	PLAYER_EQUIPMENT_CHANGED = true,
	PLAYER_FLAGS_CHANGED = false,
	PLAYER_FOCUS_CHANGED = true,
	PLAYER_REGEN_DISABLED = true,
	PLAYER_REGEN_ENABLED = true,
	PLAYER_TARGET_CHANGED = true,
	UPDATE_MOUSEOVER_UNIT = true,
	PLAYER_UPDATE_RESTING = true,
	QUEST_LOG_UPDATE = true,
	RAID_TARGET_UPDATE = true,
	SPELL_UPDATE_COOLDOWN = true,
	UNIT_ENTERED_VEHICLE = false,
	UNIT_EXITED_VEHICLE = false,
	UNIT_FLAGS = false,
	UNIT_TARGET = false,
	UNIT_THREAT_LIST_UPDATE = false,
	UNIT_THREAT_SITUATION_UPDATE = false,
	VEHICLE_UPDATE = true,
	ZONE_CHANGED = true,
	ZONE_CHANGED_INDOORS = true,
	ZONE_CHANGED_NEW_AREA = true
}

mod.StyleFilterCastEvents = {
	UNIT_SPELLCAST_START = 1,
	UNIT_SPELLCAST_CHANNEL_START = 1,
	UNIT_SPELLCAST_STOP = 1,
	UNIT_SPELLCAST_CHANNEL_STOP = 1,
	UNIT_SPELLCAST_FAILED = 1,
	UNIT_SPELLCAST_INTERRUPTED = 1,
	UNIT_SPELLCAST_DELAYED = 1,
	UNIT_SPELLCAST_CHANNEL_UPDATE = 1
}
for event in pairs(mod.StyleFilterCastEvents) do
	mod.StyleFilterDefaultEvents[event] = false
end

function mod:StyleFilterWatchEvents()
	for event in pairs(mod.StyleFilterDefaultEvents) do
		mod.StyleFilterPlateEvents[event] = mod.StyleFilterTriggerEvents[event] and true or nil
	end
end

function mod:StyleFilterConfigure()
	local events = mod.StyleFilterTriggerEvents
	local list = mod.StyleFilterTriggerList
	wipe(events)
	wipe(list)

	if mod.db and mod.db.filters then
		for filterName, filter in pairs(E.global.nameplates.filters) do
			local t = filter.triggers
			-- "enable" lives on the GLOBAL filter (UI writes it via GetFilter -> E.global).
			-- Per-profile mod.db.filters[name] is treated as an OPTIONAL disable-override only:
			-- if the profile entry explicitly sets triggers.enable = false, the filter is skipped
			-- for that profile; a missing entry just means "use global state".
			local profileEntry = mod.db.filters[filterName]
			local profileTriggers = profileEntry and profileEntry.triggers
			local profileDisabled = profileTriggers and profileTriggers.enable == false

			if t and t.enable and not profileDisabled then
				tinsert(list, {filterName, t.priority or 1})

				-- NOTE: -1 internal, 0 fake, 1 real
				events.FAKE_AuraWaitTimer = 0 -- aura minTimeLeft / maxTimeLeft
				events.PLAYER_TARGET_CHANGED = 1
				events.NAME_PLATE_UNIT_ADDED = 1
				events.UNIT_FACTION = 1 -- frameType can change here
				events.ForceUpdate = -1
				events.PoolerUpdate = -1
				events.UpdateElement_All = -1

				if t.casting then
					local spell
					if next(t.casting.spells) then
						for _, value in pairs(t.casting.spells) do
							if value then spell = true; break end
						end
					end

					if spell or (t.casting.interruptible or t.casting.notInterruptible or t.casting.isCasting or t.casting.isChanneling or t.casting.notCasting or t.casting.notChanneling) then
						for event in pairs(mod.StyleFilterCastEvents) do
							events[event] = 1
						end
					end
				end

				if t.isFocus or t.notFocus then			events.PLAYER_FOCUS_CHANGED = 1 end
				if t.isResting or t.notResting then		events.PLAYER_UPDATE_RESTING = 1 end
				if t.isPet or t.isNotPet then			events.UNIT_PET = 1 end
				if t.isMouseover or t.notMouseover then	events.UPDATE_MOUSEOVER_UNIT = 1 end

				if t.targetMe or t.notTargetMe or t.targetPet or t.notTargetPet then
					events.UNIT_THREAT_LIST_UPDATE = 1
					events.UNIT_TARGET = 1
				end

				if t.raidTarget and (t.raidTarget.star or t.raidTarget.circle or t.raidTarget.diamond or t.raidTarget.triangle or t.raidTarget.moon or t.raidTarget.square or t.raidTarget.cross or t.raidTarget.skull) then
					events.RAID_TARGET_UPDATE = 1
				end

				if t.inVehicleUnit or t.outOfVehicleUnit then
					events.UNIT_ENTERED_VEHICLE = 1
					events.UNIT_EXITED_VEHICLE = 1
					events.VEHICLE_UPDATE = 1
				end

				if t.healthThreshold then
					events.UNIT_MAXHEALTH = 1
					events.UNIT_HEALTH = 1
				end

				if t.powerThreshold then
					events.UNIT_MANA = 1
					events.UNIT_RAGE = 1
					events.UNIT_ENERGY = 1
					events.UNIT_FOCUS = 1
					events.UNIT_RUNIC_POWER = 1
					events.UNIT_DISPLAYPOWER = 1
				end

				if t.threat and t.threat.enable then
					events.UNIT_THREAT_SITUATION_UPDATE = 1
					events.UNIT_THREAT_LIST_UPDATE = 1
				end

				if t.inCombat or t.outOfCombat or t.inCombatUnit or t.outOfCombatUnit then
					events.PLAYER_REGEN_DISABLED = 1
					events.PLAYER_REGEN_ENABLED = 1
					events.UNIT_THREAT_LIST_UPDATE = 1
					events.UNIT_FLAGS = 1
				end

				if t.role and (t.role.tank or t.role.healer or t.role.damager) then
					events.GROUP_ROSTER_UPDATE = 1
				end

				if not events.UNIT_NAME_UPDATE and t.names and next(t.names) then
					for _, value in pairs(t.names) do
						if value then events.UNIT_NAME_UPDATE = 1; break end
					end
				end

				if not events.SPELL_UPDATE_COOLDOWN and t.cooldowns and t.cooldowns.names and next(t.cooldowns.names) then
					for _, value in pairs(t.cooldowns.names) do
						if value == 'ONCD' or value == 'OFFCD' then events.SPELL_UPDATE_COOLDOWN = 1; break end
					end
				end

				if not events.UNIT_AURA and t.buffs and t.buffs.names and next(t.buffs.names) then
					for _, value in pairs(t.buffs.names) do
						if value then events.UNIT_AURA = 1; break end
					end
				end

				if not events.UNIT_AURA and t.debuffs and t.debuffs.names and next(t.debuffs.names) then
					for _, value in pairs(t.debuffs.names) do
						if value then events.UNIT_AURA = 1; break end
					end
				end
			end
		end
	end

	mod.watchMouseover = events.UPDATE_MOUSEOVER_UNIT and true or nil

	mod:StyleFilterWatchEvents()

	if next(list) then
		sort(list, mod.StyleFilterSort) -- sort by priority
	elseif mod.ForEachPlate then
		mod:ForEachPlate('StyleFilterClear')
	end

	-- refresh per-plate event watches whenever filters change
	if mod.Plates then
		for nameplate in pairs(mod.Plates) do
			mod:StyleFilterEventWatch(nameplate)
		end
	end
end

function mod:StyleFilterUpdate(frame, event)
	if frame == _G.ElvNP_Test or not frame.StyleFilterChanges or not mod.StyleFilterTriggerEvents[event] then return end

	-- If no filters are active and this frame has no pending style, nothing to do
	if not frame.StyleChanged and not frame.pendingFrameLevelReset and not next(mod.StyleFilterTriggerList) then return end

	local hadNameTag = frame.NameTagChanged
	local hadLevelTag = frame.LevelTagChanged
	local hadPowerTag = frame.PowerTagChanged
	local state = mod:StyleFilterHiddenState(frame.StyleFilterChanges)
	frame.StyleFilterChanges.NameTag = nil
	frame.StyleFilterChanges.LevelTag = nil
	frame.StyleFilterChanges.PowerTag = nil
	frame.StyleFilterChanges.ShowTargetIndicator = nil
	frame.StyleFilterChanges.TargetIndicatorStyle = nil
	frame.StyleFilterChanges.TargetIndicatorArrow = nil
	frame.StyleFilterChanges.TargetIndicatorArrowSize = nil
	frame.StyleFilterChanges.TargetIndicatorArrowXOffset = nil
	frame.StyleFilterChanges.TargetIndicatorArrowYOffset = nil
	frame.StyleFilterChanges.ShowMouseoverHighlight = nil

	-- Skip visual revert for indicators; they are re-evaluated in this same update.
	frame.TargetIndicatorChanged = nil
	frame.MouseoverHighlightChanged = nil

	mod:StyleFilterClear(frame)

	for filterNum in ipairs(mod.StyleFilterTriggerList) do
		local filter = E.global.nameplates.filters[mod.StyleFilterTriggerList[filterNum][1]]
		if filter and filter.triggers then
			mod:StyleFilterConditionCheck(frame, filter, filter.triggers)
		end
	end

	-- ShowHealth overrides NameOnly when a lower-priority filter (e.g. raid marker) runs after NonTarget.
	if frame.StyleFilterChanges.NameOnly and not frame.StyleFilterChanges.ShowHealth then
		mod:Health_SetTransparent(frame, true)
	end

	-- Restore default tags only when an override is no longer active.
	if hadNameTag and not frame.StyleFilterChanges.NameTag then
		frame.NameTagChanged = nil
		StyleFilterSetTag(frame, frame.Name, mod:StyleFilterDefaultTag(frame, 'name'))
	end
	if hadLevelTag and not frame.StyleFilterChanges.LevelTag then
		frame.LevelTagChanged = nil
		StyleFilterSetTag(frame, frame.Level, mod:StyleFilterDefaultTag(frame, 'level'))
	end
	if hadPowerTag and not frame.StyleFilterChanges.PowerTag and frame.Power and frame.Power.Text then
		frame.PowerTagChanged = nil
		StyleFilterSetTag(frame, frame.Power.Text, mod:StyleFilterDefaultTag(frame, 'power'))
	end

	-- Apply deferred frame level reset only if no filter re-claimed the boost this update
	if frame.pendingFrameLevelReset then
		frame.pendingFrameLevelReset = nil
		frame.appliedFrameLevelBoost = nil
		local base = frame._npBase or frame:GetFrameLevel()
		frame.Health:SetFrameLevel(base + 1)
		mod:Health_SyncBorderLevel(frame.Health) -- keep border glued above the bar
		if frame.Castbar then frame.Castbar:SetFrameLevel(base + 2) end
		if frame.Auras then
			if frame.Auras.Buffs  then frame.Auras.Buffs:SetFrameLevel(base + 2)  end
			if frame.Auras.Debuffs then frame.Auras.Debuffs:SetFrameLevel(base + 2) end
		end
	end

	mod:Update_TargetIndicator(frame)
	mod:Update_Highlight(frame)

	mod:StyleFilterClearVisibility(frame, state)
end

do -- oUF style filter inject watch functions without actually registering any extra C events
	local pooler = CreateFrame('Frame')
	pooler.frames = {}
	pooler.delay = 0.2 -- update check rate (was 0.1; increased to reduce per-frame cost)
	local immediateEvents = {
		PLAYER_TARGET_CHANGED = true,
		UPDATE_MOUSEOVER_UNIT = true,
		PLAYER_FOCUS_CHANGED = true,
		RAID_TARGET_UPDATE = true,
		NAME_PLATE_UNIT_ADDED = true,
	}

	pooler.update = function()
		for frame in pairs(pooler.frames) do
			mod:StyleFilterUpdate(frame, 'PoolerUpdate')
		end

		wipe(pooler.frames)
	end

	pooler.onUpdate = function(self, elapsed)
		if self.elapsed and self.elapsed > pooler.delay then
			pooler.update()
			self.elapsed = 0
		else
			self.elapsed = (self.elapsed or 0) + elapsed
		end
	end

	pooler:SetScript('OnUpdate', pooler.onUpdate)

	local update = function(frame, event, arg1, arg2, arg3, ...)
		local eventFunc = mod.StyleFilterEventFunctions[event]
		if eventFunc then
			eventFunc(frame, event, arg1, arg2, arg3, ...)
		end

		-- Trigger Event and (unitless OR verifiedUnit)
		if mod.StyleFilterTriggerEvents[event] and (mod.StyleFilterDefaultEvents[event] or (arg1 and arg1 == frame.unit)) then
			if immediateEvents[event] then
				mod:StyleFilterUpdate(frame, event)
			else
				pooler.frames[frame] = true
			end
		end
	end

	function mod:StyleFilterHandleUnitEvent(frame, event, unit, ...)
		if frame == _G.ElvNP_Test or not unit or not frame.unit or not UnitIsUnit(unit, frame.unit) then return end
		update(frame, event, unit, ...)
	end

	local oUF_event_metatable = {
		__call = function(funcs, frame, ...)
			for _, func in next, funcs do
				func(frame, ...)
			end
		end,
	}

	local oUF_fake_register = function(frame, event, remove)
		local curev = frame[event]
		if curev then
			local kind = type(curev)
			if kind == 'function' and curev ~= update then
				frame[event] = setmetatable({curev, update}, oUF_event_metatable)
			elseif kind == 'table' then
				for index, infunc in next, curev do
					if infunc == update then
						if remove then
							tremove(curev, index)
						end
						return
					end
				end

				tinsert(curev, update)
			end
		else
			frame[event] = (not remove and update) or nil
		end
	end

	local styleFilterIsWatching = function(frame, event)
		local curev = frame[event]
		if curev then
			local kind = type(curev)
			if kind == 'function' and curev == update then
				return true
			elseif kind == 'table' then
				for _, infunc in next, curev do
					if infunc == update then
						return true
					end
				end
			end
		end
	end

	function mod:StyleFilterEventWatch(frame, disable)
		if frame == _G.ElvNP_Test then return end

		for event, unitless in pairs(mod.StyleFilterDefaultEvents) do
			if unitless then
				local holdsEvent = styleFilterIsWatching(frame, event)
				if disable then
					if holdsEvent then
						oUF_fake_register(frame, event, true)
					end
				elseif mod.StyleFilterPlateEvents[event] then
					if not holdsEvent then
						oUF_fake_register(frame, event)
					end
				elseif holdsEvent then
					oUF_fake_register(frame, event, true)
				end
			end
		end

		if not disable and frame.unit then
			mod:RegisterAuraUnitEvents(frame, frame.unit)
		end
	end

	function mod:StyleFilterRegister(nameplate, event, unitless)
		if not unitless or nameplate:IsEventRegistered(event) then return end
		-- Sirus oUF RegisterEvent(event, func); unit events use RegisterUnitEvent via RegisterAuraUnitEvents
		nameplate:RegisterEvent(event, E.noop)
	end
end

-- events we actually register on plates when they are added
function mod:StyleFilterEvents(nameplate)
	if nameplate == _G.ElvNP_Test then return end

	-- per-plate change tracker
	nameplate.StyleFilterChanges = nameplate.StyleFilterChanges or {}

	for event, unitless in pairs(mod.StyleFilterDefaultEvents) do
		if unitless then
			mod:StyleFilterRegister(nameplate, event, unitless)
		end
	end
end

function mod:StyleFilterAddCustomCheck(name, func)
	if not mod.StyleFilterCustomChecks then
		mod.StyleFilterCustomChecks = {}
	end

	mod.StyleFilterCustomChecks[name] = func
end

function mod:StyleFilterRemoveCustomCheck(name)
	if not mod.StyleFilterCustomChecks then
		return
	end

	mod.StyleFilterCustomChecks[name] = nil
end

-- Shamelessy taken from AceDB-3.0 and stripped down by Simpy
local function copyDefaults(dest, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if dest[k] == nil then dest[k] = {} end
			if type(dest[k]) == "table" then copyDefaults(dest[k], v) end
		elseif dest[k] == nil then
			dest[k] = v
		end
	end
end

local function removeDefaults(db, defaults)
	setmetatable(db, nil)

	for k, v in pairs(defaults) do
		if type(v) == "table" and type(db[k]) == "table" then
			removeDefaults(db[k], v)
			if next(db[k]) == nil then db[k] = nil end
		elseif db[k] == defaults[k] then
			db[k] = nil
		end
	end
end

function mod:StyleFilterClearDefaults()
	for filterName, filterTable in pairs(E.global.nameplates.filters) do
		if G.nameplates.filters[filterName] then
			local defaultTable = E:CopyTable({}, E.StyleFilterDefaults)
			E:CopyTable(defaultTable, G.nameplates.filters[filterName])
			removeDefaults(filterTable, defaultTable)
		else
			removeDefaults(filterTable, E.StyleFilterDefaults)
		end
	end
end

function mod:StyleFilterCopyDefaults(tbl)
	copyDefaults(tbl, E.StyleFilterDefaults)
end

function mod:StyleFilterInitialize()
	for _, filterTable in pairs(E.global.nameplates.filters) do
		mod:StyleFilterCopyDefaults(filterTable)
	end
end

-- Russian totem-name fixup removed in 4g (Sirus-only totem tracking dropped).
