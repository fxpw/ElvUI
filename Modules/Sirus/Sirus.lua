local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Sirus")
-- local Skin = E:GetModule("Skins")
-- local DT = E:GetModule("DataTexts")
-- local DB = E:GetModule("DataBars")

local INP = C_NamePlate and true or false
local name

-- if C_BattlefieldScoreManager then
-- C_BattlefieldScoreManager.scoreData = {}
-- 	function C_BattlefieldScoreManager:GenerateScoreData()
-- 		wipe(self.scoreData)

-- 		local factionID = C_FactionManager:GetFactionOverride()

-- 		for i = 1, self._GetNumBattlefieldScores() do
-- 			name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone = self._GetBattlefieldScore(i)
-- 			local additionalStatData = {}

-- 			if self:IsValidation() then
-- 				for statID = 1, GetNumBattlefieldStats() do
-- 					tinsert(additionalStatData, GetBattlefieldStatData(i, statID))
-- 				end

-- 				if factionID then
-- 					if name then
-- 						local GUID = UnitGUID(name)

-- 						if GUID then
-- 							faction = factionID
-- 						else
-- 							faction = factionID == PLAYER_FACTION_GROUP.Alliance and PLAYER_FACTION_GROUP.Horde or PLAYER_FACTION_GROUP.Alliance
-- 						end
-- 					else
-- 						faction = factionID == PLAYER_FACTION_GROUP.Alliance and PLAYER_FACTION_GROUP.Horde or PLAYER_FACTION_GROUP.Alliance
-- 					end
-- 				end
-- 			end

-- 			if not self.selectedFaction or self.selectedFaction == faction then
-- 				tinsert(self.scoreData, {name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone, additionalStatData})
-- 			end
-- 		end
-- 	end
-- end
-- do
-- 	local oldPlayerTalentFrame_Refresh = PlayerTalentFrame_Refresh
-- 	function PlayerTalentFrame_Refresh()
-- 		if not PlayerTalentFrame:IsShown() then return end

-- 		return oldPlayerTalentFrame_Refresh()
-- 	end
-- end

do -- temp fix extra ab
	local LAB = E.Libs.LAB
	local function Update(self)
		name = self:GetName()

		if self:HasAction() then
			local actionType, id, _, spellID = GetActionInfo(self._state_action)
			if spellID then
				SPELL_ACTION_DATA[name] = spellID
			elseif actionType == "item" and id then
				ITEM_ACTION_DATA[name] = id
			end
		else
			SPELL_ACTION_DATA[name] = false
			ITEM_ACTION_DATA[name] = false
		end
	end

	local old_script = ExtraActionBarFrame.FindOnActionBar
	function ExtraActionBarFrame:FindOnActionBar(...)
		for button in next, LAB.buttonRegistry do
			if button._state_type == "action" then
				Update(button)
			end
		end

		return old_script(ExtraActionBarFrame, ...)
	end
end

local oldIsAddOnLoaded = IsAddOnLoaded
function IsAddOnLoaded(nameA)
	if nameA == "Blizzard_TimeManager" then
		return true
	else
		return oldIsAddOnLoaded(nameA)
	end
end

PVPUIFrame:HookScript("OnHide", function(self)
	if self.TitleTimer then
		self.TitleTimer:Cancel()
		self.TitleTimer = nil
	end
end)

PVPHonorFrame:HookScript("OnHide", function(self)
	local worldPVP2Button = self.BottomInset.WorldPVPContainer.WorldPVP2Button

	if worldPVP2Button.Timer then
		worldPVP2Button.Timer:Cancel()
		worldPVP2Button.Timer = nil
	end
end)

