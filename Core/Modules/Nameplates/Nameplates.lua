local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM
local LAI = E.Libs.LAI
local ElvUF = E.oUF

--Lua functions
local _G = _G
local pcall = pcall
local type = type
local select, unpack, pairs, next, tonumber = select, unpack, pairs, next, tonumber
local floor, random = math.floor, math.random
local format, gsub, match, split = string.format, string.gsub, string.match, string.split
local twipe = table.wipe
--WoW API / Variables
local CreateFrame = CreateFrame
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitHealthMax = UnitHealthMax
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction
local UnitName = UnitName
local WorldFrame = WorldFrame
local WorldGetChildren = WorldFrame.GetChildren
local WorldGetNumChildren = WorldFrame.GetNumChildren

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local lastChildern, numChildren, hasTarget = 0, 0
local OVERLAY = [=[Interface\TargetingFrame\UI-TargetingFrame-Flash]=]
local FSPAT = "%s*"..(gsub(gsub(_G.FOREIGN_SERVER_LABEL, "^%s", ""), "[%*()]", "%%%1")).."$"

local RaidIconCoordinate = {
	[0] = {[0] = "STAR", [0.25] = "MOON"},
	[0.25] = {[0] = "CIRCLE", [0.25] = "SQUARE"},
	[0.5] = {[0] = "DIAMOND", [0.25] = "CROSS"},
	[0.75] = {[0] = "TRIANGLE", [0.25] = "SKULL"}
}

NP.CreatedPlates = {}
NP.VisiblePlates = {}
NP.Healers = {}

NP.GUIDList = {}

NP.UnitByName = {}
NP.NameByUnit = {}
NP.ENEMY_PLAYER = {}
NP.FRIENDLY_PLAYER = {}
NP.ENEMY_NPC = {}
NP.FRIENDLY_NPC = {}

NP.ResizeQueue = {}

NP.Totems = {}
NP.UniqueUnits = {}

function NP:CheckBGHealers()
	local name, _, classToken, damageDone, healingDone
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, classToken, damageDone, healingDone = GetBattlefieldScore(i)
		if name and classToken and E.HealingClasses[classToken] then
			name = match(name, "([^%-]+).*")
			if name and healingDone > (damageDone * 2) then
				NP.Healers[name] = true
			elseif name and NP.Healers[name] then
				NP.Healers[name] = nil
			end
		end
	end
end

function NP:SetFrameScale(frame, scale, noPlayAnimation)
	if frame.currentScale ~= scale then
		NP:Configure_HealthBarScale(frame, scale, noPlayAnimation)
		NP:Configure_CastBarScale(frame, scale, noPlayAnimation)
		NP:Configure_CPointsScale(frame, scale, noPlayAnimation)
		frame.currentScale = scale
	end
end

function NP:GetPlateFrameLevel(frame)
	local plateLevel
	if frame.plateID then
		plateLevel = 10 + frame.plateID*NP.levelStep
	end
	return plateLevel
end

function NP:SetPlateFrameLevel(frame, level, isTarget)
	if frame and level then
		if isTarget then
			level = 890 --10 higher than the max calculated level of 880
		elseif frame.FrameLevelChanged then
			--calculate Style Filter FrameLevelChanged leveling
			--level method: (10*(40*2)) max 800 + max 80 (40*2) = max 880
			--highest possible should be level 880 and we add 1 to all so 881
			local leveledCount = NP.CollectedFrameLevelCount or 1
			level = (frame.FrameLevelChanged*(40*NP.levelStep)) + (leveledCount*NP.levelStep)
		end

		frame:SetFrameLevel(level+1)
--		frame.Glow:OffsetFrameLevel(-1, frame)
		frame.Shadow:OffsetFrameLevel(-1, frame)
		frame.Buffs:SetFrameLevel(level+1)
		frame.Debuffs:SetFrameLevel(level+1)
	end
end

function NP:ResetNameplateFrameLevel(frame)
	local isTarget = frame.isTarget --frame.isTarget is not the same here so keep this.
	local plateLevel = NP:GetPlateFrameLevel(frame)
	if plateLevel then
		if frame.FrameLevelChanged then --keep how many plates we change, this is reset to 1 post-ResetNameplateFrameLevel
			NP.CollectedFrameLevelCount = (NP.CollectedFrameLevelCount and NP.CollectedFrameLevelCount + 1) or 1
		end
		NP:SetPlateFrameLevel(frame, plateLevel, isTarget)
	end
end

