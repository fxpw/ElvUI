local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
NP.LSM = E.Libs.LSM
local ElvUF = E.oUF
assert(ElvUF, 'ElvUI was unable to locate oUF.')

local _G = _G
local pairs, ipairs, wipe = pairs, ipairs, wipe
local select, unpack, type = select, unpack, type
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
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
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

-- Single OnUpdate frame to poll UnitHealth for all nameplate units.
-- UNIT_HEALTH only fires for player/target in WotLK; this covers non-targeted units.
-- Only values are updated here — color is intentionally left to events/StyleFilter.
do
	local f = CreateFrame('Frame')
	local elapsed = 0
	local tagsElapsed = 0
	local HEALTH_INTERVAL = 0.2  -- health/power bar value update rate
	local TAGS_INTERVAL   = 0.5  -- tag text update rate (name, %, etc. — less critical)
	f:SetScript('OnUpdate', function(_, dt)
		elapsed     = elapsed     + dt
		tagsElapsed = tagsElapsed + dt
		if elapsed < HEALTH_INTERVAL then return end
		local doTags = tagsElapsed >= TAGS_INTERVAL
		elapsed = 0
		if doTags then tagsElapsed = 0 end
		for plate in pairs(NP.Plates) do
			local u = plate.unit
			if u then
				-- local changed = false
				-- Update health value only when changed (avoids unnecessary StatusBar redraws)
				local h = plate.Health
				if h then
					local cur = UnitHealth(u)
					local max = UnitHealthMax(u)
					if max and max > 0 then
						if h._np_max ~= max then
							h._np_max = max
							h:SetMinMaxValues(0, max)
							-- changed = true
						end
						if h._np_cur ~= cur then
							h._np_cur = cur
							h:SetValue(cur)
							-- changed = true
						end
					end
				end
				-- Update power value only when changed
				local pw = plate.Power
				if pw and pw:IsShown() then
					local cur = UnitPower(u)
					local max = UnitPowerMax(u)
					if max and max > 0 then
						if pw._np_max ~= max then
							pw._np_max = max
							pw:SetMinMaxValues(0, max)
							-- changed = true
						end
						if pw._np_cur ~= cur then
							pw._np_cur = cur
							pw:SetValue(cur)
							-- changed = true
						end
					end
				end
				-- Update tag texts only on the slower cadence; the bar already reflects current value.
				if doTags then
					plate:UpdateTags()
				end

				-- Sync frame levels to engine plate: engine can reassign plate levels
				-- dynamically (stacking, targeting). Skip if StyleFilter boost is active.
				if not plate.appliedFrameLevelBoost then
					local engineParent = plate._engineParent or plate:GetParent()
					plate._engineParent = engineParent
					local engineLevel = engineParent and engineParent:GetFrameLevel()
					if engineLevel and plate._npBase ~= engineLevel then
						plate._npBase = engineLevel
						plate.Health:SetFrameLevel(engineLevel + 1)
						if plate.Power and plate.Power:IsShown() then plate.Power:SetFrameLevel(engineLevel + 1) end
						if plate.Castbar and plate.Castbar:IsShown() then plate.Castbar:SetFrameLevel(engineLevel + 2) end
						local Buffs = plate.Buffs
						if Buffs and Buffs:IsShown() then
							Buffs:SetFrameLevel(engineLevel + 2)
							local n = Buffs.visibleAuras or Buffs.visibleBuffs or #Buffs
							for i = 1, n do
								local btn = Buffs[i]
								if btn and btn:IsShown() then
									btn:SetFrameLevel(engineLevel + 3)
									local cd = btn.cd
									if cd then
										cd:SetFrameLevel(engineLevel + 4)
										if cd.timer then cd.timer:SetFrameLevel(engineLevel + 5) end
									end
								end
							end
						end
						local Debuffs = plate.Debuffs
						if Debuffs and Debuffs:IsShown() then
							Debuffs:SetFrameLevel(engineLevel + 2)
							local n = Debuffs.visibleAuras or Debuffs.visibleDebuffs or #Debuffs
							for i = 1, n do
								local btn = Debuffs[i]
								if btn and btn:IsShown() then
									btn:SetFrameLevel(engineLevel + 3)
									local cd = btn.cd
									if cd then
										cd:SetFrameLevel(engineLevel + 4)
										if cd.timer then cd.timer:SetFrameLevel(engineLevel + 5) end
									end
								end
							end
						end
						if plate.ClassPower and plate.ClassPower:IsShown() then
							plate.ClassPower:SetFrameLevel(engineLevel + 2)
							for i = 1, #plate.ClassPower do
								local cp = plate.ClassPower[i]
								if cp then cp:SetFrameLevel(engineLevel + 3) end
							end
						end
					end
				end
			end
		end
	end)
