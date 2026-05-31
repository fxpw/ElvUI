local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local max, pairs = max, pairs

local CreateFrame = CreateFrame
local GetComboPoints = GetComboPoints
local GetRuneCooldown = GetRuneCooldown
local GetRuneType = GetRuneType
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

-- Classes that display resources
local COMBO_CLASS = { ROGUE = true, DRUID = true }
local RUNE_CLASS  = 'DEATHKNIGHT'

-- Number of power bars per class
local MAX_POINTS = {
	DEATHKNIGHT = 6,
	ROGUE       = max(5, MAX_COMBO_POINTS),
	DRUID       = max(5, MAX_COMBO_POINTS),
}

-- Hide Blizzard RuneFrame and class nameplate mechanic bar when custom display is enabled
function NP:ClassPower_UpdateRuneFrameVisibility()
	local playerDB = NP.db.units.PLAYER and NP.db.units.PLAYER.classpower
	local targetDB = NP.db.units.TARGET and NP.db.units.TARGET.classpower
	local enabled  = (playerDB and playerDB.enable) or (targetDB and targetDB.enable)

	-- Standalone DK rune bar
	if E.myclass == RUNE_CLASS then
		local rf = _G.RuneFrame
		if rf then
			if enabled then
				rf:Hide()
				rf.Show = E.noop
			else
				rf.Show = nil
				rf:Show()
			end
		end
	end

	-- Blizzard class nameplate mechanic bar (combo points / runes on nameplate)
	if COMBO_CLASS[E.myclass] or E.myclass == RUNE_CLASS then
		local driver = _G.NamePlateDriverFrame
		local bar    = driver and driver:GetClassNameplateBar()
		if bar then
			if enabled then
				bar:Hide()
			elseif driver then
				driver:SetupClassNameplateBars()
			end
		end
	end
end

-- Hook NamePlateDriverFrame:SetupClassNameplateBars so Blizzard can't re-show the bar
function NP:ClassPower_HookBlizzardBars()
	if not (COMBO_CLASS[E.myclass] or E.myclass == RUNE_CLASS) then return end
	local driver = _G.NamePlateDriverFrame
	if not driver or driver._elvClassPowerHooked then return end
	driver._elvClassPowerHooked = true

	hooksecurefunc(driver, 'SetupClassNameplateBars', function()
		local pDB = NP.db and NP.db.units.PLAYER and NP.db.units.PLAYER.classpower
		local tDB = NP.db and NP.db.units.TARGET and NP.db.units.TARGET.classpower
		if not ((pDB and pDB.enable) or (tDB and tDB.enable)) then return end
		local bar = driver.classNamePlateMechanicFrame
		if bar then bar:Hide() end
	end)
end

-- Rune slot -> display position map (matches oUF runes.lua)
local runemap = {1, 2, 5, 6, 3, 4}

-- Smooth rune cooldown fill: throttle SetValue so we don't spam StatusBar every frame.
local RUNE_STEP = 0.05
local function RuneOnUpdate(self, elapsed)
	self.duration = self.duration + elapsed
	if (self.duration - (self._lastApplied or -1)) >= RUNE_STEP then
		self._lastApplied = self.duration
		self:SetValue(self.duration)
	end
end

-- ─── Color helpers ──────────────────────────────────────────────────────────

function NP:ClassPower_SetBarColor(bar, r, g, b)
	bar:SetStatusBarColor(r, g, b)
	if bar.bg then
		bar.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier)
	end
end

function NP:ClassPower_UpdateColor(frame, powerType)
	local colors     = NP.db.colors.classResources
	local classColor = (powerType == 'COMBO_POINTS') and colors.comboPoints
	for i = 1, #frame do
		local bar = frame[i]
		if bar then
			local color = classColor and classColor[i]
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
		NP:ClassPower_UpdateColor(frame, 'COMBO_POINTS')
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
		rune._lastApplied = nil
		rune:SetScript('OnUpdate', nil)
	else
		rune.duration = GetTime() - start
		rune._lastApplied = nil
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
	do local s = nameplate:GetFrameStrata() if s ~= 'UNKNOWN' then ClassPower:SetFrameStrata(s) else ClassPower:SetFrameStrata('MEDIUM') end end
	ClassPower:SetFrameLevel(nameplate:GetFrameLevel() + 2)

	local texture = LSM:Fetch('statusbar', NP.db.statusbar)
	local total   = MAX_POINTS[E.myclass] or 0

	for i = 1, total do
		local bar = CreateFrame('StatusBar', frameName..'ClassPower'..i, ClassPower)
		bar:SetStatusBarTexture(texture)
		do local s = nameplate:GetFrameStrata() if s ~= 'UNKNOWN' then bar:SetFrameStrata(s) else bar:SetFrameStrata('MEDIUM') end end
		bar:SetFrameLevel(nameplate:GetFrameLevel() + 3)
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

-- ─── Layout helper ──────────────────────────────────────────────────────────

