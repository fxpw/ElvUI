local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')

local abs, exp, floor = math.abs, math.exp, math.floor
local sort = table.sort
local pairs = pairs
local wipe = wipe

local ENEMY_TYPES = {
	ENEMY_PLAYER = true,
	ENEMY_NPC = true,
}

local STACK_INTERVAL = 0.05

NP.StackingPlates = NP.StackingPlates or {}

local snapPool = {}
local snap = {}
local active = {}

local function GetStackingDB()
	NP.db = NP.db or E.db.nameplates
	if not NP.db.stacking then
		NP.db.stacking = E:CopyTable(P.nameplates.stacking)
	end

	local def = P.nameplates.stacking
	if def then
		for k, v in pairs(def) do
			if NP.db.stacking[k] == nil then
				NP.db.stacking[k] = v
			end
		end
	end

	return NP.db.stacking
end

local function GetPlatePosition(basePlate)
	local _, _, _, x, y = basePlate:GetPoint(1)
	if x and y then
		return x, y
	end

	local cx, cy = basePlate:GetCenter()
	if not cx or not cy then
		return nil, nil
	end

	local scale = UIParent and UIParent:GetEffectiveScale() or 1
	return cx * scale, cy * scale
end

function NP:IsOverlapStackingEnabled()
	return NP.db and NP.db.motionType == 'OVERLAP_STACK'
end

function NP:ResetPlateOffset(childPlate)
	childPlate:ClearAllPoints()
	childPlate:SetPoint('CENTER')
	local d = NP.StackingPlates[childPlate]
	if d then
		d.applied = 0
		d.lastApplied = 0
	end
end

function NP:ClearStackingForNameplate(nameplate)
	if not nameplate or nameplate == NP.TestFrame then return end
	if NP.StackingPlates[nameplate] then
		NP:ResetPlateOffset(nameplate)
		NP.StackingPlates[nameplate] = nil
	end
end

function NP:ClearAllStackingPlates()
	for childPlate in pairs(NP.StackingPlates) do
		NP:ResetPlateOffset(childPlate)
		NP.StackingPlates[childPlate] = nil
	end
end

local function SortByVisualY(a, b)
	if a.vis ~= b.vis then
		return a.vis < b.vis
	end
	return (a.plate._npSlot or 0) < (b.plate._npSlot or 0)
end

function NP:UpdateNameplateStacking(dt)
	if not NP:IsOverlapStackingEnabled() then return end

	local cfg = GetStackingDB()
	local xspace = cfg.xspace
	local yspace = cfg.yspace
	local maxOffset = cfg.maxOffset
	local dampRate = (cfg.speed and cfg.speed > 0) and (cfg.speed * 22) or 10

	local n = 0
	wipe(snap)
	wipe(active)
	for nameplate in pairs(NP.Plates) do
		if nameplate ~= NP.TestFrame and nameplate:IsShown() and ENEMY_TYPES[nameplate.frameType] then
			local base = nameplate:GetParent()
			if base and base:IsShown() then
				local x, y = GetPlatePosition(base)
				if x and y then
					local d = NP.StackingPlates[nameplate]
					if not d then
						d = {applied = 0, lastApplied = 0}
						NP.StackingPlates[nameplate] = d
					end
					n = n + 1
					local e = snapPool[n]
					if not e then e = {} snapPool[n] = e end
					e.plate = nameplate
					e.base = base
					e.x = x
					e.y = y
					e.vis = y + d.applied
					e.packed = y
					snap[n] = e
					active[nameplate] = true
				end
			end
		end
	end

	for childPlate in pairs(NP.StackingPlates) do
		if not active[childPlate] then
			NP:ResetPlateOffset(childPlate)
			NP.StackingPlates[childPlate] = nil
		end
	end

	if n == 0 then return end

	sort(snap, SortByVisualY)

	for i = 1, n do
		local e = snap[i]
		local packed = e.y
		for j = 1, i - 1 do
			local o = snap[j]
			if abs(e.x - o.x) < xspace then
				local need = o.packed + yspace
				if need > packed then
					packed = need
				end
			end
		end
		e.packed = packed
		local target = packed - e.y
		e.target = (target > maxOffset and maxOffset) or target
	end

	-- ease toward target (lerp) but hard-cap the per-tick move: any target jump
	-- (reslot/membership churn under motion) becomes a smooth ramp, never a jerk.
	local lerp = 1 - exp(-dampRate * dt)
	local maxStep = 90 * dt
	if maxStep < 1 then maxStep = 1 end
	for i = 1, n do
		local e = snap[i]
		local d = NP.StackingPlates[e.plate]
		if d then
			local step = (e.target - d.applied) * lerp
			if step > maxStep then step = maxStep elseif step < -maxStep then step = -maxStep end
			local a = d.applied + step
			if abs(e.target - a) < 0.5 then
				a = e.target
			end
			d.applied = a

			local r = floor(a + 0.5)
			if r ~= d.lastApplied then
				d.lastApplied = r
				e.plate:ClearAllPoints()
				e.plate:SetPoint('CENTER', e.base, 'CENTER', 0, r)
			end
		end
	end
end

function NP.StackingOnUpdate(frame, dt)
	frame.elapsed = (frame.elapsed or 0) + dt
	if frame.elapsed < STACK_INTERVAL then return end
	NP:UpdateNameplateStacking(frame.elapsed)
	frame.elapsed = 0
end

function NP:UpdateStackingState()
	if not NP.Initialized then return end

	if NP:IsOverlapStackingEnabled() then
		if not NP.StackingFrame then
			NP.StackingFrame = CreateFrame('Frame')
		end
		NP.StackingFrame.elapsed = 0
		NP.StackingFrame:SetScript('OnUpdate', NP.StackingOnUpdate)
	else
		if NP.StackingFrame then
			NP.StackingFrame:SetScript('OnUpdate', nil)
		end
		NP:ClearAllStackingPlates()
	end
end

