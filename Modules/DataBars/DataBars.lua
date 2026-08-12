local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("DataBars")
local LSM = E.Libs.LSM

function mod:GetBarOrientation(db)
	if db.orientation == "AUTOMATIC" then
		return db.height > db.width and "VERTICAL" or "HORIZONTAL"
	end

	return db.orientation
end

function mod:GetBarTexture()
	return self.db.customTexture and LSM:Fetch("statusbar", self.db.statusbar) or E.media.normTex
end

function mod.OnLeave(self)
	if (self == ElvUI_ExperienceBar and mod.db.experience.mouseover)
	or (self == ElvUI_PetExperienceBar and mod.db.petExperience.mouseover)
	or (self == ElvUI_ReputationBar and mod.db.reputation.mouseover)
	or (self == ElvUI_HonorBar and mod.db.honor and mod.db.honor.mouseover)
	or (self == ElvUI_ThreatBar and mod.db.threat and mod.db.threat.mouseover)
	then
		E:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
	end

	GameTooltip:Hide()
end

function mod:CreateBar(name, onEnter, onClick, ...)
	local bar = CreateFrame("Button", name, E.UIParent)
	bar:Point(...)
	bar:SetScript("OnEnter", onEnter)
	bar:SetScript("OnLeave", mod.OnLeave)
	bar:SetScript("OnClick", onClick)
	bar:SetFrameStrata("LOW")
	bar:SetTemplate("Transparent")
	bar:Hide()

	bar.statusBar = CreateFrame("StatusBar", nil, bar)
	bar.statusBar:SetInside()
	bar.statusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(bar.statusBar)

	bar.text = bar.statusBar:CreateFontString(nil, "OVERLAY")
	bar.text:FontTemplate()
	bar.text:Point("CENTER")

	return bar
end

function mod:CreateBarBubbles(bar)
	local bubbles = CreateFrame("Frame", "$parent_Bubbles", bar)
	bubbles:SetAllPoints()
	bubbles.textures = {}

	for i = 1, 19 do
		bubbles.textures[i] = bubbles:CreateTexture(nil, "OVERLAY")
		bubbles.textures[i]:SetTexture(0, 0, 0, 1)
	end

	bar.bubbles = bubbles

	return bubbles
end

function mod:UpdateBarBubbles(bar, db)
	if db.showBubbles then
		local vertical = self:GetBarOrientation(db) ~= "HORIZONTAL"
		local width = vertical and db.width or 1
		local height = not vertical and db.height or 1
		local offset = (vertical and db.height or db.width) / 20

		for i, texture in ipairs(bar.bubbles.textures) do
			texture:Size(width, height)
			texture:Point("TOPLEFT", bar, "TOPLEFT", vertical and 0 or offset * i, vertical and -offset * i or 0)
			texture:Show()
		end
	else
		for _, texture in ipairs(bar.bubbles.textures) do
			texture:Hide()
		end
	end
end

function mod:UpdateDataBarDimensions()
	self:ExperienceBar_UpdateDimensions()
	self:PetExperienceBar_UpdateDimensions()
	self:ReputationBar_UpdateDimensions()
	if self.honorBar then
		self:UpdateHonorDimensions()
	end
	if self.threatBar then
		self:UpdateThreatDimensions()
	end
end

function mod:ToggleAll()
	mod:ExperienceBar_Toggle()
	mod:PetExperienceBar_Toggle()
	mod:ReputationBar_Toggle()
	if self.honorBar then
		self:EnableDisable_HonorBar()
	end
	if self.threatBar then
		self:ThreatBar_Toggle()
	end
end

function mod:UpdateAll()
	self:UpdateDataBarDimensions()
end

function mod:Initialize()
	self.db = E.db.databars

	self.maxExpansionLevel = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]

	self:ExperienceBar_Load()
	self:PetExperienceBar_Load()
	self:ReputationBar_Load()
	self:ThreatBar_Load()
end

local ElvUF = E.oUF

local next = next
local wipe = wipe
local strmatch = strmatch

local UnitAffectingCombat = UnitAffectingCombat
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitClass = UnitClass
local UnitName = UnitName
local UNKNOWN = UNKNOWN

local tankStatus = {[0] = 3, 2, 1, 0}

function mod:ThreatBar_GetLargestThreatOnList(percent)
	local largestValue, largestUnit = 0, nil
	for unit, threatPercent in next, self.threatBar.list do
		if threatPercent > largestValue then
			largestValue = threatPercent
			largestUnit = unit
		end
	end

	return (percent - largestValue), largestUnit
end

function mod:ThreatBar_GetColor(unit)
	local unitReaction = UnitReaction(unit, "player")
	local _, unitClass = UnitClass(unit)
	if UnitIsPlayer(unit) then
		local class = E:ClassColor(unitClass)
		if not class then return 194, 194, 194 end
		return class.r * 255, class.g * 255, class.b * 255
	elseif unitReaction then
		local reaction = ElvUF.colors.reaction[unitReaction]
		return reaction.r * 255, reaction.g * 255, reaction.b * 255
	else
		return 194, 194, 194
	end
end

function mod:ThreatBar_OnEnter()
	if mod.db.threat.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)
	GameTooltip:AddLine(L["Threat Bar"])
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Current Target:"], UnitName("target") or UNKNOWN, 1, 1, 1)
	GameTooltip:Show()
end

function mod:ThreatBar_OnClick()
	if UnitExists("target") and not UnitIsUnit("target", "player") then
		TargetUnit("player")
	end
