local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mountChest ~= true then return end

	--Custom_MountChestFrame:SetParent(UIParent)
	Custom_MountChestFrame:SetScale(E.mult * UIParent:GetScale())

	Custom_MountChestFrame:StripTextures()
	Custom_MountChestFrame:SetTemplate("Transparent")

	S:HandleCloseButton(Custom_MountChestFrame.closeButton)

	Custom_MountChestFrame.HeaderFrame:SetPoint("TOP", 0, 6)
	Custom_MountChestFrame.HeaderFrame.Background:Hide()
	Custom_MountChestFrame.HeaderFrame.TitleText:FontTemplate(nil, 18, "NONE")

	S:HandleButton(Custom_MountChestFrame.TakeButton)

	hooksecurefunc(Custom_MountChestFrame, "Reset", function(self, animationStage)
		for pi, card in pairs(self.cards) do
			if not card.isSkinned then
				card.Background:SetAlpha(0)

				card.NameFrame.Background:SetTexture(E.Media.Textures.Highlight)
				card.NameFrame.Background:SetAlpha(0.3)

				card.ArtFrame.Border:SetAlpha(0)

				card.NameArtFrame:SetHeight(36)
				card.NameArtFrame.Background:SetTexture(E.Media.Textures.Highlight)
				card.NameArtFrame.Background:SetTexCoord(1, 0, 1, 0)
				card.NameArtFrame.Background:SetAlpha(0.5)
				card.NameArtFrame.Name:SetTextColor(1, 1, 1)
				card.NameArtFrame.Name:SetPoint("CENTER")

				card.isSkinned = true
			end

			card:SetTemplate("Transparent")

            local mountData = LOTTERY_MOUNT_CHEST[pi]
            if mountData then
                local _, _, quality = GetItemInfo(mountData[E_LOTTERY_MOUNT_CHEST.ITEM_ID])
				if quality then
					card:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					card:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
            end
		end
	end)

	hooksecurefunc(Custom_MountChestFrame, "SetAnimationStage", function(self, animationStage)
        if animationStage == 4 then
			local winnerID = self:GetWinnerID()
			if not winnerID then return end

			local card = self.cards[winnerID]
			card:SetTemplate("NoBackdrop")
		end
	end)
end

S:AddCallback("Custom_MountChest", LoadSkin)