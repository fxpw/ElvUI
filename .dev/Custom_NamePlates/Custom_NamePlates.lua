local NP_SPELL_SHOW_PERSONAL = NP_SPELL_SHOW_PERSONAL
local NP_SPELL_SHOW_ALL = NP_SPELL_SHOW_ALL
local NP_BUFF_BLACKLIST = NP_BUFF_BLACKLIST
local NP_DEBUFF_BLACKLIST = NP_DEBUFF_BLACKLIST

local CUF_SPELL_VISIBILITY_BLACKLIST = CUF_SPELL_VISIBILITY_BLACKLIST

local FACTION_OVERRIDE_BY_DEBUFFS = FACTION_OVERRIDE_BY_DEBUFFS
local S_CATEGORY_SPELL_ID = S_CATEGORY_SPELL_ID
local S_VIP_STATUS_DATA = S_VIP_STATUS_DATA
local S_PREMIUM_SPELL_ID = S_PREMIUM_SPELL_ID
local ZODIAC_DEBUFFS = ZODIAC_DEBUFFS

NamePlateDriverMixin = {};

function NamePlateDriverMixin:OnLoad()
	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterEvent("UNIT_FACTION");

	self:SetBaseNamePlateSize(110, 25);

	self.pool = CreateFramePool("Button", self, "NamePlateUnitFrameTemplate");

	self.namePlateSetupFunctions =
	{
		["player"] = DefaultCompactNamePlatePlayerFrameSetup,
		["friendly"] = DefaultCompactNamePlateFriendlyFrameSetup,
		["enemy"] = DefaultCompactNamePlateEnemyFrameSetup,
	};

	self.namePlateAnchorFunctions =
	{
		["player"] = DefaultCompactNamePlatePlayerFrameAnchor,
		["friendly"] = DefaultCompactNamePlateFrameAnchors,
		["enemy"] = DefaultCompactNamePlateFrameAnchors,
	};

	self.namePlateSetInsetFunctions =
	{
		["player"] = C_NamePlate.SetNamePlateSelfPreferredClickInsets,
		["friendly"] =  C_NamePlate.SetNamePlateFriendlyPreferredClickInsets,
		["enemy"] = C_NamePlate.SetNamePlateEnemyPreferredClickInsets,
	};

	self.optionCVars =
	{
		["ShowClassColorInNameplate"] = true,
		["nameplateShowDebuffsOnFriendly"] = true,
		["nameplateResourceOnTarget"] = true,
		["nameplateHideHealthAndPower"] = true,
		["NamePlateVerticalScale"] = true,
		["nameplateShowOnlyNames"] = true,
		["NameplatePersonalClickThrough"] = true,
		["NamePlateHorizontalScale"] = true,
		["NamePlateClassificationScale"] = true,
		["NamePlateMaximumClassificationScale"] = true,
		["nameplateClassResourceTopInset"] = true,
		["nameplatePredictedHealthAndPower"] = true,

		["UnitNameNPC"] = true,
		["UnitNameFriendlyPlayerName"] = true,
		["UnitNameFriendlyPetName"] = true,
		["UnitNameFriendlyGuardianName"] = true,
		["UnitNameFriendlyTotemName"] = true,
		["UnitNameEnemyPlayerName"] = true,
		["UnitNameEnemyPetName"] = true,
		["UnitNameEnemyGuardianName"] = true,
		["UnitNameEnemyTotemName"] = true,
	};
end

function NamePlateDriverMixin:OnEvent(event, ...)
	if event == "NAME_PLATE_CREATED" then
		local namePlateFrameBase = ...;
		self:OnNamePlateCreated(namePlateFrameBase);
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local namePlateUnitToken = ...;
		self:OnNamePlateAdded(namePlateUnitToken);
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		local namePlateUnitToken = ...;
		self:OnNamePlateRemoved(namePlateUnitToken);
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:OnTargetChanged();
	elseif event == "DISPLAY_SIZE_CHANGED" then
		self:UpdateNamePlateOptions();
	elseif event == "UNIT_AURA" then
		self:OnUnitAuraUpdate(...);
	elseif event == "VARIABLES_LOADED" then
		self:UpdateNamePlateOptions();
	elseif event == "CVAR_UPDATE" then
		self:UpdateNamePlateOptions();
	elseif event == "RAID_TARGET_UPDATE" then
		self:OnRaidTargetUpdate();
	elseif event == "UNIT_FACTION" then
		self:OnUnitFactionChanged(...);
	end