end

function mod:ThreatBar_Update(event, unit)
	if not mod.db.threat.enable then return end
	if (event == "UNIT_THREAT_LIST_UPDATE" or event == "UNIT_FLAGS") and unit and unit ~= "player" and unit ~= "pet" and not strmatch(unit, "^party") and not strmatch(unit, "^raid") then return end

	local bar = mod.threatBar
	if not bar then return end

	local petExists = UnitExists("pet")
	local showBar = false

	if UnitAffectingCombat("player") and (petExists or E.IsInGroup) then
		local _, status, percent = UnitDetailedThreatSituation("player", "target")

		if percent then
			local name, isTank = UnitName("target") or UNKNOWN, E.myrole == "TANK"
			showBar = true

			local leadPercent, largestUnit
			if percent == 100 then
				if petExists then
					_, _, bar.list.pet = UnitDetailedThreatSituation("pet", "target")
				end

				for guid, role in next, E.GroupRoles do
					local unitID = E.GroupUnitsByRole[role][guid]
					if unitID and not UnitIsUnit(unitID, "player") then
						_, _, bar.list[unitID] = UnitDetailedThreatSituation(unitID, "target")
					end
				end

				leadPercent, largestUnit = mod:ThreatBar_GetLargestThreatOnList(percent)
			end

			if largestUnit and leadPercent > 0 then
				local r, g, b = mod:ThreatBar_GetColor(largestUnit)
				bar.text:SetFormattedText(L["ABOVE_THREAT_FORMAT"], name, percent, leadPercent, r, g, b, UnitName(largestUnit) or UNKNOWN)
				bar.statusBar:SetValue(isTank and leadPercent or percent)
			else
				bar.text:SetFormattedText("%s: %.0f%%", name, percent)
				bar.statusBar:SetValue(percent)
			end

			local r, g, b = GetThreatStatusColor(isTank and bar.db.tankStatus and tankStatus[status] or status)
			if r then
				bar.statusBar:SetStatusBarColor(r, g, b, 0.8)
			end
		end
	end

	if not showBar then
		bar:Hide()
	else
		bar:Show()

		if mod.db.threat.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end
	end

	bar.text:SetShown(bar.db.displayText)

	wipe(bar.list)
end

function mod:ThreatBar_Toggle()
	local bar = self.threatBar
	if not bar then return end

	bar.db = self.db.threat

	E:SetSmoothing(bar.statusBar, bar.db.smoothbars)

	if bar.db.enable then
		bar.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		bar.eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
		bar.eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
		bar.eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		bar.eventFrame:RegisterEvent("UNIT_FLAGS")
		bar.eventFrame:RegisterEvent("UNIT_PET")

		self:ThreatBar_Update()
		E:EnableMover(bar.mover:GetName())
	else
		bar.eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
		bar.eventFrame:UnregisterEvent("UNIT_THREAT_LIST_UPDATE")
		bar.eventFrame:UnregisterEvent("RAID_ROSTER_UPDATE")
		bar.eventFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		bar.eventFrame:UnregisterEvent("UNIT_FLAGS")
		bar.eventFrame:UnregisterEvent("UNIT_PET")

		bar:Hide()
		E:DisableMover(bar.mover:GetName())
	end
end

function mod:UpdateThreatDimensions()
	local db = self.db.threat
	if not self.threatBar then return end

	self.threatBar:SetWidth(db.width)
	self.threatBar:SetHeight(db.height)
	self.threatBar:SetAlpha(db.mouseover and 0 or 1)
	self.threatBar:SetTemplate(self.db.transparent and "Transparent" or nil)
	self.threatBar:EnableMouse(not db.clickThrough)
	self.threatBar:SetFrameLevel(db.frameLevel)
	self.threatBar:SetFrameStrata(db.frameStrata)

	local orientation = self:GetBarOrientation(db)

	self.threatBar.statusBar:SetOrientation(orientation)
	self.threatBar.statusBar:SetRotatesTexture(orientation ~= "HORIZONTAL")
	self.threatBar.statusBar:SetStatusBarTexture(self:GetBarTexture())

	self.threatBar.text:FontTemplate(LSM:Fetch("font", db.font), db.textSize, db.fontOutline)
	self.threatBar.text:ClearAllPoints()
	self.threatBar.text:Point(db.anchorPoint, db.xOffset, db.yOffset)
	self.threatBar.text:SetShown(db.displayText)
end

function mod:ThreatBar_Load()
	self.threatBar = self:CreateBar("ElvUI_ThreatBar", mod.ThreatBar_OnEnter, mod.ThreatBar_OnClick, "TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -245)
	self.threatBar.statusBar:SetMinMaxValues(0, 100)
	self.threatBar.list = {}
	self.threatBar.db = self.db.threat

	self.threatBar.eventFrame = CreateFrame("Frame")
	self.threatBar.eventFrame:Hide()
	self.threatBar.eventFrame:SetScript("OnEvent", function(_, event, unit) self:ThreatBar_Update(event, unit) end)

	E:CreateMover(self.threatBar, "ThreatBarMover", L["Threat Bar"], nil, nil, nil, nil, nil, "databars,threat")

	self:ThreatBar_Toggle()
	self:UpdateThreatDimensions()
end

local function InitializeCallback()
	mod:Initialize()
end

E:RegisterCallback("StaggeredUpdate", mod.UpdateAll, mod)

E:RegisterModule(mod:GetName(), InitializeCallback)