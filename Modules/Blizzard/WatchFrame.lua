local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")
local S = E:GetModule("Skins")
--Lua functions
local min = math.min
--WoW API / Variables
local GetScreenHeight = GetScreenHeight

local hideRule =
"[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists]"

function B:SetObjectiveFrameAutoHide()
	-- if not WatchFrame then return end
	-- if E.db.general.watchFrameAutoHide then
	-- 	RegisterStateDriver(WatchFrame, "visibility", hideRule)
	-- else
	-- 	UnregisterStateDriver(WatchFrame, "visibility")
	-- end
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

function B:MoveWatchFrame()
	InterfaceOptionsObjectivesPanelTrackerFontSize:Hide()
	InterfaceOptionsObjectivesPanelTrackerOpacity:Hide()
	InterfaceOptionsObjectivesPanelTrackerHeight:Hide()
	InterfaceOptionsObjectivesPanelTrackerResetPosition:Hide()
	InterfaceOptionsObjectivesPanelTrackerToggleSelection:Hide()
	local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
	local w, h = ObjectiveTrackerFrame:GetSize()
	WatchFrameHolder:Size(w, E.db.general.watchFrameHeight)
	WatchFrameHolder:Point("TOPRIGHT", -135, -300)
	E:CreateMover(WatchFrameHolder, "WatchFrameMover", L["Objective Frame"], nil, nil, nil, nil, nil,
		"general,objectiveFrameGroup")
	WatchFrameHolder:SetAllPoints(WatchFrameMover)
	ObjectiveTrackerFrameHeader:StripTextures()
	ObjectiveTrackerFrameScrollFrameScrollBar:Hide()

	C_Timer:After(1, function()
		ObjectiveTrackerFrame:ClearAllPoints()
		ObjectiveTrackerFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
		B:SetWatchFrameHeight()
		local normalTexture = ObjectiveTrackerFrameHeader.MinimizeButton:GetNormalTexture();
		local pushedTexture = ObjectiveTrackerFrameHeader.MinimizeButton:GetPushedTexture();

		if ObjectiveTrackerFrame.isCollapsed then
			normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand-Pressed", true);
		else
			normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse-Pressed", true);
		end
	end)
	hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(_, _, parent)
		if parent ~= WatchFrameHolder then
			ObjectiveTrackerFrame:ClearAllPoints()
			ObjectiveTrackerFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
		end
	end)
	hooksecurefunc(ObjectiveTrackerFrameScrollFrameScrollBar, "Show", function(frame)
		frame:Hide()
	end)

	hooksecurefunc(ObjectiveTrackerFrameHeader, "SetCollapsed", function(frame, collapse)
		local normalTexture = frame.MinimizeButton:GetNormalTexture();
		local pushedTexture = frame.MinimizeButton:GetPushedTexture();
		if collapse then
			normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Expand-Pressed", true);
		else
			normalTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Secondary-Collapse-Pressed", true);
		end

	end)



	self:SetObjectiveFrameAutoHide()
end