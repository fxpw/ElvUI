-- local E, L = unpack(select(2, ...)); --Import: Engine, Locales
-- local B = E:GetModule("Blizzard")
-- -- local S = E:GetModule("Skins")
-- --Lua functions
-- local min = math.min
-- --WoW API / Variables
-- local GetScreenHeight = GetScreenHeight

-- -- local hideRule =
-- -- "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists]"

-- function B:SetObjectiveFrameAutoHide()
-- 	-- if not WatchFrame then return end
-- 	-- if E.db.general.watchFrameAutoHide then
-- 	-- 	RegisterStateDriver(WatchFrame, "visibility", hideRule)
-- 	-- else
-- 	-- 	UnregisterStateDriver(WatchFrame, "visibility")
-- 	-- end
-- end

-- function B:SetWatchFrameHeight()
-- 	local top = ObjectiveTrackerFrame:GetTop() or 0
-- 	local screenHeight = GetScreenHeight()
-- 	local gapFromTop = screenHeight - top
-- 	local maxHeight = screenHeight - gapFromTop
-- 	local watchFrameHeight = min(maxHeight, E.db.general.watchFrameHeight)

-- 	ObjectiveTrackerFrame:Height(watchFrameHeight)
-- 	ObjectiveTrackerFrameScrollFrame:Height(watchFrameHeight)
-- end

-- function B:MoveWatchFrame()
-- 	InterfaceOptionsObjectivesPanelTrackerFontSize:Hide()
-- 	InterfaceOptionsObjectivesPanelTrackerOpacity:Hide()
-- 	InterfaceOptionsObjectivesPanelTrackerHeight:Hide()
-- 	InterfaceOptionsObjectivesPanelTrackerResetPosition:Hide()
-- 	InterfaceOptionsObjectivesPanelTrackerToggleSelection:Hide()
-- 	-- TODO ALPHA PARAMS IN CONFIG
-- 	InterfaceOptionsObjectivesPanelTrackerHeaderAlpha:Hide()
-- 	InterfaceOptionsObjectivesPanelTrackerStyle:Hide()
-- 	local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
-- 	local w, _ = ObjectiveTrackerFrame:GetSize()
-- 	WatchFrameHolder:Size(w, E.db.general.watchFrameHeight)
-- 	WatchFrameHolder:Point("TOPRIGHT", -135, -300)
-- 	E:CreateMover(WatchFrameHolder, "WatchFrameMover", L["Objective Frame"], nil, nil, nil, nil, nil,
-- 		"general,objectiveFrameGroup")
-- 	WatchFrameHolder:SetAllPoints(WatchFrameMover)
-- 	ObjectiveTrackerFrameHeader:StripTextures()
-- 	ObjectiveTrackerFrameScrollFrameScrollBar:Hide()

-- 	C_Timer:After(1, function()
-- 		ObjectiveTrackerFrame:ClearAllPoints()
-- 		ObjectiveTrackerFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
-- 		B:SetWatchFrameHeight()
-- 		local normalTexture = ObjectiveTrackerFrameHeader.MinimizeButton:GetNormalTexture();
-- 		local pushedTexture = ObjectiveTrackerFrameHeader.MinimizeButton:GetPushedTexture();

-- 		if ObjectiveTrackerFrame.isCollapsed then
-- 			normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand", true);
-- 			pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand-Pressed", true);
-- 		else
-- 			normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse", true);
-- 			pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse-Pressed", true);
-- 		end
-- 	end)
-- 	hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(_, _, parent)
-- 		if parent ~= WatchFrameHolder then
-- 			ObjectiveTrackerFrame:ClearAllPoints()
-- 			ObjectiveTrackerFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
-- 		end
-- 	end)
-- 	ObjectiveTrackerFrameScrollFrameScrollBar:Hide()
-- 	hooksecurefunc(ObjectiveTrackerFrameScrollFrameScrollBar, "Show", function(frame)
-- 		frame:Hide()
-- 	end)
-- 	-- QuestObjectiveTrackerHeaderFilterButton.NormalTexture:SetAtlas("UI-QuestTrackerButton-Filter", true)
-- 	-- QuestObjectiveTrackerHeaderFilterButton.NormalTexture:SetAtlas("UI-QuestTrackerButton-Filter", true)
-- 	-- QuestObjectiveTrackerHeaderFilterButton.PushedTexture:SetAtlas("UI-QuestTrackerButton-Filter-Pressed", true)
-- 	ObjectiveTrackerFrameHeaderFilterButton:StripTextures()
-- 	ObjectiveTrackerFrameHeaderFilterButton.NormalTexture:SetBlendMode("ADD")
-- 	ObjectiveTrackerFrameHeaderFilterButton.PushedTexture:SetBlendMode("ADD")
-- 	ObjectiveTrackerFrameHeaderFilterButton.NormalTexture:SetAtlas("Map-Filter-Button",true)
-- 	ObjectiveTrackerFrameHeaderFilterButton.NormalTexture:SetVertexColor(0.86, 0.94, 1)
-- 	ObjectiveTrackerFrameHeaderFilterButton.PushedTexture:SetAtlas("Map-Filter-Button-down")

