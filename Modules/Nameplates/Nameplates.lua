local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
NP.LSM = E.Libs.LSM
local ElvUF = E.oUF
assert(ElvUF, 'ElvUI was unable to locate oUF.')

local _G = _G
local pairs, ipairs, wipe, tinsert = pairs, ipairs, wipe, tinsert
local select, unpack, next, type = select, unpack, next, type
local match = string.match
local strsplit = strsplit

local CreateFrame = CreateFrame
local GetBattlefieldScore = GetBattlefieldScore
local GetCVar = GetCVar
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetPartyAssignment = GetPartyAssignment
local GetRaidRosterInfo = GetRaidRosterInfo
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local SetCVar = SetCVar
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitReaction = UnitReaction
local hooksecurefunc = hooksecurefunc

-- Module state tables
NP.Plates     = {}
NP.GroupRoles = {}
NP.PlateGUID  = {}
NP.StatusBars = {}
NP.Healers    = {}
NP.multiplier = 0.35
NP.IsInGroup  = false

NP.StyleFilterEventFunctions = {}

do
	local empty = {}
	function NP:PlateDB(nameplate)
		return (nameplate and NP.db.units and NP.db.units[nameplate.frameType]) or empty
	end
end

function NP:SetCVar(cvar, value)
	if GetCVar(cvar) ~= tostring(value) then
		SetCVar(cvar, value)
	end
end

function NP:UpdateCVars()
	NP:SetCVar('ShowClassColorInNameplate', '1')
	NP:SetCVar('showVKeyCastbar', '1')
	NP:SetCVar('nameplateAllowOverlap', NP.db.motionType == 'STACKED' and '0' or '1')
end

function NP:UnitNPCID(unit)
	local guid = UnitGUID(unit)
	if not guid then return nil, nil end
	local parts = {strsplit('-', guid)}
	return parts[6], guid
end

function NP:UpdatePlateGUID(nameplate, guid)
	NP.PlateGUID[nameplate.unitGUID] = (guid and nameplate) or nil
end

function NP:UpdatePlateType(nameplate)
	local unit = nameplate.unit
	if not unit then return end

	if UnitIsUnit(unit, 'player') then
		nameplate.frameType = 'PLAYER'
		nameplate.isPlayer  = true
		nameplate.classFile = select(2, UnitClass('player'))
		nameplate.UnitType     = 'PLAYER'
		nameplate.UnitName     = nameplate.unitName
		nameplate.UnitReaction = nameplate.reaction
		return
	end

	local isPlayer = UnitIsPlayer(unit)
	local reaction = UnitReaction('player', unit)
	local isFriendly = reaction and reaction >= 5

	if isPlayer then
		nameplate.frameType = isFriendly and 'FRIENDLY_PLAYER' or 'ENEMY_PLAYER'
	else
		local faction = UnitFactionGroup(unit)
		if faction == 'Neutral' then
			nameplate.frameType = 'FRIENDLY_NPC'
		else
			nameplate.frameType = isFriendly and 'FRIENDLY_NPC' or 'ENEMY_NPC'
		end
	end

	nameplate.isPlayer  = isPlayer
	nameplate.classFile = isPlayer and select(2, UnitClass(unit)) or nil

	nameplate.UnitType     = nameplate.frameType
	nameplate.UnitName     = nameplate.unitName
	nameplate.UnitReaction = nameplate.reaction
end

function NP:GetUnitTypeFromUnit(unit)
	local reaction = UnitReaction('player', unit)
	local isPlayer = UnitIsPlayer(unit)

	if isPlayer and UnitIsFriend('player', unit) and reaction and reaction >= 5 then
		return 'FRIENDLY_PLAYER'
	elseif not isPlayer and (reaction and reaction >= 5 or UnitFactionGroup(unit) == 'Neutral') then
		return 'FRIENDLY_NPC'
	elseif not isPlayer and (reaction and reaction <= 4) then
		return 'ENEMY_NPC'
	else
		return 'ENEMY_PLAYER'
	end
end

