local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local ElvUF = E.oUF

local function HideIndicators(element)
	if element.TopIndicator then element.TopIndicator:Hide() end
	if element.LeftIndicator then element.LeftIndicator:Hide() end
	if element.RightIndicator then element.RightIndicator:Hide() end
	if element.Shadow then element.Shadow:Hide() end
	if element.Spark then element.Spark:Hide() end
end

local function ConfigureStyleFilterIndicators(owner, element, sf)
	local health = owner and owner.Health
	if not health then return end

	local arrowKey = sf.TargetIndicatorArrow or 'ArrowUp'
	local arrowTex = (E.Media.Arrows and E.Media.Arrows[arrowKey]) or (E.Media.Arrows and E.Media.Arrows.ArrowUp)
	local arrowSize = sf.TargetIndicatorArrowSize or 20
	local xOff = sf.TargetIndicatorArrowXOffset or 0
	local yOff = sf.TargetIndicatorArrowYOffset or 0

	if element.TopIndicator then
		element.TopIndicator:SetTexture(arrowTex)
		element.TopIndicator:SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)
		element.TopIndicator:SetSize(arrowSize, arrowSize)
		element.TopIndicator:ClearAllPoints()
		element.TopIndicator:SetPoint('BOTTOM', health, 'TOP', xOff, yOff)
	end

	if element.LeftIndicator then
		element.LeftIndicator:SetTexture(arrowTex)
		element.LeftIndicator:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)
		element.LeftIndicator:SetSize(arrowSize, arrowSize)
		element.LeftIndicator:ClearAllPoints()
		element.LeftIndicator:SetPoint('LEFT', health, 'RIGHT', xOff, yOff)
	end

	if element.RightIndicator then
		element.RightIndicator:SetTexture(arrowTex)
		element.RightIndicator:SetTexCoord(1, 1, 0, 1, 1, 0, 0, 0)
		element.RightIndicator:SetSize(arrowSize, arrowSize)
		element.RightIndicator:ClearAllPoints()
		element.RightIndicator:SetPoint('RIGHT', health, 'LEFT', -xOff, yOff)
	end
end

local function ShowIndicators(element, color)
	if element.TopIndicator and (element.style == 'style3' or element.style == 'style5' or element.style == 'style6') then
		element.TopIndicator:SetVertexColor(color.r, color.g, color.b)
		element.TopIndicator:Show()
	end

	if element.LeftIndicator and element.RightIndicator and (element.style == 'style4' or element.style == 'style7' or element.style == 'style8') then
		element.LeftIndicator:SetVertexColor(color.r, color.g, color.b)
		element.RightIndicator:SetVertexColor(color.r, color.g, color.b)
		element.RightIndicator:Show()
		element.LeftIndicator:Show()
	end

	if element.Shadow and (element.style == 'style1' or element.style == 'style5' or element.style == 'style7') then
		element.Shadow:SetBackdropBorderColor(color.r, color.g, color.b)
		element.Shadow:Show()
	end

	if element.Spark and (element.style == 'style2' or element.style == 'style6' or element.style == 'style8') then
		element.Spark:SetVertexColor(color.r, color.g, color.b)
		element.Spark:Show()
	end
end

local function Update(self)
	local element = self.TargetIndicator
	if element.PreUpdate then
		element:PreUpdate()
	end

	HideIndicators(element)

	local sf = NP:StyleFilterChanges(self)
	if not sf.ShowTargetIndicator then
		return
	end

	element.style = sf.TargetIndicatorStyle or 'style4'
	ConfigureStyleFilterIndicators(self, element, sf)

	ShowIndicators(element, NP.db.colors.glowColor)

	if element.PostUpdate then
		return element:PostUpdate(self.unit)
	end
end

local function Path(self, ...)
	return (self.TargetIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.TargetIndicator
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if element.Shadow and element.Shadow:IsObjectType('Frame') and not element.Shadow:GetBackdrop() then
			element.Shadow:SetBackdrop({edgeFile = E.Media.Textures.GlowTex, edgeSize = 5})
		end

		if element.Spark and element.Spark:IsObjectType('Texture') and not element.Spark:GetTexture() then
			element.Spark:SetTexture(E.Media.Textures.Spark)
		end

		if element.TopIndicator and element.TopIndicator:IsObjectType('Texture') and not element.TopIndicator:GetTexture() then
			element.TopIndicator:SetTexture(E.Media.Arrows.ArrowUp)
			element.TopIndicator:SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)
		end

		if element.LeftIndicator and element.LeftIndicator:IsObjectType('Texture') and not element.LeftIndicator:GetTexture() then
			element.LeftIndicator:SetTexture(E.Media.Arrows.ArrowUp)
		end

		if element.RightIndicator and element.RightIndicator:IsObjectType('Texture') and not element.RightIndicator:GetTexture() then
			element.RightIndicator:SetTexture(E.Media.Arrows.ArrowUp)
		end

		return true
	end
end

local function Disable(self)
	local element = self.TargetIndicator
	if element then
		HideIndicators(element)
	end
end

ElvUF:AddElement('TargetIndicator', Path, Enable, Disable)

local CreateFrame = CreateFrame

function NP:Construct_TargetIndicator(nameplate)
	local health = nameplate.Health
	local TI = CreateFrame('Frame', nil, nameplate)
	TI:SetAllPoints(health)

	TI.TopIndicator = TI:CreateTexture(nil, 'OVERLAY', nil, 6)
	TI.TopIndicator:SetSize(20, 20)
	TI.TopIndicator:SetPoint('BOTTOM', health, 'TOP', 0, 2)
	TI.TopIndicator:Hide()

	TI.LeftIndicator = TI:CreateTexture(nil, 'OVERLAY', nil, 6)
	TI.LeftIndicator:SetSize(20, 20)
	TI.LeftIndicator:SetPoint('RIGHT', health, 'LEFT', -2, 0)
	TI.LeftIndicator:Hide()

	TI.RightIndicator = TI:CreateTexture(nil, 'OVERLAY', nil, 6)
	TI.RightIndicator:SetSize(20, 20)
	TI.RightIndicator:SetPoint('LEFT', health, 'RIGHT', 2, 0)
	TI.RightIndicator:Hide()

	TI.Shadow = CreateFrame('Frame', nil, nameplate)
	TI.Shadow:SetPoint('TOPLEFT', health, 'TOPLEFT', -5, 5)
	TI.Shadow:SetPoint('BOTTOMRIGHT', health, 'BOTTOMRIGHT', 5, -5)
	TI.Shadow:Hide()

	TI.Spark = TI:CreateTexture(nil, 'BORDER', nil, -1)
	TI.Spark:SetAllPoints(health)
	TI.Spark:Hide()

	return TI
end

function NP:Update_TargetIndicator(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)

	if sf.ShowTargetIndicator then
		if not nameplate:IsElementEnabled('TargetIndicator') then
			nameplate:EnableElement('TargetIndicator')
		end
		nameplate.TargetIndicator:ForceUpdate()
	elseif nameplate:IsElementEnabled('TargetIndicator') then
		nameplate.TargetIndicator:ForceUpdate()
	end
end
