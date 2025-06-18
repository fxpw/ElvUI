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
local GetMouseFocus = GetMouseFocus
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
		queuedSpellFrame = CreateFrame("Frame", "ElvOF_WatchFrame")
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


local tableForPowerTrue = {
	MANA = true,
	RAGE = true,
	ENERGY = true,
	RUNIC_POWER = true,
}
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
		if spelllist[spellName .. rank] then
			spellName = spelllist[spellName .. rank]
		end
		local _, _, _, powerCost, _, powerType = GetSpellInfo(spellName);
		if powerType and powerCost then
			if powerType == powerTypeToCheck then
				return powerCost;
			end
		end
	end
end

-- local LastTickTime = GetTime()
-- local TickDelay = 2.025 -- Average tick time is slightly over 2 seconds
-- local myClass = select(2, UnitClass('player'))
-- local Mp5Delay = 5
-- local Mp5DelayWillEnd = nil
-- local Mp5IgnoredSpells = {
-- 	[18182] = true, -- Improved Life Tap 1
-- 	[18183] = true, -- Improved Life Tap 2
-- 	[1454] = true, -- Life Tap 1
-- 	[1455] = true, -- Life Tap 2
-- 	[1456] = true, -- Life Tap 3
-- 	[11687] = true, -- Life Tap 4
-- 	[11688] = true, -- Life Tap 5
-- 	[11689] = true, -- Life Tap 6
-- }

-- local LastValue = UnitPower('player')
-- local ENERGY = "ENERGY"
-- local MANA = "MANA"

-- -- Sets tick time to the last possible time based on the last tick
-- local UpdateTickTime = function(now)
-- 	LastTickTime = now - ((now - LastTickTime) % TickDelay)
-- end

local Update = function(self, elapsed)
	local element = self.PowerCostDisplay
	element.sinceLastUpdate = (element.sinceLastUpdate or 0) + (tonumber(elapsed) or 0)

	if element.sinceLastUpdate > 0.01 then
		local pnumber, powerType = UnitPowerType(element.unit)
		local CurrentValue = UnitPower(element.unit, pnumber)
		local MaxPower = UnitPowerMax(element.unit, pnumber)
		local cost = GetSpellPowerCost(tableForPower[powerType], element.unit)
		cost = cost and cost or 0
		if cost > 0 then
			element.Spark:Show()
			element:SetMinMaxValues(0, MaxPower)
			element.Spark:SetVertexColor(1, 1, 1, 1)
			element:SetValue(CurrentValue - cost)
		else
			element.Spark:Hide()
		end

		element.sinceLastUpdate = 0
	end
end

-- local OnUnitPowerUpdate = function()
-- 	local pnumber,powerType = UnitPowerType('player')
-- 	if powerType ~= MANA and powerType ~= ENERGY then return end

-- 	-- We also register ticks from mp5 gear within the 5-second-rule to get a more accurate sync later.
-- 	-- Unfortunately this registers a tick when a mana pot or life tab is used.
-- 	local CurrentValue = UnitPower('player', pnumber)
-- 	if CurrentValue > LastValue then
-- 		LastTickTime = GetTime()
-- 	end

-- 	LastValue = CurrentValue
-- end

-- local OnUnitSpellcastSucceeded = function(_, _, _, _, spellID)
-- 	local _,powerType = UnitPowerType('player')
-- 	if powerType ~= MANA then return end

-- 	local spellCost = false
-- 	local cost = GetSpellPowerCost(tableForPower[powerType])
-- 	if cost and cost>0 then
-- 		spellCost = true
-- 	end

-- 	if not spellCost or Mp5IgnoredSpells[spellID] then
-- 		return
-- 	end

-- 	Mp5DelayWillEnd = GetTime() + 5
-- end


local Path = function(self, ...)
	return (self.PowerCostDisplay.Override or Update)(self, ...)
end

local Enable = function(self, unit)
	local element = self.Power and self.PowerCostDisplay
	if element then
		element.unit = unit
		element.__owner = self

		if element:IsObjectType('StatusBar') and not element:GetStatusBarTexture() then
			element:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
			element:GetStatusBarTexture():SetAlpha(0)
			element:SetMinMaxValues(0, 2)
		end

		local spark = element.Spark
		if spark and spark:IsObjectType('Texture') and not spark:GetTexture() then
			spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
			spark:SetSize(20, 20)
			spark:SetBlendMode('ADD')
			spark:SetPoint('CENTER', element:GetStatusBarTexture(), 'RIGHT')
		end

		-- self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', OnUnitSpellcastSucceeded)
		-- self:RegisterEvent('UNIT_POWER_UPDATE', OnUnitPowerUpdate)

		element:SetScript('OnUpdate', function(_, elapsed) Path(self, elapsed) end)

		return true
	end
end

local Disable = function(self)
	local element = self.Power and self.PowerCostDisplay

	if element then
		-- self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', OnUnitSpellcastSucceeded)
		-- self:UnregisterEvent('UNIT_POWER_UPDATE', OnUnitPowerUpdate)

		element.Spark:Hide()
		element:SetScript('OnUpdate', nil)

		return false
	end
end

oUF:AddElement('PowerCostDisplay', Path, Enable, Disable)