-- 	hooksecurefunc(ObjectiveTrackerFrameHeader, "SetCollapsed", function(frame, collapse)
-- 		local normalTexture = frame.MinimizeButton:GetNormalTexture();
-- 		local pushedTexture = frame.MinimizeButton:GetPushedTexture();
-- 		if collapse then
-- 			normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand", true);
-- 			pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand-Pressed", true);
-- 		else
-- 			normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse", true);
-- 			pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse-Pressed", true);
-- 		end

-- 	end)



-- 	self:SetObjectiveFrameAutoHide()
-- end



local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')
local B = E:GetModule("Blizzard")
local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local trackers = {
	-- _G.ScenarioObjectiveTracker,
	-- _G.UIWidgetObjectiveTracker,
	-- _G.CampaignQuestObjectiveTracker,
	_G.QuestObjectiveTracker,
	-- _G.AdventureObjectiveTracker,
	_G.AchievementObjectiveTracker,
	-- _G.MonthlyActivitiesObjectiveTracker,
	_G.ProfessionsRecipeTracker,
	-- _G.BonusObjectiveTracker,
	_G.BattlePassQuestTracker,
}

local function SkinOjectiveTrackerHeaders(header)
	if header and header.Background then
		header.Background:StripTextures()
	end
end

local function ReskinQuestIcon(button)
	if not button then return end

	if not button.IsSkinned then
		button:SetSize(24, 24)
		-- button:SetNormalTexture(nil)
		-- button:SetPushedTexture(nil)
		-- button:SetHighlightTexture(nil)
		S:HandleButton(button)

		local icon = button.icon or button.Icon
		if icon then
			S:HandleIcon(icon)
			icon:SetInside(button)
		end

		button.IsSkinned = true
	end

	if button.backdrop then
		button.backdrop:SetFrameLevel(0)
	end
end

local function HandleQuestIcons(_, block)
	ReskinQuestIcon(block.ItemButton)
	ReskinQuestIcon(block.itemButton)

	local check = block.currentLine and block.currentLine.Check
	if check and not check.IsSkinned then
		check:SetAtlas('checkmark-minimal')
		check:SetDesaturated(true)
		check:SetVertexColor(0, 1, 0)

		check.styled = true
	end
end

local function ReskinBarTemplate(bar)
	if bar.backdrop then return end

	bar:StripTextures()
	bar:CreateBackdrop('Transparent')
	bar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(bar)
end

local function HandleProgressBar(tracker, key)
	local progressBar = tracker.usedProgressBars[key]
	local bar = progressBar and progressBar.Bar

	if bar then
		ReskinBarTemplate(bar)

		local _, maxValue = bar:GetMinMaxValues()
		S:StatusBarColorGradient(bar, bar:GetValue(), maxValue)

		local icon = bar.Icon
		if icon and icon:IsShown() and not icon.backdrop then
			icon:SetMask('') -- This needs to be before S:HandleIcon
			S:HandleIcon(icon)

			icon:ClearAllPoints()
			icon:Point('LEFT', bar, 'RIGHT', E.PixelMode and 3 or 7, 0)
		end

		local label = bar.Label
		if label then
			label:ClearAllPoints()
			label:Point('CENTER', bar)
			label:FontTemplate(nil, E.db.general.fontSize, E.db.general.fontStyle)
		end
	end
end

local function HandleTimers(tracker, key)
	local timerBar = tracker.usedTimerBars[key]
	local bar = timerBar and timerBar.Bar

	if bar then
		ReskinBarTemplate(bar)
	end
end

