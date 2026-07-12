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
local pairs, setmetatable, unpack = pairs, setmetatable, unpack

local C_Item = C_Item
local C_Timer = C_Timer
local GetTradeTargetItemLink = GetTradeTargetItemLink
local InCombatLockdown = InCombatLockdown
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetSpellInfo = GetSpellInfo
local GetItemInfo = GetItemInfo
local GetItemInfoEx = GetItemInfoEx
local GetItemSetInfo = GetItemSetInfo
local GetItemCount = GetItemCount
local GetTime = GetTime
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
	[785] = true, -- Mageroyal
	[2447] = true, -- Peacebloom
	[2449] = true, -- Earthroot
	[2450] = true, -- Briarthorn
	[2452] = true, -- Swiftthistle
	[2453] = true, -- Bruiseweed
	[3355] = true, -- Wild Steelbloom
	[3356] = true, -- Kingsblood
	[3357] = true, -- Liferoot
	[3358] = true, -- Khadgar's Whisker
	[3369] = true, -- Grave Moss
	[3818] = true, -- Fadeleaf
	[3819] = true, -- Dragon's Teeth (Wintersbite)
	[3820] = true, -- Stranglekelp
	[3821] = true, -- Goldthorn
	[4625] = true, -- Firebloom
	[8831] = true, -- Purple Lotus
	[8836] = true, -- Arthas' Tears
	[8838] = true, -- Sungrass
	[8839] = true, -- Blindweed
	[8845] = true, -- Ghost Mushroom
	[8846] = true, -- Gromsblood
	[13463] = true, -- Dreamfoil
	[13464] = true, -- Golden Sansam
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
D.Keys = {
	[15869] = true,
	[15870] = true,
	[15871] = true,
	[15872] = true,
	[43854] = true,
	[43853] = true,
}
D.BlacklistDE = {}
D.BlacklistLOCK = {}
D.BlacklistDEPatterns = {}
D.BlacklistLOCKPatterns = {}
D.ItemProcessingCache = {}
D.PendingItemInfo = {}
D.DeconstructButtons = setmetatable({}, { __mode = "k" })
local skeletonKeys = { 43853, 43854, 15872, 15871, 15870, 15869 }

local processTooltip
local disenchantMinSkillPrefix = ITEM_DISENCHANT_MIN_SKILL and ITEM_DISENCHANT_MIN_SKILL:match("^(.-)%%s")
local PROCESS_UNLOCK = "unlock"
local PROCESS_PROSPECT = "prospect"
local PROCESS_MILL = "mill"
local PROCESS_DISENCHANT = "disenchant"

local function PrepareProcessTooltip(itemLink, bag, slot)
	if not itemLink then return end

	if not processTooltip then
		processTooltip = CreateFrame("GameTooltip", "ElvUIDeconstructScanTooltip", UIParent, "GameTooltipTemplate")
	end

	processTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	processTooltip:ClearLines()
	if bag ~= nil and slot then
		processTooltip:SetBagItem(bag, slot)
	else
		processTooltip:SetHyperlink(itemLink)
	end
	return processTooltip:GetName(), processTooltip:NumLines()
end

local function FinishProcessTooltip()
	processTooltip:Hide()
	processTooltip:ClearLines()
end

local function GetItemClassAndSet(item)
	local _, _, _, _, _, _, _, _, _, _, _, _, classID, _, _, setID = GetItemInfoEx(item)
	return classID, setID
end

local function IsGladiatorItem(itemName, setID)
	if itemName and (strfind(itemName, "гладиатор", 1, true) or strfind(itemName, "Гладиатор", 1, true)
	or strfind(itemName, "gladiator", 1, true) or strfind(itemName, "Gladiator", 1, true))
	then
		return true
	end

	if setID and setID ~= 0 then
		local setName = GetItemSetInfo(setID)
		return setName and (strfind(setName, "гладиатор", 1, true) or strfind(setName, "Гладиатор", 1, true)
		or strfind(setName, "gladiator", 1, true) or strfind(setName, "Gladiator", 1, true)) or false
	end

	return false
end

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

