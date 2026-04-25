local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Minimap')
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local _G = _G
local mod, floor = mod, math.floor
local next = next
local sort = sort
local ipairs = ipairs
local unpack = unpack
local tinsert = tinsert
local hooksecurefunc = hooksecurefunc
local utf8sub = string.utf8sub

local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local GetTime = GetTime
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown
local PlaySound = PlaySound
local ShowUIPanel = ShowUIPanel
local ToggleFrame = ToggleFrame
local UIParent = UIParent
local EasyMenu = EasyMenu

local MainMenuMicroButton_SetNormal = MainMenuMicroButton_SetNormal

local WorldMapFrame = _G.WorldMapFrame
local MinimapCluster = _G.MinimapCluster
local Minimap = _G.Minimap

local IconParents = {}

--Create the minimap micro menu
local menuFrame = CreateFrame('Frame', 'MinimapRightClickMenu', E.UIParent, 'UIDropDownMenuTemplate')
local menuList = {
	{ text = _G.CHARACTER_BUTTON, microOffset = 'CharacterMicroButton', func = function() _G.ToggleCharacter('PaperDollFrame') end },
	{ text = _G.SPELLBOOK_ABILITIES_BUTTON, microOffset = 'SpellbookMicroButton', func = function() ToggleFrame(_G.SpellBookFrame) end },
	{ text = _G.TIMEMANAGER_TITLE, func = _G.ToggleTimeManager, icon = [[Interface\ICONS\INV_Misc_PocketWatch_01]], cropIcon = 2 },
	{ text = _G.CHAT_CHANNELS, func = function() _G.ToggleFriendsFrame(4) end, icon = [[Interface\ICONS\UI_Chat]], cropIcon = 1 },
	{ text = _G.SOCIAL_BUTTON, func = function() _G.ToggleFriendsFrame(1) end, icon = [[Interface\FriendsFrame\PlusManz-PlusManz]], cropIcon = 10 },
	{ text = _G.TALENTS_BUTTON, microOffset = 'TalentMicroButton', func = _G.ToggleTalentFrame },
	{ text = _G.GUILD, microOffset = 'SocialsMicroButton', func = function() _G.ToggleFriendsFrame(3) end },
	{ text = _G.ACHIEVEMENT_BUTTON, microOffset = 'AchievementMicroButton', func = _G.ToggleAchievementFrame, icon = E.Media.Textures.GoldCoins },
	{ text = _G.LFG_TITLE, microOffset = 'LFDMicroButton', func = function() ToggleFrame(_G.LFDParentFrame) end },
	{ text = L["Calendar"], func = function() _G.GameTimeFrame:Click() end, icon = [[Interface\Calendar\MeetingIcon]], cropIcon = 1 },
	{ text = _G.BATTLEFIELD_MINIMAP, func = _G.ToggleBattlefieldMinimap, icon = [[Interface\ICONS\Inv_Misc_Map_01]], cropIcon = 1 },
	{ text = _G.LOOKING_FOR_RAID, func = function() ToggleFrame(_G.LFRParentFrame) end, icon = [[Interface\LFGFrame\LFGIcon-Raid]], cropIcon = 1 },
	{ text = _G.QUEST_LOG, microOffset = 'QuestLogMicroButton', func = function() ToggleFrame(_G.QuestLogFrame) end },
}

if E.mylevel >= _G.SHOW_PVP_LEVEL then
	tinsert(menuList, { text = _G.PLAYER_V_PLAYER, microOffset = 'PVPMicroButton', func = function() _G.TogglePVPFrame() end })
end

if _G.GetNumCompanions('MOUNT') > 0 or _G.GetNumCompanions('CRITTER') > 0 then
	tinsert(menuList, { text = _G.MOUNTS..' & '.._G.COMPANIONS, func = function() _G.ToggleCharacter('PetPaperDollFrame') end, icon = [[Interface\ICONS\ability_mount_ridinghorse]], cropIcon = 2 })
