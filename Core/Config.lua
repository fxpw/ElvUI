local E, L, V, P, G = unpack(select(2, ...)); -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local type, ipairs, tonumber = type, ipairs, tonumber
local floor, select = floor, select
local max, min = max, min
--WoW API / Variables
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local InCombatLockdown = InCombatLockdown
local EditBox_ClearFocus = EditBox_ClearFocus
local RESET = RESET

local selectedValue, grid = "ALL"
local statusTextHooked = {}

E.ConfigModeLayouts = {
	"ALL",
	"GENERAL",
	"SOLO",
	"PARTY",
	"ARENA",
	"RAID",
	"ACTIONBARS"
}

E.ConfigModeLocalizedStrings = {
	ALL = ALL,
	GENERAL = GENERAL,
	SOLO = SOLO,
	PARTY = PARTY,
	ARENA = ARENA,
	RAID = RAID,
	ACTIONBARS = ACTIONBARS_LABEL
}

function E:Grid_Show()
	if not grid then
		E:Grid_Create()
	elseif grid.boxSize ~= E.db.gridSize then
		grid:Hide()
		E:Grid_Create()
	else
		grid:Show()
	end
end

function E:Grid_Hide()
	if grid then
		grid:Hide()
	end
end

function E:ToggleMoveMode(override, configType)
	if InCombatLockdown() then return end
	if override ~= nil and override ~= "" then E.ConfigurationMode = override end

	if E.ConfigurationMode ~= true then
		E:Grid_Show()

		if not ElvUIMoverPopupWindow then
			E:CreateMoverPopup()
		end

		ElvUIMoverPopupWindow:Show()

		if IsAddOnLoaded("ElvUI_OptionsUI") then
			if E.Libs.AceConfigDialog then
				E.Libs.AceConfigDialog:Close("ElvUI")
			end

			GameTooltip:Hide()
		end

		E.ConfigurationMode = true
	else
		E:Grid_Hide()

		if ElvUIMoverPopupWindow then
			ElvUIMoverPopupWindow:Hide()
		end

		E.ConfigurationMode = false
	end

	if type(configType) ~= "string" then
		configType = nil
	end

	self:ToggleMovers(E.ConfigurationMode, configType or "ALL")
end

function E:Grid_GetRegion()
	if grid then
		if grid.regionCount and grid.regionCount > 0 then
			local line = select(grid.regionCount, grid:GetRegions())
			grid.regionCount = grid.regionCount - 1
			line:SetAlpha(1)
			return line
		else
			return grid:CreateTexture()
		end
	end
end

