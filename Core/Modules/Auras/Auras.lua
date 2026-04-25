local E, L, V, P, G = unpack(ElvUI)
local A = E:GetModule('Auras')
local LSM = E.Libs.LSM
local ElvUF = E.oUF

local _G = _G
local unpack = unpack
local floor = math.floor
local tinsert = tinsert
local strmatch = strmatch
local tonumber = tonumber

local UnitAura = UnitAura
local CancelItemTempEnchantment = CancelItemTempEnchantment
local CancelUnitBuff = CancelUnitBuff
local GetInventoryItemQuality = GetInventoryItemQuality
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetInventoryItemTexture = GetInventoryItemTexture
local GameTooltip_Hide = GameTooltip_Hide
local GameTooltip = GameTooltip
local CreateFrame = CreateFrame
local GetTime = GetTime

local Masque = E.Masque or E.Libs.LBF
local MasqueGroupBuffs = Masque and Masque:Group('ElvUI', 'Buffs')
local MasqueGroupDebuffs = Masque and Masque:Group('ElvUI', 'Debuffs')

local DebuffColors = DebuffTypeColor

local DIRECTION_TO_POINT = {
	DOWN_RIGHT = 'TOPLEFT',
	DOWN_LEFT = 'TOPRIGHT',
	UP_RIGHT = 'BOTTOMLEFT',
	UP_LEFT = 'BOTTOMRIGHT',
	RIGHT_DOWN = 'TOPLEFT',
	RIGHT_UP = 'BOTTOMLEFT',
	LEFT_DOWN = 'TOPRIGHT',
	LEFT_UP = 'BOTTOMRIGHT',
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1,
}

local IS_HORIZONTAL_GROWTH = {
	RIGHT_DOWN = true,
	RIGHT_UP = true,
	LEFT_DOWN = true,
	LEFT_UP = true,
}

local MasqueButtonData = {
	Icon = nil,
	Highlight = nil,
	FloatingBG = nil,
	Cooldown = nil,
	Flash = nil,
	Pushed = nil,
	Normal = nil,
	Disabled = nil,
	Checked = nil,
	Border = nil,
	AutoCastable = nil,
	HotKey = nil,
	Count = false,
	Name = nil,
	Duration = false,
	AutoCast = nil,
}

local enchantableSlots = { [1] = 16, [2] = 17 }
local weaponEnchantTime = {}
A.EnchanData = weaponEnchantTime

function A:MasqueData(texture, highlight)
	local data = E:CopyTable({}, MasqueButtonData)
	data.Icon = texture
	data.Highlight = highlight
	return data
end

function A:UpdateButton(button)
	local db = A.db[button.auraType]
	if button.statusBar and button.statusBar:IsShown() then
		local r, g, b
		if db.barColorGradient then
			r, g, b = ElvUF:ColorGradient(button.timeLeft, button.duration or 0, .8, 0, 0, .8, .8, 0, 0, .8, 0)
		else
			r, g, b = db.barColor.r, db.barColor.g, db.barColor.b
		end

		button.statusBar:SetStatusBarColor(r, g, b)
		button.statusBar:SetValue(button.timeLeft)
	end

	local threshold = db.fadeThreshold
	if threshold == -1 then
		return
	elseif button.timeLeft and button.timeLeft > threshold then
		E:StopFlash(button, 1)
	else
		E:Flash(button, 1)
	end
end

