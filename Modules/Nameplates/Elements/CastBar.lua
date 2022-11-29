local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
local unpack = unpack
local abs = math.abs
--WoW API / Variables
local CreateFrame = CreateFrame
-- local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo


function NP:UpdateElement_CastBarOnShow()
	local parent = self:GetParent()
	local unitFrame = parent.UnitFrame
	if not unitFrame.UnitType then
		return
	end

	if NP.db.units[unitFrame.UnitType].castbar.enable ~= true then return end
	if not unitFrame.Health:IsShown() and not NP.db.units[unitFrame.UnitType].castbar.showWhenHPHidden  then return end

	if unitFrame.CastBar then
		unitFrame.CastBar:Show()

		NP:StyleFilterUpdate(unitFrame, "FAKE_Casting")
	end
end

function NP:UpdateElement_CastBarOnHide()
	local parent = self:GetParent()
	if parent.UnitFrame.CastBar then
		parent.UnitFrame.CastBar:Hide()

		NP:StyleFilterUpdate(parent.UnitFrame, "FAKE_Casting")
	end
end


function NP:UpdateElement_CastBarOnValueChanged(value)
	local frame = self:GetParent()
	local min, max = self:GetMinMaxValues()
	local unitFrame = frame.UnitFrame
	local isChannel = value < unitFrame.CastBar:GetValue()

	unitFrame.CastBar.value = value
	unitFrame.CastBar.max = max
	unitFrame.CastBar:SetMinMaxValues(min, max)
	unitFrame.CastBar:SetValue(value)

	if isChannel then
		if unitFrame.CastBar.channelTimeFormat == "CURRENT" then
			unitFrame.CastBar.Time:SetFormattedText("%.1f", abs(unitFrame.CastBar.value - unitFrame.CastBar.max))
		elseif unitFrame.CastBar.channelTimeFormat == "CURRENTMAX" then
			unitFrame.CastBar.Time:SetFormattedText("%.1f / %.2f", abs(unitFrame.CastBar.value - unitFrame.CastBar.max), unitFrame.CastBar.max)
		elseif unitFrame.CastBar.channelTimeFormat == "REMAINING" then
			unitFrame.CastBar.Time:SetFormattedText("%.1f", unitFrame.CastBar.value)
		elseif unitFrame.CastBar.channelTimeFormat == "REMAININGMAX" then
			unitFrame.CastBar.Time:SetFormattedText("%.1f / %.2f", unitFrame.CastBar.value, unitFrame.CastBar.max)
		end
	else
		if unitFrame.CastBar.castTimeFormat == "CURRENT" then
			unitFrame.CastBar.Time:SetFormattedText("%.1f", unitFrame.CastBar.value)
		elseif unitFrame.CastBar.castTimeFormat == "CURRENTMAX" then
			unitFrame.CastBar.Time:SetFormattedText("%.1f / %.2f", unitFrame.CastBar.value, unitFrame.CastBar.max)
		elseif unitFrame.CastBar.castTimeFormat == "REMAINING" then
			unitFrame.CastBar.Time:SetFormattedText("%.1f", abs(unitFrame.CastBar.value - unitFrame.CastBar.max))
		elseif unitFrame.CastBar.castTimeFormat == "REMAININGMAX" then
			unitFrame.CastBar.Time:SetFormattedText("%.1f / %.2f", abs(unitFrame.CastBar.value - unitFrame.CastBar.max), unitFrame.CastBar.max)
		end
	end

	local unit = unitFrame.unit or unitFrame.unitName
	if unit then
		local spell, _, spellName = UnitCastingInfo(unit)
		if not spell then
			_, _, spellName = UnitChannelInfo(unit)
		end
		-- print(spellName)
		-- if unitFrame.CastBar:IsShown() then
			-- unitFrame.CastBar.Name:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
			-- print(unitFrame.CastBar.Name)
		if spellName and unitFrame.Health:IsShown() then
			unitFrame.CastBar.Name:SetText(spellName)
		end
		-- end
	else
		if unitFrame.Health:IsShown() then
			unitFrame.CastBar.Name:SetText("")
		end
	end

	unitFrame.CastBar.Icon.texture:SetTexture(self.Icon:GetTexture())
	self.Icon:Hide()
	if not self.Shield:IsShown() then
		unitFrame.CastBar:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)
		unitFrame.CastBar.Icon.texture:SetDesaturated(false)
	else
		unitFrame.CastBar:SetStatusBarColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g, NP.db.colors.castNoInterruptColor.b)

		if NP.db.colors.castbarDesaturate then
			unitFrame.CastBar.Icon.texture:SetDesaturated(true)
		end
	end

	NP:StyleFilterUpdate(unitFrame, "FAKE_Casting")