end

sort(menuList, function(a, b) if a and b and a.text and b.text then return a.text < b.text end end)

tinsert(menuList, {
	text = _G.MAINMENU_BUTTON,
	microOffset = 'MainMenuMicroButton',
	func = function()
		if not _G.GameMenuFrame:IsShown() then
			if _G.VideoOptionsFrame:IsShown() then
				_G.VideoOptionsFrameCancel:Click()
			elseif _G.AudioOptionsFrame:IsShown() then
				_G.AudioOptionsFrameCancel:Click()
			elseif _G.InterfaceOptionsFrame:IsShown() then
				_G.InterfaceOptionsFrameCancel:Click()
			end

			CloseMenus()
			CloseAllWindows()
			PlaySound(850) -- IG_MAINMENU_OPEN
			ShowUIPanel(_G.GameMenuFrame)
		else
			PlaySound(854) -- IG_MAINMENU_QUIT
			HideUIPanel(_G.GameMenuFrame)

			MainMenuMicroButton_SetNormal()
		end
	end
})

tinsert(menuList, { text = _G.HELP_BUTTON, microOffset = 'HelpMicroButton', bottom = true, func = function() _G.ToggleHelpFrame() end, icon = [[Interface\HelpFrame\OpenTicketIcon]], cropIcon = 8 })

M.RightClickMenu = menuFrame
M.RightClickMenuList = menuList

function M:SetScale(frame, scale)
	frame:SetScale(scale)
end

function M:HandleTrackingButton()
	local tracking = _G.MiniMapTracking
	if not tracking then return end

	M:SaveIconParent(tracking)

	tracking:ClearAllPoints()

	local hidden = not Minimap:IsShown()
	if hidden or E.private.general.minimap.hideTracking then
		tracking:Point('TOP', UIParent, 'BOTTOM') -- retail cant hide the parent otherwise the menu will error
	else
		local scale, position, xOffset, yOffset = M:GetIconSettings('tracking')

		tracking:Point(position, Minimap, xOffset, yOffset)
		M:SetScale(tracking, scale)

		if _G.MiniMapTrackingButtonBorder then
			_G.MiniMapTrackingButtonBorder:Hide()
		end

		if _G.MiniMapTrackingBorder then
			_G.MiniMapTrackingBorder:Hide()
		end

		if _G.MiniMapTrackingBackground then
			_G.MiniMapTrackingBackground:Hide()
		end

		if _G.MiniMapTrackingIcon then
			_G.MiniMapTrackingIcon:SetDrawLayer('ARTWORK')
			_G.MiniMapTrackingIcon:SetTexCoords()
			_G.MiniMapTrackingIcon:SetInside()
		end
	end
end

function M:HideNonInstancePanels()
	if InCombatLockdown() or not WorldMapFrame:IsShown() then return end

	HideUIPanel(WorldMapFrame)
end

function M:ADDON_LOADED(event, addon)
	if addon == 'Blizzard_TimeManager' then
		M:UnregisterEvent(event)
		_G.TimeManagerClockButton:Kill()
	end
end

function M:CreateMinimapTrackingDropdown()
	local dropdown = CreateFrame('Frame', 'ElvUIMiniMapTrackingDropDown', UIParent, 'UIDropDownMenuTemplate')
	dropdown:SetID(1)
	dropdown:SetClampedToScreen(true)
	dropdown:Hide()

	_G.UIDropDownMenu_Initialize(dropdown, _G.MiniMapTrackingDropDown_Initialize, 'MENU')
	dropdown.noResize = true

	return dropdown
end

function M:MinimapTracking_UpdateTracking()
	if _G.UIDROPDOWNMENU_OPEN_MENU == M.TrackingDropdown then
		_G.UIDropDownMenu_Refresh(M.TrackingDropdown)
	end
end

function M:Minimap_OnShow()
	M:UpdateIcons()
end

