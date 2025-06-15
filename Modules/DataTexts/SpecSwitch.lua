
local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")
-- local EP = LibStub("LibElvUIPlugin-1.0")

--Lua functions
local  join = string.join

--WoW API / Variables

local ToggleTalentFrame = ToggleTalentFrame


local lastPanel
local displayString = ""


local maxSpecs
local activeSpec
local indexToChangeSpec = 1

local function AddTexture(texture)
	return texture and "|T"..texture..":20:20:0:0:64:64:4:55:4:55|t" or ""
end


local function switchSet()
	-- if not E.db.datatexts.SAOSS then return end
	local names ,_ = C_Talent.GetTalentGroupSettings(activeSpec)
	for i = 1, GetNumEquipmentSets() do
		local name = GetEquipmentSetInfo(i)
		if name and names == name then
			UseEquipmentSet(names)
		end
	end
end

local function OnEvent(self, event)
	lastPanel = self
	E.db.datatexts.SAOSS = E.db.datatexts.SAOSS or false
	maxSpecs =  C_Talent.GetNumTalentGroups()
	activeSpec = C_Talent.GetSpecInfoCache().activeTalentGroup

	local _, specName, talent = E:GetTalentSpecInfo()

	local name ,texture = C_Talent.GetTalentGroupSettings(activeSpec)

	if specName == "None" then
		self.text:SetFormattedText(displayString, "Без специализации","")
	else
		self.text:SetFormattedText(displayString, AddTexture(texture and texture or talent), name and name or specName)
	end

end

local function OnEnter(self)
	DT:SetupTooltip(self)

	for i = 1,maxSpecs do
		-- local _, specName, talent = E:GetTalentSpecInfo()
		local name ,texture = C_Talent.GetTalentGroupSettings(i)
		if activeSpec == i then
			if indexToChangeSpec == i then
				DT.tooltip:AddLine(join(" ",AddTexture(texture and texture or nil), name and name.." (Текущий)" or "Набор талантов "..i.." (Текущий)"), .31,.99,.46)
			else
				DT.tooltip:AddLine(join(" ",AddTexture(texture and texture or nil), name and name.." (Текущий)" or "Набор талантов "..i.." (Текущий)"), 1, 1, 1)
			end
		else
			if indexToChangeSpec == i then
				DT.tooltip:AddLine(join(" ",AddTexture(texture and texture or nil), name and name or "Набор талантов "..i), .31,.99,.46)
			else
				DT.tooltip:AddLine(join(" ",AddTexture(texture and texture or nil), name and name or "Набор талантов "..i), 1, 1, 1)
			end
		end
	end

	local name,_ = C_Talent.GetTalentGroupSettings(indexToChangeSpec)
	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine("ЛКМ", "Сменить специализацию на "..(name and name or indexToChangeSpec), 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddDoubleLine("ПКМ", "Открыть окно талантов", 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddDoubleLine("Shift + СКМ: Менять сет при смене спека (только если имя спека = имя сета)", " " ..(E.db.datatexts.SAOSS and "Вкл" or "Выкл"), 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddDoubleLine("Гортать колесиком мыши для выбора специализации", "", 1, 1, 1, 1, 1, 0)


	DT.tooltip:Show()
end

local function OnClick(self, button)
	if button == "LeftButton" then
		if indexToChangeSpec ~= C_Talent.GetSelectedTalentGroup() then

			if indexToChangeSpec > 2 then
				C_Talent.SelectTalentGroup(indexToChangeSpec)
				if IsResting() then
					C_Talent.SelectedCurrency(1)
				else
					C_Talent.SelectedCurrency(2)
				end
				C_Talent.SetActiveTalentGroup(indexToChangeSpec)
				if E.db.datatexts.SAOSS then
					C_Timer:After(11,switchSet)
					C_Timer:After(12,switchSet)
				end
			else
				C_Talent.SelectTalentGroup(indexToChangeSpec)
				C_Talent.SetActiveTalentGroup(indexToChangeSpec)
				if E.db.datatexts.SAOSS then
					C_Timer:After(6,switchSet)
					C_Timer:After(7,switchSet)
				end
			end

		end

	elseif button == "RightButton" then
		ToggleTalentFrame()

	elseif button == "MiddleButton" and IsShiftKeyDown() then
		E.db.datatexts.SAOSS = not E.db.datatexts.SAOSS
		DT.tooltip:Hide()
		OnEnter(self)
	end
end

local function OnMouseWheel(self,delta)

	indexToChangeSpec = indexToChangeSpec - delta
	if indexToChangeSpec > maxSpecs then
		indexToChangeSpec = maxSpecs
	elseif indexToChangeSpec <= 1 then
		indexToChangeSpec = 1
	end


	DT.tooltip:Hide()
	OnEnter(self)

end

local function ValueColorUpdate(hex)
	displayString = join(" ", "%s%s")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end


E.valueColorUpdateFuncs[ValueColorUpdate] = true


DT:RegisterDatatext("Специализации", {"PLAYER_ENTERING_WORLD", "PLAYER_ALIVE", "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE", "ACTIVE_TALENT_GROUP_CHANGED","INSPECT_TALENT_READY"}, OnEvent, nil, OnClick, OnEnter, nil, "Специализации", OnMouseWheel)