function A:CreateIcon(button)
	local header = button:GetParent()

	button.header = header
	button.filter = header.filter
	button.auraType = (header.filter == 'HELPFUL' and 'buffs') or 'debuffs'

	button.name = button:GetName()
	button.enchantIndex = tonumber(strmatch(button.name or '', 'TempEnchant(%d)$'))
	if button.enchantIndex then
		header['enchant' .. button.enchantIndex] = button
		header.enchantButtons[button.enchantIndex] = button
	else
		button.instant = true
	end

	button.texture = button:CreateTexture(nil, 'ARTWORK')
	button.texture:SetInside()

	button.count = button:CreateFontString(nil, 'OVERLAY')
	button.count:FontTemplate()

	button.text = button:CreateFontString(nil, 'OVERLAY')
	button.text:FontTemplate()

	button.highlight = button:CreateTexture(nil, 'HIGHLIGHT')
	button.highlight:SetTexture(1, 1, 1, .45)
	button.highlight:SetInside()

	button.statusBar = CreateFrame('StatusBar', nil, button)
	button.statusBar:OffsetFrameLevel(nil, button)
	button.statusBar:SetFrameStrata(button:GetFrameStrata())
	button.statusBar:SetMinMaxValues(0, 1)
	button.statusBar:SetValue(0)
	button.statusBar:CreateBackdrop()

	button:RegisterForClicks('RightButtonUp')

	button:SetScript('OnUpdate', A.Button_OnUpdate)
	button:SetScript('OnClick', A.Button_OnClick)
	button:SetScript('OnEnter', A.Button_OnEnter)
	button:SetScript('OnLeave', A.Button_OnLeave)
	button:SetScript('OnHide', A.Button_OnHide)
	button:SetScript('OnShow', A.Button_OnShow)

	-- support cooldown override
	if not button.isRegisteredCooldown then
		button.CooldownOverride = 'auras'
		button.isRegisteredCooldown = true
		button.forceEnabled = true
		button.showSeconds = true

		if not E.RegisteredCooldowns.auras then E.RegisteredCooldowns.auras = {} end
		tinsert(E.RegisteredCooldowns.auras, button)
	end

	A:Update_CooldownOptions(button)
	A:UpdateIcon(button)
end

function A:UpdateTexture(button) -- self here can be the header from UpdateMasque calling this function
	local db = A.db[button.auraType]
	local width, height = db.size, (db.keepSizeRatio and db.size) or db.height

	if db.keepSizeRatio then
		button.texture:SetTexCoords()
	else
		local left, right, top, bottom = E:CropRatio(width, height)
		button.texture:SetTexCoord(left, right, top, bottom)
	end
end

function A:UpdateIcon(button, update)
	local db = A.db[button.auraType]

	local width, height = db.size, (db.keepSizeRatio and db.size) or db.height
	if update then
		button:SetWidth(width)
		button:SetHeight(height)
	elseif button.header.MasqueGroup then
		local data = A:MasqueData(button.texture, button.highlight)
		button.header.MasqueGroup:AddButton(button, data)
	elseif not button.template then
		button:SetTemplate()
	end

	if button.texture then
		A:UpdateTexture(button)
	end

	if button.count then
		button.count:ClearAllPoints()
		button.count:Point('BOTTOMRIGHT', db.countXOffset, db.countYOffset)
		button.count:FontTemplate(LSM:Fetch('font', db.countFont), db.countFontSize, db.countFontOutline)
	end

	if button.text then
		button.text:ClearAllPoints()
		button.text:Point('TOP', button, 'BOTTOM', db.timeXOffset, db.timeYOffset)
		button.text:FontTemplate(LSM:Fetch('font', db.timeFont), db.timeFontSize, db.timeFontOutline)
	end

	if button.statusBar then
		E:SetSmoothing(button.statusBar, db.smoothbars)

		local pos, iconSize = db.barPosition, db.size - (E.Border * 2)
		local onTop, onBottom, onLeft = pos == 'TOP', pos == 'BOTTOM', pos == 'LEFT'
		local barSpacing = db.barSpacing + (E.PixelMode and 1 or 3)
		local barSize = db.barSize + (E.PixelMode and 0 or 2)
		local isHorizontal = onTop or onBottom

		button.statusBar:ClearAllPoints()
		button.statusBar:Size(isHorizontal and iconSize or barSize, isHorizontal and barSize or iconSize)
		button.statusBar:Point(E.InversePoints[pos], button, pos, isHorizontal and 0 or (onLeft and -barSpacing or barSpacing), not isHorizontal and 0 or (onTop and barSpacing or -barSpacing))
		button.statusBar:SetStatusBarTexture(LSM:Fetch('statusbar', db.barTexture))
		button.statusBar:SetOrientation(isHorizontal and 'HORIZONTAL' or 'VERTICAL')
		button.statusBar:SetRotatesTexture(not isHorizontal)
	end
end

function A:SetAuraTime(button, expiration, duration, modRate)
	local oldEnd = button.endTime
	button.expiration = expiration
	button.endTime = expiration
	button.duration = duration
	button.modRate = modRate or 1

	if oldEnd ~= button.endTime then
		if button.statusBar:IsShown() then
			button.statusBar:SetMinMaxValues(0, duration)
		end
		button.nextUpdate = 0
	end

	A:UpdateTime(button, expiration, modRate)
	button.elapsed = 0
end

