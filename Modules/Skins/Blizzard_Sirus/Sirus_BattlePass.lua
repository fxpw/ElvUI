local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local function ApplyElvUIFont(frame)
	if not frame or not frame.GetNumRegions then
		return
	end
	for i = 1, (frame:GetNumRegions() or 0) do
		local r = select(i, frame:GetRegions())
		if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.FontTemplate then
			local _, size, flags = r:GetFont()
			if not size or size <= 0 then
				r:FontTemplate(nil, nil, flags)
			else
				r:FontTemplate(nil, size, flags)
			end
		end
	end
	local numChildren = frame:GetNumChildren() or 0
	if numChildren > 0 then
		for i = 1, numChildren do
			local child = select(i, frame:GetChildren())
			if child then
				ApplyElvUIFont(child)
			end
		end
	end
end

local function ApplyElvUIFontForce(frame)
	if not frame or not frame.GetObjectType then
		return
	end
	for i = 1, (frame:GetNumRegions() or 0) do
		local r = select(i, frame:GetRegions())
		if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.SetFont then
			local _, size, flags = r:GetFont()
			r:SetFont(E.media.normFont or (select(1, GameFontNormal:GetFont())), (size and size > 0) and size or 12,
				flags or "")
		end
	end
	for i = 1, (frame:GetNumChildren() or 0) do
		local child = select(i, frame:GetChildren())
		if child then
			ApplyElvUIFontForce(child)
		end
	end
end

local function StyleTutorialButton(btn)
	if not btn then
		return
	end
	if btn.backdrop then
		btn.backdrop:Hide()
	end
	if btn.HelpI then
		btn.HelpI:SetAllPoints(btn)
		btn.HelpI:SetDrawLayer("ARTWORK")
		btn.HelpI:SetVertexColor(1, 1, 1)
	end
	local ht = (btn.GetHighlightTexture and btn:GetHighlightTexture()) or btn.HighlightTexture
	if not ht then
		ht = btn:CreateTexture(nil, "HIGHLIGHT")
		ht:SetAllPoints(btn)
		btn.HighlightTexture = ht
	end
	S:HandleButtonHighlight(ht, 1, 1, 1, 0.25)
	if btn.SetHitRectInsets then
		btn:SetHitRectInsets(4, 4, 4, 4)
	end
end

local function CleanPageButton(btn)
	if not btn then
		return
	end
	S:HandleButton(btn)

	if btn.SetNormalTexture then
		btn:SetNormalTexture("")
	end
	if btn.SetPushedTexture then
		btn:SetPushedTexture("")
	end
	if btn.GetHighlightTexture then
		local ht = btn:GetHighlightTexture()
		if ht then
			ht:SetTexture()
			ht:SetAlpha(0)
		end
		btn:SetHighlightTexture("")
	end

	if btn.Background then
		btn.Background:SetTexture(0, 0, 0, 0)
		btn.Background:SetAlpha(0)
	end
	if btn.DisabledBackground then
		btn.DisabledBackground:SetTexture(0, 0, 0, 0)
		btn.DisabledBackground:SetAlpha(0)
	end

	for i = 1, (btn:GetNumRegions() or 0) do
		local region = select(i, btn:GetRegions())
		if region and region.IsObjectType and region:IsObjectType("Texture") then
			region:SetTexture()
			region:SetAlpha(0)
		end
	end

	btn:HookScript("OnShow", function(self)
		if self.GetHighlightTexture then
			local ht = self:GetHighlightTexture()
			if ht then
				ht:SetTexture()
				ht:SetAlpha(0)
			end
		end
		if self.Background then
			self.Background:SetTexture(0, 0, 0, 0)
			self.Background:SetAlpha(0)
		end
		if self.DisabledBackground then
			self.DisabledBackground:SetTexture(0, 0, 0, 0)
			self.DisabledBackground:SetAlpha(0)
		end
		for i = 1, (self:GetNumRegions() or 0) do
			local r = select(i, self:GetRegions())
			if r and r.IsObjectType and r:IsObjectType("Texture") then
				r:SetTexture()
				r:SetAlpha(0)
			end
		end
	end)
end

