local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local join = string.join
--WoW API / Variables
local UnitStat = UnitStat

local NOT_APPLICABLE = NOT_APPLICABLE

-- primary stat index (LE_UNIT_STAT_*) per class / talent tree, 3.3.5a has no GetSpecializationInfo
local primaryStatByClassTree = {
	WARRIOR = {1, 1, 1},      -- Strength
	PALADIN = {4, 1, 1},      -- Intellect, Strength, Strength
	HUNTER = {2, 2, 2},       -- Agility
	ROGUE = {2, 2, 2},        -- Agility
	PRIEST = {4, 4, 4},       -- Intellect
	DEATHKNIGHT = {1, 1, 1},  -- Strength
	SHAMAN = {4, 2, 4},       -- Intellect, Agility, Intellect
	MAGE = {4, 4, 4},         -- Intellect
	WARLOCK = {4, 4, 4},      -- Intellect
	DRUID = {4, 2, 4},        -- Intellect, Agility, Intellect
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
