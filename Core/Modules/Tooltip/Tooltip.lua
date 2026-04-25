local E, L, V, P, G = unpack(ElvUI)
local TT = E:GetModule('Tooltip')
local AB = E:GetModule('ActionBars')
local S = E:GetModule('Skins')
local B = E:GetModule('Bags')
local LSM = E.Libs.LSM

local _G = _G
local unpack, select, ipairs = unpack, select, ipairs
local wipe, next, tinsert, tconcat = wipe, next, tinsert, table.concat
local floor, tonumber, strlower = floor, tonumber, strlower
local strfind, format, strmatch, strsub = strfind, format, strmatch, strsub

local CanInspect = CanInspect
local CreateFrame = CreateFrame
local GameTooltip_ClearMoney = GameTooltip_ClearMoney
local GameTooltip_ClearStatusBars = GameTooltip_ClearStatusBars
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetCurrencyListInfo = GetCurrencyListInfo
local CheckInteractDistance = CheckInteractDistance
local GetGuildInfo = GetGuildInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemCount = GetItemCount
local GetItemInfo = GetItemInfo
local GetMouseFocus = GetMouseFocus
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local NotifyInspect = NotifyInspect
local SetTooltipMoney = SetTooltipMoney
local ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3 = ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3
local UIParent = UIParent
local UnitAura = UnitAura
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitGUID = UnitGUID
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsAFK = UnitIsAFK
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsPVP = UnitIsPVP
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local UnitRace = UnitRace
local UnitReaction = UnitReaction
local UnitSex = UnitSex

local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local UNKNOWN = UNKNOWN
local NONE = NONE

local GameTooltip, GameTooltipStatusBar = GameTooltip, GameTooltipStatusBar
-- Custom to find LEVEL string on tooltip
local LEVEL1 = strlower(_G.TOOLTIP_UNIT_LEVEL:gsub('%s?%%s%s?%-?',''))
local LEVEL2 = strlower(_G.TOOLTIP_UNIT_LEVEL_CLASS:gsub('^%%2$s%s?(.-)%s?%%1$s','%1'):gsub('^%-?г?о?%s?',''):gsub('%s?%%s%s?%-?',''))
local IDLine = '|cFFCA3C3C%s|r %d'
local targetList, TAPPED_COLOR = {}, { r=0.6, g=0.6, b=0.6 }
local AFK_LABEL = ' |cffFFFFFF[|r|cffFF9900'..L["AFK"]..'|r|cffFFFFFF]|r'
local DND_LABEL = ' |cffFFFFFF[|r|cffFF3333'..L["DND"]..'|r|cffFFFFFF]|r'
local genderTable = { _G.UNKNOWN..' ', _G.MALE..' ', _G.FEMALE..' ' }

function TT:IsModKeyDown(db)
	local k = db or TT.db.modifierID -- defaulted to 'HIDE' unless otherwise specified
	return k == 'SHOW' or ((k == 'SHIFT' and IsShiftKeyDown()) or (k == 'CTRL' and IsControlKeyDown()) or (k == 'ALT' and IsAltKeyDown()))
end

local inventorySlots = {
	'HeadSlot', 'NeckSlot', 'ShoulderSlot', 'BackSlot', 'ChestSlot', 'WristSlot',
	'HandsSlot', 'WaistSlot', 'LegsSlot', 'FeetSlot', 'Finger0Slot', 'Finger1Slot',
	'Trinket0Slot', 'Trinket1Slot', 'MainHandSlot', 'SecondaryHandSlot', 'RangedSlot'
}

function TT:SetCompareItems(tt, value)
	if tt == GameTooltip then
		tt.supportsItemComparison = value
	end
