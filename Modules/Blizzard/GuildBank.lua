local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local BL = E:GetModule("Blizzard")
local LSM = E.Libs.LSM

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetGuildBankItemLink = GetGuildBankItemLink
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local NUM_GUILDBANK_COLUMNS = 7

local function IsItemEligibleForItemLevelDisplay(classID, subclassID, itemEquipLoc, rarity)
	return (rarity and rarity > 1)
	and (itemEquipLoc ~= nil and itemEquipLoc ~= "" and itemEquipLoc ~= "INVTYPE_AMMO" and itemEquipLoc ~= "INVTYPE_BAG" and itemEquipLoc ~= "INVTYPE_QUIVER" and itemEquipLoc ~= "INVTYPE_TABARD")
	and (classID and subclassID)
end

function BL:GuildBank_ItemLevel(button)
	local db = E.db.general.guildBank
	if not db then return end

	if not button.itemLevel then
		button.itemLevel = button:CreateFontString(nil, "ARTWORK", nil, 1)
	end

	button.itemLevel:ClearAllPoints()
	button.itemLevel:Point(db.itemLevelPosition, db.itemLevelxOffset, db.itemLevelyOffset)
	button.itemLevel:FontTemplate(LSM:Fetch("font", db.itemLevelFont), db.itemLevelFontSize, db.itemLevelFontOutline)

	local ilvl, r, g, b
	local tab = db.itemLevel and GetCurrentGuildBankTab()
	local itemlink = tab and GetGuildBankItemLink(tab, button:GetID())
	if itemlink then
		local _, _, rarity, itemLevel, _, _, _, _, itemEquipLoc, _, _, classID, subclassID = GetItemInfo(itemlink)
		if rarity and rarity > 1 then
			r, g, b = GetItemQualityColor(rarity)
		end

		if rarity and rarity > 1 and db.itemQuality then
			button:SetBackdropBorderColor(r, g, b)
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end

		local canShowItemLevel = IsItemEligibleForItemLevelDisplay(classID, subclassID, itemEquipLoc, rarity)
		if canShowItemLevel and db.itemLevel then
			local custom = db.itemLevelCustomColorEnable and db.itemLevelCustomColor
			if custom then
				r, g, b = custom.r, custom.g, custom.b
			elseif rarity and rarity > 1 then -- иначе это уже сделано выше
				r, g, b = GetItemQualityColor(rarity)
			end

			ilvl = itemLevel
		end
	else
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end

	button.itemLevel:SetText(ilvl and ilvl >= db.itemLevelThreshold and ilvl or "")
	button.itemLevel:SetTextColor(r or 1, g or 1, b or 1)
end

function BL:GuildBank_CountText(button)
	local db = E.db.general.guildBank
	if not db then return end

	button.Count = _G[button:GetName().."Count"]
	button.Count:ClearAllPoints()
	button.Count:Point(db.countPosition, db.countxOffset, db.countyOffset)
	button.Count:FontTemplate(LSM:Fetch("font", db.countFont), db.countFontSize, db.countFontOutline)
	button.Count:SetTextColor(db.countFontColor.r, db.countFontColor.g, db.countFontColor.b)
end

function BL:GuildBank_Update()
	local frame = _G.GuildBankFrame
	if not frame or not frame:IsShown() then return end

	if frame.mode ~= "bank" then
		frame.inset:Point("BOTTOMRIGHT", -29, 62)
		return
	else
		frame.inset:Point("BOTTOMRIGHT", -8, 62)

		_G.GuildBankColumn1:Point("TOPLEFT", 20, -70)
	end

	for i = 1, NUM_GUILDBANK_COLUMNS do
		for x = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = _G["GuildBankColumn"..i.."Button"..x]

			BL:GuildBank_ItemLevel(button)
			BL:GuildBank_CountText(button)
		end
	end
end

function BL:ImproveGuildBank()
	hooksecurefunc("GuildBankFrame_Update", BL.GuildBank_Update)
end
