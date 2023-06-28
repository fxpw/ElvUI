local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

--Lua functions
--WoW API / Variables
function UF:Construct_SummonIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "OVERLAY")
	tex:Size(32);
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2);
	-- tex:InitHide();
	return tex
end

function UF:Configure_SummonIcon(frame)
	local SummonIndicator = frame.SummonIndicator
	local db = frame.db

	if (db.summonIcon.enable) then
		if not frame:IsElementEnabled("SummonIndicator") then
			frame:EnableElement("SummonIndicator")
		end

		local attachPoint = self:GetObjectAnchorPoint(frame, db.summonIcon.attachTo)
		SummonIndicator:ClearAllPoints()
		SummonIndicator:Point(db.summonIcon.attachTo, attachPoint, db.summonIcon.attachTo, db.summonIcon.xOffset, db.summonIcon.yOffset)
		SummonIndicator:Size(db.summonIcon.size)
	else
		if frame:IsElementEnabled("SummonIndicator") then
			frame:DisableElement("SummonIndicator")
		end
	end
end
