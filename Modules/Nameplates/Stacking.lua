local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')

local abs, exp = math.abs, math.exp
local format = string.format
local pairs = pairs
local strtrim = strtrim
local wipe = wipe
local mathMin, mathMax = math.min, math.max

local ENEMY_TYPES = {
	ENEMY_PLAYER = true,
	ENEMY_NPC = true,
}

NP.StackingPlates = NP.StackingPlates or {}
NP.StackingForcedPlates = NP.StackingForcedPlates or {}

local function GetStackingDB()
	NP.db = NP.db or E.db.nameplates
	if not NP.db.stacking then
		NP.db.stacking = E:CopyTable(P.nameplates.stacking)
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

function NP:ClearStackingPlate(basePlate)
	if not basePlate then return end

	basePlate:SetClampRectInsets(0, 0, 0, 0)
	basePlate:SetClampedToScreen(false)
	NP.StackingPlates[basePlate] = nil
end

function NP:ClearStackingForNameplate(nameplate)
	if not nameplate or nameplate == NP.TestFrame then return end
	NP:ClearStackingPlate(nameplate:GetParent())
end

function NP:ClearAllStackingPlates()
	for basePlate in pairs(NP.StackingPlates) do
		NP:ClearStackingPlate(basePlate)
	end
end

function NP:UpdateNameplateStacking()
	if not NP:IsOverlapStackingEnabled() then return end

	local cfg = GetStackingDB()
	local active = {}
	local xspace = cfg.xspace
	local yspace = cfg.yspace
	local delta = cfg.speed * 5
	local movedCount = 0
	local maxMove = 0
	local minDistanceSeen = 1000
	local activeCount = 0

	for nameplate in pairs(NP.Plates) do
		if nameplate ~= NP.TestFrame and nameplate:IsShown() and ENEMY_TYPES[nameplate.frameType] then
			local basePlate = nameplate:GetParent()
			if basePlate and basePlate:IsShown() then
				local x, y = GetPlatePosition(basePlate)
				if x and y then
					local data = NP.StackingPlates[basePlate]
					if not data then
						data = {xpos = 0, ypos = 0, position = 0}
						NP.StackingPlates[basePlate] = data
					end

					data.xpos = x
					data.ypos = y
					active[basePlate] = true
				end
			end
		end
	end

	for basePlate in pairs(NP.StackingPlates) do
		if not active[basePlate] then
			NP:ClearStackingPlate(basePlate)
		end
	end

	for basePlate, data in pairs(NP.StackingPlates) do
		activeCount = activeCount + 1
		local _, height = basePlate:GetSize()
		local minDistance = 1000
		local reset = true

		for otherPlate, otherData in pairs(NP.StackingPlates) do
			if basePlate ~= otherPlate then
				local xdiff = data.xpos - otherData.xpos
				local ydiff = data.ypos + data.position - otherData.ypos - otherData.position
				local ydiffOrigin = data.ypos - otherData.ypos - otherData.position

				if abs(xdiff) < xspace then
					if ydiff >= 0 and abs(ydiff) < minDistance then
						minDistance = abs(ydiff)
					end
					if abs(ydiffOrigin) < yspace + 2 * delta then
						reset = false
					end
				end
			end
		end

		local oldPosition = data.position
		local newPosition = oldPosition

		if oldPosition >= 2 * delta and reset then
			newPosition = oldPosition - exp(-10 / oldPosition) * delta * cfg.speedreset
		elseif minDistance < yspace then
			newPosition = oldPosition + exp(-minDistance / yspace) * delta * cfg.speedraise
		elseif oldPosition >= 2 * delta and minDistance > yspace + 2 * delta then
			newPosition = oldPosition - exp(-yspace / minDistance) * delta * 0.8 * cfg.speedlower
		end

		-- Keep stacking soft and prevent runaway separation.
		newPosition = mathMax(0, mathMin(newPosition, cfg.maxOffset))

		data.position = newPosition
		local moved = abs(newPosition - oldPosition)
		if moved > 0.05 then
			movedCount = movedCount + 1
			if moved > maxMove then
				maxMove = moved
			end
		end
		if minDistance < minDistanceSeen then
			minDistanceSeen = minDistance
		end

		basePlate:SetClampedToScreen(true)
		basePlate:SetClampRectInsets(-10, 10, cfg.upperborder, -data.ypos - newPosition - cfg.originpos + height)
	end

	NP.StackingLastStats = {
		active = activeCount,
		moved = movedCount,
		maxMove = maxMove,
		minDistance = minDistanceSeen < 1000 and minDistanceSeen or -1,
	}
end