function NP:UpdatePlateSize(nameplate)
	if not InCombatLockdown() then
		local ft = nameplate.frameType
		if ft == 'PLAYER' or ft == 'FRIENDLY_PLAYER' or ft == 'FRIENDLY_NPC' then
			nameplate:SetSize(NP.db.plateSize.friendlyWidth, NP.db.plateSize.friendlyHeight)
		else
			nameplate:SetSize(NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight)
		end
	end
end

function NP:Style(unit)
	self.isNamePlate = true
	NP:StylePlate(self, unit)
	return self
end

function NP:Construct_RaisedElement(nameplate)
	local name = nameplate:GetName()
	local frame = CreateFrame('Frame', name and (name .. 'Raised') or nil, nameplate)
	local strata = nameplate:GetFrameStrata()
	if strata ~= 'UNKNOWN' then
		frame:SetFrameStrata(strata)
	end
	frame:SetFrameLevel(10)
	frame:SetAllPoints()
	frame:EnableMouse(false)
	return frame
end

function NP:StylePlate(nameplate)
	nameplate:SetScale(E.uiscale or 1)
	nameplate:ClearAllPoints()
	nameplate:SetPoint('CENTER')

	nameplate.RaisedElement = NP:Construct_RaisedElement(nameplate)

	nameplate.Health = NP:Construct_Health(nameplate)
	nameplate.Health.Text = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.Health.Text.frequentUpdates = 0.1

	nameplate.Power = NP:Construct_Power(nameplate)
	nameplate.Power.Text = NP:Construct_TagText(nameplate.RaisedElement)

	nameplate.Name  = NP:Construct_Name(nameplate.RaisedElement)
	nameplate.Level = NP:Construct_Level(nameplate.RaisedElement)

	nameplate.ClassificationIndicator = NP:Construct_ClassificationIndicator(nameplate.RaisedElement)
	nameplate.Castbar             = NP:Construct_Castbar(nameplate)
	nameplate.Portrait            = NP:Construct_Portrait(nameplate.RaisedElement)
	nameplate.RaidTargetIndicator = NP:Construct_RaidTargetIndicator(nameplate.RaisedElement)
	nameplate.TargetIndicator     = NP:Construct_TargetIndicator(nameplate)
	nameplate.ThreatIndicator     = NP:Construct_ThreatIndicator(nameplate.RaisedElement)
	nameplate.Highlight           = NP:Construct_Highlight(nameplate)
	nameplate.ClassPower          = NP:Construct_ClassPower(nameplate)
	nameplate.IconFrame           = NP:Construct_IconFrame(nameplate)
	nameplate.CutawayHealth       = NP:ConstructElement_CutawayHealth(nameplate)

	NP:Construct_Auras(nameplate)
	NP:StyleFilterEvents(nameplate)

	NP.Plates[nameplate] = nameplate:GetName()

	hooksecurefunc(nameplate, 'UpdateAllElements', NP.PostUpdateAllElements)
end

function NP:PostUpdateAllElements(event)
	if event and (event == 'ForceUpdate' or not NP.StyleFilterEventFunctions[event]) then
		NP:StyleFilterUpdate(self, event)
		self.StyleFilterBaseAlreadyUpdated = nil
	end
end

function NP:UpdatePlate(nameplate, updateBase)
	NP:Update_RaidTargetIndicator(nameplate)
	NP:Update_Portrait(nameplate)

	local db = NP:PlateDB(nameplate)
	if not db.enable then
		NP:DisablePlate(nameplate)

		if nameplate.RaisedElement:IsShown() then
			nameplate.RaisedElement:Hide()
		end
	elseif updateBase then
		NP:Update_Tags(nameplate)
		NP:Update_Health(nameplate)
		NP:Update_Highlight(nameplate)
		NP:Update_Power(nameplate)
		NP:Update_Castbar(nameplate)
		NP:Update_ClassPower(nameplate)
		NP:Update_Auras(nameplate)
		NP:Update_ClassificationIndicator(nameplate)
		NP:Update_TargetIndicator(nameplate)
		NP:Update_ThreatIndicator(nameplate)
	else
		NP:Update_Health(nameplate, true)
	end
end

