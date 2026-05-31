local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local unpack = unpack
local ipairs = ipairs
local tinsert = tinsert
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsTappedByAllThreatList = UnitIsTappedByAllThreatList
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local CreateFrame = CreateFrame

-- Nameplate border (Health backdrop edge): pin to exactly 1 physical px and keep it above neighbour plates.

-- 1 physical px in logical units at the frame's effective scale (native PixelUtil, taint-safe; falls back to 768/screenheight).
function NP:BorderPixelSize(effectiveScale)
	local factor = (PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor())
	if not factor or factor <= 0 then
		local sh = E.screenheight or (select(2, GetPhysicalScreenSize and GetPhysicalScreenSize())) or 768
		if not sh or sh <= 0 then sh = 768 end
		factor = 768 / sh
	end
	local s = effectiveScale
	if not s or s <= 0 then s = 1 end
	return factor / s
end

-- Pin a crisp 1px edge and keep it through SetTemplate re-applies (preserves bg/edge/insets).
function NP:Health_FixBorderPixel(Health)
	local backdrop = Health and Health.backdrop
	if not backdrop or not backdrop.GetBackdrop then return end
	local px = NP:BorderPixelSize(backdrop:GetEffectiveScale())
	local bd = backdrop:GetBackdrop()
	if not bd then return end
	if bd.edgeSize ~= px then
		local cr, cg, cb, ca = backdrop:GetBackdropColor() -- SetBackdrop wipes both colors; restore bg so it isn't opaque white
		bd.edgeSize = px
		backdrop:SetBackdrop(bd)
		if cr then backdrop:SetBackdropColor(cr, cg, cb, ca) end
		backdrop:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
	end
	backdrop:SetOutside(Health, px, px)
	backdrop.ignoreFrameTemplates = true -- don't let E:UpdateFrameTemplates reset edgeSize
end

-- Glue the border level to Health so it draws above the fill and above overlapping neighbour plates.
function NP:Health_SyncBorderLevel(Health)
	local backdrop = Health and Health.backdrop
	if not backdrop then return end
	backdrop:SetFrameLevel(Health:GetFrameLevel())
end

function NP:Health_UpdateColor(_, unit)
	if not unit or self.unit ~= unit then return end

	-- ThreatIndicator_PostUpdate manages the bar color directly via SetStatusBarColor.
	-- While ThreatStatus is set (threat active + useThreatColor), skip all standard color
	-- logic to avoid overwriting the threat color on every UNIT_THREAT_LIST_UPDATE.
	if self.ThreatStatus
		and NP.db.threat
		and NP.db.threat.enable
		and NP.db.threat.useThreatColor
	then
		return
	end

	local element = self.Health

	local r, g, b, t
	if element.colorDisconnected and not UnitIsConnected(unit) then
		t = self.colors.disconnected
	elseif element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) then
		t = NP.db.colors.tapped
	elseif element.colorClass and self.isPlayer then
		local _, class = UnitClass(unit)
		local cc = class and self.colors.class[class]
		if cc then
			r, g, b = cc[1] or cc.r, cc[2] or cc.g, cc[3] or cc.b
			element.r, element.g, element.b = r, g, b
		end
	elseif element.colorReaction and UnitReaction(unit, 'player') then
		local reaction = UnitReaction(unit, 'player')
		t = NP.db.colors.reactions[reaction == 4 and 'neutral' or reaction <= 3 and 'bad' or 'good']
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

	if not b then
		-- UnitReaction returned nil (race with UNIT_FACTION) — use cached reaction.
		local reaction = self.reaction
		local t2 = reaction and NP.db.colors.reactions[reaction == 4 and 'neutral' or reaction <= 3 and 'bad' or 'good']
		if t2 then
			r, g, b = t2.r, t2.g, t2.b
		else
			r, g, b = 0.8, 0.1, 0.1 -- ultimate fallback: hostile red
		end
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

	-- Mirror Power's color callbacks (used by CutawayHealth to sync drain-bar color).
	local frame = self
	if frame.HealthColorChangeCallbacks and b then
		for _, cb in ipairs(frame.HealthColorChangeCallbacks) do
			cb(NP, frame, r, g, b)
		end
	end

	-- Some paths re-assign statusbar textures/colors after NameOnly is applied.
	-- Re-assert transparency so the health fill cannot visually reappear.
	if element._isTransparent then
		NP:Health_SetTransparent(self, true)
	end
end