function NP:StyleFrame(parent, noBackdrop, point)
	point = point or parent
	local noscalemult = E.mult * E.uiscale

	if point.bordertop then return end

	if not noBackdrop then
		point.backdrop = parent:CreateTexture(nil, "BACKGROUND")
		point.backdrop:SetAllPoints(point)
		point.backdrop:SetTexture(unpack(E.media.backdropfadecolor))
	end

	if E.PixelMode then
		point.bordertop = parent:CreateTexture()
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E.media.bordercolor))

		point.borderbottom = parent:CreateTexture()
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E.media.bordercolor))

		point.borderleft = parent:CreateTexture()
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult, -noscalemult)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E.media.bordercolor))

		point.borderright = parent:CreateTexture()
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult, -noscalemult)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E.media.bordercolor))
	else
		point.bordertop = parent:CreateTexture(nil, "OVERLAY")
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult*2)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult*2)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E.media.bordercolor))

		point.bordertop.backdrop = parent:CreateTexture()
		point.bordertop.backdrop:SetPoint("TOPLEFT", point.bordertop, "TOPLEFT", noscalemult, noscalemult)
		point.bordertop.backdrop:SetPoint("TOPRIGHT", point.bordertop, "TOPRIGHT", -noscalemult, noscalemult)
		point.bordertop.backdrop:SetHeight(noscalemult * 3)
		point.bordertop.backdrop:SetTexture(0, 0, 0)

		point.borderbottom = parent:CreateTexture(nil, "OVERLAY")
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult*2)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult*2)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E.media.bordercolor))

		point.borderbottom.backdrop = parent:CreateTexture()
		point.borderbottom.backdrop:SetPoint("BOTTOMLEFT", point.borderbottom, "BOTTOMLEFT", noscalemult, -noscalemult)
		point.borderbottom.backdrop:SetPoint("BOTTOMRIGHT", point.borderbottom, "BOTTOMRIGHT", -noscalemult, -noscalemult)
		point.borderbottom.backdrop:SetHeight(noscalemult * 3)
		point.borderbottom.backdrop:SetTexture(0, 0, 0)

		point.borderleft = parent:CreateTexture(nil, "OVERLAY")
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult*2, -noscalemult*2)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E.media.bordercolor))

		point.borderleft.backdrop = parent:CreateTexture()
		point.borderleft.backdrop:SetPoint("TOPLEFT", point.borderleft, "TOPLEFT", -noscalemult, noscalemult)
		point.borderleft.backdrop:SetPoint("BOTTOMLEFT", point.borderleft, "BOTTOMLEFT", -noscalemult, -noscalemult)
		point.borderleft.backdrop:SetWidth(noscalemult * 3)
		point.borderleft.backdrop:SetTexture(0, 0, 0)

		point.borderright = parent:CreateTexture(nil, "OVERLAY")
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult*2, -noscalemult*2)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E.media.bordercolor))

		point.borderright.backdrop = parent:CreateTexture()
		point.borderright.backdrop:SetPoint("TOPRIGHT", point.borderright, "TOPRIGHT", noscalemult, noscalemult)
		point.borderright.backdrop:SetPoint("BOTTOMRIGHT", point.borderright, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderright.backdrop:SetWidth(noscalemult * 3)
		point.borderright.backdrop:SetTexture(0, 0, 0)
	end
end

function NP:StyleFrameColor(frame, r, g, b)
	frame.bordertop:SetTexture(r, g, b)
	frame.borderbottom:SetTexture(r, g, b)
	frame.borderleft:SetTexture(r, g, b)
	frame.borderright:SetTexture(r, g, b)
end

function NP:GetUnitByName(frame, unitType)
	local unit = NP.UnitByName[frame.UnitName] or NP[unitType][frame.UnitName]
	if unit then
		return unit
	end
end

function NP:GetUnitClassByGUID(frame, guid)
	if not guid then
		guid = NP:GetGUIDByName(frame.UnitName, frame.UnitType)
	end

	if guid then
		local _, _, class = pcall(GetPlayerInfoByGUID, guid)
		return class
	end
end

local grenColorToClass = {}
for class, color in pairs(RAID_CLASS_COLORS) do
	grenColorToClass[color.g] = class
end

function NP:UnitClass(frame, unitType)
	if unitType == "FRIENDLY_PLAYER" then
		if frame.unit then
			local _, class = UnitClass(frame.unit)
			if class then
				return class
			end
		else
			return NP:GetUnitClassByGUID(frame, frame.guid)
		end
	elseif unitType == "ENEMY_PLAYER" then
		local _, g = frame.oldHealthBar:GetStatusBarColor()
		return grenColorToClass[floor(g*100 + 0.5) / 100]
	end
end

function NP:UnitDetailedThreatSituation(frame)
	if not frame.Threat:IsShown() then
		if frame.UnitType == "ENEMY_NPC" then
			local r, g = frame.oldName:GetTextColor()
			return (r > 0.5 and g < 0.5) and 0 or nil
		end
	else
		local r, g, b = frame.Threat:GetVertexColor()
		if r > 0 then
			if g > 0 then
				if b > 0 then return 1 end
				return 2
			end
			return 3
		end
	end
end

function NP:UnitLevel(frame)
	local level, boss = frame.oldLevel:IsObjectType("FontString") and tonumber(frame.oldLevel:GetText()) or false, frame.BossIcon:IsShown()
	if boss or not level then
		return "??", 0.9, 0, 0
	else
		return level, frame.oldLevel:GetTextColor()
	end
end

function NP:GetUnitInfo(frame)
	local r, g, b = frame.oldHealthBar:GetStatusBarColor()
	if r < 0.01 then
		if b < 0.01 and g > 0.99 then
			return 5, "FRIENDLY_NPC"
		elseif b > 0.99 and g < 0.01 then
			return 5, "FRIENDLY_PLAYER"
		end
	elseif r > 0.99 then
		if b < 0.01 and g > 0.99 then
			return 4, "ENEMY_NPC"
		elseif b < 0.01 and g < 0.01 then
			return 2, "ENEMY_NPC"
		end
	elseif r > 0.5 and r < 0.6 then
		if g > 0.5 and g < 0.6 and b > 0.5 and b < 0.6 then
			return 1, "ENEMY_NPC"
		end
	end
	return 3, "ENEMY_PLAYER"
end

function NP:GetUnitTypeFromUnit(unit)
	local reaction = UnitReaction("player", unit)
	local isPlayer = UnitIsPlayer(unit)

	if isPlayer and UnitIsFriend("player", unit) and reaction and reaction >= 5 then
		return "FRIENDLY_PLAYER"
	elseif not isPlayer and (reaction and reaction >= 5) or UnitFactionGroup(unit) == "Neutral" then
		return "FRIENDLY_NPC"
	elseif not isPlayer and (reaction and reaction <= 4) then
		return "ENEMY_NPC"
	else
		return "ENEMY_PLAYER"
	end
end

function NP:GetGUIDByName(name, unitType)
	for guid, info in pairs(NP.GUIDList) do
		if info.name == name and info.unitType == unitType then
			return guid
		end
	end
end

function NP:OnShow(isConfig, dontHideHighlight)
	local frame = self.UnitFrame
	NP:CheckRaidIcon(frame)

	if self:IsShown() then
		NP.VisiblePlates[frame] = 1
	end

	frame.UnitName = gsub(frame.oldName:GetText() or "", FSPAT, "")
	local reaction, unitType = NP:GetUnitInfo(frame)
	local oldUnitType = frame.UnitType
	frame.UnitType = unitType
	frame.UnitReaction = reaction

	local unit = NP:GetUnitByName(frame, unitType)
	if unit then
		frame.unit = unit
		frame.isGroupUnit = true
		frame.guid = UnitGUID(unit)
	else
		frame.guid = NP:GetGUIDByName(frame.UnitName, unitType)
	end

	frame.UnitClass = NP:UnitClass(frame, unitType)

	if unitType ~= oldUnitType or isConfig then
		NP:Update_HealthBar(frame)

		NP:Configure_CPoints(frame, true)

		NP:Configure_Level(frame)
		NP:Configure_Name(frame)

		NP:Configure_Auras(frame, "Buffs")
		NP:Configure_Auras(frame, "Debuffs")

		if NP.db.units[unitType].health.enable or NP.db.alwaysShowTargetHealth then
			NP:Configure_HealthBar(frame, true)
			NP:Configure_CastBar(frame, true)
		end

		NP:Configure_Glow(frame)
		NP:Configure_Elite(frame)
		NP:Configure_Highlight(frame)
		NP:Configure_IconFrame(frame)
	end

	frame.CutawayHealth:Hide()

	NP:RegisterEvents(frame)
	NP:UpdateElement_All(frame, nil, true)

	NP:SetSize(self)

	if not frame.isAlphaChanged then
		if not dontHideHighlight then
			NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, 0, 1)
		end
	end

	frame:Show()

	NP:StyleFilterUpdate(frame, "NAME_PLATE_UNIT_ADDED")
	NP:ForEachVisiblePlate("ResetNameplateFrameLevel") --keep this after `StyleFilterUpdate`
