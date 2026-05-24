local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("NamePlates")
local LSM = E.Libs.LSM
local LibDispel = E.Libs.Dispel
local BleedList = LibDispel and LibDispel.BleedList or {}

--Lua functions
local ipairs, next, pairs, rawget, rawset, select, setmetatable, tonumber, type, unpack, tostring = ipairs, next, pairs, rawget, rawset, select, setmetatable, tonumber, type, unpack, tostring
local tinsert, tremove, sort, twipe, wipe = table.insert, table.remove, table.sort, table.wipe, (wipe or table.wipe)
local match, strmatch = string.match, string.match
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
local UnitThreatSituation = UnitThreatSituation

mod.StyleFilterStackPattern = '([^\n:]+):?(%d*)$'

-- Sirus 3.3.5a: native C_Timer with colon syntax. Returned object supports :Cancel().
local function C_Timer_NewTimer(delay, cb)
	return C_Timer:NewTimer(delay, cb)
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
		-- dungeons
		[1] = "normal",
		[2] = "heroic",
		-- raids
		[14] = "normal",
		[15] = "heroic",
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

function mod:StyleFilterDispelCheck(frame, filter)
	-- 3.3.5a UnitAura returns: name, rank, icon, count, dispelType, duration, expirationTime, source, isStealable, shouldConsolidate, spellID
	local index = 1
	local name, _, _, _, auraType, _, _, _, isStealable, _, spellID = UnitAura(frame.unit, index, filter)
	while name do
		if filter == 'HELPFUL' then
			if isStealable then
				return true
			end
		elseif auraType and E:IsDispellableByMe(auraType) then
			return true
		elseif not auraType and BleedList[spellID] and E:IsDispellableByMe('Bleed') then
			return true
		end

		index = index + 1
		name, _, _, _, auraType, _, _, _, isStealable, _, spellID = UnitAura(frame.unit, index, filter)
	end
end

function mod:StyleFilterAuraData(frame, filter, unit)
	local temp = {}

	if unit then
		-- 3.3.5a positions: 1 name, 4 count, 7 expirationTime, 8 source, 11 spellID
		local index = 1
		local name, _, _, count, _, _, expiration, source, _, _, spellID = UnitAura(unit, index, filter)
		while name do
			local info = temp[name] or temp[spellID]
			if not info then info = {} end

			temp[name] = info
			temp[spellID] = info

			info[index] = { count = count, expiration = expiration, source = source, modRate = 1 }

			index = index + 1
			name, _, _, count, _, _, expiration, source, _, _, spellID = UnitAura(unit, index, filter)
		end
	end

	return temp
end

function mod:StyleFilterAuraCheck(frame, names, tickers, filter, mustHaveAll, missing, minTimeLeft, maxTimeLeft, fromMe, fromPet, onMe, onPet)
	-- Backwards-compat: if `tickers` is actually the old icons array (has integer indices but no .hasMinTimer/etc fields)
	-- callers were passing frame.Buffs / frame.Debuffs. Detect by checking if it looks like an oUF aura header (has .createdIcons or such),
	-- and in that case treat it as the per-frame ticker bucket on the element.
	if tickers and type(tickers) == 'table' and tickers.tickers then
		tickers = tickers.tickers
	elseif type(tickers) ~= 'table' then
		tickers = {}
	end

	-- Default filter to HARMFUL if not provided (matches old behavior context: debuffs)
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
		wipe(temp)
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

-- ============================================================================
-- Retail-style helper shims (substage 4a). They are used by the upcoming
-- retail-style Set/ClearChanges (substage 4f). For now they are SAFE to call:
-- - StyleFilterChanges() lives in Nameplates.lua and returns the per-frame table.
-- - StyleFilterHiddenState() returns 1/2/3 depending on Visibility/NameOnly flags.
-- - StyleFilterBorderLock() locks/unlocks a backdrop's border colour. Will be
--   used once Health/Power are migrated to the backdrop+bordercolor model in 4c/4d.
-- - StyleFilterFinishedFlash + SetupFlash build a proper anim-group flasher.
-- - StyleFilterClearVisibility / BaseUpdate / ThreatUpdate restore plates after
--   a NameOnly/Visibility filter releases.
-- ============================================================================

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