end

do
	local empty = {}
	function NP:PlateDB(nameplate)
		if nameplate and nameplate.plateDBOverride then
			return nameplate.plateDBOverride
		end
		return (nameplate and NP.db.units and NP.db.units[nameplate.frameType]) or empty
	end
end

local NP_ENGINE_CVARS = {
	loadDistance = { cvar = 'nameplateMaxDistance', driver = true },
	predictedHealthAndPower = { cvar = 'nameplatePredictedHealthAndPower', bool = true },
	offsetY = { cvar = 'nameplateOffsetY', driver = true },
	showOnlyNames = { cvar = 'nameplateShowOnlyNames', driver = true },
	showClassColorFriendly = { cvar = 'ShowClassColorInFriendlyNameplate', bool = true },
	showNameClassColorFriendly = { cvar = 'ShowNameClassColorInFriendlyNameplate', bool = true },
	showDebuffsOnFriendly = { cvar = 'nameplateShowDebuffsOnFriendly', bool = true },
	otherAtBase = { cvar = 'nameplateOtherAtBase', bool = true, driver = true, plates = true },
	targetRadialPosition = { cvar = 'nameplateTargetRadialPosition', driver = true },
	horizontalScale = { cvar = 'NamePlateHorizontalScale', driver = true },
	verticalScale = { cvar = 'NamePlateVerticalScale', driver = true },
	globalScale = { cvar = 'nameplateGlobalScale', driver = true },
	selectedScale = { cvar = 'nameplateSelectedScale', driver = true },
	occludedAlphaMult = { cvar = 'nameplateOccludedAlphaMult' },
	selectedAlpha = { cvar = 'nameplateSelectedAlpha' },
	notSelectedAlpha = { cvar = 'nameplateNotSelectedAlpha' },
	showSelf = { cvar = 'nameplateShowSelf', bool = true, driver = true },
	personalClickThrough = { cvar = 'NameplatePersonalClickThrough', bool = true },
	selfAlpha = { cvar = 'nameplateSelfAlpha' },
	personalShowAlways = { cvar = 'NameplatePersonalShowAlways', bool = true, driver = true },
	personalShowInCombat = { cvar = 'NameplatePersonalShowInCombat', bool = true, driver = true },
	personalShowWithTarget = { cvar = 'NameplatePersonalShowWithTarget', driver = true },
	personalOffsetY = { cvar = 'NameplatePersonalOffsetY', driver = true },
	resourceOnTarget = { cvar = 'nameplateResourceOnTarget', bool = true, driver = true },
	classResourceTopInset = { cvar = 'nameplateClassResourceTopInset', driver = true },
}

function NP:RefreshNamePlateDriver()
	if _G.NamePlateDriverFrame and NamePlateDriverFrame.UpdateNamePlateOptions then
		NamePlateDriverFrame:UpdateNamePlateOptions()
	end
end

-- Sirus: plain GetCVar/SetCVar(cvar [, value]) — no extra args
function NP:GetEngineCVar(key)
	local db = NP.db or E.db.nameplates
	local default = (db and db.engine and db.engine[key]) or P.nameplates.engine[key]

	if key == 'dynamicScale' then
		local v = GetCVar('nameplateMinScale')
		return v and tonumber(v) < 1 or default
	end
	if key == 'dynamicAlpha' then
		local v = GetCVar('nameplateMinAlpha')
		return v and tonumber(v) < 1 or default
	end

	local entry = NP_ENGINE_CVARS[key]
	if not entry then return default end

	local v = GetCVar(entry.cvar)
	if v == nil then return default end
	if entry.bool then
		return v == '1'
	end
	return tonumber(v) or v
end

function NP:SetEngineCVar(cvar, value, isBool)
	local strValue = isBool and (value and '1' or '0') or tostring(value)
	if GetCVar(cvar) ~= strValue then
		SetCVar(cvar, strValue)
	end