end

function NP:OnHide(isConfig, dontHideHighlight)
	local frame = self.UnitFrame
	NP.VisiblePlates[frame] = nil

	frame.unit = nil
	frame.isGroupUnit = nil

	for i = 1, #frame.Buffs do
		frame.Buffs[i]:SetScript("OnUpdate", nil)
		frame.Buffs[i].timeLeft = nil
		frame.Buffs[i]:Hide()
	end

	for i = 1, #frame.Debuffs do
		frame.Debuffs[i]:SetScript("OnUpdate", nil)
		frame.Debuffs[i].timeLeft = nil
		frame.Debuffs[i]:Hide()
	end

	if isConfig then
		frame.Buffs.anchoredIcons = 0
		frame.Debuffs.anchoredIcons = 0
	end

	NP:StyleFilterClear(frame)

	if frame.currentScale and frame.currentScale ~= 1 then
		NP:SetFrameScale(frame, 1, true)
	end

	if frame.isEventsRegistered then
		NP:UnregisterAllEvents(frame)
	end

	frame.TopIndicator:Hide()
	frame.LeftIndicator:Hide()
	frame.RightIndicator:Hide()
	frame.Shadow:Hide()
	frame.Spark:Hide()
	frame.Health.r, frame.Health.g, frame.Health.b = nil, nil, nil
	frame.Health:Hide()
	frame.CastBar:Hide()
	frame.CastBar.casting = nil
	frame.CastBar.channeling = nil
	frame.CastBar.notInterruptible = nil
	frame.CastBar.spellName = nil
	frame.Level:SetText()
	frame.Name.r, frame.Name.g, frame.Name.b = nil, nil, nil
	frame.Name:SetText()
	frame.Name.NameOnlyGlow:Hide()
	frame.Elite:Hide()
	frame.CPoints:Hide()
	frame.IconFrame:Hide()
	frame:Hide()
	frame.isTarget = nil
	frame.isTargetChanged = false
	frame.isMouseover = nil
	frame.currentScale = nil
	frame.UnitName = nil
	frame.UnitClass = nil
	frame.UnitReaction = nil
	frame.TopLevelFrame = nil
	frame.TopOffset = nil
	frame.ThreatReaction = nil
	frame.guid = nil
	frame.alpha = nil
	frame.isAlphaChanged = nil
	frame.RaidIconType = nil
	frame.ThreatScale = nil
	frame.ThreatStatus = nil

	if not dontHideHighlight then
		frame.oldHighlight:Hide()
	end

	NP:StyleFilterClearVariables(self)
end

function NP:UpdateAllFrame(frame, isConfig, dontHideHighlight)
	frame = frame:GetParent()

	NP.OnHide(frame, isConfig, dontHideHighlight)
	NP.OnShow(frame, isConfig, dontHideHighlight)
end

function NP:ConfigureAll()
	if not E.private.nameplates.enable then return end

	NP:StyleFilterConfigure()
	NP:ForEachPlate("UpdateAllFrame", true, true)
	NP:SetCVars()
end

function NP:ForEachPlate(functionToRun, ...)
	for frame in pairs(NP.CreatedPlates) do
		if frame and frame.UnitFrame then
			NP[functionToRun](NP, frame.UnitFrame, ...)
		end
	end

	if functionToRun == "ResetNameplateFrameLevel" then
		NP.CollectedFrameLevelCount = 1
	end
end

function NP:ForEachVisiblePlate(functionToRun, ...)
	for frame in pairs(NP.VisiblePlates) do
		NP[functionToRun](NP, frame, ...)
	end
end

