local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local RB = E:GetModule("ReminderBuffs")
local LSM = E.Libs.LSM

--Lua functions
local ipairs, unpack = ipairs, unpack
--WoW API / Variables
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local UnitAura = UnitAura

RB.Spell1Buffs = {
	67016, -- Flask of the North (SP)
	67017, -- Flask of the North (AP)
	67018, -- Flask of the North (STR)
	53755, -- Flask of the Frost Wyrm
	53758, -- Flask of Stoneblood
	53760, -- Flask of Endless Rage
	54212, -- Flask of Pure Mojo
	53752, -- Lesser Flask of Toughness (50 Resilience)
	17627, -- Flask of Distilled Wisdom
	270006, -- Настой сопротивления
	270007, -- Настой Драконьего разума
	270008, -- Настой Сила титана
	270009, -- Настой Текущей воды
	270010, -- Настой Стальной Кожи
	270011, -- Настой Крепости

	33721, -- Spellpower Elixir
	53746, -- Wrath Elixir
	28497, -- Elixir of Mighty Agility
	53748, -- Elixir of Mighty Strength
	60346, -- Elixir of Lightning Speed
	60344, -- Elixir of Expertise
	60341, -- Elixir of Deadly Strikes
	60345, -- Elixir of Armor Piercing
	60340, -- Elixir of Accuracy
	53749, -- Guru's Elixir

	60343, -- Elixir of Mighty Defense
	53751, -- Elixir of Mighty Fortitude
	53764, -- Elixir of Mighty Mageblood
	60347, -- Elixir of Mighty Thoughts
	53763, -- Elixir of Protection
	53747, -- Elixir of Spirit
}

RB.Spell2Buffs = {
	57325, -- 80 AP
	57327, -- 46 SP
	57329, -- 40 Critical Strike Rating
	57332, -- 40 Haste Rating
	57334, -- 20 MP5
	57356, -- 40 Expertise Rating
	57358, -- 40 ARP
	57360, -- 40 Hit Rating
	57363, -- Tracking Humanoids
	57365, -- 40 Spirit
	57367, -- 40 AGI
	57371, -- 40 STR
	57373, -- Tracking Beasts
	57399, -- 80 AP, 46 SP
	59230, -- 40 Dodge Rating
	65247, -- 20 STR
}

RB.Spell3Buffs = {
	72588, -- Gift of the Wild
	48469, -- Mark of the Wild
}
-- RB.Spell4Buffs = {
-- 	72588, -- Gift of the Wild
-- 	48469, -- Mark of the Wild
-- }

RB.Spell4Buffs = {
	25898, -- Greater Blessing of Kings
	20217, -- Blessing of Kings
	72586, -- Blessing of Forgotten Kings
}

RB.CasterSpell5Buffs = {
	61316, -- Dalaran Brilliance
	43002, -- Arcane Brilliance
	42995, -- Arcane Intellect
}

RB.MeleeSpell5Buffs = {
	48162, -- Prayer of Fortitude
	48161, -- Power Word: Fortitude
	72590, -- Fortitude
}

RB.CasterSpell6Buffs = {
	48938, -- Greater Blessing of Wisdom
	48936, -- Blessing of Wisdom
	58777, -- Mana Spring
}

RB.MeleeSpell6Buffs = {
	48934, -- Greater Blessing of Might
	48932, -- Blessing of Might
	47436, -- Battle Shout
}
RB.CasterSpell7Buffs = {
	317727, --caster oil
}

RB.MeleeSpell7Buffs = {
	317728, --melee oil
}