NP.DisableElements = {
	'Health',
	'Power',
	'ClassificationIndicator',
	'Castbar',
	'ThreatIndicator',
	'TargetIndicator',
	'ClassPower',
	'Auras',
}

function NP:DisablePlate(nameplate)
	for _, element in ipairs(NP.DisableElements) do
		if nameplate:IsElementEnabled(element) then
			nameplate:DisableElement(element)
		end
	end
end

function NP:UpdatePlateBase(nameplate)
	local update = nameplate.frameType ~= nameplate.previousType
	NP:UpdatePlate(nameplate, update)

	nameplate.StyleFilterBaseAlreadyUpdated = update
	nameplate.previousType = nameplate.frameType
end

function NP:NamePlateCallBack(nameplate, event, unit)
	if event == 'PLAYER_TARGET_CHANGED' then
		return
	elseif not nameplate or not nameplate.UpdateAllElements then
		return
	end

	if event == 'UNIT_FACTION' then
		if not unit then unit = nameplate.unit end

		nameplate.reaction   = UnitReaction('player', unit)
		nameplate.isFriend   = UnitIsFriend('player', unit)
		nameplate.faction    = UnitFactionGroup(unit)
		nameplate.classColor = (nameplate.isPlayer and E:ClassColor(nameplate.classFile)) or nil

		NP:UpdatePlateType(nameplate)
		NP:UpdatePlateSize(nameplate)
		NP:UpdatePlateBase(nameplate)

		NP:StyleFilterUpdate(nameplate, event)
		nameplate.StyleFilterBaseAlreadyUpdated = nil

	elseif event == 'NAME_PLATE_UNIT_ADDED' then
		if not unit then unit = nameplate.unit end

		nameplate.classification = UnitClassification(unit)
		nameplate.creatureType   = UnitCreatureType(unit)
		nameplate.isPlayer       = UnitIsPlayer(unit)
		nameplate.isFriend       = UnitIsFriend('player', unit)
		nameplate.reaction       = UnitReaction('player', unit)
		nameplate.faction        = UnitFactionGroup(unit)
		nameplate.unitName, nameplate.unitRealm = UnitName(unit)
		nameplate.className, nameplate.classFile = UnitClass(unit)
		nameplate.npcID, nameplate.unitGUID = NP:UnitNPCID(unit)
		nameplate.classColor = (nameplate.isPlayer and E:ClassColor(nameplate.classFile)) or nil

		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate, nameplate.unitGUID)
		end

		NP:UpdatePlateType(nameplate)
		NP:UpdatePlateSize(nameplate)

		if not nameplate.RaisedElement:IsShown() then
			nameplate.RaisedElement:Show()
		end

		NP:UpdatePlateBase(nameplate)

		NP:StyleFilterEventWatch(nameplate)
		NP:StyleFilterSetVariables(nameplate)

		if NP.db.fadeIn then
			NP:PlateFade(nameplate, 1, 0, 1)
		end

		-- Hide Sirus's default nameplate UnitFrame so it doesn't overlap ElvUI's
		local baseFrame = nameplate:GetParent()
		if baseFrame and baseFrame.UnitFrame then
			if not baseFrame.UnitFrame._elvHooked then
				baseFrame.UnitFrame:HookScript('OnShow', function(self) self:Hide() end)
				baseFrame.UnitFrame._elvHooked = true
			end
			baseFrame.UnitFrame:Hide()
		end

		-- Hide Blizzard mana/power bar on personal nameplate (it's parented to the nameplate, not UnitFrame)
		if UnitIsUnit(unit, 'player') and NamePlateDriverFrame then
			local manaBar = NamePlateDriverFrame:GetClassNameplateManaBar()
			if manaBar and not manaBar._elvHooked then
				manaBar:HookScript('OnShow', function(self) self:Hide() end)
				manaBar._elvHooked = true
			end
			if manaBar then manaBar:Hide() end
		end

	elseif event == 'NAME_PLATE_UNIT_REMOVED' then
		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate)
		end

		NP:StyleFilterEventWatch(nameplate, true)
		NP:StyleFilterClearVariables(nameplate)

		nameplate.Health.cur = nil
		nameplate.Power.cur  = nil
		nameplate.npcID      = nil
	end
