local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local tonumber = tonumber
local format = string.format
local ipairs = ipairs
local tinsert = table.insert
--WoW API / Variables
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local IsShiftKeyDown = IsShiftKeyDown
local ToggleFrame = ToggleFrame
local CreateFrame = CreateFrame

local Sound_GameSystem_GetOutputDriverNameByIndex = Sound_GameSystem_GetOutputDriverNameByIndex
local Sound_GameSystem_GetNumOutputDrivers = Sound_GameSystem_GetNumOutputDrivers
local Sound_GameSystem_RestartSoundSystem = Sound_GameSystem_RestartSoundSystem

local Sound_CVars = {
	Sound_MasterVolume = true,
	Sound_SFXVolume = true,
	Sound_AmbienceVolume = true,
	Sound_MusicVolume = true
}

local AudioStreams = {
	{ Name = _G.MASTER_VOLUME, Volume = "Sound_MasterVolume", Enabled = "Sound_EnableAllSound" },
	{ Name = _G.SOUND_VOLUME, Volume = "Sound_SFXVolume", Enabled = "Sound_EnableSFX" },
	{ Name = _G.AMBIENCE_VOLUME, Volume = "Sound_AmbienceVolume", Enabled = "Sound_EnableAmbience" },
	{ Name = _G.MUSIC_VOLUME, Volume = "Sound_MusicVolume", Enabled = "Sound_EnableMusic" }
}

local panelText
local activeIndex = 1
local activeStream = AudioStreams[activeIndex]
local menu = {}
local toggleMenu = {}
local deviceMenu = {}

local dropdown = CreateFrame("Frame", "ElvUI_VolumeDropDown", E.UIParent)

local function GetStreamString(stream, tooltip)
	if not stream then stream = AudioStreams[1] end

	local color = GetCVarBool(AudioStreams[1].Enabled) and GetCVarBool(stream.Enabled) and "00FF00" or "FF3333"
	local level = (GetCVar(stream.Volume) or 0) * 100

	return (tooltip and format("|cFF%s%.f%%|r", color, level)) or format("%s: |cFF%s%.f%%|r", stream.Name, color, level)
end

local function SelectStream(_, arg1)
	activeIndex = arg1
	activeStream = AudioStreams[activeIndex]

	if panelText then
		panelText:SetText(GetStreamString(activeStream))
	end
end

local function ToggleStream(_, arg1)
	local Stream = AudioStreams[arg1]

	E:SetCVar(Stream.Enabled, GetCVarBool(Stream.Enabled) and 0 or 1, "ELVUI_VOLUME")

	if panelText then
		panelText:SetText(GetStreamString(activeStream))
	end
end

for Index, Stream in ipairs(AudioStreams) do
	tinsert(menu, { text = Stream.Name, func = function() SelectStream(nil, Index) end })
	tinsert(toggleMenu, { text = Stream.Name, func = function() ToggleStream(nil, Index) end })
end

local function SelectSoundOutput(_, arg1)
	E:SetCVar("Sound_OutputDriverIndex", arg1, "ELVUI_VOLUME")
	Sound_GameSystem_RestartSoundSystem()
end

for i = 0, (Sound_GameSystem_GetNumOutputDrivers and Sound_GameSystem_GetNumOutputDrivers() or 0) - 1 do
	tinsert(deviceMenu, { text = Sound_GameSystem_GetOutputDriverNameByIndex(i), func = function() SelectSoundOutput(nil, i) end })
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddLine(L["Active Output Audio Device"], 1, 1, 1)
	DT.tooltip:AddLine(Sound_GameSystem_GetOutputDriverNameByIndex(GetCVar("Sound_OutputDriverIndex")))
	DT.tooltip:AddLine(" ")
	DT.tooltip:AddLine(L["Volume Streams"], 1, 1, 1)

	for _, Stream in ipairs(AudioStreams) do
		DT.tooltip:AddDoubleLine(Stream.Name, GetStreamString(Stream, true))
	end

	DT.tooltip:AddLine(" ")

	DT.tooltip:AddLine(L["|cFFffffffLeft Click:|r Select Volume Stream"])
	DT.tooltip:AddLine(L["|cFFffffffMiddle Click:|r Toggle Mute Master Stream"])
	DT.tooltip:AddLine(L["|cFFffffffRight Click:|r Toggle Volume Stream"])
	DT.tooltip:AddLine(L["|cFFffffffShift + Left Click:|r Open System Audio Panel"])
	DT.tooltip:AddLine(L["|cFFffffffShift + Right Click:|r Select Output Audio Device"])

	DT.tooltip:Show()
end

local function onMouseWheel(_, delta)
	local vol = GetCVar(activeStream.Volume)
	local scale = 100

	if IsShiftKeyDown() then
		scale = 10
	end

	vol = tonumber(vol) + (delta / scale)

	if vol >= 1 then
		vol = 1
	elseif vol <= 0 then
		vol = 0
	end

	E:SetCVar(activeStream.Volume, vol, "ELVUI_VOLUME")
	panelText:SetText(GetStreamString(activeStream))
end

local function OnEvent(self, event, arg1)
	activeStream = AudioStreams[activeIndex]
	panelText = self.text

	local force = event == "ELVUI_FORCE_UPDATE" or event == "ELVUI_FORCE_RUN"
	if force or (event == "CVAR_UPDATE" and (Sound_CVars[arg1] or arg1 == "ELVUI_VOLUME")) then
		if force then
			self:EnableMouseWheel(true)
			self:SetScript("OnMouseWheel", onMouseWheel)
		end

		panelText:SetText(GetStreamString(activeStream))
	end
end

local function OnClick(self, button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			ToggleFrame(_G.AudioOptionsFrame)
			return
		end

		E:DropDown(menu, dropdown)
	elseif button == "MiddleButton" then
		E:SetCVar(AudioStreams[1].Enabled, GetCVarBool(AudioStreams[1].Enabled) and 0 or 1, "ELVUI_VOLUME")
	elseif button == "RightButton" then
		E:DropDown(IsShiftKeyDown() and deviceMenu or toggleMenu, dropdown)
	end
end

DT:RegisterDatatext(L["Volume"], {"CVAR_UPDATE"}, OnEvent, nil, OnClick, OnEnter)
