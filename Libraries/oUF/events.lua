local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local validateEvent = Private.validateEvent
local validateEventUnit = Private.validateEventUnit
local isUnitEvent = Private.isUnitEvent
local frame_metatable = Private.frame_metatable

-- Original event methods
local registerEvent = frame_metatable.__index.RegisterEvent
local registerUnitEvent = frame_metatable.__index.RegisterUnitEvent
local unregisterEvent = frame_metatable.__index.UnregisterEvent
local unregisterUnitEvent = frame_metatable.__index.UnregisterUnitEvent
local isEventRegistered = frame_metatable.__index.IsEventRegistered
local resolveFrameUnit = Private.resolveFrameUnit

-- to update unit frames correctly, some events need to be registered for
-- a specific combination of primary and secondary units
local secondaryUnits = {
	UNIT_ENTERED_VEHICLE = {
		pet = 'player',
	},
	UNIT_EXITED_VEHICLE = {
		pet = 'player',
	},
	UNIT_PET = {
		pet = 'player',
	},
}

local function unregisterUnitEventSafe(frame, event, unit1, unit2)
	if unregisterUnitEvent and unit1 then
		if unit2 and unit2 ~= '' then
			unregisterUnitEvent(frame, event, unit1, unit2)
		else
			unregisterUnitEvent(frame, event, unit1)
		end
	end

	unregisterEvent(frame, event)
end

local function registerUnitEventSafe(frame, event, unit1, unit2)
	if registerUnitEvent and unit1 and Private.isUnitEvent(event, unit1) then
		local prevUnit1, prevUnit2

		if frame._registeredUnitEvents and frame._registeredUnitEvents[event] then
			prevUnit1, prevUnit2 = frame._registeredUnitEvents[event][1], frame._registeredUnitEvents[event][2]
		elseif isEventRegistered then
			local registered, regUnit1, regUnit2 = isEventRegistered(frame, event)
			if registered and regUnit1 then
				prevUnit1, prevUnit2 = regUnit1, regUnit2
			end
		end

		if prevUnit1 and (prevUnit1 ~= unit1 or (prevUnit2 or '') ~= (unit2 or '')) then
			unregisterUnitEventSafe(frame, event, prevUnit1, prevUnit2)
		else
			unregisterEvent(frame, event)
		end

		if unit2 and unit2 ~= '' then
			registerUnitEvent(frame, event, unit1, unit2)
		else
			registerUnitEvent(frame, event, unit1)
		end

		frame._registeredUnitEvents = frame._registeredUnitEvents or {}
		frame._registeredUnitEvents[event] = {unit1, unit2 and unit2 ~= '' and unit2 or nil}
	else
		if frame._registeredUnitEvents and frame._registeredUnitEvents[event] then
			local prevUnit1, prevUnit2 = frame._registeredUnitEvents[event][1], frame._registeredUnitEvents[event][2]
			unregisterUnitEventSafe(frame, event, prevUnit1, prevUnit2)
			frame._registeredUnitEvents[event] = nil
		else
			unregisterEvent(frame, event)
		end

		registerEvent(frame, event)
	end
end

local function registerFrameUnitEvents(frame, unit, realUnit)
	if(not frame.unitEvents or not unit or not validateEventUnit(unit)) then return end

	local resetRealUnit = false

	for event in next, frame.unitEvents do
		local regRealUnit = realUnit
		if(not regRealUnit and secondaryUnits[event]) then
			regRealUnit = secondaryUnits[event][unit]
			resetRealUnit = true
		end

		local registered, unit1, unit2
		if frame._registeredUnitEvents and frame._registeredUnitEvents[event] then
			registered = true
			unit1, unit2 = frame._registeredUnitEvents[event][1], frame._registeredUnitEvents[event][2]
		elseif isEventRegistered then
			registered, unit1, unit2 = isEventRegistered(frame, event)
		end

		if(not registered or unit1 ~= unit or (unit2 or '') ~= (regRealUnit or '')) then
			registerUnitEventSafe(frame, event, unit, regRealUnit or '')
		end

		if(resetRealUnit) then
			regRealUnit = nil
			resetRealUnit = false
		end
	end
end

Private.RegisterFrameUnitEvents = registerFrameUnitEvents

function Private.UpdateUnits(frame, unit, realUnit)
	if(unit == realUnit) then
		realUnit = nil
	end

	registerFrameUnitEvents(frame, unit, realUnit)

	if(frame.unit ~= unit or frame.realUnit ~= realUnit) then
		frame.unit = unit
		frame.realUnit = realUnit
		frame.id = unit and unit:match('^.-(%d+)')

		return true
	end