end

function NP:Update_StatusBars()
	local LSM = NP.LSM
	for bar in pairs(NP.StatusBars) do
		local texture = (LSM and LSM:Fetch('statusbar', NP.db.statusbar)) or E.media.normTex
		if bar.SetStatusBarTexture then
			bar:SetStatusBarTexture(texture)
		else
			bar:SetTexture(texture)
		end
	end
end

function NP:GROUP_ROSTER_UPDATE()
	local numRaid  = GetNumRaidMembers()
	local numParty = GetNumPartyMembers()
	NP.IsInGroup = numRaid > 0 or numParty > 0

	wipe(NP.GroupRoles)

	if numRaid > 0 then
		for i = 1, numRaid do
			local name = GetRaidRosterInfo(i)
			if name then
				NP.GroupRoles[name] = GetPartyAssignment('MAINTANK', 'raid'..i) and 'TANK' or 'NONE'
			end
		end
	elseif numParty > 0 then
		for i = 1, numParty do
			local unit = 'party'..i
			if UnitExists(unit) then
				local name = UnitName(unit)
				if name then
					NP.GroupRoles[name] = GetPartyAssignment('MAINTANK', unit) and 'TANK' or 'NONE'
				end
			end
		end
	end
end

function NP:PLAYER_ENTERING_WORLD()
	wipe(self.Healers)
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType == 'pvp' and self.db.units.ENEMY_PLAYER.markHealers then
		self:RegisterEvent('UPDATE_BATTLEFIELD_SCORE', 'CheckBGHealers')
		self.CheckHealerTimer = self:ScheduleRepeatingTimer('CheckBGHealers', 3)
	else
		self:UnregisterEvent('UPDATE_BATTLEFIELD_SCORE')
		if self.CheckHealerTimer then
			self:CancelTimer(self.CheckHealerTimer)
			self.CheckHealerTimer = nil
		end
	end

	NP:ConfigureAll(true)
end

function NP:PLAYER_REGEN_DISABLED()
	if self.db.showFriendlyCombat == 'TOGGLE_ON' then
		SetCVar('nameplateShowFriends', 1)
	elseif self.db.showFriendlyCombat == 'TOGGLE_OFF' then
		SetCVar('nameplateShowFriends', 0)
	end

	if self.db.showEnemyCombat == 'TOGGLE_ON' then
		SetCVar('nameplateShowEnemies', 1)
	elseif self.db.showEnemyCombat == 'TOGGLE_OFF' then
		SetCVar('nameplateShowEnemies', 0)
	end
end

function NP:PLAYER_REGEN_ENABLED()
	if self.db.showFriendlyCombat == 'TOGGLE_ON' then
		SetCVar('nameplateShowFriends', 0)
	elseif self.db.showFriendlyCombat == 'TOGGLE_OFF' then
		SetCVar('nameplateShowFriends', 1)
	end

	if self.db.showEnemyCombat == 'TOGGLE_ON' then
		SetCVar('nameplateShowEnemies', 0)
	elseif self.db.showEnemyCombat == 'TOGGLE_OFF' then
		SetCVar('nameplateShowEnemies', 1)
	end
end

function NP:CheckBGHealers()
	local name, _, classToken, damageDone, healingDone
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, classToken, damageDone, healingDone = GetBattlefieldScore(i)
		if name and classToken and E.HealingClasses and E.HealingClasses[classToken] then
			name = match(name, '([^%-]+).*')
			if name and healingDone > (damageDone * 2) then
				self.Healers[name] = true
			elseif name and self.Healers[name] then
				self.Healers[name] = nil
			end
		end
	end
end

function NP:PlateFade(nameplate, timeToFade, startAlpha, endAlpha)
	if not nameplate.FadeObject then
		nameplate.FadeObject = {}
	end

	nameplate.FadeObject.timeToFade = (nameplate.isTarget and 0) or timeToFade
	nameplate.FadeObject.startAlpha = startAlpha
	nameplate.FadeObject.endAlpha   = endAlpha
	nameplate.FadeObject.diffAlpha  = endAlpha - startAlpha

	if nameplate.FadeObject.fadeTimer then
		nameplate.FadeObject.fadeTimer = 0
	else
		E:UIFrameFade(nameplate, nameplate.FadeObject)
	end