function A:ClearAuraTime(button, expired)
	button.expiration = nil
	button.endTime = nil
	button.duration = nil
	button.modRate = nil
	button.timeLeft = nil

	button.text:SetText('')

	E:StopFlash(button, 1)

	if not expired and button.statusBar:IsShown() then
		button.statusBar:SetMinMaxValues(0, 1)
		button.statusBar:SetValue(1)

		local db = A.db[button.auraType]
		if db.barColorGradient then -- value 1 is just green
			button.statusBar:SetStatusBarColor(0, .8, 0)
		else
			button.statusBar:SetStatusBarColor(db.barColor.r, db.barColor.g, db.barColor.b)
		end
	end
end

function A:UpdateAura(button, index)
	local name, _, icon, count, dispelType, duration, expiration, caster = UnitAura('player', index, button.filter)
	if not name then return end

	local db = A.db[button.auraType]
	button:Show()
	button.text:SetShown(db.showDuration)
	button.statusBar:SetShown((db.barShow and duration > 0) or (db.barShow and db.barNoDuration and duration == 0))
	button.count:SetText(not count or count <= 1 and '' or count)
	button.texture:SetTexture(icon)
	button.auraIndex = index

	local dtype = dispelType or 'none'
	if button.debuffType ~= dtype then
		local color = (button.filter == 'HARMFUL' and A.db.colorDebuffs and DebuffColors[dtype]) or E.db.general.bordercolor
		button:SetBackdropBorderColor(color.r, color.g, color.b)
		button.statusBar.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		button.debuffType = dtype
	end

	if duration > 0 and expiration then
		A:SetAuraTime(button, expiration, duration)
	else
		A:ClearAuraTime(button)
	end
end

function A:UpdateTempEnchant(button, index, expiration)
	local db = A.db[button.auraType]
	button.text:SetShown(db.showDuration)
	button.statusBar:SetShown((db.barShow and expiration) or (db.barShow and db.barNoDuration and not expiration))

	if expiration then
		button.texture:SetTexture(GetInventoryItemTexture('player', index))

		local quality = A.db.colorEnchants and GetInventoryItemQuality('player', index)
		local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)

		button:SetBackdropBorderColor(r, g, b)
		button.statusBar.backdrop:SetBackdropBorderColor(r, g, b)

		local remaining = (expiration * 0.001) or 0
		A:SetAuraTime(button, remaining + GetTime(), (remaining <= 3600 and remaining > 1800) and 3600 or (remaining <= 1800 and remaining > 600) and 1800 or 600)
	else
		A:ClearAuraTime(button)
	end
end

function A:Update_CooldownOptions(button)
	E:Cooldown_Options(button, A.db.cooldown, button)
end

function A:SetTooltip(button)
	if button.auraIndex then
		GameTooltip:SetUnitAura('player', button.auraIndex, button.filter)
	elseif button.enchantIndex then
		GameTooltip:SetInventoryItem('player', enchantableSlots[button.enchantIndex])
	end
end

function A:Button_OnLeave()
	GameTooltip_Hide()
end

function A:Button_OnEnter()
	local db = A.db[self.auraType]
	GameTooltip:SetOwner(self, db.tooltipAnchorType or 'ANCHOR_BOTTOMLEFT', db.tooltipAnchorX or -5, db.tooltipAnchorY or-5)

	-- Immediately set the tooltip instead of waiting for next frame
    A:SetTooltip(self)

	self.elapsed = 1 -- let the tooltip update next frame
end

function A:Button_OnClick()
	if self.enchantIndex then
		CancelItemTempEnchantment(self.enchantIndex)
	elseif self.auraIndex then
		CancelUnitBuff('player', self.auraIndex, self.filter)
	end
end

function A:Button_OnShow()
	if self.enchantIndex then
		self.header.enchants[self.enchantIndex] = self
		self.header.elapsedEnchants = 1 -- let the enchant update next frame
	end
end

function A:Button_OnHide()
	if self.enchantIndex then
		self.header.enchants[self.enchantIndex] = nil
	else
		self.instant = true
	end
end

function A:UpdateTime(button, expiration, modRate)
	button.timeLeft = (expiration - GetTime()) / (modRate or 1)

	if button.timeLeft < 0.1 then
		A:ClearAuraTime(button, true)
	else
		A:UpdateButton(button)
	end
end

function A:Button_OnUpdate(elapsed)
	local xpr = self.endTime
	if xpr then
		E.Cooldown_OnUpdate(self, elapsed)
	end

	if self.elapsed and self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			A:SetTooltip(self)
		end

		if xpr then
			A:UpdateTime(self, xpr, self.modRate)
		end

		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end

