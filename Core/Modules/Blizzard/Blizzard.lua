local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local next = next

local UIParent = UIParent
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local CreateFrame = CreateFrame
local GetRewardXP = GetRewardXP
local GetQuestLogRewardXP = GetQuestLogRewardXP
local IsAddOnLoaded = IsAddOnLoaded
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver

local GetTradeSkillListLink = GetTradeSkillListLink
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatEdit_ActivateChat = ChatEdit_ActivateChat

local function PostMove(mover)
	local x, y = mover:GetCenter()
	local top = E.UIParent:GetTop()
	local right = E.UIParent:GetRight()

	local point
	if y > (top*0.5) then
		point = (x > (right*0.5)) and 'TOPRIGHT' or 'TOPLEFT'
	else
		point = (x > (right*0.5)) and 'BOTTOMRIGHT' or 'BOTTOMLEFT'
	end
	mover.anchorPoint = point

	mover.parent:ClearAllPoints()
	mover.parent:Point(point, mover)
end

function BL:RepositionFrame(frame, _, anchor)
	if anchor ~= frame.mover then
		frame:ClearAllPoints()
		frame:Point(frame.mover.anchorPoint or 'TOPLEFT', frame.mover, frame.mover.anchorPoint or 'TOPLEFT')
	end
end

function BL:QuestXPPercent()
	if not E.db.general.questXPPercent then return end

	local unitXP, unitXPMax = UnitXP('player'), UnitXPMax('player')
	local xp = GetRewardXP() or GetQuestLogRewardXP()
	if xp and xp > 0 then
		local text = _G.QuestInfoXPFrameReceiveText:GetText()
		if text then _G.QuestInfoXPFrameReceiveText:SetFormattedText('%s (|cff4beb2c+%.2f%%|r)', text, (((unitXP + xp) / unitXPMax) - (unitXP / unitXPMax))*100) end
	end
end

function BL:ObjectiveTracker_HasQuestTracker()
	return E.OtherAddons.KalielsTracker or E.OtherAddons.DugisGuideViewerZ
end

function BL:ObjectiveTracker_IsCollapsed(frame)
	return frame:GetParent() == E.HiddenFrame
end

function BL:ObjectiveTracker_Collapse(frame)
	frame:SetParent(E.HiddenFrame)
end

function BL:ObjectiveTracker_Expand(frame)
	frame:SetParent(_G.UIParent)
end

function BL:ObjectiveTracker_AutoHideOnShow()
	local tracker = (E.Mists and _G.WatchFrame) or _G.ObjectiveTrackerFrame
	if tracker and BL:ObjectiveTracker_IsCollapsed(tracker) then
		BL:ObjectiveTracker_Expand(tracker)
	end
end

do
	local AutoHider
	function BL:ObjectiveTracker_AutoHide()
		if E.OtherAddons.BigWigs or E.OtherAddons.DBM then return end

		local tracker = _G.WatchFrame
		if not tracker then return end

		if not AutoHider then
			AutoHider = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
			AutoHider:SetAttribute('_onstate-objectiveHider', 'if newstate == 1 then self:Hide() else self:Show() end')
			AutoHider:SetScript('OnHide', BL.ObjectiveTracker_AutoHideOnHide)
			AutoHider:SetScript('OnShow', BL.ObjectiveTracker_AutoHideOnShow)
		end

		if E.db.general.objectiveFrameAutoHide then
			RegisterStateDriver(AutoHider, 'objectiveHider', '[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0')
		else
			UnregisterStateDriver(AutoHider, 'objectiveHider')
			BL:ObjectiveTracker_AutoHideOnShow() -- reshow it when needed
		end
	end
end

function BL:ADDON_LOADED(_, addon)
	if addon == 'Blizzard_GuildBankUI' then
		BL:ImproveGuildBank()
	elseif addon == 'Blizzard_TradeSkillUI' then
		_G.TradeSkillLinkButton:SetScript('OnClick', function()
			local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
			if not ChatFrameEditBox:IsShown() then
				ChatEdit_ActivateChat(ChatFrameEditBox)
			end

			ChatFrameEditBox:Insert(GetTradeSkillListLink())
		end)

		BL:UnregisterEvent('ADDON_LOADED')
	elseif BL.TryDisableTutorials then
		BL:ShutdownTutorials()
	end
end

function BL:Initialize()
	BL.Initialized = true

	BL:EnhanceColorPicker()
	BL:AlertMovers()
	BL:HandleMiscFrames()
	BL:PositionCaptureBar()

	BL:RegisterEvent('ADDON_LOADED')

	BL:PositionVehicleFrame()

	if not BL:ObjectiveTracker_HasQuestTracker() then
		BL:ObjectiveTracker_Setup()
	end

	for _, addon in next, { 'Blizzard_GuildBankUI', 'Blizzard_TradeSkillUI' } do
		if IsAddOnLoaded(addon) then
			BL:ADDON_LOADED(nil, addon)
		end
	end

	local MinimapAnchor = _G.ElvUI_MinimapHolder or _G.Minimap
	do -- Battle.Net Frame
		_G.BNToastFrame:ClearAllPoints()
		_G.BNToastFrame:Point('TOPRIGHT', MinimapAnchor, 'BOTTOMRIGHT', 0, -10)
		E:CreateMover(_G.BNToastFrame, 'BNETMover', L["BNet Frame"], nil, nil, PostMove)
		_G.BNToastFrame.mover:Size(_G.BNToastFrame:GetSize())
		BL:SecureHook(_G.BNToastFrame, 'SetPoint', 'RepositionFrame')
	end
end

E:RegisterModule(BL:GetName())