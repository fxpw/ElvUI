--[[
	Deconstruct Module for ElvUI (WoW 3.3.5a / Sirus)
	Adapted from ElvUI_SLE retail version

	This module provides functionality to disenchant, mill, prospect, and unlock items
	directly from bags by creating an overlay button when mousing over compatible items.
]] --
local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Bags")

local D = B:NewModule("Deconstruct", "AceHook-3.0", "AceEvent-3.0")
local Search = E.Libs.ItemSearch or E.Libs.LibItemSearch
if not Search then
	Search = {
		Matches = function(self, link, query)
			return link and string.find(string.lower(link), string.lower(query or ""))
		end
	}
end

local _G = _G
local format, strfind, type, tostring = format, strfind, type, tostring
local pairs, unpack = pairs, unpack

local GetTradeTargetItemLink = GetTradeTargetItemLink
local InCombatLockdown = InCombatLockdown
local GetContainerItemLink = GetContainerItemLink
local GetSpellInfo = GetSpellInfo
local GetItemInfo = GetItemInfo
local GetItemCount = GetItemCount
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip

local LOCKED = LOCKED or "Locked"
local VIDEO_OPTIONS_ENABLED = VIDEO_OPTIONS_ENABLED or "Enabled"
local VIDEO_OPTIONS_DISABLED = VIDEO_OPTIONS_DISABLED or "Disabled"

if GetLocale() == "ruRU" then
	L["Deconstruct Mode"] = "Режим распыления"
	L["Deconstruct Mode Desc"] = "Позволяет распылять, просеивать и открывать замки одним кликом."
	L["Current state: %s."] = "Текущее состояние: %s."
	LOCKED = "Заперто"
	VIDEO_OPTIONS_ENABLED = "Включено"
	VIDEO_OPTIONS_DISABLED = "Отключено"
end

D.DEname = GetSpellInfo(13262) -- Disenchant
D.DEPrimeName = GetSpellInfo(311891) -- Prime Disenchant (Custom Sirus Spell)
D.PrimeDEID = 311891
D.MILLname = GetSpellInfo(51005) -- Milling
D.PROSPECTname = GetSpellInfo(31252) -- Prospecting
D.LOCKname = GetSpellInfo(1804) -- Pick Lock

D.ItemTable = {
	['DoNotDE'] = {
		['49715'] = true, -- Rose helm
		['44731'] = true, -- Rose offhand
		['21524'] = true, -- Red winter hat
		['51525'] = true, -- Green winter hat
		['70923'] = true, -- Sweater
		['34486'] = true, -- Orgrimmar achievement fish
		['11287'] = true, -- Lesser Magic Wand
		['11288'] = true, -- Greater Magic Wand
		['11289'] = true, -- Lesser Mystic Wand
		['11290'] = true, -- Greater Mystic Wand
		['4614'] = true, -- Pendant of Myzrael
		['20406'] = true, -- Twilight Cultist Mantle
		['20407'] = true, -- Twilight Cultist Robe
		['20408'] = true, -- Twilight Cultist Cowl
		['21766'] = true, -- Opal Necklace of Impact
	},
	['Cooking'] = {
		['46349'] = true -- Chef's Hat
	},
	['Fishing'] = {
		['19022'] = true, -- Nat Pagle's Extreme Angler FC-5000
		['19970'] = true, -- Arcanite Fishing Pole
		['25978'] = true, -- Seth's Graphite Fishing Pole
		['44050'] = true, -- Mastercraft Kalu'ak Fishing Pole
		['45858'] = true, -- Nat's Lucky Fishing Pole
		['45991'] = true, -- Bone Fishing Pole
		['45992'] = true, -- Jeweled Fishing Pole
        ['33820'] = true -- Выидавшая виды рыболовная шапка
	}
}

-- Prospectable ores in WotLK (3.3.5a)
local prospectableOres = {
	[2770] = true, -- Copper Ore
	[2771] = true, -- Tin Ore
	[2772] = true, -- Iron Ore
	[3858] = true, -- Mithril Ore
	[10620] = true, -- Thorium Ore
	[23424] = true, -- Fel Iron Ore
	[23425] = true, -- Adamantite Ore
	[36909] = true, -- Cobalt Ore
	[36912] = true, -- Saronite Ore
	[36910] = true -- Titanium Ore
}

