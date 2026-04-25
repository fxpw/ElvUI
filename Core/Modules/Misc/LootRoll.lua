local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule("Bags")
local M = E:GetModule("Misc")
local LSM = E.Libs.LSM

local _G = _G
local unpack, next, pairs, ipairs = unpack, next, pairs, ipairs
local find, format = string.find, string.format
local tinsert, tremove, wipe = table.insert, table.remove, table.wipe

local CreateFrame = CreateFrame
local GetLocale = GetLocale
local GameTooltip = GameTooltip
local GetItemInfo = GetItemInfo
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local RollOnLoot = RollOnLoot
local UIParent = UIParent
local UnitClass = UnitClass

local GameTooltip_Hide = GameTooltip_Hide
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GREED, NEED, PASS = GREED, NEED, PASS
local ROLL_DISENCHANT = ROLL_DISENCHANT
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

M.RollBars = {}

local locale = GetLocale()
local rollMessages = locale == "deDE" and {
	["(.*) passt automatisch bei (.+), weil [ersi]+ den Gegenstand nicht benutzen kann.$"] = 0,
	["(.*) würfelt nicht für: (.+|r)$"] = 0,
	["(.*) hat für (.+) 'Bedarf' ausgewählt"] = 1,
	["(.*) hat für (.+) 'Gier' ausgewählt"] = 2,
	["(.*) hat für '(.+)' Entzauberung gewählt."] = 3,
} or locale == "frFR" and {
	["(.*) a passé pour : (.+) parce qu'((il)|(elle)) ne peut pas ramasser cette objet.$"] = 0,
	["(.*) a passé pour : (.+)"] = 0,
	["(.*) a choisi Besoin pour : (.+)"] = 1,
	["(.*) a choisi Cupidité pour : (.+)"] = 2,
	["(.*) a choisi Désenchantement pour : (.+)"] = 3,
} or locale == "zhCN" and {
	["(.*)自动放弃了：(.+)，因为他无法拾取该物品$"] = 0,
	["(.*)自动放弃了：(.+)，因为她无法拾取该物品$"] = 0,
	["(.*)放弃了：(.+)"] = 0,
	["(.*)选择了需求取向：(.+)"] = 1,
	["(.*)选择了贪婪取向：(.+)"] = 2,
	["(.*)选择了分解取向：(.+)"] = 3,
} or locale == "zhTW" and {
	["(.*)自動放棄:(.+)，因為他無法拾取該物品$"] = 0,
	["(.*)自動放棄:(.+)，因為她無法拾取該物品$"] = 0,
	["(.*)放棄了:(.+)"] = 0,
	["(.*)選擇了需求:(.+)"] = 1,
	["(.*)選擇了貪婪:(.+)"] = 2,
	["(.*)選擇了分解:(.+)"] = 3,
} or locale == "ruRU" and {
	["(.*) автоматически передает предмет (.+), поскольку не может его забрать"] = 0,
	["(.*) пропускает розыгрыш предмета \"(.+)\", поскольку не может его забрать"] = 0,
	["(.*) отказывается от предмета (.+)%."] = 0,
	["Разыгрывается: (.+)%. (.*): \"Мне это нужно\""] = 1,
	["Разыгрывается: (.+)%. (.*): \"Не откажусь\""] = 2,
	["Разыгрывается: (.+)%. (.*): \"Распылить\""] = 3,
} or locale == "koKR" and {
	["(.*)님이 획득할 수 없는 아이템이어서 자동으로 주사위 굴리기를 포기했습니다: (.+)"] = 0,
	["(.*)님이 주사위 굴리기를 포기했습니다: (.+)"] = 0,
	["(.*)님이 입찰을 선택했습니다: (.+)"] = 1,
	["(.*)님이 차비를 선택했습니다: (.+)"] = 2,
	["(.*)님이 마력 추출을 선택했습니다: (.+)"] = 3,
} or locale == "esES" and {
	["^(.*) pasó automáticamente de: (.+) porque no puede despojar este objeto.$"] = 0,
	["^(.*) pasó de: (.+|r)$"] = 0,
	["(.*) eligió Necesidad para: (.+)"] = 1,
	["(.*) eligió Codicia para: (.+)"] = 2,
	["(.*) eligió Desencantar para: (.+)"] = 3,
} or locale == "esMX" and {
	["^(.*) pasó automáticamente de: (.+) porque no puede despojar este objeto.$"] = 0,
	["^(.*) pasó de: (.+|r)$"] = 0,
	["(.*) eligió Necesidad para: (.+)"] = 1,
	["(.*) eligió Codicia para: (.+)"] = 2,
	["(.*) eligió Desencantar para: (.+)"] = 3,
} or {
	["^(.*) automatically passed on: (.+) because s?he cannot loot that item.$"] = 0,
	["^(.*) passed on: (.+|r)$"] = 0,
	["(.*) has selected Need for: (.+)"] = 1,
	["(.*) has selected Greed for: (.+)"] = 2,
	["(.*) has selected Disenchant for: (.+)"] = 3
}

