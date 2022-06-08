local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
    BlackMarketFrame:StripTextures()
    BlackMarketFrameInset:StripTextures()
    BlackMarketFrame.Artwork:StripTextures()
    BlackMarketFrame.art:StripTextures()
    BlackMarketScrollFrameButton8Selection:StripTextures()
    BlackMarketFrameMoneyFrameBorder:StripTextures()

    for _,button in pairs(BlackMarketScrollFrame.buttons) do

        button:StripTextures()
        S:HandleButton(button)
        for k,v in pairs(button) do
            if k == "Item" then
                S:HandleItemButton(v)
            end
        end
    end

    BlackMarketFrame:CreateBackdrop("Trasparent")
    S:HandleScrollBar(BlackMarketScrollFrameScrollBar)
    S:HandleCloseButton(BlackMarketFrame.CloseButton)
    S:HandleButton(BlackMarketFrameColumnName)
    S:HandleButton(BlackMarketFrameColumnLevel)
    S:HandleButton(BlackMarketFrameColumnType)
    S:HandleButton(BlackMarketFrameColumnDuration)
    S:HandleButton(BlackMarketFrameColumnHighBidder)
    S:HandleButton(BlackMarketFrameColumnCurrentBid)
    S:HandleButton(BlackMarketFrameBidButton)
    S:HandleEditBox(BlackMarketBidPriceGold)

end

S:AddCallback("Sirus_BlackMarket", LoadSkin)