end

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if not E.private.tooltip.enable or not TT.db.visibility or tt:GetAnchorType() ~= 'ANCHOR_NONE' then
		return
	elseif (InCombatLockdown() and not TT:IsModKeyDown(TT.db.visibility.combatOverride)) or (not AB.KeyBinder.active and not TT:IsModKeyDown(TT.db.visibility.actionbars) and AB.handledbuttons[tt:GetOwner()]) then
		TT:SetCompareItems(tt, false)
		tt:Hide() -- during kb mode this will trigger AB.ShowBinds
		return
	end

	TT:SetCompareItems(tt, true)

	local statusBar = tt.StatusBar
	if statusBar then
		local spacing = E.Spacing * 3
		local position = TT.db.healthBar.statusPosition
		statusBar:SetAlpha(position == 'DISABLED' and 0 or 1)

		if position == 'BOTTOM' and statusBar.anchoredToTop then
			statusBar:ClearAllPoints()
			statusBar:Point('TOPLEFT', tt, 'BOTTOMLEFT', E.Border, -spacing)
			statusBar:Point('TOPRIGHT', tt, 'BOTTOMRIGHT', -E.Border, -spacing)
			statusBar.anchoredToTop = nil
		elseif position == 'TOP' and not statusBar.anchoredToTop then
			statusBar:ClearAllPoints()
			statusBar:Point('BOTTOMLEFT', tt, 'TOPLEFT', E.Border, spacing)
			statusBar:Point('BOTTOMRIGHT', tt, 'TOPRIGHT', -E.Border, spacing)
			statusBar.anchoredToTop = true
		end
	end

	if parent then
		if TT.db.cursorAnchor then
			local anchor = (TT.db.cursorAnchorType == 'ANCHOR_CURSOR_LEFT' and 'ANCHOR_CURSOR_RIGHT' or TT.db.cursorAnchorType)
			local pointX = ((TT.db.cursorAnchorType == 'ANCHOR_CURSOR_LEFT' and -128 + TT.db.cursorAnchorX or 0) + TT.db.cursorAnchorX)
			local pointY = TT.db.cursorAnchorY

			tt:SetOwner(parent, anchor, pointX, pointY)
			return
		else
			tt:SetOwner(parent, 'ANCHOR_NONE')
		end
	end

	local RightChatPanel = _G.RightChatPanel
	local TooltipMover = _G.TooltipMover
	local _, anchor = tt:GetPoint()

	if anchor == nil or anchor == B.BagFrame or anchor == RightChatPanel or anchor == TooltipMover or anchor == _G.GameTooltipDefaultContainer or anchor == UIParent or anchor == E.UIParent then
		tt:ClearAllPoints()

		if not E:HasMoverBeenMoved('TooltipMover') then
			if B.BagFrame and B.BagFrame:IsShown() then
				tt:Point('BOTTOMRIGHT', B.BagFrame, 'TOPRIGHT', 0, 18)
			elseif RightChatPanel:GetAlpha() == 1 and RightChatPanel:IsShown() then
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'TOPRIGHT', 0, 18)
			else
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, 18)
			end
		else
			local point = E:GetScreenQuadrant(TooltipMover)
			if point == 'TOPLEFT' then
				tt:Point('TOPLEFT', TooltipMover, 'BOTTOMLEFT', 1, -4)
			elseif point == 'TOPRIGHT' then
				tt:Point('TOPRIGHT', TooltipMover, 'BOTTOMRIGHT', -1, -4)
			elseif point == 'BOTTOMLEFT' or point == 'LEFT' then
				tt:Point('BOTTOMLEFT', TooltipMover, 'TOPLEFT', 1, 18)
			else
				tt:Point('BOTTOMRIGHT', TooltipMover, 'TOPRIGHT', -1, 18)
			end
		end
	end
end

function TT:GetItemLvL(unit)
	local total, items = 0, 0
	for i = 1, #inventorySlots do
		local itemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(inventorySlots[i]))

		if itemLink then
			local iLvl = select(4, GetItemInfo(itemLink))
			if iLvl and iLvl > 0 then
				items = items + 1
				total = total + iLvl
			end
		end
	end

	if items == 0 then
		return 0
	end

	return E:Round(total / items, 2)
end

function TT:RemoveTrashLines(tt)
	local info = tt:GetTooltipData()
	if not (info and info.lines[3]) then return end

	for i, line in next, info.lines, 3 do
		local text = line and line.leftText
		if not text or text == '' then
			break
		elseif text == _G.PVP or text == _G.FACTION_ALLIANCE or text == _G.FACTION_HORDE then
			local left = _G['GameTooltipTextLeft'..i]
			left:SetText('')
			left:Hide()
		end
	end
end

function TT:GetLevelLine(tt, offset, raw)
	local info = tt:GetTooltipData()
	if not (info and info.lines[offset]) then return end

	for i, line in next, info.lines, offset do
		local text = line and line.leftText
		if not text or text == '' then return end

		local lower = strlower(text)
		if lower and (strfind(lower, LEVEL1) or strfind(lower, LEVEL2)) then
			if raw then
				return line, info.lines[i+1]
			else
				return _G['GameTooltipTextLeft'..i], _G['GameTooltipTextLeft'..i+1]
			end
		end
	end