function M:Minimap_OnHide()
	M:UpdateIcons()
end

function M:Minimap_OnEnter()
	M:Minimap_EnterLeave(self, true)
end

function M:Minimap_OnLeave()
	M:Minimap_EnterLeave(self)
end

function M:Minimap_EnterLeave(minimap, show)
	if M.db.locationText == 'MOUSEOVER' and M.db.clusterDisable then
		minimap.location:SetShown(show)
	end
end

function M:Minimap_OnMouseDown(btn)
	menuFrame:Hide()

	local position = M.MapHolder.mover:GetPoint()
	if btn == 'MiddleButton' or (btn == 'RightButton' and IsShiftKeyDown()) then
		if not E:AlertCombat() then
			EasyMenu(menuList, menuFrame, 'cursor', position:match('LEFT') and 0 or -160, 0, 'MENU')
			menuFrame:Show()

			PlaySound('UChatScrollButton')
		end
	elseif btn == 'RightButton' then
		local button = _G.MiniMapTrackingButton
		if button then
			button:Click()

			local menu = M.TrackingDropdown
			if menu and E.private.general.minimap.hideTracking then
				_G.ToggleDropDownMenu(1, nil, menu, 'cursor')
			end
		end
	else
		_G.Minimap_OnClick(self)
	end
end

function M:Minimap_OnMouseWheel(d)
	local zoomIn = _G.MinimapZoomIn
	local zoomOut = _G.MinimapZoomOut

	if d > 0 then
		zoomIn:Click()
	elseif d < 0 then
		zoomOut:Click()
	end
end

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == 'arena' then
		return 0.84, 0.03, 0.03
	elseif pvpType == 'friendly' then
		return 0.05, 0.85, 0.03
	elseif pvpType == 'contested' then
		return 0.9, 0.85, 0.05
	elseif pvpType == 'hostile' then
		return 0.84, 0.03, 0.03
	elseif pvpType == 'sanctuary' then
		return 0.035, 0.58, 0.84
	elseif pvpType == 'combat' then
		return 0.84, 0.03, 0.03
	else
		return 0.9, 0.85, 0.05
	end
end

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == 'HIDE' then return end

	Minimap.location:SetText(utf8sub(GetMinimapZoneText(), 1, 46))
	Minimap.location:SetTextColor(M:GetLocTextColor())
end

do
	local isResetting
	local function ResetZoom()
		Minimap:SetZoom(0)

		local zoomIn = _G.MinimapZoomIn
		local zoomOut = _G.MinimapZoomOut

		zoomIn:Enable() -- Reset enabled state of buttons
		zoomOut:Disable()

		isResetting = false
	end

	local function SetupZoomReset()
		if E.db.general.minimap.resetZoom.enable and not isResetting then
			isResetting = true

			E:Delay(M.db.resetZoom.time, ResetZoom)
		end
	end

	hooksecurefunc(Minimap, 'SetZoom', SetupZoomReset)
end

function M:GetIconSettings(button)
	local defaults = P.general.minimap.icons[button]
	local profile = M.db.icons[button]

	return profile.scale or defaults.scale, profile.position or defaults.position, profile.xOffset or defaults.xOffset, profile.yOffset or defaults.yOffset
end

function M:SaveIconParent(frame)
	if not IconParents[frame] then -- only want the first one
		IconParents[frame] = frame:GetParent()
	end
end

function M:SetIconParent(frame)
	local parent = IconParents[frame]
	if parent then -- this is unlikely
		frame:SetParent(parent)
	end
end

function M:HandleDifficulty(difficulty, cluster, hidden)
	if not difficulty then return end

	if cluster then
		difficulty:ClearAllPoints()
		difficulty:SetPoint('TOPRIGHT', MinimapCluster, 0, -25)
		M:SetIconParent(difficulty)
		M:SetScale(difficulty, 1)
	elseif hidden then
		difficulty:SetParent(E.HiddenFrame)
	else
		local scale, position, xOffset, yOffset = M:GetIconSettings('difficulty')
		difficulty:ClearAllPoints()
		difficulty:Point(position, Minimap, xOffset, yOffset)
		M:SetIconParent(difficulty)
		M:SetScale(difficulty, scale)
	end