function A:Header_OnEvent(event, unit, ...)
	if event == 'PLAYER_ENTERING_WORLD' then
		A:UpdateAllAuras(self)
	-- elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' and unit == 'player' and self.filter == 'HELPFUL' then
	-- 	local subevent, sourceGUID = ...
	-- 	if subevent == 'ENCHANT_APPLIED' and sourceGUID == E.myguid then
	-- 		A:UpdateAllAuras(self)
	-- 	end
	elseif (event == 'UNIT_AURA' or event == 'UNIT_INVENTORY_CHANGED') and unit == 'player' then
		if self.MasqueGroup then
			A:UpdateMasque(self)
		end

		A:UpdateAllAuras(self)
	end
end

function A:UpdateMasque(header)
	if header.MasqueGroup then
		header.MasqueGroup:ReSkin()
		for i = 1, #header.buttons do
			A:UpdateTexture(header.buttons[i])
		end
	end
end

function A:UpdateAllAuras(header)
    if not header or not header.buttons then return end
    if not A.db or not A.db[header.auraType] then return end

    for i = 1, #header.buttons do
        header.buttons[i].auraIndex = nil
        header.buttons[i].enchantIndex = nil
    end

	local buttonIndex = 1

	-- Handle weapon enchants for buffs
	if header.filter == 'HELPFUL' then
		local hasMainHandEnchant, mainHandExpiration, _, hasOffHandEnchant, offHandExpiration = GetWeaponEnchantInfo()

		if hasMainHandEnchant and header.buttons[buttonIndex] then
			local button = header.buttons[buttonIndex]
			button.enchantIndex = 1
			button:Show()
			A:UpdateTempEnchant(button, 16, mainHandExpiration)
			buttonIndex = buttonIndex + 1
		end

		if hasOffHandEnchant and header.buttons[buttonIndex] then
			local button = header.buttons[buttonIndex]
			button.enchantIndex = 2
			button:Show()
			A:UpdateTempEnchant(button, 17, offHandExpiration)
			buttonIndex = buttonIndex + 1
		end
	end

	-- Scan all auras
	local index = 1
	while buttonIndex <= #header.buttons do
		local name = UnitAura('player', index, header.filter)
		if not name then break end

		local button = header.buttons[buttonIndex]
		if button then
			A:UpdateAura(button, index)
			buttonIndex = buttonIndex + 1
		end

		index = index + 1
	end

	-- Hide unused buttons
	for i = buttonIndex, #header.buttons do
		header.buttons[i]:Hide()
		header.buttons[i].auraIndex = nil
		header.buttons[i].enchantIndex = nil
	end

	-- Position buttons
	A:PositionButtons(header)
end

function A:PositionButtons(header)
	if not header or not header.buttons then return end
	if not header.auraType or not A.db or not A.db[header.auraType] then return end

	local db = A.db[header.auraType]
	local width, height = db.size, (db.keepSizeRatio and db.size) or db.height
	local point = DIRECTION_TO_POINT[db.growthDirection]
	local wrapAfter = db.wrapAfter
	local maxWraps = db.maxWraps
	local hSpacing = db.horizontalSpacing
	local vSpacing = db.verticalSpacing
	local isHorizontal = IS_HORIZONTAL_GROWTH[db.growthDirection]
	local hMult = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection]
	local vMult = DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection]

	local visibleIndex = 0
	for i = 1, #header.buttons do
		local button = header.buttons[i]
		if button:IsShown() then
			button:ClearAllPoints()

			local row, col
			if isHorizontal then
				row = floor(visibleIndex / wrapAfter)
				col = visibleIndex % wrapAfter
			else
				col = floor(visibleIndex / wrapAfter)
				row = visibleIndex % wrapAfter
			end

			local xOffset = col * (width + hSpacing) * hMult
			local yOffset = row * (height + vSpacing) * vMult

			button:Point(point, header, point, xOffset, yOffset)
			visibleIndex = visibleIndex + 1
		end
	end
end

