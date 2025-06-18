local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_PowerCostDisplay(frame)
	local element = CreateFrame('StatusBar', nil, frame.Power)
	element:SetStatusBarTexture(E.media.blankTex)
	local level = frame.Power:GetFrameLevel()
	element:SetFrameLevel(level+3)
	element:SetMinMaxValues(0, 2)
	element:SetAllPoints()

	local barTexture = element:GetStatusBarTexture()
	barTexture:SetAlpha(0)

	element.Spark = element:CreateTexture(nil, 'OVERLAY')
	element.Spark:SetTexture(E.media.blankTex)
	element.Spark:SetVertexColor(0.9, 0.9, 0.9, 0.6)
	element.Spark:SetBlendMode('ADD')
	element.Spark:Point('RIGHT', barTexture)
	element.Spark:Point('BOTTOM')
	element.Spark:Point('TOP')
	element.Spark:Width(2)

	return element
end

function UF:Configure_PowerCostDisplay(frame)
	if frame.db.power.PowerCostDisplay then
		if not frame:IsElementEnabled('PowerCostDisplay') then
			frame:EnableElement('PowerCostDisplay')
		end

		frame.PowerCostDisplay:SetFrameStrata(frame.Power:GetFrameStrata())
		local level = frame.Power:GetFrameLevel()
		frame.PowerCostDisplay:SetFrameLevel(level+3)
		-- frame.PowerCostDisplay:OffsetFrameLevel(3, frame.Power)
	elseif frame:IsElementEnabled('PowerCostDisplay') then
		frame:DisableElement('PowerCostDisplay')
	end
end