local function ReskinPKBTButton(btn)
	if not btn or not btn.IsObjectType or not btn:IsObjectType("Button") then
		return
	end

	local function clearTextures(b)
		if b.Left then
			b.Left:SetAlpha(0)
		end
		if b.Right then
			b.Right:SetAlpha(0)
		end
		if b.Center then
			b.Center:SetAlpha(0)
		end
		if b.LeftHighlight then
			b.LeftHighlight:SetAlpha(0)
		end
		if b.RightHighlight then
			b.RightHighlight:SetAlpha(0)
		end
		if b.CenterHighlight then
			b.CenterHighlight:SetAlpha(0)
		end
		if b.SetNormalTexture then
			b:SetNormalTexture("")
		end
		if b.SetHighlightTexture then
			b:SetHighlightTexture("")
		end
		if b.SetPushedTexture then
			b:SetPushedTexture("")
		end
		if b.SetDisabledTexture then
			b:SetDisabledTexture("")
		end
		for i = 1, (b:GetNumRegions() or 0) do
			local r = select(i, b:GetRegions())
			if r and r.IsObjectType and r:IsObjectType("Texture") then
				r:SetTexture()
				r:SetAlpha(0)
			end
		end
		if b.Glow then
			b.Glow:Hide()
		end
		if b.WidgetHolder then
			b.WidgetHolder:Hide()
		end
		if b.Price then
			b.Price:Hide()
		end
		if b.PurchaseNote then
			b.PurchaseNote:Hide()
		end
	end

	if not btn._Elv_BaseSkinned then
		S:HandleButton(btn, true)
		btn._Elv_BaseSkinned = true
	end

	clearTextures(btn)

	ApplyElvUIFontForce(btn)

	if not btn._Elv_ClearHooks then
		btn._Elv_ClearHooks = true
		if btn.SetThreeSliceAtlas then
			hooksecurefunc(btn, "SetThreeSliceAtlas", function(self)
				clearTextures(self)
			end)
		end
		if btn.SetNormalAtlas then
			hooksecurefunc(btn, "SetNormalAtlas", function(self)
				clearTextures(self)
			end)
		end
		if btn.SetHighlightAtlas then
			hooksecurefunc(btn, "SetHighlightAtlas", function(self)
				clearTextures(self)
			end)
		end
		if btn.SetPushedAtlas then
			hooksecurefunc(btn, "SetPushedAtlas", function(self)
				clearTextures(self)
			end)
		end
		btn:HookScript("OnShow", function(self)
			clearTextures(self)
			ApplyElvUIFontForce(self)
		end)
	end
end

