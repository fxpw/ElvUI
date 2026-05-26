local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')

function NP:Construct_PvPIndicator(nameplate)
	local PvPIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	return PvPIndicator
end

function NP:Update_PvPIndicator(nameplate)
	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)

	if db.pvpindicator and db.pvpindicator.enable and not (db.nameOnly or sf.NameOnly) then
		if not nameplate:IsElementEnabled('PvPIndicator') then
			nameplate:EnableElement('PvPIndicator')
		end

		nameplate.PvPIndicator:Size(db.pvpindicator.size, db.pvpindicator.size)

		nameplate.PvPIndicator:ClearAllPoints()
		nameplate.PvPIndicator:Point(E.InversePoints[db.pvpindicator.position], nameplate, db.pvpindicator.position, db.pvpindicator.xOffset, db.pvpindicator.yOffset)
	elseif nameplate:IsElementEnabled('PvPIndicator') then
		nameplate:DisableElement('PvPIndicator')
	end
end