function A:UpdateHeader(header)
	if not E.private.auras.enable then return end

	local db = A.db[header.auraType]
	local width, height = db.size, (db.keepSizeRatio and db.size) or db.height

	E:UpdateClassColor(db.barColor)

	-- Calculate actual rows/columns needed based on button count
	local maxButtons = 32
	local iconsPerRow = db.wrapAfter

	local numRows = math.ceil(maxButtons / iconsPerRow)  -- Calculate rows needed

	-- Calculate and set header size based on growth direction
	local headerWidth, headerHeight

	if IS_HORIZONTAL_GROWTH[db.growthDirection] then
		-- Horizontal: iconsPerRow wide, numRows tall
		headerWidth = (width * iconsPerRow) + (db.horizontalSpacing * (iconsPerRow - 1))
		headerHeight = (height * numRows) + (db.verticalSpacing * (numRows - 1))
	else
		-- Vertical: numRows wide, iconsPerRow tall
		headerWidth = (width * numRows) + (db.horizontalSpacing * (numRows - 1))
		headerHeight = (height * iconsPerRow) + (db.verticalSpacing * (iconsPerRow - 1))
	end

	header:SetSize(headerWidth, headerHeight)

	if header.buttons then
		for i = 1, #header.buttons do
			local button = header.buttons[i]
			if button then
				A:Update_CooldownOptions(button)
				A:UpdateIcon(button, true)
			end
		end
	end

	if header.MasqueGroup then
		A:UpdateMasque(header)
	end

	A:UpdateAllAuras(header)
end

function A:CreateAuraHeader(filter)
	local name, auraType = filter == 'HELPFUL' and 'ElvUIPlayerBuffs' or 'ElvUIPlayerDebuffs', filter == 'HELPFUL' and 'buffs' or 'debuffs'

	local header = CreateFrame('Frame', name, E.UIParent)
	header:SetClampedToScreen(true)
	header:SetSize(200, 200)
	header:Show()

	header.filter = filter
	header.auraType = auraType
	header.name = name

	header.buttons = {}
	header.enchants = {}
	header.enchantButtons = {}

	local db = A.db[auraType]
	local numButtons = (db.wrapAfter or 8) * (db.maxWraps or 5)

	-- Only create buttons if they don't exist
	if #header.buttons == 0 then
		for i = 1, numButtons do
			local button = CreateFrame('Button', name .. 'Button' .. i, header)
			button:SetID(i)
			button:Hide()
			A:CreateIcon(button)
			header.buttons[i] = button
		end
	end

	-- Register events
	header:RegisterEvent('UNIT_AURA')
	header:RegisterEvent('UNIT_INVENTORY_CHANGED')
	header:RegisterEvent('PLAYER_ENTERING_WORLD')

	-- NEW: Register for COMBAT_LOG_EVENT_UNFILTERED for enchant detection
	if filter == 'HELPFUL' then
		header:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	end

	header:HookScript('OnEvent', A.Header_OnEvent)

	if filter == 'HELPFUL' then
		if MasqueGroupBuffs and E.private.auras.masque.buffs then
			header.MasqueGroup = MasqueGroupBuffs
		end
	elseif MasqueGroupDebuffs and E.private.auras.masque.debuffs then
		header.MasqueGroup = MasqueGroupDebuffs
	end

	header:Show()

	return header
end

function A:Initialize()
	if E.private.auras.disableBlizzard then
		BuffFrame:Kill()
		TemporaryEnchantFrame:Kill()

		if ConsolidatedBuffs then
			ConsolidatedBuffs:Kill()
		end
	end

	if not E.private.auras.enable then return end

	A.Initialized = true
	A.db = E.db.auras
	E.myguid = E.myguid or UnitGUID('player') -- Ensure we have the player's GUID

	local xoffset = -(6 + E.Border)

	if E.private.auras.buffsHeader then
		A.BuffFrame = A:CreateAuraHeader('HELPFUL')
		A:UpdateHeader(A.BuffFrame)

		A.BuffFrame:ClearAllPoints()
		A.BuffFrame:Point('TOPRIGHT', _G.ElvUI_MinimapHolder or _G.Minimap, 'TOPLEFT', xoffset, -E.Spacing)

		E:CreateMover(A.BuffFrame, 'BuffsMover', L["Player Buffs"], nil, nil, nil, nil, nil, 'auras,buffs')
	end

	if E.private.auras.debuffsHeader then
		A.DebuffFrame = A:CreateAuraHeader('HARMFUL')
		A:UpdateHeader(A.DebuffFrame)

		A.DebuffFrame:ClearAllPoints()
		A.DebuffFrame:Point('BOTTOMRIGHT', _G.ElvUI_MinimapHolder or _G.Minimap, 'BOTTOMLEFT', xoffset, E.Spacing)

		E:CreateMover(A.DebuffFrame, 'DebuffsMover', L["Player Debuffs"], nil, nil, nil, nil, nil, 'auras,debuffs')
	end
end

E:RegisterModule(A:GetName())