function NP:UpdateElement_All(frame, noTargetFrame, filterIgnore)
	local healthShown = NP.db.units[frame.UnitType].health.enable or (frame.isTarget and NP.db.alwaysShowTargetHealth)

	NP:Update_HealthBar(frame)

	if healthShown then
		NP:Update_Health(frame)
		NP:Update_HealthColor(frame)
		NP:Update_CastBar(frame, nil, frame.unit)
		NP:UpdateElement_Auras(frame)
	end

	NP:Update_RaidIcon(frame)
	NP:Update_HealerIcon(frame)

	frame.Level:ClearAllPoints()
	frame.Name:ClearAllPoints()
	NP:Update_Name(frame)
	NP:Update_Level(frame)

	if not noTargetFrame then
		NP:Update_Elite(frame)
		NP:Update_Highlight(frame)
		NP:Update_Glow(frame)

		NP:SetTargetFrame(frame)
	end

	NP:Update_IconFrame(frame)

	if not filterIgnore then
		NP:StyleFilterUpdate(frame, "UpdateElement_All")
	end
end

function NP:SetSize(frame)
	if InCombatLockdown() then
		NP.ResizeQueue[frame] = true
	else
		local unitFrame = frame.UnitFrame
		local unitType = unitFrame.UnitType
		unitType = (unitType == "FRIENDLY_PLAYER" or unitType == "FRIENDLY_NPC") and "friendly" or "enemy"

		if NP.db.clickThrough[unitType] then
			frame:SetSize(0.001, 0.001)
		else
			if unitType == "friendly" then
				frame:SetSize(NP.db.plateSize.friendlyWidth, NP.db.plateSize.friendlyHeight)
			else
				frame:SetSize(NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight)
			end
		end

		NP.ResizeQueue[frame] = nil
	end
end

local plateID = 0
function NP:OnCreated(frame)
	plateID = plateID + 1
	local Health, CastBar = frame:GetChildren()
	local Threat, Border, CastBarBorder, CastBarShield, CastBarIcon, Highlight, Name, Level, BossIcon, RaidIcon, EliteIcon = frame:GetRegions()

	local unitFrame = CreateFrame("Frame", format("ElvUI_NamePlate%d", plateID), frame)
	frame.UnitFrame = unitFrame
	unitFrame:Hide()
	unitFrame:SetAllPoints()
	unitFrame:SetScript("OnEvent", NP.OnEvent)
	unitFrame:SetScale(NP.db.plateScale and E.uiscale or 1)
	unitFrame.plateID = plateID

	unitFrame.Health = NP:Construct_HealthBar(unitFrame)
	unitFrame.Health.Highlight = NP:Construct_Highlight(unitFrame)
	unitFrame.CutawayHealth = NP:ConstructElement_CutawayHealth(unitFrame)
	unitFrame.Level = NP:Construct_Level(unitFrame)
	unitFrame.Name = NP:Construct_Name(unitFrame)
	unitFrame.CastBar = NP:Construct_CastBar(unitFrame)
	unitFrame.Elite = NP:Construct_Elite(unitFrame)
	unitFrame.Buffs = NP:ConstructElement_Auras(unitFrame, "Buffs")
	unitFrame.Debuffs = NP:ConstructElement_Auras(unitFrame, "Debuffs")
	unitFrame.HealerIcon = NP:Construct_HealerIcon(unitFrame)
	unitFrame.CPoints = NP:Construct_CPoints(unitFrame)
	unitFrame.IconFrame = NP:Construct_IconFrame(unitFrame)
	NP:Construct_Glow(unitFrame)

	NP:QueueObject(Health)
	NP:QueueObject(CastBar)
	NP:QueueObject(Level)
	NP:QueueObject(Name)
	NP:QueueObject(Threat)
	NP:QueueObject(Border)
	NP:QueueObject(CastBarBorder)
	NP:QueueObject(CastBarShield)
	NP:QueueObject(Highlight)
	BossIcon:SetAlpha(0)
	EliteIcon:SetAlpha(0)

	unitFrame.oldHealthBar = Health
	unitFrame.oldCastBar = CastBar
	unitFrame.oldCastBar.Shield = CastBarShield
	unitFrame.oldCastBar.Icon = CastBarIcon
	unitFrame.oldName = Name
	unitFrame.oldHighlight = Highlight
	unitFrame.oldLevel = Level

	unitFrame.Threat = Threat
	RaidIcon:SetParent(unitFrame)
	unitFrame.RaidIcon = RaidIcon

	unitFrame.BossIcon = BossIcon
	unitFrame.EliteIcon = EliteIcon

	NP.OnShow(frame, true)
	NP:SetSize(frame)

	frame:HookScript("OnShow", NP.OnShow)
	frame:HookScript("OnHide", NP.OnHide)
	Health:HookScript("OnValueChanged", NP.Update_HealthOnValueChanged)

	NP.CreatedPlates[frame] = true
	NP.VisiblePlates[unitFrame] = 1
end

function NP:OnEvent(event, unit, ...)
	if not unit and not self.unit then return end
	if self.unit ~= unit then return end

	NP:Update_CastBar(self, event, unit, ...)
end

function NP:RegisterEvents(frame)
	if not frame.unit then return end

	if NP.db.units[frame.UnitType].health.enable or (frame.isTarget and NP.db.alwaysShowTargetHealth) then
		if NP.db.units[frame.UnitType].castbar.enable then
			frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
			frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
			frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
			frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
			frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
			frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
			frame:RegisterEvent("UNIT_SPELLCAST_START")
			frame:RegisterEvent("UNIT_SPELLCAST_STOP")
			frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
			frame.isEventsRegistered = true
		end

		NP.OnEvent(frame, nil, frame.unit)
	end
end

