local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables
local function AllHideAndHandle(self,bool)
    self.TopLeft:Hide();
    self.TopRight:Hide();
    self.BottomLeft:Hide();
    self.BottomRight:Hide();
    self.TopMiddle:Hide();
    self.MiddleLeft:Hide();
    self.MiddleRight:Hide();
    self.BottomMiddle:Hide();
    self.MiddleMiddle:Hide();
	if bool then
		S:HandleButton(self)
	end
end


local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true then return end

	local frameManager = CompactRaidFrameManager
	local displayFrame = frameManager.displayFrame

	frameManager:StripTextures()
	frameManager:CreateBackdrop()
	-- frameManager.backdrop:Point("TOPLEFT", 0, 0)
	-- frameManager.backdrop:Point("BOTTOMRIGHT", 0, 0)
	-- frameManager:Size(200,100)
	S:HandleButton(frameManager.toggleButton)
	frameManager.toggleButton:ClearAllPoints()
	frameManager.toggleButton:Width(10)
	frameManager.toggleButton:Point("RIGHT", -7, 0)

	frameManager.toggleButton.Icon = frameManager.toggleButton:CreateTexture()
	frameManager.toggleButton.Icon:Size(16)
	frameManager.toggleButton.Icon:SetPoint("CENTER")
	frameManager.toggleButton.Icon:SetTexture(E.Media.Textures.ArrowUp)
	frameManager.toggleButton.Icon:SetRotation(S.ArrowRotation.right)

	hooksecurefunc(frameManager.toggleButton:GetNormalTexture(), "SetTexCoord", function(_, a, b)
		if a > 0 then
			frameManager.toggleButton.Icon:SetRotation(S.ArrowRotation.left)
			frameManager:Size(200,264)
		elseif b < 1 then
			frameManager.toggleButton.Icon:SetRotation(S.ArrowRotation.right)
			frameManager:Size(200,100)
		end
	end)
	frameManager:Size(200,100)
	displayFrame:StripTextures()

	displayFrame.memberCountLabel:SetPoint("TOPRIGHT", -18, -8)

	for i = 1, 8 do
		_G["CompactRaidFrameManagerDisplayFrameRaidMarkersRaidMarker"..i]:SetNormalTexture(E.Media.Textures.RaidIcons)
		-- _G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i]:StripTextures()
		AllHideAndHandle(_G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i],true)
		-- S:HandleButton(_G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i])
	end

	S:HandleDropDownBox(CompactRaidFrameManagerDisplayFrameProfileSelector)

	displayFrame.convertToRaid:StripTextures(nil, true)
	S:HandleButton(displayFrame.convertToRaid, true)

	AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLeaderOptionsCountdown,true)
	AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck,true)

	AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton,false)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetTemplate(nil, true)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetHighlightTexture("")
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:HookScript("OnEnter", S.SetModifiedBackdrop)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:HookScript("OnLeave", S.SetOriginalBackdrop)


	-- AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLockedModeToggle,true)
	-- AllHideAndHandle(CompactRaidFrameManagerDisplayFrameHiddenModeToggle,true)

	S:HandleCheckBox(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton,true)
	if E.private.unitframe.disabledBlizzardFrames.raidFrames then
		CompactRaidFrameManagerDisplayFrameLockedModeToggle:Kill()
		CompactRaidFrameManagerDisplayFrameHiddenModeToggle:Kill()
	else
		AllHideAndHandle(CompactRaidFrameManagerDisplayFrameLockedModeToggle,true)
		AllHideAndHandle(CompactRaidFrameManagerDisplayFrameHiddenModeToggle,true)
	end
	-- /run print(RaidFrameAllAssistCheckButton.text:GetText())
	CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton.text:ClearAllPoints()
	CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton.text:SetPoint("RIGHT",50,0)
	CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton.text:SetText(RaidFrameAllAssistCheckButton.text:GetText())
	CompactRaidFrameManagerDisplayFrameOptionsButton:ClearAllPoints()
	CompactRaidFrameManagerDisplayFrameOptionsButton:SetPoint("TOPRIGHT", 0, -7)
end

S:AddCallback("Skin_RaidManager", LoadSkin)