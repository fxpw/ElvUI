local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--Lua functions
local _G = _G
local floor = math.floor
local min = min
--WoW API / Variables
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown

local NAMEPLATE_UF_COUNT = 40

local NameplateHeader = CreateFrame("Frame", "NameplateHeader", UIParent)
NameplateHeader:SetFrameStrata("LOW")

local DIRECTION_TO_GROUP_ANCHOR_POINT = {
	DOWN_RIGHT = "TOPLEFT",
	DOWN_LEFT = "TOPRIGHT",
	UP_RIGHT = "BOTTOMLEFT",
	UP_LEFT = "BOTTOMRIGHT",
	RIGHT_DOWN = "TOPLEFT",
	RIGHT_UP = "BOTTOMLEFT",
	LEFT_DOWN = "TOPRIGHT",
	LEFT_UP = "BOTTOMRIGHT",
}

local HORIZONTAL_PRIMARY = {
	RIGHT_DOWN = true,
	RIGHT_UP = true,
	LEFT_DOWN = true,
	LEFT_UP = true,
}

local function PositionNameplateFrame(frame, db)
	local index = frame.index
	local perRow = db.groupsPerRowCol or 8
	local hSpace = db.horizontalSpacing or 0
	local vSpace = db.verticalSpacing or 0
	local direction = db.growthDirection or "RIGHT_DOWN"
	local col = (index - 1) % perRow

	frame:ClearAllPoints()

	if index == 1 then
		local point = DIRECTION_TO_GROUP_ANCHOR_POINT[direction] or "TOPLEFT"
		frame:Point(point, NameplateHeaderMover, point)
		return
	end

	if col == 0 then
		local above = _G["ElvUF_Nameplate"..(index - perRow)]
		if HORIZONTAL_PRIMARY[direction] then
			if direction == "RIGHT_DOWN" or direction == "LEFT_DOWN" then
				frame:Point("TOP", above, "BOTTOM", 0, -vSpace)
			else
				frame:Point("BOTTOM", above, "TOP", 0, vSpace)
			end
		elseif direction == "DOWN_RIGHT" or direction == "UP_RIGHT" then
			frame:Point("LEFT", above, "RIGHT", hSpace, 0)
		else
			frame:Point("RIGHT", above, "LEFT", -hSpace, 0)
		end
	else
		local prev = _G["ElvUF_Nameplate"..(index - 1)]
		if HORIZONTAL_PRIMARY[direction] then
			if direction == "RIGHT_DOWN" or direction == "RIGHT_UP" then
				frame:Point("LEFT", prev, "RIGHT", hSpace, 0)
			else
				frame:Point("RIGHT", prev, "LEFT", -hSpace, 0)
			end
		elseif direction == "DOWN_RIGHT" or direction == "DOWN_LEFT" then
			frame:Point("TOP", prev, "BOTTOM", 0, -vSpace)
		else
			frame:Point("BOTTOM", prev, "TOP", 0, vSpace)
		end
	end
end

function UF:UpdateAllNameplateFrames()
	if InCombatLockdown() then return end

	for i = 1, NAMEPLATE_UF_COUNT do
		local frame = self["nameplate"..i]
		if frame and frame:IsShown() and frame.Update then
			frame:Update()
		end
	end
end

function UF:RegisterNameplateUFEvents()
	if NameplateHeader.eventsRegistered then return end
	NameplateHeader.eventsRegistered = true

	NameplateHeader:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	NameplateHeader:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	NameplateHeader:RegisterEvent("PLAYER_ENTERING_WORLD")
	NameplateHeader:SetScript("OnEvent", function()
		UF:UpdateAllNameplateFrames()
	end)
end

function UF:EnsureNameplateHeaderMover()
	local db = self.db and self.db.units and self.db.units.nameplate
	if not db then return end

	local perRow = db.groupsPerRowCol or 8
	local cols = min(perRow, NAMEPLATE_UF_COUNT)
	local rows = floor((NAMEPLATE_UF_COUNT - 1) / perRow) + 1
	local hSpace = db.horizontalSpacing or 0
	local vSpace = db.verticalSpacing or 0

	NameplateHeader:ClearAllPoints()
	NameplateHeader:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 248)
	NameplateHeader:Width(cols * db.width + (cols - 1) * hSpace)
	NameplateHeader:Height(rows * db.height + (rows - 1) * vSpace)

	E:CreateMover(NameplateHeader, NameplateHeader:GetName().."Mover", L["Nameplate Frames"], nil, nil, nil, "ALL", nil, "unitframe,nameplate,generalGroup")
end

function UF:Update_NameplateHeader(db)
	NameplateHeader.db = db

	if db.enable then
		NameplateHeader:Show()
	else
		NameplateHeader:Hide()
	end
end