end

function NP:StyleFrame(parent, noBackdrop, point)
	point = point or parent
	local noscalemult = E.mult * UIParent:GetScale()

	if point.bordertop then return end

	if not noBackdrop then
		point.backdrop = parent:CreateTexture(nil, 'BACKGROUND')
		point.backdrop:SetAllPoints(point)
		point.backdrop:SetTexture(unpack(E.media.backdropfadecolor))
	end

	if E.PixelMode then
		point.bordertop = parent:CreateTexture()
		point.bordertop:SetPoint('TOPLEFT', point, 'TOPLEFT', -noscalemult, noscalemult)
		point.bordertop:SetPoint('TOPRIGHT', point, 'TOPRIGHT', noscalemult, noscalemult)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E.media.bordercolor))

		point.borderbottom = parent:CreateTexture()
		point.borderbottom:SetPoint('BOTTOMLEFT', point, 'BOTTOMLEFT', -noscalemult, -noscalemult)
		point.borderbottom:SetPoint('BOTTOMRIGHT', point, 'BOTTOMRIGHT', noscalemult, -noscalemult)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E.media.bordercolor))

		point.borderleft = parent:CreateTexture()
		point.borderleft:SetPoint('TOPLEFT', point, 'TOPLEFT', -noscalemult, noscalemult)
		point.borderleft:SetPoint('BOTTOMLEFT', point, 'BOTTOMLEFT', noscalemult, -noscalemult)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E.media.bordercolor))

		point.borderright = parent:CreateTexture()
		point.borderright:SetPoint('TOPRIGHT', point, 'TOPRIGHT', noscalemult, noscalemult)
		point.borderright:SetPoint('BOTTOMRIGHT', point, 'BOTTOMRIGHT', -noscalemult, -noscalemult)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E.media.bordercolor))
	else
		point.bordertop = parent:CreateTexture(nil, 'OVERLAY')
		point.bordertop:SetPoint('TOPLEFT', point, 'TOPLEFT', -noscalemult, noscalemult*2)
		point.bordertop:SetPoint('TOPRIGHT', point, 'TOPRIGHT', noscalemult, noscalemult*2)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E.media.bordercolor))

		point.bordertop.backdrop = parent:CreateTexture()
		point.bordertop.backdrop:SetPoint('TOPLEFT', point.bordertop, 'TOPLEFT', noscalemult, noscalemult)
		point.bordertop.backdrop:SetPoint('TOPRIGHT', point.bordertop, 'TOPRIGHT', -noscalemult, noscalemult)
		point.bordertop.backdrop:SetHeight(noscalemult * 3)
		point.bordertop.backdrop:SetTexture(0, 0, 0)

		point.borderbottom = parent:CreateTexture(nil, 'OVERLAY')
		point.borderbottom:SetPoint('BOTTOMLEFT', point, 'BOTTOMLEFT', -noscalemult, -noscalemult*2)
		point.borderbottom:SetPoint('BOTTOMRIGHT', point, 'BOTTOMRIGHT', noscalemult, -noscalemult*2)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E.media.bordercolor))

		point.borderbottom.backdrop = parent:CreateTexture()
		point.borderbottom.backdrop:SetPoint('BOTTOMLEFT', point.borderbottom, 'BOTTOMLEFT', noscalemult, -noscalemult)
		point.borderbottom.backdrop:SetPoint('BOTTOMRIGHT', point.borderbottom, 'BOTTOMRIGHT', -noscalemult, -noscalemult)
		point.borderbottom.backdrop:SetHeight(noscalemult * 3)
		point.borderbottom.backdrop:SetTexture(0, 0, 0)

		point.borderleft = parent:CreateTexture(nil, 'OVERLAY')
		point.borderleft:SetPoint('TOPLEFT', point, 'TOPLEFT', -noscalemult*2, noscalemult*2)
		point.borderleft:SetPoint('BOTTOMLEFT', point, 'BOTTOMLEFT', noscalemult*2, -noscalemult*2)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E.media.bordercolor))

		point.borderleft.backdrop = parent:CreateTexture()
		point.borderleft.backdrop:SetPoint('TOPLEFT', point.borderleft, 'TOPLEFT', -noscalemult, noscalemult)
		point.borderleft.backdrop:SetPoint('BOTTOMLEFT', point.borderleft, 'BOTTOMLEFT', -noscalemult, -noscalemult)
		point.borderleft.backdrop:SetWidth(noscalemult * 3)
		point.borderleft.backdrop:SetTexture(0, 0, 0)

		point.borderright = parent:CreateTexture(nil, 'OVERLAY')
		point.borderright:SetPoint('TOPRIGHT', point, 'TOPRIGHT', noscalemult*2, noscalemult*2)
		point.borderright:SetPoint('BOTTOMRIGHT', point, 'BOTTOMRIGHT', -noscalemult*2, -noscalemult*2)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E.media.bordercolor))

		point.borderright.backdrop = parent:CreateTexture()
		point.borderright.backdrop:SetPoint('TOPRIGHT', point.borderright, 'TOPRIGHT', noscalemult, noscalemult)
		point.borderright.backdrop:SetPoint('BOTTOMRIGHT', point.borderright, 'BOTTOMRIGHT', noscalemult, -noscalemult)
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

