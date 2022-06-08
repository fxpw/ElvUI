local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.transmogrify ~= true then return end

-- 	S:HandlePortraitFrame(TransmogrifyFrame)
-- 	S:HandleCloseButton(TransmogrifyFrameCloseButton)
-- 	TransmogrifyFrameArt:StripTextures()

-- 	S:HandleRotateButton(TransmogrifyModelFrameRotateLeftButton)
-- 	S:HandleRotateButton(TransmogrifyModelFrameRotateRightButton)
-- 	TransmogrifyModelFrameRotateRightButton:Point("TOPLEFT", TransmogrifyModelFrameRotateLeftButton, "TOPRIGHT", 5, 0)

-- 	local slots = {
-- 		"HeadSlot",
-- 		"ShoulderSlot",
-- 		"BackSlot",
-- 		"ChestSlot",
-- 		"WristSlot",
-- 		"HandsSlot",
-- 		"WaistSlot",
-- 		"LegsSlot",
-- 		"FeetSlot",
-- 		"MainHandSlot",
-- 		"SecondaryHandSlot",
-- 		"RangedSlot"
-- 	}

-- 	for i, slot in pairs(slots) do
-- 		local button = _G["TransmogrifyFrame"..slot]
-- 		button:SetTemplate()
-- 		button:StyleButton()

-- 		button.icon:SetTexCoord(unpack(E.TexCoords))
-- 		button.icon:SetInside()
-- 		button.icon:SetDrawLayer("BORDER")
-- 		button.altTexture:SetAlpha(0)

-- 		_G["TransmogrifyFrame"..slot.."Border"]:SetAlpha(0)
-- 		_G["TransmogrifyFrame"..slot.."Grabber"]:SetAlpha(0)
-- 	end