local function SetCollapsed(header, collapsed)
	local MinimizeButton = header.MinimizeButton
	local normalTexture = MinimizeButton:GetNormalTexture()
	local pushedTexture = MinimizeButton:GetPushedTexture()

	if collapsed then
		normalTexture:SetAtlas('UI-QuestTrackerButton-Secondary-Expand', true)
		pushedTexture:SetAtlas('UI-QuestTrackerButton-Secondary-Expand-Pressed', true)
	else
		normalTexture:SetAtlas('UI-QuestTrackerButton-Secondary-Collapse', true)
		pushedTexture:SetAtlas('UI-QuestTrackerButton-Secondary-Collapse-Pressed', true)
	end
end

function B:SetWatchFrameHeight()
	local top = ObjectiveTrackerFrame:GetTop() or 0
	local screenHeight = GetScreenHeight()
	local gapFromTop = screenHeight - top
	local maxHeight = screenHeight - gapFromTop
	local watchFrameHeight = min(maxHeight, E.db.general.watchFrameHeight)

	ObjectiveTrackerFrame:Height(watchFrameHeight)
	ObjectiveTrackerFrameScrollFrame:Height(watchFrameHeight)
end

function B:Blizzard_ObjectiveTracker()
	-- if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.watchframe or not WatchFrame then return end
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.watchframe) then return end
	InterfaceOptionsObjectivesPanelTrackerFontSize:Hide()
	InterfaceOptionsObjectivesPanelTrackerOpacity:Hide()
	InterfaceOptionsObjectivesPanelTrackerHeight:Hide()
	InterfaceOptionsObjectivesPanelTrackerResetPosition:Hide()
	InterfaceOptionsObjectivesPanelTrackerToggleSelection:Hide()
	-- TODO ALPHA PARAMS IN CONFIG
	InterfaceOptionsObjectivesPanelTrackerHeaderAlpha:Hide()
	InterfaceOptionsObjectivesPanelTrackerStyle:Hide()


	ObjectiveTrackerFrameHeaderFilterButton:StripTextures()
	ObjectiveTrackerFrameHeaderFilterButton.NormalTexture:SetBlendMode("ADD")
	ObjectiveTrackerFrameHeaderFilterButton.PushedTexture:SetBlendMode("ADD")
	ObjectiveTrackerFrameHeaderFilterButton.NormalTexture:SetAtlas("Map-Filter-Button",true)
	ObjectiveTrackerFrameHeaderFilterButton.NormalTexture:SetVertexColor(0.86, 0.94, 1)
	ObjectiveTrackerFrameHeaderFilterButton.PushedTexture:SetAtlas("Map-Filter-Button-down")
	ObjectiveTrackerFrameScrollFrameScrollBar:Hide()
	hooksecurefunc(ObjectiveTrackerFrameScrollFrameScrollBar, "Show", function(frame)
		frame:Hide()
	end)

	local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
	local w, _ = ObjectiveTrackerFrame:GetSize()
	WatchFrameHolder:Size(w, E.db.general.watchFrameHeight)
	WatchFrameHolder:Point("TOPRIGHT", -135, -300)
	E:CreateMover(WatchFrameHolder, "WatchFrameMover", L["Objective Frame"], nil, nil, nil, nil, nil,
		"general,objectiveFrameGroup")
	WatchFrameHolder:SetAllPoints(WatchFrameMover)


	local TrackerFrame = _G.ObjectiveTrackerFrame
	local TrackerHeader = TrackerFrame and TrackerFrame.Header
	if TrackerHeader then
		SkinOjectiveTrackerHeaders(TrackerHeader)

		local MinimizeButton = TrackerHeader.MinimizeButton
		if MinimizeButton then
			MinimizeButton:Size(16)
			MinimizeButton:SetHighlightAtlas('UI-QuestTrackerButton-Yellow-Highlight', 'ADD')

			SetCollapsed(TrackerHeader, TrackerFrame.isCollapsed)
			hooksecurefunc(TrackerHeader, 'SetCollapsed', SetCollapsed)
		end
	end

	for _, tracker in pairs(trackers) do
		SkinOjectiveTrackerHeaders(tracker.Header)

		hooksecurefunc(tracker, 'AddBlock', HandleQuestIcons)
		hooksecurefunc(tracker, 'GetProgressBar', HandleProgressBar)
		hooksecurefunc(tracker, 'GetTimerBar', HandleTimers)
	end
	B:SetWatchFrameHeight()
end
