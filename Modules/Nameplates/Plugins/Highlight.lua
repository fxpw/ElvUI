local E, L, V, P, G = unpack(select(2, ...))
local oUF = E.oUF
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local function Update(self)
	local element = self.Highlight

	if element.PreUpdate then
		element:PreUpdate()
	end

	local sf = NP:StyleFilterChanges(self)
	if sf.ShowMouseoverHighlight and self.isMouseover then
		local c = NP.db.colors.mouseoverHighlight or { r = 1, g = 1, b = 1, a = 0.35 }
		element.texture:SetVertexColor(c.r, c.g, c.b, c.a)
		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then
		return element:PostUpdate(element:IsShown())
	end
end

local function Path(self, ...)
	return (self.Highlight.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.Highlight
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		return true
	end
end

local function Disable(self)
	local element = self.Highlight
	if element then
		element:Hide()
	end
end

oUF:AddElement('Highlight', Path, Enable, Disable)

function NP:Construct_Highlight(nameplate)
	local Highlight = CreateFrame('Frame', nil, nameplate.Health)
	Highlight:SetAllPoints(nameplate.Health)
	Highlight:SetFrameLevel(nameplate.Health:GetFrameLevel() + 2)
	Highlight:Hide()

	local tex = Highlight:CreateTexture(nil, 'OVERLAY', nil, 7)
	tex:SetAllPoints(Highlight)
	tex:SetTexture(LSM:Fetch('statusbar', NP.db.statusbar))
	NP.StatusBars[tex] = true
	tex:SetBlendMode('ADD')
	tex:SetVertexColor(1, 1, 1, 0.35)
	Highlight.texture = tex

	return Highlight
end

function NP:Update_Highlight(nameplate)
	if not nameplate then return end

	if not nameplate:IsElementEnabled('Highlight') then
		nameplate:EnableElement('Highlight')
	elseif nameplate.Highlight then
		nameplate.Highlight:ForceUpdate()
	end
end
