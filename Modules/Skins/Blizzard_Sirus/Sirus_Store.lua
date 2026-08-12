local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

local _G = _G

local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight

local function GetStoreFrameScale()
	local parentScale = UIParent and UIParent:GetScale() or 1
	if parentScale > 0 and parentScale < 0.7 and (GetScreenWidth() >= 2560 or GetScreenHeight() >= 1440) then
		return 0.75
	end

	return parentScale
end

------------------------------------------------------------------------
-- Shared PKBT helpers (same approach as the BattlePass skin)
------------------------------------------------------------------------

local function ApplyElvUIFont(frame)
	if not frame or not frame.GetNumRegions then return end
	for i = 1, (frame:GetNumRegions() or 0) do
		local r = select(i, frame:GetRegions())
		if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.FontTemplate then
			local _, size, flags = r:GetFont()
			if not size or size < 1 then
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
			if child then ApplyElvUIFont(child) end
		end
	end
end

local function ApplyElvUIFontForce(frame)
	if not frame or not frame.GetObjectType then return end
	for i = 1, (frame:GetNumRegions() or 0) do
		local r = select(i, frame:GetRegions())
		if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.SetFont then
			local _, size, flags = r:GetFont()
			r:SetFont(E.media.normFont or (select(1, GameFontNormal:GetFont())), (size and size >= 1) and size or 12, flags or "")
		end
	end
	for i = 1, (frame:GetNumChildren() or 0) do
		local child = select(i, frame:GetChildren())
		if child then ApplyElvUIFontForce(child) end
	end
end

-- Strip the PKBT three-slice/atlas chrome from a button and give it the
-- ElvUI look. Hooks keep it clean when the client swaps atlas textures.
-- NOTE: the button's content lives in WidgetHolder (AddText/AddTextureAtlas)
-- and the Price/PurchaseNote widgets, so those are left untouched - hiding
-- them makes the button empty.
-- Named PKBT chrome only. Safe to run after the ElvUI backdrop exists;
-- the generic region wipe must never run after the backdrop is created,
-- because the backdrop textures show up in GetRegions and would be wiped.
local function ClearPKBTChrome(b)
	if not b then return end
	if b.Left then b.Left:SetAlpha(0) end
	if b.Right then b.Right:SetAlpha(0) end
	if b.Center then b.Center:SetAlpha(0) end
	if b.LeftHighlight then b.LeftHighlight:SetAlpha(0) end
	if b.RightHighlight then b.RightHighlight:SetAlpha(0) end
	if b.CenterHighlight then b.CenterHighlight:SetAlpha(0) end
	if b.SetNormalTexture then b:SetNormalTexture("") end
	if b.SetHighlightTexture then b:SetHighlightTexture("") end
	if b.SetPushedTexture then b:SetPushedTexture("") end
	if b.SetDisabledTexture then b:SetDisabledTexture("") end
	if b.Glow then b.Glow:Hide() end
end

-- The client re-applies the three-slice/state atlases on every state change
-- (OnShow/OnEnable/OnDisable/SetChecked all go through UpdateButton, which
-- sets the atlases directly and bypasses SetThreeSliceAtlas), so hook all of
-- them to keep the chrome off.
local function HookClearPKBTChrome(btn)
	if btn._Elv_ClearHooks then return end
	btn._Elv_ClearHooks = true

	for _, method in ipairs({
		"SetThreeSliceAtlas", "SetNormalAtlas", "SetHighlightAtlas", "SetPushedAtlas",
		"SetCheckedAtlas", "SetDisabledAtlas", "UpdateButton",
	}) do
		if btn[method] then
			hooksecurefunc(btn, method, function(self) ClearPKBTChrome(self) end)
		end
	end

	btn:HookScript("OnShow", function(self)
		ClearPKBTChrome(self)
		ApplyElvUIFontForce(self)
	end)
end

local function ReskinPKBTButton(btn)
	if not btn or not btn.IsObjectType or not btn:IsObjectType("Button") then return end

	if not btn._Elv_BaseSkinned then
		-- Wipe every leftover atlas texture BEFORE S:HandleButton creates the
		-- ElvUI backdrop, so the catch-all wipe can never touch the backdrop.
		for i = 1, (btn:GetNumRegions() or 0) do
			local r = select(i, btn:GetRegions())
			if r and r.IsObjectType and r:IsObjectType("Texture") then
				r:SetTexture()
				r:SetAlpha(0)
			end
		end

		S:HandleButton(btn, true)
		btn._Elv_BaseSkinned = true
	end

	ClearPKBTChrome(btn)

	ApplyElvUIFontForce(btn)

	HookClearPKBTChrome(btn)
