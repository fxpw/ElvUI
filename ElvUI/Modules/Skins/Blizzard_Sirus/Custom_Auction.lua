local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

local _G = _G
local pairs, ipairs, select = pairs, ipairs, select
local hooksecurefunc = hooksecurefunc
local unpack = unpack




local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.auctionhouse then return end
	--tab
	S:HandleTab(AuctionHouseFrameBuyTab)
	S:HandleTab(AuctionHouseFrameSellTab)
	S:HandleTab(AuctionHouseFrameAuctionsTab)

		--buy tab
			--frames
				AuctionHouseFrame:StripTextures()
				AuctionHouseFrame:CreateBackdrop("Transparent")
				--browseframe
					AuctionHouseFrameBrowseResultsFrameItemListScrollFrame:StripTextures()
					AuctionHouseFrameBrowseResultsFrameItemListScrollFrame:CreateBackdrop("Transparent")

				--buy tab
					AuctionHouseFrameBrowseResultsFrameItemList:StripTextures()
					AuctionHouseFrameBrowseResultsFrameItemListNineSlice:StripTextures()
				--money
					AuctionHouseFrameMoneyFrame:StripTextures()
					--AuctionHouseFrameMoneyFrame:CreateBackdrop("Transparent")
					AuctionHouseFrameMoneyFrameBorder:StripTextures()
					AuctionHouseFrameMoneyFrameBorderMoneyFrame:StripTextures()
				--category
					AuctionHouseFrameCategoriesListNineSlice:StripTextures()
					AuctionHouseFrameCategoriesList:StripTextures()
					--AuctionHouseFrameCategoriesListScrollFrameScrollChildFrame:StripTextures()
					--AuctionHouseFrameCategoriesListScrollFrameScrollChildFrame:CreateBackdrop("Transparent")
					AuctionHouseFrameCategoriesListScrollFrame:StripTextures()
				--results
					AuctionHouseFrameItemBuyFrameItemListScrollFrame:StripTextures()
					AuctionHouseFrameItemBuyFrameItemListScrollFrame:CreateBackdrop("Transparent")
					AuctionHouseFrameItemBuyFrameItemList:StripTextures()
					AuctionHouseFrameItemBuyFrameItemList:CreateBackdrop("Transparent")
					----------hook
					function aucpanitemlistnineslice_OnShow(self)
							AuctionHouseFrameItemBuyFrameItemListNineSlice:StripTextures()
							AuctionHouseFrameItemBuyFrameItemListNineSlice:CreateBackdrop("Transparent")
							S:HandleEditBox(AuctionHouseFrameItemBuyFrameBidFrameBidAmountGold)
							S:HandleEditBox(AuctionHouseFrameItemBuyFrameBidFrameBidAmountSilver)
							aucfpanelbidbut1_OnShow(self)

					end
					local aucpanitemlistnineslice = AuctionHouseFrameItemBuyFrameItemListHeaderContainer
					aucpanitemlistnineslice:HookScript("OnUpdate", aucpanitemlistnineslice_OnShow)
					--
					AuctionHouseFrameItemBuyFrameItemDisplay:StripTextures()
					AuctionHouseFrameItemBuyFrameItemDisplay:CreateBackdrop("Transparent")
					AuctionHouseFrameItemBuyFrameItemDisplayNineSlice:StripTextures()
					AuctionHouseFrameItemBuyFrameItemDisplayNineSlice:CreateBackdrop("Transparent")
				--2results
					--but
						S:HandleButton(AuctionHouseFrameCommoditiesBuyFrameBackButton, true)
						S:HandleButton(AuctionHouseFrameCommoditiesBuyFrameBuyDisplayBuyButton, true)
						S:HandleButton(AuctionHouseFrameCommoditiesBuyFrameItemListRefreshFrameRefreshButton)
					--scrollbar
						S:HandleScrollBar(AuctionHouseFrameCommoditiesBuyFrameItemListScrollFrameScrollBar)
						AuctionHouseFrameCommoditiesBuyFrameItemListScrollFrameScrollBar:ClearAllPoints()
						AuctionHouseFrameCommoditiesBuyFrameItemListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameCommoditiesBuyFrameItemListScrollFrame, "TOPRIGHT", 6, -15)
						AuctionHouseFrameCommoditiesBuyFrameItemListScrollFrameScrollBar:Height(355)

					--frame
						AuctionHouseFrameCommoditiesBuyFrameBuyDisplay:StripTextures()
						AuctionHouseFrameCommoditiesBuyFrameBuyDisplay:CreateBackdrop("Transparent")
						AuctionHouseFrameCommoditiesBuyFrameBuyDisplayNineSlice:StripTextures()
						AuctionHouseFrameCommoditiesBuyFrameBuyDisplayNineSlice:CreateBackdrop("Transparent")

						AuctionHouseFrameCommoditiesBuyFrameItemListScrollFrame:StripTextures()
						AuctionHouseFrameCommoditiesBuyFrameItemListScrollFrame:CreateBackdrop("Transparent")
						AuctionHouseFrameCommoditiesBuyFrameItemList:StripTextures()
						AuctionHouseFrameCommoditiesBuyFrameItemList:CreateBackdrop("Transparent")
						AuctionHouseFrameCommoditiesBuyFrameItemListNineSlice:StripTextures()
						AuctionHouseFrameCommoditiesBuyFrameItemListNineSlice:CreateBackdrop("Transparent")

						AuctionHouseFrameCommoditiesBuyFrameBuyDisplayItemDisplay:StripTextures()
						AuctionHouseFrameCommoditiesBuyFrameBuyDisplayItemDisplay:CreateBackdrop("Transparent")
						AuctionHouseFrameCommoditiesBuyFrameBuyDisplay:StripTextures()
						AuctionHouseFrameCommoditiesBuyFrameBuyDisplay:CreateBackdrop("Transparent")
						AuctionHouseFrameCommoditiesBuyFrameBuyDisplayNineSlice:StripTextures()
						AuctionHouseFrameCommoditiesBuyFrameBuyDisplayNineSlice:CreateBackdrop("Transparent")

						S:HandleEditBox(AuctionHouseFrameCommoditiesBuyFrameBuyDisplayQuantityInputInputBox)


			--scrollbar
				AuctionHouseFrameCategoriesListScrollFrameScrollBar:StripTextures()
				S:HandleScrollBar(AuctionHouseFrameBrowseResultsFrameItemListScrollFrameScrollBar)
				AuctionHouseFrameBrowseResultsFrameItemListScrollFrameScrollBar:ClearAllPoints()
				AuctionHouseFrameBrowseResultsFrameItemListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameBrowseResultsFrameItemListScrollFrame, "TOPRIGHT", 6, -20)
				AuctionHouseFrameBrowseResultsFrameItemListScrollFrameScrollBar:Height(370)



				S:HandleScrollBar(AuctionHouseFrameCategoriesListScrollFrameScrollBar)
				S:HandleScrollBar(AuctionHouseFrameItemBuyFrameItemListScrollFrameScrollBar)
				AuctionHouseFrameItemBuyFrameItemListScrollFrameScrollBar:ClearAllPoints()
				AuctionHouseFrameItemBuyFrameItemListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameItemBuyFrameItemListScrollFrame, "TOPRIGHT", 6, -20)
				AuctionHouseFrameItemBuyFrameItemListScrollFrameScrollBar:Height(230)

			--button
				S:HandleButton(AuctionHouseFrameSearchBarSearchButton, true)
				AuctionHouseFrameSearchBarFilterButton:StripTextures(true)
				S:HandleButton(AuctionHouseFrameSearchBarFilterButton, true)
				S:HandleCloseButton(AuctionHouseFrameCloseButton)
				S:HandleButton(AuctionHouseFrameSearchBarFavoritesSearchButton)
				-- 1

				S:HandleButton(AuctionHouseFrameItemBuyFrameBackButton)
				S:HandleButton(AuctionHouseFrameItemBuyFrameBuyoutFrameBuyoutButton)
				S:HandleButton(AuctionHouseFrameItemBuyFrameBidFrameBidButton)
				S:HandleButton(AuctionHouseFrameItemBuyFrameItemListRefreshFrameRefreshButton)

			--Search
				AuctionHouseFrameSearchBarSearchBox:StripTextures(true)
				S:HandleEditBox(AuctionHouseFrameSearchBarSearchBox)
				-- edit box

