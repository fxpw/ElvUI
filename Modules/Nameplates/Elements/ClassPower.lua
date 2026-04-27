local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local _G = _G
local max, ipairs, pairs = max, ipairs, pairs

local CreateFrame = CreateFrame
local GetComboPoints = GetComboPoints
local GetRuneCooldown = GetRuneCooldown
local GetRuneType = GetRuneType
local GetTime = GetTime
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

-- Classes that display resources on the TARGET nameplate
local COMBO_CLASS = { ROGUE = true, DRUID = true }
local RUNE_CLASS  = 'DEATHKNIGHT'

-- Number of power bars per class
local MAX_POINTS = {
	DEATHKNIGHT = 6,
	ROGUE       = max(5, MAX_COMBO_POINTS),
	DRUID       = max(5, MAX_COMBO_POINTS),
}

-- Hide Blizzard RuneFrame if custom DK rune display is enabled
function NP:ClassPower_UpdateRuneFrameVisibility()
	if E.myclass ~= RUNE_CLASS then return end
	local rf = _G.RuneFrame
	if not rf then return end
	local targetDB = NP.db.units.TARGET
	if targetDB and targetDB.classpower and targetDB.classpower.enable then
		rf:Hide()
		rf.Show = E.noop
	else
		rf.Show = nil
		rf:Show()
	end
end

-- Rune slot -> display position map (matches oUF runes.lua)
local runemap = {1, 2, 5, 6, 3, 4}

-- Smooth rune cooldown fill
local function RuneOnUpdate(self, elapsed)
	self.duration = self.duration + elapsed
	self:SetValue(self.duration)
end

-- ─── Color helpers ──────────────────────────────────────────────────────────

function NP:ClassPower_SetBarColor(bar, r, g, b)
	bar:SetStatusBarColor(r, g, b)
	if bar.bg then
		bar.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier)
	end
end

function NP:ClassPower_UpdateColor(powerType, rune)
	local colors   = NP.db.colors.classResources
	local fallback = NP.db.colors.power and NP.db.colors.power[powerType]

	if powerType == 'RUNES' and rune then
		local color = colors.DEATHKNIGHT and colors.DEATHKNIGHT[rune.runeType or 0]
		if color then NP:ClassPower_SetBarColor(rune, color.r, color.g, color.b) end
	else
		local classColor = powerType == 'COMBO_POINTS' and colors.comboPoints
		for i, bar in ipairs(self) do
			local color = (classColor and classColor[i]) or colors[E.myclass] or fallback
			if color then NP:ClassPower_SetBarColor(bar, color.r, color.g, color.b) end
		end
	end
end

-- ─── Value updaters (called every time a resource changes) ──────────────────

function NP:ClassPower_UpdateComboPoints(nameplate)
	local frame = nameplate.ClassPower
	if not frame then return end

	local cp
	if UnitHasVehicleUI('player') then
		cp = GetComboPoints('vehicle', 'target')
	else
		cp = GetComboPoints('player', 'target')
	end

	for i = 1, MAX_COMBO_POINTS do
		local bar = frame[i]
		if bar then
			if i <= cp then
				bar:Show()
				bar.bg:Show()
			else
				bar:Hide()
				bar.bg:Hide()
			end
		end
	end

	if cp > 0 then
		frame:Show()
		NP.ClassPower_UpdateColor(frame, 'COMBO_POINTS')
	else
		frame:Hide()
	end
end

function NP:ClassPower_UpdateRune(nameplate, runeID)
	local frame = nameplate.ClassPower
	if not frame then return end

	local rune = frame[runemap[runeID]]
	if not rune then return end

	local runeType = GetRuneType(runeID)
	if runeType then
		rune.runeType = runeType
		local colors = NP.db.colors.classResources
		local color  = colors.DEATHKNIGHT and colors.DEATHKNIGHT[runeType]
		if color then NP:ClassPower_SetBarColor(rune, color.r, color.g, color.b) end
	end

	if UnitHasVehicleUI('player') then
		rune:Hide()
		return
	end

	local start, duration, runeReady = GetRuneCooldown(runeID)
	if not start then return end

	if runeReady then
		rune:SetMinMaxValues(0, 1)
		rune:SetValue(1)
		rune:SetScript('OnUpdate', nil)
	else
		rune.duration = GetTime() - start
		rune:SetMinMaxValues(0, duration)
		rune:SetValue(0)
		rune:SetScript('OnUpdate', RuneOnUpdate)
	end
	rune:Show()
end

function NP:ClassPower_UpdateAllRunes(nameplate)
	if not nameplate.ClassPower then return end
	for i = 1, 6 do
		NP:ClassPower_UpdateRune(nameplate, i)
	end
	nameplate.ClassPower:Show()
end

-- ─── Construction ───────────────────────────────────────────────────────────