end

------------------------------------------------------------------------
-- Store skin parts
------------------------------------------------------------------------

-- Category buttons keep their icon texture: ReskinPKBTButton wipes ALL
-- direct regions (including the icon) and S:HandleIcon does not restore
-- textures, so use strip=false here and only clear the named chrome.
local function SkinStoreCategoryButton(btn)
	if not btn or not btn.IsObjectType or not btn:IsObjectType("Button") then return end
	if btn._ElvCategorySkinned then return end
	btn._ElvCategorySkinned = true

	S:HandleButton(btn, false)
	ClearPKBTChrome(btn)
	ApplyElvUIFont(btn)
	HookClearPKBTChrome(btn)

	-- top-level category icons are set via SetTexture (UpdateInfo) - the
	-- standard ElvUI icon crop is safe and desired here
	if btn.Icon then
		btn.Icon:SetTexCoord(unpack(E.TexCoords))
	end
	if btn.ButtonText then
		-- font only: the client's UpdateState owns the state colors
		-- (white / hover green / selected gold / disabled gray)
		btn.ButtonText:FontTemplate(nil, nil, "OUTLINE")
	end
	if btn.NewIcon then btn.NewIcon:Hide() end
end

local function SkinStoreSubCategoryButton(btn)
	if not btn or not btn.IsObjectType or not btn:IsObjectType("Button") then return end
	if btn._ElvSubCategorySkinned then return end
	btn._ElvSubCategorySkinned = true

	S:HandleButton(btn, false)
	ClearPKBTChrome(btn)
	ApplyElvUIFont(btn)
	HookClearPKBTChrome(btn)

	-- sub-category icons are ALWAYS atlases (SetAtlas in UpdateInfo) - the
	-- texcoords SetAtlas assigned must be preserved or the icon renders
	-- crooked/blank, so never call SetTexCoord here
	if btn.ButtonText then
		-- font only: the client's UpdateState owns the state colors
		-- (white / hover green / selected gold / disabled gray)
		btn.ButtonText:FontTemplate(nil, nil, "OUTLINE")
	end
	if btn.NewIcon then btn.NewIcon:Hide() end
end

-- Bag buttons on the top panels (Vote / Referral / Loyality). The bag icon
-- IS the button's normal atlas (PKBT-Store-Bag-Portrait), so a generic
-- HandleCheckBox would strip it and leave the button empty. Only the chrome
-- states (pushed/disabled/highlight/checked) are cleared.
local function SkinStoreBagButton(btn)
	if not btn or not btn.IsObjectType or not btn:IsObjectType("CheckButton") then return end
	if btn._ElvBagSkinned then return end
	btn._ElvBagSkinned = true

	local function clearChrome(b)
		if b.SetPushedTexture then b:SetPushedTexture("") end
		if b.SetDisabledTexture then b:SetDisabledTexture("") end
		if b.SetHighlightTexture then b:SetHighlightTexture("") end
		if b.SetCheckedTexture then b:SetCheckedTexture("") end
		if b.SetDisabledCheckedTexture then b:SetDisabledCheckedTexture("") end
	end

	clearChrome(btn)

	if not btn._ElvBagHooked then
		btn._ElvBagHooked = true
		for _, method in ipairs({ "SetPushedAtlas", "SetDisabledAtlas", "SetHighlightAtlas", "SetCheckedAtlas", "SetDisabledCheckedAtlas" }) do
			if btn[method] then
				hooksecurefunc(btn, method, function(self) clearChrome(self) end)
			end
		end
	end
end