end

function M:UpdateIcons()
	local gameTime = _G.GameTimeFrame
	local mailFrame = _G.MiniMapMailFrame
	local difficulty = _G.MiniMapInstanceDifficulty
	local battlefieldFrame = _G.MiniMapBattlefieldFrame
	local lfgFrame = _G.MiniMapLFGFrame

	if not next(IconParents) then
		if gameTime then M:SaveIconParent(gameTime) end
		if mailFrame then M:SaveIconParent(mailFrame) end
		if battlefieldFrame then M:SaveIconParent(battlefieldFrame) end
		if difficulty then M:SaveIconParent(difficulty) end
		if lfgFrame then M:SaveIconParent(lfgFrame) end
	end

	local noCluster = E.db.general.minimap.clusterDisable
	if not noCluster then
		if M.ClusterHolder then
			E:EnableMover(M.ClusterHolder.mover.name)
		end

		if difficulty then M:HandleDifficulty(difficulty, true) end

		if gameTime then M:SetIconParent(gameTime) end
		if mailFrame then M:SetIconParent(mailFrame) end
		if battlefieldFrame then M:SetIconParent(battlefieldFrame) end
	else
		if M.ClusterHolder then
			E:DisableMover(M.ClusterHolder.mover.name)
		end

		M.HandleTrackingButton()

		local hidden = not Minimap:IsShown()
		if gameTime then
			if hidden or E.private.general.minimap.hideCalendar then
				gameTime:SetParent(E.HiddenFrame)
			else
				local scale, position, xOffset, yOffset = M:GetIconSettings('calendar')
				gameTime:ClearAllPoints()
				gameTime:Point(position, Minimap, xOffset, yOffset)
				gameTime:SetParent(Minimap)
				gameTime:OffsetFrameLevel(2, _G.MinimapBackdrop)
				M:SetIconParent(gameTime)
				M:SetScale(gameTime, scale)
			end
		end

		if mailFrame then
			if hidden then
				mailFrame:SetParent(E.HiddenFrame)
			else
				local scale, position, xOffset, yOffset = M:GetIconSettings('mail')
				mailFrame:ClearAllPoints()
				mailFrame:Point(position, Minimap, xOffset, yOffset)
				M:SetIconParent(mailFrame)
				M:SetScale(mailFrame, scale)
			end
		end

		if battlefieldFrame then
			if hidden then
				battlefieldFrame:SetParent(E.HiddenFrame)
			else
				local scale, position, xOffset, yOffset = M:GetIconSettings('battlefield')
				battlefieldFrame:ClearAllPoints()
				battlefieldFrame:Point(position, Minimap, xOffset, yOffset)
				M:SetIconParent(battlefieldFrame)
				M:SetScale(battlefieldFrame, scale)
			end

			if _G.BattlegroundShine then _G.BattlegroundShine:Hide() end
			if _G.MiniMapBattlefieldBorder then _G.MiniMapBattlefieldBorder:Hide() end
			if _G.MiniMapBattlefieldIcon then _G.MiniMapBattlefieldIcon:SetTexCoords() end
		end

		if difficulty then
			M:HandleDifficulty(difficulty, false, hidden)
		end

		if lfgFrame then
			if hidden then
				lfgFrame:SetParent(E.HiddenFrame)
			else
				local scale, position, xOffset, yOffset = M:GetIconSettings('lfgEye')
				lfgFrame:ClearAllPoints()
				lfgFrame:Point(position, Minimap, xOffset, yOffset)
				M:SetIconParent(lfgFrame)
				M:SetScale(lfgFrame, scale)
			end
		end
	end
end