function NP:UnregisterAllEvents(frame)
	frame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	frame:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
	frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	frame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	frame:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	frame:UnregisterEvent("UNIT_SPELLCAST_START")
	frame:UnregisterEvent("UNIT_SPELLCAST_STOP")
	frame:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	frame.isEventsRegistered = nil
end

function NP:QueueObject(object)
	local objectType = object:GetObjectType()
	if objectType == "Texture" then
		object:SetTexture("")
		object:SetTexCoord(0, 0, 0, 0)
	elseif objectType == "FontString" then
		object:SetWidth(0.001)
	elseif objectType == "StatusBar" then
		object:SetStatusBarTexture("")
	end
	object:Hide()
end

function NP:PlateFade(nameplate, timeToFade, startAlpha, endAlpha)
	-- we need our own function because we want a smooth transition and dont want it to force update every pass.
	-- its controlled by fadeTimer which is reset when UIFrameFadeOut or UIFrameFadeIn code runs.

	if not nameplate.FadeObject then
		nameplate.FadeObject = {}
	end

	nameplate.FadeObject.timeToFade = (nameplate.isTarget and 0) or timeToFade
	nameplate.FadeObject.startAlpha = startAlpha
	nameplate.FadeObject.endAlpha = endAlpha
	nameplate.FadeObject.diffAlpha = endAlpha - startAlpha

	if nameplate.FadeObject.fadeTimer then
		nameplate.FadeObject.fadeTimer = 0
	else
		E:UIFrameFade(nameplate, nameplate.FadeObject)
	end
end

function NP:SetTargetFrame(frame)
	if hasTarget and frame.alpha == 1 then
		if not frame.isTarget then
			frame.isTarget = true

			NP:SetPlateFrameLevel(frame, NP:GetPlateFrameLevel(frame), true)

			if NP.db.useTargetScale then
				NP:SetFrameScale(frame, (frame.ThreatScale or 1) * NP.db.targetScale)
			end

			if not frame.isGroupUnit then
				frame.unit = "target"
				frame.guid = UnitGUID("target")

				NP:RegisterEvents(frame)
			end

			NP:UpdateElement_Auras(frame)

			if not NP.db.units[frame.UnitType].health.enable and NP.db.alwaysShowTargetHealth then
				frame.Health.r, frame.Health.g, frame.Health.b = nil, nil, nil

				NP:Configure_HealthBar(frame)
				NP:Configure_CastBar(frame)
				NP:Configure_Elite(frame)
				NP:Configure_CPoints(frame)

				NP:RegisterEvents(frame)

				NP:UpdateElement_All(frame, true)
			end

			NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)

			NP:Update_Highlight(frame)
			NP:Update_CPoints(frame)
			NP:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
			NP:ForEachVisiblePlate("ResetNameplateFrameLevel") --keep this after `StyleFilterUpdate`
		end
	elseif frame.isTarget then
		frame.isTarget = nil

		NP:SetPlateFrameLevel(frame, NP:GetPlateFrameLevel(frame))

		if NP.db.useTargetScale then
			NP:SetFrameScale(frame, (frame.ThreatScale or 1))
		end

		if not frame.isGroupUnit then
			frame.unit = nil

			if frame.isEventsRegistered then
				NP:UnregisterAllEvents(frame)
				NP:Update_CastBar(frame)
			end
		end

		if not NP.db.units[frame.UnitType].health.enable then
			NP:UpdateAllFrame(frame, nil, true)
		end

		NP:Update_CPoints(frame)

		if not frame.AlphaChanged then
			if hasTarget then
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), NP.db.nonTargetTransparency)
			else
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)
			end
		end

		NP:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
		NP:ForEachVisiblePlate("ResetNameplateFrameLevel") --keep this after `StyleFilterUpdate`
	else
		if hasTarget and not frame.isAlphaChanged then
			frame.isAlphaChanged = true

			if not frame.AlphaChanged then
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), NP.db.nonTargetTransparency)
			end

			NP:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
		elseif not hasTarget and frame.isAlphaChanged then
			frame.isAlphaChanged = nil

			if not frame.AlphaChanged then
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)
			end

			NP:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
		end
	end

	NP:Configure_Glow(frame)
	NP:Update_Glow(frame)
end

function NP:SetMouseoverFrame(frame)
	if frame.oldHighlight:IsShown() then
		if not frame.isMouseover then
			frame.isMouseover = true

			NP:Update_Highlight(frame)

			if not frame.isGroupUnit then
				frame.unit = "mouseover"
				frame.guid = UnitGUID("mouseover")

				NP:Update_CastBar(frame, nil, frame.unit)
			end

			NP:UpdateElement_Auras(frame)
		end
	elseif frame.isMouseover then
		frame.isMouseover = nil

		NP:Update_Highlight(frame)

		if not frame.isGroupUnit then
			frame.unit = nil

			NP:Update_CastBar(frame)
		end
	end
end

local function findNewPlate(...)
	for i = lastChildern + 1, numChildren do
		local frame = select(i, ...)
		local region = frame:GetRegions()
		if region and region:IsObjectType("Texture") and region:GetTexture() == OVERLAY and not NP.CreatedPlates[frame] then
			NP:OnCreated(frame)
		end
	end
end

function NP:OnUpdate()
	numChildren = WorldGetNumChildren(WorldFrame)
	if lastChildern ~= numChildren then
		findNewPlate(WorldGetChildren(WorldFrame))
		lastChildern = numChildren
	end

	for frame in pairs(NP.VisiblePlates) do
		if hasTarget then
			frame.alpha = frame:GetParent():GetAlpha()
			frame:GetParent():SetAlpha(1)
		else
			frame.alpha = 1
		end

		NP:SetMouseoverFrame(frame)
		NP:SetTargetFrame(frame)

		if frame.UnitReaction ~= NP:GetUnitInfo(frame) then
			NP:UpdateAllFrame(frame, nil, true)
		end

		local status = NP:UnitDetailedThreatSituation(frame)
		if frame.ThreatStatus ~= status then
			frame.ThreatStatus = status

			NP:Update_HealthColor(frame)
		end
	end
