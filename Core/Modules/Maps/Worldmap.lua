local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('WorldMap')

local _G = _G
local find = string.find

local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local GetCursorPosition = GetCursorPosition
local GetPlayerMapPosition = GetPlayerMapPosition
local GetUnitSpeed = GetUnitSpeed

local MOUSE_LABEL = MOUSE_LABEL
local PLAYER = PLAYER
local WORLDMAP_SETTINGS = WORLDMAP_SETTINGS

local INVERTED_POINTS = {
	['TOPLEFT'] = 'BOTTOMLEFT',
	['TOPRIGHT'] = 'BOTTOMRIGHT',
	['BOTTOMLEFT'] = 'TOPLEFT',
	['BOTTOMRIGHT'] = 'TOPRIGHT',
	['TOP'] = 'BOTTOM',
	['BOTTOM'] = 'TOP'
}

local function BlobFrameHide()
	M.blobWasVisible = nil
end

local function BlobFrameShow()
	M.blobWasVisible = true
end

function M:PLAYER_REGEN_ENABLED()
	_G.WorldMapBlobFrame.SetFrameLevel = nil
	_G.WorldMapBlobFrame.SetScale = nil
	_G.WorldMapBlobFrame.Hide = nil
	_G.WorldMapBlobFrame.Show = nil

	_G.WorldMapBlobFrame:SetParent(WorldMapFrame)
	_G.WorldMapBlobFrame:ClearAllPoints()
	_G.WorldMapBlobFrame:SetPoint('TOPLEFT', _G.WorldMapDetailFrame)
	_G.WorldMapBlobFrame:SetScale(M.blobNewScale or WORLDMAP_SETTINGS.size)
	_G.WorldMapBlobFrame:OffsetFrameLevel(1, _G.WorldMapDetailFrame)
	_G.WorldMapBlobFrame:OffsetFrameLevel(1, _G.WorldMapDetailFrame)	-- called twice to set frame level above the default limit (256)

	if M.blobWasVisible then
		_G.WorldMapBlobFrame:Show()
	end

	if WORLDMAP_SETTINGS.selectedQuest then
		_G.WorldMapBlobFrame:DrawQuestBlob(WORLDMAP_SETTINGS.selectedQuest.questId, false)
	end

	if M.blobWasVisible then
		_G.WorldMapBlobFrame_CalculateHitTranslations()

		if WORLDMAP_SETTINGS.selectedQuest and not WORLDMAP_SETTINGS.selectedQuest.completed then
			_G.WorldMapBlobFrame:DrawQuestBlob(WORLDMAP_SETTINGS.selectedQuest.questId, true)
		end
	end
end

function M:PLAYER_REGEN_DISABLED()
	M.blobWasVisible = _G.WorldMapFrame:IsShown() and _G.WorldMapBlobFrame:IsShown()

	_G.WorldMapBlobFrame:SetParent(nil)
	_G.WorldMapBlobFrame:ClearAllPoints()
	_G.WorldMapBlobFrame:SetPoint('TOP', UIParent, 'BOTTOM')
	_G.WorldMapBlobFrame:Hide()
	_G.WorldMapBlobFrame.Hide = BlobFrameHide
	_G.WorldMapBlobFrame.Show = BlobFrameShow
	_G.WorldMapBlobFrame.SetFrameLevel = E.noop
	_G.WorldMapBlobFrame.SetScale = E.noop

	M.blobNewScale = nil
end

function M:UpdateCoords(elapsed)
	M.coordTimer = (M.coordTimer or 0) + elapsed
	if M.coordTimer < 0.03333 then return end
	M.coordTimer = 0

	local x, y = GetPlayerMapPosition('player')

	local playerCoords = M.coordsHolder.playerCoords
	local mouseCoords = M.coordsHolder.mouseCoords

	if playerCoords.x ~= x or playerCoords.y ~= y then
		if x ~= 0 or y ~= 0 then
			playerCoords.x = x
			playerCoords.y = y
			playerCoords:SetFormattedText('%s:   %.2f, %.2f', PLAYER, x * 100, y * 100)
		else
			playerCoords.x = nil
			playerCoords.y = nil
			playerCoords:SetFormattedText('%s:   %s', PLAYER, 'N/A')
		end
	end

	if _G.WorldMapDetailFrame:IsMouseOver() then
		local curX, curY = GetCursorPosition()

		if mouseCoords.x ~= curX or mouseCoords.y ~= curY then
			local scale = _G.WorldMapDetailFrame:GetEffectiveScale()
			local width, height = _G.WorldMapDetailFrame:GetSize()
			local centerX, centerY = _G.WorldMapDetailFrame:GetCenter()
			local adjustedX = (curX / scale - (centerX - (width * 0.5))) / width
			local adjustedY = (centerY + (height * 0.5) - curY / scale) / height

			if adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1 then
				mouseCoords.x = curX
				mouseCoords.y = curY
				mouseCoords:SetFormattedText('%s:  %.2f, %.2f', MOUSE_LABEL, adjustedX * 100, adjustedY * 100)
			else
				mouseCoords.x = nil
				mouseCoords.y = nil
				mouseCoords:SetText('')
			end
		end
	elseif mouseCoords.x then
		mouseCoords.x = nil
		mouseCoords.y = nil
		mouseCoords:SetText('')
	end
end

