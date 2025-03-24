local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

--Lua functions
-- local random = math.random
--WoW API / Variables
-- local UnitGroupRolesAssigned = UnitGroupRolesAssigned
-- local UnitIsConnected = UnitIsConnected

-- function UF:Construct_RoleIcon(frame)
-- 	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
-- 	tex:Size(17)
-- 	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)
-- 	tex.Override = UF.UpdateRoleIcon
-- 	frame:RegisterEvent("UNIT_CONNECTION", UF.UpdateRoleIcon)

-- 	return tex
-- end

-- local roleIconTextures = {
-- 	TANK = E.Media.Textures.Tank,
-- 	HEALER = E.Media.Textures.Healer,
-- 	DAMAGER = E.Media.Textures.DPS
-- }

-- function UF:UpdateRoleIcon(event)
-- 	local lfdrole = self.GroupRoleIndicator
-- 	if not self.db then return end
-- 	local db = self.db.roleIcon

-- 	if (not db) or (db and not db.enable) then
-- 		lfdrole:Hide()
-- 		return
-- 	end

-- 	local isTank, isHealer, isDamage = UnitGroupRolesAssigned(self.unit)
-- 	local role = isTank and "TANK" or isHealer and "HEALER" or isDamage and "DAMAGER" or "NONE"
-- 	if self.isForced and role == "NONE" then
-- 		local rnd = random(1, 3)
-- 		role = rnd == 1 and "TANK" or (rnd == 2 and "HEALER" or (rnd == 3 and "DAMAGER"))
-- 	end

-- --	local shouldHide = ((event == "PLAYER_REGEN_DISABLED" and db.combatHide and true) or false)

-- 	if (self.isForced or UnitIsConnected(self.unit)) and ((role == "DAMAGER" and db.damager) or (role == "HEALER" and db.healer) or (role == "TANK" and db.tank)) then
-- 		lfdrole:SetTexture(roleIconTextures[role])
-- --		if not shouldHide then
-- 			lfdrole:Show()
-- --		else
-- --			lfdrole:Hide()
-- --		end
-- 	else
-- 		lfdrole:Hide()
-- 	end
-- end

-- function UF:Configure_RoleIcon(frame)
-- 	local role = frame.GroupRoleIndicator
-- 	local db = frame.db

-- 	if db.roleIcon.enable then
-- 		frame:EnableElement("GroupRoleIndicator")
-- 		local attachPoint = self:GetObjectAnchorPoint(frame, db.roleIcon.attachTo)

-- 		role:ClearAllPoints()
-- 		role:Point(db.roleIcon.position, attachPoint, db.roleIcon.position, db.roleIcon.xOffset, db.roleIcon.yOffset)
-- 		role:Size(db.roleIcon.size)

-- 	--	if db.roleIcon.combatHide then
-- 	--		E:RegisterEventForObject("PLAYER_REGEN_ENABLED", frame, UF.UpdateRoleIcon)
-- 	--		E:RegisterEventForObject("PLAYER_REGEN_DISABLED", frame, UF.UpdateRoleIcon)
-- 	--	else
-- 	--		E:UnregisterEventForObject("PLAYER_REGEN_ENABLED", frame, UF.UpdateRoleIcon)
-- 	--		E:UnregisterEventForObject("PLAYER_REGEN_DISABLED", frame, UF.UpdateRoleIcon)
-- 	--	end
-- 	else
-- 		frame:DisableElement("GroupRoleIndicator")
-- 		role:Hide()
-- 		--Unregister combat hide events
-- 	--	E:UnregisterEventForObject("PLAYER_REGEN_ENABLED", frame, UF.UpdateRoleIcon)
-- 	--	E:UnregisterEventForObject("PLAYER_REGEN_DISABLED", frame, UF.UpdateRoleIcon)
-- 	end
-- end


local _, Engine = ...
-- local UF = E.UnitFrames


UF.rolePaths = {
	["ElvUI"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\tank]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\healer]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\dps]]
	},
	["SupervillainUI"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\Role\svui-tank]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\Role\svui-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\Role\svui-dps]]
	},
	["Blizzard"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\Role\blizz-tank]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\Role\blizz-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\Role\blizz-dps]]
	},
	["BlizzardCircle"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\Role\blizz-tank-circle]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\Role\blizz-healer-circle]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\Role\blizz-dps-circle]]
	},
	["MiirGui"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\Role\mg-tank]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\Role\mg-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\Role\mg-dps]]
	},
	["Lyn"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\Role\lyn-tank]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\Role\lyn-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\Role\lyn-dps]]
	},
	["Philmod"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\Role\philmod-tank]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\Role\philmod-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\Role\philmod-dps]]
	},
	["ReleafUI"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\Role\releaf-tank]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\Role\releaf-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\Role\releaf-dps]]
	},
	["ToxiUI"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\Role\ToxiUI-Tank]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\Role\ToxiUI-Heal]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\Role\ToxiUI-DPS]]
	},
}

local random = math.random
local UnitIsConnected = UnitIsConnected
-- local hooksecurefunc = hooksecurefunc

