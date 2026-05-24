local E, L, V, P, G = unpack(select(2, ...))
local oUF = E.oUF

-- WotLK: no SetAtlas, use texture coords instead
-- Texture: Interface\TARGETINGFRAME\Nameplates contains elite/rare icons
-- TexCoords for gold elite star: approximate values
local EliteTexCoords      = {0, 0.5, 0, 0.5}  -- gold star (elite/worldboss)
local RareTexCoords       = {0.5, 1, 0, 0.5}  -- silver star (rare/rareelite)

local function Update(self)
	local element = self.ClassificationIndicator

	if element.PreUpdate then
		element:PreUpdate()
	end

	local classification = self.classification
	if classification == 'elite' or classification == 'worldboss' then
		element:SetTexCoord(unpack(EliteTexCoords))
		element:Show()
	elseif classification == 'rareelite' or classification == 'rare' then
		element:SetTexCoord(unpack(RareTexCoords))
		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then
		return element:PostUpdate(classification)
	end
end

local function Path(self, ...)
	return (self.ClassificationIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.ClassificationIndicator
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if element:IsObjectType('Texture') and not element:GetTexture() then
			element:SetTexture([[Interface\TARGETINGFRAME\Nameplates]])
		end

		self:RegisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)

		return true
	end
end

local function Disable(self)
	local element = self.ClassificationIndicator
	if element then
		element:Hide()

		self:UnregisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
	end
end

oUF:AddElement('ClassificationIndicator', Path, Enable, Disable)

local NP = E:GetModule('NamePlates')

function NP:Construct_ClassificationIndicator(parent)
	local CI = parent:CreateTexture(nil, 'OVERLAY', nil, 5)
	CI:SetSize(16, 16)
	CI:Hide()
	return CI
end

function NP:Update_ClassificationIndicator(nameplate)
	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)

	if db.eliteIcon and db.eliteIcon.enable then
		if not nameplate:IsElementEnabled('ClassificationIndicator') then
			nameplate:EnableElement('ClassificationIndicator')
		end

		local size = db.eliteIcon.size or 16
		nameplate.ClassificationIndicator:SetSize(size, size)

		if not (db.nameOnly or sf.NameOnly) then
			nameplate.ClassificationIndicator:ClearAllPoints()
			nameplate.ClassificationIndicator:SetPoint(
				E.InversePoints[db.eliteIcon.position],
				nameplate, db.eliteIcon.position,
				db.eliteIcon.xOffset, db.eliteIcon.yOffset
			)
		end
	elseif nameplate:IsElementEnabled('ClassificationIndicator') then
		nameplate:DisableElement('ClassificationIndicator')
	end
end