local function LayoutClassPowerBars(frame, db, maxButtons)
	frame:ClearAllPoints()
	frame:Point('CENTER', frame:GetParent(), 'CENTER', db.xOffset, db.yOffset)
	frame:Size(db.width, db.height)

	for i = 1, #frame do
		frame[i]:Hide()
		frame[i].bg:Hide()
	end

	if maxButtons > 0 then
		local barW = db.width / maxButtons
		for i = 1, maxButtons do
			local btn = frame[i]
			btn:ClearAllPoints()
			if i == 1 then
				btn:Point('LEFT', frame, 'LEFT', 0, 0)
				btn:Size(barW, db.height)
			else
				btn:Point('LEFT', frame[i - 1], 'RIGHT', 1, 0)
				btn:Size(barW - 1, db.height)
				if i == maxButtons then
					btn:Point('RIGHT', frame)
				end
			end
		end
	end
end

-- ─── Main update ────────────────────────────────────────────────────────────

function NP:Update_ClassPower(nameplate)
	local frame = nameplate.ClassPower
	if not frame then return end

	-- Test-frame preview
	if nameplate == _G.ElvNP_Test then
		local db = NP:PlateDB(nameplate)
		if not db.nameOnly and db.classpower and db.classpower.enable then
			local fixedCount = 5
			if fixedCount > #frame then fixedCount = #frame end
			LayoutClassPowerBars(frame, db.classpower, fixedCount)
			for i = 1, fixedCount do
				local bar = frame[i]
				if bar then
					bar:Show()
					if bar.bg then bar.bg:Show() end
				end
			end
			NP:ClassPower_UpdateColor(frame, 'COMBO_POINTS')
			frame:SetAlpha(1)
		else
			frame:SetAlpha(0)
		end
		return
	end

	-- Gate by class
	if not COMBO_CLASS[E.myclass] and E.myclass ~= RUNE_CLASS then
		frame:Hide()
		return
	end

	-- Hide when nameOnly is enabled for this plate type
	local plateDB = NP:PlateDB(nameplate)
	if plateDB.nameOnly then
		frame:Hide()
		return
	end

	-- ── Player's own nameplate or targeted nameplate: combo points / DK runes ──
	local isPlayer = nameplate.frameType == 'PLAYER'
	local isTarget = nameplate.isTarget

	local db = isPlayer and (NP.db.units.PLAYER and NP.db.units.PLAYER.classpower)
		or (isTarget and (NP.db.units.TARGET and NP.db.units.TARGET.classpower))
	if not db then
		frame:Hide()
		return
	end

	if not db.enable then
		frame:Hide()
		return
	end
	if db.onlyInCombat and not InCombatLockdown() then
		frame:Hide()
		return
	end

	local isRuneMode = E.myclass == RUNE_CLASS
	local maxButtons = isRuneMode and 6 or MAX_COMBO_POINTS
	if maxButtons > #frame then maxButtons = #frame end

	LayoutClassPowerBars(frame, db, maxButtons)

	if isRuneMode then
		NP:ClassPower_UpdateAllRunes(nameplate)
	else
		NP:ClassPower_UpdateComboPoints(nameplate)
	end
end

-- ─── Module-level event handlers ────────────────────────────────────────────

-- Combo points changed (Rogue/Druid) — update player plate and target plate
function NP:ClassPower_UNIT_COMBO_POINTS()
	if not COMBO_CLASS[E.myclass] or not NP.Plates then return end
	for plate in pairs(NP.Plates) do
		if plate.ClassPower and (plate.isTarget or plate.frameType == 'PLAYER') then
			NP:Update_ClassPower(plate)
		end
	end
end

-- DK rune changed — update player plate and/or target plate
function NP:ClassPower_RUNE_POWER_UPDATE(_, runeID)
	if E.myclass ~= RUNE_CLASS or not NP.Plates then return end
	local playerDB = NP.db.units.PLAYER and NP.db.units.PLAYER.classpower
	local targetDB = NP.db.units.TARGET and NP.db.units.TARGET.classpower

	for plate in pairs(NP.Plates) do
		if plate.ClassPower then
			if plate.frameType == 'PLAYER' and playerDB and playerDB.enable then
				NP:ClassPower_UpdateRune(plate, runeID)
			elseif plate.isTarget and targetDB and targetDB.enable then
				NP:ClassPower_UpdateRune(plate, runeID)
			end
		end
	end
end

NP.ClassPower_RUNE_TYPE_UPDATE = NP.ClassPower_RUNE_POWER_UPDATE

-- Combat state changed: refresh all relevant plates (for onlyInCombat setting)
function NP:ClassPower_PLAYER_REGEN()
	if not NP.Plates then return end
	for plate in pairs(NP.Plates) do
		if plate.ClassPower and (plate.isTarget or plate.frameType == 'PLAYER') then
			NP:Update_ClassPower(plate)
		end
	end
end