end

function TT:SetUnitText(tt, unit, isPlayerUnit)
	local name, realm = UnitName(unit)

	if isPlayerUnit then
		local localeClass, class = UnitClass(unit)
		if not localeClass or not class then return end

		local nameRealm = (realm and realm ~= '' and format('%s-%s', name, realm)) or name
		local guildName, guildRankName = GetGuildInfo(unit)
		local pvpName, gender = UnitPVPName(unit), UnitSex(unit)
		local level = UnitLevel(unit)
		local isShiftKeyDown = IsShiftKeyDown()

		local nameColor = E:ClassColor(class) or PRIEST_COLOR

		if TT.db.playerTitles and pvpName and pvpName ~= '' then
			name = pvpName
		end

		if realm and realm ~= '' then
			if isShiftKeyDown or TT.db.alwaysShowRealm then
				name = name..'-'..realm
			else
				name = name.._G.FOREIGN_SERVER_LABEL
			end
		end

		local awayText = UnitIsAFK(unit) and AFK_LABEL or UnitIsDND(unit) and DND_LABEL or ''
		_G.GameTooltipTextLeft1:SetFormattedText('|c%s%s%s|r', nameColor.colorStr, name or UNKNOWN, awayText)

		local levelLine, specLine = TT:GetLevelLine(tt, guildName and 2 or 1)
		if guildName then
			local text = TT.db.guildRanks and format('<|cff00ff10%s|r> [|cff00ff10%s|r]', guildName, guildRankName) or format('<|cff00ff10%s|r>', guildName)
			if levelLine == _G.GameTooltipTextLeft2 then
				tt:AddLine(text, 1, 1, 1)
			else
				_G.GameTooltipTextLeft2:SetText(text)
			end
		end

		if levelLine then
			local diffColor = GetQuestDifficultyColor(level)
			local race = UnitRace(unit)
			local hexColor = E:RGBToHex(diffColor.r, diffColor.g, diffColor.b)
			local unitGender = TT.db.gender and genderTable[gender]

			local levelText
			levelText = format('%s%s|r %s%s', hexColor, level > 0 and level or '??', unitGender or '', race or '')
			levelText = format('%s |c%s%s|r', levelText, nameColor.colorStr, localeClass)

			local specText = specLine and specLine:GetText()
			if specText then
				specLine:SetFormattedText('|c%s%s|r', nameColor.colorStr, specText)
			end

			levelLine:SetFormattedText(levelText)
		end

		if TT.db.showElvUIUsers then
			local addonUser = E.UserList[nameRealm]
			if addonUser then
				local same = addonUser == E.version
				tt:AddDoubleLine(L["ElvUI Version:"], format('%.2f', addonUser), nil, nil, nil, same and 0.2 or 1, same and 1 or 0.2, 0.2)
			end
		end

		return nameColor
	else
		local levelLine = TT:GetLevelLine(tt, 2)
		if levelLine then
			local pvpFlag, classificationString = '', ''
			local level = UnitLevel(unit)
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local diffColor = GetQuestDifficultyColor(level)

			if UnitIsPVP(unit) then
				pvpFlag = format(' (%s)', _G.PVP)
			end

			if creatureClassification == 'rare' or creatureClassification == 'elite' or creatureClassification == 'rareelite' or creatureClassification == 'worldboss' then
				classificationString = format('%s %s|r', E:CallTag('classificationcolor', unit), E:CallTag('classification', unit))
			end

			levelLine:SetFormattedText('|cff%02x%02x%02x%s|r%s %s%s', diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or '??', classificationString, creatureType or '', pvpFlag)
		end
	end

	local unitReaction = UnitReaction(unit, 'player')
	local nameColor = unitReaction and ((TT.db.useCustomFactionColors and TT.db.factionColors[unitReaction]) or _G.FACTION_BAR_COLORS[unitReaction]) or PRIEST_COLOR

	return (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and TAPPED_COLOR) or nameColor
end

local inspectGUIDCache = {}
function TT:PopulateInspectGUIDCache(unitGUID, itemLevel)
	if itemLevel then
		local inspectCache = inspectGUIDCache[unitGUID]
		if inspectCache then
			inspectCache.time = GetTime()
			inspectCache.itemLevel = itemLevel
		end

		GameTooltip.ItemLevelShown = true
		GameTooltip:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
		GameTooltip:Show()
	end
end