end

function NP:ApplyDynamicScale(e)
	if e.dynamicScale then
		NP:SetEngineCVar('nameplateMinScale', '0.6')
		NP:SetEngineCVar('nameplateMaxScale', '1')
	else
		NP:SetEngineCVar('nameplateMinScale', '1')
		NP:SetEngineCVar('nameplateMaxScale', '1')
	end
end

function NP:ApplyDynamicAlpha(e)
	if e.dynamicAlpha then
		NP:SetEngineCVar('nameplateMinAlpha', '0.6')
		NP:SetEngineCVar('nameplateMaxAlpha', '1')
	else
		NP:SetEngineCVar('nameplateMinAlpha', '1')
		NP:SetEngineCVar('nameplateMaxAlpha', '1')
	end
end

function NP:ApplyEngineCVar(entry, value)
	NP:SetEngineCVar(entry.cvar, value, entry.bool)
end

function NP:ApplyEngineOption(key)
	NP.db = NP.db or E.db.nameplates
	NP:EnsureEngineDB()
	local e = NP.db.engine

	if key == 'dynamicScale' then
		NP:ApplyDynamicScale(e)
		NP:RefreshNamePlateDriver()
		return
	elseif key == 'dynamicAlpha' then
		NP:ApplyDynamicAlpha(e)
		return
	end

	local entry = NP_ENGINE_CVARS[key]
	if not entry then return end

	if key == 'selectedScale' then
		NP:ApplyEngineCVar(entry, NP.db.useTargetScale and NP.db.targetScale or e.selectedScale)
	elseif key == 'notSelectedAlpha' then
		NP:ApplyEngineCVar(entry, NP.db.nonTargetTransparency or e.notSelectedAlpha)
	else
		NP:ApplyEngineCVar(entry, e[key])
	end

	if entry.driver then
		NP:RefreshNamePlateDriver()
	end
	if entry.plates and NP.Initialized then
		NP:ConfigurePlates()
	end
end

local function NP_CVarBool(cvar, default)
	local v = GetCVar(cvar)
	if v == nil then return default end
	return v == '1'
end

local function NP_CVarNum(cvar, default)
	local v = GetCVar(cvar)
	if v == nil then return default end
	return tonumber(v) or default
end

function NP:ImportEngineFromCVars(e)
	e.loadDistance = NP_CVarNum('nameplateMaxDistance', e.loadDistance or P.nameplates.engine.loadDistance)
	e.predictedHealthAndPower = NP_CVarBool('nameplatePredictedHealthAndPower', e.predictedHealthAndPower)
	e.dynamicScale = NP_CVarNum('nameplateMinScale', 1) < 1
	e.dynamicAlpha = NP_CVarNum('nameplateMinAlpha', 1) < 1
	e.offsetY = NP_CVarNum('nameplateOffsetY', e.offsetY)
	e.showOnlyNames = NP_CVarNum('nameplateShowOnlyNames', e.showOnlyNames)
	e.showClassColorFriendly = NP_CVarBool('ShowClassColorInFriendlyNameplate', e.showClassColorFriendly)
	e.showNameClassColorFriendly = NP_CVarBool('ShowNameClassColorInFriendlyNameplate', e.showNameClassColorFriendly)
	e.showDebuffsOnFriendly = NP_CVarBool('nameplateShowDebuffsOnFriendly', e.showDebuffsOnFriendly)
	e.otherAtBase = NP_CVarBool('nameplateOtherAtBase', e.otherAtBase)
	e.targetRadialPosition = NP_CVarNum('nameplateTargetRadialPosition', e.targetRadialPosition)
	e.horizontalScale = NP_CVarNum('NamePlateHorizontalScale', e.horizontalScale)
	e.verticalScale = NP_CVarNum('NamePlateVerticalScale', e.verticalScale)
	e.globalScale = NP_CVarNum('nameplateGlobalScale', e.globalScale)
	e.selectedScale = NP_CVarNum('nameplateSelectedScale', e.selectedScale)
	e.occludedAlphaMult = NP_CVarNum('nameplateOccludedAlphaMult', e.occludedAlphaMult)
	e.selectedAlpha = NP_CVarNum('nameplateSelectedAlpha', e.selectedAlpha)
	e.notSelectedAlpha = NP_CVarNum('nameplateNotSelectedAlpha', e.notSelectedAlpha)
	e.showSelf = NP_CVarBool('nameplateShowSelf', e.showSelf)
	e.personalClickThrough = NP_CVarBool('NameplatePersonalClickThrough', e.personalClickThrough)
	e.selfAlpha = NP_CVarNum('nameplateSelfAlpha', e.selfAlpha)
	e.personalShowAlways = NP_CVarBool('NameplatePersonalShowAlways', e.personalShowAlways)
	e.personalShowInCombat = NP_CVarBool('NameplatePersonalShowInCombat', e.personalShowInCombat)
	e.personalShowWithTarget = NP_CVarNum('NameplatePersonalShowWithTarget', e.personalShowWithTarget)
	e.personalOffsetY = NP_CVarNum('NameplatePersonalOffsetY', e.personalOffsetY)
	e.resourceOnTarget = NP_CVarBool('nameplateResourceOnTarget', e.resourceOnTarget)
	e.classResourceTopInset = NP_CVarNum('nameplateClassResourceTopInset', e.classResourceTopInset)
