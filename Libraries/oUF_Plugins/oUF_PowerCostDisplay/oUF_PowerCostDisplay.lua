local _, ns = ...
local oUF = ns.oUF

local next = next
local GetTime = GetTime
local UnitPower = UnitPower
local UnitClass = UnitClass
local tonumber = tonumber
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
local GetSpellInfo = GetSpellInfo
local IsCurrentSpell = IsCurrentSpell
local queueableSpells

local classQueueableSpells = {
	["WARRIOR"] = {
		(select(1, GetSpellInfo(78))), -- Heroic Strike
		(select(1, GetSpellInfo(845))), -- Cleave
	},
	["HUNTER"] = {
		(select(1, GetSpellInfo(2973))), -- Raptor Strike
	},
	["DRUID"] = {
		(select(1, GetSpellInfo(6807))), -- Maul
	},
	["DEATHKNIGHT"] = {
		(select(1, GetSpellInfo(56815))), -- Rune Strike
	},
}
local class = select(2, UnitClass("player"))
queueableSpells = classQueueableSpells[class]

local queuedSpellFrame
local function WatchForQueuedSpell()
	if not queuedSpellFrame then
		queuedSpellFrame = _G["ElvoUF_WatchSpellFrame"] and _G["ElvoUF_WatchSpellFrame"] or
		CreateFrame("Frame", "ElvoUF_WatchSpellFrame")
		queuedSpellFrame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")

		queuedSpellFrame:SetScript("OnEvent", function(self)
			local newQueuedSpell
			if queueableSpells then
				for _, spellName in ipairs(queueableSpells) do
					if IsCurrentSpell(spellName) then
						newQueuedSpell = spellName
						break
					end
				end
			end
			if newQueuedSpell ~= self.queuedSpell then
				self.queuedSpell = newQueuedSpell
			end
		end)
	end
end

WatchForQueuedSpell()
local function GetQueuedSpell()
	return queuedSpellFrame and queuedSpellFrame.queuedSpell
end


local spelllist = {}

for id = 1, 100000 do
	local name, rank = GetSpellInfo(id);
	if name and rank then
		spelllist[name .. rank] = id
	end
end

for id = 300000, 350000 do
	local name = GetSpellInfo(id);
	if name then
		spelllist[spelllist] = id
	end
end


local tableForPower = {
	MANA = 0,
	RAGE = 1,
	ENERGY = 3,
	RUNIC_POWER = 6,
}


local GetSpellPowerCost = function(powerTypeToCheck, unit)
	local spellName, rank = UnitCastingInfo(unit)
	if not spellName and (unit == "player" or UnitGUID(unit) == UnitGUID("player")) then
		spellName = GetQueuedSpell()
	end
	if spellName then
		if rank and spelllist[spellName .. rank] then
			spellName = spelllist[spellName .. rank]
			local _, _, _, powerCost, _, powerType = GetSpellInfo(spellName);
			if powerType and powerCost then
				if powerType == powerTypeToCheck then
					return powerCost;
				end
			end
		end
	end
end

local Update = function(self, elapsed)
	local element = self.PowerCostDisplay
	if element.PreUpdate then
		element:PreUpdate()
	end
	element.sinceLastUpdate = (element.sinceLastUpdate or 0) + (tonumber(elapsed) or 0)

	if element.sinceLastUpdate > 0.01 then
		local pnumber, powerType = UnitPowerType(element.unit)
		local CurrentValue = UnitPower(element.unit, pnumber)
		local MaxPower = UnitPowerMax(element.unit, pnumber)
		local cost = GetSpellPowerCost(tableForPower[powerType], element.unit)
		cost = cost and cost or 0
		if cost > 0 then
			element:SetMinMaxValues(0, MaxPower)
			element:SetValue(CurrentValue - cost)
		else
			element:SetValue(0)
		end

		element.sinceLastUpdate = 0
	end
	if element.PostUpdate then
		return element:PostUpdate()
	end
end

local Path = function(self, ...)
	return (self.PowerCostDisplay.Override or Update)(self, ...)
end
local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local element = self.Power and self.PowerCostDisplay
	if element then
		element:Show()
		element.unit = self.unit or unit
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if element:IsObjectType('StatusBar') and not element:GetStatusBarTexture() then
			element:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
			element:GetStatusBarTexture():SetAlpha(0.3)
			element:SetMinMaxValues(0, 2)
		end

		element:SetScript('OnUpdate', function(_, elapsed) Path(self, elapsed) end)

		return true
	end
end

local Disable = function(self)
	local element = self.Power and self.PowerCostDisplay
	element:Hide()
	if element then
		element:SetScript('OnUpdate', nil)

		return false
	end
end

oUF:AddElement('PowerCostDisplay', Path, Enable, Disable)