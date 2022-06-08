local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables

local displayString = ""
local lastPanel


local Premium
local curLvL
local lvlXP
local maxXP
local Cap

local function OnEnter(self)


	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L["Left Click:"], "Открыть боевой пропуск", 1, 1, 1)


	DT.tooltip:Show()

end


local function OnClick(_,button)
	if button == "LeftButton" then
		BattlePassFrame:Show()
	end
end
local function OnEvent(self, event)
	lastPanel = self

	Premium = BattlePassFrameMixin:IsBuyPremium()

	Cap = BattlePassFrameMixin:GetCapXP()
	curLvL, maxXP, lvlXP = BattlePassFrameMixin:GetLevelInfoByXP(BattlePassFrameMixin:GetTotalXP())

	self.text:SetFormattedText(displayString, curLvL,lvlXP,maxXP,Cap)
end

local function ValueColorUpdate(hex)
	if Premium == true then
		displayString = join("", "|cfff5cf00БП(%s)|r: ", hex, "%.0f/%.0f (%.0f)|r")
	else
		displayString = join("", "БП(%s): ", hex, "%.0f/%.0f (%.0f)|r")
	end

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Hit", {"SPELL_UPDATE_USABLE", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "COMBAT_RATING_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, "Боевой пропуск")