local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local function StyleTutorialButton(btn)
    if not btn then return end
    if btn.backdrop then btn.backdrop:Hide() end
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
    if btn.SetHitRectInsets then btn:SetHitRectInsets(4, 4, 4, 4) end
end

local function CleanPageButton(btn)
    if not btn then return end
    S:HandleButton(btn)

    if btn.GetNormalTexture then btn:SetNormalTexture("") end
    if btn.GetPushedTexture then btn:SetPushedTexture("") end
    if btn.GetHighlightTexture then
        local ht = btn:GetHighlightTexture()
        if ht then ht:SetTexture() ht:SetAlpha(0) end
        btn:SetHighlightTexture("")
    end

    if btn.Background then btn.Background:SetTexture(0,0,0,0) btn.Background:SetAlpha(0) end
    if btn.DisabledBackground then btn.DisabledBackground:SetTexture(0,0,0,0) btn.DisabledBackground:SetAlpha(0) end

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
            if ht then ht:SetTexture() ht:SetAlpha(0) end
        end
        if self.Background then self.Background:SetTexture(0,0,0,0) self.Background:SetAlpha(0) end
        if self.DisabledBackground then self.DisabledBackground:SetTexture(0,0,0,0) self.DisabledBackground:SetAlpha(0) end
        for i = 1, (self:GetNumRegions() or 0) do
            local r = select(i, self:GetRegions())
            if r and r.IsObjectType and r:IsObjectType("Texture") then
                r:SetTexture()
                r:SetAlpha(0)
            end
        end
    end)
end

local function HandleBattlePassFrame()
    if not _G.BattlePassFrame then return end

    local f = _G.BattlePassFrame

    f:StripTextures(true)
    f:SetTemplate("NoBackdrop")
    if f.NineSlice then f.NineSlice:Hide() end
    f:CreateBackdrop("Transparent")
    if f.backdrop then
        f.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
    end
    f:SetScale(0.67)
    if f.Inset then
        if f.Inset.NineSlice then f.Inset.NineSlice:Hide() end
        if f.Inset.Top then f.Inset.Top:SetTexture(0,0,0,0) end
        if f.Inset.Middle then f.Inset.Middle:SetTexture(0,0,0,0) end
        if f.Inset.Bottom then f.Inset.Bottom:SetTexture(0,0,0,0) end
        if f.Inset.NineSliceBorder then f.Inset.NineSliceBorder:Hide() end
        if f.Inset.NineSliceGlow then f.Inset.NineSliceGlow:Hide() end
        if f.Inset.ShadowLeft then f.Inset.ShadowLeft:SetTexture(0,0,0,0) end
        if f.Inset.ShadowRight then f.Inset.ShadowRight:SetTexture(0,0,0,0) end
        if f.Inset.VignetteTopRight then f.Inset.VignetteTopRight:SetTexture(0,0,0,0) end
        if f.Inset.VignetteBottomLeft then f.Inset.VignetteBottomLeft:SetTexture(0,0,0,0) end
        if f.Inset.VignetteBottomRight then f.Inset.VignetteBottomRight:SetTexture(0,0,0,0) end
        if f.Inset.ArtworkBottomLeft then f.Inset.ArtworkBottomLeft:SetTexture(0,0,0,0) end
        if f.Inset.DecorOverlay then f.Inset.DecorOverlay:Hide() end
    end

    if f.CloseButton then
        S:HandleCloseButton(f.CloseButton)
    end

    if f.TopPanel then
        if f.TopPanel.SeasonTimer then
            local st = f.TopPanel.SeasonTimer
            if st.TimeLeft then st.TimeLeft:FontTemplate(nil, 18, "NONE") end
            if st.TimeLeftLabel then st.TimeLeftLabel:FontTemplate(nil, 12, "NONE") end
        end

        if f.TopPanel.ExperiencePanel then
            local ep = f.TopPanel.ExperiencePanel
            if ep.PurchaseButton then CleanPageButton(ep.PurchaseButton) end
            if ep.StatusBar then S:HandleStatusBar(ep.StatusBar) end
        end

        if f.TopPanel.RewardPageButton then CleanPageButton(f.TopPanel.RewardPageButton) end
        if f.TopPanel.QuestPageButton then CleanPageButton(f.TopPanel.QuestPageButton) end
        if f.TopPanel.Tutorial then StyleTutorialButton(f.TopPanel.Tutorial) end
    end

    if f.Content and f.Content.MainPage then
        local main = f.Content.MainPage
        if main.ScrollFrame and main.ScrollFrame.ScrollBar then
            S:HandleScrollBar(main.ScrollFrame.ScrollBar, true)
        end
        if main.ExperienceScrollFrame and main.ExperienceScrollFrame.ScrollChild and main.ExperienceScrollFrame.ScrollChild.ExperienceStatusBar then
            S:HandleStatusBar(main.ExperienceScrollFrame.ScrollChild.ExperienceStatusBar)
        end

        if main.TakeAllRewardsCheckButton then
            S:HandleCheckBox(main.TakeAllRewardsCheckButton)
        end

        if main.PurchasePremiumButton then
            S:HandleButton(main.PurchasePremiumButton)
        end
    end

    if f.PurchasePremiumDialog then
        local d = f.PurchasePremiumDialog
        d:StripTextures(true)
        d:SetTemplate("Transparent")
        if d.CloseButton then S:HandleCloseButton(d.CloseButton) end
        if d.PurchaseButton then S:HandleButton(d.PurchaseButton) end
    end

    if f.PurchaseExperienceDialog then
        local d = f.PurchaseExperienceDialog
        d:StripTextures(true)
        d:SetTemplate("Transparent")
        if d.CloseButton then S:HandleCloseButton(d.CloseButton) end
        if d.PurchaseButton then S:HandleButton(d.PurchaseButton) end
        if d.OptionAmount then S:HandleEditBox(d.OptionAmount) end
    end

    if f.PurchaseLevelExperienceDialog then
        local d = f.PurchaseLevelExperienceDialog
        d:StripTextures(true)
        d:SetTemplate("Transparent")
        if d.CloseButton then S:HandleCloseButton(d.CloseButton) end
        if d.PurchaseButton then S:HandleButton(d.PurchaseButton) end
    end

    if f.ItemRewardFrame then
        local d = f.ItemRewardFrame
        d:StripTextures(true)
        d:SetTemplate("Transparent")
        if d.CloseButton then S:HandleCloseButton(d.CloseButton) end
    end

    if f.AlertFrame then
        local d = f.AlertFrame
        d:StripTextures(true)
        d:SetTemplate("Transparent")
    end
end

local function LoadSkin()
    if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.battlePass ~= true then return end

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


