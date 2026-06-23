local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local _G = _G
local abs = abs
local unpack = unpack
local strmatch = strmatch
local CreateFrame = CreateFrame
local UnitCanAttack = UnitCanAttack
local INTERRUPTED = INTERRUPTED

function NP:Castbar_CheckInterrupt(unit)
	if unit == 'vehicle' then
		unit = 'player'
	end

	if self.notInterruptible and UnitCanAttack('player', unit) then
		self:SetStatusBarColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g,
			NP.db.colors.castNoInterruptColor.b)

		if self.Icon and NP.db.colors.castbarDesaturate then
			self.Icon:SetDesaturated(true)
		end
	else
		self:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)

		if self.Icon then
			self.Icon:SetDesaturated(false)
		end
	end
end

function NP:Castbar_CustomDelayText(duration)
	if self.channeling then
		if self.channelTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%.1f |cffaf5050%.1f|r', abs(duration - self.max), self.delay)
		elseif self.channelTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%.1f|r', duration, self.max, self.delay)
		elseif self.channelTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%.1f |cffaf5050%.1f|r', duration, self.delay)
		elseif self.channelTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%.1f|r', abs(duration - self.max), self.max, self.delay)
		end
	else
		if self.castTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%.1f |cffaf5050%s %.1f|r', duration, '+', self.delay)
		elseif self.castTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%s %.1f|r', duration, self.max, '+', self.delay)
		elseif self.castTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%.1f |cffaf5050%s %.1f|r', abs(duration - self.max), '+', self.delay)
		elseif self.castTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f |cffaf5050%s %.1f|r', abs(duration - self.max), self.max, '+',
				self.delay)
		end
	end
end

function NP:Castbar_CustomTimeText(duration)
	if self.channeling then
		if self.channelTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%.1f', abs(duration - self.max))
		elseif self.channelTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', abs(duration - self.max), self.max)
		elseif self.channelTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%.1f', duration)
		elseif self.channelTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', duration, self.max)
		end
	else
		if self.castTimeFormat == 'CURRENT' then
			self.Time:SetFormattedText('%.1f', duration)
		elseif self.castTimeFormat == 'CURRENTMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', duration, self.max)
		elseif self.castTimeFormat == 'REMAINING' then
			self.Time:SetFormattedText('%.1f', abs(duration - self.max))
		elseif self.castTimeFormat == 'REMAININGMAX' then
			self.Time:SetFormattedText('%.1f / %.1f', abs(duration - self.max), self.max)
		end
	end
end

function NP:Castbar_PostCastStart(unit)
	self:CheckInterrupt(unit)
end

function NP:Castbar_PostCastFail()
	self:SetStatusBarColor(NP.db.colors.castInterruptedColor.r, NP.db.colors.castInterruptedColor.g,
		NP.db.colors.castInterruptedColor.b)
end

function NP:Castbar_PostCastInterruptible(unit)
	self:CheckInterrupt(unit)
end

function NP:Castbar_PostCastStop() end

local function PositionCastbarText(castbar, db)
	castbar.Time:ClearAllPoints()
	castbar.Text:ClearAllPoints()

	if db.textPosition == 'BELOW' then
		castbar.Time:Point('TOPRIGHT', castbar, 'BOTTOMRIGHT')
		castbar.Text:Point('TOPLEFT', castbar, 'BOTTOMLEFT')
		if db.hideTime then
			castbar.Text:Point('TOPRIGHT', castbar, 'BOTTOMRIGHT')
		else
			castbar.Text:Point('TOPRIGHT', castbar.Time, 'TOPLEFT', -2, 0)
		end
	elseif db.textPosition == 'ABOVE' then
		castbar.Time:Point('BOTTOMRIGHT', castbar, 'TOPRIGHT')
		castbar.Text:Point('BOTTOMLEFT', castbar, 'TOPLEFT')
		if db.hideTime then
			castbar.Text:Point('BOTTOMRIGHT', castbar, 'TOPRIGHT')
		else
			castbar.Text:Point('BOTTOMRIGHT', castbar.Time, 'BOTTOMLEFT', -2, 0)
		end
	else
		castbar.Time:Point('RIGHT', castbar, 'RIGHT', -4, 0)
		castbar.Text:Point('LEFT', castbar, 'LEFT', 4, 0)
		if db.hideTime then
			castbar.Text:Point('RIGHT', castbar, 'RIGHT', -4, 0)
		else
			castbar.Text:Point('RIGHT', castbar.Time, 'LEFT', -2, 0)
		end
	end
end