function M:UpdateSettings()
	if not M.Initialized then return end

	local noCluster = M.db.clusterDisable
	E.MinimapSize = M.db.size or Minimap:GetWidth()

	-- handle the icons placed around the minimap (also the cluster)
	M:UpdateIcons()

	local panel, holder = _G.MinimapPanel, M.MapHolder
	panel:SetShown(E.db.datatexts.panels.MinimapPanel.enable)

	local mmOffset = E.PixelMode and 1 or 3
	local mmScale = M.db.scale
	Minimap:ClearAllPoints()
	Minimap:Point('TOPRIGHT', holder, -mmOffset / mmScale, -mmOffset / mmScale)
	Minimap:Size(E.MinimapSize)

	local mWidth, mHeight = Minimap:GetSize()
	local bWidth, bHeight = E:Scale(E.PixelMode and 2 or 6), E:Scale(E.PixelMode and 2 or 8)
	local panelSize, joinPanel = (panel:IsShown() and panel:GetHeight()) or E:Scale(E.PixelMode and 1 or -1), E:Scale(1)
	local HEIGHT, WIDTH = (mHeight * mmScale) + (panelSize - joinPanel), mWidth * mmScale
	holder:SetSize(WIDTH + bWidth, HEIGHT + bHeight)

	local locationFont, locaitonSize, locationOutline = LSM:Fetch('font', M.db.locationFont), M.db.locationFontSize, M.db.locationFontOutline
	if Minimap.location then
		Minimap.location:Width(E.MinimapSize)
		Minimap.location:FontTemplate(locationFont, locaitonSize, locationOutline)
		Minimap.location:SetShown(M.db.locationText == 'SHOW' and noCluster)
	end

	local classicBorder = _G.MinimapBorder
	local compassBorder = _G.MinimapCompassTexture
	if classicBorder then
		classicBorder:ClearAllPoints()
		classicBorder:SetPoint('TOPRIGHT', Minimap, 0, 0)
		classicBorder:SetTexCoord(0.165, 0.945, 0.125, 0.90)

		if compassBorder then
			compassBorder:SetAlpha(0)
		end
	end

	local compass = classicBorder or compassBorder
	if M.db.circle then
		Minimap.backdrop:Hide()

		if compass then
			compass:Show()

			if not classicBorder then
				compass:Size(M.db.size, M.db.size * 1.05)
			else
				compass:Size(M.db.size)
			end
		end
	else
		Minimap.backdrop:Show()

		if compass then
			compass:Hide()

			if not classicBorder then
				compass:Size(215, 226)
			else
				compass:Size(192, 192)
			end
		end
	end

	if _G.MiniMapMailIcon then
		_G.MiniMapMailIcon:SetTexture(E.Media.MailIcons[M.db.icons.mail.texture] or E.Media.MailIcons.Mail3)
		_G.MiniMapMailIcon:Size(20)
	end

	MinimapCluster:SetScale(mmScale)

	local mcWidth = MinimapCluster:GetWidth()
	local height, width = 20 * mmScale, (mcWidth - 30) * mmScale
	M.ClusterHolder:SetSize(width, height)
	M.ClusterBackdrop:SetSize(width, height)
	M.ClusterBackdrop:SetShown(M.db.clusterBackdrop and not noCluster)

	_G.MinimapZoneText:FontTemplate(locationFont, locaitonSize, locationOutline)

	if _G.TimeManagerClockTicker then
		_G.TimeManagerClockTicker:FontTemplate(LSM:Fetch('font', E.db.general.minimap.timeFont), E.db.general.minimap.timeFontSize, E.db.general.minimap.timeFontOutline)
	end

	if noCluster then
		_G.MinimapZoneTextButton:Kill()
		if _G.TimeManagerClockButton then
			_G.TimeManagerClockButton:Kill()
		else
			M:RegisterEvent('ADDON_LOADED')
		end
	else
		_G.MinimapZoneTextButton.Show = nil
		_G.MinimapZoneTextButton:SetParent(MinimapCluster)
		_G.MinimapZoneTextButton:RegisterEvent('UPDATE_BINDINGS')
		_G.MinimapZoneTextButton:Show()

		if _G.TimeManagerClockButton then
			_G.TimeManagerClockButton.Show = nil
			_G.TimeManagerClockButton:SetParent(MinimapCluster)
			_G.TimeManagerClockButton:Show()
		else
			M:RegisterEvent('ADDON_LOADED')
		end
	end