end

function NamePlateDriverMixin:OnNamePlateCreated(namePlateFrameBase)
	self:OnNamePlateCreatedInternal(namePlateFrameBase, "NamePlateUnitFrameTemplate");
end

function NamePlateDriverMixin:OnNamePlateCreatedInternal(namePlateFrameBase, template)
	Mixin(namePlateFrameBase, NamePlateBaseMixin);
	namePlateFrameBase.template = template;
end

function NamePlateDriverMixin:AcquireUnitFrame(namePlateFrameBase, namePlateUnitToken)
	local unitFrame = self.pool:Acquire();
	namePlateFrameBase.UnitFrame = unitFrame;

	unitFrame:SetParent(namePlateFrameBase);
	unitFrame:SetPoint("TOPLEFT", namePlateFrameBase, "TOPLEFT");
	unitFrame:EnableMouse(false);

	namePlateFrameBase:SetScript("OnSizeChanged", namePlateFrameBase.OnSizeChanged);
	namePlateFrameBase:OnSizeChanged();
end

function NamePlateDriverMixin:OnNamePlateAdded(namePlateUnitToken)
	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken);

	self:AcquireUnitFrame(namePlateFrameBase, namePlateUnitToken);

	self:ApplyFrameOptions(namePlateFrameBase, namePlateUnitToken);

	namePlateFrameBase:OnAdded(namePlateUnitToken, self);
	self:SetupClassNameplateBars();

	self:OnUnitAuraUpdate(namePlateUnitToken);
	self:OnRaidTargetUpdate();
end

function NamePlateDriverMixin:GetNamePlateTypeFromUnit(unit)
	if UnitIsUnit("player", unit) then
		return "player";
	elseif UnitIsFriend("player", unit) then
		return "friendly";
	else
		return "enemy";
	end
end

function NamePlateDriverMixin:ApplyFrameOptions(namePlateFrameBase, namePlateUnitToken)
	local namePlateType = self:GetNamePlateTypeFromUnit(namePlateUnitToken);
	local setupFn = self.namePlateSetupFunctions[namePlateType];

	local unitFrame = namePlateFrameBase.UnitFrame;
	if setupFn then
		CompactUnitFrame_SetUpFrame(unitFrame, setupFn);
	end

	if unitFrame.SetupOverride then
		unitFrame:SetupOverride();
	end

	namePlateFrameBase:OnOptionsUpdated();

	self:UpdateInsetsForType(namePlateType, namePlateFrameBase);
end

function NamePlateDriverMixin:GetOnSizeChangedFunction(namePlateUnitToken)
	local namePlateType = self:GetNamePlateTypeFromUnit(namePlateUnitToken);
	return self.namePlateAnchorFunctions[namePlateType];
end

function NamePlateDriverMixin:UpdateInsetsForType(namePlateType, namePlateFrameBase)
	-- Only update the options for each nameplate type once, these can change at run time
	-- depending on any options that change where pieces of the nameplate are positioned (scale is the main one)
	if not self.preferredInsets[namePlateType] then
		local setInsetFn = self.namePlateSetInsetFunctions[namePlateType];
		if setInsetFn then
			-- NOTE: Insets should push in from the edge, but avoid using abs in case they actually push outside, it will be handled properly.
			local left, right, top, bottom = namePlateFrameBase:GetPreferredInsets()
			if left then
				self.preferredInsets[namePlateType] = true;
				setInsetFn(left, right, top, bottom);
			end
		end
	end
end

function NamePlateDriverMixin:OnNamePlateRemoved(namePlateUnitToken)
	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken);

	namePlateFrameBase:OnRemoved();

	self.pool:Release(namePlateFrameBase.UnitFrame);
	namePlateFrameBase.UnitFrame = nil;
end

function NamePlateDriverMixin:OnTargetChanged()
	self:SetupClassNameplateBars();
	self:OnUnitAuraUpdate("target");