function D:GetAvailableKey()
	local now = GetTime()
	if D._keyCheckTime and now < D._keyCheckTime then
		return D._availableKey
	end

	local availableKey
	for _, key in ipairs(skeletonKeys) do
		if GetItemCount(key) > 0 then
			availableKey = key
			break
		end
	end

	D._keyCheckTime = now + 0.5
	if D._availableKey ~= availableKey then
		D._availableKey = availableKey
		wipe(D.ItemProcessingCache)
	end
	return availableKey
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

function D:IsDisenchantableTooltip(itemLink, bag, slot)
	local tooltipName, numLines = PrepareProcessTooltip(itemLink, bag, slot)
	if not tooltipName then return nil end

	local result
	for i = 2, numLines do
		local line = _G[tooltipName .. "TextLeft" .. i]
		local text = line and line:GetText()
		if text == ITEM_DISENCHANT_NOT_DISENCHANTABLE then
			result = false
			break
		elseif text == ITEM_DISENCHANT_ANY_SKILL
		or (text and disenchantMinSkillPrefix and strfind(text, disenchantMinSkillPrefix, 1, true) == 1)
		then
			result = true
			break
		end
	end

	FinishProcessTooltip()
	return result
end

function D:IsDisenchantable(itemId, itemName, itemLink, itemRarity, itemType, itemEquipLoc, bag, slot)
	if not itemId or not itemName or not D.HasEnchanting then return false end

	local tooltipResult = D:IsDisenchantableTooltip(itemLink, bag, slot)
	if tooltipResult ~= nil then return tooltipResult end

	local classID, setID = GetItemClassAndSet(itemLink or itemId)
	if IsGladiatorItem(itemName, setID) then return false end

	if not itemRarity or itemRarity < 2 or itemRarity > 4 then return false end
	if classID ~= 2 and classID ~= 4 then return false end
	if not itemEquipLoc or itemEquipLoc == "" then return false end

	return true
end

function D:IsProspectable(itemId)
	if not itemId or not D.HasJewelcrafting then return false end
	return prospectableOres[tonumber(itemId)] or false
end

function D:IsProspectableTooltip(itemLink, bag, slot)
	if not itemLink then return false end
	local tooltipName, numLines = PrepareProcessTooltip(itemLink, bag, slot)
	if not tooltipName then return false end

	local result = false
	for i = 2, numLines do
		local line = _G[tooltipName .. "TextLeft" .. i]
		if line and line:GetText() then
			if ITEM_PROSPECTABLE and strfind(line:GetText(), ITEM_PROSPECTABLE, 1, true) then
				result = true
				break
			end
		end
	end
	FinishProcessTooltip()
	return result
end

function D:IsMillable(itemId)
	if not itemId or not D.HasInscription then return false end
	return millableHerbs[tonumber(itemId)] or false
end

function D:IsMillableTooltip(itemLink, bag, slot)
	if not itemLink or not ITEM_MILLABLE then return false end
	local tooltipName, numLines = PrepareProcessTooltip(itemLink, bag, slot)
	if not tooltipName then return false end

	local result = false
	for i = 2, numLines do
		local line = _G[tooltipName .. "TextLeft" .. i]
		local text = line and line:GetText()
		if text and strfind(text, ITEM_MILLABLE, 1, true) then
			result = true
			break
		end
	end
	FinishProcessTooltip()
	return result
end

function D:IsUnlockable(itemLink, bag, slot)
	if not itemLink then return false end
	local tooltipName, numLines = PrepareProcessTooltip(itemLink, bag, slot)
	if not tooltipName then return false end

	local result = false
	for i = 2, numLines do
		local line = _G[tooltipName .. "TextLeft" .. i]
		if line then
			local text = line:GetText()
			if text and strfind(text, LOCKED) then
				result = true
				break
			end
		end
	end
	FinishProcessTooltip()
	return result
end

