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
end

-- local C_TalkingHead_SetConversationsDeferred = C_TalkingHead.SetConversationsDeferred

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
	local holder = CreateFrame('Frame', 'ObjectiveFrameHolder', E.UIParent)
	holder:Point('TOPRIGHT', E.UIParent, -135, -300)
	holder:Size(130, 22)

	E:CreateMover(holder, 'ObjectiveFrameMover', L["Objective Frame"], nil, nil, nil, nil, nil, 'general,blizzardImprovements')
	holder:SetAllPoints(_G.ObjectiveFrameMover)

	local tracker = _G.ObjectiveTrackerFrame
	tracker:SetMovable(true)
	tracker:SetUserPlaced(true)
	tracker:SetDontSavePosition(true)
	tracker:SetClampedToScreen(false)
	tracker:ClearAllPoints()
	tracker:SetPoint('TOP', holder)

	B:ObjectiveTracker_AutoHide()
	B:ObjectiveTracker_SetHeight()

	tracker.holder = holder
	hooksecurefunc(tracker, 'SetPoint', ObjectiveTracker_SetPoint)
end
