--[[
# Element: SummonIndicator

Handles the visibility and updating of unit summon status.

## Widget

SummonIndicator - A `Texture` used to display the current summon state.
The element works by changing the texture's.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local SummonIndicator = self:CreateTexture(nil, 'OVERLAY')
    SummonIndicator:SetSize(16, 16)
    SummonIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.SummonIndicator = SummonIndicator
--]]

local _, ns = ...
local oUF = ns.oUF
local find = string.find

local function Update(self, event, ...)
	local element = self.SummonIndicator
	if not element then return end

	if not find(select(1,...), "INCOMING_SUMMON_CHANGED") then return end

	--[[ Callback: SummonIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the SummonIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end
	local summonStatus = 0
	if (C_IncomingSummon.HasIncomingSummon(self.unit)) then
		summonStatus = C_IncomingSummon.IncomingSummonStatus(self.unit)
		if summonStatus == 0 then
			return element:Hide()
		end

		if(summonStatus == Enum.SummonStatus.Pending) then
			element:SetAtlas("Raid-Icon-SummonPending");
		elseif( summonStatus == Enum.SummonStatus.Accepted ) then
			element:SetAtlas("Raid-Icon-SummonAccepted");
		elseif( summonStatus == Enum.SummonStatus.Declined ) then
			element:SetAtlas("Raid-Icon-SummonDeclined");
		end
		element:Show()
		if element.timer and element.timer.IsCancelled and not element.timer:IsCancelled() then
			element.timer:Cancel()
		end
		element.timer = C_Timer:After((summonStatus == 1 and 120) or (summonStatus == 2 and 10) or 4, function()
			element:Hide()
		end);
	else
		return element:Hide()
	end

	--[[ Callback: SummonIndicator:PostUpdate(summonStatus)
	Called after the element has been updated.

	* self      - the Summon element
	* unit      - the unit for which the update has been triggered (string)
	* state     - the unit summon status (integer)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(self.unit, summonStatus)
	end
end
-- local function InitHide(self,...)
-- 	local element = self.SummonIndicator
-- 	if not element then return end
-- 	element:Hide()
-- end
local function Path(self, ...)
	--[[ Override: SummonIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.SummonIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', "ForceUpdate")
end

local function Enable(self)
	local element = self.SummonIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		-- element.InitHide = InitHide

		self:RegisterEvent('CHAT_MSG_ADDON', Path)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface/RaidFrame/RaidFrameSummon]])
		end
		element:Hide();
		return true
	end
end

local function Disable(self)
	local element = self.SummonIndicator
	if (element) then
		element:Hide()

		self:UnregisterEvent('CHAT_MSG_ADDON', Path)
	end
end

oUF:AddElement('SummonIndicator', Path, Enable, Disable)