-- 	S:HandleButton(TransmogrifyApplyButton, true)
-- 	TransmogrifyFrameButtonFrame:StripTextures()



		-- transmog tab
		local WardrobeFrame = _G.WardrobeFrame
		WardrobeFrame:StripTextures()
		WardrobeFrame:SetTemplate('Transparent')

		S:HandleCloseButton(WardrobeFrameCloseButton)
		
		---- save set frame

			local WardrobeOutfitFrame = _G.WardrobeOutfitFrame
				WardrobeOutfitFrame:StripTextures()
				WardrobeOutfitFrameBorder:StripTextures()
				WardrobeOutfitFrame:SetTemplate('Transparent')
				
				S:HandleButton(_G.WardrobeOutfitDropDown.SaveButton)
				S:HandleDropDownBox(_G.WardrobeOutfitDropDown, 221)
				_G.WardrobeOutfitDropDown:Height(34)
				_G.WardrobeOutfitDropDown.SaveButton:ClearAllPoints()
				_G.WardrobeOutfitDropDown.SaveButton:Point('TOPLEFT', _G.WardrobeOutfitDropDown, 'TOPRIGHT', -2, -2)

			-- local WardrobeOutfitEditFrame = _G.WardrobeOutfitEditFrame
				WardrobeOutfitEditFrame:StripTextures()
				WardrobeOutfitEditFrame:SetTemplate('Transparent')
				WardrobeOutfitEditFrameBorder:StripTextures()
				WardrobeOutfitEditFrame.EditBox:StripTextures()
				S:HandleEditBox(WardrobeOutfitEditFrame.EditBox)
				S:HandleButton(WardrobeOutfitEditFrame.AcceptButton)
				S:HandleButton(WardrobeOutfitEditFrame.CancelButton)
				S:HandleButton(WardrobeOutfitEditFrame.DeleteButton)
				

		WardrobeTransmogFrame:StripTextures()
		-- WardrobeTransmogFrame:CreateBackdrop("Transperent")

		WardrobeTransmogFrameModelFrame:StripTextures()
		-- WardrobeTransmogFrameModelFrame:CreateBackdrop("Transperent")
		local function refreshbutton_onshow()
			WardrobeCollectionFrameFilterButton:StripTextures()
			WardrobeCollectionFrameFilterButton:CreateBackdrop()
			S:HandleButton(WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton)
			
			-- WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton:StripTextures()
			-- WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton:CreateBackdrop()
			-- local iconrefresh = AuctionHouseFrameCommoditiesBuyFrameItemListRefreshFrameRefreshButtonIcon:GetTexture();
			-- WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.Icon:SetTexture(iconrefresh)
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.Icon:SetDrawLayer("ARTWORK")
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.TopLeft:Hide()
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.TopRight:Hide()
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.BottomLeft:Hide()
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.BottomRight:Hide()
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.TopMiddle:Hide()
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.MiddleLeft:Hide()
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.MiddleRight:Hide()
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.BottomMiddle:Hide()
			WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.MiddleMiddle:Hide()
			-- WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton.BottomLeft:Hide()
		end
			

		WardrobeTransmogFrame.ModelFrame.ClearAllPendingButton:SetScript("OnUpdate",refreshbutton_onshow)

		S:HandleNextPrevButton(WardrobeCollectionFrameItemsCollectionFramePagingFramePrevPageButton, nil, nil, true)
		S:HandleNextPrevButton(WardrobeCollectionFrameItemsCollectionFramePagingFrameNextPageButton, nil, nil, true)

		S:HandleDropDownBox(WardrobeCollectionFrameItemsCollectionFrameWeaponDropDown)
		
		S:HandleTab(WardrobeCollectionFrameTab1)
		WardrobeCollectionFrameTab1:StripTextures()
		S:HandleEditBox(WardrobeCollectionFrameSearchBox)
		

		WardrobeCollectionFrameItemsCollectionFrameOverlayFrame:StripTextures()
		WardrobeCollectionFrameItemsCollectionFrameOverlayFrame:CreateBackdrop("Transperent")
		WardrobeCollectionFrameItemsCollectionFrame:StripTextures()


		



		local sbcR, sbcG, sbcB = 4/255, 179/255, 30/255

		local function skinStatusBar(bar)
			bar:StripTextures()
			bar:SetStatusBarTexture(E.media.normTex)
			bar:SetStatusBarColor(sbcR, sbcG, sbcB)
			bar:CreateBackdrop("Default")
			E:RegisterStatusBar(bar)
	
			local barName = bar:GetName()
			local title = _G[barName.."Title"]
			local label = _G[barName.."Label"]
			local text = _G[barName.."Text"]
	
			if title then
				title:Point("LEFT", 4, 0)
			end
	
			if label then
				label:Point("LEFT", 4, 0)
			end
	
			if text then
				text:Point("RIGHT", -4, 0)
			end
		end


		skinStatusBar(WardrobeCollectionFrameProgressBar)

		--buttons top 
		-- S:HandleButton(WardrobeCollectionFrameItemsCollectionFrameSlotsFrameSlotButton1)
		local function stripbutton_onup()
			S:HandleButton(WardrobeCollectionFrameFilterButton)
			-- WardrobeCollectionFrameFilterButton:CreateBackdrop()
			WardrobeCollectionFrame.FilterButton.TopLeft:Hide()
			WardrobeCollectionFrame.FilterButton.TopRight:Hide()
			WardrobeCollectionFrame.FilterButton.BottomLeft:Hide()
			WardrobeCollectionFrame.FilterButton.BottomRight:Hide()
			WardrobeCollectionFrame.FilterButton.TopMiddle:Hide()
			WardrobeCollectionFrame.FilterButton.MiddleLeft:Hide()
			WardrobeCollectionFrame.FilterButton.MiddleRight:Hide()
			WardrobeCollectionFrame.FilterButton.BottomMiddle:Hide()
			WardrobeCollectionFrame.FilterButton.MiddleMiddle:Hide()
			
					end
		WardrobeCollectionFrameFilterButton:SetScript("OnUpdate",stripbutton_onup)
						
		
		local function clearBackdrop(self)
			self:SetBackdropColor(0, 0, 0, 0)
		end

		for _, Frame in ipairs(WardrobeCollectionFrame.ContentFrames) do
			if Frame.Models then
				for _, Model in pairs(Frame.Models) do
					Model.Overlay.Border:SetAlpha(0)
					Model.Overlay.TransmogStateTexture:SetAlpha(0)
	
					local border = CreateFrame('Frame', nil, Model)
					border:SetTemplate()
					border:ClearAllPoints()
					border:SetPoint('TOPLEFT', Model, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
					border:SetPoint('BOTTOMRIGHT', Model, 'BOTTOMRIGHT', 1, -1)
					border:SetBackdropColor(0, 0, 0, 0)
					border.callbackBackdropColor = clearBackdrop
	
					if Model.NewGlow then Model.NewGlow:SetParent(border) end
					if Model.NewString then Model.NewString:SetParent(border) end
	
					for i=1, Model:GetNumRegions() do
						local region = select(i, Model:GetRegions())
						if region:IsObjectType('Texture') then -- check for hover glow
							local texture = region:GetTexture()
							if texture == 1116940 or texture == 1569530 then -- transmogrify.blp (items:1116940 or sets:1569530)
								region:SetColorTexture(1, 1, 1, 0.3)
								region:SetBlendMode('ADD')
								region:SetAllPoints(Model)
							end
						end
					end
	
					hooksecurefunc(Model.Overlay.Border, 'SetAtlas', function(_, texture)
						if texture == 'transmog-wardrobe-border-uncollected' then
							border:SetBackdropBorderColor(0.9, 0.9, 0.3)
						elseif texture == 'transmog-wardrobe-border-unusable' then
							border:SetBackdropBorderColor(0.9, 0.3, 0.3)
						elseif Model.Overlay.TransmogStateTexture:IsShown() then
							border:SetBackdropBorderColor(1, 0.7, 1)
						else
							border:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end)
				end
			end
	
			-- local pending = Frame.PendingTransmogFrame
			-- if pending then
			-- 	local Glowframe = pending.Glowframe
			-- 	-- Glowframe:SetAtlas(nil)
			-- 	-- Glowframe:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, pending:GetFrameLevel())
	
			-- 	if Glowframe.backdrop then
			-- 		Glowframe.backdrop:SetPoint('TOPLEFT', pending, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
			-- 		Glowframe.backdrop:SetPoint('BOTTOMRIGHT', pending, 'BOTTOMRIGHT', 1, -1)
			-- 		Glowframe.backdrop:SetBackdropBorderColor(1, 0.7, 1)
			-- 		Glowframe.backdrop:SetBackdropColor(0, 0, 0, 0)
			-- 	end
	
			-- 	for i = 1, 12 do
			-- 		if i < 5 then
			-- 			Frame.PendingTransmogFrame['Smoke'..i]:Hide()
			-- 		end
	
			-- 		Frame.PendingTransmogFrame['Wisp'..i]:Hide()
			-- 	end
			-- end
	
			-- local paging = Frame.PagingFrame
			-- if paging then
			-- 	S:HandleNextPrevButton(paging.PrevPageButton, nil, nil, true)
			-- 	S:HandleNextPrevButton(paging.NextPageButton, nil, nil, true)
			-- end

			S:HandleButton(WardrobeTransmogFrameApplyButton)
			
			for i = 1, #WardrobeTransmogFrame.SlotButtons do
				local slotButton = WardrobeTransmogFrame.SlotButtons[i]
				slotButton:SetFrameLevel(slotButton:GetFrameLevel() + 2)
				slotButton:StripTextures()
				slotButton:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
				slotButton.Border:Kill()
				slotButton.Icon:SetTexCoord(unpack(E.TexCoords))
				slotButton.Icon:SetInside(slotButton.backdrop)

				local undo = slotButton.UndoButton
				if undo then undo:SetHighlightTexture(nil) end

				local pending = slotButton.PendingFrame
				if pending then
					if slotButton.transmogType == 1 then
						pending.Glow:Size(48)
						pending.Ants:Size(30)
					else
						pending.Glow:Size(74)
						pending.Ants:Size(48)
					end
				end
			end
		end



end





S:AddCallback("Sirus_Transmogrify", LoadSkin)