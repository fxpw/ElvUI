local E, L, V, P, G = unpack(select(2, ...))
local _, Engine = ...
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM
local StatusBarPrototype = Engine.Compat.StatusBarPrototype

local CreateFrame = CreateFrame

local DEFAULT_COLORS = {
	myBar    = { r = 0, g = 1, b = 0.5, a = 0.25 },
	otherBar = { r = 0, g = 1, b = 0,   a = 0.25 },
}

local function GetColor(db, key)
	local c = db.colors and db.colors[key]
	if c then return c end
	return DEFAULT_COLORS[key]
end

local function HealPrediction_SetTransparent(element, transparent)
	local a = transparent and 0 or 1
	element.myBar:SetAlpha(a)
	element.otherBar:SetAlpha(a)
	element.absorbBar:SetAlpha(a)
	element.healAbsorbBar:SetAlpha(a)
	element.overAbsorb:SetAlpha(a)
	element.overHealAbsorb:SetAlpha(a)
	element._isTransparent = transparent or nil
end

local function HealPrediction_ShouldHide(nameplate, plateDB)
	local sf = NP:StyleFilterChanges(nameplate)
	return (plateDB and plateDB.nameOnly) or sf.NameOnly or not NP:Health_IsVisible(nameplate)
end

local function HealPrediction_PostUpdate(element, _, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb, health, maxHealth)
	local nameplate = element.__owner
	local db = nameplate and nameplate.HealPredictionDB
	if not db or not db.enable or not health then return end

	local plateDB = NP:PlateDB(nameplate)
	if HealPrediction_ShouldHide(nameplate, plateDB) then
		if not element._isTransparent then
			HealPrediction_SetTransparent(element, true)
		end
		return
	elseif element._isTransparent then
		HealPrediction_SetTransparent(element, false)
	end

	if NP.db.absorbSpark == false then
		element.overAbsorb:Hide()
		element.overHealAbsorb:Hide()
	end

	local absorbBar = element.absorbBar
	local healAbsorbBar = element.healAbsorbBar

	if not absorbBar then return end

	if db.absorbStyle == 'NONE' then
		absorbBar:Hide()
		if healAbsorbBar then healAbsorbBar:Hide() end
		return
	end

	local missingHealth = maxHealth - health
	local healthPostHeal = health + (myIncomingHeal or 0) + (otherIncomingHeal or 0)

	local ac = NP.db.colors.absorbs
	absorbBar:SetStatusBarColor(ac.r, ac.g, ac.b, ac.a)

	if healAbsorbBar then
		local hac = NP.db.colors.healAbsorbs
		healAbsorbBar:SetStatusBarColor(hac.r, hac.g, hac.b, hac.a)
	end

	if db.absorbStyle == 'NORMAL' then
		if hasOverAbsorb then
			if health == maxHealth then
				absorbBar:SetValue(0)
			elseif health + absorb > maxHealth then
				absorbBar:SetValue(missingHealth)
			end
		end
	elseif db.absorbStyle == 'STACKED' then
		if hasOverAbsorb then
			if health == maxHealth then
				absorbBar:SetValue(0)
			elseif healthPostHeal + absorb > maxHealth then
				absorbBar:SetValue(maxHealth - healthPostHeal)
			end
		end
	elseif db.absorbStyle == 'REVERSED' then
		if absorb > health then
			absorbBar:SetValue(health)
		end
	elseif db.absorbStyle == 'OVERFLOW' then
		if hasOverAbsorb then
			local maxOverflow = (db.maxOverflow or 0)
			local overflowAbsorb = absorb * maxOverflow
			if health == maxHealth then
				absorbBar:SetValue(overflowAbsorb)
			else
				absorbBar:SetValue(missingHealth + overflowAbsorb)
			end
		end
	end
end

function NP:Construct_HealPrediction(nameplate)
	local health = nameplate.Health
	if not health then return end

	local makeBar = StatusBarPrototype
	local myBar          = makeBar(nil, health)
	local otherBar       = makeBar(nil, health)
	local absorbBar      = makeBar(nil, health)
	local healAbsorbBar  = makeBar(nil, health)

	for _, bar in ipairs({ myBar, otherBar, absorbBar, healAbsorbBar }) do
		bar:SetFrameLevel(health:GetFrameLevel() + 1)
		bar:Hide()
	end

	local overlay = CreateFrame('Frame', nil, health)
	overlay:SetAllPoints(health)
	overlay:SetFrameLevel(health:GetFrameLevel() + 3)
	local overAbsorb     = overlay:CreateTexture(nil, 'OVERLAY')
	local overHealAbsorb = overlay:CreateTexture(nil, 'OVERLAY')

	overAbsorb:SetTexture([[Interface\AddOns\ElvUI\Media\Textures\RaidFrame\Shield-Overshield]])
	overAbsorb:SetBlendMode('ADD')
	overAbsorb:Hide()

	overHealAbsorb:SetTexture([[Interface\AddOns\ElvUI\Media\Textures\RaidFrame\Absorb-Overabsorb]])
	overHealAbsorb:SetBlendMode('ADD')
	overHealAbsorb:Hide()

	local element = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		maxOverflow = 1,
		PostUpdate = HealPrediction_PostUpdate,
	}

	-- oUF_HealthPrediction requires the element under HealCommBar; HealPrediction is our own alias.
	nameplate.HealCommBar = element
	nameplate.HealPrediction = element

	return element
