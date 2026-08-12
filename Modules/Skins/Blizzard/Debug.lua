local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc
--WoW API / Variables
local PlaySound = PlaySound

S:AddCallbackForAddon("Blizzard_DebugTools", "Skin_Blizzard_DebugTools", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.debug then return end

	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:StripTextures()
	ScriptErrorsFrame:SetTemplate("Transparent")

	S:HandleScrollBar(ScriptErrorsFrameScrollFrameScrollBar)
	S:HandleCloseButton(ScriptErrorsFrameClose, ScriptErrorsFrame)

	ScriptErrorsFrameScrollFrameText:FontTemplate(nil, 13)
	ScriptErrorsFrameScrollFrameText:Width(461)

	ScriptErrorsFrameScrollFrame:CreateBackdrop("Default")
	ScriptErrorsFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", 1, -2)
	ScriptErrorsFrameScrollFrame:SetFrameLevel(ScriptErrorsFrameScrollFrame:GetFrameLevel() + 2)
	ScriptErrorsFrameScrollFrame:Width(461)
	ScriptErrorsFrameScrollFrame:Point("TOPLEFT", 9, -30)

	ScriptErrorsFrameScrollFrameScrollBar:Point("TOPLEFT", ScriptErrorsFrameScrollFrame, "TOPRIGHT", 4, -18)
	ScriptErrorsFrameScrollFrameScrollBar:Point("BOTTOMLEFT", ScriptErrorsFrameScrollFrame, "BOTTOMRIGHT", 4, 17)

	EventTraceFrame:StripTextures()
	EventTraceFrame:SetTemplate("Transparent")
	S:HandleSliderFrame(EventTraceFrameScroll)

	for i = 1, ScriptErrorsFrame:GetNumChildren() do
		local child = select(i, ScriptErrorsFrame:GetChildren())
		if child:GetObjectType() == "Button" and not child:GetName() then
			S:HandleButton(child)
		end
	end

	FrameStackTooltip:HookScript("OnShow", function(self)
		local noscalemult = E.mult * GetCVar("uiScale")

		self:SetBackdrop({
			bgFile = E.media.blankTex,
			edgeFile = E.media.blankTex,
			tile = false, tileSize = 0, edgeSize = noscalemult,
			insets = {left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		})

		self:SetBackdropColor(unpack(E.media.backdropfadecolor))
		self:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	EventTraceTooltip:HookScript("OnShow", function(self)
		self:SetTemplate("Transparent")
	end)

	S:HandleCloseButton(EventTraceFrameCloseButton, EventTraceFrame)
end)

S:AddCallbackForAddon("ViragDevTool", "Skin_ViragDevTool", function()
	local ViragDevTool = _G.ViragDevTool
	local color = E:ClassColor(E.myclass)

	local frames = {
		_G.ViragDevToolFrame,
		_G.ViragDevToolFrameSideBar,
		_G.ViragDevToolOptionsMainFrame,
		_G.ViragDevToolFrameScrollFrame,
		_G.ViragDevToolFrameSideBarScrollFrame,
	}

	for _, frame in ipairs(frames) do
		if frame then
			frame:StripTextures()
			frame:SetTemplate("Transparent")
			if frame:IsObjectType("ScrollFrame") then
				frame:StripTextures()
			end
		end
	end

	local sideButtons = {
		_G.ViragDevToolFrameSideBarHistoryButton,
		_G.ViragDevToolFrameSideBarEventsButton,
		_G.ViragDevToolFrameSideBarLogButton,
		_G.ViragDevToolFrameClearButton,
		_G.ViragDevToolFrameAddGlobalButton,
		_G.ViragDevToolFrameFrameStack,
		_G.ViragDevToolFrameHelpButton,
		_G.ViragDevToolFrameFNCallLabelButton,

		_G.VDTFrameColorReset,
	}

	hooksecurefunc(ViragDevTool, "UpdateSideBarUI", function(self)
		local mainFrame = self.wndRef
		local sideFrame = mainFrame.sideFrame

		for _, button in ipairs(sideButtons) do
			local buttonChecked = button:GetName().."Checked"
			local checked = _G[buttonChecked]
			if button and not checked then
				S:HandleButton(button, true, nil, nil, true)
			else
				button:StripTextures(true)

				S:HandleButton(button, nil, nil, nil, true)

				checked:SetVertexColor(color.r, color.g, color.b)
				button:OffsetFrameLevel(2)
				if button:GetChecked() then
					button.backdrop:SetBackdropColor(color.r, color.g, color.b)
				else
					button.backdrop:SetBackdropColor(unpack(E.media.backdropfadecolor))
				end
			end
		end

		for i = 1, sideFrame:GetNumChildren() do
			local button = _G["VDTColorPickerFrameItem"..i.."Button"]
			if button then
				S:HandleButton(button, true, nil, nil, true)

				button.colorTexture:SetTexture(button:GetFontString():GetTextColor())
			end
		end
	end)

	E:Delay(0.1, function()
		for i = 1, 23 do
			local actionButton = _G["ViragDevToolFrameSideBarScrollFrameButton"..i.."ActionButton"]
			if actionButton then
				S:HandleCloseButton(actionButton)
			end
		end
	end)

	local frame = _G.ViragDevToolFrameSideBar
	local button = _G.ViragDevToolFrameToggleSideBarButton
	S:HandleNextPrevButton(button, frame:IsShown() and "right" or "left")

	hooksecurefunc(ViragDevTool, "ToggleSidebar", function(self)
		local isShown = self.settings.isSideBarOpen
		local normal, disabled, pushed = button:GetNormalTexture(), button:GetDisabledTexture(), button:GetPushedTexture()
		local rotation = isShown and S.ArrowRotation.right or S.ArrowRotation.left

		normal:SetRotation(rotation)
		pushed:SetRotation(rotation)
		disabled:SetRotation(rotation)

		PlaySound(isShown and 620 or 621) -- QUESTLOGOPEN or QUESTLOGCLOSE
	end)

	local button = _G.ViragDevToolFrameResizeButton
	local normal, pushed = button:GetNormalTexture(), button:GetPushedTexture()

	S:HandleNextPrevButton(button)

	normal:SetRotation(-2.35)
	pushed:SetRotation(-2.35)

	S:HandleEditBox(_G.ViragDevToolFrameSideBarTextArea, "Transparent")
	S:HandleEditBox(_G.ViragDevToolFrameTextArea, "Transparent")

	S:HandleScrollBar(_G.ViragDevToolFrameScrollFrameScrollBar)
	S:HandleScrollBar(_G.ViragDevToolFrameSideBarScrollFrameScrollBar)

	S:HandleCloseButton(_G.ViragDevToolFrameCloseWndButton)
end)