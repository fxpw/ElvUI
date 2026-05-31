local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame

-- ============================================================================
-- Cutaway element (Health + Power). Substage 4b of the v2.1 retail-like rewrite.
-- Each nameplate gets `frame.Cutaway = { Health = StatusBar, Power = StatusBar }`.
-- The legacy `frame.CutawayHealth` field is preserved as an alias for backwards
-- compatibility (StyleFilter.lua / Plugins still reference it).
-- Both halves are fully wired: Power fires its value callbacks from the
-- OnUpdate poller in Nameplates.lua (the only value source for non-target
-- plates, mirroring Health) and its color callbacks from Power_UpdateColor;
-- Health fires its value callbacks from the OnUpdate poller in Nameplates.lua
-- (the only value source for non-target plates) and its color callbacks from
-- Health_UpdateColor.
-- ============================================================================

-- ===== Health side ==========================================================

function NP:UpdateElement_CutawayHealthFadeOut(frame)
	local cutawayHealth = frame.Cutaway and frame.Cutaway.Health or frame.CutawayHealth
	if not cutawayHealth then return end
	cutawayHealth.fading = true
	E:UIFrameFadeOut(cutawayHealth, self.db.cutaway.health.fadeOutTime, cutawayHealth:GetAlpha(), 0)
	cutawayHealth.isPlaying = nil
end

local function CutawayHealthClosure(frame)
	NP:UpdateElement_CutawayHealthFadeOut(frame)
end

function NP:CutawayHealthValueChangeCallback(frame, health, maxHealth)
	local cutawayHealth = frame.Cutaway and frame.Cutaway.Health or frame.CutawayHealth
	if not cutawayHealth then return end
	if not NP:Health_IsVisible(frame) then
		if cutawayHealth.isPlaying then
			cutawayHealth.isPlaying = nil
			cutawayHealth:SetScript("OnUpdate", nil)
		end
		cutawayHealth:Hide()
		return
	end

	if self.db.cutaway.health.enabled then
		cutawayHealth:SetMinMaxValues(0, maxHealth)
		local oldValue = frame.Health:GetValue()
		local change = oldValue - health
		if change > 0 and not cutawayHealth.isPlaying then
			if cutawayHealth.fading then
				E:UIFrameFadeRemoveFrame(cutawayHealth)
			end
			cutawayHealth.fading = false
			cutawayHealth:SetValue(oldValue)
			cutawayHealth:SetAlpha(1)

			E:Delay(self.db.cutaway.health.lengthBeforeFade, CutawayHealthClosure, frame)

			cutawayHealth.isPlaying = true
			cutawayHealth:Show()
		end
	else
		if cutawayHealth.isPlaying then
			cutawayHealth.isPlaying = nil
			cutawayHealth:SetScript("OnUpdate", nil)
		end
		cutawayHealth:Hide()
	end
end

function NP:CutawayHealthColorChangeCallback(frame, r, g, b)
	local cutawayHealth = frame.Cutaway and frame.Cutaway.Health or frame.CutawayHealth
	if cutawayHealth then
		cutawayHealth:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, 1)
	end
end

function NP:ConstructElement_CutawayHealth(parent)
	local healthBar = parent.Health

	local cutawayHealth = CreateFrame("StatusBar", "$parentCutawayHealth", healthBar)
	cutawayHealth:SetAllPoints()
	cutawayHealth:SetStatusBarTexture(E.media.blankTex)
	cutawayHealth:SetFrameLevel(healthBar:GetFrameLevel() - 1)
	cutawayHealth:Hide()

	NP:RegisterHealthBarCallbacks(parent, NP.CutawayHealthValueChangeCallback, NP.CutawayHealthColorChangeCallback)

	return cutawayHealth
end

-- ===== Power side ===========================================================

function NP:UpdateElement_CutawayPowerFadeOut(frame)
	local cutawayPower = frame.Cutaway and frame.Cutaway.Power
	if not cutawayPower then return end
	cutawayPower.fading = true
	E:UIFrameFadeOut(cutawayPower, self.db.cutaway.power.fadeOutTime, cutawayPower:GetAlpha(), 0)
	cutawayPower.isPlaying = nil
end

local function CutawayPowerClosure(frame)
	NP:UpdateElement_CutawayPowerFadeOut(frame)
end

function NP:CutawayPowerValueChangeCallback(frame, power, maxPower)
	local cutawayPower = frame.Cutaway and frame.Cutaway.Power
	if not cutawayPower then return end

	if self.db.cutaway.power.enabled then
		cutawayPower:SetMinMaxValues(0, maxPower)
		local oldValue = frame.Power:GetValue()
		local change = oldValue - power
		if change > 0 and not cutawayPower.isPlaying then
			if cutawayPower.fading then
				E:UIFrameFadeRemoveFrame(cutawayPower)
			end
			cutawayPower.fading = false
			cutawayPower:SetValue(oldValue)
			cutawayPower:SetAlpha(1)

			E:Delay(self.db.cutaway.power.lengthBeforeFade, CutawayPowerClosure, frame)

			cutawayPower.isPlaying = true
			cutawayPower:Show()
		end
	else
		if cutawayPower.isPlaying then
			cutawayPower.isPlaying = nil
			cutawayPower:SetScript("OnUpdate", nil)
		end
		cutawayPower:Hide()
	end
end

function NP:CutawayPowerColorChangeCallback(frame, r, g, b)
	local cutawayPower = frame.Cutaway and frame.Cutaway.Power
	if cutawayPower then
		cutawayPower:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, 1)
	end
end

function NP:ConstructElement_CutawayPower(parent)
	if not parent.Power then return nil end
	local powerBar = parent.Power

	local cutawayPower = CreateFrame("StatusBar", "$parentCutawayPower", powerBar)
	cutawayPower:SetAllPoints()
	cutawayPower:SetStatusBarTexture(E.media.blankTex)
	cutawayPower:SetFrameLevel(powerBar:GetFrameLevel() - 1)
	cutawayPower:Hide()

	NP:RegisterPowerBarCallbacks(parent, NP.CutawayPowerValueChangeCallback, NP.CutawayPowerColorChangeCallback)

	return cutawayPower
end

-- ===== Wrapper ==============================================================

function NP:Construct_Cutaway(parent)
	local cutaway = {
		Health = NP:ConstructElement_CutawayHealth(parent),
		Power  = NP:ConstructElement_CutawayPower(parent),
	}
	return cutaway
end
