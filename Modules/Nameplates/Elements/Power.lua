local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local unpack = unpack
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapped = UnitIsTapped
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local CreateFrame = CreateFrame
local UnitPowerType = UnitPowerType

function NP:Power_UpdateColor(_, unit)
	if self.unit ~= unit then return end

	local element = self.Power
	local ptype, ptoken = UnitPowerType(unit)
	element.token = ptoken

	local sf = NP:StyleFilterChanges(self)
	if sf.PowerColor then return end

	local r, g, b, t
	if element.colorDisconnected and not UnitIsConnected(unit) then
		t = self.colors.disconnected
	elseif element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapped(unit) then
		t = self.colors.tapped
	elseif element.colorPower then
		t = NP.db.colors.power and NP.db.colors.power[ptoken or ptype]
	elseif (element.colorClass and self.isPlayer) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif element.colorReaction and UnitReaction(unit, 'player') then
		local reaction = UnitReaction(unit, 'player')
		t = NP.db.colors.reactions[reaction == 4 and 'neutral' or reaction <= 3 and 'bad' or 'good']
	end

	if t then
		r, g, b = t[1] or t.r, t[2] or t.g, t[3] or t.b
	end

	if b then
		element:SetStatusBarColor(r, g, b)
	end

	if element.bg and b then
		element.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier)
	end

	if element.PostUpdateColor then
		element:PostUpdateColor(unit, r, g, b)
	end
end

function NP:Power_PostUpdate(_, cur)
	local db = NP:PlateDB(self.__owner)
	if not db.enable then return end

	if db.power and db.power.enable and db.power.hideWhenEmpty and (cur == 0) then
		self:Hide()
	else
		self:Show()
	end
end

function NP:Construct_Power(nameplate)
	local Power = CreateFrame('StatusBar', nameplate:GetName()..'Power', nameplate)
	do local s = nameplate:GetFrameStrata() if s ~= 'UNKNOWN' then Power:SetFrameStrata(s) end end
	Power:SetFrameLevel(5)
	Power:CreateBackdrop('Transparent', nil, nil, nil, nil, true, true)

	NP.StatusBars[Power] = true

	Power.frequentUpdates = true
	Power.colorTapping = false
	Power.colorClass = false
	Power.colorPower = true

	Power.PostUpdate = NP.Power_PostUpdate
	Power.UpdateColor = NP.Power_UpdateColor

	return Power
end

function NP:Update_Power(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.power and db.power.enable then
		if not nameplate:IsElementEnabled('Power') then
			nameplate:EnableElement('Power')
		end

		nameplate.Power:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
		nameplate.Power:Point('CENTER', nameplate, 'CENTER', db.power.xOffset or 0, db.power.yOffset or 0)

		E:SetSmoothing(nameplate.Power, NP.db.smoothbars)
	elseif nameplate:IsElementEnabled('Power') then
		nameplate:DisableElement('Power')
	end

	nameplate.Power.colorClass = db.power and db.power.useClassColor
	nameplate.Power.colorPower = not (db.power and db.power.useClassColor)
	nameplate.Power.width = db.power and db.power.width
	nameplate.Power.height = db.power and db.power.height
	if db.power then
		nameplate.Power:Size(db.power.width, db.power.height)
	end
end
