local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")

function NP:Update_Level(frame)
	if not self.db.units[frame.UnitType].level.enable then return end

	local levelText, r, g, b = self:UnitLevel(frame)

	local level = frame.Level
	level:ClearAllPoints()

	if NP:Health_IsVisible(frame) then
		level:SetJustifyH("RIGHT")
		level:SetPoint(E.InversePoints[self.db.units[frame.UnitType].level.position], frame.Health or frame, self.db.units[frame.UnitType].level.position, self.db.units[frame.UnitType].level.xOffset, self.db.units[frame.UnitType].level.yOffset)
		level:SetText(levelText)
	else
		if self.db.units[frame.UnitType].name.enable then
			level:SetPoint("LEFT", frame.Name, "RIGHT")
		else
			level:SetPoint("TOPLEFT", frame, "TOPRIGHT", -38, 0)
		end
		level:SetJustifyH("LEFT")
		level:SetFormattedText(" [%s]", levelText)
	end
	level:SetTextColor(r, g, b)
end

function NP:Construct_Level(frame)
	local fs = frame:CreateFontString(nil, "OVERLAY")
	fs:FontTemplate()
	return fs
end