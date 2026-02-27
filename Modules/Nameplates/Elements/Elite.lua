local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables

function NP:Update_Elite(frame)
	local db = self.db.units[frame.UnitType].eliteIcon
	if not db then return end

	local icon = frame.Elite
	if db.enable then
		local isBoss, isElite
		if C_Unit and C_Unit.GetClassification and frame.unit then
			local info = C_Unit.GetClassification(frame.unit)
			if info then
				local class = info.classification
				if class == "worldboss" then
					isBoss = true
				elseif class == "elite" or class == "rareelite" or class == "rare" then
					isElite = true
				end
			end
		end

		if not isBoss and not isElite then
			isElite, isBoss = frame.EliteIcon:IsShown(), frame.BossIcon:IsShown()
		end

		if isBoss then
			icon:SetTexCoord(0, 0.15, 0.62, 0.94)
			icon:Show()
		elseif isElite then
			icon:SetTexCoord(0, 0.15, 0.35, 0.63)
			icon:Show()
			if frame.Health:IsShown() then
				icon:ClearAllPoints();
				icon:Point(db.position, db.xOffset, db.yOffset);
			else
				icon:ClearAllPoints();
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
