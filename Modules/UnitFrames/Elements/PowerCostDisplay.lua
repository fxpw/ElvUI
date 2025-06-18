local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_PowerCostDisplay(frame)
	local element = CreateFrame('StatusBar', nil, frame.Power)
	element:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
	element:SetFrameLevel(frame.Power:GetFrameLevel()+4)
	element:SetMinMaxValues(0, 2)
	element:SetAllPoints()
	element:Hide()
	local barTexture = element:GetStatusBarTexture()
	barTexture:SetAlpha(0.3)

	return element
end

function UF:Configure_PowerCostDisplay(frame)
	if frame.db.power.PowerCostDisplay then
		if not frame:IsElementEnabled('PowerCostDisplay') then
			frame:EnableElement('PowerCostDisplay')
		end
		frame.PowerCostDisplay.unit = frame.unit

		frame.PowerCostDisplay:SetFrameStrata(frame.Power:GetFrameStrata())
		local level = frame.Power:GetFrameLevel()
		frame.PowerCostDisplay:SetFrameLevel(level+4)
		frame.PowerCostDisplay:Show()
	elseif frame:IsElementEnabled('PowerCostDisplay') then
		frame:DisableElement('PowerCostDisplay')
		frame.PowerCostDisplay:Hide()
	end
end
