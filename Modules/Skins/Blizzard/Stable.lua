local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
--WoW API / Variables
local GetPetHappiness = GetPetHappiness
local HasPetUI = HasPetUI
local UnitExists = UnitExists

S:AddCallback("Skin_Stable", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.stable then return end

	S:HandlePortraitFrame(PetStableFrame)

	PetStableFrameInset:StripTextures()
	PetStableBottomInset:StripTextures()

	PetStableFrameModelBg:Hide()
	if PetStableModelShadow then
		PetStableModelShadow:Kill()
	end

	S:HandleRotateButton(PetStableModelRotateLeftButton)
	S:HandleRotateButton(PetStableModelRotateRightButton)

	S:HandleButton(PetStablePurchaseButton)

	S:HandleItemButton(PetStableCurrentPet, true)
	PetStableCurrentPetIconTexture:SetDrawLayer("OVERLAY")

	PetStableModel:CreateBackdrop("Transparent")

	PetStableModelRotateLeftButton:ClearAllPoints()
	PetStableModelRotateLeftButton:Point("TOPLEFT", PetStableModel, "TOPLEFT", 4, -4)
	PetStableModelRotateRightButton:ClearAllPoints()
	PetStableModelRotateRightButton:Point("TOPLEFT", PetStableModelRotateLeftButton, "TOPRIGHT", 3, 0)

	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 52, 4
	PetStablePetInfo:GetRegions():SetTexCoord(0.03125, 0.15625, 0.0625, 0.3125)
	PetStablePetInfo:SetFrameLevel(PetStableModel:GetFrameLevel() + 2)
	PetStablePetInfo:CreateBackdrop("Default")
	PetStablePetInfo:Size(25)
	PetStablePetInfo:ClearAllPoints()
	PetStablePetInfo:Point("TOPLEFT", PetStableModelRotateLeftButton, "BOTTOMLEFT", 10, -4)

	if PetStableMoneyBg then
		PetStableMoneyBg:StripTextures()
	end

	local function UpdateSlot(self, r, g, b)
		if g ~= 1 then
			self:SetTexture(.8, .2, .2, .3)
		else
			self:SetTexture(0, 0, 0, 0)
		end
	end

	for i = 1, NUM_PET_STABLE_SLOTS do
		local button = _G["PetStableStabledPet"..i]
		S:HandleItemButton(button, true)
		_G["PetStableStabledPet"..i.."IconTexture"]:SetDrawLayer("OVERLAY")

		local bg = _G["PetStableStabledPet"..i.."Background"]
		bg:SetDrawLayer("BORDER")
		bg:SetInside()
		hooksecurefunc(bg, "SetVertexColor", UpdateSlot)
	end

	hooksecurefunc("PetStable_Update", function()
		local hasPetUI, isHunterPet = HasPetUI()
		if hasPetUI and not isHunterPet and UnitExists("pet") then return end

		local happiness = GetPetHappiness()

		if happiness == 1 then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 52, 4
			PetStablePetInfo:GetRegions():SetTexCoord(0.40625, 0.53125, 0.0625, 0.3125)
		elseif happiness == 2 then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 28, 4
			PetStablePetInfo:GetRegions():SetTexCoord(0.21875, 0.34375, 0.0625, 0.3125)
		elseif happiness == 3 then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 52, 4
			PetStablePetInfo:GetRegions():SetTexCoord(0.03125, 0.15625, 0.0625, 0.3125)
		end
	end)
end)