-- Tabs keep their icon/text; only the three-slice chrome is cleared.
local function SkinStoreTabButton(btn)
	if not btn or not btn.IsObjectType or not btn:IsObjectType("Button") then return end

	local function clearChrome(b)
		if b.Left then b.Left:SetAlpha(0) end
		if b.Center then b.Center:SetAlpha(0) end
		if b.Right then b.Right:SetAlpha(0) end
		if b.LeftHighlight then b.LeftHighlight:SetAlpha(0) end
		if b.RightHighlight then b.RightHighlight:SetAlpha(0) end
		if b.CenterHighlight then b.CenterHighlight:SetAlpha(0) end
		if b.SetNormalTexture then b:SetNormalTexture("") end
		if b.SetHighlightTexture then b:SetHighlightTexture("") end
		if b.SetPushedTexture then b:SetPushedTexture("") end
		if b.SetDisabledTexture then b:SetDisabledTexture("") end
	end

	-- no strip: keep the tab icon and any non-chrome textures
	S:HandleButton(btn, false)
	clearChrome(btn)
	ApplyElvUIFont(btn)

	if not btn._Elv_TabHooked then
		btn._Elv_TabHooked = true
		if btn.SetThreeSliceAtlas then
			hooksecurefunc(btn, "SetThreeSliceAtlas", function(self) clearChrome(self) end)
		end
		if btn.SetNormalAtlas then
			hooksecurefunc(btn, "SetNormalAtlas", function(self) clearChrome(self) end)
		end
		if btn.SetHighlightAtlas then
			hooksecurefunc(btn, "SetHighlightAtlas", function(self) clearChrome(self) end)
		end
		if btn.SetPushedAtlas then
			hooksecurefunc(btn, "SetPushedAtlas", function(self) clearChrome(self) end)
		end
		btn:HookScript("OnShow", function(self)
			clearChrome(self)
			ApplyElvUIFont(self)
		end)
	end
end

local function SkinStoreRowButton(row)
	if not row then return end
	if row._ElvRowSkinned then return end
	row._ElvRowSkinned = true

	if row.BackgroundLeft then row.BackgroundLeft:SetAlpha(0) end
	if row.BackgroundRight then row.BackgroundRight:SetAlpha(0) end
	if row.BackgroundCenter then row.BackgroundCenter:SetAlpha(0) end
	if row.NineSliceSelection then row.NineSliceSelection:Hide() end
	if row.NineSliceHighlight then row.NineSliceHighlight:Hide() end

	row:CreateBackdrop("Transparent")

	local ht = (row.GetHighlightTexture and row:GetHighlightTexture()) or row.HighlightTexture
	if not ht then
		ht = row:CreateTexture(nil, "HIGHLIGHT")
		ht:SetAllPoints(row)
		row:SetHighlightTexture(ht)
	end
	ht:SetTexture(E.Media.Textures.Highlight)
	ht:SetTexCoord(0, 1, 0, 1)
	ht:SetVertexColor(1, 1, 1, 0.25)

	ApplyElvUIFont(row)

	for i = 1, (row:GetNumChildren() or 0) do
		local child = select(i, row:GetChildren())
		if child then
			ApplyElvUIFont(child)
			if child.Icon then
				S:HandleIcon(child.Icon)
				child.Icon:SetTexCoord(unpack(E.TexCoords))
			end
			if child.Border then child.Border:SetAlpha(0) end
			if child.IconBorder then child.IconBorder:SetAlpha(0) end
			if child.Price then child.Price:StripTextures() end
		end
	end
end

local function SkinStoreList(view)
	if not view then return end

	local list = view.List
	if list then
		if not list._ElvSkinned then
			list._ElvSkinned = true
			list:StripTextures(true)
			list:CreateBackdrop("Transparent")
		end
		if list.Scroll then
			if list.Scroll.ScrollBar then
				S:HandleScrollBar(list.Scroll.ScrollBar)
			end
			for _, row in ipairs(list.Scroll.buttons or {}) do
				SkinStoreRowButton(row)
			end
		end
		ApplyElvUIFont(list)
	end

	local filter = view.Filter
	if filter then
		if not filter._ElvSkinned then
			filter._ElvSkinned = true
			filter:StripTextures(true)
			filter:CreateBackdrop("Transparent")
		end
		if filter.ResetButton then ReskinPKBTButton(filter.ResetButton) end
		local scrollChild = filter.Scroll and filter.Scroll.ScrollChild
		if scrollChild then
			for i = 1, (scrollChild:GetNumChildren() or 0) do
				local child = select(i, scrollChild:GetChildren())
				if child then
					if child.IsObjectType and child:IsObjectType("CheckButton") then
						S:HandleCheckBox(child)
					elseif child.IsObjectType and child:IsObjectType("EditBox") then
						S:HandleEditBox(child)
					end
					ApplyElvUIFont(child)
				end
			end
		end
		ApplyElvUIFont(filter)
	end

	local header = view.PageHeader
	if header then
		if not header._ElvSkinned then
			header._ElvSkinned = true
			header:StripTextures(true)
			header:CreateBackdrop("Transparent")
		end
		if header.RefreshButton then ReskinPKBTButton(header.RefreshButton) end
		if header.Title then header.Title:FontTemplate(nil, 18, "OUTLINE") end
		ApplyElvUIFont(header)
	end
