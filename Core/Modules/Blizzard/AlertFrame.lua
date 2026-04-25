local E, L = unpack(ElvUI)
local BL = E:GetModule('Blizzard')
local M = E:GetModule('Misc')

local _G = _G
local CreateFrame = CreateFrame

local POSITION, ANCHOR_POINT, Y_OFFSET, BASE_YOFFSET = 'TOP', 'BOTTOM', -5, 0 -- should match in PostAlertMove

function E:PostAlertMove()
	local AlertFrame = _G.AlertFrame
	local AlertFrameMover = _G.AlertFrameMover

	local _, y = AlertFrameMover:GetCenter()
	local growUp = y < (E.UIParent:GetTop() * 0.5)

	if growUp then
		POSITION, ANCHOR_POINT, Y_OFFSET = 'BOTTOM', 'TOP', 5
	else -- should match above in the cache
		POSITION, ANCHOR_POINT, Y_OFFSET = 'TOP', 'BOTTOM', -5
	end

	AlertFrameMover:SetFormattedText('%s %s', AlertFrameMover.textString, growUp and '(Grow Up)' or '(Grow Down)')

	AlertFrame:ClearAllPoints()
	AlertFrame:SetAllPoints((E.private.general.lootRoll and M:UpdateLootRollAnchors(POSITION)) or _G.AlertFrameHolder)
end

function BL:AchievementAlertFrame_FixAnchors()
	local alertAnchor
	for i = 1, _G.MAX_ACHIEVEMENT_ALERTS do
		local frame = _G['AchievementAlertFrame'..i]
		if frame then
			frame:ClearAllPoints()
			if alertAnchor and alertAnchor:IsShown() then
				frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, Y_OFFSET)
			else
				frame:Point(POSITION, AlertFrame, ANCHOR_POINT)
			end

			alertAnchor = frame
		end
	end
end

function BL:DungeonCompletionAlertFrame_FixAnchors()
	for i = _G.MAX_ACHIEVEMENT_ALERTS, 1, -1 do
		local frame = _G['AchievementAlertFrame'..i]
		if frame and frame:IsShown() then
			DungeonCompletionAlertFrame1:ClearAllPoints()
			DungeonCompletionAlertFrame1:Point(POSITION, frame, ANCHOR_POINT, 0, Y_OFFSET)
			return
		end

		DungeonCompletionAlertFrame1:ClearAllPoints()
		DungeonCompletionAlertFrame1:Point(POSITION, AlertFrame, ANCHOR_POINT)
	end
end

function BL:AlertMovers()
	local AlertFrameHolder = CreateFrame('Frame', 'AlertFrameHolder', E.UIParent)
	AlertFrameHolder:Size(250, 20)
	AlertFrameHolder:Point('TOP', E.UIParent, 'TOP', 0, -20)

	self:SecureHook('AlertFrame_FixAnchors', E.PostAlertMove)
	self:SecureHook('AchievementAlertFrame_FixAnchors')
	self:SecureHook('DungeonCompletionAlertFrame_FixAnchors')

	E:CreateMover(AlertFrameHolder, 'AlertFrameMover', L['Loot / Alert Frames'], nil, nil, E.PostAlertMove, nil, nil, 'general,blizzardImprovements')
end