end

function NP:CheckRaidIcon(frame)
	if frame.RaidIcon:IsShown() then
		local ux, uy = frame.RaidIcon:GetTexCoord()
		frame.RaidIconType = RaidIconCoordinate[ux][uy]
	else
		frame.RaidIconType = nil
	end
end

function NP:SearchNameplateByGUID(guid)
	for frame in pairs(NP.VisiblePlates) do
		if frame.guid == guid then
			return frame
		end
	end
end

function NP:SearchNameplateByName(sourceName)
	if not sourceName then return end
	local SearchFor = split("-", sourceName)
	for frame in pairs(NP.VisiblePlates) do
		if frame.UnitName == SearchFor and RAID_CLASS_COLORS[frame.UnitClass] then
			return frame
		end
	end
end

function NP:SearchNameplateByIconName(raidIcon)
	for frame in pairs(NP.VisiblePlates) do
		NP:CheckRaidIcon(frame)
		if frame.RaidIcon:IsShown() and (frame.RaidIconType == raidIcon) then
			return frame
		end
	end
end

function NP:SearchForFrame(guid, raidIcon, name)
	local frame
	if guid then frame = NP:SearchNameplateByGUID(guid) end
	if (not frame) and name then frame = NP:SearchNameplateByName(name) end
	if (not frame) and raidIcon then frame = NP:SearchNameplateByIconName(raidIcon) end

	return frame
end

local function CopySettings(from, to)
	for setting, value in pairs(from) do
		if type(value) == "table" and to[setting] ~= nil then
			CopySettings(from[setting], to[setting])
		else
			if to[setting] ~= nil then
				to[setting] = from[setting]
			end
		end
	end
end

function NP:ResetAuraPriority()
	for unitType, content in pairs(E.db.nameplates.units) do
		local default = P.nameplates.units[unitType]
		if default then
			if content.buffs and content.buffs.filters then
				content.buffs.filters.priority = default.buffs.filters.priority
			end
			if content.debuffs and content.debuffs.filters then
				content.debuffs.filters.priority = default.debuffs.filters.priority
			end
		end
	end
end

function NP:ResetSettings(unit)
	CopySettings(P.nameplates.units[unit], NP.db.units[unit])
end

function NP:CopySettings(from, to)
	if from == to then return end

	CopySettings(NP.db.units[from], NP.db.units[to])
end

function NP:PLAYER_ENTERING_WORLD()
	twipe(NP.Healers)
	local inInstance, instanceType = IsInInstance()
	if inInstance and (instanceType == "pvp") and NP.db.units.ENEMY_PLAYER.markHealers then
		NP:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", "CheckBGHealers")
		NP.CheckHealerTimer = NP:ScheduleRepeatingTimer("CheckBGHealers", 3)
	else
		NP:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
		if NP.CheckHealerTimer then
			NP:CancelTimer(NP.CheckHealerTimer)
			NP.CheckHealerTimer = nil;
		end
	end
end

function NP:PLAYER_TARGET_CHANGED()
	hasTarget = UnitExists("target") == 1
end

function NP:UPDATE_MOUSEOVER_UNIT()
	if not UnitIsUnit("mouseover", "player") and UnitIsPlayer("mouseover") then
		local name = UnitName("mouseover")
		local guid = UnitGUID("mouseover")
		local unitType = NP:GetUnitTypeFromUnit("mouseover")
		for frame in pairs(NP.VisiblePlates) do
			if frame.UnitName == name and frame.UnitType == unitType then
				if not NP.GUIDList[guid] then
					NP.GUIDList[guid] = {name = name, unitType = frame.UnitType}
					NP.OnShow(frame:GetParent(), nil, true)
					break
				end
			end
		end
	end
end

function NP:PLAYER_FOCUS_CHANGED()
	local unitName

	if UnitIsPlayer("focus") and not UnitIsUnit("focus", "player") then
		local name = UnitName("focus")
		local guid = UnitGUID("focus")

		NP.UnitByName[name] = "focus"
		NP.NameByUnit.focus = name

		if not NP.GUIDList[guid] then
			NP.GUIDList[guid] = {name = name, unitType = NP:GetUnitTypeFromUnit("focus")}
		end

		unitName = name
	elseif NP.NameByUnit.focus then
		NP.UnitByName[NP.NameByUnit.focus] = nil
		unitName = NP.NameByUnit.focus
		NP.NameByUnit.focus = nil
	end

	if not unitName then
		return
	end

	for frame in pairs(NP.VisiblePlates) do
		if frame.UnitName == unitName then
			NP:UpdateAllFrame(frame, nil, true)
		end
	end
end

function NP:SetCVars()
	E:SetCVar('ShowClassColorInNameplate', 1)
	E:SetCVar('showVKeyCastbar', 0)
	E:SetCVar('nameplateAllowOverlap', NP.db.motionType == 'STACKED' and 0 or 1)

	-- the order of these is important !!
	E:SetCVar('nameplateShowEnemyGuardians', NP.db.visibility.enemy.guardians and 1 or 0)
	E:SetCVar('nameplateShowEnemyPets', NP.db.visibility.enemy.pets and 1 or 0)
	E:SetCVar('nameplateShowEnemyTotems', NP.db.visibility.enemy.totems and 1 or 0)
	E:SetCVar('nameplateShowFriendlyGuardians', NP.db.visibility.friendly.guardians and 1 or 0)
	E:SetCVar('nameplateShowFriendlyPets', NP.db.visibility.friendly.pets and 1 or 0)
	E:SetCVar('nameplateShowFriendlyTotems', NP.db.visibility.friendly.totems and 1 or 0)
