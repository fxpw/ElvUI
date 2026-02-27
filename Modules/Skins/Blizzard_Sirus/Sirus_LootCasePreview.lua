local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.loot then return end

	local LootCasePreviewFrame = _G.LootCasePreviewFrame
	if not LootCasePreviewFrame then return end

	S:HandlePortraitFrame(LootCasePreviewFrame)

	local ScrollFrame = LootCasePreviewFrame.ScrollFrame
	if ScrollFrame then
		S:HandleScrollBar(ScrollFrame.ScrollBar)
	end

	if _G.LootCasePreviewMixin and _G.LootCasePreviewMixin.UpdateScroll then
		hooksecurefunc(_G.LootCasePreviewMixin, "UpdateScroll", function(self)
			local scrollFrame = self.ScrollFrame
			local buttons = scrollFrame.buttons
			if not buttons then return end

			for _, button in ipairs(buttons) do
				if not button.isSkinned then
					button.Background:SetTexture(nil)
					S:HandleIcon(button.Icon)
					button.Icon:SetDrawLayer("ARTWORK")
					
					button:CreateBackdrop("Default")
                    button.backdrop:SetPoint("TOPLEFT", 38, 0)
                    button.backdrop:SetPoint("BOTTOMRIGHT", 0, 0)

                    button.HighlightTexture:SetColorTexture(1, 1, 1, 0.3)
                    button.HighlightTexture:SetInside(button.backdrop)

					button.isSkinned = true
				end

                if button.itemLink then
                    local _, _, quality = GetItemInfo(button.itemLink)
                    if quality then
                        button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
                        button.Icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
                    else
                         button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
                         button.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
                    end
                else
                     button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
                     button.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
                end
			end
		end)
	end
end

S:AddCallbackForAddon("Blizzard_LootCasePreview", "Sirus_LootCasePreview", LoadSkin)
if _G.LootCasePreviewFrame then
    S:AddCallback("Sirus_LootCasePreview", LoadSkin)
end
