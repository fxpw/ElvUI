local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.misc then return end

	if not PromoCodeFrame then return end

	PromoCodeFrame:StripTextures()
	PromoCodeFrame:SetTemplate("Transparent")

	if PromoCodeFrame.NineSlice then
		PromoCodeFrame.NineSlice:Hide()
	end

	if PromoCodeFrame.Background then
		PromoCodeFrame.Background:Hide()
	end

	if PromoCodeFrame.TopTileStreaks then
		PromoCodeFrame.TopTileStreaks:Hide()
	end

	if PromoCodeFrame.TitleContainer then
		PromoCodeFrame.TitleContainer:StripTextures()
	end

	if PromoCodeFrame.CloseButton then
		S:HandleCloseButton(PromoCodeFrame.CloseButton)
	end

	local content = PromoCodeFrame.Content
	if content then
		content:StripTextures()

		if content.BackgroundTop then
			content.BackgroundTop:Hide()
		end
		if content.BackgroundBottom then
			content.BackgroundBottom:Hide()
		end
		if content.ShadowBottom then
			content.ShadowBottom:Hide()
		end

		if content.Code then
			content.Code:StripTextures()

			if content.Code.Background then
				content.Code.Background:Hide()
			end
			if content.Code.ShadowTop then
				content.Code.ShadowTop:Hide()
			end
			if content.Code.ShadowBottom then
				content.Code.ShadowBottom:Hide()
			end
			if content.Code.ShadowLeft then
				content.Code.ShadowLeft:Hide()
			end
			if content.Code.ShadowRight then
				content.Code.ShadowRight:Hide()
			end
			if content.Code.VignetteTopLeft then
				content.Code.VignetteTopLeft:Hide()
			end
			if content.Code.VignetteTopRight then
				content.Code.VignetteTopRight:Hide()
			end
			if content.Code.VignetteBottomLeft then
				content.Code.VignetteBottomLeft:Hide()
			end
			if content.Code.VignetteBottomRight then
				content.Code.VignetteBottomRight:Hide()
			end
			if content.Code.DividerTop then
				content.Code.DividerTop:Hide()
			end
			if content.Code.DividerBottom then
				content.Code.DividerBottom:Hide()
			end

			if content.Code.EditBox then
				content.Code.EditBox:StripTextures()
				S:HandleEditBox(content.Code.EditBox)
				content.Code.EditBox:Height(40)

				if content.Code.EditBox.Background then
					content.Code.EditBox.Background:Hide()
				end
				if content.Code.EditBox.DecorTop then
					content.Code.EditBox.DecorTop:Hide()
				end
				if content.Code.EditBox.DecorBottom then
					content.Code.EditBox.DecorBottom:Hide()
				end
				if content.Code.EditBox.DecorLeft then
					content.Code.EditBox.DecorLeft:Hide()
				end
				if content.Code.EditBox.DecorRight then
					content.Code.EditBox.DecorRight:Hide()
				end
			end
		end

		if content.ActionButton then
			content.ActionButton:StripTextures()
			S:HandleButton(content.ActionButton)

			if content.ActionButton.Left then
				content.ActionButton.Left:Hide()
			end
			if content.ActionButton.Right then
				content.ActionButton.Right:Hide()
			end
			if content.ActionButton.Center then
				content.ActionButton.Center:Hide()
			end
		end

		if content.Scroll then
			content.Scroll:StripTextures()
			if content.Scroll.ScrollBar then
				S:HandleScrollBar(content.Scroll.ScrollBar)
			end
		end
	end

	if PromoCodeFrame.BlockFrame then
		PromoCodeFrame.BlockFrame:StripTextures()
	end
end

S:AddCallback("Skin_PromoCode", LoadSkin)