end

function M:Minimap_PostDrag()
	_G.MinimapBackdrop:ClearAllPoints()
	_G.MinimapBackdrop:SetAllPoints(Minimap)
end

function M:ClusterSize(width, height)
	local holder = M.ClusterHolder
	if holder and (width ~= holder.savedWidth or height ~= holder.savedHeight) then
		self:SetSize(holder.savedWidth, holder.savedHeight)
	end
end

function M:ClusterPoint(_, anchor)
	local noCluster = M.db.clusterDisable
	local frame = (noCluster and UIParent) or M.ClusterHolder

	if anchor ~= frame then
		MinimapCluster:ClearAllPoints()
		MinimapCluster:Point('TOPRIGHT', frame, 0, noCluster and 0 or 1)
	end
end

function M:ContainerScale(scale)
	if scale ~= 1 then
		self:SetScale(1)
	end
end

function M:SetMinimapMask(square)
	if square then
		Minimap:SetMaskTexture([[interface\chatframe\chatframebackground]])
	else
		Minimap:SetMaskTexture([[textures\minimapmask]])
	end
end

function M:SetMinimapRotate()
	E:SetCVar('rotateMinimap', M.db.rotate and 1 or 0)
end

function M:PLAYER_ENTERING_WORLD()
	local LFGIconBorder = _G.MiniMapLFGFrameBorder or _G.MiniMapLFGFrame
	if LFGIconBorder then
		LFGIconBorder:Hide()
	end

	M:SetMinimapRotate()

	M:Update_ZoneText()
end

function M:GetMinimapShape()
	return (M.db.circle and 'ROUND') or 'SQUARE'
end

function M:SetGetMinimapShape()
	GetMinimapShape = M.GetMinimapShape

	if M.db.size then
		Minimap:Size(M.db.size)
	end
end

