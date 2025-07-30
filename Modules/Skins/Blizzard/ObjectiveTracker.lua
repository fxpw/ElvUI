local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown

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

local function HotkeyShow(self)
	local item = self:GetParent()
	if item.rangeOverlay then item.rangeOverlay:Show() end
end
local function HotkeyHide(self)
	local item = self:GetParent()
	if item.rangeOverlay then item.rangeOverlay:Hide() end
end
local function HotkeyColor(self, r, g, b)
	local item = self:GetParent()
	if item.rangeOverlay then
		if r == 0.6 and g == 0.6 and b == 0.6 then
			item.rangeOverlay:SetVertexColor(0, 0, 0, 0)
		else
			item.rangeOverlay:SetVertexColor(.8, .1, .1, .5)
		end
	end
end

local function SkinItemButton(item)
	item:SetTemplate('Transparent')
	item:StyleButton()
	item:SetNormalTexture(E.ClearTexture)

	item.icon:SetTexCoord(unpack(E.TexCoords))
	item.icon:SetInside()

	item.Cooldown:SetInside()
	item.Count:ClearAllPoints()
	item.Count:Point('TOPLEFT', 1, -1)
	item.Count:FontTemplate(nil, 14, 'OUTLINE')
	item.Count:SetShadowOffset(5, -5)

	local rangeOverlay = item:CreateTexture(nil, 'OVERLAY')
	rangeOverlay:SetTexture(E.Media.Textures.White8x8)
	rangeOverlay:SetInside()
	item.rangeOverlay = rangeOverlay

	hooksecurefunc(item.HotKey, 'Show', HotkeyShow)
	hooksecurefunc(item.HotKey, 'Hide', HotkeyHide)
	hooksecurefunc(item.HotKey, 'SetVertexColor', HotkeyColor)
	HotkeyColor(item.HotKey, item.HotKey:GetTextColor())
	item.HotKey:SetAlpha(0)

	E:RegisterCooldown(item.Cooldown)
end

local function HandleItemButton(_, block)
	if InCombatLockdown() then return end -- will break quest item button
	if not block then return end
	local item = block.itemButton or block.ItemButton
	if not item then return end
	if not item.skinned then
		SkinItemButton(item)
		item.skinned = true
	end

	if item.backdrop then
		item.backdrop:SetFrameLevel(3)
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

		hooksecurefunc(tracker, 'AddBlock', HandleItemButton)
		hooksecurefunc(tracker, 'GetProgressBar', HandleProgressBar)
		hooksecurefunc(tracker, 'GetTimerBar', HandleTimers)
	end
end

S:AddCallback('Blizzard_ObjectiveTracker', S.Blizzard_ObjectiveTracker)