function NP:Construct_Castbar(nameplate)
	local castbar = CreateFrame('StatusBar', nameplate:GetName() .. 'Castbar', nameplate)
	do
		local s = nameplate:GetFrameStrata()
		if s ~= 'UNKNOWN' then castbar:SetFrameStrata(s) else castbar:SetFrameStrata('MEDIUM') end
	end
	castbar:SetFrameLevel(nameplate:GetFrameLevel() + 2)
	castbar:CreateBackdrop('Transparent', nil, nil, true, true)
	NP:PinBorderPixel(castbar)
	NP:HookBorderPin(castbar)
	castbar:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))

	NP.StatusBars[castbar] = true

	castbar.Button = CreateFrame('Frame', nil, castbar)
	castbar.Button:SetTemplate(nil, nil, nil, true, true)

	castbar.Icon = castbar.Button:CreateTexture(nil, 'ARTWORK')
	castbar.Icon:SetTexCoord(unpack(E.TexCoords))
	castbar.Icon:SetInside()

	castbar.Time = castbar:CreateFontString(nil, 'OVERLAY')
	castbar.Time:FontTemplate(LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)
	castbar.Time:Point('RIGHT', castbar, 'RIGHT', -4, 0)
	castbar.Time:SetJustifyH('RIGHT')

	castbar.Text = castbar:CreateFontString(nil, 'OVERLAY')
	castbar.Text:FontTemplate(LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)
	castbar.Text:Point('LEFT', castbar, 'LEFT', 4, 0)
	castbar.Text:SetJustifyH('LEFT')
	castbar.Text:SetWordWrap(false)

	castbar.CheckInterrupt = NP.Castbar_CheckInterrupt
	castbar.CustomDelayText = NP.Castbar_CustomDelayText
	castbar.CustomTimeText = NP.Castbar_CustomTimeText
	castbar.PostCastStart = NP.Castbar_PostCastStart
	castbar.PostCastFail = NP.Castbar_PostCastFail
	castbar.PostCastInterruptible = NP.Castbar_PostCastInterruptible
	castbar.PostCastStop = NP.Castbar_PostCastStop

	if nameplate == _G.ElvNP_Test then
		castbar.Hide = castbar.Show
		castbar:Show()
		castbar.Text:SetText('Casting')
		castbar.Time:SetText('3.1')
		castbar.Icon:SetTexture([[Interface\Icons\Achievement_Character_Pandaren_Female]])
		castbar:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)
	end

	return castbar
end

-- 3.3.5a passes combat-log fields as event args; there is no CombatLogGetCurrentEventInfo.
function NP:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, subEvent, sourceGUID, sourceName, _, targetGUID)
	if (subEvent == 'SPELL_INTERRUPT' or subEvent == 'SPELL_PERIODIC_INTERRUPT') and targetGUID and (sourceName and sourceName ~= '') then
		local plate = NP.PlateGUID[targetGUID]
		if plate and plate.Castbar then
			local db = NP:PlateDB(plate)
			if db.castbar and db.castbar.enable and db.castbar.sourceInterrupt and (db.castbar.timeToHold > 0) then
				local name = strmatch(sourceName, '([^%-]+).*')
				plate.Castbar.Text:SetFormattedText('%s > %s', INTERRUPTED, name or sourceName)
			end
		end
	end
end

function NP:Update_Castbar(nameplate)
	local frameDB = NP:PlateDB(nameplate)
	local db = frameDB.castbar

	local castbar = nameplate.Castbar
	if nameplate == _G.ElvNP_Test then
		castbar:SetAlpha((not frameDB.nameOnly and db.enable) and 1 or 0)
	end

	if db.enable and not frameDB.nameOnly then
		if not nameplate:IsElementEnabled('Castbar') then
			nameplate:EnableElement('Castbar')
		end

		castbar.timeToHold = db.timeToHold
		castbar.castTimeFormat = db.castTimeFormat
		castbar.channelTimeFormat = db.channelTimeFormat

		castbar:Size(db.width, db.height)
		castbar:ClearAllPoints()
		castbar:Point('TOP', nameplate.Health, 'BOTTOM', db.xOffset, db.yOffset)

		if db.showIcon then
			castbar.Button:ClearAllPoints()
			castbar.Button:Point(db.iconPosition == 'RIGHT' and 'BOTTOMLEFT' or 'BOTTOMRIGHT', castbar,
				db.iconPosition == 'RIGHT' and 'BOTTOMRIGHT' or 'BOTTOMLEFT', db.iconOffsetX, db.iconOffsetY)
			castbar.Button:Size(db.iconSize, db.iconSize)
			castbar.Button:Show()
		else
			castbar.Button:Hide()
		end

		PositionCastbarText(castbar, db)

		if db.hideTime then
			castbar.Time:Hide()
		else
			castbar.Time:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
			castbar.Time:Show()
		end

		if db.hideSpellName then
			castbar.Text:Hide()
		else
			castbar.Text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
			castbar.Text:Show()
		end
	elseif nameplate:IsElementEnabled('Castbar') then
		nameplate:DisableElement('Castbar')
	end
end
