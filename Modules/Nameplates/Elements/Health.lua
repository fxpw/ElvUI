local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local unpack = unpack
local tinsert = tinsert
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapped = UnitIsTapped
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local CreateFrame = CreateFrame

function NP:Health_UpdateColor(_, unit)
	if not unit or self.unit ~= unit then return end
	local element = self.Health

	local r, g, b, t
	if element.colorDisconnected and not UnitIsConnected(unit) then
		t = self.colors.disconnected
	elseif element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapped(unit) then
		t = NP.db.colors.tapped
	elseif (element.colorClass and self.isPlayer) or (element.colorClassNPC and not self.isPlayer) or (element.colorClassPet and UnitPlayerControlled(unit) and not self.isPlayer) then
		local _, class = UnitClass(unit)
		local cc = class and self.colors.class[class]
		if cc then
			r, g, b = cc[1] or cc.r, cc[2] or cc.g, cc[3] or cc.b
			element.r, element.g, element.b = r, g, b
		end
	elseif element.colorReaction and UnitReaction(unit, 'player') then
		local reaction = UnitReaction(unit, 'player')
		t = NP.db.colors.reactions[reaction == 4 and 'neutral' or reaction <= 3 and 'bad' or 'good']
	elseif element.colorSmooth then
		r, g, b = self:ColorGradient(element.cur or 1, element.max or 1, unpack(element.smoothGradient or self.colors.smooth))
	elseif element.colorHealth then
		t = NP.db.colors.health
	end

	if t then
		r, g, b = t.r, t.g, t.b
		element.r, element.g, element.b = r, g, b
	end

	local sf = NP:StyleFilterChanges(self)
	if sf.HealthColor then
		r, g, b = sf.HealthColor.r, sf.HealthColor.g, sf.HealthColor.b
	end

	-- Fallback: ensure the bar always has a visible color even if every branch above missed
	-- (e.g. UnitReaction returned nil for a brand-new nameplate unit).
	if not b then
		r, g, b = 0.7, 0.7, 0.7
	end

	if b then
		element:SetStatusBarColor(r, g, b)

		if element.bg then
			element.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier)
		end
	end

	if element.PostUpdateColor then
		element:PostUpdateColor(unit, r, g, b)
	end
end

function NP:Construct_Health(nameplate)
	local Health = CreateFrame('StatusBar', nameplate:GetName()..'Health', nameplate)
	do local s = nameplate:GetFrameStrata() if s ~= 'UNKNOWN' then Health:SetFrameStrata(s) end end
	Health:SetFrameLevel(5)
	Health:CreateBackdrop('Transparent', nil, nil, nil, nil, true, true)
	Health:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
	-- Defaults so the bar is visible before oUF's first Update fills MinMax/Value/Color.
	Health:SetMinMaxValues(0, 1)
	Health:SetValue(1)
	Health:SetStatusBarColor(0.7, 0.7, 0.7)
	Health.colorReaction = true   -- WotLK: always use reaction color
	Health.colorSelection = false -- WotLK: no selection color system
	Health.UpdateColor = NP.Health_UpdateColor

	NP.StatusBars[Health] = true

	-- Background texture for the unfilled portion of the bar.
	-- Color is set in Health_UpdateColor as (r,g,b) * NP.multiplier so it tints with the bar.
	local bg = Health:CreateTexture(nameplate:GetName()..'HealthBG', 'BORDER')
	bg:SetAllPoints(Health)
	bg:SetTexture(LSM:Fetch('statusbar', NP.db.statusbar))
	bg:SetVertexColor(0, 0, 0, 1)
	Health.bg = bg

	local healthFlashTexture = Health:CreateTexture(nameplate:GetName()..'FlashTexture', 'OVERLAY')
	healthFlashTexture:SetTexture(LSM:Fetch('background', 'ElvUI Blank'))
	healthFlashTexture:Point('BOTTOMLEFT', Health:GetStatusBarTexture(), 'BOTTOMLEFT')
	healthFlashTexture:Point('TOPRIGHT', Health:GetStatusBarTexture(), 'TOPRIGHT')
	healthFlashTexture:Hide()
	nameplate.HealthFlashTexture = healthFlashTexture
	-- StyleFilter looks up frame.FlashTexture (see StyleFilterPass / StyleFilterSetChanges).
	-- Keep both names so legacy code paths and the StyleFilter flash action both work.
	nameplate.FlashTexture = healthFlashTexture

	return Health
end

function NP:Health_SetColors(nameplate, threatColors)
	if threatColors then
		nameplate.Health:SetColorTapping(nil)
		nameplate.Health.colorReaction = nil
		nameplate.Health.colorClass = nil
	else
		local db = NP:PlateDB(nameplate)
		nameplate.Health:SetColorTapping(true)
		nameplate.Health.colorReaction = true  -- WotLK: not E.Retail
		nameplate.Health.colorClass = db.health and db.health.useClassColor
	end
end

function NP:Update_Health(nameplate, skipUpdate)
	local db = NP:PlateDB(nameplate)

	-- Defensive: old saved profiles may be missing the per-unit health subtable entirely.
	-- Without this guard db.health.enable nils out and the bar is permanently disabled.
	if not db.health then
		db.health = { enable = true, height = 10, useClassColor = true }
	end

	NP:Health_SetColors(nameplate)

	if skipUpdate then return end

	if db.health.enable and not db.nameOnly then
		if not nameplate:IsElementEnabled('Health') then
			nameplate:EnableElement('Health')
		end

		nameplate.Health:Show()
		if nameplate.Health.backdrop then nameplate.Health.backdrop:Show() end

		nameplate.Health:Point('CENTER')
		nameplate.Health:Point('LEFT')
		nameplate.Health:Point('RIGHT')

		E:SetSmoothing(nameplate.Health, NP.db.smoothbars)
	else
		if nameplate:IsElementEnabled('Health') then
			nameplate:DisableElement('Health')
		end

		-- Hide bar + its backdrop/border so disabling Health visually removes everything attached to it.
		nameplate.Health:Hide()
		if nameplate.Health.backdrop then nameplate.Health.backdrop:Hide() end
	end

	nameplate.Health.width = db.health.width
	nameplate.Health.height = db.health.height
	nameplate.Health:Height(db.health.height)
end

-- Registers value/color change callbacks on a nameplate health bar (used by CutawayHealth)
function NP:RegisterHealthBarCallbacks(frame, valueChangeCB, colorChangeCB)
	if valueChangeCB then
		frame.HealthValueChangeCallbacks = frame.HealthValueChangeCallbacks or {}
		tinsert(frame.HealthValueChangeCallbacks, valueChangeCB)
	end

	if colorChangeCB then
		frame.HealthColorChangeCallbacks = frame.HealthColorChangeCallbacks or {}
		tinsert(frame.HealthColorChangeCallbacks, colorChangeCB)
	end
end
