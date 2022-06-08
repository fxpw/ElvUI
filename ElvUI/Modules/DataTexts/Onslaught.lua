local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables

local onslaughtRating
local displayString = ""
local lastPanel

local function OnEvent(self, event)
	lastPanel = self

	onslaughtRating = GetOnslaughtRating();

	self.text:SetFormattedText(displayString, onslaughtRating)
end

local function ValueColorUpdate(hex)
	displayString = join("", "Натиск", ": ", hex, "%.0f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Onslaught", {"COMBAT_RATING_UPDATE"}, OnEvent, nil, nil, nil, nil, "Натиск")