function TT:INSPECT_TALENT_READY(event, unitGUID)
	if UnitExists('mouseover') and UnitGUID('mouseover') == unitGUID then
		local itemLevel, retryUnit, retryTable, iLevelDB = E:GetUnitItemLevel('mouseover')
		if itemLevel == 'tooSoon' then
			E:Delay(0.05, function()
				local canUpdate = true
				for _, x in ipairs(retryTable) do
					local slotInfo = E:GetGearSlotInfo(retryUnit, x)
					if slotInfo == 'tooSoon' then
						canUpdate = false
					else
						iLevelDB[x] = slotInfo.iLvl
					end
				end

				if canUpdate then
					local calculateItemLevel = E:CalculateAverageItemLevel(iLevelDB, retryUnit)
					TT:PopulateInspectGUIDCache(unitGUID, calculateItemLevel)
				end
			end)
		else
			TT:PopulateInspectGUIDCache(unitGUID, itemLevel)
		end
	end

	if event then
		TT:UnregisterEvent(event)
	end
end

local lastGUID
function TT:AddInspectInfo(tt, unit, numTries, r, g, b)
	if tt.ItemLevelShown or (not unit) or (numTries > 3) or not CanInspect(unit) or not CheckInteractDistance(unit, 4) then return end

	local unitGUID = UnitGUID(unit)
	if not unitGUID then return end
	local cache = inspectGUIDCache[unitGUID]

	if unitGUID == E.myguid then
		tt.ItemLevelShown = true
		tt:AddDoubleLine(L["Item Level:"], E:GetUnitItemLevel(unit), nil, nil, nil, 1, 1, 1)
	elseif cache and cache.time then
		local itemLevel = cache.itemLevel
		if not itemLevel or (GetTime() - cache.time > 120) then
			cache.time, cache.itemLevel = nil, nil
			return E:Delay(0.33, TT.AddInspectInfo, TT, tt, unit, numTries + 1, r, g, b)
		end

		tt.ItemLevelShown = true
		tt:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
	elseif unitGUID then
		if not inspectGUIDCache[unitGUID] then
			inspectGUIDCache[unitGUID] = { unitColor = {r, g, b} }
		end

		if lastGUID ~= unitGUID then
			lastGUID = unitGUID
			NotifyInspect(unit)
			TT:RegisterEvent('INSPECT_TALENT_READY')
		else
			TT:INSPECT_TALENT_READY(nil, unitGUID)
		end
	end
end