end

function NP:EnsureEngineDB()
	NP.db = NP.db or E.db.nameplates
	if not NP.db.engine then
		NP.db.engine = E:CopyTable(P.nameplates.engine)
		NP:ImportEngineFromCVars(NP.db.engine)
	end

	local e = NP.db.engine
	if e.loadDistance == nil then
		local legacy = NP.db.plateSize and NP.db.plateSize.loadDistance
		e.loadDistance = legacy or P.nameplates.engine.loadDistance
	end
end

function NP:ResetEngineDefaults()
	NP.db.engine = E:CopyTable(P.nameplates.engine)
	NP:UpdateCVars()
	NP:ConfigureAll()
end

function NP:UpdateCVars()
	local db = NP.db
	NP:EnsureEngineDB()
	local e = db.engine

	NP:SetEngineCVar('nameplateEnableNew', '1')
	NP:SetEngineCVar('showVKeyCastbar', '1')
	NP:SetEngineCVar('nameplateAllowOverlap', db.motionType == 'STACKED' and '0' or '1')

	NP:ApplyDynamicScale(e)
	NP:ApplyDynamicAlpha(e)

	for key in pairs(NP_ENGINE_CVARS) do
		NP:ApplyEngineOption(key)
	end

	NP:RefreshNamePlateDriver()
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
	if nameplate == NP.TestFrame then return end

	local unit = nameplate.unit
	if not unit then return end

	if UnitIsUnit(unit, 'player') then
		nameplate.frameType = 'PLAYER'
		nameplate.isPlayer  = true
		nameplate.classFile = select(2, UnitClass('player'))
		nameplate.UnitType     = 'PLAYER'
		nameplate.UnitName     = nameplate.unitName
		nameplate.UnitReaction = nameplate.reaction
		nameplate.UnitClass    = nameplate.classFile
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
	nameplate.UnitClass    = nameplate.classFile
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
		if ft == 'PLAYER' then
			nameplate:SetSize(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
		elseif ft == 'FRIENDLY_PLAYER' or ft == 'FRIENDLY_NPC' then
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

function NP:StylePlate(nameplate)
	if nameplate:GetName() == 'ElvNP_Test' then
		NP.TestFrame = nameplate
	end

	local scale = (nameplate == NP.TestFrame) and 1 or (E.uiscale or 1)
	nameplate:SetScale(scale)
	nameplate:ClearAllPoints()
	nameplate:SetPoint('CENTER')
	nameplate:SetFrameStrata('BACKGROUND') -- keep plates under Minimap/UI frames
	nameplate._npBase = nameplate:GetFrameLevel()

	nameplate.Health = NP:Construct_Health(nameplate)
	nameplate.Health.Text = NP:Construct_TagText(nameplate.Health)
	nameplate.RaisedElement = nameplate.Health -- legacy alias: all overlay elements share Health's framelevel

	NP:Construct_HealPrediction(nameplate)

	nameplate.Power = NP:Construct_Power(nameplate)
	nameplate.Power.Text = NP:Construct_TagText(nameplate.Power)

	nameplate.Name  = NP:Construct_Name(nameplate.Health)
	nameplate.Level = NP:Construct_Level(nameplate.Health)

	nameplate.ClassificationIndicator = NP:Construct_ClassificationIndicator(nameplate.RaisedElement)
	nameplate.Castbar             = NP:Construct_Castbar(nameplate)
	nameplate.Portrait            = NP:Construct_Portrait(nameplate.RaisedElement)
	nameplate.PvPIndicator        = NP:Construct_PvPIndicator(nameplate.RaisedElement)
	nameplate.RaidTargetIndicator = NP:Construct_RaidTargetIndicator(nameplate.RaisedElement)
	nameplate.TargetIndicator     = NP:Construct_TargetIndicator(nameplate)
	nameplate.ThreatIndicator     = NP:Construct_ThreatIndicator(nameplate.RaisedElement)
	nameplate.Highlight           = NP:Construct_Highlight(nameplate)
	nameplate.ClassPower          = NP:Construct_ClassPower(nameplate)
	nameplate.Cutaway             = NP:Construct_Cutaway(nameplate)
	nameplate.CutawayHealth       = nameplate.Cutaway.Health -- legacy alias

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
	NP:Update_PvPIndicator(nameplate)

	local db = NP:PlateDB(nameplate)
	if not db.enable then
		NP:DisablePlate(nameplate)

		if nameplate.RaisedElement:IsShown() then
			nameplate.RaisedElement:Hide()
		end
	elseif updateBase then
		NP:Update_Tags(nameplate)
		NP:Update_CustomTexts(nameplate)
		NP:Update_Health(nameplate)
		NP:Update_HealPrediction(nameplate)
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
	'HealthPrediction',
	'Power',
	'ClassificationIndicator',
	'Castbar',
	'ThreatIndicator',
	'TargetIndicator',
	'ClassPower',
	'Auras',
	'PvPIndicator',
}

