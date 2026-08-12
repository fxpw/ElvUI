local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join
--WoW API / Variables
local IsFalling = IsFalling
local GetUnitSpeed = GetUnitSpeed

local BASE_MOVEMENT_SPEED = 7

local displayString = ""
local lastPanel
local beforeFalling, wasFlying

local function UpdateSpeed(self)
	local unitSpeed = GetUnitSpeed("player")
	local speed = unitSpeed
	wasFlying = false

	if IsFalling() and wasFlying and beforeFalling then
		speed = beforeFalling
	else
		beforeFalling = speed
	end

	local percent = speed / BASE_MOVEMENT_SPEED * 100
	self.text:SetFormattedText(displayString, percent)
end

local function OnUpdate(self, elapsed)
	self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
	if self.timeSinceLastUpdate >= 1 then
		UpdateSpeed(self)
		self.timeSinceLastUpdate = 0
	end
end

local function OnEvent(self)
	lastPanel = self
	self:SetScript("OnUpdate", OnUpdate)
end

local function ValueColorUpdate(hex)
	displayString = join("", L["Mov. Speed"], ": ", hex, "%.0f%%|r")

	if lastPanel ~= nil then
		UpdateSpeed(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("MovementSpeed", {"UNIT_STATS", "UNIT_AURA", "UNIT_SPELL_HASTE"}, OnEvent, nil, nil, nil, nil, L["Movement Speed"])