end

local function onEvent(self, event, ...)
	if(not (self:IsVisible() or event == 'UNIT_COMBO_POINTS')) then return end

	local handler = self[event]
	if not handler then return end

	local unit = ...
	if self.unitEvents and self.unitEvents[event] and (not unit or type(unit) ~= 'string') then
		return handler(self, event, self.unit, select(2, ...))
	end

	return handler(self, event, ...)
end

local event_metatable = {
	__call = function(funcs, self, ...)
		for _, func in next, funcs do
			func(self, ...)
		end
	end,
}

--[[ Events: frame:RegisterEvent(event, func, unitless)
Used to register a frame for a game event and add an event handler. OnUpdate polled frames are prevented from
registering events.

* self     - frame that will be registered for the given event.
* event    - name of the event to register (string)
* func     - function that will be executed when the event fires. If a string is passed, then a function by that name
             must be defined on the frame. Multiple functions can be added for the same frame and event
             (string or function)
* unitless - indicates that the event does not fire for a specific unit, so the event arguments won't be
             matched to the frame unit(s). Events that do not start with UNIT_ or are not known to be unit events are
             automatically considered unitless (boolean)
--]]
function frame_metatable.__index:RegisterEvent(event, func, unitless)
	-- Block OnUpdate polled frames from registering events.
	-- UNIT_PORTRAIT_UPDATE and UNIT_MODEL_CHANGED which are used for
	-- portrait updates.
	if(self.__eventless and event ~= 'UNIT_PORTRAIT_UPDATE' and event ~= 'UNIT_MODEL_CHANGED') then return end

	argcheck(event, 2, 'string')
	argcheck(func, 3, 'function')

	local curev = self[event]
	local kind = type(curev)
	if(curev) then
		if(kind == 'function' and curev ~= func) then
			self[event] = setmetatable({curev, func}, event_metatable)
		elseif(kind == 'table') then
			for _, infunc in next, curev do
				if(infunc == func) then return end
			end

			table.insert(curev, func)
		end

		if(unitless or self.__eventless) then
			registerEvent(self, event)

			if(self.unitEvents) then
				self.unitEvents[event] = nil
			end
		end
	elseif(not validateEvent or validateEvent(event)) then
		self[event] = func

		if(not self:GetScript('OnEvent')) then
			self:SetScript('OnEvent', onEvent)
		end

		if(unitless or self.__eventless) then
			registerEvent(self, event)
		else
			self.unitEvents = self.unitEvents or {}
			self.unitEvents[event] = true

			local unit1 = resolveFrameUnit(self, self.unit) or self.unit
			local unit2 = self.realUnit
			if(unit1 and validateEventUnit(unit1)) then
				if(secondaryUnits[event]) then
					unit2 = secondaryUnits[event][unit1]
				end

				registerUnitEventSafe(self, event, unit1, unit2 or '')
			else
				registerEvent(self, event)
			end
		end
	end
end

--[[ Events: frame:UnregisterEvent(event, func)
Used to remove a function from the event handler list for a game event.

* self  - the frame registered for the event
* event - name of the registered event (string)
* func  - function to be removed from the list of event handlers. If this is the only handler for the given event, then
          the frame will be unregistered for the event (function)
--]]
function frame_metatable.__index:UnregisterEvent(event, func)
	argcheck(event, 2, 'string')

	local cleanUp = false
	local curev = self[event]
	if(type(curev) == 'table' and func) then
		for k, infunc in next, curev do
			if(infunc == func) then
				curev[k] = nil

				break
			end
		end

		if(not next(curev)) then
			cleanUp = true
		end
	end

	if(cleanUp or curev == func) then
		self[event] = nil
		if(self.unitEvents) then
			self.unitEvents[event] = nil
		end
		if(self._registeredUnitEvents) then
			local registered = self._registeredUnitEvents[event]
			if registered then
				unregisterUnitEventSafe(self, event, registered[1], registered[2])
				self._registeredUnitEvents[event] = nil
			else
				unregisterEvent(self, event)
			end
		else
			unregisterEvent(self, event)
		end
	end
end

if not frame_metatable.__index.IsEventRegistered then
	function frame_metatable.__index:IsEventRegistered(event)
		if isEventRegistered then
			return isEventRegistered(self, event)
		end
	end
end