-- Millable herbs in WotLK (3.3.5a)
local millableHerbs = {
	[765] = true, -- Silverleaf
	[2447] = true, -- Peacebloom
	[2449] = true, -- Earthroot
	[785] = true, -- Mageroyal
	[2450] = true, -- Briarthorn
	[2452] = true, -- Swiftthistle
	[2453] = true, -- Bruiseweed
	[3820] = true, -- Stranglekelp
	[3369] = true, -- Grave Moss
	[3356] = true, -- Kingsblood
	[3357] = true, -- Liferoot
	[3818] = true, -- Fadeleaf
	[3821] = true, -- Goldthorn
	[3358] = true, -- Khadgar's Whisker
	[3819] = true, -- Dragon's Teeth (Wintersbite)
	[8836] = true, -- Arthas' Tears
	[8838] = true, -- Sungrass
	[8839] = true, -- Blindweed
	[8845] = true, -- Ghost Mushroom
	[8846] = true, -- Gromsblood
	[13464] = true, -- Golden Sansam
	[13463] = true, -- Dreamfoil
	[13465] = true, -- Mountain Silversage
	[13466] = true, -- Plaguebloom
	[13467] = true, -- Icecap
	[22785] = true, -- Felweed
	[22786] = true, -- Dreaming Glory
	[22787] = true, -- Ragveil
	[22789] = true, -- Terocone
	[22790] = true, -- Ancient Lichen
	[22791] = true, -- Netherbloom
	[22792] = true, -- Nightmare Vine
	[22793] = true, -- Mana Thistle
	[36901] = true, -- Goldclover
	[36903] = true, -- Adder's Tongue
	[36904] = true, -- Tiger Lily
	[36905] = true, -- Lichbloom
	[36906] = true, -- Icethorn
	[36907] = true, -- Talandra's Rose
	[37921] = true, -- Deadnettle
	[39970] = true -- Fire Leaf
}


D.DeconstructMode = false
D.Keys = {}
D.BlacklistDE = {}
D.BlacklistLOCK = {}
D.BlacklistDEPatterns = {}
D.BlacklistLOCKPatterns = {}
D.ItemProcessingCache = {}

function D:HasRelevantProfession()
	if D.HasEnchanting then return true end
	if D.HasInscription then return true end
	if D.HasJewelcrafting then return true end
	if D.HasPickLock then return true end
	return false
end

function D:UpdateProfessions()
	D.HasEnchanting = false
	D.HasInscription = false
	D.HasJewelcrafting = false
	D.HasPickLock = false

	if not D.DEPrimeName and D.PrimeDEID then
		D.DEPrimeName = GetSpellInfo(D.PrimeDEID)
	end

	if (D.DEname and GetSpellInfo(D.DEname)) or (D.DEPrimeName and GetSpellInfo(D.DEPrimeName)) or (D.PrimeDEID and IsSpellKnown(D.PrimeDEID)) then
		D.HasEnchanting = true
	end
	if D.MILLname and GetSpellInfo(D.MILLname) then D.HasInscription = true end
	if D.PROSPECTname and GetSpellInfo(D.PROSPECTname) then D.HasJewelcrafting = true end
	if D.LOCKname and GetSpellInfo(D.LOCKname) then D.HasPickLock = true end

	wipe(D.ItemProcessingCache)
end

local function HaveKey()
	for key in pairs(D.Keys) do
		if GetItemCount(key) > 0 then return key end
	end
end

function D:Blacklisting(skill)
	if skill == 'DE' then
		D:BuildBlacklistDE()
	elseif skill == 'LOCK' then
		D:BuildBlacklistLOCK()
	end
end