function RB.CheckForTimeChest(...)
	-- print(...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region:GetObjectType() == "FontString" then
            --print(region)
            local text = region:GetText()
            -- print(text)
            if text and (string.match(text, "(+52 к силе заклинаний)") or string.match(text, "(+90 к силе атаки)")) then
				local hour,mins,seconds = nil,nil,nil
				local sh,ch = string.find(text, "%d+ час")
				local sm,em  = string.find(text, "%d+ мин%.")
				local sc,ec = string.find(text, "%d+ cек%.")

				if sh then
					hour = string.sub(text,sh,sh+1)
				elseif sm then
					mins = string.sub(text,sm,sm+2)
				elseif sc then
					seconds = string.sub(text,sc,sc+2)
				end
				if hour then
					RB.remainingTime = (tonumber(hour) or 1) * 60 * 60
					-- print( RB.remainingTime)
                    return
                elseif mins then
                    RB.remainingTime = (tonumber(mins) or 1) * 60
					-- print( RB.remainingTime)
                    return
                elseif seconds then
                    RB.remainingTime = (tonumber(seconds) or 1)
					-- print( RB.remainingTime)
                    return
				else
					RB.remainingTime = 0
                end

                return
            end
        end
    end
    RB.remainingTime = 0
end




function RB:CheckItemForBuffOil(...)

	if not (RB.chestFrame) then
		RB.chestFrame = CreateFrame("GameTooltip", "ChestTooltip", nil, "GameTooltipTemplate")
		RB.chestFrame:SetOwner(WorldFrame, "ANCHOR_NONE")
	end

    RB.chestFrame:SetInventoryItem("player", 5)
    -- RB.checkTime = GetTime()
    -- print(RB.checkTime)
	do
    	RB.CheckForTimeChest(RB.chestFrame:GetRegions())
	end
end





function RB:CheckFilterForActiveBuff(filter,...)

	if filter ~= self["Spell7Buffs"] or filter ~= self["Spell7Buffs"] then
		for _, spell in ipairs(filter) do
			local spellName = GetSpellInfo(spell)
			local name, _, texture, _, _, duration, expirationTime = UnitAura("player", spellName)

			if name then
				return texture, duration, expirationTime
			end
		end
	else
		-- print("--------------------------------------------")
		RB:CheckItemForBuffOil(...)
		for _, spell in ipairs(filter) do
			local spellName = GetSpellInfo(spell)
			local name, _, texture, _, _, duration, expirationTime = UnitAura("player",spellName)
			if name then
				return texture, 3600, RB.remainingTime + GetTime()
			end
		end
	end
end



function RB:UpdateReminderTime(elapsed)
	self.expiration = self.expiration - elapsed

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if self.expiration <= 0 then
		self.timer:SetText("")
		self:SetScript("OnUpdate", nil)
		return
	end

	local value, id, nextUpdate, remainder = E:GetTimeInfo(self.expiration, 4)
	self.nextUpdate = nextUpdate

	local style = E.TimeFormats[id]
	if style then
		self.timer:SetFormattedText(style[1], value, remainder)
	end
end

function RB:UpdateReminder(event, unit)
	if event == "UNIT_AURA" and unit ~= "player" then return end

	for i = 1, 7 do
		local texture, duration, expirationTime = self:CheckFilterForActiveBuff(self["Spell"..i.."Buffs"])
		local button = self.frame[i]

		if texture then
			button.t:SetTexture(texture)
			if (duration == 0 and expirationTime == 0) or E.db.general.reminder.durations ~= true then
				button.t:SetAlpha(E.db.general.reminder.reverse and 1 or 0.3)
				button:SetScript("OnUpdate", nil)
				button.timer:SetText(nil)
				CooldownFrame_SetTimer(button.cd, 0, 0, 0)
			else
				button.expiration = expirationTime - GetTime()
				button.nextUpdate = 0
				button.t:SetAlpha(1)
				CooldownFrame_SetTimer(button.cd, expirationTime - duration, duration, 1)
				button.cd:SetReverse(E.db.general.reminder.reverse)
				button:SetScript("OnUpdate", self.UpdateReminderTime)
			end
		else
			CooldownFrame_SetTimer(button.cd, 0, 0, 0)
			button.t:SetAlpha(E.db.general.reminder.reverse and 0.3 or 1)
			button:SetScript("OnUpdate", nil)
			button.timer:SetText(nil)
			button.t:SetTexture(self.DefaultIcons[i])
		end
	end
end

function RB:CreateButton()
	local button = CreateFrame("Button", nil, ElvUI_ReminderBuffs)
	button:SetTemplate("Default")

	button.t = button:CreateTexture(nil, "OVERLAY")
	button.t:SetTexCoord(unpack(E.TexCoords))
	button.t:SetInside()
	button.t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

	button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.cd:SetInside()
	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	button.timer = button.cd:CreateFontString(nil, "OVERLAY")
	button.timer:SetPoint("CENTER")

	return button
end

function RB:EnableRB()
	ElvUI_ReminderBuffs:Show()
	self:RegisterEvent("UNIT_AURA", "UpdateReminder")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "UpdateReminder")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "UpdateReminder")
	E.RegisterCallback(self, "RoleChanged", "UpdateSettings")
	self:UpdateReminder()
