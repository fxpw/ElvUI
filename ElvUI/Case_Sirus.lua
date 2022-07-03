local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local mod = E:GetModule("SirusCase", "AceEvent-3.0")

local CASE_LIST = {}
local ACTIVE_CASES = {}
---------------
--------------
local BUTTON_WIDTH, BUTTON_HEIGHT = 64, 64
local SMALL_BUTTON_WIDTH, SMALL_BUTTON_HEIGHT = 56, 56
local BUTTON_SPACING = 3

local MAX_BUTTONS = 25
local CHILD_WIDTH = (BUTTON_WIDTH * MAX_BUTTONS) + (BUTTON_SPACING * (MAX_BUTTONS - 1))
local SMAIL_CHILD_WIDTH = (SMALL_BUTTON_WIDTH * MAX_BUTTONS) + (BUTTON_SPACING * (MAX_BUTTONS - 1))

local START_POINT = BUTTON_WIDTH + BUTTON_SPACING + (BUTTON_WIDTH / 2)
local LEFT_START_POINT = 0
local RIGHT_START_POINT = ((SMALL_BUTTON_WIDTH + BUTTON_SPACING) * 3) + (BUTTON_WIDTH / 2) - BUTTON_SPACING

local END_POINT = CHILD_WIDTH - START_POINT - ((BUTTON_WIDTH + BUTTON_SPACING) * 5) + BUTTON_SPACING
local LEFT_END_POINT = SMAIL_CHILD_WIDTH - LEFT_START_POINT - ((SMALL_BUTTON_WIDTH + BUTTON_SPACING) * 6) - (SMALL_BUTTON_WIDTH / 2)
local RIGHT_END_POINT = SMAIL_CHILD_WIDTH - RIGHT_START_POINT - ((SMALL_BUTTON_WIDTH + BUTTON_SPACING) * 3) + BUTTON_SPACING

local faction = UnitFactionGroup("player")
local honorIcon = "PVPCurrency-Honor-"..faction
local arenaIcon = "PVPCurrency-Conquest-"..faction

local ITEMS_TABLE = {
	{icon = honorIcon, name = "Очки чести", count = 100, quality = 3},
	{icon = arenaIcon, name = "Очки арены", count = 25, quality = 3},
	{icon = "pvecurrency-valor", name = "Очки доблести", count = 50, quality = 4},
	{icon = "INV_MISC_TRINKETPANDA_08", name = "Жетон запределья", count = 3, quality = 3},
	{icon = "Spell_Frost_FrozenCore", name = "Ледяной шар", count = 1, quality = 3},
	{icon = "spell_monk_diffusemagic", name = "Руна Лили", count = 1, quality = 4},

	{icon = honorIcon, name = "Очки чести", count = 500, quality = 3},
	{icon = arenaIcon, name = "Очки арены", count = 125, quality = 3},
	{icon = "pvecurrency-valor", name = "Очки доблести", count = 250, quality = 4},
	{icon = "INV_MISC_TRINKETPANDA_08", name = "Жетон запределья", count = 9, quality = 3},
	{icon = "INV_Elemental_Primal_Nether", name = "Изначальная пустота", count = 1, quality = 3},
	{icon = "ability_monk_touchofdeath", name = "Руна Сируса", count = 1, quality = 4},
	{icon = "INV_LEGENDARY_CHIMERAOFFEAR", name = "Черный бриллиант", count = 1, quality = 5},
}