function UF:Construct_NameplateFrames(frame)
	frame.RaisedElementParent = CreateFrame("Frame", nil, frame)
	frame.RaisedElementParent.TextureParent = CreateFrame("Frame", nil, frame.RaisedElementParent)
	frame.RaisedElementParent:SetFrameLevel(frame:GetFrameLevel() + 100)

	frame.Health = UF:Construct_HealthBar(frame, true, true, "RIGHT")

	frame.Power = UF:Construct_PowerBar(frame, true, true, "LEFT")
	frame.Power.frequentUpdates = false

	frame.Portrait3D = UF:Construct_Portrait(frame, "model")
	frame.Portrait2D = UF:Construct_Portrait(frame, "texture")

	frame.Name = UF:Construct_NameText(frame)
	frame.Buffs = UF:Construct_Buffs(frame)
	frame.Debuffs = UF:Construct_Debuffs(frame)
	frame.AuraWatch = UF:Construct_AuraWatch(frame)
	frame.RaidDebuffs = UF:Construct_RaidDebuffs(frame)
	frame.DebuffHighlight = UF:Construct_DebuffHighlight(frame)
	frame.ResurrectIndicator = UF:Construct_ResurrectionIcon(frame)
	frame.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(frame)
	frame.MouseGlow = UF:Construct_MouseGlow(frame)
	frame.TargetGlow = UF:Construct_TargetGlow(frame)

	frame.ThreatIndicator = UF:Construct_Threat(frame)
	frame.GroupRoleIndicator = UF:Construct_RoleIcon(frame)
	frame.RaidTargetIndicator = UF:Construct_RaidIcon(frame)
	frame.ReadyCheckIndicator = UF:Construct_ReadyCheckIcon(frame)
	frame.SummonIndicator = UF:Construct_SummonIcon(frame)
	frame.HealCommBar = UF:Construct_HealComm(frame)
	frame.GPS = UF:Construct_GPS(frame)
	frame.Fader = UF:Construct_Fader()
	frame.Cutaway = UF:Construct_Cutaway(frame)
	frame.PowerCostDisplay = UF:Construct_PowerCostDisplay(frame)

	frame.customTexts = {}
	frame.InfoPanel = UF:Construct_InfoPanel(frame)

	frame.unitframeType = "nameplate"
	UF:EnsureNameplateHeaderMover()
	frame.mover = NameplateHeader.mover
end

function UF:Update_NameplateFrames(frame, db)
	if not db then
		db = frame.db
	else
		frame.db = db
	end

	frame.Portrait = frame.Portrait or (db.portrait.style == "2D" and frame.Portrait2D or frame.Portrait3D)
	frame.colors = ElvUF.colors
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp")

	do
		if self.thinBorders then
			frame.SPACING = 0
			frame.BORDER = E.mult
		else
			frame.BORDER = E.Border
			frame.SPACING = E.Spacing
		end
		frame.SHADOW_SPACING = 3

		frame.ORIENTATION = db.orientation

		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height

		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == "inset" and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == "spaced" and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width

		frame.CLASSBAR_YOFFSET = 0
		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

		frame.VARIABLES_SET = true
	end

	if not InCombatLockdown() then
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	else
		frame:SetAttribute("initial-width", frame.UNIT_WIDTH)
		frame:SetAttribute("initial-height", frame.UNIT_HEIGHT)
	end

	if frame.index == 1 then
		UF:Update_NameplateHeader(db)
	end

	UF:Configure_InfoPanel(frame)
	UF:Configure_HealthBar(frame)
	UF:UpdateNameSettings(frame)
	UF:Configure_Power(frame)
	UF:Configure_Portrait(frame)
	UF:Configure_Threat(frame)
	UF:EnableDisable_Auras(frame)
	UF:Configure_Auras(frame, "Buffs")
	UF:Configure_Auras(frame, "Debuffs")
	UF:Configure_RaidDebuffs(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_ResurrectionIcon(frame)
	UF:Configure_DebuffHighlight(frame)
	UF:Configure_HealComm(frame)
	UF:Configure_GPS(frame)
	UF:Configure_RoleIcon(frame)
	UF:Configure_RaidRoleIcons(frame)
	UF:Configure_Fader(frame)
	UF:Configure_Cutaway(frame)
	UF:UpdateAuraWatch(frame)
	UF:Configure_ReadyCheckIcon(frame)
	UF:Configure_SummonIcon(frame)
	UF:Configure_CustomTexts(frame)
	UF:Configure_PowerCostDisplay(frame)

	PositionNameplateFrame(frame, db)

	if frame.index == NAMEPLATE_UF_COUNT then
		local perRow = db.groupsPerRowCol or 8
		local hSpace = db.horizontalSpacing or 0
		local vSpace = db.verticalSpacing or 0
		local cols = min(perRow, NAMEPLATE_UF_COUNT)
		local rows = floor((NAMEPLATE_UF_COUNT - 1) / perRow) + 1

		NameplateHeader:Width(cols * frame.UNIT_WIDTH + (cols - 1) * hSpace)
		NameplateHeader:Height(rows * frame.UNIT_HEIGHT + (rows - 1) * vSpace)
	end

	frame.mover = NameplateHeader.mover
	frame:UpdateAllElements("ForceUpdate")
end

UF.unitgroupstoload.nameplate = {NAMEPLATE_UF_COUNT}
