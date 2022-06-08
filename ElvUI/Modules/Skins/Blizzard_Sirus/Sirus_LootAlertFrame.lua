local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	-- print(E.private.general.hideLootAlert,10)
	if E.private.general.hideLootAlerts == true then
		-- print(E.private.general.hideLootAlerts)
		for  i = 1, 4 do
			local button = _G["LootAlertButton"..i]
			button:HookScript("OnUpdate",function()
				button:Hide()
			end)
		end
	end

	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.alertframes then return end

	for i = 1, 4 do
		local button = _G["LootAlertButton"..i]
		button:DisableDrawLayer("OVERLAY")
		button.Background:SetAlpha(0)

		button:CreateBackdrop("Transparent")
		button.backdrop:Point("TOPLEFT", 14, -15)
		button.backdrop:Point("BOTTOMRIGHT", -16, 11)

		local iconBackdrop = CreateFrame("Frame", nil, button)
		iconBackdrop:SetTemplate()
		button.Icon:SetTexCoord(unpack(E.TexCoords))
		button.Icon:SetParent(iconBackdrop)
		button.Count:SetParent(iconBackdrop)
		iconBackdrop:SetOutside(button.Icon)

		button.IconBorder:SetAlpha(0)
		hooksecurefunc(button.ItemName, "SetTextColor", function(_, r, g, b) iconBackdrop:SetBackdropBorderColor(r, g, b) end)
	end
	
--[[
	function TestAlert()
		local name, link, quality, _, _, _, _, _, _, texture, _ = GetItemInfo(100152)

		if link then
			LootAlertFrame:AddAlert(name, link, quality, texture, 5)
		end
	end

	/run local function TestAlert() local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(100152) if link then  LootAlertFrame:AddAlert(name, link, quality, texture, 5) end end TestAlert()
]]
end

S:AddCallback("Sirus_LootAlertFrame", LoadSkin)