function NP:DisablePlate(nameplate)
	for _, element in ipairs(NP.DisableElements) do
		if nameplate:IsElementEnabled(element) then
			nameplate:DisableElement(element)
		end
	end

	if nameplate.customTexts then
		for _, object in pairs(nameplate.customTexts) do
			nameplate:Untag(object)
			object:Hide()
		end
	end
end

function NP:UpdatePlateBase(nameplate)
	if nameplate == NP.TestFrame then
		NP:UpdatePlate(nameplate, true)
		nameplate.previousType = nameplate.frameType
		nameplate.StyleFilterBaseAlreadyUpdated = true
		return
	end

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
		NP:RegisterAuraUnitEvents(nameplate, unit)

		NP:StyleFilterEventWatch(nameplate)
		NP:StyleFilterSetVariables(nameplate)

		if NP.db.fadeIn and nameplate ~= NP.TestFrame then
			NP:PlateFade(nameplate, 1, 0, 1)
		end

		if nameplate == NP.TestFrame then
			return
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
		NP:UnregisterAuraUnitEvents(nameplate)

		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate)
		end

		NP:StyleFilterEventWatch(nameplate, true)
		NP:StyleFilterClearVariables(nameplate)

		nameplate.Health.cur  = nil
		nameplate.Health._np_cur = nil
		nameplate.Health._np_max = nil
		nameplate.Power.cur   = nil
		nameplate.Power._np_cur  = nil
		nameplate.Power._np_max  = nil
		nameplate.npcID       = nil
		nameplate.previousType = nil  -- force full re-init on next UNIT_ADDED (same frame, new unit)
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

function NP:PLAYER_REGEN_DISABLED() end

function NP:PLAYER_REGEN_ENABLED() end

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

-- Thin alias around the global UnitExists; used by retail-derived StyleFilter helpers.
function NP:UnitExists(unit)
	return unit and UnitExists(unit) or nil
end

-- Hook for StyleFilter NameOnly transitions; ClassPower/ClassBar isn't ported on WotLK,
-- so this currently just refreshes the TargetIndicator if present. Safe no-op otherwise.
function NP:SetupTarget(nameplate, _)
	if nameplate and nameplate.TargetIndicator and nameplate:IsElementEnabled('TargetIndicator') then
		nameplate.TargetIndicator:ForceUpdate()
	end
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

-- StyleFilterEvents / StyleFilterEventWatch / StyleFilterSetVariables / StyleFilterClearVariables
-- now defined in StyleFilter.lua (retail-faithful pooler + fake-register pattern).

