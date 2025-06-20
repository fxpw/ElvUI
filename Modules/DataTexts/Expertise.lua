local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule("DataTexts")

local format = string.format
local join = string.join

local GetExpertise = GetExpertise
local GetInventoryItemLink = GetInventoryItemLink

local STAT_EXPERTISE = STAT_EXPERTISE

local displayString = ""
local mainExpertise, offExpertise = 0, 0
local hasOffHand = false

local lastPanel

local function OnEvent(self)
    mainExpertise, offExpertise = GetExpertise()
    hasOffHand = GetInventoryItemLink("player", 17) ~= nil

    if hasOffHand then
        self.text:SetFormattedText(displayString, STAT_EXPERTISE..": ", format("%d / %d", mainExpertise, offExpertise))
    else
        self.text:SetFormattedText(displayString, STAT_EXPERTISE..": ", format("%d", mainExpertise))
    end

	lastPanel = self
end

local function ApplySettings(hex)
    displayString = join('', '%s', hex, '%s|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ApplySettings] = true

DT:RegisterDatatext( "Expertise", {"UNIT_STATS", "UNIT_AURA", "PLAYER_TALENT_UPDATE", "PLAYER_EQUIPMENT_CHANGED"}, OnEvent, nil, nil, nil, nil, STAT_EXPERTISE )