function D:BuildBlacklistDE()
	wipe(D.BlacklistDE)
	wipe(D.ItemProcessingCache)
	wipe(D.BlacklistDEPatterns)
	local db = E.db.bags.deconstructBlacklist or {}
	local g = E.global.bags.deconstructBlacklist or {}

	if type(db) == "string" then
		local parsed = {}
		for item in string.gmatch(db, "([^,]+)") do
			tinsert(parsed, item)
		end
		db = parsed
	end

	for _, value in pairs(db) do
		if value and value ~= "" then
			local entry = tostring(value)
			entry = entry:match("^%s*(.-)%s*$") or entry
			local itemName = GetItemInfo(entry)
			if itemName then
				D.BlacklistDE[itemName] = true
			else
				table.insert(D.BlacklistDEPatterns, entry)
			end
		end
	end

	for _, value in pairs(g) do
		if value and value ~= "" then
			local entry = tostring(value)
			entry = entry:match("^%s*(.-)%s*$") or entry
			local itemName = GetItemInfo(entry)
			if itemName then
				D.BlacklistDE[itemName] = true
			else
				table.insert(D.BlacklistDEPatterns, entry)
			end
		end
	end
end

function D:BuildBlacklistLOCK()
	wipe(D.BlacklistLOCK)
	wipe(D.ItemProcessingCache)
	wipe(D.BlacklistLOCKPatterns)
	local db = E.db.bags.lockBlacklist or {}
	local g = E.global.bags.lockBlacklist or {}

	for _, value in pairs(db) do
		if value and value ~= "" then
			local entry = tostring(value)
			entry = entry:match("^%s*(.-)%s*$") or entry
			local itemName = GetItemInfo(entry)
			if itemName then
				D.BlacklistLOCK[itemName] = true
			else
				table.insert(D.BlacklistLOCKPatterns, entry)
			end
		end
	end

	for _, value in pairs(g) do
		if value and value ~= "" then
			local entry = tostring(value)
			entry = entry:match("^%s*(.-)%s*$") or entry
			local itemName = GetItemInfo(entry)
			if itemName then
				D.BlacklistLOCK[itemName] = true
			else
				table.insert(D.BlacklistLOCKPatterns, entry)
			end
		end
	end
end


function D:IsBreakable(itemId, itemName, itemLink)
	if not itemId then return false end
	if type(itemId) == "number" then itemId = tostring(itemId) end

	if D.ItemTable['DoNotDE'][itemId] then return false end
	if D.ItemTable['Cooking'][itemId] then return false end
	if D.ItemTable['Fishing'][itemId] then return false end
	if itemName and D.BlacklistDE[itemName] then return false end

	for _, query in ipairs(D.BlacklistDEPatterns or {}) do
		if query and query ~= "" then
			local ok, result = pcall(Search.Matches, Search, itemLink or itemName, query)
			if ok and result then
				return false
			end
		end
	end

	return true
end

function D:IsDisenchantableTooltip(itemLink)
	if not itemLink then return false end

	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:SetHyperlink(itemLink)

	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]
		if line and line:GetText() then
			local text = line:GetText()
			if string.find(text, "Disenchant") and not string.find(text, "Cannot") then
				GameTooltip:Hide()
				return true
			end
			if string.find(text, "Распыл") and not string.find(text, "Нельзя") then
				GameTooltip:Hide()
				return true
			end
		end
	end
	GameTooltip:Hide()
	return false
end

function D:IsDisenchantable(itemId, itemName, itemLink, itemRarity, itemType, itemEquipLoc)
	if not itemId or not itemName or not D.HasEnchanting then return false end

	if D:IsDisenchantableTooltip(itemLink) then return true end

	if not itemRarity or itemRarity < 2 or itemRarity > 4 then return false end
	if itemType ~= "Armor" and itemType ~= "Weapon" then return false end
	if not itemEquipLoc or itemEquipLoc == "" then return false end

	return true
end

function D:IsProspectable(itemId)
	if not itemId or not D.HasJewelcrafting then return false end
	return prospectableOres[tonumber(itemId)] or false
end

function D:IsProspectableTooltip(itemLink)
	if not itemLink then return false end
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:SetHyperlink(itemLink)
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]
		if line and line:GetText() then
			if string.find(line:GetText(), ITEM_PROSPECTABLE) then
				GameTooltip:Hide()
				return true
			end
		end
	end
	GameTooltip:Hide()
	return false
end