function mod:StyleFilterFinishedFlash(requested)
	if not requested then self:Play() end
end

function mod:StyleFilterSetupFlash(FlashTexture)
	local anim = FlashTexture:CreateAnimationGroup('Flash')
	anim:SetScript('OnFinished', mod.StyleFilterFinishedFlash)
	FlashTexture.anim = anim

	local fadein = anim:CreateAnimation('ALPHA', 'FadeIn')
	fadein:SetChange(1)        -- 3.3.5a uses SetChange instead of SetFromAlpha/SetToAlpha
	fadein:SetOrder(2)
	anim.fadein = fadein

	local fadeout = anim:CreateAnimation('ALPHA', 'FadeOut')
	fadeout:SetChange(-1)
	fadeout:SetOrder(1)
	anim.fadeout = fadeout

	return anim
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

		if frame.isTarget and frame.frameType ~= 'PLAYER' and frame:IsElementEnabled('TargetIndicator') then
			frame.TargetIndicator:ForceUpdate() -- so the target indicator reappears
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
		mod:StyleFilterBaseUpdate(frame, state == 1)
	end
end

function mod:StyleFilterThreatUpdate(frame, unit)
	if mod:UnitExists(unit) then
		local indicator = frame.ThreatIndicator
		if not (indicator and mod.ThreatIndicator_PreUpdate) then return end
		local isTank, offTank, feedbackUnit = mod.ThreatIndicator_PreUpdate(indicator, unit, true)
		if feedbackUnit and (feedbackUnit ~= unit) and mod:UnitExists(feedbackUnit) then
			return isTank, offTank, UnitThreatSituation(feedbackUnit, unit)
		else
			return isTank, offTank, UnitThreatSituation(unit)
		end
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

function mod:StyleFilterSetChanges(frame, actions, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged, ShowHealthChanged, TargetIndicatorChanged)
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
		frame.FrameLevelChanged = actions.frameLevel -- we pass this to `ResetNameplateFrameLevel`
	end
	if HealthColorChanged then
		frame.StyleChanged = true
		frame.HealthColorChanged = true
		local hc = actions.color.healthColor
		local hr, hg, hb, ha = hc.r, hc.g, hc.b, hc.a
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
		local br, bg, bb, ba = bc.r, bc.g, bc.b, bc.a
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
			local nr, ng, nb, na = nc.r, nc.g, nc.b, nc.a
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
	if NameOnlyChanged then
		frame.StyleChanged = true
		frame.NameOnlyChanged = true
		frame.StyleFilterChanges.NameOnly = true
		--hide the bars
		if frame.Castbar and frame.Castbar:IsShown() then frame.Castbar:Hide() end
		if frame.Health:IsShown() then frame.Health:Hide() end
		--hide the target indicator
		mod:Configure_Glow(frame)
		mod:Update_Glow(frame)
		--position the name and update its color
		frame.Name:ClearAllPoints()
		frame.Name:SetJustifyH("CENTER")
		frame.Name:SetPoint("CENTER", frame.RaisedElement or frame)
		frame.Name:SetParent(frame.RaisedElement or frame)
		if mod.db.units[frame.UnitType].level.enable then
			frame.Level:ClearAllPoints()
			frame.Level:SetPoint("LEFT", frame.Name, "RIGHT")
			frame.Level:SetJustifyH("LEFT")
			frame.Level:SetParent(frame.RaisedElement or frame)
			frame.Level:SetFormattedText(" [%s]", mod:UnitLevel(frame))
		end
		if not NameColorChanged then
			mod:Update_Name(frame, true)
		end
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
		frame.StyleFilterChanges.ShowTargetIndicator = true
		frame.StyleFilterChanges.TargetIndicatorStyle = actions.targetIndicatorStyle or 'style4'
		mod:Update_TargetIndicator(frame)
	end
