local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables

function NP:Update_Elite(frame)
	local db = self.db.units[frame.UnitType].eliteIcon
	if not db then return end

	local icon = frame.Elite
	if db.enable then
		local elite, boss = frame.EliteIcon:IsShown(), frame.BossIcon:IsShown()
		-- local lengs = #frame.UnitName or 0
		if boss then
			icon:SetTexCoord(0, 0.15, 0.62, 0.94)
			icon:Show()
		elseif elite then
			icon:SetTexCoord(0, 0.15, 0.35, 0.63)
			icon:Show()
			-- local cf = frame.Name.fontSize
			-- print(cf)
			if frame.Health:IsShown() then
				icon:ClearAllPoints();
				icon:Point(db.position, db.xOffset, db.yOffset);
			else
				icon:ClearAllPoints();
				-- icon:Point("CENTER", (lengs/2)*cf*0.3, db.yOffset);
				icon:Point(db.positionh or "CENTER",db.xOffseth,db.yOffseth);
			end
		else
			icon:Hide()
		end
	else
		icon:Hide()
	end
end

-- function NP:Configure_Elite(frame)
-- 	local db = self.db.units[frame.UnitType].eliteIcon
-- 	if not db then return end
-- 	local healthPlate = frame.Health
-- 	local icon = frame.Elite
-- 	if frame.Health:IsShown() then
-- 		icon:SetParent(frame.Health or frame)
-- 	else
-- 		icon:SetParent(frame)
-- 	end
-- 	icon:Size(db.size)
-- 	icon:ClearAllPoints()
-- 	local parent = icon:GetParent()
-- 	if parent == healthPlate then
-- 		icon:Point(db.positionHealth, db.xOffset, db.yOffset)
-- 	else
-- 		icon:Point(db.positionFrame, db.xOffset, db.yOffset)
-- 	end
-- end


function NP:Configure_Elite(frame)
	local db = self.db.units[frame.UnitType].eliteIcon;
	if not db then return end

	local icon = frame.Elite;

	icon:SetParent(frame.Health:IsShown() and frame.Health or frame);
	icon:Size(db.size);
	icon:ClearAllPoints();
	icon:Point(db.position, db.xOffset, db.yOffset);
end

function NP:Construct_Elite(frame)
	local icon = frame.Health:CreateTexture(nil, "OVERLAY")
	icon:SetTexture(E.Media.Textures.Nameplates)
	icon:Hide()

	return icon
end