end

function NP:PLAYER_REGEN_DISABLED()
	if NP.db.showFriendlyCombat == 'TOGGLE_ON' then
		E:SetCVar('nameplateShowFriends', 1)
	elseif NP.db.showFriendlyCombat == 'TOGGLE_OFF' then
		E:SetCVar('nameplateShowFriends', 0)
	end

	if NP.db.showEnemyCombat == 'TOGGLE_ON' then
		E:SetCVar('nameplateShowEnemies', 1)
	elseif NP.db.showEnemyCombat == 'TOGGLE_OFF' then
		E:SetCVar('nameplateShowEnemies', 0)
	end

	NP:ForEachVisiblePlate("StyleFilterUpdate", "PLAYER_REGEN_DISABLED")
end

function NP:PLAYER_REGEN_ENABLED()
	if next(NP.ResizeQueue) then
		for frame in pairs(NP.ResizeQueue) do
			NP:SetSize(frame)
		end
	end

	if NP.db.showFriendlyCombat == 'TOGGLE_ON' then
		E:SetCVar('nameplateShowFriends', 0)
	elseif NP.db.showFriendlyCombat == 'TOGGLE_OFF' then
		E:SetCVar('nameplateShowFriends', 1)
	end

	if NP.db.showEnemyCombat == 'TOGGLE_ON' then
		E:SetCVar('nameplateShowEnemies', 0)
	elseif NP.db.showEnemyCombat == 'TOGGLE_OFF' then
		E:SetCVar('nameplateShowEnemies', 1)
	end

	NP:ForEachVisiblePlate("StyleFilterUpdate", "PLAYER_REGEN_ENABLED")
end

function NP:UNIT_COMBO_POINTS(_, unit)
	if unit == "player" or unit == "vehicle" then
		NP:ForEachVisiblePlate("Update_CPoints")
	end
end

function NP:UNIT_HEALTH(_, unit)
	if unit ~= "player" then return end
	NP:ForEachVisiblePlate("StyleFilterUpdate", "UNIT_HEALTH")
end

function NP:UNIT_MANA(_, unit)
	if unit ~= "player" then return end
	NP:ForEachVisiblePlate("StyleFilterUpdate", "UNIT_MANA")
end

function NP:UNIT_ENERGY(_, unit)
	if unit ~= "player" then return end
	NP:ForEachVisiblePlate("StyleFilterUpdate", "UNIT_ENERGY")
end

function NP:UNIT_FOCUS(_, unit)
	if unit ~= "player" then return end
	NP:ForEachVisiblePlate("StyleFilterUpdate", "UNIT_FOCUS")
end

function NP:UNIT_RAGE(_, unit)
	if unit ~= "player" then return end
	NP:ForEachVisiblePlate("StyleFilterUpdate", "UNIT_RAGE")
end

function NP:SPELL_UPDATE_COOLDOWN(...)
	NP:ForEachVisiblePlate("StyleFilterUpdate", "SPELL_UPDATE_COOLDOWN")
end

function NP:PLAYER_UPDATE_RESTING()
	NP:ForEachVisiblePlate("StyleFilterUpdate", "PLAYER_UPDATE_RESTING")
end

function NP:RAID_TARGET_UPDATE()
	for frame in pairs(NP.VisiblePlates) do
		NP:CheckRaidIcon(frame)
		NP:StyleFilterUpdate(frame, "RAID_TARGET_UPDATE")
	end
end

function NP:CacheArenaUnits()
	twipe(NP.ENEMY_PLAYER)
	twipe(NP.ENEMY_NPC)

	for i = 1, 5 do
		if UnitExists("arena"..i) then
			local unit = format("arena%d", i)
			NP.ENEMY_PLAYER[UnitName(unit)] = unit
		end
		if UnitExists("arenapet"..i) then
			local unit = format("arenapet%d", i)
			NP.ENEMY_NPC[UnitName(unit)] = unit
		end
	end
end

function NP:CacheGroupUnits()
	twipe(NP.FRIENDLY_PLAYER)

	if GetNumRaidMembers() > 0 then
		for i = 1, 40 do
			if UnitExists("raid"..i) then
				local unit = format("raid%d", i)
				NP.FRIENDLY_PLAYER[UnitName(unit)] = unit
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, 5 do
			if UnitExists("party"..i) then
				local unit = format("party%d", i)
				NP.FRIENDLY_PLAYER[UnitName(unit)] = unit
			end
		end
	end
end

function NP:CacheGroupPetUnits()
	twipe(NP.FRIENDLY_NPC)
	twipe(NP.ENEMY_NPC)

	for i = 1, 5 do
		if UnitExists("arenapet"..i) then
			local unit = format("arenapet%d", i)
			NP.ENEMY_NPC[UnitName(unit)] = unit
		end
	end
	if GetNumRaidMembers() > 0 then
		for i = 1, 40 do
			if UnitExists("raidpet"..i) then
				local unit = format("raidpet%d", i)
				NP.FRIENDLY_NPC[UnitName(unit)] = unit
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, 5 do
			if UnitExists("partypet"..i) then
				local unit = format("partypet%d", i)
				NP.FRIENDLY_NPC[UnitName(unit)] = unit
			end
		end
	end
end

