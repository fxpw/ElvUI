local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true then return end

	local frameManager = CompactRaidFrameManager
	local displayFrame = frameManager.displayFrame

	frameManager:StripTextures()
	frameManager:CreateBackdrop("Transparent")
	frameManager.backdrop:Point("TOPLEFT", 1, -1)
	frameManager.backdrop:Point("BOTTOMRIGHT", -11, 1)

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
		elseif b < 1 then
			frameManager.toggleButton.Icon:SetRotation(S.ArrowRotation.right)
		end
	end)

	S:HandleButton(frameManager.resizer)
	frameManager.resizer:Size(64, 10)
	frameManager.resizer:Point("BOTTOM", 0, -3)

	frameManager.resizer.UpIcon = frameManager.resizer:CreateTexture()
	frameManager.resizer.UpIcon:Size(16)
	frameManager.resizer.UpIcon:SetPoint("LEFT", 12, 0)
	frameManager.resizer.UpIcon:SetTexture(E.Media.Textures.ArrowUp)
	frameManager.resizer.UpIcon:SetRotation(S.ArrowRotation.up)

	frameManager.resizer.DownIcon = frameManager.resizer:CreateTexture()
	frameManager.resizer.DownIcon:Size(16)
	frameManager.resizer.DownIcon:SetPoint("RIGHT", -12, 0)
	frameManager.resizer.DownIcon:SetTexture(E.Media.Textures.ArrowUp)
	frameManager.resizer.DownIcon:SetRotation(S.ArrowRotation.down)

	displayFrame:StripTextures()

	displayFrame.memberCountLabel:SetPoint("TOPRIGHT", -18, -8)

	for i = 1, 8 do
		_G["CompactRaidFrameManagerDisplayFrameRaidMarkersRaidMarker"..i]:SetNormalTexture(E.Media.Textures.RaidIcons)
	end

	displayFrame.convertToRaid:StripTextures(nil, true)
	S:HandleButton(displayFrame.convertToRaid, true)

	displayFrame.readyCheckButton:StripTextures(nil, true)
	S:HandleButton(displayFrame.readyCheckButton)

	displayFrame.RaidWorldMarkerButton:StripTextures(nil, true)
	S:HandleButton(displayFrame.RaidWorldMarkerButton)
	displayFrame.RaidWorldMarkerButton:Width(39)
	displayFrame.RaidWorldMarkerButton:Point("TOPLEFT", displayFrame.readyCheckButton, "TOPRIGHT", 2, 0)
	displayFrame.RaidWorldMarkerButton:SetNormalTexture("Interface\\RaidFrame\\Raid-WorldPing")
end

S:AddCallback("Skin_RaidManager", LoadSkin)