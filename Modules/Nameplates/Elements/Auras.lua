local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local _G = _G
local wipe = wipe
local unpack = unpack
local CreateFrame = CreateFrame
local strsplit = strsplit
local UnitIsFriend = UnitIsFriend
local UnitCanAttack = UnitCanAttack
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local ceil, min = math.ceil, math.min

function NP:GetAuraIconSize(db)
	if not db then return 27, 27 end

	local width = db.size
	if not width or width <= 0 then
		width = 27
	end

	if db.keepSizeRatio ~= false then
		return width, width
	end

	local height = db.height
	if not height or height <= 0 then
		height = width
	end

	return width, height
end

function NP:SetAuraIconTexCoords(texture, frame)
	if texture and frame then
		texture:SetTexCoord(E:CropRatio(frame))
	end
end

local NP_PLATE_POWER_EVENTS = {
	'UNIT_MANA',
	'UNIT_RAGE',
	'UNIT_FOCUS',
	'UNIT_ENERGY',
	'UNIT_RUNIC_POWER',
	'UNIT_MAXMANA',
	'UNIT_MAXRAGE',
	'UNIT_MAXFOCUS',
	'UNIT_MAXENERGY',
	'UNIT_MAXRUNIC_POWER',
	'UNIT_DISPLAYPOWER',
}

local NP_PLATE_POWER_EVENT_SET = {}
for i = 1, #NP_PLATE_POWER_EVENTS do
	NP_PLATE_POWER_EVENT_SET[NP_PLATE_POWER_EVENTS[i]] = true
end

local function NP_ShouldTrackAuras(nameplate)
	if not nameplate then return false end
	local db = NP:PlateDB(nameplate)
	return db and not db.nameOnly and (db.buffs.enable or db.debuffs.enable)
end

local function NP_FormatUsesPowerTag(fmt)
	if not fmt or fmt == '' then return false end
	local lower = fmt:lower()
	return lower:find('power', 1, true) or lower:find('pp', 1, true) or lower:find('mana', 1, true)
		or lower:find('energy', 1, true) or lower:find('rage', 1, true) or lower:find('runic', 1, true)
		or lower:find('focus', 1, true)
end

local function NP_ShouldTrackPower(nameplate)
	if not nameplate then return false end
	local db = NP:PlateDB(nameplate)
	if not db or db.nameOnly then return false end
	if db.power and db.power.enable then return true end

	local hText = db.health and db.health.text
	if hText and hText.enable and NP_FormatUsesPowerTag(hText.textFormat or hText.format) then
		return true
	end

	local pText = db.power and db.power.text
	if pText and pText.enable and NP_FormatUsesPowerTag(pText.textFormat or pText.format) then
		return true
	end

	return false
end

local function NP_ShouldTrackName(nameplate)
	if not nameplate then return false end
	local db = NP:PlateDB(nameplate)
	if not db or db.nameOnly then return false end
	local nameDB = db.name
	return nameDB and nameDB.enable and nameDB.textFormat and nameDB.textFormat ~= ''
end

function NP:UpdatePlateName(nameplate)
	if not nameplate or not nameplate.unit then return end

	nameplate.unitName, nameplate.unitRealm = UnitName(nameplate.unit)

	if nameplate.Name and nameplate.Name.UpdateTag then
		nameplate.Name:UpdateTag()
	end
end

function NP:UpdatePlatePower(nameplate)
	if not nameplate or not nameplate.unit then return end

	if nameplate.Power and nameplate.Power.ForceUpdate and nameplate:IsElementEnabled('Power') then
		nameplate.Power:ForceUpdate()
	end

	local db = NP:PlateDB(nameplate)
	local hText = db.health and db.health.text
	if hText and hText.enable and nameplate.Health and nameplate.Health.Text and nameplate.Health.Text.UpdateTag then
		nameplate.Health.Text:UpdateTag()
	end

	local pText = db.power and db.power.text
	if pText and pText.enable and nameplate.Power and nameplate.Power.Text and nameplate.Power.Text.UpdateTag then
		nameplate.Power.Text:UpdateTag()
	end
