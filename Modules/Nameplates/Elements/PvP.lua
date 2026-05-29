local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')

function NP:Construct_PvPIndicator(nameplate)
	local PvPIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	return PvPIndicator
end

function NP:Update_PvPIndicator(nameplate)
	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)
	local pvpDB = db.pvpindicator

	if pvpDB and pvpDB.enable and not (db.nameOnly or sf.NameOnly) then
		if not nameplate:IsElementEnabled('PvPIndicator') then
			nameplate:EnableElement('PvPIndicator')
		end

		local size = pvpDB.size or 24
		local position = pvpDB.position or 'RIGHT'

		nameplate.PvPIndicator:Size(size, size)
		nameplate.PvPIndicator:ClearAllPoints()
		nameplate.PvPIndicator:Point(E.InversePoints[position], nameplate, position, pvpDB.xOffset or 0, pvpDB.yOffset or 0)
	elseif nameplate:IsElementEnabled('PvPIndicator') then
		nameplate:DisableElement('PvPIndicator')
	end
end
