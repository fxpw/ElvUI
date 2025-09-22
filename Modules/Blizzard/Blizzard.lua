local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule("Blizzard")

--Lua functions
--WoW API / Variables
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local GetTradeSkillListLink = GetTradeSkillListLink
local Minimap_SetPing = Minimap_SetPing
local UnitIsUnit = UnitIsUnit
local MINIMAPPING_FADE_TIMER = MINIMAPPING_FADE_TIMER

function B:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TradeSkillUI" then
		TradeSkillLinkButton:SetScript("OnClick", function()
			local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
			if not ChatFrameEditBox:IsShown() then
				ChatEdit_ActivateChat(ChatFrameEditBox)
			end

			ChatFrameEditBox:Insert(GetTradeSkillListLink())
		end)

		self:UnregisterEvent("ADDON_LOADED")
	end
end

function B:ObjectiveTracker_IsCollapsed(frame)
	return frame:GetParent() == E.HiddenFrame
end

function B:ObjectiveTracker_Collapse(frame)
	frame:SetParent(E.HiddenFrame)
end

function B:ObjectiveTracker_Expand(frame)
	frame:SetParent(_G.UIParent)
end

function B:ObjectiveTracker_AutoHideOnShow()
	local tracker = _G.ObjectiveTrackerFrame
	if tracker and B:ObjectiveTracker_IsCollapsed(tracker) then
		B:ObjectiveTracker_Expand(tracker)
	end
end

do
	local AutoHider
	function B:ObjectiveTracker_AutoHide()
		if E.IsAddOnEnabled("BigWigs") or E.IsAddOnEnabled("DBM") then return end

		local tracker = _G.ObjectiveTrackerFrame
		if not tracker then return end

		if not AutoHider then
			AutoHider = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
			AutoHider:SetAttribute('_onstate-objectiveHider', 'if newstate == 1 then self:Hide() else self:Show() end')
			AutoHider:SetScript('OnHide', B.ObjectiveTracker_AutoHideOnHide)
			AutoHider:SetScript('OnShow', B.ObjectiveTracker_AutoHideOnShow)
		end

		if E.db.general.objectiveFrameAutoHide then
			RegisterStateDriver(AutoHider, 'objectiveHider',
				'[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0')
		else
			UnregisterStateDriver(AutoHider, 'objectiveHider')
			B:ObjectiveTracker_AutoHideOnShow() -- reshow it when needed
		end
	end
end

function B:Initialize()
	self.Initialized = true

	self:AlertMovers()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:PositionVehicleFrame()
	self:ObjectiveTracker_Setup()
	self:SocialToast_Setup()

	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", SetMapToCurrentZone)

	KBArticle_BeginLoading = E.noop
	KBSetup_BeginLoading = E.noop
	-- KnowledgeBaseFrame_OnEvent(nil, "KNOWLEDGE_BASE_SETUP_LOAD_FAILURE")

	if GetLocale() == "deDE" then
		DAY_ONELETTER_ABBR = "%d d"
		MINUTE_ONELETTER_ABBR = "%d m"
	end

	-- CreateFrame("Frame"):SetScript("OnUpdate", function()
	-- 	if LFRBrowseFrame.timeToClear then
	-- 		LFRBrowseFrame.timeToClear = nil
	-- 	end
	-- end)

	MinimapPing:HookScript("OnUpdate", function(self)
		if self.fadeOut or self.timer > MINIMAPPING_FADE_TIMER then
			Minimap_SetPing(Minimap:GetPingPosition())
		end
	end)

	local items = {
		["QuestInfoItem"] = MAX_NUM_ITEMS,
		["QuestProgressItem"] = MAX_REQUIRED_ITEMS,
		["QuestRequiredItem"] = MAX_REQUIRED_ITEMS,
	}

	QuestLogFrame:HookScript("OnShow", function()
		local questFrame = QuestLogFrame:GetFrameLevel()
		local controlPanel = QuestLogControlPanel:GetFrameLevel()
		local scrollFrame = QuestLogDetailScrollFrame:GetFrameLevel()

		if questFrame >= controlPanel then
			QuestLogControlPanel:SetFrameLevel(questFrame + 1)
		end
		if questFrame >= scrollFrame then
			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
		end
		local frameLevel = QuestLogFrame:GetFrameLevel()

		if QuestInfoItem1:GetFrameLevel() <= frameLevel or QuestProgressItem1:GetFrameLevel() <= frameLevel then
			for frame, numItems in pairs(items) do
				for i = 1, numItems do
					_G[frame..i]:SetFrameLevel(frameLevel + 5)
				end
			end
		end
	end)

	ReadyCheckFrame:HookScript("OnShow", function(self)
		if UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

--	WORLDMAP_POI_FRAMELEVEL = 300
--	WorldMapFrame:SetToplevel(true)

	do
		local originalFunc = LFDQueueFrameRandomCooldownFrame_OnEvent
		local originalScript = LFDQueueFrameCooldownFrame:GetScript("OnEvent")

		LFDQueueFrameRandomCooldownFrame_OnEvent = function(self, event, unit, ...)
			if event == "UNIT_AURA" and not unit then return end
			originalFunc(self, event, unit, ...)
		end

		if originalFunc == originalScript then
			LFDQueueFrameCooldownFrame:SetScript("OnEvent", LFDQueueFrameRandomCooldownFrame_OnEvent)
		else
			LFDQueueFrameCooldownFrame:SetScript("OnEvent", function(self, event, unit, ...)
				if event == "UNIT_AURA" and not unit then return end
				originalScript(self, event, unit, ...)
			end)
		end
	end
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)