-- nameOnly visual toggle: keep the Health frame Shown so children (Name/Level) keep
-- inheriting its framelevel/strata across plate recycling and engine target switches,
-- but make the bar visually disappear (texture/bg/backdrop).
function NP:Health_SetTransparent(nameplate, transparent)
	local Health = nameplate and nameplate.Health
	if not Health then return end
	local a = transparent and 0 or 1
	local tex = Health:GetStatusBarTexture()
	if tex then tex:SetAlpha(a) end
	if Health.bg then Health.bg:SetAlpha(a) end
	if nameplate.Highlight then
		nameplate.Highlight:SetAlpha(a)
		if transparent then
			nameplate.Highlight:Hide()
		end
	end
	if nameplate.HealthFlashTexture then
		nameplate.HealthFlashTexture:SetAlpha(a)
		if transparent then
			nameplate.HealthFlashTexture:Hide()
		end
	end
	if Health.backdrop then
		if transparent then Health.backdrop:Hide() else Health.backdrop:Show() end
	end
	Health._isTransparent = transparent or nil
end

-- Returns true when the Health bar is visually visible (not Hidden, not transparent).
function NP:Health_IsVisible(nameplate)
	local Health = nameplate and nameplate.Health
	if not Health or not Health:IsShown() then return false end
	return not Health._isTransparent
end

function NP:Construct_Health(nameplate)
	local Health = CreateFrame('StatusBar', nameplate:GetName()..'Health', nameplate)
	do local s = nameplate:GetFrameStrata() if s ~= 'UNKNOWN' then Health:SetFrameStrata(s) else Health:SetFrameStrata('MEDIUM') end end
	Health:SetFrameLevel(nameplate:GetFrameLevel() + 1)
	Health:CreateBackdrop('Transparent', nil, nil, nil, nil, true, true)
	NP:Health_FixBorderPixel(Health)   -- crisp 1 physical px border (no 1<->2px flicker)
	NP:Health_SyncBorderLevel(Health)  -- keep border above health fill / above neighbors
	Health:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
	-- Defaults so the bar is visible before oUF's first Update fills MinMax/Value/Color.
	Health:SetMinMaxValues(0, 1)
	Health:SetValue(1)
	Health:SetStatusBarColor(0.7, 0.7, 0.7)
	Health.colorTapping = true    -- enable tapped coloring for nameplates
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
		nameplate.Health:SetColorTapping(true)  -- enabled with proper retail-style check (UnitIsTappedByPlayer / UnitIsTappedByAllThreatList)
		nameplate.Health.colorReaction = true  -- WotLK: not E.Retail
		nameplate.Health.colorClass = db.health and db.health.useClassColor
	end
end

function NP:Update_Health(nameplate, skipUpdate)
	local db = NP:PlateDB(nameplate)

	-- Defensive: old saved profiles may be missing the per-unit health subtable entirely.
	-- Without this guard db.health.enable nils out and the bar is permanently disabled.
	if not db.health then
		db.health = {
			enable = true,
			height = 10,
			useClassColor = true,
			text = {
				enable = true,
				format = '[health:current]',
				position = 'CENTER',
				parent = 'Nameplate',
				xOffset = 0,
				yOffset = 0,
				font = 'PT Sans Narrow',
				fontOutline = 'OUTLINE',
				fontSize = 11,
			},
			healPrediction = {
				enable = true,
				absorbStyle = 'REVERSED',
				anchorPoint = 'BOTTOM',
				absorbTexture = 'ElvUI Norm',
				height = -1,
				maxOverflow = 0,
				colors = {
					myBar = {r = 0, g = 1, b = 0.5, a = 0.25},
					otherBar = {r = 0, g = 1, b = 0, a = 0.25},
					absorbs = {r = 0, g = 1, b = 1, a = 0.25},
					healAbsorbs = {r = 1, g = 0, b = 0, a = 0.25},
					overabsorbs = {r = 0, g = 1, b = 1, a = 1},
					overhealabsorbs = {r = 1, g = 0, b = 0, a = 1},
				},
			},
		}
	end

	NP:Health_SetColors(nameplate)

	if skipUpdate then return end

	nameplate.Health:Point('CENTER')
	nameplate.Health:Point('LEFT')
	nameplate.Health:Point('RIGHT')

	if db.health.enable and not db.nameOnly then
		if not nameplate:IsElementEnabled('Health') then
			nameplate:EnableElement('Health')
		end

		nameplate.Health:Show()
		NP:Health_SetTransparent(nameplate, false)

		E:SetSmoothing(nameplate.Health, NP.db.smoothbars)
	else
		if nameplate:IsElementEnabled('Health') then
			nameplate:DisableElement('Health')
		end

		-- nameOnly: keep Health frame Shown (so children Name/Level inherit its framelevel and stay visible),
		-- just hide the visual textures + backdrop.
		nameplate.Health:Show()
		NP:Health_SetTransparent(nameplate, true)
	end

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