end

function RB:DisableRB()
	ElvUI_ReminderBuffs:Hide()
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("CHARACTER_POINTS_CHANGED")
	E.UnregisterCallback(self, "RoleChanged", "UpdateSettings")
end

function RB:UpdateSettings(isCallback)
	local frame = self.frame
	frame:Width(E.RBRWidth)

	self:UpdateDefaultIcons()

	for i = 1, 7 do
		local button = frame[i]
		button:ClearAllPoints()
		button:SetWidth(E.RBRWidth)
		button:SetHeight(E.RBRWidth)

		if i == 1 then
			button:SetPoint("TOP", ElvUI_ReminderBuffs, "TOP", 0, 0)
		elseif i == 7 then
			button:SetPoint("BOTTOM", ElvUI_ReminderBuffs, "BOTTOM", 0, 0)
		else
			button:Point("TOP", frame[i - 1], "BOTTOM", 0, E.Border - E.Spacing*3)
		end

		if E.db.general.reminder.durations then
			button.cd:SetAlpha(1)
		else
			button.cd:SetAlpha(0)
		end

		button.timer:FontTemplate(LSM:Fetch("font", E.db.general.reminder.font), E.db.general.reminder.fontSize, E.db.general.reminder.fontOutline)
	end

	if not isCallback then
		if E.db.general.reminder.enable then
			RB:EnableRB()
		else
			RB:DisableRB()
		end
	else
		self:UpdateReminder()
	end
end