function D:GetProcessAction(itemLink, hasKey, count, bag, slot)
	if not itemLink then return end

	local itemId = tonumber(itemLink:match("item:(%d+)"))
	if not itemId then return end

	local itemName, _, itemRarity, _, _, itemType, _, _, itemEquipLoc = GetItemInfo(itemId)
	if not itemName then
		D.PendingItemInfo[itemId] = true
		C_Item.GetItemInfo(itemId, true)
		return
	end

	if (D.HasPickLock or hasKey) and D:IsUnlockable(itemLink, bag, slot) then
		if D.BlacklistLOCK[itemName] then return end
		for _, query in ipairs(D.BlacklistLOCKPatterns or {}) do
			if query and query ~= "" then
				local ok, matchResult = pcall(Search.Matches, Search, itemLink, query)
				if ok and matchResult then return end
			end
		end
		if D.HasPickLock then
			return PROCESS_UNLOCK, D.LOCKname, "spell", itemId
		elseif hasKey then
			return PROCESS_UNLOCK, hasKey, "item", itemId
		end
	end

	local process = D.ItemProcessingCache[itemId]
	if process == nil then
		process = false
		if D.HasJewelcrafting and (D:IsProspectable(itemId) or D:IsProspectableTooltip(itemLink, bag, slot)) then
			process = PROCESS_PROSPECT
		elseif D.HasInscription and (D:IsMillable(itemId) or D:IsMillableTooltip(itemLink, bag, slot)) then
			process = PROCESS_MILL
		elseif D.HasEnchanting and D:IsDisenchantable(itemId, itemName, itemLink, itemRarity, itemType, itemEquipLoc, bag, slot) then
			if D:IsBreakable(itemId, itemName, itemLink) then
				process = PROCESS_DISENCHANT
			end
		end

		D.ItemProcessingCache[itemId] = process
	end

	if process == PROCESS_PROSPECT and (count or 0) >= 5 then
		return process, D.PROSPECTname, "spell", itemId
	elseif process == PROCESS_MILL and (count or 0) >= 5 then
		return process, D.MILLname, "spell", itemId
	elseif process == PROCESS_DISENCHANT then
		local spell = D.DEname
		if D.DEPrimeName and IsSpellKnown(D.PrimeDEID) then
			spell = D.DEPrimeName
		end
		return process, spell, "spell", itemId
	end
end

function D:CanProcessItem(itemLink, hasKey, count, bag, slot)
	return D:GetProcessAction(itemLink, hasKey, count, bag, slot) ~= nil
end

function D:ApplyDeconstruct(itemLink, itemId, spell, spellType, slot)
	if not slot or not D.DeconstructionReal then return end
	if slot == D.DeconstructionReal then return end

	local bag = slot.bag or slot:GetParent():GetID()
	local slotID = slot.slot or slot:GetID()

	local validBag = slot.bag or (B.BagFrame and B.BagFrame.Bags and B.BagFrame.Bags[bag]) or (B.BankFrame and B.BankFrame.Bags and B.BankFrame.Bags[bag])
	if not validBag then return end

	if GetTradeTargetItemLink and GetTradeTargetItemLink(7) == itemLink then
		return
	elseif GetContainerItemLink(bag, slotID) == itemLink then
		local targetKey = format("%s:%s:%s:%s:%s:%s", bag, slotID, itemId, spellType, tostring(spell), tostring(slot))
		if D.DeconstructionReal.TargetKey == targetKey and D.DeconstructionReal:IsShown() then
			ActionButton_ShowOverlayGlow(D.DeconstructionReal)
			return
		end

		D.DeconstructionReal.TargetKey = targetKey
		D.DeconstructionReal.Bag = bag
		D.DeconstructionReal.Slot = slotID
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

	local isAdiBagsItem = strfind(ownerName, 'AdiBagsItemButton') or strfind(ownerName, 'AdiBagsBankItemButton')
	if not (strfind(ownerName, 'ElvUI_ContainerFrameBag') or strfind(ownerName, 'ElvUI_BankContainerFrameBag') or isAdiBagsItem) then return end

	local bag, slot
	if isAdiBagsItem then
		bag = owner.bag
		slot = owner.slot
	else
		if owner.GetParent then
			local parent = owner:GetParent()
			if parent.GetID then bag = parent:GetID() end
		end
		if owner.GetID then slot = owner:GetID() end
	end

	if not bag or not slot then return end

	local itemLink = GetContainerItemLink(bag, slot)
	if not itemLink then return end

	if InCombatLockdown() then return end

	local count = select(2, GetContainerItemInfo(bag, slot)) or 0
	local process, spell, spellType, itemId = D:GetProcessAction(itemLink, D:GetAvailableKey(), count, bag, slot)
	if process then
		D:ApplyDeconstruct(itemLink, itemId, spell, spellType, owner)
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

