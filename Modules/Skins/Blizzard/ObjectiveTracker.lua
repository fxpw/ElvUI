local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local trackers = {
	_G.QuestObjectiveTracker,
	_G.AchievementObjectiveTracker,
	_G.BattlePassQuestTracker,
  _G.ProfessionsRecipeTracker,
}

local function SkinOjectiveTrackerHeaders(header)
	if header and header.Background then
		header.Background:SetTexture(nil)
	end
end

local function ReskinQuestIcon(button)
	if not button then return end

	if not button.IsSkinned then
		button:SetSize(24, 24)
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
			S:HandleIcon(icon, true)

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

function S:Blizzard_ObjectiveTracker()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.objectiveTracker) then return end

	local TrackerFrame = _G.ObjectiveTrackerFrame
	local TrackerHeader = TrackerFrame and TrackerFrame.Header
	if TrackerHeader then
		SkinOjectiveTrackerHeaders(TrackerHeader)

		local MinimizeButton = TrackerHeader.MinimizeButton
		local FilterButton = TrackerHeader.FilterButton
		if FilterButton then
			FilterButton:Size(16)
			FilterButton:SetHighlightAtlas('UI-QuestTrackerButton-Yellow-Highlight', 'ADD')
			local normalTexture = FilterButton:GetNormalTexture()
			local pushedTexture = FilterButton:GetPushedTexture()
			normalTexture:SetBlendMode("ADD")
			normalTexture:SetAtlas('Map-Filter-Button', true)
			normalTexture:SetVertexColor(0.86, 0.94, 1)
			pushedTexture:SetBlendMode("ADD")
			pushedTexture:SetAtlas('Map-Filter-Button-down', true)
		end
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
end

S:AddCallback('Blizzard_ObjectiveTracker', S.Blizzard_ObjectiveTracker)