function NP:TogleTestFrame(unitType)
	local unitFrame = ElvNP_Test.UnitFrame
	if not ElvNP_Test:IsShown() or unitFrame.UnitType ~= unitType then
		if unitType == "ENEMY_NPC" then
			unitFrame.oldHealthBar:SetStatusBarColor(1, 0, 0)
		elseif unitType == "FRIENDLY_NPC" then
			unitFrame.oldHealthBar:SetStatusBarColor(0, 1, 0)
		elseif unitType == "FRIENDLY_PLAYER" then
			unitFrame.oldHealthBar:SetStatusBarColor(0, 0, 1)
		else
			local color = RAID_CLASS_COLORS[E.myclass]
			unitFrame.oldHealthBar:SetStatusBarColor(color.r, color.g, color.b)
		end

		local maxHealth = UnitHealthMax("player")
		unitFrame.oldHealthBar:SetMinMaxValues(0, maxHealth)
		unitFrame.oldHealthBar:SetValue(random(1, maxHealth))

		unitFrame.oldName:SetText(L[unitType])
		unitFrame.oldLevel:SetText(E.mylevel)
		unitFrame.Buffs.forceShow = true
		unitFrame.Debuffs.forceShow = true
		unitFrame.RaidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		SetRaidTargetIconTexture(unitFrame.RaidIcon, random(1, 8))
		unitFrame.RaidIcon:Show()

		if not ElvNP_Test:IsShown() then
			ElvNP_Test:Show()
		end

		NP:UpdateAllFrame(unitFrame, true, true)
	else
		ElvNP_Test:Hide()
	end
end

function NP:Initialize()
	if not E.private.nameplates.enable then return end
	NP.Initialized = true

	NP.db = E.db.nameplates


	--Add metatable to all our StyleFilters so they can grab default values if missing
	NP:StyleFilterInitialize()

	--Populate `NP.StyleFilterEvents` with events Style Filters will be using and sort the filters based on priority.
	NP:StyleFilterConfigure()

	NP.levelStep = 2

	NP:SetCVars()

	local ElvNP_Test = CreateFrame("Button", "ElvNP_Test")
	ElvNP_Test:SetScale(1)
	ElvNP_Test:ClearAllPoints()
	ElvNP_Test:Point("BOTTOM", UIParent, "BOTTOM", 0, 250)
	ElvNP_Test:SetMovable(true)
	ElvNP_Test:RegisterForDrag("LeftButton", "RightButton")
	ElvNP_Test:SetScript("OnDragStart", function() ElvNP_Test:StartMoving() end)
	ElvNP_Test:SetScript("OnDragStop", function() ElvNP_Test:StopMovingOrSizing() end)
	ElvNP_Test.frameType = 'PLAYER'

	CreateFrame("StatusBar", nil, ElvNP_Test)
	CreateFrame("StatusBar", nil, ElvNP_Test)

	for i = 1, 11 do
		if i == 7 or i == 8 then
			ElvNP_Test:CreateFontString(nil, "OVERLAY", "GameFontNormal"):SetText("Empty")
		else
			ElvNP_Test:CreateTexture():Hide()
		end
	end

	NP:StyleFrame(ElvNP_Test, true)
	NP:OnCreated(ElvNP_Test)
	local castbar = ElvNP_Test.UnitFrame.CastBar
	castbar:SetParent(ElvNP_Test.UnitFrame.Health)
	castbar.Hide = castbar.Show
	castbar:Show()
	castbar.Name:SetText("Casting")
	castbar.Time:SetText("3.1")
	castbar.Icon.texture:SetTexture([[Interface\Icons\Spell_Holy_Penance]])
	castbar:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)
	ElvNP_Test:Hide()

	NP.Frame = CreateFrame("Frame"):SetScript("OnUpdate", NP.OnUpdate)

	NP:RegisterEvent("PLAYER_ENTERING_WORLD")
	NP:RegisterEvent("PLAYER_REGEN_ENABLED")
	NP:RegisterEvent("PLAYER_REGEN_DISABLED")
	NP:RegisterEvent("PLAYER_LOGOUT")
	NP:RegisterEvent("PLAYER_TARGET_CHANGED")
	NP:RegisterEvent("PLAYER_FOCUS_CHANGED")
	NP:RegisterEvent("PLAYER_UPDATE_RESTING")
	NP:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	NP:RegisterEvent("RAID_TARGET_UPDATE")
	NP:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	NP:RegisterEvent("UNIT_COMBO_POINTS")
	NP:RegisterEvent("UNIT_HEALTH")
	NP:RegisterEvent("UNIT_MANA")
	NP:RegisterEvent("UNIT_ENERGY")
	NP:RegisterEvent("UNIT_FOCUS")
	NP:RegisterEvent("UNIT_RAGE")

	-- Arena & Arena Pets
	NP:CacheArenaUnits()
	NP:RegisterEvent("ARENA_OPPONENT_UPDATE", "CacheArenaUnits")
	-- Group
	NP:CacheGroupUnits()
	NP:RegisterEvent("PARTY_MEMBERS_CHANGED", "CacheGroupUnits")
	NP:RegisterEvent("RAID_ROSTER_UPDATE", "CacheGroupUnits")
	-- Group Pets
	NP:CacheGroupPetUnits()
	NP:RegisterEvent("UNIT_NAME_UPDATE", "CacheGroupPetUnits")

	LAI.UnregisterAllCallbacks(NP)
	LAI.RegisterCallback(NP, "LibAuraInfo_AURA_APPLIED")
	LAI.RegisterCallback(NP, "LibAuraInfo_AURA_REMOVED")
	LAI.RegisterCallback(NP, "LibAuraInfo_AURA_REFRESH")
	LAI.RegisterCallback(NP, "LibAuraInfo_AURA_APPLIED_DOSE")
	LAI.RegisterCallback(NP, "LibAuraInfo_AURA_CLEAR")
	LAI.RegisterCallback(NP, "LibAuraInfo_UNIT_AURA")
end

E:RegisterModule(NP:GetName())