local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule("DataBars")
local LSM = E.Libs.LSM

local format = format
local UnitIsPVP = UnitIsPVP
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL

function DB:UpdateHonor(event, unit)
	if not DB.db.honor.enable then return end
	if (event == "PLAYER_FLAGS_CHANGED" or event == "UNIT_FACTION") and unit ~= "player" then return end

	local bar = DB.honorBar

	if (DB.db.honor.hideInCombat and (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown())) or
		(DB.db.honor.hideOutsidePvP and not UnitIsPVP("player")) or (DB.db.honor.hideBelowMaxLevel and E.mylevel < MAX_PLAYER_LEVEL) then
		bar:Hide()
	else
		bar:Show()

		if DB.db.honor.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local _, _, _, _, cur, _, _, _, max = GetRatedBattlegroundRankInfo()

		--Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
		if max == 0 then max = 1 end

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur)

		local text = ""
		local textFormat = DB.db.honor.textFormat

		if textFormat == "PERCENT" then
			text = format("%d%%", cur / max * 100)
		elseif textFormat == "CURMAX" then
			text = format("%s - %s", E:ShortValue(cur), E:ShortValue(max))
		elseif textFormat == "CURPERC" then
			text = format("%s - %d%%", E:ShortValue(cur), cur / max * 100)
		elseif textFormat == "CUR" then
			text = format("%s", E:ShortValue(cur))
		elseif textFormat == "REM" then
			text = format("%s", E:ShortValue(max - cur))
		elseif textFormat == "CURREM" then
			text = format("%s - %s", E:ShortValue(cur), E:ShortValue(max - cur))
		elseif textFormat == "CURPERCREM" then
			text = format("%s - %d%% (%s)", E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur))
		end

		bar.text:SetText(text)
	end
end

function DB:HonorBar_OnEnter()
	if DB.db.honor.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	local currTitle, _, level, _, cur, _, _, _, max = GetRatedBattlegroundRankInfo()

	GameTooltip:AddLine(PVP_TAB_SERVICES)

	GameTooltip:AddDoubleLine(PVP_YOUR_RATING..":", format(RBG_SCORE_TOOLTIP_RANK, currTitle, level), 1, 1, 1)

	if level < 14 then
		GameTooltip:AddLine(" ")

		GameTooltip:AddDoubleLine(RATED_BATTLEGROUND_TOOLTIP_NEXTRANK, format(" %d / %d (%d%%)", cur, max, cur/max * 100), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Remaining:"], format(" %d (%d%% - %d "..L["Bars"]..")", max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)
	end

	GameTooltip:Show()
end

function DB:HonorBar_OnClick()
	TogglePVPUIFrame()
end

function DB:UpdateHonorDimensions()
	self.honorBar:SetWidth(self.db.honor.width)
	self.honorBar:SetHeight(self.db.honor.height)
	self.honorBar.statusBar:SetOrientation(self.db.honor.orientation)
	self.honorBar.text:FontTemplate(LSM:Fetch("font", self.db.honor.font), self.db.honor.textSize, self.db.honor.fontOutline)

	if DB.db.honor.orientation == "HORIZONTAL" then
		self.honorBar.statusBar:SetRotatesTexture(false)
	else
		self.honorBar.statusBar:SetRotatesTexture(true)
	end

	if self.db.honor.mouseover then
		self.honorBar:SetAlpha(0)
	else
		self.honorBar:SetAlpha(1)
	end
end

function DB:EnableDisable_HonorBar()
	if self.db.honor.enable then
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateHonor")
		self:RegisterEvent("UNIT_FACTION", "UpdateHonor")
		self:UpdateHonor()
		E:EnableMover(self.honorBar.mover:GetName())
	else
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("UNIT_FACTION")
		self.honorBar:Hide()
		E:DisableMover(self.honorBar.mover:GetName())
	end
end

function DB:LoadHonorBar()
	self.honorBar = self:CreateBar("ElvUI_HonorBar", self.HonorBar_OnEnter, self.HonorBar_OnClick, "RIGHT", self.repBar, "LEFT", E.Border - E.Spacing*3, 0)
	self.honorBar.statusBar:SetStatusBarColor(240/255, 114/255, 65/255)
	self.honorBar.statusBar:SetMinMaxValues(0, 325)

	self.honorBar.eventFrame = CreateFrame("Frame")
	self.honorBar.eventFrame:Hide()
	self.honorBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.honorBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.honorBar.eventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	self.honorBar.eventFrame:SetScript("OnEvent", function(_, event, unit) self:UpdateHonor(event, unit) end)

	self:UpdateHonorDimensions()
	E:CreateMover(self.honorBar, "HonorBarMover", PVP_TAB_SERVICES, nil, nil, nil, nil, nil, "databars,honor")

	self:EnableDisable_HonorBar()
end

hooksecurefunc(DB, "Initialize", function()
	DB:LoadHonorBar()
end)

-- Temp
function DB:OnLeave()
	if (self == ElvUI_ExperienceBar and DB.db.experience.mouseover) or (self == ElvUI_ReputationBar and DB.db.reputation.mouseover) or (self == ElvUI_HonorBar and DB.db.honor.mouseover) then
		E:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
	end
	GameTooltip:Hide()
end