function NP:Construct_ClassPower(nameplate)
	local frameName  = nameplate:GetName()
	local ClassPower = CreateFrame('Frame', frameName..'ClassPower', nameplate)
	ClassPower:CreateBackdrop('Transparent', nil, nil, nil, nil, true, true)
	ClassPower:Hide()
	do local s = nameplate:GetFrameStrata() if s ~= 'UNKNOWN' then ClassPower:SetFrameStrata(s) end end
	ClassPower:SetFrameLevel(5)

	local texture = LSM:Fetch('statusbar', NP.db.statusbar)
	local total   = MAX_POINTS[E.myclass] or 0

	for i = 1, total do
		local bar = CreateFrame('StatusBar', frameName..'ClassPower'..i, ClassPower)
		bar:SetStatusBarTexture(texture)
		do local s = nameplate:GetFrameStrata() if s ~= 'UNKNOWN' then bar:SetFrameStrata(s) end end
		bar:SetFrameLevel(6)
		NP.StatusBars[bar] = true

		-- bg texture anchored to bar (sized per-bar later)
		bar.bg = ClassPower:CreateTexture(frameName..'ClassPower'..i..'bg', 'BORDER')
		bar.bg:SetTexture(texture)
		bar.bg:SetAllPoints(bar)

		if E.myclass == RUNE_CLASS then
			bar:SetMinMaxValues(0, 1)
			bar:SetValue(1)
		end

		ClassPower[i] = bar
	end

	-- Test frame: always visible, use combo-point colors
	if nameplate == _G.ElvNP_Test then
		ClassPower.Hide = ClassPower.Show
		ClassPower:Show()
	end

	return ClassPower
end

-- ─── Layout + enable/disable ────────────────────────────────────────────────

function NP:Update_ClassPower(nameplate)
	local frame = nameplate.ClassPower
	if not frame then return end

	-- Test-frame preview
	if nameplate == _G.ElvNP_Test then
		local db = NP:PlateDB(nameplate)
		if not db.nameOnly and db.classpower and db.classpower.enable then
			NP.ClassPower_UpdateColor(frame, 'COMBO_POINTS')
			frame:SetAlpha(1)
		else
			frame:SetAlpha(0)
		end
		return
	end

	local isTarget = nameplate.isTarget

	-- Only show on the targeted nameplate
	if not isTarget then
		frame:Hide()
		return
	end

	-- Gate by class
	if not COMBO_CLASS[E.myclass] and E.myclass ~= RUNE_CLASS then
		frame:Hide()
		return
	end

	local db = NP.db.units.TARGET
	if not db or not db.classpower or not db.classpower.enable then
		frame:Hide()
		return
	end

	-- Layout: position and size the container
	local cpDB       = db.classpower
	local maxButtons = (E.myclass == RUNE_CLASS) and 6 or MAX_COMBO_POINTS
	if maxButtons > #frame then maxButtons = #frame end

	frame:ClearAllPoints()
	frame:Point('CENTER', nameplate, 'CENTER', cpDB.xOffset, cpDB.yOffset)
	frame:Size(cpDB.width, cpDB.height)

	-- Hide all bars first, then show/size visible ones
	for i = 1, #frame do
		frame[i]:Hide()
		frame[i].bg:Hide()
	end

	if maxButtons > 0 then
		local barW = cpDB.width / maxButtons
		for i = 1, maxButtons do
			local btn = frame[i]
			btn:ClearAllPoints()
			if i == 1 then
				btn:Point('LEFT', frame, 'LEFT', 0, 0)
				btn:Size(barW, cpDB.height)
			else
				btn:Point('LEFT', frame[i - 1], 'RIGHT', 1, 0)
				btn:Size(barW - 1, cpDB.height)
				if i == maxButtons then
					btn:Point('RIGHT', frame)
				end
			end
		end
	end

	-- Populate values
	if E.myclass == RUNE_CLASS then
		NP:ClassPower_UpdateAllRunes(nameplate)
	else
		NP:ClassPower_UpdateComboPoints(nameplate)
	end
end

-- ─── Module-level event handlers ────────────────────────────────────────────

function NP:ClassPower_UNIT_COMBO_POINTS()
	if not COMBO_CLASS[E.myclass] or not NP.Plates then return end
	local targetDB = NP.db.units.TARGET
	if not targetDB or not targetDB.classpower or not targetDB.classpower.enable then return end

	for plate in pairs(NP.Plates) do
		if plate.isTarget and plate.ClassPower then
			NP:ClassPower_UpdateComboPoints(plate)
		end
	end
end

function NP:ClassPower_RUNE_POWER_UPDATE(_, runeID)
	if E.myclass ~= RUNE_CLASS or not NP.Plates then return end
	local targetDB = NP.db.units.TARGET
	if not targetDB or not targetDB.classpower or not targetDB.classpower.enable then return end

	for plate in pairs(NP.Plates) do
		if plate.isTarget and plate.ClassPower then
			NP:ClassPower_UpdateRune(plate, runeID)
		end
	end
end

NP.ClassPower_RUNE_TYPE_UPDATE = NP.ClassPower_RUNE_POWER_UPDATE