-- UpdateLibAuraInfoInfo: initialises LibAuraInfo integration for aura tracking
function NP:UpdateLibAuraInfoInfo()
	-- stub: LibAuraInfo callbacks can be registered here when needed
end

function NP:RefreshTestFrame()
	local test = NP.TestFrame
	if not test or not test:IsEnabled() then return end

	NP:UpdatePlateSize(test)
	NP:NamePlateCallBack(test, 'NAME_PLATE_UNIT_ADDED', test.unit)
	test:UpdateAllElements('ForceUpdate')
end

-- TogleTestFrame: toggle the test nameplate frame for a given unit type (called from OptionsUI)
function NP:TogleTestFrame(unit)
	local test = NP.TestFrame
	if not test then return end

	if not test:IsEnabled() or test.frameType ~= unit then
		test.frameType = unit
		test:Enable()
		test:Show()
		NP:RefreshTestFrame()
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

	if NP.TestFrame and NP.TestFrame:IsEnabled() then
		NP:RefreshTestFrame()
	end

	local test = NP.TestFrame
	for nameplate in pairs(NP.Plates) do
		if nameplate ~= test then
			NP:UpdatePlateSize(nameplate)

			nameplate.previousType = nil
			NP:NamePlateCallBack(nameplate, 'NAME_PLATE_UNIT_ADDED')

			NP:StyleFilterUpdate(nameplate, 'PoolerUpdate') -- re-evaluate filter conditions after reconfigure

			nameplate.StyleFilterBaseAlreadyUpdated = nil
			nameplate:UpdateAllElements('ForceUpdate')
		end
	end

	NP.SkipFading = nil
end

function NP:ConfigureAll(init)
	if not E.private.nameplates.enable then return end

	NP:UpdateCVars()
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
	NP.multiplier = (NP.db.colors and NP.db.colors.healthBgMultiplier) or 0.35

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

	-- Class resources on nameplates
	if E.myclass == 'ROGUE' or E.myclass == 'DRUID' then
		NP:RegisterEvent('UNIT_COMBO_POINTS',     'ClassPower_UNIT_COMBO_POINTS')
		NP:RegisterEvent('PLAYER_TARGET_CHANGED', 'ClassPower_PLAYER_TARGET_CHANGED')
		NP:RegisterEvent('PLAYER_REGEN_ENABLED',  'ClassPower_PLAYER_REGEN')
		NP:RegisterEvent('PLAYER_REGEN_DISABLED', 'ClassPower_PLAYER_REGEN')
		NP:ClassPower_HookBlizzardBars()
		NP:ClassPower_UpdateRuneFrameVisibility()
	elseif E.myclass == 'DEATHKNIGHT' then
		NP:RegisterEvent('RUNE_POWER_UPDATE',     'ClassPower_RUNE_POWER_UPDATE')
		NP:RegisterEvent('RUNE_TYPE_UPDATE',      'ClassPower_RUNE_TYPE_UPDATE')
		NP:RegisterEvent('PLAYER_TARGET_CHANGED', 'ClassPower_PLAYER_TARGET_CHANGED')
		NP:RegisterEvent('PLAYER_REGEN_ENABLED',  'ClassPower_PLAYER_REGEN')
		NP:RegisterEvent('PLAYER_REGEN_DISABLED', 'ClassPower_PLAYER_REGEN')
		NP:ClassPower_HookBlizzardBars()
		NP:ClassPower_UpdateRuneFrameVisibility()
	end

	NP:GROUP_ROSTER_UPDATE()

	NP:UpdateCVars()

	-- Create test nameplate frame for OptionsUI preview
	ElvUF:Spawn('player', 'ElvNP_Test')
	local test = NP.TestFrame
	if test then
		UnregisterUnitWatch(test)
		test:ClearAllPoints()
		test:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 250)
		test:SetMovable(true)
		test:RegisterForDrag('LeftButton', 'RightButton')
		test:SetScript('OnDragStart', function() test:StartMoving() end)
		test:SetScript('OnDragStop', function() test:StopMovingOrSizing() end)
		test.frameType = 'ENEMY_NPC'
		NP:UpdatePlateSize(test)
		test:Disable()
		NP:DisablePlate(test)
	end
end

local function InitializeCallback()
	NP:Initialize()
end

E:RegisterModule(NP:GetName(), InitializeCallback)