function RB:UpdatePosition()
	Minimap:ClearAllPoints()
	ElvConfigToggle:ClearAllPoints()
	ElvUI_ReminderBuffs:ClearAllPoints()
	if E.db.general.reminder.position == "LEFT" then
		Minimap:Point("TOPRIGHT", MMHolder, "TOPRIGHT", -E.Border, -E.Border)
		ElvConfigToggle:SetPoint("TOPRIGHT", LeftMiniPanel, "TOPLEFT", E.Border - E.Spacing*3, 0)
		ElvConfigToggle:SetPoint("BOTTOMRIGHT", LeftMiniPanel, "BOTTOMLEFT", E.Border - E.Spacing*3, 0)
		ElvUI_ReminderBuffs:SetPoint("TOPRIGHT", Minimap.backdrop, "TOPLEFT", E.Border - E.Spacing*3, 0)
		ElvUI_ReminderBuffs:SetPoint("BOTTOMRIGHT", Minimap.backdrop, "BOTTOMLEFT", E.Border - E.Spacing*3, 0)
	else
		Minimap:Point("TOPLEFT", MMHolder, "TOPLEFT", E.Border, -E.Border)
		ElvConfigToggle:SetPoint("TOPLEFT", RightMiniPanel, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
		ElvConfigToggle:SetPoint("BOTTOMLEFT", RightMiniPanel, "BOTTOMRIGHT", -E.Border + E.Spacing*3, 0)
		ElvUI_ReminderBuffs:SetPoint("TOPLEFT", Minimap.backdrop, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
		ElvUI_ReminderBuffs:SetPoint("BOTTOMLEFT", Minimap.backdrop, "BOTTOMRIGHT", -E.Border + E.Spacing*3, 0)
	end
end

function RB:UpdateDefaultIcons()
	self.DefaultIcons = {
		[1] = "Interface\\Icons\\INV_Potion_97",
		[2] = "Interface\\Icons\\Spell_Misc_Food",
		[3] = "Interface\\Icons\\Spell_Nature_Regeneration",
		[4] = "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings",
		[5] = (E.Role == "Caster" and "Interface\\Icons\\Spell_Holy_MagicalSentry") or "Interface\\Icons\\Spell_Holy_WordFortitude",
		[6] = (E.Role == "Caster" and "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom") or "Interface\\Icons\\Ability_Warrior_BattleShout",
		[7] = (E.Role == "Caster" and "Interface\\Icons\\INV_Potion_141") or "Interface\\Icons\\INV_Potion_141", --- for another icons TODO later
	}

	self.Spell5Buffs = E.Role == "Caster" and self.CasterSpell5Buffs or self.MeleeSpell5Buffs
	self.Spell6Buffs = E.Role == "Caster" and self.CasterSpell6Buffs or self.MeleeSpell6Buffs
	self.Spell7Buffs = E.Role == "Caster" and self.CasterSpell7Buffs or self.MeleeSpell7Buffs
end


function RB:UpdateButtonStatus()
	-- if not E.db.general.reminder.pot then
	-- 	print("DSA")
	-- end
	local lastid = 1
	local allParametres = {
		E.db.general.reminder.pot,
		E.db.general.reminder.food,
		E.db.general.reminder.drubuff,
		E.db.general.reminder.palcask,
		E.db.general.reminder.inta,
		E.db.general.reminder.palmp5,
		E.db.general.reminder.oil,
	}

	for i = 1,#allParametres do

		ElvUI_ReminderBuffs[i]:ClearAllPoints()
		ElvUI_ReminderBuffs[i]:SetWidth(E.RBRWidth)
		ElvUI_ReminderBuffs[i]:SetHeight(E.RBRWidth)
		ElvUI_ReminderBuffs[i]:Hide()

		if allParametres[i] == true then
			ElvUI_ReminderBuffs[i].currentID = lastid
			lastid = lastid + 1
			ElvUI_ReminderBuffs[i]:Show()
		elseif allParametres[i] == false then
			ElvUI_ReminderBuffs[i]:Hide()
		end

		-- if i == 1 then
		-- 	local id = ElvUI_ReminderBuffs[i].currentID
		-- 	if id then
		-- 		ElvUI_ReminderBuffs[i]:SetPoint("TOP", ElvUI_ReminderBuffs, "TOP", 0, E.RBRWidth*-id)
		-- 	end
		-- -- elseif i == #allParametres then
		-- -- 	ElvUI_ReminderBuffs[i]:SetPoint("BOTTOM", ElvUI_ReminderBuffs, "BOTTOM", 0, 0)
		-- else
			local id = ElvUI_ReminderBuffs[i].currentID
			if id then
				if id == 1 then
					ElvUI_ReminderBuffs[i]:Point("TOP", ElvUI_ReminderBuffs, "TOP", 0, (E.RBRWidth*-(id-1)))
				-- print((E.Border))
				-- print((E.Spacing*3))
				else
					ElvUI_ReminderBuffs[i]:Point("TOP", ElvUI_ReminderBuffs, "TOP", 0, (E.RBRWidth*-(id-1))+(E.Border - E.Spacing*3)*4)
				end
			end
		-- end
	end
end

function RB:Initialize()
	if not E.private.general.minimap.enable then return end

	self.db = E.db.general.reminder

	local frame = CreateFrame("Frame", "ElvUI_ReminderBuffs", Minimap)
	frame:Width(E.RBRWidth)
	if E.db.general.reminder.position == "LEFT" then
		frame:Point("TOPRIGHT", Minimap.backdrop, "TOPLEFT", E.Border - E.Spacing*3, 0)
		frame:Point("BOTTOMRIGHT", Minimap.backdrop, "BOTTOMLEFT", E.Border - E.Spacing*3, 0)
	else
		frame:Point("TOPLEFT", Minimap.backdrop, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
		frame:Point("BOTTOMLEFT", Minimap.backdrop, "BOTTOMRIGHT", -E.Border + E.Spacing*3, 0)
	end
	self.frame = frame

	for i = 1, 7 do
		frame[i] = self:CreateButton()
		frame[i]:SetID(i)
	end
	self:UpdateSettings()
	self:UpdateButtonStatus()

	RB.remainingTime = 0
	-- RB.checkTime = 0
	
	-- local f = CreateFrame("Frame",nil,UIParent)
	-- f:RegisterEvent("UNIT_INVENTORY_CHANGED")
	-- f:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- -- f:RegisterEvent("UNIT_INVENTORY_CHANGED")
	-- -- f:RegisterEvent("UNIT_INVENTORY_CHANGED")
	-- -- f:RegisterEvent("UNIT_INVENTORY_CHANGED")

	-- f:SetScript("OnEvent",function()
	-- 	print("da")
	-- 	RB:CheckItemForBuffOil()
	-- end)
end

local function InitializeCallback()
	RB:Initialize()
end

E:RegisterModule(RB:GetName(), InitializeCallback)