function D:IsMillable(itemId)
	if not itemId or not D.HasInscription then return false end
	return millableHerbs[tonumber(itemId)] or false
end

function D:IsUnlockable(itemLink)
	if not itemLink then return false end

	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:SetHyperlink(itemLink)

	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]
		if line then
			local text = line:GetText()
			if text and strfind(text, LOCKED) then
				GameTooltip:Hide()
				return true
			end
		end
	end

	GameTooltip:Hide()
	return false
end

function D:CanProcessItem(itemLink, hasKey)
	if not itemLink then return false end

	local itemId = tonumber(itemLink:match("item:(%d+)"))
	if not itemId then return false end

	if D.ItemProcessingCache[itemId] ~= nil then
		return D.ItemProcessingCache[itemId]
	end

	local result = false
	local itemName, _, itemRarity, _, _, itemType, _, _, itemEquipLoc = GetItemInfo(itemId)

	if (D.HasPickLock or hasKey) and D:IsUnlockable(itemLink) then
		if itemName then
			if D.BlacklistLOCK[itemName] then
				result = false
			else
				local blacklisted = false
				for _, query in ipairs(D.BlacklistLOCKPatterns or {}) do
					if query and query ~= "" then
						local ok, matchResult = pcall(Search.Matches, Search, itemLink, query)
						if ok and matchResult then
							blacklisted = true
							break
						end
					end
				end
				result = not blacklisted
			end
		end
	elseif D.HasJewelcrafting and D:IsProspectable(itemId) then
		result = true
	elseif D.HasInscription and D:IsMillable(itemId) then
		result = true
	elseif D.HasEnchanting and D:IsDisenchantable(itemId, itemName, itemLink, itemRarity, itemType, itemEquipLoc) then
		if D:IsBreakable(itemId, itemName, itemLink) then
			result = true
		end
	end

	D.ItemProcessingCache[itemId] = result
	return result
end

function D:ApplyDeconstruct(itemLink, itemId, spell, spellType, r, g, b, slot)
	if not slot then return end
	if slot == D.DeconstructionReal then return end

	local bag = slot:GetParent():GetID()

	local validBag = (B.BagFrame and B.BagFrame.Bags and B.BagFrame.Bags[bag]) or (B.BankFrame and B.BankFrame.Bags and B.BankFrame.Bags[bag])
	if not validBag then return end

	D.DeconstructionReal.Bag = bag
	D.DeconstructionReal.Slot = slot:GetID()

	if GetTradeTargetItemLink and GetTradeTargetItemLink(7) == itemLink then
		return
	elseif GetContainerItemLink(bag, slot:GetID()) == itemLink then
		D.DeconstructionReal.ID = itemId
		D.DeconstructionReal:SetAttribute('type1', spellType)
		D.DeconstructionReal:SetAttribute(spellType, spell)
		D.DeconstructionReal:SetAttribute('target-bag', D.DeconstructionReal.Bag)
		D.DeconstructionReal:SetAttribute('target-slot', D.DeconstructionReal.Slot)
		D.DeconstructionReal:SetAllPoints(slot)
		D.DeconstructionReal:Show()

		ActionButton_ShowOverlayGlow(D.DeconstructionReal)
	end
end

