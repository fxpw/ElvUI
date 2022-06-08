local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables

local BlockChance
local displayString = ""
local lastPanel

local function OnEvent(self, event)
	lastPanel = self

	if event == "SPELL_UPDATE_USABLE" then
		self:UnregisterEvent(event)
	end

	BlockChance = GetBlockChance()
	-- print(BlockChance)

	self.text:SetFormattedText(displayString, BlockChance)
end

local function ValueColorUpdate(hex)
	displayString = join("", L["BlockC"], ": ", hex, "%.0f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("BlockChance", {"SPELL_UPDATE_USABLE", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "COMBAT_RATING_UPDATE"}, OnEvent, nil, nil, nil, nil, "Шанс блока")