end

local function SkinStoreDialog(dialog)
	if not dialog or not dialog.IsObjectType or not dialog:IsObjectType("Frame") then return end
	if dialog._ElvDialogSkinned then return end
	dialog._ElvDialogSkinned = true

	dialog:StripTextures(true)

	if dialog.NineSlice then dialog.NineSlice:Hide() end
	if dialog.Background then dialog.Background:SetAlpha(0) end
	if dialog.VignetteTopLeft then dialog.VignetteTopLeft:SetAlpha(0) end
	if dialog.VignetteTopRight then dialog.VignetteTopRight:SetAlpha(0) end
	if dialog.VignetteBottomLeft then dialog.VignetteBottomLeft:SetAlpha(0) end
	if dialog.VignetteBottomRight then dialog.VignetteBottomRight:SetAlpha(0) end

	if dialog.TitleContainer then
		dialog.TitleContainer:StripTextures(true)
		if dialog.TitleContainer.TitleText then
			dialog.TitleContainer.TitleText:FontTemplate(nil, 18, "OUTLINE")
			dialog.TitleContainer.TitleText:SetTextColor(unpack(E.media.rgbvaluecolor))
		end
	end

	if dialog.CloseButton then S:HandleCloseButton(dialog.CloseButton) end

	dialog:SetTemplate("Transparent")

	for _, key in ipairs({ "PurchaseButton", "BuyButton", "ActionButton", "AgreeButton", "InviteButton", "InfoButton", "OkButton", "CancelButton", "AcceptButton", "BackButton", "DetailsButton" }) do
		local btn = dialog[key]
		-- Price/widget content is never hidden by ReskinPKBTButton
		if btn then ReskinPKBTButton(btn) end
	end

	ApplyElvUIFont(dialog)
end