end

function NamePlateDriverMixin:OnUnitAuraUpdate(unit)
	local filter;
	local showAll = false;
	if UnitIsUnit("player", unit) then
		filter = "HELPFUL";
	else
		local reaction = UnitReaction("player", unit);
		if reaction and reaction <= 4 then
		-- Reaction 4 is neutral and less than 4 becomes increasingly more hostile
			filter = "HARMFUL";
		else
			local showDebuffsOnFriendly = GetCVarBool("nameplateShowDebuffsOnFriendly");
			if showDebuffsOnFriendly then
				-- dispellable debuffs
				filter = "HARMFUL|RAID";
				showAll = true;
			else
				filter = "NONE";
			end
		end
	end

	local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
	if nameplate then
		nameplate.UnitFrame.BuffFrame:UpdateBuffs(nameplate.namePlateUnitToken, filter, showAll);
	end
end

function NamePlateDriverMixin:OnRaidTargetUpdate()
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		local icon = frame.UnitFrame.RaidTargetFrame.RaidTargetIcon;
		local index = GetRaidTargetIndex(frame.namePlateUnitToken);
		if index and not UnitIsUnit("player", frame.namePlateUnitToken) then
			SetRaidTargetIconTexture(icon, index);
			icon:Show();
		else
			icon:Hide();
		end
	end

end

function NamePlateDriverMixin:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
	if nameplate then
		CompactUnitFrame_UpdateName(nameplate.UnitFrame);
		CompactUnitFrame_UpdateHealthColor(nameplate.UnitFrame);
	end
end

function NamePlateDriverMixin:OnNamePlateResized(namePlateFrame)
	if self.classNamePlateMechanicFrame and self.classNamePlateMechanicFrame:GetParent() == namePlateFrame then
		self.classNamePlateMechanicFrame:OnSizeChanged();
	end
	if self.classNamePlatePowerBar and self.classNamePlatePowerBar:GetParent() == namePlateFrame then
		self.classNamePlatePowerBar:OnSizeChanged();
	end
end

function NamePlateDriverMixin:SetupClassNameplateBars()
	local showMechanicOnTarget;
	if self.classNamePlateMechanicFrame and self.classNamePlateMechanicFrame.overrideTargetMode ~= nil then
		showMechanicOnTarget = self.classNamePlateMechanicFrame.overrideTargetMode;
	else
		showMechanicOnTarget = GetCVarBool("nameplateResourceOnTarget");
	end

	local bottomMostBar = nil;
	local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player");
	if namePlatePlayer then
		bottomMostBar = namePlatePlayer.UnitFrame.healthBar;
	end

	if self.classNamePlatePowerBar then
		if namePlatePlayer then
			self.classNamePlatePowerBar:SetParent(namePlatePlayer);
			self.classNamePlatePowerBar:ClearAllPoints();
			self.classNamePlatePowerBar:SetPoint("TOPLEFT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMLEFT", 0, 0);
			self.classNamePlatePowerBar:SetPoint("TOPRIGHT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMRIGHT", 0, 0);
			self.classNamePlatePowerBar:SetShown(not self.playerHideHealthandPowerBar);

			bottomMostBar = self.classNamePlatePowerBar;
		else
			self.classNamePlatePowerBar:Hide();
		end
	end

	if self.classNamePlateMechanicFrame then
		if showMechanicOnTarget then
			local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target");
			if namePlateTarget then
				self.classNamePlateMechanicFrame:SetParent(namePlateTarget);
				self.classNamePlateMechanicFrame:ClearAllPoints();
				PixelUtil.SetPoint(self.classNamePlateMechanicFrame, "BOTTOM", namePlateTarget.UnitFrame.name, "TOP", 0, 4);
				self.classNamePlateMechanicFrame:Show();
			else
				self.classNamePlateMechanicFrame:Hide();
			end
		elseif bottomMostBar then
			self.classNamePlateMechanicFrame:SetParent(namePlatePlayer);
			self.classNamePlateMechanicFrame:ClearAllPoints();
			self.classNamePlateMechanicFrame:SetPoint("TOP", bottomMostBar, "BOTTOM", 0, self.classNamePlateMechanicFrame.paddingOverride or -4);
			self.classNamePlateMechanicFrame:Show();
		else
			self.classNamePlateMechanicFrame:Hide();
		end
	end

	if showMechanicOnTarget and self.classNamePlateMechanicFrame then
		local percentOffset = tonumber(GetCVar("nameplateClassResourceTopInset")) or 0;
		if self:IsUsingLargerNamePlateStyle() then
			percentOffset = percentOffset + .1;
		end
		C_NamePlate.SetTargetClampingInsets(0, 0, percentOffset * UIParent:GetHeight(), 0);
	else
		C_NamePlate.SetTargetClampingInsets(0, 0, 0, 0);
	end