function E:Grid_Create()
	if not grid then
		grid = CreateFrame("Frame", "ElvUIGrid", E.UIParent)
		grid:SetFrameStrata("BACKGROUND")
	else
		grid.regionCount = 0
		local numRegions = grid:GetNumRegions()
		for i = 1, numRegions do
			local region = select(i, grid:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				grid.regionCount = grid.regionCount + 1
				region:SetAlpha(0)
			end
		end
	end

	local size = E.mult
	local width, height = E.UIParent:GetSize()

	local ratio = width / height
	local hStepheight = height * ratio
	local wStep = width / E.db.gridSize
	local hStep = hStepheight / E.db.gridSize

	grid.boxSize = E.db.gridSize
	grid:SetPoint("CENTER", E.UIParent)
	grid:SetSize(width, height)
	grid:Show()

	for i = 0, E.db.gridSize do
		local tx = E:Grid_GetRegion()
		if i == E.db.gridSize / 2 then
			tx:SetTexture(1, 0, 0)
			tx:SetDrawLayer("BORDER")
		else
			tx:SetTexture(0, 0, 0)
			tx:SetDrawLayer("BACKGROUND")
		end
		tx:ClearAllPoints()
		tx:Point("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0)
		tx:Point("BOTTOMRIGHT", grid, "BOTTOMLEFT", i*wStep + (size/2), 0)
	end

	do
		local tx = E:Grid_GetRegion()
		tx:SetTexture(1, 0, 0)
		tx:SetDrawLayer("BORDER")
		tx:ClearAllPoints()
		tx:Point("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
		tx:Point("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2 + size/2))
	end

	for i = 1, floor((height/2)/hStep) do
		local tx = E:Grid_GetRegion()
		tx:SetTexture(0, 0, 0)
		tx:SetDrawLayer("BACKGROUND")
		tx:ClearAllPoints()
		tx:Point("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
		tx:Point("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2+i*hStep + size/2))

		tx = E:Grid_GetRegion()
		tx:SetTexture(0, 0, 0)
		tx:SetDrawLayer("BACKGROUND")
		tx:ClearAllPoints()
		tx:Point("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
		tx:Point("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2-i*hStep + size/2))
	end
end

local function ConfigMode_OnClick(self)
	selectedValue = self.value
	E:ToggleMoveMode(false, self.value)
	UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, self.value)
end

local function ConfigMode_Initialize()
	local info = _G.UIDropDownMenu_CreateInfo()
	info.func = ConfigMode_OnClick

	for _, configMode in ipairs(E.ConfigModeLayouts) do
		info.text = E.ConfigModeLocalizedStrings[configMode]
		info.value = configMode
		UIDropDownMenu_AddButton(info)
	end

	UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, selectedValue)
end

function E:NudgeMover(nudgeX, nudgeY)
	local mover = ElvUIMoverNudgeWindow.child
	local x, y, point = E:CalculateMoverPoints(mover, nudgeX, nudgeY)

	mover:ClearAllPoints()
	mover:Point(mover.positionOverride or point, E.UIParent, mover.positionOverride and "BOTTOMLEFT" or point, x, y)
	E:SaveMoverPosition(mover.name)

	--Update coordinates in Nudge Window
	E:UpdateNudgeFrame(mover, x, y)
end

function E:UpdateNudgeFrame(mover, x, y)
	if not (x and y) then
		x, y = E:CalculateMoverPoints(mover)
	end

	x = E:Round(x, 0)
	y = E:Round(y, 0)

	local ElvUIMoverNudgeWindow = ElvUIMoverNudgeWindow
	ElvUIMoverNudgeWindow.xOffset:SetText(x)
	ElvUIMoverNudgeWindow.yOffset:SetText(y)
	ElvUIMoverNudgeWindow.xOffset.currentValue = x
	ElvUIMoverNudgeWindow.yOffset.currentValue = y
	ElvUIMoverNudgeWindow.title:SetText(mover.textString)
end

function E:AssignFrameToNudge()
	ElvUIMoverNudgeWindow.child = self
	E:UpdateNudgeFrame(self)
end

function E:CreateMoverPopup()
	local f = CreateFrame("Frame", "ElvUIMoverPopupWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetFrameLevel(99)
	f:SetClampedToScreen(true)
	f:Width(360)
	f:Height(195)
	f:SetTemplate("Transparent")
	f:Point("BOTTOM", UIParent, "CENTER", 0, 100)
	f:SetScript("OnHide", function()
		if ElvUIMoverPopupWindowDropDown then
			UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, "ALL")
		end
	end)
	f:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	f:CreateShadow(5)
	f:Hide()

	local header = CreateFrame("Button", nil, f)
	header:SetTemplate(nil, true)
	header:Width(100)
	header:Height(25)
	header:Point("CENTER", f, "TOP")
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:EnableMouse(true)
	header:RegisterForClicks("AnyUp", "AnyDown")
	header:SetScript("OnMouseDown", function() f:StartMoving() end)
	header:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)
	header:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:Point("CENTER", header, "CENTER")
	title:SetText("ElvUI")

	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:Point("TOPLEFT", 18, -32)
	desc:Point("BOTTOMRIGHT", -18, 48)
	desc:SetText(L["DESC_MOVERCONFIG"])

	local snapping = CreateFrame("CheckButton", f:GetName().."CheckButton", f, "OptionsCheckButtonTemplate")
	_G[snapping:GetName().."Text"]:SetText(L["Sticky Frames"])

	snapping:SetScript("OnShow", function(cb)
		cb:SetChecked(E.db.general.stickyFrames)
	end)

	snapping:SetScript("OnClick", function(cb)
		E.db.general.stickyFrames = cb:GetChecked()
	end)

	local lock = CreateFrame("Button", f:GetName().."CloseButton", f, "OptionsButtonTemplate")
	_G[lock:GetName().."Text"]:SetText(L["Lock"])

	lock:SetScript("OnClick", function()
		E:ToggleMoveMode(true)

		if IsAddOnLoaded("ElvUI_OptionsUI") and E.Libs.AceConfigDialog then
			E.Libs.AceConfigDialog:Open("ElvUI")
		end

		selectedValue = "ALL"
		UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, selectedValue)
	end)

	local align = CreateFrame("EditBox", f:GetName().."EditBox", f, "InputBoxTemplate")
	align:Width(24)
	align:Height(17)
	align:SetAutoFocus(false)
	align:SetScript("OnEscapePressed", function(eb)
		eb:SetText(E.db.gridSize)
		EditBox_ClearFocus(eb)
	end)
	align:SetScript("OnEnterPressed", function(eb)
		local text = eb:GetText()
		if tonumber(text) then
			if tonumber(text) <= 256 and tonumber(text) >= 4 then
				E.db.gridSize = tonumber(text)
			else
				eb:SetText(E.db.gridSize)
			end
		else
			eb:SetText(E.db.gridSize)
		end
		E:Grid_Show()
		EditBox_ClearFocus(eb)
	end)
	align:SetScript("OnEditFocusLost", function(eb)
		eb:SetText(E.db.gridSize)
	end)
	align:SetScript("OnEditFocusGained", align.HighlightText)
	align:SetScript("OnShow", function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E.db.gridSize)
	end)

	align.text = align:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	align.text:Point("RIGHT", align, "LEFT", -4, 0)
	align.text:SetText(L["Grid Size:"])

	--position buttons
	snapping:Point("BOTTOMLEFT", 14, 10)
	lock:Point("BOTTOMRIGHT", -14, 14)
	align:Point("TOPRIGHT", lock, "TOPLEFT", -4, -2)

	S:HandleCheckBox(snapping)
	S:HandleButton(lock)
	S:HandleEditBox(align)

	f:RegisterEvent("PLAYER_REGEN_DISABLED")
	f:SetScript("OnEvent", function(mover)
		if mover:IsShown() then
			mover:Hide()
			E:Grid_Hide()
			E:ToggleMoveMode(true)
		end
	end)

	local configMode = CreateFrame("Frame", f:GetName().."DropDown", f, "UIDropDownMenuTemplate")
	configMode:Point("BOTTOMRIGHT", lock, "TOPRIGHT", 8, -5)
	S:HandleDropDownBox(configMode, 148)
	configMode.text = configMode:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	configMode.text:Point("RIGHT", configMode.backdrop, "LEFT", -2, 0)
	configMode.text:SetText(L["Config Mode:"])

	UIDropDownMenu_Initialize(configMode, ConfigMode_Initialize)

	local nudgeFrame = CreateFrame("Frame", "ElvUIMoverNudgeWindow", E.UIParent)
	nudgeFrame:SetFrameStrata("DIALOG")
	nudgeFrame:Width(200)
	nudgeFrame:Height(110)
	nudgeFrame:SetTemplate("Transparent")
	nudgeFrame:CreateShadow(5)
	nudgeFrame:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	nudgeFrame:SetFrameLevel(100)
	nudgeFrame:Hide()
	nudgeFrame:EnableMouse(true)
	nudgeFrame:SetClampedToScreen(true)

	ElvUIMoverPopupWindow:HookScript("OnHide", function() ElvUIMoverNudgeWindow:Hide() end)

	desc = nudgeFrame:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:Point("TOPLEFT", 18, -15)
	desc:Point("BOTTOMRIGHT", -18, 28)
	desc:SetJustifyH("CENTER")
	nudgeFrame.title = desc

	header = CreateFrame("Button", nil, nudgeFrame)
	header:SetTemplate(nil, true)
	header:Width(100)
	header:Height(25)
	header:Point("CENTER", nudgeFrame, "TOP")
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))

	title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:Point("CENTER", header, "CENTER")
	title:SetText(L["Nudge"])

	local xOffset = CreateFrame("EditBox", nudgeFrame:GetName().."XEditBox", nudgeFrame, "InputBoxTemplate")
	xOffset:Width(50)
	xOffset:Height(17)
	xOffset:SetAutoFocus(false)
	xOffset.currentValue = 0
	xOffset:SetScript("OnEscapePressed", function(eb)
		eb:SetText(E:Round(xOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	xOffset:SetScript("OnEnterPressed", function(eb)
		local num = eb:GetText()
		if tonumber(num) then
			local diff = num - xOffset.currentValue
			xOffset.currentValue = num
			E:NudgeMover(diff)
		end
		eb:SetText(E:Round(xOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	xOffset:SetScript("OnEditFocusLost", function(eb)
		eb:SetText(E:Round(xOffset.currentValue))
	end)
	xOffset:SetScript("OnEditFocusGained", xOffset.HighlightText)
	xOffset:SetScript("OnShow", function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E:Round(xOffset.currentValue))
	end)

	xOffset.text = xOffset:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	xOffset.text:Point("RIGHT", xOffset, "LEFT", -4, 0)
	xOffset.text:SetText("X:")
	xOffset:Point("BOTTOMRIGHT", nudgeFrame, "CENTER", -6, 8)
	nudgeFrame.xOffset = xOffset
	S:HandleEditBox(xOffset)

	local yOffset = CreateFrame("EditBox", nudgeFrame:GetName().."YEditBox", nudgeFrame, "InputBoxTemplate")
	yOffset:Width(50)
	yOffset:Height(17)
	yOffset:SetAutoFocus(false)
	yOffset.currentValue = 0
	yOffset:SetScript("OnEscapePressed", function(eb)
		eb:SetText(E:Round(yOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	yOffset:SetScript("OnEnterPressed", function(eb)
		local num = eb:GetText()
		if tonumber(num) then
			local diff = num - yOffset.currentValue
			yOffset.currentValue = num
			E:NudgeMover(nil, diff)
		end
		eb:SetText(E:Round(yOffset.currentValue))
		EditBox_ClearFocus(eb)
	end)
	yOffset:SetScript("OnEditFocusLost", function(eb)
		eb:SetText(E:Round(yOffset.currentValue))
	end)
	yOffset:SetScript("OnEditFocusGained", yOffset.HighlightText)
	yOffset:SetScript("OnShow", function(eb)
		EditBox_ClearFocus(eb)
		eb:SetText(E:Round(yOffset.currentValue))
	end)

	yOffset.text = yOffset:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	yOffset.text:Point("RIGHT", yOffset, "LEFT", -4, 0)
	yOffset.text:SetText("Y:")
	yOffset:Point("BOTTOMLEFT", nudgeFrame, "CENTER", 16, 8)
	nudgeFrame.yOffset = yOffset
	S:HandleEditBox(yOffset)

	local resetButton = CreateFrame("Button", nudgeFrame:GetName().."ResetButton", nudgeFrame, "UIPanelButtonTemplate")
	resetButton:SetText(RESET)
	resetButton:Point("TOP", nudgeFrame, "CENTER", 0, 2)
	resetButton:Size(100, 25)
	resetButton:SetScript("OnClick", function()
		if ElvUIMoverNudgeWindow.child.textString then
			E:ResetMovers(ElvUIMoverNudgeWindow.child.textString)
		end
	end)
	S:HandleButton(resetButton)

	local upButton = CreateFrame("Button", nudgeFrame:GetName().."UpButton", nudgeFrame)
	upButton:Point("BOTTOMRIGHT", nudgeFrame, "BOTTOM", -6, 4)
	upButton:SetScript("OnClick", function()
		E:NudgeMover(nil, 1)
	end)
	S:HandleNextPrevButton(upButton)
	upButton:SetSize(22, 22)

	local downButton = CreateFrame("Button", nudgeFrame:GetName().."DownButton", nudgeFrame)
	downButton:Point("BOTTOMLEFT", nudgeFrame, "BOTTOM", 6, 4)
	downButton:SetScript("OnClick", function()
		E:NudgeMover(nil, -1)
	end)
	S:HandleNextPrevButton(downButton)
	downButton:SetSize(22, 22)

	local leftButton = CreateFrame("Button", nudgeFrame:GetName().."LeftButton", nudgeFrame)
	leftButton:Point("RIGHT", upButton, "LEFT", -6, 0)
	leftButton:SetScript("OnClick", function()
		E:NudgeMover(-1)
	end)
	S:HandleNextPrevButton(leftButton)
	leftButton:SetSize(22, 22)

	local rightButton = CreateFrame("Button", nudgeFrame:GetName().."RightButton", nudgeFrame)
	rightButton:Point("LEFT", downButton, "RIGHT", 6, 0)
	rightButton:SetScript("OnClick", function()
		E:NudgeMover(1)
	end)
	S:HandleNextPrevButton(rightButton)
	rightButton:SetSize(22, 22)
end--=================== ElvUI 7.x window chrome (ported from ElvUI-development) ===================
local hooksecurefunc = hooksecurefunc
local next, sort, gsub, wipe = next, sort, gsub, wipe
local strsplit, strmatch, strtrim, strlower = strsplit, strmatch, strtrim, strlower
local pairs, tinsert, tContains = pairs, tinsert, tContains
local min = min
local EditBox_HighlightText = EditBox_HighlightText
local EnableAddOn, GetAddOnInfo = EnableAddOn, GetAddOnInfo
local LoadAddOn = LoadAddOn
local GetMouseFocus = GetMouseFocus
local UIParent = UIParent

if not E.ConfigTooltip then
	E.ConfigTooltip = CreateFrame('GameTooltip', 'ElvUI_ConfigTooltip', UIParent, 'GameTooltipTemplate')
end

function E:Config_ResetSettings()
	E.configSavedPositionTop, E.configSavedPositionLeft = nil, nil
	E.global.general.AceGUI = E:CopyTable({}, E.DF.global.general.AceGUI)
end

function E:Config_GetPosition()
	return E.configSavedPositionTop, E.configSavedPositionLeft
end

function E:Config_GetSize()
	return E.global.general.AceGUI.width, E.global.general.AceGUI.height
end

function E:Config_GetStatus(frame)
	local status = frame and frame.obj and frame.obj.status
	local selected = status and status.groups and status.groups.selected

	return status, selected
end

function E:Config_UpdateSize(reset)
	local frame = E:Config_GetWindow()
	if not frame then return end

	local maxWidth, maxHeight = self.UIParent:GetSize()
	if frame.SetResizeBounds then
		frame:SetResizeBounds(800, 600, maxWidth-50, maxHeight-50)
	else
		frame:SetMinResize(800, 600)
		frame:SetMaxResize(maxWidth-50, maxHeight-50)
	end

	self.Libs.AceConfigDialog:SetDefaultSize('ElvUI', E:Config_GetDefaultSize())

	local status = E:Config_GetStatus(frame)
	if status then
		if reset then
			E:Config_ResetSettings()

			status.top, status.left = E:Config_GetPosition()
			status.width, status.height = E:Config_GetDefaultSize()

			frame.obj:ApplyStatus()
		else
			local top, left = E:Config_GetPosition()
			if top and left then
				status.top, status.left = top, left

				frame.obj:ApplyStatus()
			end
		end

		E:Config_UpdateLeftScroller(frame)
	end
end

function E:Config_GetDefaultSize()
	local width, height = E:Config_GetSize()
	local maxWidth, maxHeight = E.UIParent:GetSize()
	width, height = min(maxWidth-50, width), min(maxHeight-50, height)
	return width, height
end

function E:Config_StopMoving()
	local frame = self
	if not (frame and frame.obj and frame.obj.status) then
		frame = self and self.GetParent and self:GetParent()
	end

	local status = frame and E:Config_GetStatus(frame)
	if status then
		E.configSavedPositionTop, E.configSavedPositionLeft = E:Round(frame:GetTop(), 2), E:Round(frame:GetLeft(), 2)
		E.global.general.AceGUI.width, E.global.general.AceGUI.height = E:Round(frame:GetWidth(), 2), E:Round(frame:GetHeight(), 2)
		E:Config_UpdateLeftScroller(frame)
	end
end

function E:Config_ButtonOnEnter()
	local name = self.info and self.info.name
	if type(name) == 'function' then name = name() end

	if not self.desc and not name then return end

	local current = self:GetText()
	E.ConfigTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT', 0, 2)

	-- show the full name when the button label was truncated
	if name and name ~= current then
		E.ConfigTooltip:AddLine(E:StripString(name), 1, 1, 1, true)
	end

	if self.desc then
		E.ConfigTooltip:AddLine(self.desc, 1, 1, 1, true)
	end

	E.ConfigTooltip:Show()
end

function E:Config_ButtonOnLeave()
	E.ConfigTooltip:Hide()
end

function E:Config_RepositionOnEnter()
	if self.highlight then
		self.highlight:Show()
	else
		local r, g, b = unpack(E.media.rgbvaluecolor)
		self.texture:SetVertexColor(r, g, b, 1)
	end

	E.Config_ButtonOnEnter(self)
end

function E:Config_RepositionOnLeave()
	if self.highlight then
		self.highlight:Hide()
	else
		self.texture:SetVertexColor(1, 1, 1, 0.8)
	end

	E.Config_ButtonOnLeave()
end

function E:Config_PreviousLocation(editbox)
	local _, selected = E:Config_GetStatus(editbox.frame)
	if selected ~= 'search' then
		editbox.selected = selected or nil
	end
end

function E:Config_SearchUpdate(userInput)
	if not userInput then return end

	local C = E.Config[1]
	C:Search_ClearResults()

	local text = self:GetText()
	if strmatch(text, '%S+') then
		C.SearchText = strtrim(strlower(text))

		C:Search_Config()
		C:Search_AddResults()

		local ACD = E.Libs.AceConfigDialog
		if ACD then
			ACD:SelectGroup('ElvUI', 'search') -- trigger update
		end
	end
end

function E:Config_SearchClear()
	if not self.ClearFocus then
		self = self:GetParent()
	end

	local C = E.Config[1]
	C:Search_ClearResults()

	local _, selected = E:Config_GetStatus(self.frame)
	if selected == 'search' then
		local ACD = E.Libs.AceConfigDialog
		if ACD then
			ACD:SelectGroup('ElvUI', self.selected or 'general') -- try to stay or swap back to general if it cant
		end
	end

	self:SetText("")
	EditBox_ClearFocus(self)
end

function E:Config_SearchFocusGained()
	EditBox_HighlightText(self)
	E:Config_PreviousLocation(self)
end

function E:Config_SearchFocusLost()
	EditBox_ClearFocus(self)
end

function E:Config_SearchOnEvent()
	local frame = self:HasFocus() and GetMouseFocus()
	if frame and (frame ~= self and frame ~= self.clearButton) then
		EditBox_ClearFocus(self)
	end
end

function E:Config_SliderOnMouseWheel(offset)
	local _, maxValue = self:GetMinMaxValues()
	if maxValue == 0 then return end

	local newValue = self:GetValue() - offset
	if newValue < 0 then newValue = 0 end
	if newValue > maxValue then return end

	self:SetValue(newValue)
	self.buttons:Point('TOPLEFT', 0, newValue * 36)
end

function E:Config_SliderOnValueChanged(value)
	self:SetValue(value)
	self.buttons:Point('TOPLEFT', 0, value * 30)
end

function E:Config_TruncateButtonText(btn)
	local fs = btn:GetFontString()
	if not fs then return end

	-- Sirus client: the raw fontstring may have no font yet; ensure one is set
	-- before measuring, otherwise SetText fails with "Font not set"
	local _, fontHeight = fs:GetFont()
	if not fontHeight and fs.FontTemplate then
		fs:FontTemplate(nil, 12)
	end

	fs:SetWordWrap(false)
	fs:SetJustifyH('CENTER')

	local maxWidth = btn:GetWidth() and (btn:GetWidth() - 20) or 0
	if maxWidth <= 0 then return end

	local name = btn:GetText() or ''
	if name:gsub('|c[fF][fF]%x%x%x%x%x%x',''):gsub('|r',''):gsub('%s','') == '' then return end

	fs:SetText(name)

	if fs:GetStringWidth() > maxWidth then
		local cut = #name
		local truncated = name
		while cut > 0 and fs:GetStringWidth() > maxWidth do
			cut = cut - 1
			truncated = name:sub(1, cut)..'...'
			fs:SetText(truncated)
		end
		btn:SetText(truncated)
	end
end

function E:Config_SetButtonText(btn, noColor)
	local name = btn.info.name
	if type(name) == 'function' then name = name() end

	if noColor then
		name = name:gsub('|c[fF][fF]%x%x%x%x%x%x',''):gsub('|r','')
	end

	btn:SetText(name)
end

function E:Config_CreateSeparatorLine(frame, lastButton)
	local line = frame.leftHolder.buttons:CreateTexture()
	line:SetTexture(E.Media.Textures.White8x8)
	line:SetVertexColor(1, .82, 0, .4)
	line:Size(179, 2)
	line:Point('TOP', lastButton, 'BOTTOM', 0, -6)
	line.separator = true
	return line
end

function E:Config_SetButtonColor(btn, disabled)
	btn:SetEnabled(not disabled)

	if not btn:GetFontString() then return end

	if disabled then
		btn:GetFontString():SetTextColor(1, 1, 1)
		E:Config_SetButtonText(btn, true)

		if btn.SetBackdropColor then
			btn:SetBackdropColor(1, .82, 0, 0.4)
			btn:SetBackdropBorderColor(1, .82, 0, 1)
		end
	else
		btn:GetFontString():SetTextColor(1, .82, 0)
		E:Config_SetButtonText(btn)

		if btn.SetBackdropColor then
			local r1, g1, b1 = unpack(E.media.backdropcolor)
			btn:SetBackdropColor(r1, g1, b1, 1)

			local r2, g2, b2 = unpack(E.media.bordercolor)
			btn:SetBackdropBorderColor(r2, g2, b2, 1)
		end
	end
end

function E:Config_UpdateSliderPosition(btn)
	local left = btn and btn.frame and btn.frame.leftHolder
	if left and left.slider then
		E.Config_SliderOnValueChanged(left.slider, btn.sliderValue or 0)
	end
end

function E:Config_CreateFrame(info, frame, unskinned, frameType, ...)
	local element = CreateFrame(frameType, ...)
	element.frame = frame
	element.desc = info.desc
	element.info = info

	if frameType == 'Button' then
		if not unskinned then
			S:HandleButton(element)
		end

		element:SetScript('OnClick', info.func)

		if element then
			E:Config_SetButtonText(element)
			E:Config_SetButtonColor(element, element.info.key == 'general')
			element:HookScript('OnEnter', E.Config_ButtonOnEnter)
			element:HookScript('OnLeave', E.Config_ButtonOnLeave)

			-- Sirus client: template buttons have no font on the raw fontstring
			-- until the button machinery applies it; set one up front so the
			-- width is measured correctly and truncation does not hit
			-- "Font not set" (bottom buttons only; left buttons get theirs
			-- in Config_HandleLeftButton)
			if not info.key then
				local btext = element:GetFontString()
				if btext and btext.FontTemplate then
					btext:FontTemplate()
				end
			end

			-- dev: width = text + 40, height 22. Bottom buttons (no info.key)
			-- get a safety cap so russian labels never overlap the search box;
			-- left buttons override the width later (Config_HandleLeftButton)
			local width = element:GetTextWidth() + 40
			if not info.key then
				width = min(width, 160)
			end
			element:Size(width, 22)

			if not info.key then
				E:Config_TruncateButtonText(element)
			end
		end
	elseif frameType == 'EditBox' then
		element:FontTemplate() -- Define Font properties for the Editbox text field to show written characters
		element:SetAutoFocus(false)

		S:HandleSearchBox(element, unskinned)

		element:HookScript('OnTextChanged', info.update)
		element:SetScript('OnEscapePressed', info.clear)
		element:SetScript('OnEditFocusLost', info.focusLost)
		element:SetScript('OnEditFocusGained', info.focusGained)
		element.clearButton:HookScript('OnClick', info.clear)

		element:Size(220, 22)
	end

	return element
end

function E:Config_DialogOpened(name)
	if name ~= 'ElvUI' then return end

	local frame = E:Config_GetWindow()
	if frame and frame.leftHolder then
		E:Config_WindowOpened(frame)
	end
end

function E:Config_UpdateLeftButtons()
	local frame = E:Config_GetWindow()
	if not (frame and frame.leftHolder) then return end

	local _, selected = E:Config_GetStatus(frame)
	for _, btn in next, frame.leftHolder.buttons do
		if type(btn) == 'table' and btn.IsObjectType and btn:IsObjectType('Button') then
			local enabled = btn.info.key == selected
			E:Config_SetButtonColor(btn, enabled)

			if enabled then
				E:Config_UpdateSliderPosition(btn)
			end
		end
	end
end

function E:Config_UpdateLeftScroller(frame)
	local left = frame and frame.leftHolder
	if not left then return end

	local btns = left.buttons
	local bottom = btns:GetBottom()
	if not bottom then return end
	btns:Point('TOPLEFT', 0, 0)

	local max = 0
	for _, btn in next, btns do
		local button = type(btn) == 'table' and btn.IsObjectType and btn:IsObjectType('Button')
		if button then
			btn.sliderValue = nil

			local btm = btn:GetBottom()
			if btm then
				if bottom > btm then
					max = max + 1
					btn.sliderValue = max
				end
			end
		end
	end

	local slider = left.slider
	slider:SetMinMaxValues(0, max)
	slider:SetValue(0)

	if max == 0 then
		slider.thumb.holder:Hide()
	else
		slider.thumb.holder:Show()
	end
end

function E:Config_SaveOldFramelevel(frame)
	if not frame.oldFramelevel then
		frame.oldFramelevel = frame:GetFrameLevel()
	end
end

function E:Config_RestoreOldFramelevel(frame)
	if frame.oldFramelevel then
		frame:SetFrameLevel(frame.oldFramelevel)

		frame.oldFramelevel = nil
	end
end

function E:Config_SaveOldPosition(frame)
	if frame.GetNumPoints and not frame.oldPosition then
		frame.oldPosition = {}

		for i = 1, frame:GetNumPoints() do
			tinsert(frame.oldPosition, { frame:GetPoint(i) })
		end
	end
end

function E:Config_RestoreOldPosition(frame)
	local position = frame.oldPosition
	if not position then return end

	frame:ClearAllPoints()

	for i = 1, #position do
		frame:Point(unpack(position[i]))
	end

	frame.oldPosition = nil
end

function E:Config_HandleLeftButton(info, frame, unskinned, buttons, last, index)
	local btn = E:Config_CreateFrame(info, frame, unskinned, 'Button', nil, buttons, 'UIPanelButtonTemplate')

	-- plugin groups (not part of core options) are visually nested
	local submenu = (info.order or 0) >= 6 and not tContains(E.OriginalOptions, info.key)

	btn:Width(submenu and 164 or 176)

	if btn.GetFontString and btn:GetFontString() then
		local fs = btn:GetFontString()
		if fs.FontTemplate then
			fs:FontTemplate(nil, 11)
		end
	end

	E:Config_TruncateButtonText(btn)

	if not last then
		btn:Point('TOP', buttons, 'TOP', submenu and 11 or -1, 0)
	elseif last.IsObjectType and last:IsObjectType('FontString') then
		-- x offset 0: vertical chain only; the horizontal indent for plugins
		-- comes from the "Plugins" section label, so rows never staircase
		btn:Point('TOP', last, 'BOTTOM', 0, -4)
	else
		btn:Point('TOP', last, 'BOTTOM', 0, (last.separator and -6) or -4)
	end

	buttons[index] = btn

	return btn
end

function E:Config_StripNameColor(name)
	if type(name) == 'function' then
		name = name()
	end

	return E:StripString(name)
end

local function Config_SortButtons(a, b)
	local A1, B1 = a[1], b[1]
	if A1 and B1 then
		if A1 == B1 then
			local A3, B3 = a[3], b[3]
			if A3 and B3 and (A3.name and B3.name) then
				return E:Config_StripNameColor(A3.name) < E:Config_StripNameColor(B3.name)
			end
		end

		return A1 < B1
	end
end

function E:Config_CreateLeftButtons(frame, unskinned, options)
	local opts = {}
	-- plugin groups (not part of core options) go to the end of the list, visually nested
	local pluginHeaderShown = false
	for key, info in pairs(options) do
		if not tContains(E.OriginalOptions, key) then
			info.order = 100 + (info.order or 0)
		end
		if key == 'profiles' then
			info.desc = nil
		end
		tinsert(opts, {info.order, key, info})
	end
	sort(opts, Config_SortButtons)

	local buttons, last, order = frame.leftHolder.buttons
	for index, opt in ipairs(opts) do
		local info = opt[3]
		local key = opt[2]

		if (order == 2 or order == 5 or order == 20) and order < opt[1] then
			last = E:Config_CreateSeparatorLine(frame, last)
		end

		-- first plugin group gets a "Plugins" heading (non-clickable)
		if (opt[1] or 0) >= 100 and not pluginHeaderShown then
			pluginHeaderShown = true
			last = E:Config_CreateSectionLabel(frame, last, L["Plugins"])
		end

		order = opt[1]

		info.key = key
		info.func = function()
			local ACD = E.Libs.AceConfigDialog
			if ACD then ACD:SelectGroup('ElvUI', key) end
		end

		if key ~= 'search' then
			last = E:Config_HandleLeftButton(info, frame, unskinned, buttons, last, index)
		end
	end
end

function E:Config_CreateSectionLabel(frame, lastButton, text)
	local label = frame.leftHolder.buttons:CreateFontString(nil, 'OVERLAY')
	label:FontTemplate(nil, 11, 'OUTLINE')
	label:SetTextColor(1, .82, 0)
	label:SetText(text)
	label:Point('TOPLEFT', lastButton, 'BOTTOMLEFT', 12, -10)
	label:Width(164)
	label:SetJustifyH('LEFT')
	return label
end

function E:Config_CloseClicked()
	if self.originalClose then
		self.originalClose:Click()
	end
end

function E:Config_CloseWindow()
	local ACD = E.Libs.AceConfigDialog
	if ACD then ACD:Close('ElvUI') end

	E.ConfigTooltip:Hide()
end

function E:Config_OpenWindow()
	local ACD = E.Libs.AceConfigDialog
	if ACD then ACD:Open('ElvUI') end

	E.ConfigTooltip:Hide()
end

function E:Config_GetWindow()
	local ACD = E.Libs.AceConfigDialog
	local ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames.ElvUI
	return ConfigOpen and ConfigOpen.frame
end

local ConfigLogoTop
local function ConfigLogoUpdate(_, r, g, b)
	if ConfigLogoTop then
		ConfigLogoTop:SetVertexColor(r, g, b)
	end

	if ElvUIMoverNudgeWindow and ElvUIMoverNudgeWindow.shadow then
		ElvUIMoverNudgeWindow.shadow:SetBackdropBorderColor(r, g, b, 0.9)
	end
end
E.valueColorUpdateFuncs[ConfigLogoUpdate] = true

function E:Config_WindowClosed()
	if not self.bottomHolder then return end

	local frame = E:Config_GetWindow()
	if not frame or frame ~= self then
		self.bottomHolder:Hide()
		self.leftHolder:Hide()
		self.topHolder:Hide()
		self.leftHolder.slider:Hide()
		self.closeButton:Hide()
		self.originalClose:Show()

		ConfigLogoTop = nil

		E:StopElasticize(self.leftHolder.LogoTop)
		E:StopElasticize(self.leftHolder.LogoBottom)

		E:Config_RestoreOldPosition(self.topHolder.version)
		E:Config_RestoreOldPosition(self.obj.content)
		E:Config_RestoreOldPosition(self.obj.titlebg)

		local unskinned = not E.private.skins.ace3.enable
		local statusParent = self.statusText and self.statusText.parent
		if statusParent then
			statusParent:Show()

			E:Config_RestoreOldPosition(statusParent)

			if unskinned then
				E:Config_RestoreOldFramelevel(statusParent)
			end
		end

		if E.ShowPopup then
			E:StaticPopup_Show('CONFIG_RL')
			E.ShowPopup = nil
		end
	end
end

function E:Config_ContentPlacement(frame, content, unskinned, statusShown)
	content:ClearAllPoints()
	content:Point('TOPLEFT', frame, 'TOPLEFT', unskinned and 13 or 7, -(frame.bottomHolder:GetHeight() + (unskinned and 46 or 41)))
	content:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -(unskinned and 18 or 8), (statusShown and (unskinned and 32 or 25)) or (unskinned and 12) or 2)
end

function E:Config_SetStatusText(text)
	if not ConfigLogoTop or not self.parent then return end

	local shown = text and text ~= ''
	self.parent:SetShown(shown)

	E:Config_ContentPlacement(self.frame, self.content, not E.private.skins.ace3.enable, shown)
end

-- Defensive: hide the AceConfigDialog treeframe for the ElvUI root group even
-- if the Ace3 skin hook did not run (the chrome renders its own left menu).
function E:Config_HideAceTree(frame)
	if not (frame and frame.obj) then return end

	local function walk(widget)
		if not widget then return end
		if widget.treeframe and widget.userdata and widget.userdata.option
			and widget.userdata.option.childGroups == 'ElvUI_HiddenTree'
			and widget.treeframe:IsShown() then
			widget.treeframe:Hide()
		end
		if widget.children then
			for _, child in ipairs(widget.children) do
				walk(child)
			end
		end
	end

	walk(frame.obj)
end

function E:Config_WindowOpened(frame)
	E:Config_HideAceTree(frame)

	if frame and frame.bottomHolder and not ConfigLogoTop then
		frame.bottomHolder:Show()
		frame.leftHolder:Show()
		frame.topHolder:Show()
		frame.leftHolder.slider:Show()
		frame.closeButton:Show()
		frame.originalClose:Hide()

		local logoColor = E.media.rgbvaluecolor or {1, .82, 0}
		frame.leftHolder.LogoTop:SetVertexColor(unpack(logoColor))
		frame.leftHolder.LogoBottom:SetVertexColor(unpack(logoColor))
		frame.leftHolder.LogoTop:Show()
		frame.leftHolder.LogoBottom:Show()
		ConfigLogoTop = frame.leftHolder.LogoTop

		-- decorative bounce-in; if the animation framework fails the logo
		-- must still stay visible at its full size (pcall guards it)
		pcall(E.Elasticize, E, frame.leftHolder.LogoTop, 128, 64)
		pcall(E.Elasticize, E, frame.leftHolder.LogoBottom, 128, 64)

		local unskinned = not E.private.skins.ace3.enable
		local version = frame.topHolder.version
		E:Config_SaveOldPosition(version)
		version:ClearAllPoints()
		version:Point('LEFT', frame.topHolder, 'LEFT', unskinned and 8 or 6, unskinned and -4 or 0)

		local content = frame.obj.content
		E:Config_SaveOldPosition(content)
		E:Config_ContentPlacement(frame, content, unskinned)

		local titlebg = frame.obj.titlebg
		E:Config_SaveOldPosition(titlebg)
		titlebg:ClearAllPoints()
		titlebg:SetPoint('TOPLEFT', frame)
		titlebg:SetPoint('TOPRIGHT', frame)
		titlebg:SetTexture(nil) -- hide the default dialog header strip (the chrome renders its own top bar)

		local statusParent = frame.statusText and frame.statusText.parent
		if statusParent then
			if unskinned then -- this lets the arrow work properly without finding it
				E:Config_SaveOldFramelevel(statusParent)

				statusParent:OffsetFrameLevel(-1)
			end

			E:Config_SaveOldPosition(statusParent)

			statusParent:ClearAllPoints()
			statusParent:Point('TOPLEFT', frame.leftHolder, 'BOTTOMRIGHT', unskinned and 11 or 1, unskinned and 38 or 22)
			statusParent:Point('BOTTOMRIGHT', frame, -2, 2)
		end
	end
end

function E:Config_CreateBottomButtons(frame, unskinned)
	local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')
	local C = E.Config[1]

	local last, search
	for index, info in ipairs({
		{
			var = 'Install',
			name = L["Install"],
			desc = L["Run the installation process."],
			func = function()
				E:Install()
				E:ToggleOptions()
			end
		},
		{
			var = 'ShowStatusReport',
			name = L["Status"],
			desc = L["Shows a frame with needed info for support."],
			func = function()
				E:ShowStatusReport()
				E:ToggleOptions()
				E.StatusReportToggled = true
			end
		},
		{
			var = 'ToggleAnchors',
			name = L["Movers"],
			desc = L["Unlock various elements of the UI to be repositioned."],
			func = function()
				E:ToggleMoveMode()
				E.ConfigurationToggled = true
			end
		},
		{
			editBox = 'InputBoxTemplate',
			clear = E.Config_SearchClear,
			update = E.Config_SearchUpdate,
			focusLost = E.Config_SearchFocusLost,
			focusGained = E.Config_SearchFocusGained,
			event = E.Config_SearchOnEvent,
			var = 'Search',
			name = L["Search"]
		},
		{
			var = 'WhatsNew',
			name = L["Whats New"],
			hidden = function()
				return C.SearchText ~= "" or next(C.SearchCache)
			end,
			func = function()
				if search then
					E:Config_PreviousLocation(search)
				end

				C:Search_ClearResults()
				C:Search_Config(nil, nil, nil, true)
				C:Search_AddResults()

				local ACD = E.Libs.AceConfigDialog
				if ACD then
					ACD:SelectGroup('ElvUI', 'search') -- trigger update
				end
			end
		},
		{
			texture = true,
			var = 'RepositionWindow',
			name = L["Reposition Window"],
			desc = L["Reset the size and position of this frame."],
			func = function() E:Config_UpdateSize(true) end
		}
	}) do
		local element
		if info.var == 'RepositionWindow' then
			element = E:Config_CreateFrame(info, frame, true, 'Button', nil, frame.bottomHolder)
			element:Size(unskinned and 34 or 18)

			local texture = element:CreateTexture()
			texture:SetTexture(unskinned and [[Interface\ChatFrame\UI-ChatIcon-Maximize-Up]] or E.Media.Textures.Resize2)
			texture:SetAllPoints()
			element.texture = texture

			if unskinned then
				local highlight = element:CreateTexture()
				highlight:SetTexture([[Interface\Buttons\UI-Common-MouseHilight]])
				highlight:SetBlendMode('ADD')
				highlight:SetAllPoints()
				highlight:Hide()
				element.highlight = highlight
			else
				texture:SetVertexColor(1, 1, 1, 0.8)
			end

			element:HookScript('OnEnter', E.Config_RepositionOnEnter)
			element:HookScript('OnLeave', E.Config_RepositionOnLeave)
		elseif info.editBox then
			element = E:Config_CreateFrame(info, frame, unskinned, 'EditBox', nil, frame.bottomHolder, info.editbox)
		else
			element = E:Config_CreateFrame(info, frame, unskinned, 'Button', nil, frame.bottomHolder, 'UIPanelButtonTemplate')
		end

		if not search and (info.var == 'Search') then
			search = element

			search:RegisterEvent('CURSOR_UPDATE')
			search:SetScript('OnEvent', info.event)
			search:SetScript('OnMouseDown', info.event)
		end

		local offset = unskinned and 14 or 10

		if not last then
			element:Point('BOTTOMLEFT', frame.bottomHolder, 'BOTTOMLEFT', unskinned and 24 or offset, offset)
		elseif info.var == 'RepositionWindow' then
			element:Point('TOPRIGHT', frame.topHolder, 'TOPRIGHT', -(unskinned and 46 or 32), -(unskinned and 4 or 2))
		elseif index == 4 then -- Search
			element:Point('BOTTOMRIGHT', frame.bottomHolder, 'BOTTOMRIGHT', -(unskinned and 24 or offset), offset)
		elseif index > 4 then
			element:Point('RIGHT', last, 'LEFT', -(index == 5 and (unskinned and 16 or 20) or (unskinned and 6 or 12)), 0)
		else
			element:Point('LEFT', last, 'RIGHT', unskinned and 6 or 12, 0)
		end

		last = element

		frame.bottomHolder[info.var] = element
	end
end

local pageNodes = {}
function E:Config_GetToggleMode(frame, msg)
	local pages, msgStr
	if msg and msg ~= "" then
		pages = {strsplit(',', msg)}
		msgStr = gsub(msg, ',', '\001')
	end

	local empty = pages ~= nil
	if not frame or empty then
		if empty then
			local ACD = E.Libs.AceConfigDialog
			local pageCount, index, mainSel = #pages
			if pageCount > 1 then
				wipe(pageNodes)
				index = 0

				local main, mainNode, mainSelStr, sub, subNode, subSel
				for i = 1, pageCount do
					if i == 1 then
						main = pages[i] and ACD and ACD.Status and ACD.Status.ElvUI
						mainSel = main and main.status and main.status.groups and main.status.groups.selected
						mainSelStr = mainSel and ('^'..E:EscapeString(mainSel)..'\001')
						mainNode = main and main.children and main.children[pages[i]]
						pageNodes[index+1], pageNodes[index+2] = main, mainNode
					else
						sub = pages[i] and pageNodes[i] and ((i == pageCount and pageNodes[i]) or pageNodes[i].children[pages[i]])
						subSel = sub and sub.status and sub.status.groups and sub.status.groups.selected
						subNode = (mainSelStr and msgStr:match(mainSelStr..E:EscapeString(pages[i])..'$') and (subSel and subSel == pages[i])) or ((i == pageCount and not subSel) and mainSel and mainSel == msgStr)
						pageNodes[index+1], pageNodes[index+2] = sub, subNode
					end
					index = index + 2
				end
			else
				local main = pages[1] and ACD and ACD.Status and ACD.Status.ElvUI
				mainSel = main and main.status and main.status.groups and main.status.groups.selected
			end

			if frame and ((not index and mainSel and mainSel == msg) or (index and pageNodes and pageNodes[index])) then
				return 'Close'
			else
				return 'Open', pages
			end
		else
			return 'Open'
		end
	else
		return 'Close'
	end
end

function E:ToggleOptions(msg)
	if InCombatLockdown() and E.db.general.showWhenInCombat == false then
		E:Print(ERR_NOT_IN_COMBAT)
		E:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if not IsAddOnLoaded('ElvUI_OptionsUI') then
		local noConfig
		local _, _, _, _, reason = GetAddOnInfo("ElvUI_OptionsUI")
		if reason ~= "MISSING" and reason ~= "DISABLED" then
			E.GUIFrame = false
			LoadAddOn("ElvUI_OptionsUI")

			--For some reason, GetAddOnInfo reason is "DEMAND_LOADED" even if the addon is disabled.
			--Workaround: Try to load addon and check if it is loaded right after.
			if not IsAddOnLoaded("ElvUI_OptionsUI") then noConfig = true end

			-- version check elvui options if it's actually enabled
			if (not noConfig) and GetAddOnMetadata("ElvUI_OptionsUI", "Version") ~= "1.35" then
				E:StaticPopup_Show("CLIENT_UPDATE_REQUEST")
			end
		else
			noConfig = true
		end

		if noConfig then
			E:Print("|cffff0000Error -- Addon 'ElvUI_OptionsUI' не найден или выключен.|r")
			return
		end
	end

	local frame = E:Config_GetWindow()
	local mode, pages = E:Config_GetToggleMode(frame, msg)

	local ACD = E.Libs.AceConfigDialog
	if ACD then
		if not ACD.OpenHookedElvUI then
			hooksecurefunc(ACD, 'Open', E.Config_DialogOpened)
			ACD.OpenHookedElvUI = true
		end

		ACD[mode](ACD, 'ElvUI')
	end

	if not frame then
		frame = E:Config_GetWindow()
	end

	if mode == 'Open' and frame then
		local ACR = E.Libs.AceConfigRegistry
		if ACR and not ACR.NotifyHookedElvUI then
			hooksecurefunc(ACR, 'NotifyChange', E.Config_UpdateLeftButtons)
			ACR.NotifyHookedElvUI = true
			E:Config_UpdateSize()
		end

		local unskinned = not E.private.skins.ace3.enable
		if not frame.bottomHolder then -- window was released or never opened
			frame:HookScript('OnHide', E.Config_WindowClosed)

			for _, child in next, { frame:GetChildren() } do
				local button = child:IsObjectType('Button')
				if button and child:GetText() == _G.CLOSE then
					frame.originalClose = child
					child:Hide()
				elseif button or child:IsObjectType('Frame') then
					if unskinned and child.GetBackdrop then
						local info = child:GetBackdrop()
						if info and info.edgeFile == [[Interface\Tooltips\UI-Tooltip-Border]] then
							child:SetBackdrop(nil)
						end
					end

					local point = not unskinned and not frame.resizeArrow and child:GetPoint()
					if point == 'BOTTOMRIGHT' then
						for _, region in next, { child:GetRegions() } do
							local texture = region:IsObjectType('Texture') and region:GetTexture()
							if texture == [[Interface\Tooltips\UI-Tooltip-Border]] then
								if not child.resizeTexture then
									region:SetTexture(E.Media.Textures.ArrowUp)
									region:SetTexCoord(0, 1, 0, 1)
									region:SetRotation(-2.35)
									region:SetAllPoints()

									child.resizeTexture = region
								elseif texture then -- this is the smaller texture, we don"t need it
									region:SetAlpha(0)
								end
							end
						end

						child:Size(24)
						child:Point('BOTTOMRIGHT', 1, -1)
						child:SetFrameLevel(200)

						frame.resizeArrow = child
					end

					if child:HasScript('OnMouseUp') then
						child:HookScript('OnMouseUp', E.Config_StopMoving)
					end
				end
			end

			local close = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
			close:SetScript('OnClick', E.Config_CloseClicked)
			close:SetFrameLevel(1000)
			close:Point('TOPRIGHT', unskinned and -12 or 1, unskinned and -12 or 2)
			close:Size(unskinned and 30 or 32)
			close.originalClose = frame.originalClose
			frame.closeButton = close

			local statusText = frame.obj.statustext
			if statusText then
				frame.statusText = statusText

				statusText.parent = statusText:GetParent()
				statusText.content = frame.obj.content
				statusText.frame = frame

				if not statusTextHooked[statusText] then
					statusTextHooked[statusText] = true

					hooksecurefunc(statusText, 'SetText', E.Config_SetStatusText)
				end
			end

			local left = CreateFrame('Frame', nil, frame)
			left:Point('TOPLEFT', unskinned and 10 or 2, unskinned and -6 or -2)
			left:Point('BOTTOMRIGHT', frame, 'BOTTOMLEFT', 182, 2)
			frame.leftHolder = left

			local top = CreateFrame('Frame', nil, frame)
			top.version = frame.obj.titletext
			top:Point('TOPRIGHT', frame, -2, 0)
			top:Point('TOPLEFT', left, 'TOPRIGHT', 1, 0)
			top:Height(24)
			frame.topHolder = top

			local bottom = CreateFrame('Frame', nil, frame)
			bottom:Point('TOPLEFT', top, 'BOTTOMLEFT', unskinned and -15 or 0, -(unskinned and 15 or 1))
			bottom:Point('TOPRIGHT', top, 'BOTTOMRIGHT', unskinned and 10 or 0, -(unskinned and 15 or 1))
			bottom:Height(37)
			frame.bottomHolder = bottom

			local LogoBottom = left:CreateTexture()
			LogoBottom:SetTexture(E.Media.Textures.LogoBottomSmall or E.Media.Textures.Logo)
			LogoBottom:Point('CENTER', left, 'TOP', unskinned and 10 or 0, unskinned and -40 or -36)
			LogoBottom:Size(128, 64)
			left.LogoBottom = LogoBottom

			local LogoTop = left:CreateTexture()
			LogoTop:SetTexture(E.Media.Textures.LogoTopSmall or E.Media.Textures.Logo)
			LogoTop:Point('CENTER', left, 'TOP', unskinned and 10 or 0, unskinned and -40 or -36)
			LogoTop:Size(128, 64)
			left.LogoTop = LogoTop

			local buttonsHolder = CreateFrame('Frame', nil, left)
			buttonsHolder:Point('TOPLEFT', unskinned and 4 or 1, -70)
			buttonsHolder:Point('BOTTOMRIGHT', unskinned and 6 or 1, unskinned and 10 or 0)
			left.buttonsHolder = buttonsHolder

			local buttonsScrollFrame = CreateFrame('ScrollFrame', nil, buttonsHolder) -- SetClipsChildren does not exist in 3.3.5, lets do this instead
			buttonsScrollFrame:SetAllPoints(buttonsHolder)
			left.buttonsScrollFrame = buttonsScrollFrame

			local buttonsScrollFrameChild = CreateFrame('Frame', nil, buttonsScrollFrame)
			buttonsScrollFrame:SetScrollChild(buttonsScrollFrameChild)
			buttonsScrollFrameChild:SetAllPoints(buttonsScrollFrame)
			left.buttonsScrollFrameChild = buttonsScrollFrameChild

			local buttons = CreateFrame('Frame', nil, buttonsScrollFrameChild)
			buttons:Point('BOTTOMRIGHT')
			buttons:Point('TOPLEFT', 0, 0)
			left.buttons = buttons

			local slider = CreateFrame('Slider', nil, frame)
			slider:SetThumbTexture(E.Media.Textures.White8x8)
			slider:EnableMouseWheel(true)
			slider:SetScript('OnMouseWheel', E.Config_SliderOnMouseWheel)
			slider:SetScript('OnValueChanged', E.Config_SliderOnValueChanged)
			slider:SetOrientation('VERTICAL')
			slider:SetValueStep(1)
			slider:SetValue(0)
			slider:Width(192)
			slider:Point('TOPLEFT', buttons, 'TOPLEFT', 0, 0)
			slider:Point('BOTTOMRIGHT', left, 'BOTTOMRIGHT', unskinned and 3 or 0, unskinned and 10 or 1)
			slider.buttons = buttons
			left.slider = slider

			local thumb = slider:GetThumbTexture()
			thumb:Point('LEFT', left, 'RIGHT', unskinned and 6 or 2, 0)
			thumb:Size(8, 12)
			thumb:SetAlpha(0) -- hide this one, its under the unskinned buttons
			left.slider.thumb = thumb

			local thumbHolder = CreateFrame('Frame', nil, left)
			thumbHolder:SetFrameLevel(200)
			thumbHolder:SetAllPoints(thumb)
			thumb.holder = thumbHolder

			local thumbTexture = thumbHolder:CreateTexture()
			thumbTexture:SetTexture(E.media.blankTex)
			thumbTexture:SetDrawLayer('OVERLAY')
			thumbTexture:SetVertexColor(1, 1, 1, 0.5)
			thumbTexture:SetAllPoints()
			thumbHolder.texture = thumbTexture

			if not unskinned then
				local statusParent = statusText and statusText.parent
				if statusParent then
					statusParent:Hide()
					statusParent:SetTemplate('Transparent')
				end

				bottom:SetTemplate('Transparent')
				left:SetTemplate('Transparent')
				top:SetTemplate('Transparent')

				S:HandleCloseButton(close)
			else
				for _, region in next, { frame:GetRegions() } do
					local texture = region:IsObjectType('Texture') and region:GetTexture()
					if texture == [[Interface\DialogFrame\UI-DialogBox-Header]] then
						region:SetAlpha(0)
					end
				end
			end

			E:Config_CreateLeftButtons(frame, unskinned, E.Options.args)
			E:Config_CreateBottomButtons(frame, unskinned)
			E:Config_UpdateLeftScroller(frame)
			E:Config_WindowOpened(frame)
		end

		if ACD and pages then
			ACD:SelectGroup('ElvUI', unpack(pages))
		end

		if not E.GUIFrame then
			E.GUIFrame = frame
			ElvUIGUIFrame = E.GUIFrame
			hooksecurefunc(frame, 'StopMovingOrSizing', E.Config_StopMoving)
		end
	end

	GameTooltip:Hide() --Just in case you're mouseovered something and it closes.
end

-- aliases so existing Sirus callers (PixelPerfect, OptionsUI Core, commands) keep working
E.ToggleOptionsUI = E.ToggleOptions
E.UpdateConfigSize = E.Config_UpdateSize
E.GetConfigDefaultSize = E.Config_GetDefaultSize
E.GetConfigSize = E.Config_GetSize
E.GetConfigPosition = E.Config_GetPosition
E.ResetConfigSettings = E.Config_ResetSettings
E.ConfigStopMovingOrSizing = E.Config_StopMoving