end

local function NP_UnregisterPlateUnitEvent(frame, event, unit)
	if frame.UnregisterUnitEvent then
		frame:UnregisterUnitEvent(event, unit)
	else
		frame:UnregisterEvent(event)
	end
end

local function NP_RegisterPlateUnitEvent(frame, event, unit)
	frame:RegisterUnitEvent(event, unit)
end

local function NP_UnregisterNameplateUnitEvents(nameplate)
	if not nameplate then return end

	local defaults = NP.StyleFilterDefaultEvents
	if defaults then
		for event, unitless in pairs(defaults) do
			if not unitless then
				nameplate:UnregisterEvent(event)
			end
		end
	end
end

local function NP_PlateUsesAuraTags(nameplate)
	if not nameplate then return false end

	local function usesAuraTag(fmt)
		if not fmt or fmt == '' then return false end
		return fmt:find('[category:', 1, true) or fmt:find('[vip:', 1, true)
			or fmt:find('[premium:', 1, true) or fmt:find('[zodiac:', 1, true)
	end

	local db = NP:PlateDB(nameplate)
	if db.name and usesAuraTag(db.name.textFormat or db.name.format) then return true end
	if db.level and usesAuraTag(db.level.textFormat or db.level.format) then return true end
	if db.health and db.health.text and usesAuraTag(db.health.text.textFormat or db.health.text.format) then return true end
	if db.power and db.power.text and usesAuraTag(db.power.text.textFormat or db.power.text.format) then return true end

	local customDB = db.customTexts
	if customDB then
		for _, objectDB in pairs(customDB) do
			if usesAuraTag(objectDB.textFormat or objectDB.format) then return true end
		end
	end

	return false
end

function NP:CollectPlateUnitEvents(nameplate)
	local events = {}

	local function add(event)
		if event then events[event] = true end
	end

	if NP_ShouldTrackAuras(nameplate) or NP_PlateUsesAuraTags(nameplate) then
		add('UNIT_AURA')
	end
	if NP_ShouldTrackName(nameplate) then
		add('UNIT_NAME_UPDATE')
	end
	if NP_ShouldTrackPower(nameplate) then
		for i = 1, #NP_PLATE_POWER_EVENTS do
			add(NP_PLATE_POWER_EVENTS[i])
		end
	end

	local db = NP:PlateDB(nameplate)
	if db.eliteIcon and db.eliteIcon.enable then
		add('UNIT_CLASSIFICATION_CHANGED')
	end

	local plateEvents = NP.StyleFilterPlateEvents
	local defaults = NP.StyleFilterDefaultEvents
	if plateEvents and defaults then
		for event, active in pairs(plateEvents) do
			if active and not defaults[event] then
				add(event)
			end
		end
	end

	return events
end

function NP:UpdatePlateAuraTags(nameplate)
	local function refresh(fs)
		if fs and fs.UpdateTag then fs:UpdateTag() end
	end

	refresh(nameplate.Name)
	refresh(nameplate.Level)
	if nameplate.Health and nameplate.Health.Text then refresh(nameplate.Health.Text) end
	if nameplate.Power and nameplate.Power.Text then refresh(nameplate.Power.Text) end

	if nameplate.customTexts then
		for _, fs in pairs(nameplate.customTexts) do
			refresh(fs)
		end
	end
end

