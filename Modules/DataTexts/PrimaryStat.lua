local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local join = string.join
--WoW API / Variables
local UnitStat = UnitStat

local NOT_APPLICABLE = NOT_APPLICABLE

-- индекс основной характеристики (LE_UNIT_STAT_*) по классу и ветке талантов; в 3.3.5a нет GetSpecializationInfo
local primaryStatByClassTree = {
	WARRIOR = {1, 1, 1},      -- Сила
	PALADIN = {4, 1, 1},      -- Интеллект, Сила, Сила
	HUNTER = {2, 2, 2},       -- Ловкость
	ROGUE = {2, 2, 2},        -- Ловкость
	PRIEST = {4, 4, 4},       -- Интеллект
	DEATHKNIGHT = {1, 1, 1},  -- Сила
	SHAMAN = {4, 2, 4},       -- Интеллект, Ловкость, Интеллект
	MAGE = {4, 4, 4},         -- Интеллект
	WARLOCK = {4, 4, 4},      -- Интеллект
	DRUID = {4, 2, 4},        -- Интеллект, Ловкость, Интеллект
}

local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	local specIndex = E:GetTalentSpecInfo()
	local statID = specIndex and primaryStatByClassTree[E.myclass] and primaryStatByClassTree[E.myclass][specIndex]

	local name = statID and _G["SPELL_STAT"..statID.."_NAME"]
	if name then
		self.text:SetFormattedText(displayString, name..": ", UnitStat("player", statID))
	else
		self.text:SetText(NOT_APPLICABLE)
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s", hex, "%.f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Primary Stat", {"UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "CHARACTER_POINTS_CHANGED"}, OnEvent, nil, nil, nil, nil, L["Primary Stat"])