local function CopySettings(from, to)
	for setting, value in pairs(from) do
		if type(value) == 'table' and to[setting] ~= nil then
			CopySettings(from[setting], to[setting])
		else
			if to[setting] ~= nil then
				to[setting] = from[setting]
			end
		end
	end
end

function NP:ResetSettings(unit)
	CopySettings(P.nameplates.units[unit], self.db.units[unit])
end

function NP:CopySettings(from, to)
	if from == to then return end
	CopySettings(self.db.units[from], self.db.units[to])
end

function NP:ForEachPlate(functionToRun, ...)
	for nameplate in pairs(self.Plates) do
		if nameplate and nameplate.UpdateAllElements then
			self[functionToRun](self, nameplate, ...)
		end
	end
end

function NP:StyleFilterChanges(frame)
	return (frame and frame.StyleFilterChanges) or {}
end

-- Scale a nameplate by a given multiplier (called from Threat element)
function NP:ScalePlate(nameplate, scale)
	if nameplate.isTarget and NP.db.useTargetScale then
		scale = scale * NP.db.targetScale
	end
	nameplate:SetScale(scale * (E.uiscale or 1))
end

-- Alias used by StyleFilter and HealthBar
function NP:SetFrameScale(frame, scale)
	NP:ScalePlate(frame, scale)
end

-- Returns level text + r,g,b; used by Level.lua and StyleFilter
function NP:UnitLevel(frame)
	if not frame.unit then return '??', 1, 1, 1 end
	local level = UnitLevel(frame.unit)
	if level == -1 then
		return '??', 0.8, 0.05, 0.05
	end
	local color = GetQuestDifficultyColor and GetQuestDifficultyColor(level)
	if color then
		return level, color.r, color.g, color.b
	end
	return level, 1, 1, 1
end

function NP:StyleFilterEvents(nameplate)
	if not nameplate.StyleFilterChanges then
		nameplate.StyleFilterChanges = {}
	end
end

function NP:StyleFilterEventWatch(nameplate, disable)
end

function NP:StyleFilterSetVariables(nameplate)
	nameplate.isTarget = nameplate.unit and UnitIsUnit(nameplate.unit, 'target') or nil
end

-- UpdateLibAuraInfoInfo: initialises LibAuraInfo integration for aura tracking
function NP:UpdateLibAuraInfoInfo()
	-- stub: LibAuraInfo callbacks can be registered here when needed
end

