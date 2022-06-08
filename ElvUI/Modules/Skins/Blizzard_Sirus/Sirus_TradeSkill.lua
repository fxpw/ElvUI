local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select = select
local unpack = unpack
local find = string.find
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradeSkillItemLink = GetTradeSkillItemLink
local GetTradeSkillNumReagents = GetTradeSkillNumReagents
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tradeskill then return end

	S:HandlePortraitFrame(TradeSkillFrame)
	S:HandleMaxMinFrame(TradeSkillFrame.MaxMinButtonFrame)

	TradeSkillFrame.RecipeInset:StripTextures()
	TradeSkillFrame.DetailsInset:StripTextures()

	TradeSkillListScrollFrame:StripTextures()
	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar)

	for i = 1, 25 do
		local skillButton = _G["TradeSkillSkill"..i]
		local skillButtonHighlight = _G["TradeSkillSkill"..i.."Highlight"]

		skillButton:SetNormalTexture(E.Media.Textures.Plus)
		skillButton.SetNormalTexture = E.noop
		skillButton:GetNormalTexture():Size(13)
		skillButton:GetNormalTexture():Point("LEFT", 2, 1)

		skillButtonHighlight:SetTexture("")
		skillButtonHighlight.SetTexture = E.noop

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
			else
				self:GetNormalTexture():SetTexture("")
			end
		end)
	end

	TradeSkillFrame.LearnedTab:StripTextures()
	TradeSkillFrame.UnlearnedTab:StripTextures()

	TradeSkillDetailScrollFrame:StripTextures()
	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar)
	TradeSkillDetailScrollFrameScrollBar:SetFrameLevel(TradeSkillListScrollFrameScrollBar:GetFrameLevel())

	S:HandleButton(TradeSkillCreateAllButton, true)
	S:HandleButton(TradeSkillCancelButton, true)
	S:HandleButton(TradeSkillCreateButton, true)

	TradeSkillInputBox:Height(16)
	S:HandleEditBox(TradeSkillInputBox)
	TradeSkillInputBox.Left:SetAlpha(0)
	TradeSkillInputBox.Right:SetAlpha(0)
	TradeSkillInputBox.Middle:SetAlpha(0)
	TradeSkillInputBox:SetPoint("LEFT", TradeSkillCreateAllButton, "RIGHT", 27, 0)
	S:HandleNextPrevButton(TradeSkillInputBox.IncrementButton)
	TradeSkillInputBox.IncrementButton:SetPoint("LEFT", TradeSkillInputBox, "RIGHT", 6 , 0)
	S:HandleNextPrevButton(TradeSkillInputBox.DecrementButton)

	TradeSkillSkillIcon:StripTextures()
	TradeSkillSkillIcon:StyleButton(nil, true)
	TradeSkillSkillIcon:SetTemplate("Default")

	for i = 1, 8 do
		local reagent = _G["TradeSkillReagent"..i]
		local icon = _G["TradeSkillReagent"..i.."IconTexture"]
		local count = _G["TradeSkillReagent"..i.."Count"]
		local name = _G["TradeSkillReagent"..i.."Name"]
		local nameFrame = _G["TradeSkillReagent"..i.."NameFrame"]

		reagent:SetTemplate("Default")
		reagent:StyleButton(nil, true)
		reagent:Size(143, 40)

		icon.backdrop = CreateFrame("Frame", nil, reagent)
		icon.backdrop:SetTemplate()
		icon.backdrop:Point("TOPLEFT", icon, -1, 1)
		icon.backdrop:Point("BOTTOMRIGHT", icon, 1, -1)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer("OVERLAY")
		icon:Size(E.PixelMode and 38 or 32)
		icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
		icon:SetParent(icon.backdrop)

		count:SetParent(icon.backdrop)
		count:SetDrawLayer("OVERLAY")

		name:Point("LEFT", nameFrame, "LEFT", 20, 0)

		nameFrame:Kill()
	end

	TradeSkillRankFrame:StripTextures()
	TradeSkillRankFrame:CreateBackdrop()
	TradeSkillRankFrame:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(TradeSkillRankFrame)

	TradeSkillFrame.FilterButton:StripTextures(true)
	S:HandleButton(TradeSkillFrame.FilterButton)

	S:HandleEditBox(TradeSkillFrame.SearchBox)

	TradeSkillFrame.LinkToButton:GetNormalTexture():SetTexCoord(6 / 32, 24 / 32, 12 / 32, 24 / 32)
	TradeSkillFrame.LinkToButton:GetPushedTexture():SetTexCoord(6 / 32, 24 / 32, 14 / 32, 26 / 32)
	TradeSkillFrame.LinkToButton:GetHighlightTexture():Kill()
	TradeSkillFrame.LinkToButton:CreateBackdrop()
	TradeSkillFrame.LinkToButton:SetSize(19, 14)
	TradeSkillFrame.LinkToButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame.FilterButton, "TOPRIGHT", -2, 8)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillSkillIcon:SetAlpha(1)
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			TradeSkillSkillIcon:GetNormalTexture():SetInside()
		else
			TradeSkillSkillIcon:SetAlpha(0)
		end

		local skillLink = GetTradeSkillItemLink(id)
		local r, g, b

		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality then
				r, g, b = GetItemQualityColor(quality)

				TradeSkillSkillIcon:SetBackdropBorderColor(r, g, b)
				TradeSkillSkillName:SetTextColor(r, g, b)
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E.media.bordercolor))
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end

		for i = 1, GetTradeSkillNumReagents(id) do
			local _, _, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
			local reagentLink = GetTradeSkillReagentItemLink(id, i)

			if reagentLink then
				local reagent = _G["TradeSkillReagent"..i]
				local icon = _G["TradeSkillReagent"..i.."IconTexture"]
				local quality = select(3, GetItemInfo(reagentLink))

				if quality then
					local name = _G["TradeSkillReagent"..i.."Name"]
					r, g, b = GetItemQualityColor(quality)

					icon.backdrop:SetBackdropBorderColor(r, g, b)
					reagent:SetBackdropBorderColor(r, g, b)

					if playerReagentCount < reagentCount then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(r, g, b)
					end
				else
					reagent:SetBackdropBorderColor(unpack(E.media.bordercolor))
					icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)
end

S:AddCallback("Sirus_TradeSkill", LoadSkin)