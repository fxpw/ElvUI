local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
-- local join = string.join
local strf = string.format
--WoW API / Variables




-- local displayNumberString = ""
local lastPanel

-- local VolumeTable ={
-- 	[1] = "Sound_MasterVolume",
-- 	[2] = "Sound_SFXVolume",
-- 	[3] = "Sound_MusicVolume",
-- 	[4] = "Sound_AmbienceVolume",
-- 	[5] = "OutboundChatVolume",
-- 	[6] = "InboundChatVolume",

-- }
local MasterVolume,SFXVolume,MusicVolume,AmbienceVolume

local currenSetVolume = 1

local allVolume
local function OnEnter(self)
	DT:SetupTooltip(self)
	MasterVolume = (1 - GetCVar("Sound_MasterVolume")) ---Громкость общего звука
	SFXVolume = (1 - GetCVar("Sound_SFXVolume")) --- Громкость звуковых эффектов
	MusicVolume = (1 - GetCVar("Sound_MusicVolume")) --- Громкость мызыки
	AmbienceVolume = (1 - GetCVar("Sound_AmbienceVolume")) --- Громкость звуков окружающего мира
	-- OutboundChatVolume = (1 - GetCVar("OutboundChatVolume")) ---mocrophone
	-- InboundChatVolume = (1 - GetCVar("InboundChatVolume")) ---speaker
	DT.tooltip:AddLine("")
	DT.tooltip:AddDoubleLine(currenSetVolume == 1 and "|cff1bf6ffГромкость общего звука" or "Громкость общего звука", strf("%.1f",((1-MasterVolume)*100)).."%", 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddDoubleLine(currenSetVolume == 2 and "|cff1bf6ffГромкость звуковых эффектов" or "Громкость звуковых эффектов",  strf("%.1f",((1-SFXVolume)*100)).."%", 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddDoubleLine(currenSetVolume == 3 and "|cff1bf6ffГромкость мызыки" or "Громкость мызыки",  strf("%.1f",((1-MusicVolume)*100)).."%", 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddDoubleLine(currenSetVolume == 4 and "|cff1bf6ffГромкость звуков окружающего мира" or "Громкость звуков окружающего мира",  strf("%.1f",((1-AmbienceVolume)*100)).."%", 1, 1, 1, 1, 1, 0)
	-- DT.tooltip:AddDoubleLine("Громкость микрофона", (OutboundChatVolume*100).."%%", 1, 1, 1, 1, 1, 0)
	-- DT.tooltip:AddDoubleLine("Громкость динамиков", (InboundChatVolume*100).."%%", 1, 1, 1, 1, 1, 0)
	-- DT.tooltip:AddLine("")
	DT.tooltip:AddLine("")
	-- DT.tooltip:AddDoubleLine("",  "", 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddLine("Клик для выключения звука")
	DT.tooltip:AddLine("Прокрутка колесика для изменения выбранного звука")
	DT.tooltip:AddLine("ALT + Прокрутка колесика для выбора звука для изменения")
	DT.tooltip:Show()
	-- lastPanel = self
end

local function OnEvent(self)
	-- DT:SetupTooltip(self)

	MasterVolume = GetCVar("Sound_MasterVolume") ---Громкость общего звука
	SFXVolume = GetCVar("Sound_SFXVolume") --- Громкость звуковых эффектов
	MusicVolume = GetCVar("Sound_MusicVolume") --- Громкость мызыки
	AmbienceVolume = GetCVar("Sound_AmbienceVolume") --- Громкость звуков окружающего мира
	-- OutboundChatVolume = (1 - GetCVar("OutboundChatVolume")) ---mocrophone
	-- InboundChatVolume = (1 - GetCVar("InboundChatVolume")) ---speaker



	-- local c = "Sound_EnableAllSound"
	allVolume = GetCVar("Sound_EnableAllSound") or "0"
	if allVolume == "0" then
		-- SetCVar(c, "0")
		self.text:SetFormattedText("%s", "Звук: |cffff0000Выкл|r")
	elseif  allVolume == "1" then
		-- SetCVar(c, "1")
		self.text:SetFormattedText("%s", "Звук: |cff2cff04Вкл|r")
	end
	-- DT.tooltip:AddLine(" ")
	-- lastPanel = self
end




local function OnClick(self,button)
	-- DT:SetupTooltip(self)
	if button == "LeftButton" then
		-- local c = "Sound_EnableAllSound"
		-- allVolume = GetCVar("Sound_EnableAllSound") or "0"
		if allVolume == "1" then
			SetCVar("Sound_EnableAllSound", "0")
			-- self.text:SetFormattedText("%s", "Звук: |cffff0000Выкл|r")
		elseif allVolume == "0" then
			SetCVar("Sound_EnableAllSound", "1")
			-- self.text:SetFormattedText("%s", "Звук: |cff2cff04Вкл|r")
		end
		OnEvent(self)
		DT.tooltip:Hide()
		OnEnter(self)
	end

end

local function OnMouseWheel(self,delta)

	if IsAltKeyDown() then
		currenSetVolume = currenSetVolume - delta
		if currenSetVolume > 4 then
			currenSetVolume = 4
		elseif currenSetVolume <= 1 then
			currenSetVolume = 1
		end
		DT.tooltip:Hide()
		OnEnter(self)
	else
		if currenSetVolume == 1 then
			-- print("--------------")
			MasterVolume = MasterVolume - (0.01*delta)
			-- print(MasterVolume)
			if MasterVolume> 1 then
				MasterVolume = 1
			elseif MasterVolume <= 0 then
				MasterVolume = 0
			end
			SetCVar("Sound_MasterVolume",1 - MasterVolume)
			MasterVolume = 1 -  GetCVar("Sound_MasterVolume")
			-- print(MasterVolume)
			-- print("--------------")
		elseif  currenSetVolume == 2 then
			-- print(SFXVolume)
			SFXVolume = SFXVolume - (0.01*delta)
			if SFXVolume> 1 then
				SFXVolume = 1
			elseif SFXVolume <= 0 then
				SFXVolume = 0
			end
			SetCVar("Sound_SFXVolume",1 -  SFXVolume)
			SFXVolume = 1 -  GetCVar("Sound_SFXVolume")
		elseif currenSetVolume == 3 then
			-- print(MusicVolume)
			MusicVolume = MusicVolume - (0.01*delta)
			if MusicVolume > 1 then
				MusicVolume = 1
			elseif MusicVolume <= 0 then
				MusicVolume = 0
			end
			SetCVar("Sound_MusicVolume",1 -  MusicVolume)
			MusicVolume = 1 -  GetCVar("Sound_MusicVolume")
		elseif currenSetVolume == 4 then
			-- print(AmbienceVolume)
			AmbienceVolume = AmbienceVolume - (0.01*delta)
			if AmbienceVolume> 1 then
				AmbienceVolume = 1
			elseif AmbienceVolume <= 0 then
				AmbienceVolume = 0
			end
			SetCVar("Sound_AmbienceVolume",1 -  AmbienceVolume)
			AmbienceVolume = 1 -  GetCVar("Sound_AmbienceVolume")
		-- elseif currenSetVolume == 5 then
		-- 	print(OutboundChatVolume)
		-- 	OutboundChatVolume = OutboundChatVolume - 0.04*delta

		-- 	SetCVar("OutboundChatVolume", OutboundChatVolume - 0.04*delta)
		-- elseif currenSetVolume == 6 then
		-- 	print(InboundChatVolume)
		-- 	InboundChatVolume = InboundChatVolume - 0.04*delta

		-- 	SetCVar("InboundChatVolume", InboundChatVolume - 0.04*delta)
		end
		DT.tooltip:Hide()
		OnEnter(self)
	end
end


local function ValueColorUpdate(hex)
	-- displayNumberString = join("", "%s: ", hex, "%d|r")


	if lastPanel ~= nil then
		OnEvent(lastPanel,"ELVUI_COLOR_UPDATE")
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Звук", {"MODIFIER_STATE_CHANGED","PLAYER_ENTERING_WORLD"}, OnEvent, nil, OnClick, OnEnter, nil, "Звук",true, OnMouseWheel)