end

function NP:Configure_HealPrediction(nameplate)
	local element = nameplate.HealCommBar
	local health = nameplate.Health
	if not element or not health then return end

	local plateDB = NP:PlateDB(nameplate)
	local db = plateDB and plateDB.health and plateDB.health.healPrediction
	nameplate.HealPredictionDB = db

	if not db or not db.enable then
		if nameplate:IsElementEnabled('HealthPrediction') then
			nameplate:DisableElement('HealthPrediction')
		end
		HealPrediction_SetTransparent(element, false)
		element.myBar:Hide()
		element.otherBar:Hide()
		element.absorbBar:Hide()
		element.healAbsorbBar:Hide()
		element.overAbsorb:Hide()
		element.overHealAbsorb:Hide()
		return
	end

	local width, height = health:GetSize()
	local barHeight = db.height
	if not barHeight or barHeight == -1 or barHeight > height then
		barHeight = height
	end

	local healthTex = health:GetStatusBarTexture()
	local absorbTex = LSM:Fetch('statusbar', db.absorbTexture or 'ElvUI Norm')
	local barTex    = LSM:Fetch('statusbar', NP.db.statusbar)

	for _, bar in ipairs({ element.myBar, element.otherBar, element.absorbBar, element.healAbsorbBar }) do
		bar:SetSize(width, barHeight)
		bar:SetOrientation('HORIZONTAL')
		bar:SetMinMaxValues(0, 1)
		bar:SetStatusBarTexture(barTex)
	end
	element.absorbBar:SetStatusBarTexture(absorbTex)

	local myC      = GetColor(db, 'myBar')
	local otherC   = GetColor(db, 'otherBar')
	local absorbC  = NP.db.colors.absorbs
	local healAbC  = NP.db.colors.healAbsorbs
	element.myBar:SetStatusBarColor(myC.r, myC.g, myC.b, myC.a)
	element.otherBar:SetStatusBarColor(otherC.r, otherC.g, otherC.b, otherC.a)
	element.absorbBar:SetStatusBarColor(absorbC.r, absorbC.g, absorbC.b, absorbC.a)
	element.healAbsorbBar:SetStatusBarColor(healAbC.r, healAbC.g, healAbC.b, healAbC.a)

	local anchor = db.anchorPoint or 'BOTTOM'
	element.myBar:ClearAllPoints()
	element.myBar:SetPoint(anchor, health, anchor)
	element.myBar:SetPoint('LEFT', healthTex, 'RIGHT')
	element.myBar:SetPoint('RIGHT', health, 'RIGHT')

	element.otherBar:ClearAllPoints()
	element.otherBar:SetPoint(anchor, health, anchor)
	element.otherBar:SetPoint('LEFT', element.myBar:GetStatusBarTexture(), 'RIGHT')
	element.otherBar:SetPoint('RIGHT', health, 'RIGHT')

	element.healAbsorbBar:ClearAllPoints()
	element.healAbsorbBar:SetPoint(anchor, health, anchor)
	element.healAbsorbBar:SetPoint('RIGHT', healthTex, 'RIGHT')
	element.healAbsorbBar:SetReverseFill(true)

	element.absorbBar:ClearAllPoints()
	element.absorbBar:SetPoint(anchor, health, anchor)
	if db.absorbStyle == 'REVERSED' then
		element.absorbBar:SetReverseFill(true)
		element.absorbBar:SetPoint('LEFT', health, 'LEFT')
		element.absorbBar:SetPoint('RIGHT', healthTex, 'RIGHT')
	elseif db.absorbStyle == 'STACKED' then
		element.absorbBar:SetReverseFill(false)
		element.absorbBar:SetPoint('LEFT', element.otherBar:GetStatusBarTexture(), 'RIGHT')
		element.absorbBar:SetPoint('RIGHT', health, 'RIGHT')
	else
		element.absorbBar:SetReverseFill(false)
		element.absorbBar:SetPoint('LEFT', healthTex, 'RIGHT')
		element.absorbBar:SetPoint('RIGHT', health, 'RIGHT')
	end

	local sparkW = 6
	element.overAbsorb:ClearAllPoints()
	element.overAbsorb:SetSize(sparkW, barHeight)
	element.overAbsorb:SetPoint('CENTER', health, 'RIGHT')
	element.overAbsorb:SetVertexColor(absorbC.r, absorbC.g, absorbC.b)

	element.overHealAbsorb:ClearAllPoints()
	element.overHealAbsorb:SetSize(sparkW, barHeight)
	element.overHealAbsorb:SetPoint('CENTER', health, 'LEFT')
	element.overHealAbsorb:SetVertexColor(healAbC.r, healAbC.g, healAbC.b)

	if NP.db.absorbSpark == false then
		element.overAbsorb:Hide()
		element.overHealAbsorb:Hide()
	end

	element.maxOverflow = 1 + (db.maxOverflow or 0)
	HealPrediction_SetTransparent(element, HealPrediction_ShouldHide(nameplate, plateDB))

	if not nameplate:IsElementEnabled('HealthPrediction') then
		nameplate:EnableElement('HealthPrediction')
	end

	if element.ForceUpdate and nameplate.unit then
		element:ForceUpdate()
	end
end

function NP:Update_HealPrediction(nameplate)
	NP:Configure_HealPrediction(nameplate)
end
