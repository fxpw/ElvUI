local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local join = string.join
--WoW API / Variables
local GetZonePVPInfo = GetZonePVPInfo
local GetRealZoneText = GetRealZoneText
local GetSubZoneText = GetSubZoneText
local GetCurrentMapContinent = GetCurrentMapContinent
local GetContinentName = GetContinentName
local GetZoneText = GetZoneText
local IsInInstance = IsInInstance
local ToggleFrame = ToggleFrame

local NOT_APPLICABLE = NOT_APPLICABLE

local colors = { -- pulled from Blizz's ZoneText.lua
	none		= {r = 1, g = 1, b = 0},
	arena		= {r = 1.0, g = 0.1, b = 0.1},
	combat		= {r = 1.0, g = 0.1, b = 0.1},
	contested	= {r = 1.0, g = 0.7, b = 0.1},
	friendly	= {r = 0.1, g = 1.0, b = 0.1},
	hostile		= {r = 1.0, g = 0.1, b = 0.1},
	instance	= {r = 1.0, g = 0.1, b = 0.1},
	sanctuary	= {r = 0.4, g = 0.8, b = 0.9},
}

local lastPanel

local function GetStatus()
	return IsInInstance() and colors.instance or colors[GetZonePVPInfo()] or colors.none
end

local function OnEvent(self)
	lastPanel = self

	local zone = GetZoneText()
	local subZone = GetSubZoneText()
	local continent = GetContinentName(GetCurrentMapContinent()) or ""

	if zone == "" and subZone == "" and continent == "" then
		self.text:SetText(NOT_APPLICABLE)
		return
	end

	local color = GetStatus()
	local first = continent ~= "" and zone ~= "" and ": " or ""
	local second = (zone ~= "" or continent ~= "") and subZone ~= "" and ": " or ""

	self.text:SetFormattedText("%s%s%s%s%s%s|r", E:RGBToHex(color.r, color.g, color.b), continent, first, zone, second, subZone)
end

local function OnClick()
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

	ToggleFrame(_G.WorldMapFrame)
end

DT:RegisterDatatext("Location", {"LOADING_SCREEN_DISABLED", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED"}, OnEvent, nil, OnClick, nil, nil, L["Location"])