-- TogleTestFrame: toggle the test nameplate frame for a given unit type (called from OptionsUI)
function NP:TogleTestFrame(unit)
	local test = _G.ElvNP_Test
	if not test then return end

	if not test:IsEnabled() or test.frameType ~= unit then
		test.frameType  = unit
		test.UnitType   = unit
		test.unitName   = unit
		test.UnitName   = unit
		test.UnitReaction = (unit == 'ENEMY_PLAYER' or unit == 'ENEMY_NPC') and 2 or 6
		test.isPlayer   = (unit == 'ENEMY_PLAYER' or unit == 'FRIENDLY_PLAYER')

		if test.RaisedElement then test.RaisedElement:Show() end
		NP:UpdatePlate(test, true)
		test:Enable()
		test:Show()
		test:UpdateAllElements('ForceUpdate')
	else
		NP:DisablePlate(test)
		test:Disable()
		test:Hide()
	end
end

-- UpdateAllNames: update name tags on all visible plates of a given unit type
-- In oUF architecture, tags are re-applied via Update_Tags during ConfigurePlates
function NP:UpdateAllNames(unit, tag)
	NP:ConfigurePlates()
end

function NP:ConfigurePlates()
	NP.SkipFading = true

	-- Update test frame if visible
	local test = _G.ElvNP_Test
	if test and test:IsEnabled() then
		NP:UpdatePlate(test, true)
		test:UpdateAllElements('ForceUpdate')
	end

	for nameplate in pairs(NP.Plates) do
		if nameplate ~= test then
			NP:UpdatePlateSize(nameplate)

			nameplate.previousType = nil
			NP:NamePlateCallBack(nameplate, 'NAME_PLATE_UNIT_ADDED')

			nameplate.StyleFilterBaseAlreadyUpdated = nil
			nameplate:UpdateAllElements('ForceUpdate')
		end
	end

	NP.SkipFading = nil
end

function NP:ConfigureAll(init)
	if not E.private.nameplates.enable then return end

	NP:StyleFilterConfigure()
	NP:PLAYER_REGEN_ENABLED()
	NP:Update_StatusBars()
	NP:ConfigurePlates()
end

function NP:CacheArenaUnits() end
function NP:CacheGroupUnits() end

function NP:Initialize()
	self.db = E.db.nameplates

	if not E.private.nameplates.enable then return end
	self.Initialized = true

	NP.thinBorders = NP.db.thinBorders
	NP.SPACING     = (NP.thinBorders or E.twoPixelsPlease) and 0 or 1
	NP.BORDER      = (NP.thinBorders and not E.twoPixelsPlease) and 1 or 2

	NP.Plates     = {}
	NP.PlateGUID  = {}
	NP.StatusBars = {}
	NP.GroupRoles = {}
	NP.multiplier = 0.35

	NP:StyleFilterInitialize()
	NP:StyleFilterConfigure()

	ElvUF:RegisterStyle('ElvNP', NP.Style)
	ElvUF:SetActiveStyle('ElvNP')

	ElvUF:SpawnNamePlates('ElvNP_', function(nameplate, event, unit)
		NP:NamePlateCallBack(nameplate, event, unit)
	end)

	NP:RegisterEvent('PLAYER_REGEN_ENABLED')
	NP:RegisterEvent('PLAYER_REGEN_DISABLED')
	NP:RegisterEvent('PLAYER_ENTERING_WORLD')
	NP:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	NP:RegisterEvent('GROUP_ROSTER_UPDATE')

	NP:GROUP_ROSTER_UPDATE()
	NP:UpdateCVars()

	-- Create test nameplate frame for OptionsUI preview
	ElvUF:Spawn('player', 'ElvNP_Test')
	local test = _G.ElvNP_Test
	if test then
		test:SetScale(1)
		test:ClearAllPoints()
		test:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 250)
		test:SetSize(NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight)
		test:SetMovable(true)
		test:RegisterForDrag('LeftButton', 'RightButton')
		test:SetScript('OnDragStart', function() test:StartMoving() end)
		test:SetScript('OnDragStop', function() test:StopMovingOrSizing() end)
		test.frameType  = 'ENEMY_NPC'
		test.UnitType   = 'ENEMY_NPC'
		test:Disable()
		NP:DisablePlate(test)
	end
end

local function InitializeCallback()
	NP:Initialize()
end

E:RegisterModule(NP:GetName(), InitializeCallback)
