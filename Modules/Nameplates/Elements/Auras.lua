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
local ceil, min = math.ceil, math.min

-- Local MatchGrowthX/Y tables (retail UF doesn't exist in WotLK)
local MatchGrowthX = {
	TOPLEFT     = 'RIGHT',
	TOPRIGHT    = 'LEFT',
	BOTTOMLEFT  = 'RIGHT',
	BOTTOMRIGHT = 'LEFT',
	LEFT        = 'RIGHT',
	RIGHT       = 'LEFT',
	TOP         = 'RIGHT',
	BOTTOM      = 'RIGHT',
}

local MatchGrowthY = {
	TOPLEFT     = 'DOWN',
	TOPRIGHT    = 'DOWN',
	BOTTOMLEFT  = 'UP',
	BOTTOMRIGHT = 'UP',
	LEFT        = 'UP',
	RIGHT       = 'UP',
	TOP         = 'DOWN',
	BOTTOM      = 'UP',
}

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
-- Non-fluid modes reuse UF.UpdateBuffsHeaderPosition / UF.UpdateDebuffsHeaderPosition directly
-- because those only do position math with no db field lookups.
local function NP_UpdateBuffsHeight(self)
	local n = self.visibleBuffs or 0
	if n > 0 then
		self:Height(self.size * min(ceil(n / (self.numAuras or 5)), self.numRows or 1))
	else
		self:Height(self.size)
	end
end

local function NP_UpdateDebuffsHeight(self)
	local n = self.visibleDebuffs or 0
	if n > 0 then
		self:Height(self.size * min(ceil(n / (self.numAuras or 5)), self.numRows or 1))
	else
		self:Height(self.size)
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

-- Local ConvertFilters: split priority string into filterList table
local function ConvertFilters(auras, priority)
	local filterList = {}
	if priority then
		for filter in priority:gmatch('[^,]+') do
			local f = filter:match('^%s*(.-)%s*$')
			if f and f ~= '' then
				filterList[#filterList + 1] = f
			end
		end
	end
	auras.filterList = filterList
	return filterList
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
	Buffs.growthX = 'RIGHT'
	Buffs.growthY = 'UP'
	Buffs.type = 'buffs'
	Buffs.forceShow = nameplate == _G.ElvNP_Test
	Buffs.tickers = {}
	Buffs.stacks = {}
	Buffs.rows = {}

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
	Debuffs.growthX = 'RIGHT'
	Debuffs.growthY = 'UP'
	Debuffs.type = 'debuffs'
	Debuffs.forceShow = nameplate == _G.ElvNP_Test
	Debuffs.tickers = {}
	Debuffs.stacks = {}
	Debuffs.rows = {}

	-- WotLK oUF: PostCreateIcon / PostUpdateIcon (not PostCreateButton / PostUpdateButton)
	Buffs.PreSetPosition = UF.SortAuras
	Buffs.PostCreateIcon = NP.Construct_AuraIcon
	Buffs.PostUpdateIcon = UF.PostUpdateAura
	Buffs.CustomFilter = NP_AuraFilter

	Debuffs.PreSetPosition = UF.SortAuras
	Debuffs.PostCreateIcon = NP.Construct_AuraIcon
	Debuffs.PostUpdateIcon = UF.PostUpdateAura
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
	E:RegisterCooldown(button.cd, 'nameplates')

	local auras = button:GetParent()
	if auras and auras.type then
		local db = NP:PlateDB(auras.__owner)
		button.db = db and db[auras.type]
	end

	NP:UpdateAuraSettings(button)
end

function NP:UpdateAuraSettings(button)
	local db = button.db
	if db then
		local point = db.countPosition or 'CENTER'
		button.count:ClearAllPoints()
		button.count:SetJustifyH(point:find('RIGHT') and 'RIGHT' or 'LEFT')
		button.count:Point(point, db.countXOffset, db.countYOffset)
		button.count:FontTemplate(LSM:Fetch('font', db.countFont), db.countFontSize, db.countFontOutline)
	end

	if button.icon then
		button.icon:SetTexCoord(unpack(E.TexCoords))
	end

	if button.auraInfo then
		wipe(button.auraInfo)
	else
		button.auraInfo = {}
	end

	button.needsUpdateCooldownPosition = true
end

function NP:Configure_Auras(nameplate, auras, db)
	-- WotLK Profile uses perrow/numrows, retail uses numAuras/numRows - support both
	local numAuras = db.numAuras or db.perrow or 5
	local numRows = db.numRows or db.numrows or 1
	local priority = db.priority or (db.filters and db.filters.priority) or ''

	auras.size = db.size
	auras.numAuras = numAuras
	auras.numRows = numRows
	auras.onlyShowPlayer = false
	auras.spacing = db.spacing
	local anchorPoint = db.anchorPoint
	-- Respect manual growth choice on pure side anchors (LEFT/RIGHT for X, TOP/BOTTOM for Y).
	-- Corner anchors still derive growth from anchor point to keep legacy behavior.
	auras.growthY = ((anchorPoint == 'TOP' or anchorPoint == 'BOTTOM') and db.growthY) or MatchGrowthY[anchorPoint] or db.growthY
	auras.growthX = ((anchorPoint == 'LEFT' or anchorPoint == 'RIGHT') and db.growthX) or MatchGrowthX[anchorPoint] or db.growthX
	auras.xOffset = db.xOffset
	auras.yOffset = db.yOffset
	auras.anchorPoint = anchorPoint
	auras.initialAnchor = E.InversePoints[anchorPoint]
	auras.point = auras.initialAnchor -- needed by SmartAuraPosition PostUpdate callbacks
	ConvertFilters(auras, priority)
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
	auras:Size(numAuras * db.size + ((numAuras - 1) * db.spacing), 1)
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
end