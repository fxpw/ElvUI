local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local date = date
--WoW API / Variables
local FormatShortDate = FormatShortDate

local displayString = "%s"
local lastPanel

local function OnClick()
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

	_G.GameTimeFrame:Click()
end

local function OnEvent(self)
	lastPanel = self

	local dateTable = date("*t")

	self.text:SetText(FormatShortDate(dateTable.day, dateTable.month, dateTable.year):gsub("([/.])", displayString))
end

local function ValueColorUpdate(hex)
	displayString = hex.."%1|r"

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Date", {"UPDATE_INSTANCE_INFO"}, OnEvent, nil, OnClick)