end

function NamePlateDriverMixin:SetClassNameplateBar(frame)
	self.classNamePlateMechanicFrame = frame;
	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:GetClassNameplateBar()
	return self.classNamePlateMechanicFrame;
end

function NamePlateDriverMixin:GetClassNameplateManaBar()
	return self.classNamePlatePowerBar;
end

function NamePlateDriverMixin:SetClassNameplateManaBar(frame)
	self.classNamePlatePowerBar = frame;
	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:SetBaseNamePlateSize(width, height)
	if self.baseNamePlateWidth ~= width or self.baseNamePlateHeight ~= height then
		self.baseNamePlateWidth = width;
		self.baseNamePlateHeight = height;

		self:UpdateNamePlateOptions();
	end
end

function NamePlateDriverMixin:GetBaseNamePlateWidth()
	return self.baseNamePlateWidth;
end

function NamePlateDriverMixin:GetBaseNamePlateHeight()
	return self.baseNamePlateHeight;
end

function NamePlateDriverMixin:IsUsingLargerNamePlateStyle()
	local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"));
	return namePlateVerticalScale > 1.0;
end

function NamePlateDriverMixin:UpdateNamePlateOptions()
	DefaultCompactNamePlateEnemyFrameOptions.useClassColors = GetCVarBool("ShowClassColorInNameplate");
	DefaultCompactNamePlateEnemyFrameOptions.playLoseAggroHighlight = GetCVarBool("ShowNamePlateLoseAggroFlash");

	local showOnlyNames = GetCVarBool("nameplateShowOnlyNames");
	DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = GetCVarBool("ShowClassColorInFriendlyNameplate");
	DefaultCompactNamePlateFriendlyFrameOptions.hideHealthbar = showOnlyNames;
	DefaultCompactNamePlateFriendlyFrameOptions.hideCastbar = showOnlyNames;

	local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"));
	local zeroBasedScale = namePlateVerticalScale - 1.0;
	local clampedZeroBasedScale = Saturate(zeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.healthBarHeight = 4 * namePlateVerticalScale;
	DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight = 4 * namePlateVerticalScale * Lerp(1.2, 1.0, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.useLargeNameFont = clampedZeroBasedScale > .25;
	local screenWidth, screenHeight = GetPhysicalScreenSize();
	DefaultCompactNamePlateFrameSetUpOptions.useFixedSizeFont = screenHeight <= 1200;

	DefaultCompactNamePlateFrameSetUpOptions.castBarHeight = math.min(Lerp(12, 16, zeroBasedScale), DefaultCompactNamePlateFrameSetUpOptions.healthBarHeight * 2);
	DefaultCompactNamePlateFrameSetUpOptions.castBarFontHeight = Lerp(8, 12, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.castBarShieldWidth = Lerp(10, 15, clampedZeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.castBarShieldHeight = Lerp(12, 18, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.castIconWidth = Lerp(10, 15, clampedZeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.castIconHeight = Lerp(10, 15, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.hideHealthbar = showOnlyNames;
	DefaultCompactNamePlateFrameSetUpOptions.hideCastbar = showOnlyNames;

	local nameplatePredictedHealthAndPower = GetCVarBool("nameplatePredictedHealthAndPower")
	DefaultCompactNamePlateFrameSetUpOptions.frequentHealthUpdates = nameplatePredictedHealthAndPower and GetCVarBool("predictedHealth")
	DefaultCompactNamePlateFrameSetUpOptions.frequentPowerUpdates = nameplatePredictedHealthAndPower and GetCVarBool("predictedPower")
	DefaultCompactNamePlatePlayerFrameSetUpOptions.frequentHealthUpdates = DefaultCompactNamePlateFrameSetUpOptions.frequentHealthUpdates
	DefaultCompactNamePlatePlayerFrameSetUpOptions.frequentPowerUpdates = DefaultCompactNamePlateFrameSetUpOptions.frequentPowerUpdates

	local personalNamePlateClickThrough = GetCVarBool("NameplatePersonalClickThrough");
	C_NamePlate.SetNamePlateSelfClickThrough(personalNamePlateClickThrough);

	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"));
	C_NamePlate.SetNamePlateFriendlySize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale));
	C_NamePlate.SetNamePlateEnemySize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale));
	C_NamePlate.SetNamePlateSelfSize(self.baseNamePlateWidth * horizontalScale * Lerp(1.1, 1.0, clampedZeroBasedScale), self.baseNamePlateHeight);

	-- Clear the inset table, just update it from scratch since this will iterate all nameplates
	-- As each nameplate updates, it will handle updating preferred insets during its setup
	self.preferredInsets = {};

	for i, frame in ipairs(C_NamePlate.GetNamePlates()) do
		self:ApplyFrameOptions(frame, frame.namePlateUnitToken);
		CompactUnitFrame_SetUnit(frame.UnitFrame, frame.namePlateUnitToken);
		self:OnUnitAuraUpdate(frame.namePlateUnitToken);
	end

	if self.classNamePlateMechanicFrame then
		self.classNamePlateMechanicFrame:OnOptionsUpdated();
	end
	if self.classNamePlatePowerBar then
		self.classNamePlatePowerBar:OnOptionsUpdated();
	end
	self:SetupClassNameplateBars();
end

NamePlateBaseMixin = {};

function NamePlateBaseMixin:OnAdded(namePlateUnitToken, driverFrame)
	self.namePlateUnitToken = namePlateUnitToken;
	self.driverFrame = driverFrame;

	CompactUnitFrame_SetUnit(self.UnitFrame, namePlateUnitToken);

	self:ApplyOffsets();

	self.UnitFrame.BuffFrame:SetActive(true);
end

function NamePlateBaseMixin:OnRemoved()
	self.namePlateUnitToken = nil;
	self.driverFrame = nil;

	CompactUnitFrame_SetUnit(self.UnitFrame, nil);
end

function NamePlateBaseMixin:OnOptionsUpdated()
	if self.driverFrame then
		self:ApplyOffsets();
	end
end

function NamePlateBaseMixin:ApplyOffsets()
	if self.driverFrame:IsUsingLargerNamePlateStyle() then
		self.UnitFrame.BuffFrame:SetBaseYOffset(-3);
	else
		self.UnitFrame.BuffFrame:SetBaseYOffset(-3);
	end

	local targetMode = GetCVarBool("nameplateResourceOnTarget");
	if targetMode then
		self.UnitFrame.BuffFrame:SetTargetYOffset(24);
	else
		self.UnitFrame.BuffFrame:SetTargetYOffset(0);
	end
end

NAMEPLATE_MINIMUM_INSET_HEIGHT_THRESHOLD = 10;
NAMEPLATE_ADDITIONAL_INSET_HEIGHT_PADDING = 2;

function NamePlateBaseMixin:GetAdditionalInsetPadding(insetWidth, insetHeight)
	local heightPadding = 0;
	local widthPadding = 0; -- No change to width is necessary yet.

	if insetHeight < NAMEPLATE_MINIMUM_INSET_HEIGHT_THRESHOLD then
		heightPadding = NAMEPLATE_ADDITIONAL_INSET_HEIGHT_PADDING;
	end

	return widthPadding, heightPadding;
end

function NamePlateBaseMixin:GetPreferredInsets()
	local frame = self.UnitFrame;
	local health = frame.healthBar;

	if not health:GetLeft() or not frame:GetLeft() then
		return
	end

	local left = health:GetLeft() - frame:GetLeft();
	local right = frame:GetRight() - health:GetRight();
	local top = frame:GetTop() - health:GetTop();
	local bottom = health:GetBottom() - frame:GetBottom();

	-- Width probably won't be an issue, but if height is under a certain threshold, give the user a little more area to click on.
	local widthPadding, heightPadding = self:GetAdditionalInsetPadding(right - left, top - bottom)
	left = left - widthPadding
	right = right - widthPadding
	top = top - heightPadding
	bottom = bottom - heightPadding

	return left, right, top, bottom;
end

function NamePlateBaseMixin:OnSizeChanged()
	if self.namePlateUnitToken and self:IsVisible() then
		local anchorUpdateFunction = self.driverFrame:GetOnSizeChangedFunction(self.namePlateUnitToken);
		if anchorUpdateFunction then
			anchorUpdateFunction(self.UnitFrame);
		end

		-- Occurs after the anchor update function has been called, so any dependant points
		-- will have their points set.
		if self.SizeChangedOverride then
			self:SizeChangedOverride();
		end

		self.driverFrame:OnNamePlateResized(self);
	end
end

--------------------------------------------------------------------------------
--
-- Buffs
--
--------------------------------------------------------------------------------

NameplateBuffContainerMixin = {};

function NameplateBuffContainerMixin:OnLoad()
	self.buffList = {};
	self.targetYOffset = 0;
	self.baseYOffset = 0;
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function NameplateBuffContainerMixin:OnEvent(event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		self:UpdateAnchor();
	end
end

function NameplateBuffContainerMixin:SetTargetYOffset(targetYOffset)
	self.targetYOffset = targetYOffset;
end

function NameplateBuffContainerMixin:GetTargetYOffset()
	return self.targetYOffset;
end

function NameplateBuffContainerMixin:SetBaseYOffset(baseYOffset)
	self.baseYOffset = baseYOffset;
end

function NameplateBuffContainerMixin:GetBaseYOffset()
	return self.baseYOffset;
end

function NameplateBuffContainerMixin:UpdateAnchor()
	local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, "target");
	local targetYOffset = self:GetBaseYOffset() + (isTarget and self:GetTargetYOffset() or 0);

	if self:GetParent().unit and ShouldShowName(self:GetParent()) then
		self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, targetYOffset);
	else
		self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 5 + targetYOffset);
	end
end

function NameplateBuffContainerMixin:ShouldShowBuff(caster, showAll, spellId)
	if NP_BUFF_BLACKLIST[spellId]
	or NP_DEBUFF_BLACKLIST[spellId]
	or FACTION_OVERRIDE_BY_DEBUFFS[spellId]
	or ZODIAC_DEBUFFS[spellId]
	or S_CATEGORY_SPELL_ID[spellId]
	or S_VIP_STATUS_DATA[spellId]
	or S_PREMIUM_SPELL_ID[spellId]
	then
		return false
	end

	if showAll or NP_SPELL_SHOW_ALL[spellId] or SpellIsPriorityAura(spellId) then
		return true
	end

	local allowPersonal = NP_SPELL_SHOW_PERSONAL[spellId]
	if allowPersonal then
		return caster == "player"
			or caster == "pet"
			or caster == "vehicle"
	end

	return false
end

function NameplateBuffContainerMixin:SetActive(isActive)
	self.isActive = isActive;
end

function NameplateBuffContainerMixin:UpdateBuffs(unit, filter, showAll)
	if not self.isActive then
		for i = 1, BUFF_MAX_DISPLAY do
			if self.buffList[i] then
				self.buffList[i]:Hide();
			else
				break;
			end
		end

		return;
	end

	self.unit = unit;
	self.filter = filter;
	self:UpdateAnchor();

	if filter == "NONE" then
		for i, buff in ipairs(self.buffList) do
			buff:Hide();
		end
	else
		-- Some buffs may be filtered out, use this to create the buff frames.
		local buffIndex = 1;
		local index = 1;
		AuraUtil.ForEachAura(unit, filter, BUFF_MAX_DISPLAY, function(...)
			local name, _, texture, count, debuffType, duration, expirationTime, caster, _, _, spellId = ...;

			if (self:ShouldShowBuff(caster, showAll, spellId)) then
				if (not self.buffList[buffIndex]) then
					self.buffList[buffIndex] = CreateFrame("Frame", nil, self, "NameplateBuffButtonTemplate");
--					self.buffList[buffIndex]:SetMouseClickEnabled(false);
					self.buffList[buffIndex].layoutIndex = buffIndex;
				end
				local buff = self.buffList[buffIndex];
				buff:SetID(index);
				buff.Icon:SetTexture(texture);
				if (count > 1) then
					buff.CountFrame.Count:SetText(count);
					buff.CountFrame.Count:Show();
				else
					buff.CountFrame.Count:Hide();
				end

				CooldownFrame_SetTimer(buff.Cooldown, expirationTime - duration, duration, duration > 0);

				buff:Show();
				buffIndex = buffIndex + 1;
			end
			index = index + 1;
			return buffIndex > BUFF_MAX_DISPLAY;
		end);

		for i = buffIndex, BUFF_MAX_DISPLAY do
			if self.buffList[i] then
				self.buffList[i]:Hide();
			else
				break;
			end
		end
	end
	self:Layout();
end

NameplateBuffButtonTemplateMixin = {};

function NameplateBuffButtonTemplateMixin:OnEnter()
	NamePlateTooltip:SetOwner(self, "ANCHOR_LEFT");
	NamePlateTooltip:SetUnitAura(self:GetParent().unit, self:GetID(), self:GetParent().filter);

	self.UpdateTooltip = self.OnEnter;
end

function NameplateBuffButtonTemplateMixin:OnLeave()
	NamePlateTooltip:Hide();
end

NamePlateBorderTemplateMixin = {};

function NamePlateBorderTemplateMixin:OnLoad()
	if not self.Top then
		self.Textures = {self.Left, self.Right, self.Bottom};
	else
		self.Textures = {self.Left, self.Right, self.Bottom, self.Top};
	end

	if self.SetIgnoreParentScale then
	--	self:SetIgnoreParentScale(true);
	end

	SetParentFrameLevel(self)
end

function NamePlateBorderTemplateMixin:SetVertexColor(r, g, b, a)
	for i, texture in ipairs(self.Textures) do
		texture:SetVertexColor(r, g, b, a);
	end
end

function NamePlateBorderTemplateMixin:SetBorderSizes(borderSize, borderSizeMinPixels, upwardExtendHeightPixels, upwardExtendHeightMinPixels)
	self.borderSize = borderSize;
	self.borderSizeMinPixels = borderSizeMinPixels;
	self.upwardExtendHeightPixels = upwardExtendHeightPixels;
	self.upwardExtendHeightMinPixels = upwardExtendHeightMinPixels;
end

function NamePlateBorderTemplateMixin:UpdateSizes()
	local borderSize = self.borderSize or 1;
	local minPixels = self.borderSizeMinPixels or 2;

	local upwardExtendHeightPixels = self.upwardExtendHeightPixels or borderSize;
	local upwardExtendHeightMinPixels = self.upwardExtendHeightMinPixels or minPixels;

	PixelUtil.SetWidth(self.Left, borderSize, minPixels);
	PixelUtil.SetPoint(self.Left, "TOPRIGHT", self, "TOPLEFT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
	PixelUtil.SetPoint(self.Left, "BOTTOMRIGHT", self, "BOTTOMLEFT", 0, -borderSize, 0, minPixels);

	PixelUtil.SetWidth(self.Right, borderSize, minPixels);
	PixelUtil.SetPoint(self.Right, "TOPLEFT", self, "TOPRIGHT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
	PixelUtil.SetPoint(self.Right, "BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -borderSize, 0, minPixels);

	PixelUtil.SetHeight(self.Bottom, borderSize, minPixels);
	PixelUtil.SetPoint(self.Bottom, "TOPLEFT", self, "BOTTOMLEFT", 0, 0);
	PixelUtil.SetPoint(self.Bottom, "TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);

	if self.Top then
		PixelUtil.SetHeight(self.Top, borderSize, minPixels);
		PixelUtil.SetPoint(self.Top, "BOTTOMLEFT", self, "TOPLEFT", 0, 0);
		PixelUtil.SetPoint(self.Top, "BOTTOMRIGHT", self, "TOPRIGHT", 0, 0);
	end
end