local function HandleBattlePassFrame()
	if not _G.BattlePassFrame then
		return
	end

	local f = _G.BattlePassFrame

	f:StripTextures(true)
	f:SetTemplate("NoBackdrop")
	if f.NineSlice then
		f.NineSlice:Hide()
	end
	f:CreateBackdrop("Transparent")
	if f.backdrop then
		f.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
	end

	if not f._Elv_ScaleHooked then
		f._Elv_ScaleHooked = true
		f:HookScript("OnShow", function(self)
			self:SetScale(E.global.general.UIScale)
		end)
	end

	if f.Inset then
		if f.Inset.NineSlice then
			f.Inset.NineSlice:Hide()
		end
		if f.Inset.Top then
			f.Inset.Top:SetTexture(0, 0, 0, 0)
		end
		if f.Inset.Middle then
			f.Inset.Middle:SetTexture(0, 0, 0, 0)
		end
		if f.Inset.Bottom then
			f.Inset.Bottom:SetTexture(0, 0, 0, 0)
		end
		if f.Inset.NineSliceBorder then
			f.Inset.NineSliceBorder:Hide()
		end
		if f.Inset.NineSliceGlow then
			f.Inset.NineSliceGlow:Hide()
		end
		if f.Inset.ShadowLeft then
			f.Inset.ShadowLeft:SetTexture(0, 0, 0, 0)
		end
		if f.Inset.ShadowRight then
			f.Inset.ShadowRight:SetTexture(0, 0, 0, 0)
		end
		if f.Inset.VignetteTopRight then
			f.Inset.VignetteTopRight:SetTexture(0, 0, 0, 0)
		end
		if f.Inset.VignetteBottomLeft then
			f.Inset.VignetteBottomLeft:SetTexture(0, 0, 0, 0)
		end
		if f.Inset.VignetteBottomRight then
			f.Inset.VignetteBottomRight:SetTexture(0, 0, 0, 0)
		end
		if f.Inset.ArtworkBottomLeft then
			f.Inset.ArtworkBottomLeft:SetTexture(0, 0, 0, 0)
		end
		if f.Inset.DecorOverlay then
			f.Inset.DecorOverlay:Hide()
		end
	end

	if f.CloseButton then
		S:HandleCloseButton(f.CloseButton)
	end

	if f.TopPanel then
		if f.TopPanel.SeasonTimer then
			local st = f.TopPanel.SeasonTimer
			if st.TimeLeft then
				st.TimeLeft:FontTemplate(nil, 18, "NONE")
			end
			if st.TimeLeftLabel then
				st.TimeLeftLabel:FontTemplate(nil, 12, "NONE")
			end
		end

		if f.TopPanel.ExperiencePanel then
			local ep = f.TopPanel.ExperiencePanel
			if ep.PurchaseButton then
				CleanPageButton(ep.PurchaseButton)
			end
			if ep.StatusBar then
				S:HandleStatusBar(ep.StatusBar)
				if ep.StatusBar.Background then
					ep.StatusBar.Background:SetTexture(nil)
					ep.StatusBar.Background:SetAlpha(0)
				end
				if ep.StatusBar.Overlay then
					ep.StatusBar.Overlay:SetTexture(nil)
					ep.StatusBar.Overlay:SetAlpha(0)
				end
			end
		end

		if f.TopPanel.RewardPageButton then
			CleanPageButton(f.TopPanel.RewardPageButton)
		end
		if f.TopPanel.QuestPageButton then
			CleanPageButton(f.TopPanel.QuestPageButton)
		end
		if f.TopPanel.Tutorial then
			StyleTutorialButton(f.TopPanel.Tutorial)
		end
	end

	ApplyElvUIFont(f.TopPanel)

	if f.Content and f.Content.QuestPage and not f.Content.QuestPage._Elv_FontHooked then
		f.Content.QuestPage._Elv_FontHooked = true
		local function SkinAllQuestActionButtons(root)
			if not root or not root.GetNumChildren then
				return
			end
			for i = 1, (root:GetNumChildren() or 0) do
				local child = select(i, root:GetChildren())
				if child then
					-- local cb = child.CancelButton
					-- if cb then
						-- child:StripTextures()
						-- child.backdrop = CreateFrame("Frame", nil, child)
						-- child.backdrop:SetAllPoints(child)
						-- local frameLevel = child.GetFrameLevel and child:GetFrameLevel()
						-- local frameLevelMinusOne = frameLevel and (frameLevel - 4)

						-- if frameLevelMinusOne and (frameLevelMinusOne >= 0) then
						-- 	child.backdrop:SetFrameLevel(frameLevelMinusOne)
						-- else
						-- 	child.backdrop:SetFrameLevel(0)
						-- end
						-- local borderr, borderg, borderb = unpack( E.media.bordercolor)
						-- local backdropr, backdropg, backdropb, backdropa = unpack(E.media.backdropfadecolor)
						-- child.backdrop:SetBackdrop({
						-- 	bgFile = E.media.blankTex,
						-- 	edgeFile = E.media.blankTex,
						-- 	tile = false, tileSize = 0, edgeSize = E.mult,
						-- 	insets = {left = 0, right = 0, top = 0, bottom = 0}
						-- })

						-- child.backdrop:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
						-- child.backdrop:SetBackdropBorderColor(borderr, borderg, borderb, 1)
						-- child:CreateBackdrop("Transparent")
						-- child:SetBackdropBorderColor(unpack(E.media.bordercolor))
						-- S:HandleFrame(child,true,false)
						-- S:HandleCloseButton(cb);
					-- end
					-- local ns = child.NineSliceBorder
					-- if(ns)then
					-- 	ns:StripTextures()
					-- 	ns:Hide()
					-- end
					-- local ng = child.NineSliceGlow
					-- if(ng)then
					-- 	ng:Hide()
					-- 	ng:StripTextures()
					-- end
					-- local checkbox = child.TrackButton
					-- if(checkbox)then
					-- 	S:HandleCheckBox(checkbox)
					-- end
					--  _G.ElvUI[1]:GetModule("Skins"):HandleStatusBar(BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2ProgressStatusBar)
					-- BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2ProgressStatusBar:SetFrameLevel(BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2ProgressStatusBar:GetFrameLevel()+1)
					-- BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2Progress:SetFrameLevel(BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2Progress:GetFrameLevel()+1)
					-- BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2Progress:SetFrameStrata("DIALOG")
					-- S:HandleStatusBar(esb)
					-- if esb.Background then
					-- 	BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2ProgressStatusBar.backdrop:SetTexture(nil)
					-- 	BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2ProgressStatusBar.backdrop:SetAlpha(0)
					-- end
					-- if esb.Overlay then
					-- 	BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2ProgressStatusBar.Overlay:SetTexture(nil)
					-- 	BattlePassFrameContentQuestPageScrollFrameScrollChildQuestHolder2QuestFrame2ProgressStatusBar.Overlay:SetAlpha(0)
					-- end
					-- local status = child.Progress and child.Progress.StatusBar
					-- if(status)then
					-- 	S:HandleStatusBar(status)
					-- 	if status.backdrop then
					-- 		status.backdrop:Hide()
					-- 		status.backdrop:StripTextures()
					-- 	end
					-- end
					-- S:HandleFrame(child)
					if child.ActionButton then
						ReskinPKBTButton(child.ActionButton)
						child.ActionButton:Show()
					end
					SkinAllQuestActionButtons(child)
				end
			end
		end
		hooksecurefunc(f.Content.QuestPage, "UpdateQuestHolders", function(self)
			ApplyElvUIFont(self)
			if self.ScrollFrame and self.ScrollFrame.ScrollChild then
				SkinAllQuestActionButtons(self.ScrollFrame.ScrollChild)
			end
		end)
		-- run once for currently existing frames
		if f.Content.QuestPage.ScrollFrame and f.Content.QuestPage.ScrollFrame.ScrollChild then
			SkinAllQuestActionButtons(f.Content.QuestPage.ScrollFrame.ScrollChild)
		end
	end
	if _G.BattlePassQuestHolderMixin and _G.BattlePassQuestHolderMixin.UpdateQuests and not S._Elv_QuestHolderFontsHooked then
		S._Elv_QuestHolderFontsHooked = true
		hooksecurefunc(_G.BattlePassQuestHolderMixin, "UpdateQuests", function(self)
			ApplyElvUIFont(self)
		end)
	end

	if f.Content and f.Content.MainPage then
		local main = f.Content.MainPage

		if _G.BattlePassLevelCardMixin and not S._Elv_LevelCardButtonsHooked then
			S._Elv_LevelCardButtonsHooked = true
			hooksecurefunc(_G.BattlePassLevelCardMixin, "SetTypeState", function(self)
				local freeButton = self.FreeFrame and self.FreeFrame.ActionButton
				local premButton = self.PremiumFrame and self.PremiumFrame.ActionButton
				if freeButton then
					S:HandleButton(freeButton)
					-- ReskinPKBTButton(freeButton)
					-- freeButton:Show()
				end
				if premButton then
					S:HandleButton(premButton)
					-- ReskinPKBTButton(premButton)
					-- premButton:Show()
				end
			end)
			hooksecurefunc(_G.BattlePassLevelCardMixin, "SetState", function(self)
				if self.SetScript then
					self:SetScript("OnUpdate", nil)
				end
				local fb = self.FreeFrame and self.FreeFrame.ActionButton
				local pb = self.PremiumFrame and self.PremiumFrame.ActionButton
				if fb then
					S:HandleButton(fb)
					fb:Show()
				end
				if pb then
					S:HandleButton(pb)
					pb:Show()
				end
			end)
			hooksecurefunc(_G.BattlePassLevelCardMixin, "OnLeave", function(self)
				local fb = self.FreeFrame and self.FreeFrame.ActionButton
				local pb = self.PremiumFrame and self.PremiumFrame.ActionButton
				if fb then
					S:HandleButton(fb)
					fb:Show()
				end
				if pb then
					S:HandleButton(pb)
					pb:Show()
				end
			end)
		end

		if main.ScrollFrame and main.ScrollFrame.buttons then
			for _, card in ipairs(main.ScrollFrame.buttons) do
				local fb = card.FreeFrame and card.FreeFrame.ActionButton
				local pb = card.PremiumFrame and card.PremiumFrame.ActionButton
				if fb then
					S:HandleButton(fb)
					-- ReskinPKBTButton(fb)
					-- fb:Show()
				end
				if pb then
					S:HandleButton(pb)
					-- ReskinPKBTButton(pb)
					-- pb:Show()
				end
			end
		end
		if main.ScrollFrame and main.ScrollFrame.ScrollBar then
			S:HandleScrollBar(main.ScrollFrame.ScrollBar, true)
		end
		if main.ExperienceScrollFrame and main.ExperienceScrollFrame.ScrollChild and
			main.ExperienceScrollFrame.ScrollChild.ExperienceStatusBar then
			local esb = main.ExperienceScrollFrame.ScrollChild.ExperienceStatusBar
			S:HandleStatusBar(esb)
			if esb.Background then
				esb.Background:SetTexture(nil)
				esb.Background:SetAlpha(0)
			end
			if esb.Overlay then
				esb.Overlay:SetTexture(nil)
				esb.Overlay:SetAlpha(0)
			end
		end

		if main.TakeAllRewardsCheckButton then
			S:HandleCheckBox(main.TakeAllRewardsCheckButton)
			local cb = main.TakeAllRewardsCheckButton
			local function FixDuplicateLabel()
				local first
				for i = 1, (cb:GetNumRegions() or 0) do
					local r = select(i, cb:GetRegions())
					if r and r:GetObjectType() == "FontString" then
						local txt = r.GetText and r:GetText()
						if txt and txt ~= "" then
							if first then
								if r.Hide then
									r:Hide()
								end
							else
								first = r
								if r.Show then
									r:Show()
								end
								local _, size, flags = r:GetFont()
								r:SetFont(E.media.normFont or (select(1, GameFontNormal:GetFont())),
									size and size > 0 and size or 12,
									flags or "")
							end
						end
					end
				end
			end
			FixDuplicateLabel()
			if not cb._Elv_FixDuplicateHooked then
				cb._Elv_FixDuplicateHooked = true
				cb:HookScript("OnShow", FixDuplicateLabel)
			end
		end

		if main.PurchasePremiumButton then
			S:HandleButton(main.PurchasePremiumButton)
		end
		ApplyElvUIFont(main)
	end

	if f.Content and f.Content.QuestPage and f.Content.QuestPage.ScrollFrame and f.Content.QuestPage.ScrollFrame.ScrollBar then
		S:HandleScrollBar(f.Content.QuestPage.ScrollFrame.ScrollBar)
	end
	if f.Content and f.Content.QuestPage then
		ApplyElvUIFont(f.Content.QuestPage)
	end

	if _G.BattlePassQuestMixin and not S._Elv_QuestActionButtonsHooked then
		S._Elv_QuestActionButtonsHooked = true
		hooksecurefunc(_G.BattlePassQuestMixin, "UpdateActionButton", function(self)
			local btn = self.ActionButton
			if btn then
				ReskinPKBTButton(btn)
				if btn.ClearAllPoints then
					btn:ClearAllPoints()
				end
				if self.Progress then
					btn:SetPoint("BOTTOMLEFT", self.Progress, "BOTTOMLEFT", 5, 15)
				else
					btn:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 100, 12)
				end
				btn:Show()
			end
		end)
	end

	if f.PurchasePremiumDialog then
		local d = f.PurchasePremiumDialog
		S:HandleFrame(BattlePassFramePurchasePremiumDialog)
		S:HandleFrame(d)
		if d.CloseButton then
			S:HandleCloseButton(d.CloseButton)
		end
		if d.PurchaseButton then
			S:HandleButton(d.PurchaseButton)
		end
		ApplyElvUIFont(d)
	end

	if f.PurchaseExperienceDialog then
		local d = f.PurchaseExperienceDialog
		S:HandleFrame(BattlePassFramePurchaseLevelExperienceDialog)
		-- d:StripTextures(true)
		-- d:SetTemplate("Transparent")
		if d.CloseButton then
			S:HandleCloseButton(d.CloseButton)
		end
		if d.PurchaseButton then
			CleanPageButton(d.PurchaseButton)
		end
		if d.OptionAmount then
			S:HandleEditBox(d.OptionAmount)
			if d.OptionAmount.Left then
				d.OptionAmount.Left:SetAlpha(0)
			end
			if d.OptionAmount.Right then
				d.OptionAmount.Right:SetAlpha(0)
			end
			if d.OptionAmount.Center then
				d.OptionAmount.Center:SetAlpha(0)
			end
			for i = 1, (d.OptionAmount:GetNumRegions() or 0) do
				local r = select(i, d.OptionAmount:GetRegions())
				if r and r.IsObjectType and r:IsObjectType("Texture") then
					r:SetTexture()
					r:SetAlpha(0)
				end
			end
		end

		if d.NineSlice then
			d.NineSlice:Hide()
		end
		if d.Background then
			d.Background:SetTexture(0, 0, 0, 0)
			d.Background:SetAlpha(0)
		end
		if d.VignetteTopLeft then
			d.VignetteTopLeft:SetTexture(0, 0, 0, 0)
			d.VignetteTopLeft:SetAlpha(0)
		end
		if d.VignetteTopRight then
			d.VignetteTopRight:SetTexture(0, 0, 0, 0)
			d.VignetteTopRight:SetAlpha(0)
		end

		if d.OptionAmount then
			local inc = d.OptionAmount.IncrementButton
			local dec = d.OptionAmount.DecrementButton
			if inc and inc.IsObjectType and inc:IsObjectType("Button") then
				if S.HandleNextPrevButton then
					S:HandleNextPrevButton(inc)
				else
					S:HandleButton(inc)
				end
				if S.SetNextPrevButtonDirection then
					S:SetNextPrevButtonDirection(inc, "right")
				end
				if inc.ClearAllPoints then
					inc:ClearAllPoints()
				end
				if inc.SetPoint then
					inc:SetPoint("RIGHT", d.OptionAmount, "RIGHT", -14, -2)
				end
				if inc.SetSize then
					inc:SetSize(18, 18)
				end
				if d.OptionAmount.GetFrameLevel then
					inc:SetFrameLevel(d.OptionAmount:GetFrameLevel() + 2)
				end
				if inc.Show then
					inc:Show()
				end
			end
			if dec and dec.IsObjectType and dec:IsObjectType("Button") then
				if S.HandleNextPrevButton then
					S:HandleNextPrevButton(dec)
				else
					S:HandleButton(dec)
				end
				if S.SetNextPrevButtonDirection then
					S:SetNextPrevButtonDirection(dec, "left")
				end
				if dec.ClearAllPoints then
					dec:ClearAllPoints()
				end
				if dec.SetPoint then
					dec:SetPoint("LEFT", d.OptionAmount, "LEFT", 14, -2)
				end
				if dec.SetSize then
					dec:SetSize(18, 18)
				end
				if d.OptionAmount.GetFrameLevel then
					dec:SetFrameLevel(d.OptionAmount:GetFrameLevel() + 2)
				end
				if dec.Show then
					dec:Show()
				end
			end
		end
	end

	if f.PurchaseLevelExperienceDialog then
		local d = f.PurchaseLevelExperienceDialog
		S:HandleFrame(BattlePassFramePurchaseLevelExperienceDialog)
		d:StripTextures(true)
		d:SetTemplate("Transparent")
		if d.CloseButton then
			S:HandleCloseButton(d.CloseButton)
		end
		if d.PurchaseButton then
			S:HandleButton(d.PurchaseButton)
		end
		ApplyElvUIFont(d)
	end

	if f.QuestActionDialog then
		local d = f.QuestActionDialog
		d:StripTextures(true)
		d:SetTemplate("Transparent")
		if d.NineSlice then
			d.NineSlice:Hide()
		end
		if d.SetBackdropBorderColor then
			d:SetBackdropBorderColor(0, 0, 0, 0)
		end
		if d.backdrop and d.backdrop.SetBackdropBorderColor then
			d.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
		end
		if d.OkButton then
			S:HandleButton(d.OkButton)
		end
		if d.CancelButton then
			S:HandleButton(d.CancelButton)
		end
		ApplyElvUIFont(d)
	end

	if f.ItemRewardFrame then
		local d = f.ItemRewardFrame
		d:StripTextures(true)
		d:SetTemplate("Transparent")
		if d.CloseButton then
			S:HandleCloseButton(d.CloseButton)
		end
		ApplyElvUIFont(d)
	end

	if f.AlertFrame then
		local d = f.AlertFrame
		d:StripTextures(true)
		d:SetTemplate("Transparent")
		ApplyElvUIFont(d)
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.battlePass ~= true then
		return
	end

	if _G.BattlePassFrame then
		HandleBattlePassFrame()
	else
		local f = CreateFrame("Frame")
		f:RegisterEvent("PLAYER_LOGIN")
		f:SetScript("OnEvent", function(self)
			if _G.BattlePassFrame then
				HandleBattlePassFrame()
				self:UnregisterAllEvents()
			end
		end)
	end
end

S:AddCallback("Custom_BattlePass", LoadSkin)