local GetUnitRole = Engine.Compat.GetUnitRole

-- local function dbUpdater(frame)
-- 	if frame then
-- 		local unit = frame.unitframeType
-- 		if unit then
-- 			frame.db.roleIcon = UF.db.units[unit].roleIcon
-- 		end
-- 	end
-- end

function UF:Construct_RoleIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
	tex:Size(17)
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)
	tex.Override = UF.UpdateRoleIcon
	frame:RegisterEvent("UNIT_CONNECTION", UF.UpdateRoleIcon)

	return tex
end

function UF:UpdateRoleIcon(event)
	local lfdrole = self.GroupRoleIndicator
	if not self.db then return end
	local rldb = UF.db.roleIcons
	-- for k,v in pairs(rldb) do print(k,v) end
	local db = self.db.roleIcon

	if not db or not db.enable then
		if lfdrole then
			lfdrole:Hide()
		end
		return
	end

	local role = GetUnitRole(self.unit)
	if self.isForced and role == "NONE" then
		local rnd = random(1, 3)
		role = rnd == 1 and "TANK" or (rnd == 2 and "HEALER" or (rnd == 3 and "DAMAGER"))
	end

	local shouldHide = ((event == "PLAYER_REGEN_DISABLED" and db.combatHide and true) or false)

	if (self.isForced or UnitIsConnected(self.unit)) and ((role == "DAMAGER" and db.damager) or (role == "HEALER" and db.healer) or (role == "TANK" and db.tank)) then
		lfdrole:SetTexture(UF.rolePaths[rldb.icons][role])
		if not shouldHide then
			lfdrole:Show()
		else
			lfdrole:Hide()
		end
	else
		lfdrole:Hide()
	end
end

function UF:Configure_RoleIcon(frame)
	local role = frame.GroupRoleIndicator
	local db = frame.db

	-- if not db.roleIcon then
	-- 	dbUpdater(frame)
	-- end

	if db.roleIcon.enable then
		frame:EnableElement("UnitGroupRoleIndicator")
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.roleIcon.attachTo or "Health")

		role:ClearAllPoints()
		role:Point(db.roleIcon.position or "BOTTOMRIGHT", attachPoint, db.roleIcon.position or "BOTTOMRIGHT", db.roleIcon.xOffset or 0, db.roleIcon.yOffset or 0)
		role:Size(db.roleIcon.size or 15)

		if db.roleIcon.combatHide then
			E:RegisterEventForObject("PLAYER_REGEN_ENABLED", frame, UF.UpdateRoleIcon)
			E:RegisterEventForObject("PLAYER_REGEN_DISABLED", frame, UF.UpdateRoleIcon)
		else
			E:UnregisterEventForObject("PLAYER_REGEN_ENABLED", frame, UF.UpdateRoleIcon)
			E:UnregisterEventForObject("PLAYER_REGEN_DISABLED", frame, UF.UpdateRoleIcon)
		end
	else
		frame:DisableElement("UnitGroupRoleIndicator")
		role:Hide()
		--Unregister combat hide events
		E:UnregisterEventForObject("PLAYER_REGEN_ENABLED", frame, UF.UpdateRoleIcon)
		E:UnregisterEventForObject("PLAYER_REGEN_DISABLED", frame, UF.UpdateRoleIcon)
	end
end

-- UF.Construct_RoleIcon = UF.Construct_RoleIcon
-- UF.UpdateRoleIcon = UF.UpdateRoleIcon
-- UF.Configure_RoleIcon = UF.Configure_RoleIcon

-- hooksecurefunc(UF, "Update_PlayerFrame", function(_, frame)
-- 	dbUpdater(frame)
-- 	if frame and not frame.GroupRoleIndicator then
-- 		frame.GroupRoleIndicator = UF:Construct_RoleIcon(frame)
-- 	end
-- end)
-- hooksecurefunc(UF, "Update_TargetFrame", function(_, frame)
-- 	dbUpdater(frame)
-- 	if frame and not frame.GroupRoleIndicator then
-- 		frame.GroupRoleIndicator = UF:Construct_RoleIcon(frame)
-- 	end
-- end)
-- hooksecurefunc(UF, "Update_FocusFrame", function(_, frame)
-- 	dbUpdater(frame)
-- 	if frame and not frame.GroupRoleIndicator then
-- 		frame.GroupRoleIndicator = UF:Construct_RoleIcon(frame)
-- 	end
-- end)
-- hooksecurefunc(UF, "Update_ArenaFrames", function(_, frame)
-- 	dbUpdater(frame)
-- 	if frame and not frame.GroupRoleIndicator then
-- 		frame.GroupRoleIndicator = UF:Construct_RoleIcon(frame)
-- 	end
-- end)
-- hooksecurefunc(UF, "Update_Raid40Frames", function(_, frame)
-- 	dbUpdater(frame)
-- 	if frame and not frame.GroupRoleIndicator then
-- 		frame.GroupRoleIndicator = UF:Construct_RoleIcon(frame)
-- 	end
-- end)