end

function NP:Configure_CastBarScale(frame, scale, noPlayAnimation)
	if frame.currentScale == scale then return end
	local db = self.db.units[frame.UnitType].castbar
	if not db.enable then return end

	local castBar = frame.CastBar

	if noPlayAnimation then
		castBar:SetSize(db.width * scale, db.height * scale)
		castBar.Icon:SetSize(db.iconSize * scale, db.iconSize * scale)
	else
		if castBar.scale:IsPlaying() or castBar.Icon.scale:IsPlaying() then
			castBar.scale:Stop()
			castBar.Icon.scale:Stop()
		end

		castBar.scale.width:SetChange(db.width * scale)
		castBar.scale.height:SetChange(db.height * scale)
		castBar.scale:Play()

		castBar.Icon.scale.width:SetChange(db.iconSize * scale)
		castBar.Icon.scale.height:SetChange(db.iconSize * scale)
		castBar.Icon.scale:Play()
	end
end

function NP:Configure_CastBar(frame, configuring)
	local db = self.db.units[frame.UnitType].castbar
	local castBar = frame.CastBar

	castBar:SetPoint("TOP", frame.Health, "BOTTOM", db.xOffset, db.yOffset)

	if db.showIcon then
		castBar.Icon:ClearAllPoints()
		castBar.Icon:SetPoint(db.iconPosition == "RIGHT" and "BOTTOMLEFT" or "BOTTOMRIGHT", castBar, db.iconPosition == "RIGHT" and "BOTTOMRIGHT" or "BOTTOMLEFT", db.iconOffsetX, db.iconOffsetY)
		castBar.Icon:Show()
	else
		castBar.Icon:Hide()
	end

	castBar.Time:ClearAllPoints()
	castBar.Name:ClearAllPoints()

	castBar.Spark:SetPoint("CENTER", castBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	castBar.Spark:SetHeight(db.height * 2)

	if db.textPosition == "BELOW" then
		castBar.Time:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT")
		castBar.Name:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT")
	elseif db.textPosition == "ABOVE" then
		castBar.Time:SetPoint("BOTTOMRIGHT", castBar, "TOPRIGHT")
		castBar.Name:SetPoint("BOTTOMLEFT", castBar, "TOPLEFT")
	else
		castBar.Time:SetPoint("RIGHT", castBar, "RIGHT", -4, 0)
		castBar.Name:SetPoint("LEFT", castBar, "LEFT", 4, 0)
	end

	if configuring then
		self:Configure_CastBarScale(frame, frame.currentScale or 1, configuring)
	end

	castBar.Name:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
	castBar.Time:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)

	if db.hideSpellName then
		castBar.Name:Hide()
	else
		castBar.Name:Show()
	end
	if db.hideTime then
		castBar.Time:Hide()
	else
		castBar.Time:Show()
	end

	castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))

	castBar.castTimeFormat = db.castTimeFormat
	castBar.channelTimeFormat = db.channelTimeFormat
end

function NP:Construct_CastBar(parent)
	local frame = CreateFrame("StatusBar", "$parentCastBar", parent)
	NP:StyleFrame(frame)

	frame.Icon = CreateFrame("Frame", nil, frame)
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER")
	frame.Icon.texture:SetAllPoints()
	frame.Icon.texture:SetTexCoord(unpack(E.TexCoords))
	NP:StyleFrame(frame.Icon)

	frame.Time = frame:CreateFontString(nil, "OVERLAY")
	frame.Time:SetJustifyH("RIGHT")
	frame.Time:SetWordWrap(false)

	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Name:SetJustifyH("LEFT")
	frame.Name:SetWordWrap(false)

	frame.Spark = frame:CreateTexture(nil, "OVERLAY")
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	frame.Spark:SetBlendMode("ADD")
	frame.Spark:SetSize(15, 15)

	frame.holdTime = 0
	frame.interrupted = nil

	frame.scale = CreateAnimationGroup(frame)
	frame.scale.width = frame.scale:CreateAnimation("Width")
	frame.scale.width:SetDuration(0.2)
	frame.scale.height = frame.scale:CreateAnimation("Height")
	frame.scale.height:SetDuration(0.2)

	frame.Icon.scale = CreateAnimationGroup(frame.Icon)
	frame.Icon.scale.width = frame.Icon.scale:CreateAnimation("Width")
	frame.Icon.scale.width:SetDuration(0.2)
	frame.Icon.scale.height = frame.Icon.scale:CreateAnimation("Height")
	frame.Icon.scale.height:SetDuration(0.2)

	frame:Hide()

	return frame
end