function D:DeconstructParser()
	if not D.DeconstructMode then return end
	if not GameTooltip:IsVisible() then return end

	local owner = GameTooltip:GetOwner()
	if not owner then return end

	local ownerName = owner.GetName and owner:GetName()
	if not ownerName then return end

	if not (strfind(ownerName, 'ElvUI_ContainerFrameBag') or strfind(ownerName, 'ElvUI_BankContainerFrameBag')) then return end

	local bag, slot
	if owner.GetParent then
		local parent = owner:GetParent()
		if parent.GetID then bag = parent:GetID() end
	end
	if owner.GetID then slot = owner:GetID() end

	if not bag or not slot then return end

	local itemLink = GetContainerItemLink(bag, slot)
	if not itemLink then return end

	local itemId = tonumber(itemLink:match("item:(%d+)"))
	if not itemId then return end

	local itemName, _, itemRarity, _, _, itemType, _, _, itemEquipLoc = GetItemInfo(itemId)

	if InCombatLockdown() then return end

	local r, g, b

	local hasKey = HaveKey()
	if (D.HasPickLock or hasKey) and D:IsUnlockable(itemLink) then
		if itemName then
			if D.BlacklistLOCK[itemName] then
				return
			end
			for _, query in ipairs(D.BlacklistLOCKPatterns or {}) do
				if query and query ~= "" then
					local ok, result = pcall(Search.Matches, Search, itemLink, query)
					if ok and result then
						return
					end
				end
			end
		end

		r, g, b = 0, 1, 1
		if D.HasPickLock then
			D:ApplyDeconstruct(itemLink, itemId, D.LOCKname, 'spell', r, g, b, owner)
		elseif hasKey then
			D:ApplyDeconstruct(itemLink, itemId, hasKey, 'item', r, g, b, owner)
		end
		return
	end

	if D.HasJewelcrafting and (D:IsProspectable(itemId) or D:IsProspectableTooltip(itemLink)) then
		r, g, b = 1, 0.5, 0
		D:ApplyDeconstruct(itemLink, itemId, D.PROSPECTname, 'spell', r, g, b, owner)
		return
	end

	if D.HasInscription and D:IsMillable(itemId) then
		r, g, b = 0, 1, 0
		D:ApplyDeconstruct(itemLink, itemId, D.MILLname, 'spell', r, g, b, owner)
		return
	end

	if D.HasEnchanting and D:IsDisenchantable(itemId, itemName, itemLink, itemRarity, itemType, itemEquipLoc) then
		if D:IsBreakable(itemId, itemName, itemLink) then
			r, g, b = 0.5, 0, 1
			local spell = D.DEname
			if D.DEPrimeName and IsSpellKnown(311891) then
				spell = D.DEPrimeName
			end
			D:ApplyDeconstruct(itemLink, itemId, spell, 'spell', r, g, b, owner)
			return
		end
	end
end

function D:GetDeconMode()
	local text
	if D.DeconstructMode then
		text = '|cff00FF00 ' .. VIDEO_OPTIONS_ENABLED .. '|r'
	else
		text = '|cffFF0000 ' .. VIDEO_OPTIONS_DISABLED .. '|r'
	end
	return text
end

function D:ToggleMode()
	if not D:HasRelevantProfession() then return end

	D.DeconstructMode = not D.DeconstructMode

	if D.DeconstructButton then
		local normalTex = D.DeconstructButton:GetNormalTexture()
		if normalTex then
			if D.DeconstructMode then
				normalTex:SetTexture([[Interface\ICONS\INV_Enchant_EssenceCosmicGreater]])
				ActionButton_ShowOverlayGlow(D.DeconstructButton)
			else
				normalTex:SetTexture([[Interface\ICONS\INV_Rod_Enchantedcobalt]])
				ActionButton_HideOverlayGlow(D.DeconstructButton)
			end
		end

		D.DeconstructButton.ttText2 = format(L["Deconstruct Mode Desc"] .. "\n" .. L["Current state: %s."], D:GetDeconMode())
		if GameTooltip:IsOwned(D.DeconstructButton) then B.Tooltip_Show(D.DeconstructButton) end
	end

	if B.BagFrame then D:UpdateBagSlots(B.BagFrame, D.DeconstructMode) end
	if B.BankFrame then D:UpdateBagSlots(B.BankFrame, D.DeconstructMode) end
end

function D:UpdateButtonState()
	if not D.DeconstructButton then return end

	local hasProf = D:HasRelevantProfession()

	if hasProf then
		D.DeconstructButton:Enable()
		D.DeconstructButton:SetAlpha(1)
	else
		D.DeconstructButton:Disable()
		D.DeconstructButton:SetAlpha(0.5)
	end
end

