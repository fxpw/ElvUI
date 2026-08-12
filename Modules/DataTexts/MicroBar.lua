local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local join = string.join
--WoW API / Variables
local ToggleFrame = ToggleFrame
local CreateFrame = CreateFrame

local displayString = ""
local lastPanel

local dropdown = CreateFrame("Frame", "ElvUI_MicroBarDropDown", E.UIParent)

local RightClickMenuList = {
	{ text = L["Character"], func = function() ToggleFrame(_G.CharacterFrame) end },
	{ text = L["Spellbook"], func = function() ToggleFrame(_G.SpellBookFrame) end },
	{ text = L["Talents"], func = function() ToggleFrame(_G.PlayerTalentFrame) end },
	{ text = L["Quest Log"], func = function() ToggleFrame(_G.QuestLogFrame) end },
	{ text = L["Social"], func = function() ToggleFrame(_G.CharacterFrame) end },
	{ text = L["World Map"], func = function() ToggleFrame(_G.WorldMapFrame) end },
	{ text = L["Help"], func = function() ToggleFrame(_G.HelpFrame) end },
	{ text = L["Game Menu"], func = function() ToggleFrame(_G.GameMenuFrame) end },
}

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, L["Micro Bar"])
end

local function OnClick(self, button)
	if button == "LeftButton" then
		ToggleFrame(_G.GameMenuFrame)
	else
		E:DropDown(RightClickMenuList, dropdown)
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Micro Bar", nil, OnEvent, nil, OnClick, nil, nil, L["Micro Bar"])