local function HandleStoreFrame()
	local f = _G.StoreFrame
	if not f then return end

	if not f._ElvMainSkinned then
		f._ElvMainSkinned = true

		-- PKBT panel chrome -> ElvUI backdrop
		f:StripTextures(true)
		if f.NineSlice then f.NineSlice:Hide() end
		if f.DecorOverlay then f.DecorOverlay:Hide() end
		if f.TopTileStreaks then f.TopTileStreaks:SetAlpha(0) end

		f:CreateBackdrop("Transparent")

		if f.CloseButton then S:HandleCloseButton(f.CloseButton) end

		if f.TitleContainer then
			f.TitleContainer:StripTextures(true)
			if f.TitleContainer.TitleText then
				f.TitleContainer.TitleText:FontTemplate(nil, 20, "OUTLINE")
				f.TitleContainer.TitleText:SetTextColor(unpack(E.media.rgbvaluecolor))
			end
		end
	end

	-- Top panel (account info + currencies + progress)
	local top = f.TopPanel
	if top then
		if not top._ElvSkinned then
			top._ElvSkinned = true
			top:StripTextures(true)
			top:CreateBackdrop("Transparent")
		end

		if top.AccountPanel then
			local portrait = top.AccountPanel.PortraitContainer
			if portrait and portrait.Ring then
				portrait.Ring:SetAlpha(0)
			end
			ApplyElvUIFont(top.AccountPanel)
		end

		for _, panel in ipairs({ top.BalancePanel, top.VotePanel }) do
			if panel then
				if panel.Divider then panel.Divider:Hide() end
				if panel.Button then ReskinPKBTButton(panel.Button) end
				if panel.BrowseButton then SkinStoreBagButton(panel.BrowseButton) end
				ApplyElvUIFont(panel)
			end
		end

		for _, panel in ipairs({ top.LoyalityPanel, top.ReferralPanel }) do
			if panel then
				if panel.Divider then panel.Divider:Hide() end
				if panel.StatusBar then S:HandleStatusBar(panel.StatusBar) end
				if panel.BrowseButton then SkinStoreBagButton(panel.BrowseButton) end
				if panel.AddButton then ReskinPKBTButton(panel.AddButton) end
				ApplyElvUIFont(panel)
			end
		end
	end

	-- Left panel (nav + premium + subscription tracker)
	local left = f.LeftPanel
	if left then
		if left.NavPanel then
			local nav = left.NavPanel
			if not nav._ElvSkinned then
				nav._ElvSkinned = true
				nav:StripTextures(true)
				nav:CreateBackdrop("Transparent")
			end
			ApplyElvUIFont(nav)
		end

		if left.PremiumPanel then
			local premium = left.PremiumPanel
			if not premium._ElvSkinned then
				premium._ElvSkinned = true
				premium:StripTextures(true)
				premium:CreateBackdrop("Transparent")
			end
			if premium.Purchase then ReskinPKBTButton(premium.Purchase) end
		end

		if left.SubscriptionTracker then
			local tracker = left.SubscriptionTracker
			if not tracker._ElvSkinned then
				tracker._ElvSkinned = true
				tracker:StripTextures(true)
				tracker:CreateBackdrop("Transparent")
			end
			if tracker.Artwork then tracker.Artwork:Hide() end
			if tracker.ActionButton then ReskinPKBTButton(tracker.ActionButton) end
			ApplyElvUIFont(tracker)
		end
	end

	-- Content area
	local content = f.Content
	if content then
		if not content._ElvSkinned then
			content._ElvSkinned = true
			content:StripTextures(true)
			if content.NineSliceInset then content.NineSliceInset:Hide() end
			content:CreateBackdrop("Transparent")
		end
		ApplyElvUIFont(content)
	end

	-- Dialogs
	for _, dialog in ipairs({ f.LinkDialog, f.AgreementDialog, f.ReferralInviteDialog, f.PremiumPurchaseDialog, f.ProductPurchaseDialogSecondary }) do
		SkinStoreDialog(dialog)
	end

	if f.dialogFramePool then
		for dialog in f.dialogFramePool:EnumerateActive() do
			SkinStoreDialog(dialog)
		end
	end

	-- Promo code frame
	local promo = _G.PromoCodeFrame
	if promo and not promo._ElvSkinned then
		promo._ElvSkinned = true
		promo:StripTextures(true)
		if promo.NineSlice then promo.NineSlice:Hide() end
		if promo.Background then promo.Background:SetAlpha(0) end
		promo:SetTemplate("Transparent")
		if promo.CloseButton then S:HandleCloseButton(promo.CloseButton) end
		if promo.Content then
			if promo.Content.Code and promo.Content.Code.EditBox then
				S:HandleEditBox(promo.Content.Code.EditBox)
			end
			if promo.Content.ActionButton then ReskinPKBTButton(promo.Content.ActionButton) end
			if promo.Content.Scroll and promo.Content.Scroll.ScrollBar then
				S:HandleScrollBar(promo.Content.Scroll.ScrollBar)
			end
			ApplyElvUIFont(promo.Content)
		end
	end
end

