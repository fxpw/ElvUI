local print, strmatch, strlower = print, strmatch, strlower
local _G, UNKNOWN, format, type, next, select = _G, UNKNOWN, format, type, next, select

local CreateFrame = CreateFrame
local WorldFrame = WorldFrame
local hooksecurefunc = hooksecurefunc
local LoadAddOn = LoadAddOn
local GetAddOnInfo = GetAddOnInfo
local SlashCmdList = SlashCmdList
local GetMouseFocus = GetMouseFocus
local IsAddOnLoaded = IsAddOnLoaded
local UIParentLoadAddOn = UIParentLoadAddOn
-- GLOBALS: ElvUI_CPU, ElvUI

local function GetName(frame, text)
	if frame.GetName then
		return frame:GetName()
	else
		return text or 'nil'
	end
end

local function IsTrue(value)
	return value == 'true' or value == '1'
end

local function AddCommand(name, keys, func)
	if not SlashCmdList[name] then
		SlashCmdList[name] = func

		if type(keys) == 'table' then
			for i, key in next, keys do
				_G['SLASH_'..name..i] = key
			end
		else
			_G['SLASH_'..name..'1'] = keys
		end
	end
end

-- /rl, /reloadui, /reload NOTE: /reload is from SLASH_RELOAD
AddCommand('RELOADUI', {'/rl','/reloadui'}, _G.ReloadUI)

AddCommand('GETPOINT', '/getpoint', function(arg)
	local frame = (arg ~= '' and _G[arg]) or GetMouseFocus()
	if not frame then return end

	local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
	print(GetName(frame), point, GetName(relativeTo), relativePoint, xOffset, yOffset)
end)

AddCommand('FRAME', '/frame', function(arg)
	local frameName, tinspect = strmatch(arg, '^(%S+)%s*(%S*)$')
	local frame = (frameName ~= '' and _G[frameName]) or GetMouseFocus()
	if not frame then return end

	_G.FRAME = frame -- Set the global variable FRAME to = whatever we are mousing over to simplify messing with frames that have no name.
	ElvUI[1]:Print('_G.FRAME set to: ', GetName(frame, UNKNOWN))
end)

AddCommand('TEXLIST', '/texlist', function(arg)
	local frame = (arg ~= '' and _G[arg]) or _G.FRAME or GetMouseFocus()
	if not frame then return end

	for _, region in next, { frame:GetRegions() } do
		if region.IsObjectType and region:IsObjectType('Texture') then
			print(region:GetTexture(), region:GetName(), region:GetDrawLayer())
		end
	end
end)

AddCommand('FRAMELIST', '/framelist', function(arg)
	if not _G.FrameStackTooltip then
		UIParentLoadAddOn('Blizzard_DebugTools')
	end

	local copyChat, showHidden, showRegions, showAnchors = strmatch(arg, '^(%S+)%s*(%S*)%s*(%S*)%s*(%S*)$')

	local wasShown = _G.FrameStackTooltip:IsShown()
	if not wasShown then
		_G.FrameStackTooltip_Toggle(IsTrue(showHidden), IsTrue(showRegions), IsTrue(showAnchors))
	end

	print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
	for i = 2, _G.FrameStackTooltip:NumLines() do
		local text = _G['FrameStackTooltipTextLeft'..i]:GetText()
		if text and text ~= '' then
			print(text)
		end
	end
	print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

	if _G.CopyChatFrame and IsTrue(copyChat) then
		if _G.CopyChatFrame:IsShown() then
			_G.CopyChatFrame:Hide()
		end

		ElvUI[1]:GetModule('Chat'):CopyChat(_G.ChatFrame1)
	end

	if not wasShown then
		_G.FrameStackTooltip_Toggle()
	end
end)

AddCommand('ECPU', '/ecpu', function()
	if not IsAddOnLoaded('ElvUI_CPU') then
		local _, _, _, _, loadable, reason = GetAddOnInfo('ElvUI_CPU')
		print(loadable, reason)
		if not loadable then
			if reason == 'MISSING' then
				print('ElvUI_CPU addon is missing.')
			elseif reason == 'DISABLED' then
				print('ElvUI_CPU addon is disabled.')
			else
				local loaded, rsn = LoadAddOn('ElvUI_CPU')
				if loaded then
					ElvUI_CPU:ToggleFrame()
				else
					print(format('ElvUI_CPU addon cannot be loaded: %s.', strlower(rsn)))
				end
			end
		end
	elseif not ElvUI_CPU.frame:IsShown() then
		ElvUI_CPU.frame:Show()
	else
		ElvUI_CPU.frame:Hide()
	end
end)

AddCommand('REGLIST', '/reglist', function(arg)
	local frame = (arg ~= '' and _G[arg]) or GetMouseFocus()
	if not frame then return end

	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		print(i, region:GetObjectType(), region:GetName(), region:GetDrawLayer())
	end
end)

AddCommand('CHILDLIST', '/childlist', function(arg)
	local frame = (arg ~= '' and _G[arg]) or GetMouseFocus()
	if not frame then return end

	for i = 1, frame:GetNumChildren() do
		local obj = select(i, frame:GetChildren())
		print(i, obj:GetObjectType(), obj:GetName(), obj:GetFrameStrata(), obj:GetFrameLevel())
	end
end)

local FrameStackHighlight = CreateFrame('Frame', 'FrameStackHighlight')
FrameStackHighlight:SetFrameStrata('TOOLTIP')
FrameStackHighlight.t = FrameStackHighlight:CreateTexture('$parentTexture', 'BORDER')
FrameStackHighlight.t:SetAllPoints()
FrameStackHighlight.t:SetTexture(0, 1, 0, 0.5)

local FrameStackHighlightHitRect = FrameStackHighlight:CreateTexture('$parentHitRectTexture', 'ARTWORK')
FrameStackHighlightHitRect:SetTexture(0, 0, 1, 0.5)
FrameStackHighlightHitRect:SetBlendMode('ADD')

hooksecurefunc('FrameStackTooltip_Toggle', function()
	if not _G.FrameStackTooltip:IsVisible() then
		FrameStackHighlight:Hide()
	end
end)

local _timeSinceLast = 0
_G.FrameStackTooltip:HookScript('OnUpdate', function(_, elapsed)
	_timeSinceLast = _timeSinceLast - elapsed
	if _timeSinceLast <= 0 then
		_timeSinceLast = FRAMESTACK_UPDATE_TIME
		local highlightFrame = GetMouseFocus()

		if highlightFrame and highlightFrame ~= WorldFrame then
			FrameStackHighlight:ClearAllPoints()
			FrameStackHighlight:SetPoint('BOTTOMLEFT', highlightFrame)
			FrameStackHighlight:SetPoint('TOPRIGHT', highlightFrame)
			FrameStackHighlight:Show()

			local l, r, t, b = highlightFrame:GetHitRectInsets()
			if l ~= 0 or r ~= 0 or t ~= 0 or b ~= 0 then
				local scale = highlightFrame:GetEffectiveScale()
				FrameStackHighlightHitRect:ClearAllPoints()
				FrameStackHighlightHitRect:SetPoint('TOPLEFT', highlightFrame, l * scale, -t * scale)
				FrameStackHighlightHitRect:SetPoint('BOTTOMRIGHT', highlightFrame, -r * scale, b * scale)
				FrameStackHighlightHitRect:Show()
			else
				FrameStackHighlightHitRect:Hide()
			end
		else
			FrameStackHighlight:Hide()
		end
	end
end)