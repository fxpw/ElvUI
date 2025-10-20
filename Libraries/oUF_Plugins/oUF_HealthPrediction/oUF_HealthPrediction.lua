--[[
# Element: Health Prediction Bars

Handles the visibility and updating of incoming heals and heal/damage absorbs.

## Widget

HealthPrediction - A `table` containing references to sub-widgets and options.

## Sub-Widgets

myBar			- A `StatusBar` used to represent incoming heals from the player.
otherBar		- A `StatusBar` used to represent incoming heals from others.
absorbBar		- A `StatusBar` used to represent damage absorbs.
healAbsorbBar	- A `StatusBar` used to represent heal absorbs.
overAbsorb		- A `Texture` used to signify that the amount of damage absorb is greater than the unit's missing health.
overHealAbsorb	- A `Texture` used to signify that the amount of heal absorb is greater than the unit's current health.

## Notes

A default texture will be applied to the StatusBar widgets if they don't have a texture set.
A default texture will be applied to the Texture widgets if they don't have a texture or a color set.

## Options

.maxOverflow	- The maximum amount of overflow past the end of the health bar. Set this to 1 to disable the overflow.
				  Defaults to 1.05 (number)
.lookAhead		- Classic only, the duration in seconds into the future to look for incoming healing.
				  Defaults to 5 (number)

## Examples

	-- Position and size
	local myBar = CreateFrame('StatusBar', nil, self.Health)
	myBar:SetPoint('TOP')
	myBar:SetPoint('BOTTOM')
	myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
	myBar:SetWidth(200)

	local otherBar = CreateFrame('StatusBar', nil, self.Health)
	otherBar:SetPoint('TOP')
	otherBar:SetPoint('BOTTOM')
	otherBar:SetPoint('LEFT', myBar:GetStatusBarTexture(), 'RIGHT')
	otherBar:SetWidth(200)

	local absorbBar = CreateFrame('StatusBar', nil, self.Health)
	absorbBar:SetPoint('TOP')
	absorbBar:SetPoint('BOTTOM')
	absorbBar:SetPoint('LEFT', otherBar:GetStatusBarTexture(), 'RIGHT')
	absorbBar:SetWidth(200)

	local healAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
	healAbsorbBar:SetPoint('TOP')
	healAbsorbBar:SetPoint('BOTTOM')
	healAbsorbBar:SetPoint('RIGHT', self.Health:GetStatusBarTexture())
	healAbsorbBar:SetWidth(200)
	healAbsorbBar:SetReverseFill(true)

	local overAbsorb = self.Health:CreateTexture(nil, "OVERLAY")
	overAbsorb:SetPoint('TOP')
	overAbsorb:SetPoint('BOTTOM')
	overAbsorb:SetPoint('LEFT', self.Health, 'RIGHT')
	overAbsorb:SetWidth(10)

	local overHealAbsorb = self.Health:CreateTexture(nil, "OVERLAY")
	overHealAbsorb:SetPoint('TOP')
	overHealAbsorb:SetPoint('BOTTOM')
	overHealAbsorb:SetPoint('RIGHT', self.Health, 'LEFT')
	overHealAbsorb:SetWidth(10)

	-- Register with oUF
	self.HealthPrediction = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		maxOverflow = 1.05,
	}
--]]

local _, ns = ...
local oUF = ns.oUF or oUF

local select = select

local GetTime = GetTime
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

-- local SA = LibStub("SpecializedAbsorbs-1.0")
local has_absorb_func = UnitGetTotalAbsorbs and true or false

local HealComm = LibStub("LibHealComm-4.0")

-- SA.CheckFlags = false -- for everyone/true for only groups.