local waitingRolls = {}
local rollTypes = {
	[0] = 'pass',
	[1] = 'need',
	[2] = 'greed',
	[3] = 'disenchant'
}

local function ClickRoll(button)
	RollOnLoot(button.parent.rollID, button.rolltype)
end

local function SetTip(button)
	GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
	GameTooltip:AddLine(button.tiptext)

	local lineAdded
	if button:IsEnabled() == 0 then
		GameTooltip:AddLine('|cffff3333'..L["Can't Roll"])
	end

	local rolls = button.parent.rolls[button.rolltype]
	if rolls then
		for _, infoTable in next, rolls do
			local playerName, className = unpack(infoTable)
			if not lineAdded then
				GameTooltip:AddLine(" ")
				lineAdded = true
			end

			local classColor = E:ClassColor(className) or PRIEST_COLOR
			GameTooltip:AddLine(playerName, classColor.r, classColor.g, classColor.b)
		end
	end

	GameTooltip:Show()
end

local function SetItemTip(button, event)
	if not button.rollID or (event == 'MODIFIER_STATE_CHANGED' and not button:IsMouseOver()) then return end

	GameTooltip:SetOwner(button, 'ANCHOR_TOPLEFT')
	GameTooltip:SetLootRollItem(button.rollID)

	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
end

local function LootClick(button)
	if IsModifiedClick() then
		_G.HandleModifiedItemClick(button.link)
	end
end

local function StatusUpdate(status, elapsed)
	local bar = status.parent
	local rollID = bar.rollID
	if not rollID then
		bar:Hide()
		return
	end

	if status.elapsed and status.elapsed > 0.1 then
		local timeLeft = GetLootRollTimeLeft(rollID)
		if timeLeft <= 0 then -- workaround for other addons auto-passing loot
			M.CANCEL_LOOT_ROLL(bar, 'OnUpdate', rollID)
		else
			status.spark:Point('CENTER', status, 'LEFT', (timeLeft / bar.time) * status:GetWidth(), 0)
			status:SetValue(timeLeft)
			status.elapsed = 0
		end
	else
		status.elapsed = (status.elapsed or 0) + elapsed
	end
end

local iconCoords = {
	[0] = {1.05, -0.1, 1.05, -0.1}, -- pass
	[2] = {0.05, 1.05, -0.025, 0.85}, -- greed
	[1] = {0.05, 1.05, -0.05, .95}, -- need
	[3] = {0.05, 1.05, -0.05, .95}, -- disenchant
}

local function RollTexCoords(button, icon, rolltype, minX, maxX, minY, maxY)
	local offset = icon == button.pushedTex and (rolltype == 0 and -0.05 or 0.05) or 0
	icon:SetTexCoord(minX - offset, maxX, minY - offset, maxY)

	if icon == button.disabledTex then
		icon:SetDesaturated(true)
		icon:SetAlpha(0.25)
	end
end

