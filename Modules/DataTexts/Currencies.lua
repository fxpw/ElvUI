local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local format = string.format
--WoW API / Variables
local GetMoney = GetMoney
local GetCurrencyListSize = GetCurrencyListSize
local GetCurrencyListInfo = GetCurrencyListInfo
local ToggleCharacter = ToggleCharacter

local iconString = "|T%s:20:20:0:0:64:64:4:60:4:60|t"
local goldText = ""
local lastPanel

local function OnClick()
	ToggleCharacter("TokenFrame")
end

local function OnEvent(self)
	lastPanel = self

	goldText = E:FormatMoney(GetMoney(), "BLIZZARD", true)
	self.text:SetText(goldText)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:ClearLines()

	local numCurrency = GetCurrencyListSize()
	for i = 1, numCurrency do
		local name, isHeader, _, _, _, count, _, icon = GetCurrencyListInfo(i)
		if not isHeader and name and count and count > 0 then
			DT.tooltip:AddDoubleLine(format("%s %s", format(iconString, icon or ""), name), E:ShortValue(count), 1, 1, 1)
		end
	end

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(L["Gold"]..":", goldText, nil, nil, nil, 1, 1, 1)
	DT.tooltip:Show()
end

local function ValueColorUpdate()
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Currencies", {"PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED", "CURRENCY_DISPLAY_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, _G.CURRENCY)