function D:UpdateDeconstructButton(button)
	if not button then return end

	local normalTex = button:GetNormalTexture()
	if normalTex then
		if D.DeconstructMode then
			normalTex:SetTexture([[Interface\ICONS\INV_Enchant_EssenceCosmicGreater]])
			ActionButton_ShowOverlayGlow(button)
		else
			normalTex:SetTexture([[Interface\ICONS\INV_Rod_Enchantedcobalt]])
			ActionButton_HideOverlayGlow(button)
		end
	end

	button.ttText2 = format(L["Deconstruct Mode Desc"] .. "\n" .. L["Current state: %s."], D:GetDeconMode())
	if D:HasRelevantProfession() then
		button:Enable()
		button:SetAlpha(1)
	else
		button:Disable()
		button:SetAlpha(0.5)
	end
	if GameTooltip:IsOwned(button) then B.Tooltip_Show(button) end
end

function D:RegisterDeconstructButton(button)
	if not button then return end
	D.DeconstructButtons[button] = true
	D.DeconstructButton = D.DeconstructButton or button
	D:UpdateDeconstructButton(button)
end

function D:UpdateButtonState()
	for button in pairs(D.DeconstructButtons) do
		D:UpdateDeconstructButton(button)
	end
end

function D:SetMode(enabled)
	enabled = not not enabled
	if enabled and not D:HasRelevantProfession() then return false end
	D.DeconstructMode = enabled
	D:UpdateButtonState()

	if B.BagFrame then D:UpdateBagSlots(B.BagFrame, enabled) end
	if B.BankFrame then D:UpdateBagSlots(B.BankFrame, enabled) end
	if not enabled and D.DeconstructionReal then D.DeconstructionReal:OnLeave() end
	D:SendMessage("AdiBags_UpdateAllButtons")
	return true
end

function D:ToggleMode()
	return D:SetMode(not D.DeconstructMode)
end

function D:UpdateBagSlots(frame, isActive, onlyBagID)
	if not frame or not frame.Bags then return end

	local hasKey = D:GetAvailableKey()
	for _, bagID in ipairs(frame.BagIDs) do
		if (not onlyBagID) or (onlyBagID == bagID) then
			if frame.Bags[bagID] then
				for slotID = 1, GetContainerNumSlots(bagID) do
				local slot = frame.Bags[bagID][slotID]
				if slot then
					if isActive then
						local itemLink = GetContainerItemLink(bagID, slotID)
						local count = select(2, GetContainerItemInfo(bagID, slotID)) or 0
						if itemLink and D:CanProcessItem(itemLink, hasKey, count, bagID, slotID) then
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
		if D.DeconstructMode and frame:IsMouseOver() then
			ActionButton_ShowOverlayGlow(frame)
			return
		end

		if InCombatLockdown() then
			frame:SetAlpha(0)
			frame:RegisterEvent('PLAYER_REGEN_ENABLED')
		else
			frame.TargetKey = nil
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
		ActionButton_ShowOverlayGlow(f)
		RunNextFrame(function()
			if f:IsShown() and f:IsMouseOver() then
				ActionButton_ShowOverlayGlow(f)
			end
		end)
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
	D:RegisterDeconstructButton(button)

	if bagFrame.editBox then
		bagFrame.editBox:ClearAllPoints()
		bagFrame.editBox:Point("BOTTOMLEFT", bagFrame.holderFrame, "TOPLEFT", (E.Border * 2) + 18, E.Border * 2 + 2)
		bagFrame.editBox:Point("RIGHT", bagFrame.deconstructButton, "LEFT", -5, 0)
	end
end

