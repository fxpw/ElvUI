local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local format, join = string.format, string.join
--WoW API / Variables
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local GetLFGDungeonRewards = GetLFGDungeonRewards
local GetNumRandomDungeons = GetNumRandomDungeons
local ToggleFrame = ToggleFrame

local BATTLEGROUND_HOLIDAY = BATTLEGROUND_HOLIDAY
local DUNGEONS = DUNGEONS
local NOT_APPLICABLE = NOT_APPLICABLE

local function RoleIcon(role)
	local left, right, top, bottom = GetTexCoordsForRoleSmallCircle(role)
	return format("|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:%s:%s:%s:%s|t", left, right, top, bottom)
end

local TANK_ICON = RoleIcon("TANK")
local HEALER_ICON = RoleIcon("HEALER")
local DPS_ICON = RoleIcon("DAMAGER")

local displayString = ""
local enteredFrame = false

local function MakeIconString(tank, healer, damage)
	local str = ""
	if tank then
		str = str..TANK_ICON
	end
	if healer then
		str = str..HEALER_ICON
	end
	if damage then
		str = str..DPS_ICON
	end

	return str
end

local function OnEvent(self)
	local tankReward = false
	local healerReward = false
	local dpsReward = false
	local unavailable = true

	for i = 1, GetNumRandomDungeons() do
		local id = GetLFGRandomDungeonInfo(i)
		local eligible, forTank, forHealer, forDamage, itemCount = GetLFGDungeonRewards(id)
		if eligible and forTank and itemCount > 0 then tankReward = true; unavailable = false end
		if eligible and forHealer and itemCount > 0 then healerReward = true; unavailable = false end
		if eligible and forDamage and itemCount > 0 then dpsReward = true; unavailable = false end
	end

	local stat = unavailable and NOT_APPLICABLE or MakeIconString(tankReward, healerReward, dpsReward)
	self.text:SetFormattedText(displayString, BATTLEGROUND_HOLIDAY..": ", stat)
end

local function OnClick()
	ToggleFrame(_G.LFDParentFrame)
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	enteredFrame = true

	local numCTA = 0
	local addTooltipHeader = true
	for i = 1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		local tankReward = false
		local healerReward = false
		local dpsReward = false
		local unavailable = true

		local eligible, forTank, forHealer, forDamage, itemCount = GetLFGDungeonRewards(id)
		if eligible then unavailable = false end
		if eligible and forTank and itemCount > 0 then tankReward = true end
		if eligible and forHealer and itemCount > 0 then healerReward = true end
		if eligible and forDamage and itemCount > 0 then dpsReward = true end

		if not unavailable then
			local rolesString = MakeIconString(tankReward, healerReward, dpsReward)
			if rolesString ~= "" then
				if addTooltipHeader then
					DT.tooltip:AddLine(DUNGEONS)
					addTooltipHeader = false
				end
				DT.tooltip:AddDoubleLine(name..":", rolesString, 1, 1, 1)
			end
			if tankReward or healerReward or dpsReward then numCTA = numCTA + 1 end
		end
	end

	DT.tooltip:Show()
end

local updateInterval = 10
local function Update(self, elapsed)
	if self.timeSinceUpdate and self.timeSinceUpdate > updateInterval then
		OnEvent(self)

		if enteredFrame then
			OnEnter(self)
		end

		self.timeSinceUpdate = 0
	else
		self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed
	end
end

local function OnLeave()
	enteredFrame = false
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s", hex, "%s|r")
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("CallToArms", {"LFG_UPDATE", "LFG_QUEUE_STATUS_UPDATE", "LFG_PROPOSAL_UPDATE", "LFG_PROPOSAL_SHOW", "LFG_PROPOSAL_FAILED", "LFG_PROPOSAL_SUCCEEDED", "LFG_ROLE_CHECK_SHOW", "LFG_ROLE_CHECK_HIDE", "LFG_BOOT_PROPOSAL_UPDATE", "LFG_ROLE_UPDATE", "LFG_UPDATE_RANDOM_INFO"}, OnEvent, Update, OnClick, OnEnter, OnLeave, BATTLEGROUND_HOLIDAY)