function TT:AddTargetInfo(tt, unit)
	local unitTarget = unit..'target'
	if unit ~= 'player' and UnitExists(unitTarget) then
		local targetColor
		if UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget) then
			local _, class = UnitClass(unitTarget)
			targetColor = E:ClassColor(class) or PRIEST_COLOR
		else
			local reaction = UnitReaction(unitTarget, 'player')
			targetColor = (TT.db.useCustomFactionColors and TT.db.factionColors[reaction]) or FACTION_BAR_COLORS[reaction] or PRIEST_COLOR
		end

		tt:AddDoubleLine(format('%s:', _G.TARGET), format('|cff%02x%02x%02x%s|r', targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
	end

	if GetNumPartyMembers() > 0 then
		local isInRaid = GetNumRaidMembers() > 1
		for i = 1, GetNumPartyMembers() do
			local groupUnit = (isInRaid and 'raid' or 'party')..i
			if UnitIsUnit(groupUnit..'target', unit) and not UnitIsUnit(groupUnit,'player') then
				local _, class = UnitClass(groupUnit)
				local classColor = E:ClassColor(class) or PRIEST_COLOR
				tinsert(targetList, format('|c%s%s|r', classColor.colorStr, UnitName(groupUnit)))
			end
		end

		local numList = #targetList
		if numList > 0 then
			tt:AddLine(format('%s (|cffffffff%d|r): %s', L["Targeted By:"], numList, tconcat(targetList, ', ')), nil, nil, nil, true)
			wipe(targetList)
		end
	end
end

function TT:AddRoleInfo(tt, unit)
	local tank, healer, damage = UnitGroupRolesAssigned(unit)
	local role = (tank and 'TANK') or (healer and 'HEALER') or (damage and 'DAMAGER') or NONE
	local r, g, b = 1, 1, 1

	if GetNumPartyMembers() > 0 and (UnitInParty(unit) or UnitInRaid(unit)) then
		if role == 'HEALER' then
			role, r, g, b = _G.HEALER, 0, 1, .59
		elseif role == 'TANK' then
			role, r, g, b = _G.TANK, .16, .31, .61
		elseif role == 'DAMAGER' then
			role, r, g, b = L["DPS"], .77, .12, .24
		end

		tt:AddDoubleLine(format('%s:', _G.ROLE), role, nil, nil, nil, r, g, b)
	end
end

function TT:GameTooltip_OnTooltipSetUnit(data)
	if self ~= GameTooltip or not TT.db.visibility then return end

	local _, unit = self:GetUnit()
	local isPlayerUnit = UnitIsPlayer(unit)
	if self:GetOwner() ~= UIParent and not TT:IsModKeyDown(TT.db.visibility.unitFrames) then
		self:Hide()
		return
	end

	if not unit then
		local GMF = GetMouseFocus()
		local focusUnit = GMF and GMF.GetAttribute and GMF:GetAttribute('unit')
		if focusUnit then unit = focusUnit end
		if not unit or not UnitExists(unit) then
			return
		end
	end

	TT:RemoveTrashLines(self) --keep an eye on this may be buggy

	local isShiftKeyDown = IsShiftKeyDown()
	local isControlKeyDown = IsControlKeyDown()
	local color = TT:SetUnitText(self, unit, isPlayerUnit)

	if TT.db.targetInfo and not isShiftKeyDown and not isControlKeyDown then
		TT:AddTargetInfo(self, unit)
	end

	if TT.db.role then
		TT:AddRoleInfo(self, unit)
	end

	if not InCombatLockdown() then
		if isShiftKeyDown and color and TT.db.inspectDataEnable and not self.ItemLevelShown then
			TT:AddInspectInfo(self, unit, 0, color.r, color.g, color.b)
		end
	end

	if unit and not isPlayerUnit and TT:IsModKeyDown() then
		local guid = (data and data.guid) or UnitGUID(unit) or ''
		local id = tonumber(strsub(guid, 8, 12), 16)
		if id then -- NPC ID's
			self:AddLine(format(IDLine, _G.ID, id))
		end
	end

	local statusBar = self.StatusBar
	if color then
		statusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		statusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end

	if statusBar.text then
		local textWidth = statusBar.text:GetStringWidth()
		if textWidth then
			self:SetMinimumWidth(textWidth)
		end
	end
end

function TT:GameTooltipStatusBar_OnValueChanged(tt, value)
	if not value or not tt.text or not TT.db.healthBar.text then return end

	-- try to get ahold of the unit token
	local _, unit = tt:GetParent():GetUnit()
	if not unit then
		local frame = GetMouseFocus()
		if frame and frame.GetAttribute then
			unit = frame:GetAttribute('unit')
		end
	end

	-- check if dead
	if value == 0 or (unit and UnitIsDeadOrGhost(unit)) then
		tt.text:SetText(_G.DEAD)
	else
		local MAX, _
		if unit then -- try to get the real health values if possible
			value, MAX = UnitHealth(unit), UnitHealthMax(unit)
		else
			_, MAX = tt:GetMinMaxValues()
		end

		-- return what we got
		if value > 0 and MAX == 1 then
			tt.text:SetFormattedText('%d%%', floor(value * 100))
		else
			tt.text:SetText(E:ShortValue(value)..' / '..E:ShortValue(MAX))
		end
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	if tt.qualityChanged then
		tt.qualityChanged = nil
	end

	tt.ItemLevelShown = nil

	if tt.ItemTooltip then
		tt.ItemTooltip:Hide()
	end

	-- This code is to reset stuck widgets.
	GameTooltip_ClearMoney(tt)
	GameTooltip_ClearStatusBars(tt)
end

function TT:EmbeddedItemTooltip_ID(tt, id)
	if tt.Tooltip:IsShown() and TT:IsModKeyDown() then
		tt.Tooltip:AddLine(format(IDLine, _G.ID, id))
		tt.Tooltip:Show()
	end
end

function TT:EmbeddedItemTooltip_QuestReward(tt)
	if tt.Tooltip:IsShown() and TT:IsModKeyDown() then
		tt.Tooltip:AddLine(format(IDLine, _G.ID, tt.itemID or tt.spellID))
		tt.Tooltip:Show()
	end
end

function TT:GameTooltip_OnTooltipSetItem(data)
	if (self ~= GameTooltip and self ~= _G.ShoppingTooltip1 and self ~= _G.ShoppingTooltip2) or not TT.db.visibility then return end

	local owner = self:GetOwner()
	local ownerName = owner and owner.GetName and owner:GetName()
	if ownerName and (strfind(ownerName, 'ElvUI_Container') or strfind(ownerName, 'ElvUI_BankContainer')) and not TT:IsModKeyDown(TT.db.visibility.bags) then
		self:Hide()
		return
	end

	local itemID, bagCount, bankCount, stackSize
	local modKey = TT:IsModKeyDown()
	local GetItem = self.GetItem
	if GetItem then
		local _, link = GetItem(self)
		if not link then return end

		TT:SetStyle(self)

		if modKey then
			itemID = format('|cFFCA3C3C%s|r %s', _G.ID, (data and data.id) or strmatch(link, ':(%w+)'))
		end

		if not TT.db.modifierCount or modKey then
			local count = GetItemCount(link)
			local itemCount = TT.db.itemCount
			if itemCount.bags then
				bagCount = format(IDLine, L["Bags"], count)
			end

			if itemCount.stack then
				local _, _, _, _, _, _, _, stack = GetItemInfo(link)
				if stack and stack > 1 then
					stackSize = format(IDLine, L["Stack Size"], stack)
				end
			end
		end
	elseif modKey then
		local id = data and data.id
		if id then
			itemID = format('|cFFCA3C3C%s|r %s', _G.ID, id)
		end
	end

	if itemID or bagCount or bankCount or stackSize then
		self:AddLine(' ')
		self:AddDoubleLine(itemID or ' ', bagCount or bankCount or stackSize or ' ')
	end

	if (bagCount and bankCount) then
		self:AddDoubleLine(' ', bankCount)
	end

	if (bagCount or bankCount) and stackSize then
		self:AddDoubleLine(' ', stackSize)
	end
end

function TT:GameTooltip_AddQuestRewardsToTooltip(tt, questID)
	if not (tt and questID and tt.progressBar) then return end

	local _, max = tt.progressBar:GetMinMaxValues()
	S:StatusBarColorGradient(tt.progressBar, tt.progressBar:GetValue(), max)
end

function TT:GameTooltip_ClearProgressBars(tt)
	tt.progressBar = nil
end

function TT:GameTooltip_ShowProgressBar(tt)
	if not tt or not tt.progressBarPool then return end

	local sb = tt.progressBarPool:GetNextActive()
	if not sb or not sb.Bar then return end

	tt.progressBar = sb.Bar

	if not sb.Bar.backdrop then
		sb.Bar:StripTextures()
		sb.Bar:CreateBackdrop('Transparent', nil, true)
		sb.Bar:SetStatusBarTexture(E.media.normTex)
	end
end

function TT:GameTooltip_ShowStatusBar(tt)
	if not tt then return end

	local sb = _G[tt:GetName()..'StatusBar'..tt.shownStatusBars]
	if not sb or sb.backdrop then return end

	sb:StripTextures()
	sb:CreateBackdrop(nil, nil, true, true)
	sb:SetStatusBarTexture(E.media.normTex)
end

function TT:SetStyle(tt)
	if not tt or (tt == E.ScanTooltip) then return end

	tt.customBackdropAlpha = TT.db.colorAlpha
	tt:SetTemplate('Transparent')

	local GetItem = tt.GetItem
	if GetItem then
		local _, link = GetItem(tt)
		if not link then return end

		if TT.db.itemQuality then
			local _, _, quality = GetItemInfo(link)
			if quality and quality > 1 then
				local r, g, b = E:GetItemQualityColor(quality)
				tt:SetBackdropBorderColor(r, g, b)

				tt.qualityChanged = true
			end
		end
	end
end

function TT:MODIFIER_STATE_CHANGED()
	if GameTooltip:IsShown() then
		local owner = GameTooltip:GetOwner()
		if owner == UIParent and UnitExists('mouseover') then
			GameTooltip:SetUnit('mouseover')
		end
	end
end

function TT:SetUnitAura(tt, ...)
	if not tt then return end

	local name, _, _, _, _, _, _, source, _, _, spellID = UnitAura(...)
	if not name then return end

	if TT:IsModKeyDown() then
		if source then
			local _, class = UnitClass(source)
			local color = E:ClassColor(class) or PRIEST_COLOR
			tt:AddDoubleLine(format(IDLine, _G.ID, spellID), format('|c%s%s|r', color.colorStr, UnitName(source) or UNKNOWN))
		else
			tt:AddLine(format(IDLine, _G.ID, spellID))
		end
	end

	tt:Show()
end

function TT:GameTooltip_OnTooltipSetSpell(data)
	if (self ~= GameTooltip and self ~= E.SpellBookTooltip) or not TT:IsModKeyDown() then return end

	local id = (data and data.id) or select(3, self:GetSpell())
	if not id then return end

	local ID = format(IDLine, _G.ID, id)
	for i = 3, self:NumLines() do
		local line = _G[format('GameTooltipTextLeft%d', i)]
		local text = line and line:GetText()
		if text and strfind(text, ID) then
			return -- this is called twice on talents for some reason?
		end
	end

	self:AddLine(ID)
	self:Show()
end

function TT:SetItemRef(link)
	if IsModifierKeyDown() or not (link and strfind(link, '^spell:')) then return end

	_G.ItemRefTooltip:AddLine(format(IDLine, _G.ID, strmatch(link, ':(%d+)')))
	_G.ItemRefTooltip:Show()
end

function TT:SetCurrencyToken(tt, index)
	if not TT:IsModKeyDown() then return end

	local itemID = index and select(9, GetCurrencyListInfo(index))
	local link = select(2, GetItemInfo(itemID))
	local id = link and tonumber(strmatch(link, 'currency:(%d+)'))
	if not id then return end

	tt:AddLine(' ')
	tt:AddLine(format(IDLine, _G.ID, id))
	tt:Show()
end

function TT:AddQuestID(frame)
	local questID = TT:IsModKeyDown() and frame.questID
	if not questID then return end

	GameTooltip:AddLine(format(IDLine, _G.ID, questID))

	if GameTooltip.ItemTooltip:IsShown() then
		GameTooltip:AddLine(' ')
	end

	GameTooltip:Show()
end

function TT:SetBackpackToken(tt, id)
	if id and TT:IsModKeyDown() then
		local info = GetBackpackCurrencyInfo(id)
		if info and info.currencyTypesID then
			tt:AddLine(format(IDLine, _G.ID, info.currencyTypesID))
			tt:Show()
		end
	end
end

function TT:SetTooltipFonts()
	local font, fontSize, fontOutline = LSM:Fetch('font', TT.db.font), TT.db.textFontSize, TT.db.fontOutline
	_G.GameTooltipText:FontTemplate(font, fontSize, fontOutline)

	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			_G['GameTooltipMoneyFrame'..i..'PrefixText']:FontTemplate(font, fontSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'SuffixText']:FontTemplate(font, fontSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'GoldButtonText']:FontTemplate(font, fontSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'SilverButtonText']:FontTemplate(font, fontSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'CopperButtonText']:FontTemplate(font, fontSize, fontOutline)
		end
	end

	-- Header has its own font settings
	_G.GameTooltipHeaderText:FontTemplate(LSM:Fetch('font', TT.db.headerFont), TT.db.headerFontSize, TT.db.headerFontOutline)

	-- Ignore header font size on DatatextTooltip
	if _G.DatatextTooltip then
		_G.DatatextTooltipTextLeft1:FontTemplate(font, fontSize, fontOutline)
		_G.DatatextTooltipTextRight1:FontTemplate(font, fontSize, fontOutline)
	end

	-- Comparison Tooltips has its own size setting
	local smallSize = TT.db.smallTextFontSize
	_G.GameTooltipTextSmall:FontTemplate(font, smallSize, fontOutline)

	for _, tt in ipairs(GameTooltip.shoppingTooltips) do
		for _, region in next, { tt:GetRegions() } do
			if region:IsObjectType('FontString') then
				region:FontTemplate(font, smallSize, fontOutline)
			end
		end
	end
end

function TT:GameTooltip_Hide()
	local statusBar = GameTooltip.StatusBar
	if statusBar and statusBar:IsShown() then
		statusBar:Hide()
	end
end

--This changes the growth direction of the toast frame depending on position of the mover
local function PostBNToastMove(mover)
	local x, y = mover:GetCenter()
	local screenHeight = E.UIParent:GetTop()
	local screenWidth = E.UIParent:GetRight()

	local anchorPoint
	if y > (screenHeight / 2) then
		anchorPoint = (x > (screenWidth / 2)) and 'TOPRIGHT' or 'TOPLEFT'
	else
		anchorPoint = (x > (screenWidth / 2)) and 'BOTTOMRIGHT' or 'BOTTOMLEFT'
	end
	mover.anchorPoint = anchorPoint

	_G.BNToastFrame:ClearAllPoints()
	_G.BNToastFrame:Point(anchorPoint, mover)
end

function TT:RepositionBNET(frame, _, anchor)
	if anchor ~= _G.BNETMover then
		frame:ClearAllPoints()
		frame:Point('TOPLEFT', _G.BNETMover, 'TOPLEFT')
	end
end

function TT:Initialize()
	TT.db = E.db.tooltip

	_G.FrameStackTooltip:SetScale(E.uiscale)

	_G.BNToastFrame:Point('TOPRIGHT', _G.MinimapCluster, 'BOTTOMRIGHT', 0, -10)
	E:CreateMover(_G.BNToastFrame, 'BNETMover', L["BNet Frame"], nil, nil, PostBNToastMove)
	TT:SecureHook(_G.BNToastFrame, 'SetPoint', 'RepositionBNET')

	if not E.private.tooltip.enable then return end
	TT.Initialized = true

	local statusBar = GameTooltipStatusBar
	statusBar:Height(TT.db.healthBar.height)
	statusBar:SetScript('OnValueChanged', nil) -- Do we need to unset this?
	statusBar:SetMinMaxValues(-0.00001, 1)
	GameTooltip.StatusBar = statusBar

	local statusText = statusBar:CreateFontString(nil, 'OVERLAY')
	statusText:FontTemplate(LSM:Fetch('font', TT.db.healthBar.font), TT.db.healthBar.fontSize, TT.db.healthBar.fontOutline)
	statusText:Point('CENTER', statusBar, 0, 0)
	statusBar.text = statusText

	--Tooltip Fonts
	if not GameTooltip.hasMoney then
		--Force creation of the money lines, so we can set font for it
		SetTooltipMoney(GameTooltip, 1, nil, '', '')
		SetTooltipMoney(GameTooltip, 1, nil, '', '')
		GameTooltip_ClearMoney(GameTooltip)
	end
	TT:SetTooltipFonts()

	local GameTooltipAnchor = CreateFrame('Frame', 'GameTooltipAnchor', E.UIParent)
	GameTooltipAnchor:Point('BOTTOMRIGHT', _G.RightChatToggleButton, 'BOTTOMRIGHT')
	GameTooltipAnchor:Size(130, 20)
	GameTooltipAnchor:OffsetFrameLevel(400)
	E:CreateMover(GameTooltipAnchor, 'TooltipMover', L["Tooltip"], nil, nil, nil, nil, nil, 'tooltip,general')

	TT:RegisterEvent('MODIFIER_STATE_CHANGED')

	TT:SecureHook('SetItemRef')
	TT:SecureHook('GameTooltip_SetDefaultAnchor')
	TT:SecureHook(GameTooltip, 'SetUnitAura')
	TT:SecureHook(GameTooltip, 'SetUnitBuff', 'SetUnitAura')
	TT:SecureHook(GameTooltip, 'SetUnitDebuff', 'SetUnitAura')
	TT:SecureHookScript(GameTooltip, 'OnTooltipCleared', 'GameTooltip_OnTooltipCleared')
	TT:SecureHookScript(GameTooltip.StatusBar, 'OnValueChanged', 'GameTooltipStatusBar_OnValueChanged')

	TT:SecureHook(GameTooltip, 'Hide', 'GameTooltip_Hide') -- dont use OnHide use Hide directly

	TT:SecureHookScript(GameTooltip, 'OnTooltipSetSpell', TT.GameTooltip_OnTooltipSetSpell)
	TT:SecureHookScript(GameTooltip, 'OnTooltipSetItem', TT.GameTooltip_OnTooltipSetItem)
	TT:SecureHookScript(ShoppingTooltip1, 'OnTooltipSetItem', TT.GameTooltip_OnTooltipSetItem)
	TT:SecureHookScript(ShoppingTooltip2, 'OnTooltipSetItem', TT.GameTooltip_OnTooltipSetItem)
	TT:SecureHookScript(ShoppingTooltip3, 'OnTooltipSetItem', TT.GameTooltip_OnTooltipSetItem)
	TT:SecureHookScript(GameTooltip, 'OnTooltipSetUnit', TT.GameTooltip_OnTooltipSetUnit)
	TT:SecureHookScript(E.SpellBookTooltip, 'OnTooltipSetSpell', TT.GameTooltip_OnTooltipSetSpell)

	TT:SecureHook(GameTooltip, 'SetCurrencyToken')
	TT:SecureHook(GameTooltip, 'SetBackpackToken')
end

E:RegisterModule(TT:GetName())