local function SetupDeconstructButton()
	if not B.BagFrame then return end
	if B.BagFrame.deconstructButton then return end

	CreateDeconstructButton(B.BagFrame)
	D:InitializeExternal()

	B.BagFrame:HookScript('OnHide', function()
		D:SetMode(false)
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

function D:ScheduleModeRefresh()
	if D.ModeRefreshScheduled then return end
	D.ModeRefreshScheduled = true
	C_Timer:After(0.1, function()
		D.ModeRefreshScheduled = nil
		if not D.DeconstructMode then return end
		if B.BagFrame then D:UpdateBagSlots(B.BagFrame, true) end
		if B.BankFrame then D:UpdateBagSlots(B.BankFrame, true) end
		D:SendMessage("AdiBags_UpdateAllButtons")
	end)
end

function D:GET_ITEM_INFO_RECEIVED(event, itemID, success)
	if not D.PendingItemInfo[itemID] then return end
	D.PendingItemInfo[itemID] = nil
	D.ItemProcessingCache[itemID] = nil
	if success and D.DeconstructMode then
		D:ScheduleModeRefresh()
	end
end

function D:PLAYER_REGEN_ENABLED()
	if not D.PendingExternalInit then return end
	D:UnregisterEvent('PLAYER_REGEN_ENABLED')
	D:InitializeExternal()
end

function D:BAG_UPDATE(event, bagID)
	D._keyCheckTime = nil
	D:GetAvailableKey()
	if D.DeconstructMode then
		if B.BagFrame then D:UpdateBagSlots(B.BagFrame, true, bagID) end
		if B.BankFrame then D:UpdateBagSlots(B.BankFrame, true, bagID) end
	end
end

function D:BAG_UPDATE_DELAYED()
	D:BAG_UPDATE()
end

local function MigrateDeconstructBlacklist()
	if type(E.db.bags.deconstructBlacklist) ~= "string" then return end

	local newTable = {}
	for item in string.gmatch(E.db.bags.deconstructBlacklist, "([^,]+)") do
		item = item:match("^%s*(.-)%s*$")
		if item and item ~= "" then
			local itemID = item:match("item:(%d+)")
			newTable[(itemID or item)] = item
		end
	end
	E.db.bags.deconstructBlacklist = newTable
end

function D:InitializeExternal()
	if not E.db.bags.deconstruct then return false end

	if not D.RuntimeInitialized then
		MigrateDeconstructBlacklist()
		D:UpdateProfessions()
		D:Blacklisting('DE')
		D:Blacklisting('LOCK')

		if D.RegisterCustomEvent then
			D:RegisterCustomEvent('BAG_UPDATE_DELAYED')
			D:RegisterCustomEvent('GET_ITEM_INFO_RECEIVED')
		else
			D:RegisterEvent('BAG_UPDATE')
		end
		D:RegisterEvent('SKILL_LINES_CHANGED')
		D:RegisterEvent('CHAT_MSG_ADDON')
		D:RegisterEvent('SPELLS_CHANGED')
		D:RegisterEvent('LEARNED_SPELL_IN_TAB')
		D.RuntimeInitialized = true
	end

	if not D.DeconstructionReal then
		if InCombatLockdown() then
			D.PendingExternalInit = true
			D:RegisterEvent('PLAYER_REGEN_ENABLED')
			return false
		end
		D:ConstructRealDecButton()
	end

	if not D.TooltipHooksInstalled then
		GameTooltip:HookScript('OnShow', function() D:DeconstructParser() end)
		GameTooltip:HookScript('OnUpdate', function() D:DeconstructParser() end)
		D.TooltipHooksInstalled = true
	end

	D.PendingExternalInit = nil
	D:UpdateButtonState()
	return true
end

function D:Initialize()
	if not E.private.bags.enable then return end
	if not E.db.bags.deconstruct then return end
	D:InitializeExternal()

	hooksecurefunc(B, "Layout", function(_, isBank)
		if not isBank then if B.BagFrame and not B.BagFrame.deconstructButton then E:Delay(0.1, function() SetupDeconstructButton() end) end end

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
					if B.BankFrame then D:UpdateBagSlots(B.BankFrame, true) end
				end
			end)
			B.BagFrame.deconstructDragHooked = true
		end

		if B.BankFrame and not B.BankFrame.deconstructDragHooked then
			B.BankFrame:HookScript("OnDragStop", function(self)
				if D.DeconstructMode then
					D:UpdateBagSlots(self, true)
					if B.BagFrame then D:UpdateBagSlots(B.BagFrame, true) end
				end
			end)
			B.BankFrame.deconstructDragHooked = true
		end
	end)

	if B.BagFrame and not B.BagFrame.deconstructButton then E:Delay(0.1, function() SetupDeconstructButton() end) end
end

hooksecurefunc(B, "Initialize", function() D:Initialize() end)