function M:Initialize()
	if not E.private.general.minimap.enable then
		M:SetMinimapMask(false)

		return
	end

	M.Initialized = true

	for _, menu in ipairs(menuList) do
		menu.notCheckable = true

		if menu.microOffset then
			local left, right, top, bottom = AB:GetMicroCoords(menu.microOffset, true)
			menu.tCoordLeft, menu.tCoordRight, menu.tCoordTop, menu.tCoordBottom = left, right, top, bottom
			menu.icon = menu.microOffset == 'PVPMicroButton' and ((E.myfaction == 'Horde' and E.Media.Textures.PVPHorde) or E.Media.Textures.PVPAlliance) or E.Media.Textures.MicroBar
			menu.microOffset = nil
		elseif menu.cropIcon then
			local left = 0.02 * menu.cropIcon
			local right = 1 - left
			menu.tCoordLeft, menu.tCoordRight, menu.tCoordTop, menu.tCoordBottom = left, right, left, right
			menu.cropIcon = nil
		end
	end

	menuFrame:SetTemplate('Transparent')

	local mapHolder = CreateFrame('Frame', 'ElvUI_MinimapHolder', Minimap)
	mapHolder:Point('TOPRIGHT', E.UIParent, -3, -3)
	mapHolder:Size(Minimap:GetSize())
	E:CreateMover(mapHolder, 'MinimapMover', L["Minimap"], nil, nil, M.Minimap_PostDrag, nil, nil, 'maps,minimap')
	M.MapHolder = mapHolder
	M:SetScale(mapHolder, 1)

	local clusterHolder = CreateFrame('Frame', 'ElvUI_MinimapClusterHolder', MinimapCluster)
	clusterHolder.savedWidth, clusterHolder.savedHeight = MinimapCluster:GetSize()
	clusterHolder:Point('TOPRIGHT', E.UIParent, -3, -3)
	clusterHolder:SetSize(clusterHolder.savedWidth, clusterHolder.savedHeight)
	clusterHolder:SetFrameLevel(10) -- over minimap mover
	E:CreateMover(clusterHolder, 'MinimapClusterMover', L["Minimap Cluster"], nil, nil, nil, nil, nil, 'maps,minimap')
	M.ClusterHolder = clusterHolder

	local clusterBackdrop = CreateFrame('Frame', 'ElvUI_MinimapClusterBackdrop', MinimapCluster)
	clusterBackdrop:Point('TOPRIGHT', 0, -1)
	clusterBackdrop:SetTemplate()
	M:SetScale(clusterBackdrop, 1)
	M.ClusterBackdrop = clusterBackdrop

	M:ClusterPoint()
	MinimapCluster:EnableMouse(false)
	MinimapCluster:SetFrameLevel(20) -- set before minimap itself
	hooksecurefunc(MinimapCluster, 'SetPoint', M.ClusterPoint)
	hooksecurefunc(MinimapCluster, 'SetSize', M.ClusterSize)

	Minimap:EnableMouseWheel(true)
	Minimap:SetFrameLevel(10)
	Minimap:SetFrameStrata('LOW')
	Minimap:CreateBackdrop()

	if Minimap.backdrop then -- level to hybrid maps fixed values
		Minimap.backdrop:SetFrameLevel(99)
		Minimap.backdrop:SetFrameStrata('BACKGROUND')
		M:SetScale(Minimap.backdrop, 1)
	end

	Minimap.location = Minimap:CreateFontString(nil, 'OVERLAY')
	Minimap.location:Point('TOP', Minimap, 0, -2)
	Minimap.location:SetJustifyH('CENTER')
	Minimap.location:SetJustifyV('MIDDLE')
	Minimap.location:Hide()
	M:SetMinimapMask(not M.db.circle)

	M:RegisterEvent('PLAYER_ENTERING_WORLD')
	M:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Update_ZoneText')
	M:RegisterEvent('ZONE_CHANGED_INDOORS', 'Update_ZoneText')
	M:RegisterEvent('ZONE_CHANGED', 'Update_ZoneText')

	Minimap:SetScript('OnMouseWheel', M.Minimap_OnMouseWheel)
	Minimap:SetScript('OnMouseDown', M.Minimap_OnMouseDown)
	Minimap:SetScript('OnMouseUp', E.noop)

	Minimap:HookScript('OnShow', M.Minimap_OnShow)
	Minimap:HookScript('OnHide', M.Minimap_OnHide)

	Minimap:HookScript('OnEnter', M.Minimap_OnEnter)
	Minimap:HookScript('OnLeave', M.Minimap_OnLeave)

	local killFrames = {
		_G.MinimapBorder,
		_G.MinimapBorderTop,
		_G.MinimapCompassTexture,
		_G.MiniMapMailBorder,
		_G.MinimapNorthTag,
		_G.MiniMapWorldMapButton,
		_G.MinimapZoneTextButton,
		_G.MinimapZoomIn,
		_G.MinimapZoomOut,
	}

	M:RegisterEvent('MINIMAP_UPDATE_TRACKING', M.MinimapTracking_UpdateTracking)

	--Create the new minimap tracking dropdown frame and initialize it
	M.TrackingDropdown = M:CreateMinimapTrackingDropdown()

	if _G.TimeManagerClockButton then
		tinsert(killFrames, _G.TimeManagerClockButton)
	end

	for _, frame in next, killFrames do
		frame:Kill()
	end

	M:RegisterEvent('ADDON_LOADED')
	M:UpdateSettings()
end

E:RegisterModule(M:GetName())
