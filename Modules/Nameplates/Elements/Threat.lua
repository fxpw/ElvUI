local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')

local UnitName = UnitName
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsTapped = UnitIsTapped
local GetPartyAssignment = GetPartyAssignment

-- WotLK: no E.myrole, use GetPartyAssignment instead
local function IsTank(unit)
	return GetPartyAssignment('MAINTANK', unit or 'player') ~= nil
end

function NP:ThreatIndicator_PreUpdate(unit)
	if not unit then return end
	local nameplate, db, unitTarget = self.__owner, NP.db.threat, unit..'target'
	local imTank = IsTank('player')
	local unitRole = NP.IsInGroup and (UnitExists(unitTarget) and not UnitIsUnit(unitTarget, 'player')) and NP.GroupRoles[UnitName(unitTarget)] or 'NONE'
	local unitTank = unitRole == 'TANK'
	local isTank = unitTank or imTank
	local offTank = db.beingTankedByTank and (unitTank and imTank) or false
	local feedbackUnit = (unitTank and unitTarget) or 'player'

	nameplate.ThreatScale = nil

	self.feedbackUnit = feedbackUnit
	self.offTank = offTank
	self.isTank = isTank
end

function NP:ThreatIndicator_PostUpdate(unit, status)
	local nameplate, colors, db = self.__owner, NP.db.colors.threat, NP.db.threat
	local sf = NP:StyleFilterChanges(nameplate)
	if not status and not sf.Scale then
		nameplate.ThreatStatus = nil -- clear so Health_UpdateColor runs normally next cycle
		nameplate.ThreatScale = 1
		NP:ScalePlate(nameplate, 1)
		-- threat dropped: re-enable the standard color flags (disabled on threat) and recolor now
		NP:Health_SetColors(nameplate)
		if nameplate.Health and nameplate.Health.ForceUpdate then
			nameplate.Health:ForceUpdate()
		end
	elseif status and db.enable and db.useThreatColor and not (unit and UnitIsTapped(unit)) then
		NP:Health_SetColors(nameplate, true)
		nameplate.ThreatStatus = status

		local Color, Scale
		if status == 3 then -- securely tanking
			Color = self.offTank and colors.offTankColor or self.isTank and colors.goodColor or colors.badColor
			Scale = self.isTank and db.goodScale or db.badScale
		elseif status == 2 then -- insecurely tanking
			Color = self.offTank and colors.offTankColorBadTransition or self.isTank and colors.badTransition or colors.goodTransition
			Scale = 1
		elseif status == 1 then -- not tanking but threat higher than tank
			Color = self.offTank and colors.offTankColorGoodTransition or self.isTank and colors.goodTransition or colors.badTransition
			Scale = 1
		else -- not tanking at all
			Color = self.isTank and colors.badColor or colors.goodColor
			Scale = self.isTank and db.badScale or db.goodScale
		end

		local sf2 = NP:StyleFilterChanges(nameplate)
		if sf2.HealthColor then
			self.r, self.g, self.b = Color.r, Color.g, Color.b
		else
			nameplate.Health:SetStatusBarColor(Color.r, Color.g, Color.b)
		end

		if Scale then
			nameplate.ThreatScale = Scale

			if not sf.Scale then
				NP:ScalePlate(nameplate, Scale)
			end
		end
	end
end

function NP:Construct_ThreatIndicator(nameplate)
	local ThreatIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	ThreatIndicator:Size(16, 16)
	ThreatIndicator:Hide()
	ThreatIndicator:Point('CENTER', nameplate, 'TOPRIGHT')
	ThreatIndicator:SetTexture(E.Media.Textures.SkullIcon)

	ThreatIndicator.PreUpdate = NP.ThreatIndicator_PreUpdate
	ThreatIndicator.PostUpdate = NP.ThreatIndicator_PostUpdate

	return ThreatIndicator
end

function NP:Update_ThreatIndicator(nameplate)
	local db = NP.db.threat
	local plateDB = NP:PlateDB(nameplate)
	if nameplate.frameType == 'ENEMY_NPC' and db.enable and not plateDB.nameOnly then
		if not nameplate:IsElementEnabled('ThreatIndicator') then
			nameplate:EnableElement('ThreatIndicator')
		end

		if db.indicator then
			nameplate.ThreatIndicator:SetAlpha(1)
		else
			nameplate.ThreatIndicator:SetAlpha(0)
		end
	elseif nameplate:IsElementEnabled('ThreatIndicator') then
		nameplate:DisableElement('ThreatIndicator')
	end
end