local myIncomingHeal
local allIncomingHeal
local healAbsorb
local health, maxHealth
local otherIncomingHeal
local hasOverHealAbsorb
local maxOverflowHP
local unitGUID
local element
local function Update(self, event, unit, absorb)
	if self.unit ~= unit then return end

	element = self.HealCommBar

	--[[ Callback: HealthPrediction:PreUpdate(unit)
	Called before the element has been updated.

	* self - the HealthPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if element.PreUpdate then
		element:PreUpdate(unit)
	end

	unitGUID = UnitGUID(unit)
	-- local lookAhead = element.lookAhead or 5
	-- print(absorb,"---------------124")

	myIncomingHeal = (HealComm:GetHealAmount(unitGUID, HealComm.ALL_HEALS, nil--[[GetTime() + lookAhead]], UnitGUID("player")) or 0) * ((HealComm:GetHealModifier(unitGUID) or 1) or 0)
	allIncomingHeal = (HealComm:GetHealAmount(unitGUID, HealComm.ALL_HEALS, nil--[[GetTime() + lookAhead]]) or 0) * ((HealComm:GetHealModifier(unitGUID) or 1) or 0)
	local abs = UnitGetTotalAbsorbs(unit) or 0
	local abs2 = UnitGetTotalHealAbsorbs(unit) or 0
	absorb = absorb or abs or 0
	healAbsorb = abs2 or 0
	health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	otherIncomingHeal = 0
	hasOverHealAbsorb = false
	maxOverflowHP = maxHealth * element.maxOverflow

	if healAbsorb > allIncomingHeal then
		healAbsorb = healAbsorb - allIncomingHeal
		allIncomingHeal = 0
		myIncomingHeal = 0

		if health < healAbsorb then
			hasOverHealAbsorb = true
		end
	else
		allIncomingHeal = allIncomingHeal - healAbsorb
		healAbsorb = 0

		if health + allIncomingHeal > maxOverflowHP then
			allIncomingHeal = maxOverflowHP - health
		end

		if allIncomingHeal < myIncomingHeal then
			myIncomingHeal = allIncomingHeal
		else
			otherIncomingHeal = allIncomingHeal - myIncomingHeal
		end
	end

	local hasOverAbsorb = false
	if health + allIncomingHeal + absorb >= maxHealth and absorb > 0 then
		hasOverAbsorb = true
	end

	if element.myBar then
		element.myBar:SetMinMaxValues(0, maxHealth)
		element.myBar:SetValue(myIncomingHeal)
		element.myBar:Show()
	end

	if element.otherBar then
		element.otherBar:SetMinMaxValues(0, maxHealth)
		element.otherBar:SetValue(otherIncomingHeal)
		element.otherBar:Show()
	end

	if element.absorbBar then
		element.absorbBar:SetMinMaxValues(0, maxHealth)
		element.absorbBar:SetValue(absorb)
		element.absorbBar:Show()
	end

	if element.healAbsorbBar then
		element.healAbsorbBar:SetMinMaxValues(0, maxHealth)
		element.healAbsorbBar:SetValue(healAbsorb)
		element.healAbsorbBar:Show()
	end

	if element.overAbsorb then
		if hasOverAbsorb then
			element.overAbsorb:Show()
		else
			element.overAbsorb:Hide()
		end
	end

	if element.overHealAbsorb then
		if hasOverHealAbsorb then
			element.overHealAbsorb:Show()
		else
			element.overHealAbsorb:Hide()
		end
	end
	--[[ Callback: HealthPrediction:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
	Called after the element has been updated.

	* self              - the HealthPrediction element
	* unit              - the unit for which the update has been triggered (string)
	* myIncomingHeal    - the amount of incoming healing done by the player (number)
	* otherIncomingHeal - the amount of incoming healing done by others (number)
	* absorb            - the amount of damage the unit can absorb without losing health (number)
	* healAbsorb        - the amount of healing the unit can absorb without gaining health (number)
	* hasOverAbsorb     - indicates if the amount of damage absorb is higher than the unit's missing health (boolean)
	* hasOverHealAbsorb - indicates if the amount of heal absorb is higher than the unit's current health (boolean)
	--]]
	if element.PostUpdate then
		-- print(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb, health, maxHealth)
		return element:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb, health, maxHealth)
	end
end

local function Path(self, ...)
	--[[ Override: HealthPrediction.Override(self, event, unit)
	Used to completely override the internal update function.

	* self	- the parent object
	* event - the event triggering the update (string)
	* unit	- the unit accompanying the event
	--]]
	return (self.HealCommBar.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.HealCommBar
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.healType = element.healType or HealComm.ALL_HEALS

		self:RegisterEvent("UNIT_HEALTH", Path)
		self:RegisterEvent("UNIT_HEALTH", Path)
		self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", Path)


		local function HealCommUpdate(...)
			if self.HealCommBar and self:IsVisible() then
				for i = 1, select('#', ...) do
					if self.unit and UnitGUID(self.unit) == select(i, ...) then
						Path(self, nil, self.unit)
					end
				end
			end
		end

		local function HealComm_Heal_Update(event, casterGUID, spellID, healType, _, ...)
			HealCommUpdate(...)
		end

		local function HealComm_Modified(event, guid)
			HealCommUpdate(guid)
		end

		-- local function UNIT_ABSORB_AMOUNT_CHANGED(_, event, guid, absorb)
		-- 	if UnitGUID(self.unit) == guid then
		-- 		Path(self, event, self.unit, absorb)
		-- 	end
		-- end

		HealComm.RegisterCallback(element, "HealComm_HealStarted", HealComm_Heal_Update)
		HealComm.RegisterCallback(element, "HealComm_HealUpdated", HealComm_Heal_Update)
		HealComm.RegisterCallback(element, "HealComm_HealDelayed", HealComm_Heal_Update)
		HealComm.RegisterCallback(element, "HealComm_HealStopped", HealComm_Heal_Update)
		HealComm.RegisterCallback(element, "HealComm_ModifierChanged", HealComm_Modified)
		HealComm.RegisterCallback(element, "HealComm_GUIDDisappeared", HealComm_Modified)
		-- self.UNIT_ABSORB_AMOUNT_CHANGED = UNIT_ABSORB_AMOUNT_CHANGED

		if not element.maxOverflow then
			element.maxOverflow = 1.05
		end

		--[[if not element.lookAhead then
			element.lookAhead = 5
		end]]

		if element.myBar  then
			if element.myBar:IsObjectType("StatusBar") and not element.myBar:GetStatusBarTexture() then
				element.myBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if element.otherBar then
			if element.otherBar:IsObjectType("StatusBar") and not element.otherBar:GetStatusBarTexture() then
				element.otherBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if element.absorbBar then
			if element.absorbBar:IsObjectType("StatusBar") and not element.absorbBar:GetStatusBarTexture() then
				element.absorbBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if element.healAbsorbBar then
			if element.healAbsorbBar:IsObjectType("StatusBar") and not element.healAbsorbBar:GetStatusBarTexture() then
				element.healAbsorbBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if element.overAbsorb then
			if element.overAbsorb:IsObjectType("Texture") and not element.overAbsorb:GetTexture() then
				element.overAbsorb:SetTexture([[Interface\AddOns\ElvUI\Media\Textures\RaidFrame\Shield-Overshield]])
				element.overAbsorb:SetBlendMode("ADD")
			end
		end

		if element.overHealAbsorb then
			if element.overHealAbsorb:IsObjectType("Texture") and not element.overHealAbsorb:GetTexture() then
				element.overHealAbsorb:SetTexture([[Interface\AddOns\ElvUI\Media\Textures\RaidFrame\Absorb-Overabsorb]])
				element.overHealAbsorb:SetBlendMode("ADD")
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.HealCommBar
	if element then
		if element.myBar then
			element.myBar:Hide()
		end

		if element.otherBar then
			element.otherBar:Hide()
		end

		if element.absorbBar then
			element.absorbBar:Hide()
		end

		if element.healAbsorbBar then
			element.healAbsorbBar:Hide()
		end

		if element.overAbsorb then
			element.overAbsorb:Hide()
		end

		if element.overHealAbsorb then
			element.overHealAbsorb:Hide()
		end

		self:UnregisterEvent("UNIT_HEALTH", Path)
		self:UnregisterEvent("UNIT_MAXHEALTH", Path)
		self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", Path)

		HealComm.UnregisterCallback(element, "HealComm_HealStarted")
		HealComm.UnregisterCallback(element, "HealComm_HealUpdated")
		HealComm.UnregisterCallback(element, "HealComm_HealDelayed")
		HealComm.UnregisterCallback(element, "HealComm_HealStopped")
		HealComm.UnregisterCallback(element, "HealComm_ModifierChanged")
		HealComm.UnregisterCallback(element, "HealComm_GUIDDisappeared")
		-- self.UNIT_ABSORB_AMOUNT_CHANGED = nil
	end
end

oUF:AddElement("HealthPrediction", Path, Enable, Disable)