local function GameMenuFrame_UpdateVisibleButtons()
	if not GameMenuFrame.isSirus then
		GameMenuFrame.isSirus = true
	else
		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() + 1)
	end

	local addonsButton = GameMenuButtonAddOns or ElvUI_AddonListButton
	if addonsButton then
		GameMenuButtonMacros:ClearAllPoints()
		GameMenuButtonMacros:Point("TOP", GameMenuButtonKeybindings, "BOTTOM", 0, -1)

		addonsButton:ClearAllPoints()
		addonsButton:Point("TOP", GameMenuButtonMacros, "BOTTOM", 0, -1)

		GameMenuFrame.ElvUI:ClearAllPoints()
		GameMenuFrame.ElvUI:Point("TOP", addonsButton, "BOTTOM", 0, -1)

		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() + 1)
	end
end

function S:GetUnitCategory(unit)
	local category
	if ElvSirusDB[E.myrealm][unit] then
		category = self.Categories[self.CategoriesIDs[ElvSirusDB[E.myrealm][unit]]]
		return category.name, category.icon, category.name2
--	else

	end
end

function S:UPDATE_MOUSEOVER_UNIT()
	if UnitIsPlayer("mouseover") then
		name = UnitName("mouseover")
		if not name or name == UNKNOWN then return end

		for i = 1, 40 do
			local _, _, _, _, _, _, _, _, _, _, spellID = UnitAura("mouseover", i, "HARMFUL")
			if not spellID then break end

			if self.Categories[spellID] then
				local id = self.Categories[spellID].id
				if ElvSirusDB[E.myrealm][name] ~= id then
					ElvSirusDB[E.myrealm][name] = id
				end
				break
			end
		end
	end
end



function S:NAME_PLATE_UNIT_ADDED(_,unit)
	if UnitIsPlayer(unit) then
		name = UnitName(unit)
		if not name or name == UNKNOWN then return end

		for i = 1, 40 do
			local _, _, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, i, "HARMFUL")
			if not spellID then break end

			if self.Categories[spellID] then
				local id = self.Categories[spellID].id
				if ElvSirusDB[E.myrealm][name] ~= id then
					ElvSirusDB[E.myrealm][name] = id
				end
				break
			end
		end
	end
end

function S:FixArenaTaint()
	ArenaEnemyFrames.ClearAllPoints = E.noop
	ArenaEnemyFrames.SetPoint = E.noop
end

function S:ADDON_LOADED(_, addonName)
	if addonName == "Blizzard_ArenaUI" then
		self:FixArenaTaint()
	end
end

function S:Initialize()
	ElvSirusDB = ElvSirusDB or {}
	ElvSirusDB[E.myrealm] = ElvSirusDB[E.myrealm] or {}
	if not INP then
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	else
		self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	end

	if E.private.unitframe.disabledBlizzardFrames.arena then
		if not IsAddOnLoaded("Blizzard_ArenaUI") then
			self:RegisterEvent("ADDON_LOADED")
		else
			self:FixArenaTaint()
		end
	end
	local _, nameText
	hooksecurefunc("WorldStateScoreFrame_Update", function()
		local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)

		for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
			name, _, _, _, _, faction, _, _, _, classToken = GetBattlefieldScore(offset + i)

			if name then
				local _, _, name2 = S:GetUnitCategory(name)
				if name2 then
					nameText = _G["WorldStateScoreButton"..i.."NameText"]
					nameText:SetFormattedText("%s |cffffffff%s|r", name, name2)
				end
			end
		end
	end)

	GameMenuFrame:HookScript("OnShow", GameMenuFrame_UpdateVisibleButtons)
	local function StaticPopup_OnShow(self)
		if self.ReplayInfoFrame then
			self.ReplayInfoFrame:Hide()
		end
	end

	for index = 1, 4 do
		E.StaticPopupFrames[index]:HookScript("OnShow", StaticPopup_OnShow)
	end
	-- StaticPopup1:HookScript("OnShow",function(self)
	-- 	if StaticPopup1WideEditBox:IsShown() then
	-- 		-- StaticPopup1WideEditBox:StripTextures()
	-- 		-- Skin:HandleInsetFrame()
	-- 		-- Skin:HandleEditBox(StaticPopup1WideEditBox)
	-- 	end
	-- end)
end

local function InitializeCallback()
	S:Initialize()
end

E:RegisterModule(S:GetName(), InitializeCallback)