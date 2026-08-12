local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local next = next
local pairs = pairs
local join = string.join
--WoW API / Variables
local HasNewMail = HasNewMail
local GetLatestThreeSenders = GetLatestThreeSenders
local HAVE_MAIL_FROM = HAVE_MAIL_FROM
local MAIL_LABEL = MAIL_LABEL

local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, HasNewMail() and L["New Mail"] or L["No Mail"])
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local senders = { GetLatestThreeSenders() }
	if not next(senders) then return end

	DT.tooltip:AddLine(HasNewMail() and HAVE_MAIL_FROM or MAIL_LABEL, 1, 1, 1)
	DT.tooltip:AddLine(" ")

	for _, sender in pairs(senders) do
		DT.tooltip:AddLine(sender)
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Mail", {"MAIL_INBOX_UPDATE", "UPDATE_PENDING_MAIL", "MAIL_CLOSED", "MAIL_SHOW"}, OnEvent, nil, nil, OnEnter, nil, MAIL_LABEL)