function NP.PlateUnitEvent_OnEvent(buffs, event, unit)
	local nameplate = buffs.nameplate
	if not nameplate or not nameplate.unit then return end
	if unit and not UnitIsUnit(unit, nameplate.unit) then return end

	if event == 'UNIT_AURA' then
		if nameplate.Debuffs and nameplate.Debuffs.ForceUpdate then
			nameplate.Debuffs:ForceUpdate()
		end
		if nameplate.Buffs and nameplate.Buffs.ForceUpdate then
			nameplate.Buffs:ForceUpdate()
		end
		NP:UpdatePlateAuraTags(nameplate)
	elseif event == 'UNIT_NAME_UPDATE' then
		NP:UpdatePlateName(nameplate)
	elseif event == 'UNIT_CLASSIFICATION_CHANGED' then
		if nameplate.ClassificationIndicator and nameplate:IsElementEnabled('ClassificationIndicator') then
			nameplate:UpdateAllElements('UNIT_CLASSIFICATION_CHANGED')
		end
	elseif NP_PLATE_POWER_EVENT_SET[event] then
		NP:UpdatePlatePower(nameplate)
	end

	if NP.StyleFilterHandleUnitEvent then
		NP:StyleFilterHandleUnitEvent(nameplate, event, unit)
	end
end

function NP:UnregisterAuraUnitEvents(nameplate)
	local buffs = nameplate and nameplate.Buffs_
	local unit = buffs and buffs._npPlateUnit
	if not buffs or not unit then return end

	if buffs._npRegisteredUnitEvents then
		for event in pairs(buffs._npRegisteredUnitEvents) do
			NP_UnregisterPlateUnitEvent(buffs, event, unit)
		end
		wipe(buffs._npRegisteredUnitEvents)
	end

	buffs._npPlateUnit = nil
end

function NP:RegisterAuraUnitEvents(nameplate, unit)
	unit = unit or nameplate.unit
	local events = NP:CollectPlateUnitEvents(nameplate)

	if not unit or not next(events) then
		NP:UnregisterAuraUnitEvents(nameplate)
		return
	end

	local buffs = nameplate.Buffs_
	if not buffs or not buffs.RegisterUnitEvent then return end

	if buffs._npPlateUnit == unit and buffs._npRegisteredUnitEvents then
		local same = true
		for event in pairs(events) do
			if not buffs._npRegisteredUnitEvents[event] then
				same = false
				break
			end
		end
		if same then
			for event in pairs(buffs._npRegisteredUnitEvents) do
				if not events[event] then
					same = false
					break
				end
			end
		end
		if same then return end
	end

	NP:UnregisterAuraUnitEvents(nameplate)
	NP_UnregisterNameplateUnitEvents(nameplate)

	buffs:SetScript('OnEvent', NP.PlateUnitEvent_OnEvent)
	buffs._npRegisteredUnitEvents = {}

	for event in pairs(events) do
		NP_RegisterPlateUnitEvent(buffs, event, unit)
		buffs._npRegisteredUnitEvents[event] = true
	end

	buffs._npPlateUnit = unit
end

