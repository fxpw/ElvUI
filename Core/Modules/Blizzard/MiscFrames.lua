local E, L = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local GetLocale = GetLocale
local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit
local hooksecurefunc = hooksecurefunc

local Minimap_SetPing = Minimap_SetPing
local KnowledgeBaseFrame_OnEvent = KnowledgeBaseFrame_OnEvent

local MINIMAPPING_FADE_TIMER = MINIMAPPING_FADE_TIMER

function BL:HandleMiscFrames()
    -- disable the annoying one line popup about the knowledge base being disabled
	KBArticle_BeginLoading = E.noop
	KBSetup_BeginLoading = E.noop
	KnowledgeBaseFrame_OnEvent(nil, 'KNOWLEDGE_BASE_SETUP_LOAD_FAILURE')

	-- fix german abbrevations
	if GetLocale() == 'deDE' then
		DAY_ONELETTER_ABBR = '%d d'
		MINUTE_ONELETTER_ABBR = '%d m'
	end

	-- fix minimap ping
	_G.MinimapPing:HookScript('OnUpdate', function(self)
		if self.fadeOut or self.timer > MINIMAPPING_FADE_TIMER then
			Minimap_SetPing(_G.Minimap:GetPingPosition())
		end
	end)

	-- fix quest log frame level issues
	_G.QuestLogFrame:HookScript('OnShow', function()
		local questFrame = _G.QuestLogFrame:GetFrameLevel()
		local controlPanel = _G.QuestLogControlPanel:GetFrameLevel()
		local scrollFrame = _G.QuestLogDetailScrollFrame:GetFrameLevel()

		if questFrame >= controlPanel then
			_G.QuestLogControlPanel:SetFrameLevel(questFrame + 1)
		end
		if questFrame >= scrollFrame then
			_G.QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
		end
	end)

	-- hide ready check if you are the initiator
	_G.ReadyCheckFrame:HookScript('OnShow', function(self)
		if UnitIsUnit('player', self.initiator) then
			self:Hide()
		end
	end)

	-- durability frame
	_G.DurabilityFrame:SetFrameStrata('HIGH')
	_G.DurabilityFrame:SetScale(0.6)

	_G.DurabilityWeapon:Point('RIGHT', _G.DurabilityWrists, 'LEFT', 6, 0)
	_G.DurabilityShield:Point('LEFT', _G.DurabilityWrists, 'RIGHT', -6, 10)
	_G.DurabilityOffWeapon:Point('LEFT', _G.DurabilityWrists, 'RIGHT', -6, 0)
	_G.DurabilityRanged:Point('TOP', _G.DurabilityShield, 'BOTTOM', -1, 0)

	hooksecurefunc(_G.DurabilityFrame, 'SetPoint', function(self, _, point)
		if point ~= Minimap then
			self:ClearAllPoints()

			if _G.DurabilityShield:IsShown() or _G.DurabilityOffWeapon:IsShown() or _G.DurabilityRanged:IsShown() then
				self:Point('RIGHT', Minimap, 'RIGHT', -7, 0)
			else
				self:Point('RIGHT', Minimap, 'RIGHT', 8, 0)
			end
		end
	end)

	-- kill the ui scale option
	_G.VideoOptionsResolutionPanelUseUIScale:Kill()
	_G.VideoOptionsResolutionPanelUIScaleSlider:Kill()

	-- gm ticket status
	_G.TicketStatusFrame:ClearAllPoints()
	_G.TicketStatusFrame:SetPoint('TOPLEFT', E.UIParent, 'TOPLEFT', 250, -5)

	E:CreateMover(_G.TicketStatusFrame, 'GMMover', L["GM Ticket Frame"])

	-- fix lfr browse frame taint
    local frame = CreateFrame('Frame')
	frame:SetScript('OnUpdate', function()
		if _G.LFRBrowseFrame.timeToClear then
			_G.LFRBrowseFrame.timeToClear = nil
		end
	end)

    -- fix lfd cooldown frame taint
	do
		local originalFunc = LFDQueueFrameRandomCooldownFrame_OnEvent
		local originalScript = _G.LFDQueueFrameCooldownFrame:GetScript('OnEvent')

		LFDQueueFrameRandomCooldownFrame_OnEvent = function(self, event, unit, ...)
			if event == 'UNIT_AURA' and not unit then return end
			originalFunc(self, event, unit, ...)
		end

		if originalFunc == originalScript then
			_G.LFDQueueFrameCooldownFrame:SetScript('OnEvent', LFDQueueFrameRandomCooldownFrame_OnEvent)
		else
			_G.LFDQueueFrameCooldownFrame:SetScript('OnEvent', function(self, event, unit, ...)
				if event == 'UNIT_AURA' and not unit then return end
				originalScript(self, event, unit, ...)
			end)
		end
	end
end