local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local min = min
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetInstanceInfo = GetInstanceInfo

local function ObjectiveTracker_SetPoint(tracker, _, parent)
	if parent ~= tracker.holder then
		tracker:ClearAllPoints()
		tracker:SetPoint('TOP', tracker.holder)
	end
end

function B:ObjectiveTracker_SetHeight()
	local tracker = _G.ObjectiveTrackerFrame
	local top = tracker:GetTop() or 0
	local gapFromTop = E.screenheight - top
	local maxHeight = E.screenheight - gapFromTop
	local frameHeight = min(maxHeight, E.db.general.objectiveFrameHeight)
	tracker:Height(frameHeight)
	tracker.holder:Height(frameHeight)
	_G.ObjectiveFrameMover:Height(frameHeight)
end

function B:ObjectiveTracker_AutoHideOnHide()
	local tracker = _G.ObjectiveTrackerFrame
	if not tracker or B:ObjectiveTracker_IsCollapsed(tracker) then return end

	if E.db.general.objectiveFrameAutoHideInKeystone then
		B:ObjectiveTracker_Collapse(tracker)
	else
		local _, _, difficultyID = GetInstanceInfo()
		if difficultyID ~= 8 then -- ignore hide in keystone runs
			B:ObjectiveTracker_Collapse(tracker)
		end
	end
end

function B:ObjectiveTracker_Setup()
	ObjectiveTrackerFrameScrollFrameScrollBar:Hide()
	InterfaceOptionsObjectivesPanelTrackerFontSize:Hide()
	InterfaceOptionsObjectivesPanelTrackerOpacity:Hide()
	InterfaceOptionsObjectivesPanelTrackerHeight:Hide()
	InterfaceOptionsObjectivesPanelTrackerResetPosition:Hide()
	InterfaceOptionsObjectivesPanelTrackerToggleSelection:Hide()
	-- TODO ALPHA PARAMS IN CONFIG
	InterfaceOptionsObjectivesPanelTrackerHeaderAlpha:Hide()
	InterfaceOptionsObjectivesPanelTrackerStyle:Hide()
	hooksecurefunc(ObjectiveTrackerFrameScrollFrameScrollBar, "Show", function(frame)
		frame:Hide()
	end)
	local holder = CreateFrame('Frame', 'ObjectiveFrameHolder', E.UIParent)
	holder:Point('TOPRIGHT', E.UIParent, -135, -300)
	local w, _ = ObjectiveTrackerFrame:GetSize()
	holder:Size(w, E.db.general.objectiveFrameHeight)

	E:CreateMover(holder, 'ObjectiveFrameMover', L["Objective Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')
	holder:SetAllPoints(_G.ObjectiveFrameMover)

	local tracker = _G.ObjectiveTrackerFrame
	tracker:SetMovable(true)
	tracker:SetUserPlaced(true)
	tracker:SetDontSavePosition(true)
	tracker:SetClampedToScreen(false)
	tracker:ClearAllPoints()
	tracker:SetPoint('TOP', holder)
	tracker.holder = holder

	hooksecurefunc(tracker, 'SetPoint', ObjectiveTracker_SetPoint)
	tracker.UpdateHeight = E.noop

	B:ObjectiveTracker_AutoHide()
	B:ObjectiveTracker_SetHeight()
end

local function SocialToast_SetPoint(tracker, _, parent)
	if parent ~= tracker.holder then
		tracker:ClearAllPoints()
		tracker:SetPoint('TOP', tracker.holder)
	end
end

function B:SocialToast_Setup()
	InterfaceOptionsNotificationPanelResetPosition:Hide()
	InterfaceOptionsNotificationPanelToggleMove:Hide()

	local holder = CreateFrame('Frame', 'SocialToastHolder', E.UIParent)
	holder:Point('TOPRIGHT', E.UIParent, -135, -300)
	local w, h = SocialToastAnchorFrame:GetSize()
	holder:Size(w, h)

	E:CreateMover(holder, 'SocialToastMover', L["SocialToast Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')
	holder:SetAllPoints(_G.SocialToastMover)

	local tracker = _G.SocialToastAnchorFrame
	tracker:SetMovable(true)
	tracker:SetUserPlaced(true)
	tracker:SetDontSavePosition(true)
	tracker:SetClampedToScreen(false)
	tracker:ClearAllPoints()
	tracker:SetPoint('TOP', holder)
	tracker.holder = holder

	hooksecurefunc(tracker, 'SetPoint', SocialToast_SetPoint)
	-- tracker.UpdateHeight = E.noop

	-- B:ObjectiveTracker_AutoHide()
	-- B:ObjectiveTracker_SetHeight()
end