local function RollButtonTextures(button, texture, rolltype)
	button:SetNormalTexture(texture)
	button:SetPushedTexture(texture)
	button:SetDisabledTexture(texture)
	button:SetHighlightTexture(texture)

	button.normalTex = button:GetNormalTexture()
	button.disabledTex = button:GetDisabledTexture()
	button.pushedTex = button:GetPushedTexture()
	button.highlightTex = button:GetHighlightTexture()

	local minX, maxX, minY, maxY = unpack(iconCoords[rolltype])
	RollTexCoords(button, button.normalTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(button, button.disabledTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(button, button.pushedTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(button, button.highlightTex, rolltype, minX, maxX, minY, maxY)
end

local function RollMouseDown(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(0)
	end
end

local function RollMouseUp(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(1)
	end
end

local function increaseRollCount(self, count)
	local text = self.text:GetText()
	if not text or text == '' then
		self.text:SetText(count or 1)
	else
		self.text:SetText(self.text:GetText() + (count or 1))
	end
end

local function CreateRollButton(parent, texture, rolltype, tiptext)
	local button = CreateFrame('Button', format('$parent_%sButton', tiptext), parent)
	button:SetScript('OnMouseDown', RollMouseDown)
	button:SetScript('OnMouseUp', RollMouseUp)
	button:SetScript('OnClick', ClickRoll)
	button:SetScript('OnEnter', SetTip)
	button:SetScript('OnLeave', GameTooltip_Hide)
	button:SetMotionScriptsWhileDisabled(true)
	button:SetHitRectInsets(3, 3, 3, 3)

	RollButtonTextures(button, texture, rolltype)

	button.IncreaseRollCount = increaseRollCount

	button.parent = parent
	button.rolltype = rolltype
	button.tiptext = tiptext

	button.text = button:CreateFontString(nil, 'ARTWORK')
	button.text:FontTemplate(nil, nil, 'OUTLINE')
	button.text:SetPoint('BOTTOMRIGHT', 2, -2)

	return button
end

function M:LootRoll_Create(index)
	local bar = CreateFrame('Frame', 'ElvUI_LootRollFrame'..index, E.UIParent)
	bar:SetScript('OnEvent', M.LootRoll_OnEvent)
	bar:RegisterEvent('CANCEL_LOOT_ROLL')
	bar:Hide()

	local status = CreateFrame('StatusBar', nil, bar)
	status:OffsetFrameLevel(nil, bar)
	status:SetFrameStrata(bar:GetFrameStrata())
	status:CreateBackdrop('Default')
	status:SetScript('OnUpdate', StatusUpdate)
	status:SetStatusBarTexture(E.db.general.lootRoll.statusBarTexture)
	status.parent = bar
	bar.status = status

	local spark = status:CreateTexture(nil, 'ARTWORK', nil, 1)
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	spark:SetBlendMode('ADD')
	spark:Width(2)
	status.spark = spark

	local button = CreateFrame('Button', nil, bar)
	button:CreateBackdrop()
	button:SetScript('OnEvent', SetItemTip)
	button:SetScript('OnEnter', SetItemTip)
	button:SetScript('OnLeave', GameTooltip_Hide)
	button:SetScript('OnClick', LootClick)
	button:RegisterEvent('MODIFIER_STATE_CHANGED')
	bar.button = button

	button.icon = button:CreateTexture(nil, 'OVERLAY')
	button.icon:SetAllPoints()
	button.icon:SetTexCoords()

	button.stack = button:CreateFontString(nil, 'OVERLAY')
	button.stack:SetPoint('BOTTOMRIGHT', -1, 1)
	button.stack:FontTemplate(nil, nil, 'OUTLINE')

	button.ilvl = button:CreateFontString(nil, 'OVERLAY')
	button.ilvl:SetPoint('BOTTOM', button, 'BOTTOM', 0, 0)
	button.ilvl:FontTemplate(nil, nil, 'OUTLINE')

	button.questIcon = button:CreateTexture(nil, 'OVERLAY')
	button.questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
	button.questIcon:SetTexCoord(1, 0, 0, 1)
	button.questIcon:Hide()

	bar.pass = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Pass-Up]], 0, PASS)
	bar.need = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Dice-Up]], 1, NEED)
	bar.greed = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Coin-Up]], 2, GREED)
	bar.disenchant = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-DE-Up]], 3, ROLL_DISENCHANT) or nil

	local name = bar:CreateFontString(nil, 'OVERLAY')
	name:FontTemplate(nil, nil, 'OUTLINE')
	name:SetJustifyH('LEFT')
	name:SetWordWrap(false)
	bar.name = name

	local bind = bar:CreateFontString(nil, 'OVERLAY')
	bind:FontTemplate(nil, nil, 'OUTLINE')
	bar.bind = bind

	bar.rolls = {}
	bar.rollButtons = {
		[0] = bar.pass,
		[1] = bar.need,
		[2] = bar.greed,
		[3] = bar.disenchant,
	}

	tinsert(M.RollBars, bar)

	return bar
end

function M:LootRoll_GetFrame(i)
	if i then
		return M.RollBars[i] or M:LootRoll_Create(i)
	else -- check for a bar to reuse
		for _, bar in next, M.RollBars do
			if not bar.rollID then
				return bar
			end
		end
	end
end

function M:LootRoll_OnEvent(event, rollID)
	M[event](self, event, rollID)
end

function M:LootRoll_ClearBar(bar, event)
	bar.rollID = nil
	bar.time = nil

	if next(waitingRolls) then
		local newRoll = waitingRolls[1]
		tremove(waitingRolls, 1)

		M:START_LOOT_ROLL(event, newRoll.rollID, newRoll.rollTime)
	end