local function HookStore()
	-- IMPORTANT: StoreFrame and its children Mixin() their methods at login,
	-- copying them onto the frame instances. hooksecurefunc on the mixin tables
	-- would therefore never fire for those instances - the hooks must be placed
	-- on the frame instances themselves. Mixins are only safe to hook for frames
	-- created AFTER this runs (SubCategoryMenu, recommendation cards), because
	-- those copy the already-hooked method at creation time.
	local storeFrame = _G.StoreFrame
	if storeFrame then
		if not S._Elv_StoreInstanceHooked then
			S._Elv_StoreInstanceHooked = true

			hooksecurefunc(storeFrame, "UpdateCategoryButtons", function(self)
				for _, button in ipairs(self.categoryButtons or {}) do
					SkinStoreCategoryButton(button)
				end
			end)

			hooksecurefunc(storeFrame, "ShowDialogWidget", function(self, widgetType, parent, preShowCallback)
				local dialog = self:GetDialogWidget(widgetType)
				if dialog then SkinStoreDialog(dialog) end
			end)

			hooksecurefunc(storeFrame, "ShowGenericDialog", function(self)
				if self.dialogFramePool then
					for dialog in self.dialogFramePool:EnumerateActive() do
						SkinStoreDialog(dialog)
					end
				end
			end)
		end

		local itemListView = storeFrame.ItemListView
		if itemListView and not S._Elv_StoreListViewHooked then
			S._Elv_StoreListViewHooked = true

			local function SkinListView(self)
				SkinStoreList(self)
			end

			hooksecurefunc(itemListView, "UpdateViewTable", SkinListView)
			hooksecurefunc(itemListView, "OnItemScrollUpdate", SkinListView)
			hooksecurefunc(itemListView, "OnShow", SkinListView)
		end

		local pageCollections = storeFrame.Content and storeFrame.Content.PageCollections
		if pageCollections and not S._Elv_StoreTabsHooked then
			S._Elv_StoreTabsHooked = true
			hooksecurefunc(pageCollections, "UpdateTabs", function(self)
				for _, btn in pairs(self.tabButtons or {}) do
					if btn then SkinStoreTabButton(btn) end
				end
			end)
		end

		local specialOffer = storeFrame.Content and storeFrame.Content.PageMain and storeFrame.Content.PageMain.SpecialPanel and storeFrame.Content.PageMain.SpecialPanel.Banner and storeFrame.Content.PageMain.SpecialPanel.Banner.Offer
		if specialOffer and not S._Elv_StoreSpecialOfferHooked then
			S._Elv_StoreSpecialOfferHooked = true
			hooksecurefunc(specialOffer, "OnShow", function(self)
				if self.PurchaseButton then ReskinPKBTButton(self.PurchaseButton) end
				if self.DetailsButton then ReskinPKBTButton(self.DetailsButton) end
				if self.ActionButton then ReskinPKBTButton(self.ActionButton) end
			end)
		end

		local refundView = storeFrame.RefundView
		if refundView and not S._Elv_StoreRefundHooked then
			S._Elv_StoreRefundHooked = true
			hooksecurefunc(refundView, "OnShow", function(self)
				if self.RefundButton then ReskinPKBTButton(self.RefundButton) end
				if self.Scroll then
					for _, row in ipairs(self.Scroll.buttons or {}) do
						if not row._ElvRefundRowSkinned then
							row._ElvRefundRowSkinned = true
							row:StripTextures()
							row:CreateBackdrop("Transparent")
							if row.CheckButton then S:HandleCheckBox(row.CheckButton) end
							if row.Item and row.Item.Icon then S:HandleIcon(row.Item.Icon) end
							if row.Price then row.Price:StripTextures() end
							ApplyElvUIFont(row)
						end
					end
				end
			end)
		end
	end

	-- Runtime-created frames: SubCategoryMenu (created with the category buttons)
	-- and recommendation cards (created from a pool) copy the mixin methods at
	-- creation time, so the mixin hooks DO fire for them.
	if _G.StoreCategorySubMenuMixin and not S._Elv_StoreSubMenuHooked then
		S._Elv_StoreSubMenuHooked = true

		hooksecurefunc(_G.StoreCategorySubMenuMixin, "UpdateSubCategories", function(self)
			for _, button in ipairs(self.subCategoryButtons or {}) do
				SkinStoreSubCategoryButton(button)
			end
		end)
	end

	if _G.StoreRecommendationMixin and not S._Elv_StoreRecommendationHooked then
		S._Elv_StoreRecommendationHooked = true
		hooksecurefunc(_G.StoreRecommendationMixin, "OnShow", function(self)
			if self.PurchaseButton then ReskinPKBTButton(self.PurchaseButton) end
			if self.DetailsButton then ReskinPKBTButton(self.DetailsButton) end
		end)
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.store ~= true then return end

	local function ApplySkin()
		StoreFrame:HookScript("OnShow", function()
			StoreFrame:SetScale(GetStoreFrameScale())
		end)
		StoreFrame:EnableMouse(true)
		StoreFrame:SetMovable(true)
		StoreFrame:RegisterForDrag("LeftButton")
		StoreFrame:SetScript("OnDragStart", function(self)
			self:StartMoving()
		end)
		StoreFrame:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			local frame_x, frame_y = self:GetCenter()
			frame_x = frame_x*UIParent:GetScale() - GetScreenWidth() / 2
			frame_y = frame_y*UIParent:GetScale() - GetScreenHeight() / 2
			self:ClearAllPoints()
			self:SetPoint("CENTER", UIParent, "CENTER", frame_x, frame_y)
		end)

		HandleStoreFrame()
		HookStore()
		StoreFrame:HookScript("OnShow", function()
			HandleStoreFrame()
		end)
	end

	if _G.StoreFrame then
		ApplySkin()
	else
		local f = CreateFrame("Frame")
		f:RegisterEvent("PLAYER_LOGIN")
		f:SetScript("OnEvent", function(self)
			if _G.StoreFrame then
				ApplySkin()
				self:UnregisterAllEvents()
			end
		end)
	end
end

S:AddCallback("Sirus_Store", LoadSkin)