function NP:UpdateStackingState()
	if not NP.Initialized then return end

	if NP:IsOverlapStackingEnabled() then
		if not NP.StackingFrame then
			NP.StackingFrame = CreateFrame('Frame')
		end

		local elapsed = 0
		NP.StackingFrame:SetScript('OnUpdate', function(_, dt)
			elapsed = elapsed + dt
			if elapsed < 0.03 then return end
			elapsed = 0
			NP:UpdateNameplateStacking()
		end)
	else
		if NP.StackingFrame then
			NP.StackingFrame:SetScript('OnUpdate', nil)
		end
		NP:ClearAllStackingPlates()
	end
end

function NP:StackingDiagnostic()
	NP.db = NP.db or E.db.nameplates
	local mode = NP.db and NP.db.motionType or 'nil'

	local allPlates, enemyPlates = 0, 0
	local sampleNameplate
	for nameplate in pairs(NP.Plates) do
		allPlates = allPlates + 1
		if nameplate:IsShown() and ENEMY_TYPES[nameplate.frameType] then
			enemyPlates = enemyPlates + 1
			if not sampleNameplate then
				sampleNameplate = nameplate
			end
		end
	end

	E:Print(format('[NPStack] mode=%s enabled=%s plates=%d enemy=%d',
		tostring(mode), tostring(NP:IsOverlapStackingEnabled()), allPlates, enemyPlates))

	if not sampleNameplate then
		E:Print('[NPStack] Нет активных вражеских неймплейтов для теста')
		return
	end

	local basePlate = sampleNameplate:GetParent()
	if not basePlate then
		E:Print('[NPStack] Не удалось получить базовый frame неймплейта')
		return
	end

	local managed = NP.StackingPlates[basePlate] ~= nil

	basePlate:SetClampRectInsets(-10, 10, 10, -10)
	basePlate:SetClampedToScreen(true)
	local x, y = GetPlatePosition(basePlate)

	E:Print(format('[NPStack] base=%s clamp=%s screen=%s x=%s y=%s',
		tostring(basePlate:GetName()), tostring(true), tostring(true), tostring(x), tostring(y)))

	local stats = NP.StackingLastStats
	if stats then
		E:Print(format('[NPStack] active=%d moved=%d maxMove=%.2f minDist=%.2f',
			stats.active or 0, stats.moved or 0, stats.maxMove or 0, stats.minDistance or -1))
	end

	-- Don't reset a managed StackingPlate to base; the OnUpdate loop owns its clamp
	-- and the destructive 0,0,0,0 reset would snap/flicker it until the next tick.
	if not managed then
		basePlate:SetClampRectInsets(0, 0, 0, 0)
		basePlate:SetClampedToScreen(false)
	end
end

function NP:ForceStackingPreview()
	local cfg = GetStackingDB()
	local changed = 0

	for nameplate in pairs(NP.Plates) do
		if nameplate ~= NP.TestFrame and nameplate:IsShown() and ENEMY_TYPES[nameplate.frameType] then
			local basePlate = nameplate:GetParent()
			if basePlate and basePlate:IsShown() then
				changed = changed + 1
				local _, height = basePlate:GetSize()
				local _, y = GetPlatePosition(basePlate)
				local offset = changed * 60

				basePlate:SetClampedToScreen(true)
				basePlate:SetClampRectInsets(-10, 10, cfg.upperborder, -(y or 0) - offset - cfg.originpos + height)
				NP.StackingForcedPlates[basePlate] = true
			end
		end
	end

	E:Print(format('[NPStack] Force preview applied to %d plate(s)', changed))

	if NP.StackingForceRestoreTimer then
		NP:CancelTimer(NP.StackingForceRestoreTimer)
	end
	NP.StackingForceRestoreTimer = NP:ScheduleTimer(function()
		for basePlate in pairs(NP.StackingForcedPlates) do
			NP:ClearStackingPlate(basePlate)
		end
		wipe(NP.StackingForcedPlates)
		E:Print('[NPStack] Force preview cleared')
	end, 3)
end

function NP:RegisterStackingSlash()
	if NP.StackingSlashRegistered then return end

	SLASH_ELVNPSTACK1 = '/elvnpstack'
	SlashCmdList.ELVNPSTACK = function(msg)
		msg = msg and strtrim(msg) or ''
		if msg == 'on' then
			E.db.nameplates.motionType = 'OVERLAP_STACK'
			NP:UpdateCVars()
			NP:ConfigureAll()
			E:Print('[NPStack] Режим OVERLAP_STACK включен')
		elseif msg == 'off' then
			E.db.nameplates.motionType = 'OVERLAP'
			NP:UpdateCVars()
			NP:ConfigureAll()
			E:Print('[NPStack] Режим OVERLAP_STACK выключен')
		elseif msg == 'force' then
			NP:ForceStackingPreview()
		else
			NP:StackingDiagnostic()
		end
	end

	NP.StackingSlashRegistered = true
end