end

function M:CANCEL_LOOT_ROLL(event, rollID)
	if self.rollID == rollID then
		M:LootRoll_ClearBar(self, event)
	end
end

function M:START_LOOT_ROLL(event, rollID, rollTime)
	local texture, name, count, quality, _, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)
	if not name then -- also done in GroupLootFrame_OnShow
		for _, rollBar in next, M.RollBars do
			if rollBar.rollID == rollID then
				M.CANCEL_LOOT_ROLL(rollBar, event, rollID)
			end
		end

		return
	end

	local bar = M:LootRoll_GetFrame()
	if not bar then
		return -- well this shouldn't happen
	end

	local itemLink = GetLootRollItemLink(rollID)
	local _, _, _, itemLevel, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(itemLink)
	local bindType = B:GetBindTypeText(itemLink)

	local db = E.db.general.lootRoll
	local r, g, b = E:GetItemQualityColor(quality)

	wipe(bar.rolls)

	bar.rollID = rollID
	bar.time = rollTime

	bar.button.link = itemLink
	bar.button.rollID = rollID
	bar.button.icon:SetTexture(texture)
	bar.button.stack:SetShown(count > 1)
	bar.button.stack:SetText(count)
	bar.button.ilvl:SetShown(B:IsItemEligibleForItemLevelDisplay(itemType, itemSubType, itemEquipLoc, quality))
	bar.button.ilvl:SetText(itemLevel)
	bar.button.questIcon:SetShown(B:GetItemQuestInfo(itemLink, itemType, itemSubType))

	bar.need.text:SetText('')
	bar.greed.text:SetText('')
	bar.pass.text:SetText('')
	bar.need:SetEnabled(canNeed)
	bar.greed:SetEnabled(canGreed)

	if bar.disenchant then
		bar.disenchant.text:SetText('')
		bar.disenchant:SetEnabled(canDisenchant)
	end

	bar.name:SetText(name)

	if db.qualityName then
		bar.name:SetTextColor(r, g, b)
	else
		bar.name:SetTextColor(1, 1, 1)
	end

	if db.qualityItemLevel then
		bar.button.ilvl:SetTextColor(r, g, b)
	else
		bar.button.ilvl:SetTextColor(1, 1, 1)
	end

	local bop = bindType == L["BoP"]
	bar.bind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)
	bar.bind:SetText(B.BindText[bindType] or '')

	if db.qualityStatusBar then
		bar.status:SetStatusBarColor(r, g, b, .7)
		bar.status.spark:SetVertexColor(r, g, b, .9)
	else
		local c = db.statusBarColor
		bar.status:SetStatusBarColor(c.r, c.g, c.b, .7)
		bar.status.spark:SetVertexColor(c.r, c.g, c.b, .9)
	end

	if db.qualityStatusBarBackdrop then
		bar.status.backdrop:SetBackdropColor(r, g, b, .1)
	else
		local br, bg, bb = unpack(E.media.backdropfadecolor)
		bar.status.backdrop:SetBackdropColor(br, bg, bb, .1)
	end

	bar.status.elapsed = 1
	bar.status:SetMinMaxValues(0, rollTime)
	bar.status:SetValue(rollTime)

	bar:Show()

	_G.AlertFrame_FixAnchors()
end

function M:ParseRollChoice(msg)
	for regex, rollType in pairs(rollMessages) do
		local _, _, playerName, itemName = find(msg, regex)

		if playerName and itemName and playerName ~= 'Everyone' then
			if locale == 'ruRU' and rollType ~= 0 then
				playerName, itemName = itemName, playerName
			end

			return playerName, itemName, rollType
		end
	end
end

function M:CHAT_MSG_LOOT(_, msg)
	local playerName, itemName, rollType = self:ParseRollChoice(msg)

	if playerName and itemName then
		local _, class = UnitClass(playerName)

		for _, bar in ipairs(self.RollBars) do
			if bar.rollID and bar.button.link == itemName and not bar.rolls[playerName] then
				bar.rolls[playerName] = {rollType, class}
				bar.rollButtons[rollType]:IncreaseRollCount()
				break
			end
		end
	end
end

