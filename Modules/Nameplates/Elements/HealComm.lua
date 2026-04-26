local E, L, V, P, G = unpack(select(2, ...))
local _, Engine = ...
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM
local StatusBarPrototype = Engine.Compat.StatusBarPrototype

local CreateFrame = CreateFrame

-- Create a status bar overlay for incoming heal / absorb prediction on the nameplate's Health bar.
-- The oUF "HealthPrediction" element drives this via self.HealCommBar (see oUF_HealthPrediction).

function NP:SetAlpha_HealComm(obj, alpha)
	obj.myBar:SetAlpha(alpha)
	obj.otherBar:SetAlpha(alpha)
	obj.absorbBar:SetAlpha(alpha)
	obj.healAbsorbBar:SetAlpha(alpha)
end

function NP:SetTexture_HealComm(obj, texture)
	obj.myBar:SetStatusBarTexture(texture)
	obj.otherBar:SetStatusBarTexture(texture)
	obj.absorbBar:SetStatusBarTexture(texture)
	obj.healAbsorbBar:SetStatusBarTexture(texture)
end

function NP:SetFrameLevel_HealComm(obj, level)
	obj.myBar:SetFrameLevel(level)
	obj.otherBar:SetFrameLevel(level)
	obj.absorbBar:SetFrameLevel(level)
	obj.healAbsorbBar:SetFrameLevel(level)
end

function NP:Construct_HealComm(nameplate)
	local health = nameplate.Health
	local parent = CreateFrame('Frame', nil, health)
	parent:SetPoint('LEFT', health, 'LEFT')
	parent:SetSize(1, 1) -- size set later in SetSize_HealComm

	local myBar          = StatusBarPrototype(nil, parent)
	local otherBar       = StatusBarPrototype(nil, parent)
	local absorbBar      = StatusBarPrototype(nil, parent)
	local healAbsorbBar  = StatusBarPrototype(nil, parent)
	local overAbsorb     = parent:CreateTexture(nil, 'OVERLAY')
	local overHealAbsorb = parent:CreateTexture(nil, 'OVERLAY')

	local prediction = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		PostUpdate = NP.UpdateHealComm,
		maxOverflow = 1,
		health = health,
		parent = parent,
		frame = nameplate,
	}

	NP:SetAlpha_HealComm(prediction, 0)
	NP:SetFrameLevel_HealComm(prediction, (health:GetFrameLevel() or 5) + 1)
	NP:SetTexture_HealComm(prediction, E.media.blankTex)

	return prediction
end

function NP:SetSize_HealComm(nameplate)
	local health = nameplate.Health
	local pred = nameplate.HealCommBar
	if not pred then return end

	local db = NP:PlateDB(nameplate).health.healPrediction
	local width, height = health:GetSize()

	local barHeight = db.height or -1
	if barHeight == -1 or barHeight > height then barHeight = height end

	pred.myBar:SetSize(width, barHeight)
	pred.otherBar:SetSize(width, barHeight)
	pred.healAbsorbBar:SetSize(width, barHeight)
	pred.absorbBar:SetSize(width, barHeight)
	pred.overAbsorb:SetSize(8, barHeight + 4)
	pred.overHealAbsorb:SetSize(8, barHeight + 4)
	if pred.parent then pred.parent:SetSize(width * (pred.maxOverflow or 1), height) end
end

function NP:Configure_HealComm(nameplate)
	if not (nameplate.HealCommBar and nameplate.HealCommBar.absorbBar) then return end
	local db = NP:PlateDB(nameplate).health.healPrediction
	if not db then return end

	if db.enable then
		local pred = nameplate.HealCommBar
		local myBar = pred.myBar
		local otherBar = pred.otherBar
		local absorbBar = pred.absorbBar
		local healAbsorbBar = pred.healAbsorbBar
		local overAbsorb = pred.overAbsorb
		local overHealAbsorb = pred.overHealAbsorb

		pred.maxOverflow = 1 + (db.maxOverflow or 0)

		if not nameplate:IsElementEnabled('HealthPrediction') then
			nameplate:EnableElement('HealthPrediction')
		end

		local health = nameplate.Health
		local healthBarTexture = health:GetStatusBarTexture()
		local reverseFill = false

		pred.reverseFill = reverseFill
		pred.healthBarTexture = healthBarTexture
		pred.myBarTexture = myBar:GetStatusBarTexture()
		pred.otherBarTexture = otherBar:GetStatusBarTexture()

		local statusbar = LSM:Fetch('statusbar', NP.db.statusbar)
		NP:SetTexture_HealComm(pred, statusbar)

		local absorbTexture = LSM:Fetch('statusbar', db.absorbTexture or NP.db.statusbar)
		absorbBar:SetStatusBarTexture(absorbTexture)

		myBar:SetReverseFill(reverseFill)
		otherBar:SetReverseFill(reverseFill)
		healAbsorbBar:SetReverseFill(not reverseFill)

		if db.absorbStyle == 'REVERSED' then
			absorbBar:SetReverseFill(not reverseFill)
		else
			absorbBar:SetReverseFill(reverseFill)
		end
		local c = db.colors
		myBar:SetStatusBarColor(c.myBar.r, c.myBar.g, c.myBar.b, c.myBar.a)
		otherBar:SetStatusBarColor(c.otherBar.r, c.otherBar.g, c.otherBar.b, c.otherBar.a)
		absorbBar:SetStatusBarColor(c.absorbs.r, c.absorbs.g, c.absorbs.b, c.absorbs.a)
		healAbsorbBar:SetStatusBarColor(c.healAbsorbs.r, c.healAbsorbs.g, c.healAbsorbs.b, c.healAbsorbs.a)

		myBar:SetOrientation('HORIZONTAL')
		otherBar:SetOrientation('HORIZONTAL')
		absorbBar:SetOrientation('HORIZONTAL')
		healAbsorbBar:SetOrientation('HORIZONTAL')

		local anchor = db.anchorPoint or 'BOTTOM'
		local p1, p2 = 'LEFT', 'RIGHT'
		pred.anchor, pred.anchor1, pred.anchor2 = anchor, p1, p2

		myBar:ClearAllPoints()
		myBar:SetPoint(anchor, health)
		myBar:SetPoint(p1, healthBarTexture, p2)

		otherBar:ClearAllPoints()
		otherBar:SetPoint(anchor, health)
		otherBar:SetPoint(p1, pred.myBarTexture, p2)

		healAbsorbBar:ClearAllPoints()
		healAbsorbBar:SetPoint(anchor, health)

		absorbBar:ClearAllPoints()
		absorbBar:SetPoint(anchor, health)

		overAbsorb:ClearAllPoints()
		overAbsorb:SetPoint(p1, health, p2, -3, 0)

		overHealAbsorb:ClearAllPoints()
		overHealAbsorb:SetPoint(p2, health, p1, 3, 0)

		pred.parent:ClearAllPoints()
		pred.parent:SetPoint(p1, health, p1)

		if db.absorbStyle == 'REVERSED' then
			absorbBar:SetPoint(p2, healthBarTexture, p2)
		elseif db.absorbStyle == 'STACKED' then
			absorbBar:SetPoint(p1, pred.otherBarTexture, p2)
		else
			absorbBar:SetPoint(p1, healthBarTexture, p2)
		end

		NP:SetSize_HealComm(nameplate)
		NP:SetAlpha_HealComm(pred, 1)
	elseif nameplate:IsElementEnabled('HealthPrediction') then
		nameplate:DisableElement('HealthPrediction')
		NP:SetAlpha_HealComm(nameplate.HealCommBar, 0)
	end