-- Custom AuraFilter for nameplates — reads self.db (the aura frame's db) directly,
-- because UF:AuraFilter reads parent.db which is not set on nameplate frames.
local function NP_AuraFilter(self, unit, button, name, _, _, _, debuffType, duration, expiration, caster, isStealable, _,
							 spellID)
	if not name then return end

	local db = self.db
	if not db then return true end

	local isPlayer      = (caster == 'player' or caster == 'vehicle')
	local isFriend      = unit and UnitIsFriend('player', unit) and not UnitCanAttack('player', unit)

	button.isPlayer     = isPlayer
	button.isFriend     = isFriend
	button.isStealable  = isStealable
	button.dtype        = debuffType
	button.duration     = duration
	button.expiration   = expiration
	button.name         = name
	button.spellID      = spellID
	button.owner        = caster
	button.spell        = name
	button.priority     = 0

	local noDuration    = (not duration or duration == 0)
	local maxDuration   = db.maxDuration or 0
	local minDuration   = db.minDuration or 0
	local allowDuration = noDuration or (duration and duration > 0
		and (maxDuration == 0 or duration <= maxDuration)
		and (minDuration == 0 or duration >= minDuration))

	if db.priority and db.priority ~= '' then
		local isUnit                     = unit and caster and UnitIsUnit(unit, caster)
		local canDispell                 = (self.type == 'buffs' and isStealable)
			or (self.type == 'debuffs' and debuffType and E:IsDispellableByMe(debuffType))
		local filterCheck, spellPriority = UF:CheckFilter(name, caster, spellID, isFriend, isPlayer,
			isUnit, allowDuration, noDuration, canDispell, strsplit(',', db.priority))
		if spellPriority then button.priority = spellPriority end
		return filterCheck
	end

	return allowDuration and true
end

-- Smart aura position: fluid PostUpdate callbacks (NP-specific, since UF's use db.perrow/numrows).
-- Non-fluid modes use the local NP_UpdateBuffsHeaderPosition / NP_UpdateDebuffsHeaderPosition
-- callbacks (defined below) because those only do position math with no db field lookups.
local function NP_GetAuraRowHeight(auras)
	return auras.sizeHeight or auras.size or 27
end

local function NP_UpdateBuffsHeight(self)
	local iconHeight = NP_GetAuraRowHeight(self)
	local n = self.visibleBuffs or 0
	if n > 0 then
		self:Height(iconHeight * min(ceil(n / (self.numAuras or 5)), self.numRows or 1))
	else
		self:Height(iconHeight)
	end
end

local function NP_UpdateDebuffsHeight(self)
	local iconHeight = NP_GetAuraRowHeight(self)
	local n = self.visibleDebuffs or 0
	if n > 0 then
		self:Height(iconHeight * min(ceil(n / (self.numAuras or 5)), self.numRows or 1))
	else
		self:Height(iconHeight)
	end
end

-- Non-fluid BUFFS_ON_DEBUFFS: PostUpdate on Debuffs — reposition Buffs
local function NP_UpdateBuffsHeaderPosition(self)
	local nameplate = self.nameplate
	if not nameplate then return end
	local Buffs = nameplate.Buffs
	local Debuffs = nameplate.Debuffs
	if not (Buffs and Debuffs) then return end
	if (self.visibleDebuffs or 0) == 0 then
		Buffs:ClearAllPoints()
		Buffs:Point(Debuffs.point, Debuffs.attachTo, Debuffs.anchorPoint, Debuffs.xOffset, Debuffs.yOffset)
	else
		Buffs:ClearAllPoints()
		Buffs:Point(Buffs.point, Buffs.attachTo, Buffs.anchorPoint, Buffs.xOffset, Buffs.yOffset)
	end
end

-- Non-fluid DEBUFFS_ON_BUFFS: PostUpdate on Buffs — reposition Debuffs
local function NP_UpdateDebuffsHeaderPosition(self)
	local nameplate = self.nameplate
	if not nameplate then return end
	local Buffs = nameplate.Buffs
	local Debuffs = nameplate.Debuffs
	if not (Buffs and Debuffs) then return end
	if (self.visibleBuffs or 0) == 0 then
		Debuffs:ClearAllPoints()
		Debuffs:Point(Buffs.point, Buffs.attachTo, Buffs.anchorPoint, Buffs.xOffset, Buffs.yOffset)
	else
		Debuffs:ClearAllPoints()
		Debuffs:Point(Debuffs.point, Debuffs.attachTo, Debuffs.anchorPoint, Debuffs.xOffset, Debuffs.yOffset)
	end
end

-- FLUID_BUFFS_ON_DEBUFFS: PostUpdate on Debuffs — adjust debuff height, reposition Buffs
local function NP_UpdateBuffsPositionAndDebuffHeight(self)
	local nameplate = self.nameplate or self:GetParent()
	local Buffs = nameplate and nameplate.Buffs
	if Buffs then
		if (self.visibleDebuffs or 0) == 0 then
			Buffs:ClearAllPoints()
			Buffs:Point(self.point, self.attachTo, self.anchorPoint, self.xOffset, self.yOffset)
		else
			Buffs:ClearAllPoints()
			Buffs:Point(Buffs.point, Buffs.attachTo, Buffs.anchorPoint, Buffs.xOffset, Buffs.yOffset)
		end
	end
	NP_UpdateDebuffsHeight(self)
end

-- FLUID_DEBUFFS_ON_BUFFS: PostUpdate on Buffs — adjust buff height, reposition Debuffs
local function NP_UpdateDebuffsPositionAndBuffHeight(self)
	local nameplate = self.nameplate or self:GetParent()
	local Debuffs = nameplate and nameplate.Debuffs
	if Debuffs then
		if (self.visibleBuffs or 0) == 0 then
			Debuffs:ClearAllPoints()
			Debuffs:Point(self.point, self.attachTo, self.anchorPoint, self.xOffset, self.yOffset)
		else
			Debuffs:ClearAllPoints()
			Debuffs:Point(Debuffs.point, Debuffs.attachTo, Debuffs.anchorPoint, Debuffs.xOffset, Debuffs.yOffset)
		end
	end
	NP_UpdateBuffsHeight(self)
end

function NP:Construct_Auras(nameplate)
	local frameName = nameplate:GetName()
	local parent = nameplate.Health or nameplate

	local Buffs = CreateFrame('Frame', frameName .. 'Buffs', parent)
	do
		local s = parent:GetFrameStrata()
		if s ~= 'UNKNOWN' then Buffs:SetFrameStrata(s) else Buffs:SetFrameStrata('MEDIUM') end
	end
	Buffs:SetFrameLevel(parent:GetFrameLevel() + 1)
	Buffs:Size(1, 1)
	Buffs.size = 27
	Buffs.num = 4
	Buffs.spacing = E.Border * 2
	Buffs.onlyShowPlayer = false
	Buffs.disableMouse = true
	Buffs.isNameplate = true
	Buffs.initialAnchor = 'BOTTOMLEFT'
	Buffs['growth-x'] = 'RIGHT'
	Buffs['growth-y'] = 'UP'
	Buffs.type = 'buffs'
	Buffs.forceShow = nameplate == _G.ElvNP_Test
	Buffs.tickers = {}

	local Debuffs = CreateFrame('Frame', frameName .. 'Debuffs', parent)
	do
		local s = parent:GetFrameStrata()
		if s ~= 'UNKNOWN' then Debuffs:SetFrameStrata(s) else Debuffs:SetFrameStrata('MEDIUM') end
	end
	Debuffs:SetFrameLevel(parent:GetFrameLevel() + 1)
	Debuffs:Size(1, 1)
	Debuffs.size = 27
	Debuffs.num = 4
	Debuffs.spacing = E.Border * 2
	Debuffs.onlyShowPlayer = false
	Debuffs.disableMouse = true
	Debuffs.isNameplate = true
	Debuffs.initialAnchor = 'BOTTOMLEFT'
	Debuffs['growth-x'] = 'RIGHT'
	Debuffs['growth-y'] = 'UP'
	Debuffs.type = 'debuffs'
	Debuffs.forceShow = nameplate == _G.ElvNP_Test
	Debuffs.tickers = {}

	-- WotLK oUF: PostCreateIcon / PostUpdateIcon (not PostCreateButton / PostUpdateButton)
	Buffs.PreSetPosition = UF.SortAuras
	Buffs.PostCreateIcon = NP.Construct_AuraIcon
	Buffs.PostUpdateIcon = NP.PostUpdateAuraIcon
	Buffs.CustomFilter = NP_AuraFilter

	Debuffs.PreSetPosition = UF.SortAuras
	Debuffs.PostCreateIcon = NP.Construct_AuraIcon
	Debuffs.PostUpdateIcon = NP.PostUpdateAuraIcon
	Debuffs.CustomFilter = NP_AuraFilter

	Buffs.nameplate, Debuffs.nameplate = nameplate, nameplate
	nameplate.Buffs_, nameplate.Debuffs_ = Buffs, Debuffs
	nameplate.Buffs, nameplate.Debuffs = Buffs, Debuffs
end

function NP:Construct_AuraIcon(button)
	if not button then return end

	local offset = NP.thinBorders and E.mult or E.Border
	button:SetTemplate(nil, nil, nil, NP.thinBorders, true)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetInside(button, offset, offset)

	button.icon:SetDrawLayer('ARTWORK')
	button.icon:SetInside(button, offset, offset)

	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')

	button.overlay:SetTexture()
	button.stealable:SetTexture()

	button.cd.CooldownOverride = 'nameplates'
	E:RegisterCooldown(button.cd)

	local auras = button:GetParent()
	if auras and auras.type then
		local db = NP:PlateDB(auras.__owner)
		button.db = db and db[auras.type]
	end

	NP:UpdateAuraSettings(button)
end

local function RefreshAuraCooldownFont(button)
	if button.cd and button.cd.timer then
		E:Cooldown_OnSizeChanged(button.cd.timer, button:GetWidth(), true)
	end
end

function NP:PostUpdateAuraIcon(unit, button)
	-- Border coloring / desaturate only. Size, texcoords and cooldown font are set
	-- once at config time in UpdateAuraSettings and do not change between aura updates.
	UF:PostUpdateAura(unit, button)
end

function NP:UpdateAuraSettings(button)
	local db = button.db
	if db then
		local point = db.countPosition or 'CENTER'
		button.count:ClearAllPoints()
		button.count:SetJustifyH(point:find('RIGHT') and 'RIGHT' or 'LEFT')
		button.count:Point(point, db.countXOffset, db.countYOffset)
		local countSize = db.countFontSize
		if not countSize or countSize <= 0 then countSize = 9 end
		button.count:FontTemplate(LSM:Fetch('font', db.countFont), countSize, db.countFontOutline)
	end

	local parent = button:GetParent()
	if parent and parent.db then
		local width, height = NP:GetAuraIconSize(parent.db)
		button:SetSize(width, height)
		NP:SetAuraIconTexCoords(button.icon, button)
		RefreshAuraCooldownFont(button)
	end

	if button.auraInfo then
		wipe(button.auraInfo)
	else
		button.auraInfo = {}
	end

	button.needsUpdateCooldownPosition = true
end

function NP:Configure_Auras(nameplate, auras, db)
	local numAuras = db.numAuras or 5
	local numRows = db.numRows or 1

	local width, height = NP:GetAuraIconSize(db)
	auras.size = width
	auras.sizeHeight = height
	auras.numAuras = numAuras
	auras.numRows = numRows
	auras.onlyShowPlayer = false
	auras.spacing = db.spacing
	local anchorPoint = db.anchorPoint
	auras['growth-y'] = db.growthY or 'UP'
	auras['growth-x'] = db.growthX or 'RIGHT'
	auras.xOffset = db.xOffset
	auras.yOffset = db.yOffset
	auras.anchorPoint = anchorPoint
	auras.initialAnchor = E.InversePoints[anchorPoint]
	auras.point = auras.initialAnchor -- needed by SmartAuraPosition PostUpdate callbacks
	auras.PostUpdate = nil         -- cleared here; SetSmartAuraPosition may re-assign after Configure
	auras.attachTo = nameplate.Health or nameplate -- always anchor to Health (db.attachTo ignored on nameplates)
	auras.num = numAuras * numRows
	auras.db = db

	local index = 1
	while auras[index] do
		local button = auras[index]
		if button then
			button.db = db
			NP:UpdateAuraSettings(button)
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
		index = index + 1
	end

	auras:ClearAllPoints()
	auras:Point(auras.initialAnchor, auras.attachTo, auras.anchorPoint, auras.xOffset, auras.yOffset)
	auras:Size(numAuras * width + ((numAuras - 1) * db.spacing), numRows * height + ((numRows - 1) * db.spacing))
end

-- Apply smart aura position: re-anchor buffs/debuffs relative to each other and set PostUpdate.
-- Must be called AFTER both Configure_Auras calls so that .point/.attachTo etc. are all set.
function NP:SetSmartAuraPosition(nameplate, db)
	local Buffs    = nameplate.Buffs
	local Debuffs  = nameplate.Debuffs
	local position = db.smartAuraPosition

	if position == 'BUFFS_ON_DEBUFFS' and Buffs and Debuffs then
		Buffs.attachTo = Debuffs
		Buffs:ClearAllPoints()
		Buffs:Point(Buffs.point, Buffs.attachTo, Buffs.anchorPoint, Buffs.xOffset, Buffs.yOffset)
		Buffs.PostUpdate   = nil
		Debuffs.PostUpdate = NP_UpdateBuffsHeaderPosition
	elseif position == 'DEBUFFS_ON_BUFFS' and Buffs and Debuffs then
		Debuffs.attachTo = Buffs
		Debuffs:ClearAllPoints()
		Debuffs:Point(Debuffs.point, Debuffs.attachTo, Debuffs.anchorPoint, Debuffs.xOffset, Debuffs.yOffset)
		Buffs.PostUpdate   = NP_UpdateDebuffsHeaderPosition
		Debuffs.PostUpdate = nil
	elseif position == 'FLUID_BUFFS_ON_DEBUFFS' and Buffs and Debuffs then
		Buffs.attachTo = Debuffs
		Buffs:ClearAllPoints()
		Buffs:Point(Buffs.point, Buffs.attachTo, Buffs.anchorPoint, Buffs.xOffset, Buffs.yOffset)
		Buffs.PostUpdate   = NP_UpdateBuffsHeight
		Debuffs.PostUpdate = NP_UpdateBuffsPositionAndDebuffHeight
	elseif position == 'FLUID_DEBUFFS_ON_BUFFS' and Buffs and Debuffs then
		Debuffs.attachTo = Buffs
		Debuffs:ClearAllPoints()
		Debuffs:Point(Debuffs.point, Debuffs.attachTo, Debuffs.anchorPoint, Debuffs.xOffset, Debuffs.yOffset)
		Buffs.PostUpdate   = NP_UpdateDebuffsPositionAndBuffHeight
		Debuffs.PostUpdate = NP_UpdateDebuffsHeight
	else
		if Buffs then Buffs.PostUpdate = nil end
		if Debuffs then Debuffs.PostUpdate = nil end
	end
end

function NP:Update_Auras(nameplate)
	local db = NP:PlateDB(nameplate)

	if (db.debuffs.enable or db.buffs.enable) and not db.nameOnly then
		if not nameplate:IsElementEnabled('Auras') then
			nameplate:EnableElement('Auras')
		end

		nameplate.Buffs_:ClearAllPoints()
		nameplate.Debuffs_:ClearAllPoints()

		if db.debuffs.enable then
			nameplate.Debuffs = nameplate.Debuffs_
			NP:Configure_Auras(nameplate, nameplate.Debuffs, db.debuffs)
			nameplate.Debuffs:Show()
		elseif nameplate.Debuffs then
			nameplate.Debuffs:Hide()
			nameplate.Debuffs = nil
		end

		if db.buffs.enable then
			nameplate.Buffs = nameplate.Buffs_
			NP:Configure_Auras(nameplate, nameplate.Buffs, db.buffs)
			nameplate.Buffs:Show()
		elseif nameplate.Buffs then
			nameplate.Buffs:Hide()
			nameplate.Buffs = nil
		end

		NP:SetSmartAuraPosition(nameplate, db)

		if nameplate.Debuffs then nameplate.Debuffs:ForceUpdate() end
		if nameplate.Buffs then nameplate.Buffs:ForceUpdate() end
	elseif nameplate:IsElementEnabled('Auras') then
		nameplate:DisableElement('Auras')
	end

	if nameplate.unit then
		NP:RegisterAuraUnitEvents(nameplate, nameplate.unit)
	end
end