function M:PositionCoords()
	if not M.coordsHolder then return end

	local db = E.global.general.WorldMapCoordinates
	local position = db.position

	local x = find(position, 'RIGHT') and -5 or 5
	local y = find(position, 'TOP') and -5 or 5

	M.coordsHolder.playerCoords:ClearAllPoints()
	M.coordsHolder.playerCoords:Point(position, _G.WorldMapDetailFrame, position, x + db.xOffset, y + db.yOffset)

	M.coordsHolder.mouseCoords:ClearAllPoints()
	M.coordsHolder.mouseCoords:Point(position, M.coordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function M:ToggleMapFramerate()
	if WORLDMAP_SETTINGS.size == _G.WORLDMAP_FULLMAP_SIZE or WORLDMAP_SETTINGS.size == _G.WORLDMAP_QUESTLIST_SIZE then
		_G.WorldMapFrame:SetAttribute('UIPanelLayout-area', 'center')
		_G.WorldMapFrame:SetAttribute('UIPanelLayout-allowOtherPanels', true)

		_G.WorldMapFrame:SetScale(1)
	end
end

function M:CheckMovement()
	if not _G.WorldMapFrame:IsShown() then return end

	if GetUnitSpeed('player') ~= 0 and not _G.WorldMapPositioningGuide:IsMouseOver() then
		E:UIFrameFadeOut(_G.WorldMapFrame, 0.3, _G.WorldMapFrame:GetAlpha(), E.global.general.mapAlphaWhenMoving)
		_G.WorldMapBlobFrame:SetFillAlpha(128 * E.global.general.mapAlphaWhenMoving)
		_G.WorldMapBlobFrame:SetBorderAlpha(192 * E.global.general.mapAlphaWhenMoving)
	else
		E:UIFrameFadeIn(_G.WorldMapFrame, 0.3, _G.WorldMapFrame:GetAlpha(), 1)
		_G.WorldMapBlobFrame:SetFillAlpha(128)
		_G.WorldMapBlobFrame:SetBorderAlpha(192)
	end
end

function M:UpdateMapAlpha()
	if (not E.global.general.fadeMapWhenMoving or E.global.general.mapAlphaWhenMoving >= 1) and M.MovingTimer then
		M:CancelTimer(M.MovingTimer)
		M.MovingTimer = nil

		_G.WorldMapFrame:SetAlpha(1)
		_G.WorldMapBlobFrame:SetFillAlpha(128)
		_G.WorldMapBlobFrame:SetBorderAlpha(192)
	elseif E.global.general.fadeMapWhenMoving and E.global.general.mapAlphaWhenMoving < 1 and not M.MovingTimer then
		M.MovingTimer = M:ScheduleRepeatingTimer('CheckMovement', 0.2)
	end
end

function M:Initialize()
	M.Initialized = true

	if not E.private.worldmap.enable then return end

	M:UpdateMapAlpha()

	if E.global.general.WorldMapCoordinates.enable then
		local coordsHolder = CreateFrame('Frame', 'ElvUI_CoordsHolder', _G.WorldMapFrame)
		coordsHolder:SetFrameLevel(_G.WORLDMAP_POI_FRAMELEVEL + 100)
		coordsHolder:SetFrameStrata(_G.WorldMapDetailFrame:GetFrameStrata())

		coordsHolder.playerCoords = coordsHolder:CreateFontString(nil, 'OVERLAY')
		coordsHolder.playerCoords:SetTextColor(1, 1, 0)
		coordsHolder.playerCoords:SetFontObject(NumberFontNormal)
		coordsHolder.playerCoords:SetPoint('BOTTOMLEFT', _G.WorldMapDetailFrame, 'BOTTOMLEFT', 5, 5)
		coordsHolder.playerCoords:SetFormattedText('%s:   0, 0', PLAYER)

		coordsHolder.mouseCoords = coordsHolder:CreateFontString(nil, 'OVERLAY')
		coordsHolder.mouseCoords:SetTextColor(1, 1, 0)
		coordsHolder.mouseCoords:SetFontObject(NumberFontNormal)
		coordsHolder.mouseCoords:SetPoint('BOTTOMLEFT', coordsHolder.playerCoords, 'TOPLEFT', 0, 5)

		coordsHolder:SetScript('OnUpdate', M.UpdateCoords)

		M.coordsHolder = coordsHolder
		M:PositionCoords()
	end

	if E.global.general.smallerWorldMap or (E.private.skins.blizzard.enable and E.private.skins.blizzard.worldmap) then
		M:RegisterEvent('PLAYER_REGEN_ENABLED')
		M:RegisterEvent('PLAYER_REGEN_DISABLED')
	end

	_G.WorldMapFrame:EnableMouse(false)
	_G.WorldMapFrame.EnableMouse = E.noop

	if E.global.general.smallerWorldMap then
		_G.BlackoutWorld:SetTexture(nil)

		_G.WorldMapFrame:SetParent(E.UIParent)
		_G.WorldMapFrame.SetParent = E.noop

		_G.WorldMapFrame:EnableKeyboard(false)
		_G.WorldMapFrame.EnableKeyboard = E.noop

		if not GetCVarBool('miniWorldMap') then
			ShowUIPanel(_G.WorldMapFrame)
			M:ToggleMapFramerate()
			HideUIPanel(_G.WorldMapFrame)
		end

		M:SecureHook('ToggleMapFramerate')

		hooksecurefunc(_G.WorldMapDetailFrame, 'SetScale', function(_, scale)
			M.blobNewScale = scale
		end)

		_G.DropDownList1:HookScript('OnShow', function(self)
			if self:GetScale() ~= E.uiscale then
				self:SetScale(E.uiscale)
			end
		end)

		M:RawHook('WorldMapQuestPOI_OnLeave', function()
			_G.WorldMapPOIFrame.allowBlobTooltip = true
			_G.WorldMapTooltip:Hide()
		end, true)
	end
end

E:RegisterModule(M:GetName())