end

function NP:UpdateHealComm(_, myIncomingHeal, otherIncomingHeal, absorb, _, hasOverAbsorb, hasOverHealAbsorb, health, maxHealth)
	local frame = self.frame
	if not frame or not health then return end
	local db = NP:PlateDB(frame).health.healPrediction
	if not db or not db.enable or not db.absorbStyle then return end

	local pred = frame.HealCommBar
	local healAbsorbBar = pred.healAbsorbBar
	local absorbBar = pred.absorbBar

	if not pred.anchor then
		NP:Configure_HealComm(frame)
	end

	NP:SetSize_HealComm(frame)

	if db.absorbStyle == 'NONE' then
		healAbsorbBar:Hide()
		absorbBar:Hide()
		return
	end

	local missingHealth = maxHealth - health
	local healthPostHeal = health + (myIncomingHeal or 0) + (otherIncomingHeal or 0)

	if not pred.anchor or not frame.Health then return end
	healAbsorbBar:ClearAllPoints()
	healAbsorbBar:SetPoint(pred.anchor, frame.Health)

	local c = db.colors
	if hasOverHealAbsorb then
		healAbsorbBar:SetReverseFill(pred.reverseFill)
		healAbsorbBar:SetPoint(pred.anchor1, pred.healthBarTexture, pred.anchor2)
		healAbsorbBar:SetStatusBarColor(c.overhealabsorbs.r, c.overhealabsorbs.g, c.overhealabsorbs.b, c.overhealabsorbs.a)
		healAbsorbBar:SetValue(missingHealth)
	else
		healAbsorbBar:SetReverseFill(not pred.reverseFill)
		healAbsorbBar:SetPoint(pred.anchor2, pred.healthBarTexture, pred.anchor2)
		healAbsorbBar:SetStatusBarColor(c.healAbsorbs.r, c.healAbsorbs.g, c.healAbsorbs.b, c.healAbsorbs.a)
	end

	if hasOverAbsorb then
		absorbBar:SetStatusBarColor(c.overabsorbs.r, c.overabsorbs.g, c.overabsorbs.b, c.overabsorbs.a)
	else
		absorbBar:SetStatusBarColor(c.absorbs.r, c.absorbs.g, c.absorbs.b, c.absorbs.a)
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
			healAbsorbBar:SetValue(health)
		end
	else
		if hasOverAbsorb then
			if db.absorbStyle == 'WRAPPED' then
				absorbBar:SetReverseFill(not pred.reverseFill)
				absorbBar:ClearAllPoints()
				absorbBar:SetPoint(pred.anchor, pred.health)
				absorbBar:SetPoint(pred.anchor2, pred.health, pred.anchor2)
			elseif db.absorbStyle == 'OVERFLOW' then
				local overflowAbsorb = absorb * (db.maxOverflow or 0)
				if health == maxHealth then
					absorbBar:SetValue(overflowAbsorb)
				else
					absorbBar:SetValue((maxHealth - health) + overflowAbsorb)
				end
			end
		elseif db.absorbStyle == 'WRAPPED' then
			absorbBar:SetReverseFill(pred.reverseFill)
			absorbBar:ClearAllPoints()
			absorbBar:SetPoint(pred.anchor, pred.health)
			absorbBar:SetPoint(pred.anchor1, pred.otherBarTexture, pred.anchor2)
		end
	end
end

function NP:Update_HealComm(nameplate)
	NP:Configure_HealComm(nameplate)
end