local ITEMS_MSG = {
	["Поздравляем! Вы выиграли 100 очков чести!"] = 1,
	["Поздравляем! Вы выиграли 25 очков арены!"] = 2,
	["Поздравляем! Вы выиграли Очки доблести x50!"] = 3,
	["Поздравляем! Вы выиграли Жетон воина Запределья x3!"] = 4,
	["Поздравляем! Вы выиграли Ледяной шар x1!"] = 5,
	["Поздравляем! Вы выиграли Руна Лили x1!"] = 6,

	["|cFFC80046Д|r|cFFC80025Ж|r|cFFC80001Е|r|cFFC82100К|r|cFFC84000П|r|cFFC85C00О|r|cFFC87700Т|r|cFFC79400!|r Вы выиграли 500 очков чести!"] = 7,
	["|cFFC80046Д|r|cFFC80025Ж|r|cFFC80001Е|r|cFFC82100К|r|cFFC84000П|r|cFFC85C00О|r|cFFC87700Т|r|cFFC79400!|r Вы выиграли 125 очков арены!"] = 8,
	["|cFFC80046Д|r|cFFC80025Ж|r|cFFC80001Е|r|cFFC82100К|r|cFFC84000П|r|cFFC85C00О|r|cFFC87700Т|r|cFFC79400!|r Вы выиграли Очки доблести x250!"] = 9,
	["|cFFC80046Д|r|cFFC80025Ж|r|cFFC80001Е|r|cFFC82100К|r|cFFC84000П|r|cFFC85C00О|r|cFFC87700Т|r|cFFC79400!|r Вы выиграли Жетон воина Запределья x9!"] = 10,
	["|cFFC80046Д|r|cFFC80025Ж|r|cFFC80001Е|r|cFFC82100К|r|cFFC84000П|r|cFFC85C00О|r|cFFC87700Т|r|cFFC79400!|r Вы выиграли Изначальная Пустота x1!"] = 11,
	["|cFFC80046Д|r|cFFC80025Ж|r|cFFC80001Е|r|cFFC82100К|r|cFFC84000П|r|cFFC85C00О|r|cFFC87700Т|r|cFFC79400!|r Вы выиграли Руна Сируса x1!"] = 12,
	["|cFFC80046Д|r|cFFC80025Ж|r|cFFC80001Е|r|cFFC82100К|r|cFFC84000П|r|cFFC85C00О|r|cFFC87700Т|r|cFFC79400!|r Вы выиграли Черный бриллиант x1!"] = 13,
}

local randonTable = {}

local function SetPrize(self, prizeID)
	self.Prize = prizeID
end

local function Reset(self)
	self:SetHorizontalScroll(START_POINT)
	self:UpdateScrollChildRect()

	self.LeftScroll:SetHorizontalScroll(LEFT_START_POINT)
	self.LeftScroll:UpdateScrollChildRect()

	self.RightScroll:SetHorizontalScroll(RIGHT_START_POINT)
	self.RightScroll:UpdateScrollChildRect()