end

function mod:StyleFilterClearChanges(frame, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged, ShowHealthChanged, TargetIndicatorChanged)
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
		frame.StyleFilterChanges.NameOnly = nil
		frame.TopLevelFrame = nil --We can safely clear this here because it is set upon `UpdateElement_Auras` if needed
		if mod.db.units[frame.UnitType].health.enable or (frame.isTarget and mod.db.alwaysShowTargetHealth) then
			frame.Health:Show()
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
		mod:Update_TargetIndicator(frame)
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

	-- Unit Target (Retail only)
	if E.Retail and (trigger.targetMe or trigger.notTargetMe) then
		if (trigger.targetMe and frame.isTargetingMe) or (trigger.notTargetMe and not frame.isTargetingMe) then passed = true else return end
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
				for _, value in pairs(D) do
					if value and not D[mod.TriggerConditions.difficulties[difficultyID]] then return end
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
		if ((reaction == 1 or reaction == 2 or reaction == 3) and trigger.reactionType.hostile) or (reaction == 4 and trigger.reactionType.neutral) or (reaction == 5 and trigger.reactionType.friendly) then passed = true else return end
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
				local name = trigger.names[frame.UnitName] or (frame.npcID and trigger.names[frame.npcID])
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
	local healthBarShown = healthBarEnabled and (frame.Health:IsShown() or actions.showHealth)

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
		(actions.showTargetIndicator) --TargetIndicatorChanged
	)
end

function mod:StyleFilterClear(frame)
	if frame and frame.StyleChanged then
		mod:StyleFilterClearChanges(frame, frame.HealthColorChanged, frame.BorderChanged, frame.FlashingHealth, frame.TextureChanged, frame.ScaleChanged, frame.FrameLevelChanged, frame.AlphaChanged, frame.NameColorChanged, frame.NameOnlyChanged, frame.VisibilityChanged, frame.ShowHealthChanged, frame.TargetIndicatorChanged)
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
	nameplate.isFocused = nil
	nameplate.inVehicle = nil
	nameplate.isTargetingMe = nil
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

				if t.keyMod and t.keyMod.enable then	events.MODIFIER_STATE_CHANGED = 1 end
				if t.isFocus or t.notFocus then			events.PLAYER_FOCUS_CHANGED = 1 end
				if t.isResting or t.notResting then		events.PLAYER_UPDATE_RESTING = 1 end
				if t.isPet or t.isNotPet then			events.UNIT_PET = 1 end

				if t.targetMe or t.notTargetMe then
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

	local state = mod:StyleFilterHiddenState(frame.StyleFilterChanges)

	mod:StyleFilterClear(frame)

	for filterNum in ipairs(mod.StyleFilterTriggerList) do
		local filter = E.global.nameplates.filters[mod.StyleFilterTriggerList[filterNum][1]]
		if filter and filter.triggers then
			mod:StyleFilterConditionCheck(frame, filter, filter.triggers)
		end
	end

	mod:StyleFilterClearVisibility(frame, state)
end

do -- oUF style filter inject watch functions without actually registering any extra C events
	local pooler = CreateFrame('Frame')
	pooler.frames = {}
	pooler.delay = 0.1 -- update check rate

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
			pooler.frames[frame] = true
		end
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

		for event in pairs(mod.StyleFilterDefaultEvents) do
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

	function mod:StyleFilterRegister(nameplate, event, unitless)
		if not nameplate:IsEventRegistered(event) then
			-- Sirus oUF RegisterEvent(event, func); ignore unitless arg
			nameplate:RegisterEvent(event, E.noop)
		end
	end
end

-- events we actually register on plates when they are added
function mod:StyleFilterEvents(nameplate)
	if nameplate == _G.ElvNP_Test then return end

	-- per-plate change tracker
	nameplate.StyleFilterChanges = nameplate.StyleFilterChanges or {}

	for event, unitless in pairs(mod.StyleFilterDefaultEvents) do
		mod:StyleFilterRegister(nameplate, event, unitless)
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