function M:UpdateLootRollAnchors(POSITION)
	local spacing, lastFrame, lastShown = E.db.general.lootRoll.spacing + E.Spacing
	for i, bar in next, M.RollBars do
		bar:ClearAllPoints()

		local anchor = i ~= 1 and lastFrame or _G.AlertFrameHolder
		if POSITION == 'TOP' then
			bar:Point('TOP', anchor, 'BOTTOM', 0, -spacing)
		else
			bar:Point('BOTTOM', anchor, 'TOP', 0, spacing)
		end

		lastFrame = bar

		if bar:IsShown() then
			lastShown = bar
		end
	end

	return lastShown
end

function M:UpdateLootRollFrames()
	if not E.private.general.lootRoll then return end
	local db = E.db.general.lootRoll

	local font = LSM:Fetch('font', db.nameFont)
	local texture = LSM:Fetch('statusbar', db.statusBarTexture)
	local maxBars = _G.NUM_GROUP_LOOT_FRAMES or 4

	for i = 1, maxBars do
		local bar = M:LootRoll_GetFrame(i)
		bar:Size(db.width, db.height)

		bar.status:SetStatusBarTexture(texture)

		bar.button:ClearAllPoints()
		bar.button:Point('RIGHT', bar, 'LEFT', E.PixelMode and -1 or -2, 0)
		bar.button:Size(db.height)

		bar.button.questIcon:ClearAllPoints()
		bar.button.questIcon:Point('RIGHT', bar.button, 'LEFT', -3, 0)
		bar.button.questIcon:Size(db.height)

		bar.name:FontTemplate(font, db.nameFontSize, db.nameFontOutline)
		bar.bind:FontTemplate(font, db.nameFontSize, db.nameFontOutline)

		for _, button in next, rollTypes do
			local icon = bar[button]
			if icon then
				icon:Size(db.buttonSize)
				icon:ClearAllPoints()
			end
		end

		bar.status:ClearAllPoints()
		bar.name:ClearAllPoints()
		bar.bind:ClearAllPoints()

		local full = db.style == 'fullbar'
		if full then
			bar.status:SetAllPoints()
			bar.status:Size(db.width, db.height)
		else
			bar.status:Point('BOTTOM', 3, 0)
			bar.status:Size(db.width, db.height / 3)
		end

		local anchor = full and bar or bar.status
		if db.leftButtons then
			bar.need:Point(full and 'LEFT' or 'BOTTOMLEFT', anchor, full and 'LEFT' or 'TOPLEFT', 3, 0)
			if bar.disenchant then bar.disenchant:Point('LEFT', bar.need, 'RIGHT', 3, 0) end
			bar.greed:Point('LEFT', bar.disenchant or bar.need, 'RIGHT', 3, 0)
			bar.pass:Point('LEFT', bar.greed, 'RIGHT', 3, 0)

			bar.name:Point(full and 'RIGHT' or 'BOTTOMRIGHT', anchor, full and 'RIGHT' or 'TOPRIGHT', full and -3 or -1, full and 0 or 3)
			bar.name:Point('LEFT', bar.bind, 'RIGHT', 1, 0)
			bar.bind:Point('LEFT', bar.pass, 'RIGHT', 1, 0)
		else
			bar.pass:Point(full and 'RIGHT' or 'BOTTOMRIGHT', anchor, full and 'RIGHT' or 'TOPRIGHT', -3, 0)
			if bar.disenchant then bar.disenchant:Point('RIGHT', bar.pass, 'LEFT', -3, 0) end
			bar.greed:Point('RIGHT', bar.disenchant or bar.pass, 'LEFT', -3, 0)
			bar.need:Point('RIGHT', bar.greed, 'LEFT', -3, 0)

			bar.name:Point(full and 'LEFT' or 'BOTTOMLEFT', anchor, full and 'LEFT' or 'TOPLEFT', full and 3 or 1, full and 0 or 3)
			bar.name:Point('RIGHT', bar.bind, 'LEFT', -1, 0)
			bar.bind:Point('RIGHT', bar.need, 'LEFT', -1, 0)
		end
	end
end

function M:LoadLootRoll()
	if not E.private.general.lootRoll then return end

	M:UpdateLootRollFrames()

	M:RegisterEvent('CHAT_MSG_LOOT')
	M:RegisterEvent('START_LOOT_ROLL')
	M:RegisterEvent('CANCEL_LOOT_ROLL')

	UIParent:UnregisterEvent('START_LOOT_ROLL')
	UIParent:UnregisterEvent('CANCEL_LOOT_ROLL')

	for i = 1, _G.NUM_GROUP_LOOT_FRAMES do
		_G['GroupLootFrame'..i]:UnregisterEvent('CANCEL_LOOT_ROLL')
	end
end