--					AuctionHouseFrameItemBuyFrameBidFraameBidAmountGold:Width(70)
--					AuctionHouseFrameItemBuyFrameBidFraameBidAmountGold:Height(20)

		--sell tab
			--frames
				--right side
					--first look(next 1st)
					AuctionHouseFrameItemSellListScrollFrame:StripTextures()
					AuctionHouseFrameItemSellListScrollFrame:CreateBackdrop("Transparent")
					AuctionHouseFrameItemSellList:StripTextures()
					AuctionHouseFrameItemSellListNineSlice:StripTextures()
					-- when has item(next 2nd)
					AuctionHouseFrameCommoditiesSellListScrollFrame:StripTextures()
					AuctionHouseFrameCommoditiesSellListScrollFrame:CreateBackdrop("Transparent")
					AuctionHouseFrameCommoditiesSellList:StripTextures()
					AuctionHouseFrameCommoditiesSellListNineSlice:StripTextures()
				--leftside
					--1st
						AuctionHouseFrameItemSellFrameOverlay:StripTextures()
						AuctionHouseFrameItemSellFrame:StripTextures()
						AuctionHouseFrameItemSellFrame:CreateBackdrop("Transparent")
						AuctionHouseFrameItemSellFrameNineSlice:StripTextures()
							--topleft
								AuctionHouseFrameItemSellFrameItemDisplay:StripTextures()
								-- AuctionHouseFrameItemSellFrameItemDisplay:CreateBackdrop("Transparent")
							--button
								-- S:HandleButton(AuctionHouseFrameItemSellFrameItemDisplayItemButton)
								AuctionHouseFrameItemSellFrameItemDisplayItemButtonIconBorder:StripTextures()
								AuctionHouseFrameItemSellFrameItemDisplayItemButtonEmptyBackground:StripTextures()
								S:HandleIcon(AuctionHouseFrameItemSellFrameItemDisplayItemButton.Icon)
					--2nd
						AuctionHouseFrameCommoditiesSellFrameOverlay:StripTextures()
						AuctionHouseFrameCommoditiesSellFrame:StripTextures()
						AuctionHouseFrameCommoditiesSellFrame:CreateBackdrop("Transparent")
						AuctionHouseFrameCommoditiesSellFrameNineSlice:StripTextures()
							--topleft
								AuctionHouseFrameCommoditiesSellFrameItemDisplay:StripTextures()
								AuctionHouseFrameCommoditiesSellFrameItemDisplay:CreateBackdrop("Transparent")
							--button
								-- S:HandleButton(AuctionHouseFrameCommoditiesSellFrameItemDisplayItemButton)
								AuctionHouseFrameCommoditiesSellFrameItemDisplayItemButtonIconBorder:StripTextures()
								AuctionHouseFrameCommoditiesSellFrameItemDisplayItemButtonEmptyBackground:StripTextures()
								-- AuctionHouseFrameCommoditiesSellFrameItemDisplayItemButtonIcon:SetDrawLayer("BORDER")
								S:HandleIcon(AuctionHouseFrameCommoditiesSellFrameItemDisplayItemButton.Icon)
			--scrollbar
				--1st
					S:HandleScrollBar(AuctionHouseFrameItemSellListScrollFrameScrollBar)
					AuctionHouseFrameItemSellListScrollFrameScrollBar:ClearAllPoints()
					AuctionHouseFrameItemSellListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameItemSellListScrollFrame, "TOPRIGHT", 4, -20)
					AuctionHouseFrameItemSellListScrollFrameScrollBar:Height(370)

				--2nd
					S:HandleScrollBar(AuctionHouseFrameCommoditiesSellListScrollFrameScrollBar)
					-- AuctionHouseFrameCommoditiesSellListScrollFrameScrollBar:ClearAllPoints()
					-- AuctionHouseFrameCommoditiesSellListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameCommoditiesSellListScrollFrame, "TOPRIGHT", 4, -20)
					-- AuctionHouseFrameCommoditiesSellListScrollFrameScrollBar:Height(370)

			--button
				S:HandleButton(AuctionHouseFrame.CommoditiesSellFrame.PostButton)
				S:HandleButton(AuctionHouseFrame.ItemSellFrame.PostButton)
				S:HandleButton(AuctionHouseFrameItemSellFrameQuantityInputMaxButton)
				S:HandleButton(AuctionHouseFrameCommoditiesSellFrameQuantityInputMaxButton)
				--refresh
					S:HandleButton(AuctionHouseFrameItemSellListRefreshFrameRefreshButton)
					S:HandleButton(AuctionHouseFrameCommoditiesSellListRefreshFrameRefreshButton)
			--dropdown
				S:HandleDropDownBox(AuctionHouseFrameItemSellFrameDurationDropDownDropDown)
				local dropdownArrowColor = {1, 0.8, 0}
				S:HandleNextPrevButton(AuctionHouseFrameItemSellFrameDurationDropDownDropDownButton, "down", dropdownArrowColor)
				AuctionHouseFrameItemSellFrameDurationDropDownDropDownButton:Size(20)
			--CommoditiesSellFrame
				S:HandleDropDownBox(AuctionHouseFrameCommoditiesSellFrameDurationDropDownDropDown)
				local dropdownArrowColor = {1, 0.8, 0}
				S:HandleNextPrevButton(AuctionHouseFrameCommoditiesSellFrameDurationDropDownDropDownButton, "down", dropdownArrowColor)
				AuctionHouseFrameCommoditiesSellFrameDurationDropDownDropDownButton:Size(20)
			--check
				S:HandleCheckBox(AuctionHouseFrameItemSellFrameBuyoutModeCheckButton)
				AuctionHouseFrameItemSellFrameBuyoutModeCheckButton:Height(24)
				AuctionHouseFrameItemSellFrameBuyoutModeCheckButton:Width(24)
			--editbox
				--1st
					S:HandleEditBox(AuctionHouseFrameItemSellFrameQuantityInputInputBox)

					S:HandleEditBox(AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameGoldBox)
					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameGoldBox:ClearAllPoints()
					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameGoldBox:SetPoint("TOPLEFT", AuctionHouseFrameItemSellFramePriceInput, "TOPRIGHT", -90, 0)
					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameGoldBox:Width(85)
					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameGoldBox:Height(25)

					S:HandleEditBox(AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameSilverBox)
					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameSilverBox:ClearAllPoints()
					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameSilverBox:SetPoint("TOPLEFT", AuctionHouseFrameItemSellFramePriceInput, "TOPRIGHT", 0, 0)
					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameSilverBox:Width(60)
					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameSilverBox:Height(24)

					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameSilverBoxIcon:ClearAllPoints()
					AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameSilverBoxIcon:SetPoint("TOPLEFT", AuctionHouseFrameItemSellFramePriceInputMoneyInputFrameSilverBox, "TOPRIGHT", -30, -4)
					--
					S:HandleEditBox(AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameGoldBox)
					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameGoldBox:ClearAllPoints()
					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameGoldBox:SetPoint("TOPLEFT", AuctionHouseFrameItemSellFrameSecondaryPriceInput, "TOPRIGHT", -190, 0)
					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameGoldBox:Width(85)
					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameGoldBox:Height(25)

					S:HandleEditBox(AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameSilverBox)
					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameSilverBox:ClearAllPoints()
					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameSilverBox:SetPoint("TOPLEFT", AuctionHouseFrameItemSellFrameSecondaryPriceInput, "TOPRIGHT", -100, 0)
					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameSilverBox:Width(60)
					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameSilverBox:Height(24)

					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameSilverBoxIcon:ClearAllPoints()
					AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameSilverBoxIcon:SetPoint("TOPLEFT", AuctionHouseFrameItemSellFrameSecondaryPriceInputMoneyInputFrameSilverBox, "TOPRIGHT", -30, -4)



				--2nd
					S:HandleEditBox(AuctionHouseFrameCommoditiesSellFrameQuantityInputInputBox)
					AuctionHouseFrameCommoditiesSellFrameQuantityInputInputBox:Width(70)
					AuctionHouseFrameCommoditiesSellFrameQuantityInputInputBox:Height(20)
					S:HandleEditBox(AuctionHouseFrameCommoditiesSellFramePriceInputMoneyInputFrameGoldBox)
					AuctionHouseFrameCommoditiesSellFramePriceInputMoneyInputFrameGoldBox:Width(70)
					AuctionHouseFrameCommoditiesSellFramePriceInputMoneyInputFrameGoldBox:Height(20)
					S:HandleEditBox(AuctionHouseFrameCommoditiesSellFramePriceInputMoneyInputFrameSilverBox)
					AuctionHouseFrameCommoditiesSellFramePriceInputMoneyInputFrameSilverBox:Width(70)
					AuctionHouseFrameCommoditiesSellFramePriceInputMoneyInputFrameSilverBox:Height(20)
		--lot tab
			--tabs
				S:HandleTab(AuctionHouseFrameAuctionsFrameAuctionsTab)
				S:HandleTab(AuctionHouseFrameAuctionsFrameBidsTab)
					--lots
						--scrollbar
							--left
								S:HandleScrollBar(AuctionHouseFrameAuctionsFrameSummaryListScrollFrameScrollBar)
								AuctionHouseFrameAuctionsFrameSummaryListScrollFrameScrollBar:ClearAllPoints()
								AuctionHouseFrameAuctionsFrameSummaryListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameAuctionsFrameSummaryListScrollFrame, "TOPRIGHT", 4, -20)
								AuctionHouseFrameAuctionsFrameSummaryListScrollFrameScrollBar:Height(390)
							--right
								S:HandleScrollBar(AuctionHouseFrameAuctionsFrameAllAuctionsListScrollFrameScrollBar)
								AuctionHouseFrameAuctionsFrameAllAuctionsListScrollFrameScrollBar:ClearAllPoints()
								AuctionHouseFrameAuctionsFrameAllAuctionsListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameAuctionsFrameAllAuctionsListScrollFrame, "TOPRIGHT", 4, -20)
								AuctionHouseFrameAuctionsFrameAllAuctionsListScrollFrameScrollBar:Height(370)

						--Button
							S:HandleButton(AuctionHouseFrameAuctionsFrameCancelAuctionButton)
							S:HandleButton(AuctionHouseFrameAuctionsFrameAllAuctionsListRefreshFrameRefreshButton)

						--frames
							--left
								AuctionHouseFrameAuctionsFrameSummaryListScrollFrameArtOverlay:StripTextures()
								AuctionHouseFrameAuctionsFrameSummaryListScrollFrameArtOverlay:CreateBackdrop("Transparent")
								AuctionHouseFrameAuctionsFrameSummaryList:StripTextures()
								AuctionHouseFrameAuctionsFrameSummaryListNineSlice:StripTextures()
							--right
								AuctionHouseFrameAuctionsFrameAllAuctionsListScrollFrame:StripTextures()
								AuctionHouseFrameAuctionsFrameAllAuctionsListScrollFrame:CreateBackdrop("Transparent")
								AuctionHouseFrameAuctionsFrameAllAuctionsList:StripTextures()
								AuctionHouseFrameAuctionsFrameAllAuctionsListNineSlice:StripTextures()
					--bids
						--scrolbar
							--only right
								S:HandleScrollBar(AuctionHouseFrameAuctionsFrameBidsListScrollFrameScrollBar)
								AuctionHouseFrameAuctionsFrameBidsListScrollFrameScrollBar:ClearAllPoints()
								AuctionHouseFrameAuctionsFrameBidsListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameAuctionsFrameBidsListScrollFrame, "TOPRIGHT", 4, -20)
								AuctionHouseFrameAuctionsFrameBidsListScrollFrameScrollBar:Height(370)

						--Button
							S:HandleButton(AuctionHouseFrameAuctionsFrameBidsListRefreshFrameRefreshButton)
							S:HandleButton(AuctionHouseFrameAuctionsFrameBidFrameBidButton)
							S:HandleButton(AuctionHouseFrameAuctionsFrameBuyoutFrameBuyoutButton)
						--editbox
							S:HandleEditBox(AuctionHouseFrameAuctionsFrameBidFrameBidAmountGold)
							S:HandleEditBox(AuctionHouseFrameAuctionsFrameBidFrameBidAmountSilver)
							--frames
							AuctionHouseFrameAuctionsFrameBidsListScrollFrame:StripTextures()
							AuctionHouseFrameAuctionsFrameBidsListScrollFrame:CreateBackdrop("Transparent")
							AuctionHouseFrameAuctionsFrameBidsList:StripTextures()
							AuctionHouseFrameAuctionsFrameBidsListNineSlice:StripTextures()
				---commolist
					--frame
						AuctionHouseFrameAuctionsFrameCommoditiesListScrollFrame:StripTextures()
						AuctionHouseFrameAuctionsFrameCommoditiesListScrollFrame:CreateBackdrop("Transparent")

						function commfktab_onshow(self)
							if AuctionHouseFrameAuctionsFrameCommoditiesListScrollFrame ~= nil then
								AuctionHouseFrameAuctionsFrameCommoditiesListScrollFrame:SetScript("OnUpdate", function()

									AuctionHouseFrameAuctionsFrameCommoditiesListNineSlice:StripTextures()
									AuctionHouseFrameAuctionsFrameCommoditiesList:StripTextures()
									AuctionHouseFrameAuctionsFrameCommoditiesList:CreateBackdrop("Transparent")
									AuctionHouseFrameAuctionsFrameItemDisplay:StripTextures()
									AuctionHouseFrameAuctionsFrameItemDisplayNineSlice:StripTextures()
									AuctionHouseFrameAuctionsFrameItemDisplay:CreateBackdrop("Transparent")
					--scrollbar
									S:HandleScrollBar(AuctionHouseFrameAuctionsFrameCommoditiesListScrollFrameScrollBar)
									AuctionHouseFrameAuctionsFrameCommoditiesListScrollFrameScrollBar:ClearAllPoints()
									AuctionHouseFrameAuctionsFrameCommoditiesListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameAuctionsFrameCommoditiesListScrollFrame, "TOPRIGHT", 4, -20)
									AuctionHouseFrameAuctionsFrameCommoditiesListScrollFrameScrollBar:Height(270)

					--buttons
									if AuctionHouseFrameAuctionsFrameCommoditiesListRefreshFrameRefreshButton ~= nil then
											AuctionHouseFrameAuctionsFrameCommoditiesListRefreshFrameRefreshButton:SetScript("OnUpdate", function()
												S:HandleButton(AuctionHouseFrameAuctionsFrameCommoditiesListRefreshFrameRefreshButton)
											end)
										end
									if AuctionHouseFrameAuctionsFrameCommoditiesListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate1 ~= nil then
											AuctionHouseFrameAuctionsFrameCommoditiesListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate1:SetScript("OnUpdate", function()
												S:HandleButton(AuctionHouseFrameAuctionsFrameCommoditiesListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate1)
											end)
									end
								end)
							end
						end
						AuctionHouseFrameAuctionsFrameCommoditiesList:HookScript("OnUpdate", commfktab_onshow)

				--itemlist3tab
					AuctionHouseFrameAuctionsFrameItemListScrollFrame:StripTextures()
					AuctionHouseFrameAuctionsFrameItemListScrollFrame:CreateBackdrop("Transparent")

					function itemfktab_onshow(self)
						if AuctionHouseFrameAuctionsFrameItemListScrollFrame ~= nil then
							AuctionHouseFrameAuctionsFrameItemListScrollFrame:SetScript("OnUpdate", function()

									AuctionHouseFrameAuctionsFrameItemListNineSlice:StripTextures()
									AuctionHouseFrameAuctionsFrameItemList:StripTextures()
									AuctionHouseFrameAuctionsFrameItemList:CreateBackdrop("Transparent")
									AuctionHouseFrameAuctionsFrameItemDisplay:StripTextures()
									AuctionHouseFrameAuctionsFrameItemDisplayNineSlice:StripTextures()
									AuctionHouseFrameAuctionsFrameItemDisplay:CreateBackdrop("Transparent")
								--scrollbar
									S:HandleScrollBar(AuctionHouseFrameAuctionsFrameItemListScrollFrameScrollBar)
									AuctionHouseFrameAuctionsFrameItemListScrollFrameScrollBar:ClearAllPoints()
									AuctionHouseFrameAuctionsFrameItemListScrollFrameScrollBar:SetPoint("TOPLEFT", AuctionHouseFrameAuctionsFrameItemListScrollFrame, "TOPRIGHT", 4, -20)
									AuctionHouseFrameAuctionsFrameItemListScrollFrameScrollBar:Height(270)

								--buttons
										if AuctionHouseFrameAuctionsFrameItemListRefreshFrameRefreshButton ~= nil then
											AuctionHouseFrameAuctionsFrameItemListRefreshFrameRefreshButton:SetScript("OnUpdate", function()
												S:HandleButton(AuctionHouseFrameAuctionsFrameItemListRefreshFrameRefreshButton)
																			end)

										end
										if AuctionHouseFrameAuctionsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate1 ~= nil then
											AuctionHouseFrameAuctionsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate1:SetScript("OnUpdate", function()
												S:HandleButton(AuctionHouseFrameAuctionsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate1)
																			end)
										end
										if AuctionHouseFrameAuctionsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate2 ~= nil then
											AuctionHouseFrameAuctionsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate2:SetScript("OnUpdate", function()
												S:HandleButton(AuctionHouseFrameAuctionsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate2)
																			end)
										end
										if AuctionHouseFrameAuctionsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate3 ~= nil then
											AuctionHouseFrameAuctionsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate3:SetScript("OnUpdate", function()
												S:HandleButton(AuctionHouseFrameAuctionsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate3)
																			end)
										end

							end)
						end

					end
					AuctionHouseFrameAuctionsFrameItemList:HookScript("OnUpdate", itemfktab_onshow)

		--category buttons (не придумал как сделать по другому пока, он показывает только 20 кнопок на экране максимум и если гортаешь они обновляются)
		function buttonsleft_OnShow(self)
				for i = 1,20 do
					-- if _G["AuctionHouseFrameCategoriesListAuctionFilterButton"..i] ~= nil then
						(_G["AuctionHouseFrameCategoriesListAuctionFilterButton"..i.."NormalTexture"]):StripTextures();
						S:HandleButton(_G["AuctionHouseFrameCategoriesListAuctionFilterButton"..i]);
						-- (_G["AuctionHouseFrameCategoriesListAuctionFilterButton"..i.."Lines"]):StripTextures();
						-- (_G["AuctionHouseFrameCategoriesListAuctionFilterButton"..i.."HighlightTexture"]):StripTextures();
					-- end
				end
			end
			AuctionHouseFrameCategoriesList:HookScript("OnUpdate", buttonsleft_OnShow)
		--hooksecurefunc

		function secftab_OnShow(self)
			for i = 1,2 do
				S:HandleButton(_G["AuctionHouseFrameItemSellListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate"..i])
			end
			if AuctionHouseFrameItemSellListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate3 ~= nil then
				AuctionHouseFrameItemSellListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate3:SetScript("OnUpdate", function()
					S:HandleButton(AuctionHouseFrameItemSellListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate3)
												end)
			end
		end

		function secstab_OnShow(self)
			for i = 1,2 do
				S:HandleButton(_G["AuctionHouseFrameCommoditiesSellListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate"..i])
			end
		end

		function thtab_OnShow(self)
			for i = 1,4 do
				S:HandleButton(_G["AuctionHouseFrameAuctionsFrameAllAuctionsListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate"..i])
			end
		end

		function fortab_OnShow(self)
			for i = 1,3 do
				S:HandleButton(_G["AuctionHouseFrameAuctionsFrameBidsListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate"..i])
			end
		end
		function aucfpanelbidbut1_OnShow(self)
			for i = 1,2 do
				S:HandleButton(_G["AuctionHouseFrameItemBuyFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate"..i])
			end
			--[[ for i = 3,4 do
				S:HandleButton(_G["AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate"..i])
			end	 ]]
		end

		--[[ 	aucfpanel1 = AuctionHouseFrame
				aucfpanel1:HookScript("OnShow", firtab_OnShow)	 ]]
			aucfpanel2 = AuctionHouseFrameItemSellList
				aucfpanel2:HookScript("OnUpdate", secftab_OnShow)
			--aucfpanel2:HookScript("OnShow", secftab_OnShow)
			aucfpanel3 = AuctionHouseFrameCommoditiesSellList
				aucfpanel3:HookScript("OnShow", secstab_OnShow)
			aucfpanel4 = AuctionHouseFrameAuctionsFrameAllAuctionsList
				aucfpanel4:HookScript("OnShow", thtab_OnShow)
			aucfpanel5 = AuctionHouseFrameAuctionsFrameBidsList
				aucfpanel5:HookScript("OnShow", fortab_OnShow)


				function fcng4_OnShow(self)
				if AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate4 ~= nil then
					AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate4:SetScript("OnUpdate", function()
										S:HandleButton(AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate4)
																	end)
				end
				if AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate3 ~= nil then
					AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate3:SetScript("OnUpdate", function()
										S:HandleButton(AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate3)
																	end)
				end
				if AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate2 ~= nil then
					AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate2:SetScript("OnUpdate", function()
										S:HandleButton(AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate2)
																	end)
						end
				if AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate1 ~= nil then
					AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate1:SetScript("OnUpdate", function()
										S:HandleButton(AuctionHouseFrameBrowseResultsFrameItemListHeaderContainerPoolFrameAuctionHouseTableHeaderStringTemplate1)
																	end)
						end
				end

	hooksecurefunc(AuctionHouseTableBuilderMixin,"AddUnsortableColumnInternal", fcng4_OnShow)


	AuctionHouseFrameBuyDialog:HookScript("OnShow", function()
		AuctionHouseFrameBuyDialog:StripTextures()
		AuctionHouseFrameBuyDialog:CreateBackdrop("Transparent")
		AuctionHouseFrameBuyDialogBorder:StripTextures()
		AuctionHouseFrameBuyDialogDialogOverlay:StripTextures()
		AuctionHouseFrameBuyDialogDialogOverlay:CreateBackdrop("Transparent")
		S:HandleButton(AuctionHouseFrameBuyDialogBuyNowButton)
		S:HandleButton(AuctionHouseFrameBuyDialogCancelButton)
	end)
	S:HandleEditBox(AuctionHouseFrameSearchBarFilterButtonLevelRangeFrameMinLevel)
	S:HandleEditBox(AuctionHouseFrameSearchBarFilterButtonLevelRangeFrameMaxLevel)



	for i = 1,24 do
		local chbt = _G["DropDownList1Button"..i.."Check"]
		local uchbt = _G["DropDownList1Button"..i.."UnCheck"]
		if chbt then
			chbt:StripTextures()
			chbt:SetTexture("Interface\\AddOns\\ElvUI\\Media\\Textures\\Melli")
			chbt:SetSize(13,13)
			chbt:SetVertexColor(1, 0.82, 0, 0.8)
		end
		if uchbt then
			uchbt:StripTextures()
		end
	end
end

S:AddCallback('AuctionHouse', LoadSkin)