function D:UpdateBagSlots(frame, isActive, onlyBagID)
	if not frame or not frame.Bags then return end

	local hasKey = HaveKey()
	for _, bagID in ipairs(frame.BagIDs) do
		if (not onlyBagID) or (onlyBagID == bagID) then
			if frame.Bags[bagID] then
				for slotID = 1, GetContainerNumSlots(bagID) do
				local slot = frame.Bags[bagID][slotID]
				if slot then
					if isActive then
						local itemLink = GetContainerItemLink(bagID, slotID)
						if itemLink and D:CanProcessItem(itemLink, hasKey) then
							slot:SetAlpha(1)
						else
							slot:SetAlpha(0.3)
						end
					else
						slot:SetAlpha(1)
					end
				end
			end
		end
	end
end
end

function D:ConstructRealDecButton()
	D.DeconstructionReal = CreateFrame('Button', 'ElvUI_DeconReal', E.UIParent, 'SecureActionButtonTemplate')
	D.DeconstructionReal:SetScript('OnEvent', function(obj, event, ...) obj[event](obj, ...) end)
	D.DeconstructionReal:RegisterForClicks('AnyUp', 'AnyDown')
	D.DeconstructionReal:SetFrameStrata('TOOLTIP')

	D.DeconstructionReal.OnLeave = function(frame)
		if InCombatLockdown() then
			frame:SetAlpha(0)
			frame:RegisterEvent('PLAYER_REGEN_ENABLED')
		else
			frame:ClearAllPoints()
			frame:SetAlpha(1)
			if GameTooltip then GameTooltip:Hide() end

			ActionButton_HideOverlayGlow(frame)

			frame:Hide()
		end
	end

	D.DeconstructionReal.SetTip = function(f)
		GameTooltip:SetOwner(f, 'ANCHOR_LEFT', 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:SetBagItem(f.Bag, f.Slot)
	end

	D.DeconstructionReal:SetScript('OnEnter', D.DeconstructionReal.SetTip)
	D.DeconstructionReal:SetScript('OnLeave', function() D.DeconstructionReal:OnLeave() end)
	D.DeconstructionReal:Hide()

	function D.DeconstructionReal:PLAYER_REGEN_ENABLED()
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		D.DeconstructionReal:OnLeave()
	end
end

local function CreateDeconstructButton(bagFrame)
	if not bagFrame or not bagFrame.holderFrame then return end
	if bagFrame.deconstructButton then return end

	local button = CreateFrame("Button", nil, bagFrame.holderFrame)
	button:Size(16 + E.Border)
	button:SetTemplate()
	if bagFrame.vendorGraysButton then
		button:Point("RIGHT", bagFrame.vendorGraysButton, "LEFT", -5, 0)
	elseif bagFrame.sortButton then
		button:Point("RIGHT", bagFrame.sortButton, "LEFT", -5, 0)
	else
		button:Point("TOPRIGHT", bagFrame, "TOPRIGHT", -25, -5)
	end

	button:SetNormalTexture("Interface\\ICONS\\INV_Rod_Enchantedcobalt")
	button:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	button:GetNormalTexture():SetInside()
	button:SetPushedTexture("Interface\\ICONS\\INV_Rod_Enchantedcobalt")
	button:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
	button:GetPushedTexture():SetInside()
	button:StyleButton(nil, true)
	button.ttText = L["Deconstruct Mode"]
	button.ttText2 = format(L["Deconstruct Mode Desc"] .. "\n" .. L["Current state: %s."], D:GetDeconMode())
	button:SetScript("OnEnter", B.Tooltip_Show)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button:SetScript("OnClick", function() D:ToggleMode() end)

	bagFrame.deconstructButton = button
	D.DeconstructButton = button

	if bagFrame.editBox then
		bagFrame.editBox:ClearAllPoints()
		bagFrame.editBox:Point("BOTTOMLEFT", bagFrame.holderFrame, "TOPLEFT", (E.Border * 2) + 18, E.Border * 2 + 2)
		bagFrame.editBox:Point("RIGHT", bagFrame.deconstructButton, "LEFT", -5, 0)
	end
end

local function SetupDeconstructButton()
	if D.DeconstructButton then return end

	D:UpdateProfessions()

	if not B.BagFrame then return end

	CreateDeconstructButton(B.BagFrame)

	D:UpdateButtonState()

	if not D.DeconstructionReal then
		D:ConstructRealDecButton()

		GameTooltip:HookScript('OnShow', function() D:DeconstructParser() end)
		GameTooltip:HookScript('OnUpdate', function() D:DeconstructParser() end)
	end

	B.BagFrame:HookScript('OnHide', function()
		D.DeconstructMode = false
		if D.DeconstructButton then
			local normalTex = D.DeconstructButton:GetNormalTexture()
			if normalTex then normalTex:SetTexture([[Interface\ICONS\INV_Rod_Enchantedcobalt]]) end
			ActionButton_HideOverlayGlow(D.DeconstructButton)
		end
		if B.BagFrame then D:UpdateBagSlots(B.BagFrame, false) end
		if B.BankFrame then D:UpdateBagSlots(B.BankFrame, false) end
		if D.DeconstructionReal then D.DeconstructionReal:OnLeave() end
	end)
end

function D:SKILL_LINES_CHANGED()
	D:UpdateProfessions()
	D:UpdateButtonState()
end

function D:CHAT_MSG_ADDON(event, prefix, msg)
	if prefix == 'INVOKE_CLIENT_BUTTON' and msg and (msg:find(tostring(D.PrimeDEID)) or msg:find("311891")) then
		D:UpdateProfessions()
		D:UpdateButtonState()
	end
end

function D:SPELLS_CHANGED()
	D:UpdateProfessions()
	D:UpdateButtonState()
end

function D:LEARNED_SPELL_IN_TAB()
	D:UpdateProfessions()
	D:UpdateButtonState()
end

function D:BAG_UPDATE(event, bagID)
	if D.DeconstructMode then
		if B.BagFrame then D:UpdateBagSlots(B.BagFrame, true, bagID) end
		if B.BankFrame then D:UpdateBagSlots(B.BankFrame, true, bagID) end
	end
end

function D:BAG_UPDATE_DELAYED()
	D:BAG_UPDATE()
end

function D:Initialize()
	if not E.private.bags.enable then return end
	if not E.db.bags.deconstruct then return end

	if type(E.db.bags.deconstructBlacklist) == "string" then
		local newTable = {}
		for item in string.gmatch(E.db.bags.deconstructBlacklist, "([^,]+)") do
			item = item:match("^%s*(.-)%s*$") -- trim
			if item and item ~= "" then
				local itemID = item:match("item:(%d+)")
				newTable[(itemID or item)] = item
			end
		end
		E.db.bags.deconstructBlacklist = newTable
	end


	hooksecurefunc(B, "Layout", function(_, isBank)
		if not isBank then if B.BagFrame and not D.DeconstructButton then E:Delay(0.1, function() SetupDeconstructButton() end) end end

		if D.DeconstructMode then
			E:Delay(0.05, function()
				if B.BagFrame then D:UpdateBagSlots(B.BagFrame, true) end
				if B.BankFrame then D:UpdateBagSlots(B.BankFrame, true) end
			end)
		end

		if B.BagFrame and not B.BagFrame.deconstructDragHooked then
			B.BagFrame:HookScript("OnDragStop", function(self)
				if D.DeconstructMode then
					D:UpdateBagSlots(self, true)
				end
			end)
			B.BagFrame.deconstructDragHooked = true
		end

		if B.BankFrame and not B.BankFrame.deconstructDragHooked then
			B.BankFrame:HookScript("OnDragStop", function(self)
				if D.DeconstructMode then
					D:UpdateBagSlots(self, true)
				end
			end)
			B.BankFrame.deconstructDragHooked = true
		end
	end)

	D:Blacklisting('DE')
	D:Blacklisting('LOCK')

	if D.RegisterCustomEvent then
		D:RegisterCustomEvent('BAG_UPDATE_DELAYED')
	else
		D:RegisterEvent('BAG_UPDATE')
	end
	D:RegisterEvent('SKILL_LINES_CHANGED')
	D:RegisterEvent('CHAT_MSG_ADDON')
	D:RegisterEvent('SPELLS_CHANGED')
	D:RegisterEvent('LEARNED_SPELL_IN_TAB')

	if B.BagFrame and not D.DeconstructButton then E:Delay(0.1, function() SetupDeconstructButton() end) end
end

hooksecurefunc(B, "Initialize", function() D:Initialize() end)
