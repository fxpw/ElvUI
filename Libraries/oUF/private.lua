local parent, ns = ...
local Private = ns.oUF.Private

function Private.argcheck(value, num, ...)
	assert(type(num) == 'number', "Bad argument #2 to 'argcheck' (number expected, got " .. type(num) .. ')')

	for i = 1, select('#', ...) do
		if(type(value) == select(i, ...)) then return end
	end

	local types = strjoin(', ', ...)
	local name = debugstack(2,2,0):match(": in function [`<](.-)['>]")
	error(string.format("Bad argument #%d to '%s' (%s expected, got %s)", num, name, types, type(value)), 3)
end

function Private.print(...)
	print('|cff33ff99oUF:|r', ...)
end

function Private.error(...)
	Private.print('|cffff0000Error:|r ' .. string.format(...))
end

function Private.unitExists(unit)
	return unit and UnitExists(unit)
end

local invalidUnitTokens = {
	party = true,
	raid = true,
	maintank = true,
	mainassist = true,
}

function Private.resolveFrameUnit(object, fallbackUnit)
	if not object then return end

	local attributeUnit = object:GetAttribute('unit')
	if type(attributeUnit) == 'string' and attributeUnit ~= '' then
		return attributeUnit
	end

	if SecureButton_GetModifiedUnit then
		local modUnit = SecureButton_GetModifiedUnit(object)
		if modUnit == 'playerpet' then
			modUnit = 'pet'
		elseif modUnit == 'playertarget' then
			modUnit = 'target'
		end

		if modUnit and UnitExists(modUnit) then
			return modUnit
		end
	end

	if SecureButton_GetUnit then
		local realUnit = SecureButton_GetUnit(object)
		if realUnit == 'playerpet' then
			realUnit = 'pet'
		elseif realUnit == 'playertarget' then
			realUnit = 'target'
		end

		if realUnit and UnitExists(realUnit) then
			return realUnit
		end
	end

	if not fallbackUnit or invalidUnitTokens[fallbackUnit] then
		return
	end

	if fallbackUnit == 'party5' then
		return 'player'
	end

	return fallbackUnit
end

function Private.unitMatches(frameUnit, eventUnit)
	if not frameUnit then return false end
	if not eventUnit then return true end

	return UnitIsUnit(eventUnit, frameUnit)
end

local validator = CreateFrame('Frame')

function Private.validateEventUnit(unit)
	if not unit or not validator.RegisterUnitEvent then return end

	local isOK = pcall(validator.RegisterUnitEvent, validator, 'UNIT_HEALTH', unit)
	if isOK then
		validator:UnregisterEvent('UNIT_HEALTH')
		return true
	end
end

function Private.validateEvent(event)
	local isOK = pcall(validator.RegisterEvent, validator, event)
	if isOK then
		validator:UnregisterEvent(event)
	end

	return isOK
end

function Private.isUnitEvent(event, unit)
	if not unit or not validator.RegisterUnitEvent then return false end

	local isOK = pcall(validator.RegisterUnitEvent, validator, event, unit)
	if isOK then
		validator:UnregisterEvent(event)
	end

	return isOK
end