--
	for i = 1, 7 do
		table.insert(randonTable, i + 6)
	end

	for i = 1, MAX_BUTTONS do
		if i == (MAX_BUTTONS - 3) then
			self.Child[i]:AddItem(self.Prize) -- LOL
			self.LeftScroll.Child[i]:AddItem(self.Prize) -- LOL
			self.RightScroll.Child[i]:AddItem(self.Prize) -- LOL
		elseif i >= (MAX_BUTTONS - 7) then
			local rnd = math.random(1, #randonTable)
			self.Child[i]:AddItem(randonTable[rnd]) -- Added the top items :D
			self.LeftScroll.Child[i]:AddItem(randonTable[rnd]) -- Added the top items :D
			self.RightScroll.Child[i]:AddItem(randonTable[rnd]) -- Added the top items :D
			table.remove(randonTable, rnd)
		else
			local rnd = math.random(1, #ITEMS_TABLE)
			self.Child[i]:AddItem(rnd)
			self.LeftScroll.Child[i]:AddItem(rnd)
			self.RightScroll.Child[i]:AddItem(rnd)
		end

		self.Child[i]:Show()
		self.LeftScroll.Child[i]:Show()
		self.RightScroll.Child[i]:Show()
	end
end

local function AddItem(self, id)
	local item = ITEMS_TABLE[id]
	self.Icon:SetTexture("Interface\\Icons\\"..item.icon)
	self.Count:SetText(item.count)
	self:SetBackdropBorderColor(GetItemQualityColor(item.quality))
end

local function AddMessage(self, id)
	if self.Message then
		DEFAULT_CHAT_FRAME:AddMessage(self.Message, 1, 1, 0, 1)
		self.Message = nil
	end
end

local function CreateButton(i, parent, isSmail)
	local button = CreateFrame("Frame", nil, parent)
	button:Hide()
	button:Size(isSmail and SMALL_BUTTON_WIDTH or BUTTON_WIDTH, isSmail and SMALL_BUTTON_HEIGHT or BUTTON_HEIGHT)
	button:SetID(i)

	button.AddItem = AddItem

	button:SetTemplate()

	if i == 1 then
		button:Point("TOPLEFT", 0, 0)
	else
		button:Point("LEFT", parent[i - 1], "RIGHT", BUTTON_SPACING, 0)
	end

	button.Icon = button:CreateTexture()
	button.Icon:SetTexCoord(unpack(E.TexCoords))
	button.Icon:SetInside()

	button.Count = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.Count:SetPoint("BOTTOMRIGHT", -5, 3)
	button.Count:SetTextColor(1, 1, 1)

	parent[i] = button
end

local function FadeClosure(frame)
	if frame.fadeInfo.mode == "OUT" then
		frame:Hide()

		for i, case in ipairs(ACTIVE_CASES) do
			if case == frame then
				table.remove(ACTIVE_CASES, i)
				break
			end
		end

		table.insert(CASE_LIST, frame)
		mod:UpdatePosition()
	end
end

local function UIFrameFadeOut(frame)
	if frame.IsPlaying then return end

	E:UIFrameFadeOut(frame, 1.5, 1, 0)
end

local function InOutQuintic(t, b, c, d)
	t = t / d * 2

	if (t < 1) then
		return c / 2 * t ^ 5 + b
	else
		t = t - 2

		return c / 2 * (t ^ 5 + 2) + b
	end
end

local function OnUpdate(self, elapsed)
	self.Time = self.Time + elapsed
	if self.Time >= self.Duration then
		self:SetScript("OnUpdate", nil)
		self:SetHorizontalScroll(self.EndScroll)
		self.LeftScroll:SetHorizontalScroll(self.LeftEndScroll)
		self.RightScroll:SetHorizontalScroll(self.RightEndScroll)
		self.IsPlaying = nil
		self:AddMessage()
		E:Delay(1.5, UIFrameFadeOut, self)
	end

	self:SetHorizontalScroll(InOutQuintic(self.Time, START_POINT, self.EndScroll, self.Duration))
	self.LeftScroll:SetHorizontalScroll(InOutQuintic(self.Time, LEFT_START_POINT, self.LeftEndScroll, self.Duration))
	self.RightScroll:SetHorizontalScroll(InOutQuintic(self.Time, RIGHT_START_POINT, self.RightEndScroll, self.Duration))
end

function mod:CreateCase()
	local frame = CreateFrame("ScrollFrame", nil, UIParent)
	frame:Size(BUTTON_WIDTH * 2 + BUTTON_SPACING, BUTTON_HEIGHT)
	frame:SetPoint("TOP", 0, -200)
	frame:SetAlpha(0)
	frame:Hide()

	frame.Text = frame:CreateFontString()
	frame.Text:SetPoint("TOP", 0, 22)
	frame.Text:FontTemplate(nil, 22)

	frame.Line = CreateFrame("Frame", nil, frame)
	frame.Line:Size(3, BUTTON_HEIGHT + (8 * 2))
	frame.Line:SetPoint("CENTER")
	frame.Line:SetFrameLevel(frame:GetFrameLevel() + 10)
	frame.Line.Texture = frame.Line:CreateTexture()
	frame.Line.Texture:SetTexture(0.8, 0, 0)
	frame.Line.Texture:SetAllPoints()

	frame.Reset = Reset
	frame.SetPrize = SetPrize
	frame.AddMessage = AddMessage

	frame.Child = CreateFrame("Frame", nil, frame)
	frame.Child:SetPoint("TOPLEFT")
	frame.Child:Size(CHILD_WIDTH, BUTTON_HEIGHT)

	for i = 1, MAX_BUTTONS do
		CreateButton(i, frame.Child)
	end

	frame:SetScrollChild(frame.Child)

	local t = SMALL_BUTTON_WIDTH + (SMALL_BUTTON_WIDTH * 0.5) + BUTTON_SPACING
	frame.LeftScroll = CreateFrame("ScrollFrame", nil, frame)
	frame.LeftScroll:Size(t, SMALL_BUTTON_HEIGHT)
	frame.LeftScroll:Point("RIGHT", frame, "LEFT", -BUTTON_SPACING, 0)

	frame.LeftScroll.Child = CreateFrame("Frame", nil, frame.LeftScroll)
	frame.LeftScroll.Child:SetPoint("TOPLEFT")
	frame.LeftScroll.Child:Size(SMAIL_CHILD_WIDTH, SMALL_BUTTON_HEIGHT)

	for i = 1, MAX_BUTTONS do
		CreateButton(i, frame.LeftScroll.Child, true)
	end

	frame.LeftScroll:SetScrollChild(frame.LeftScroll.Child)

	frame.RightScroll = CreateFrame("ScrollFrame", nil, frame)
	frame.RightScroll:Size(t, SMALL_BUTTON_HEIGHT)
	frame.RightScroll:Point("LEFT", frame, "RIGHT", BUTTON_SPACING, 0)

	frame.RightScroll.Child = CreateFrame("Frame", nil, frame.RightScroll)
	frame.RightScroll.Child:SetPoint("TOPLEFT")
	frame.RightScroll.Child:Size(SMAIL_CHILD_WIDTH, SMALL_BUTTON_HEIGHT)

	for i = 1, MAX_BUTTONS do
		CreateButton(i, frame.RightScroll.Child, true)
	end

	frame.RightScroll:SetScrollChild(frame.RightScroll.Child)

	frame:CreateBackdrop("Transparent")
	frame.backdrop:SetOutside(frame.LeftScroll, 15, 15, frame.RightScroll)

	frame.FadeObject = {
		finishedFuncKeep = true,
		finishedArg1 = frame,
		finishedFunc = FadeClosure
	}

	return frame
end

function mod:GetCaseFrame()
	local numCases = #CASE_LIST
	if numCases > 0 then
		local case = CASE_LIST[numCases]
		CASE_LIST[numCases] = nil
		return case
	end

	return mod:CreateCase()
end

function mod:UpdatePosition()
	local previousCase
	for i, case in ipairs(ACTIVE_CASES) do
		case:ClearAllPoints()
		if i == 1 then
			case:Point("TOP", 0, -150)
		else
			case:Point("TOP", previousCase, "BOTTOM", 0, -45)
		end
		previousCase = case
	end
end

function OpenCase(prize, message, text)
	local case = mod:GetCaseFrame()

	table.insert(ACTIVE_CASES, case)

	case:SetPrize(prize or math.random(1, #ITEMS_TABLE))
	case:Reset()
	case.Text:SetText((not message or text) and "Тестовый режим")
	case:Show()

	case.Time = 0
	case.Duration = 5

	local rnd = math.random(BUTTON_WIDTH * 0.25, BUTTON_WIDTH * 0.75)
	case.EndScroll = END_POINT + rnd
	case.LeftEndScroll = LEFT_END_POINT + rnd
	case.RightEndScroll = RIGHT_END_POINT + rnd
	case.Message = message

	E:UIFrameFadeIn(case, 0.5, case:GetAlpha(), 1)

	case.IsPlaying = true
	case:SetScript("OnUpdate", OnUpdate)

	mod:UpdatePosition()

	return case
end

local noValueText = "У вас недостаточно бонусов для участия в лотерее."
function mod:CHAT_MSG_SYSTEM(_, msg)
	if msg == noValueText then
		OpenCase(nil, nil, true)
	end
end

function mod:Initialize()
	if not E.db.sirus.case then return end

	self:RegisterEvent("CHAT_MSG_SYSTEM")

	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE", function(_, _, ...)
		local arg1, arg2, _, _, arg5 = ...
		if arg2 == E.myname and arg5 == E.myname and ITEMS_MSG[arg1] then
			return true
		end
	end)

	local oldScript = RaidBossEmoteFrame:GetScript("OnEvent")
	RaidBossEmoteFrame:SetScript("OnEvent", function(self, event, ...)
		local arg1, arg2, _, _, arg5 = ...
		if event == "CHAT_MSG_RAID_BOSS_EMOTE" and arg2 == E.myname and arg5 == E.myname and ITEMS_MSG[arg1] then
			OpenCase(ITEMS_MSG[arg1], arg1)
		else
			if oldScript then
				oldScript(self, event, ...)
			end
		end
	end)
end


local function InitializeCallback()
	mod:Initialize()
end

E:RegisterModule(mod:GetName(), InitializeCallback)
