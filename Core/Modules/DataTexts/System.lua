local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local collectgarbage = collectgarbage
local tremove, tinsert, sort, wipe, type = tremove, tinsert, sort, wipe, type
local ipairs, pairs, floor, format, strmatch = ipairs, pairs, floor, format, strmatch

local GetAddOnCPUUsage = GetAddOnCPUUsage
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local GetCVar = GetCVar
local GetFramerate = GetFramerate
local GetNetStats = GetNetStats
local GetNumAddOns = GetNumAddOns
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local ReloadUI = ReloadUI
local ResetCPUUsage = ResetCPUUsage
local UpdateAddOnCPUUsage = UpdateAddOnCPUUsage
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage

local statusColors = {
	'|cff0CD809',
	'|cffE8DA0F',
	'|cffFF9000',
	'|cffD80909'
}

local enteredFrame, db = false
local homeLatencyString = '%d ms'
local kiloByteString = '%d kb'
local megaByteString = '%.2f mb'
local profilingString = '%s%s|r |cffffffff/|r %s%s|r'
local cpuProfiling = GetCVar('scriptProfile') == '1'

local CombineAddOns = {
	['DBM-Core'] = '^<DBM>',
	['DataStore'] = '^DataStore',
	['Altoholic'] = '^Altoholic',
	['AtlasLoot'] = '^AtlasLoot',
	['Details'] = '^Details!',
	['RaiderIO'] = '^RaiderIO',
	['BigWigs'] = '^BigWigs',
}

local function formatMem(memory)
	if memory >= 1024 then
		return format(megaByteString, memory / 1024)
	else
		return format(kiloByteString, memory)
	end
end

local function statusColor(fps, ping)
	if fps then
		return statusColors[fps >= 30 and 1 or (fps >= 20 and fps < 30) and 2 or (fps >= 10 and fps < 20) and 3 or 4]
	else
		return statusColors[ping < 150 and 1 or (ping >= 150 and ping < 300) and 2 or (ping >= 300 and ping < 500) and 3 or 4]
	end
end

local infoTable = {}
DT.SystemInfo = infoTable

local function BuildAddonList()
	local addOnCount = GetNumAddOns()
	if addOnCount == #infoTable then return end

	wipe(infoTable)

	for i = 1, addOnCount do
		local name, title, _, _, loadable, reason = GetAddOnInfo(i)
		if loadable then
			tinsert(infoTable, {name = name, index = i, title = title})
		end
	end
end

local function OnClick()
	local shiftDown, ctrlDown = IsShiftKeyDown(), IsControlKeyDown()
	if shiftDown and ctrlDown then
		E:SetCVar('scriptProfile', GetCVar('scriptProfile'))
		ReloadUI()
	elseif shiftDown and not ctrlDown then
		collectgarbage('collect')
		ResetCPUUsage()
	end
end

local function displayData(data, totalMEM, totalCPU)
	if not data then return end

	local name, mem, cpu = data.title, data.mem, data.cpu
	if cpu then
		local memRed, cpuRed = mem / totalMEM, cpu / totalCPU
		local memGreen, cpuGreen = (1 - memRed) + .5, (1 - cpuRed) + .5
		DT.tooltip:AddDoubleLine(name, format(profilingString, E:RGBToHex(memRed, memGreen, 0), formatMem(mem), E:RGBToHex(cpuRed, cpuGreen, 0), format(homeLatencyString, cpu)), 1, 1, 1)
	else
		local red = mem / totalMEM
		local green = (1 - red) + .5
		DT.tooltip:AddDoubleLine(name, formatMem(mem), 1, 1, 1, red or 1, green or 1, 0)
	end
end

local function displaySort(a, b)
	return a.sort > b.sort
end

local infoDisplay = {}
local function OnEnter(_, slow)
	if not db.showTooltip then return end
	local isShiftDown = IsShiftKeyDown()

	DT.tooltip:ClearLines()
	enteredFrame = true

	local fps = E.FPS
	if isShiftDown and fps.rate then
		DT.tooltip:AddDoubleLine(L["FPS Average:"], format('%d', fps.average), .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddDoubleLine(L["FPS Lowest:"], format('%d', fps.low), .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddDoubleLine(L["FPS Highest:"], format('%d', fps.high), .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddLine(' ')
	end

	local _, _, worldPing = GetNetStats()
	DT.tooltip:AddDoubleLine(L["World Latency:"], format(homeLatencyString, worldPing), .69, .31, .31, .84, .75, .65)

	if slow == 1 or not slow then
		UpdateAddOnMemoryUsage()
	end

	if cpuProfiling and not slow then
		UpdateAddOnCPUUsage()
	end

	wipe(infoDisplay)

	local count, totalMEM, totalCPU = 0, 0, 0
	local showByCPU = cpuProfiling and not isShiftDown
	for _, data in ipairs(infoTable) do
		local i = data.index
		if IsAddOnLoaded(i) then
			local mem = GetAddOnMemoryUsage(i)
			totalMEM = totalMEM + mem

			local cpu
			if cpuProfiling then
				cpu = GetAddOnCPUUsage(i)
				totalCPU = totalCPU + cpu
			end

			data.sort = (showByCPU and cpu) or mem
			data.cpu = showByCPU and cpu
			data.mem = mem

			count = count + 1
			infoDisplay[count] = data

			if data.name == 'ElvUI' or data.name == 'ElvUI_Options' or data.name == 'ElvUI_Libraries' then
				infoTable[data.name] = data
			end
		end
	end

	if isShiftDown then
		DT.tooltip:AddDoubleLine(L["AddOn Memory:"], formatMem(totalMEM), .69, .31, .31, .84, .75, .65)

		if cpuProfiling then
			DT.tooltip:AddDoubleLine(L["Total CPU:"], format(homeLatencyString, totalCPU), .69, .31, .31, .84, .75, .65)
		end
	end

	DT.tooltip:AddLine(' ')

	if not db.ShowOthers then
		displayData(infoTable.ElvUI, totalMEM, totalCPU)
		displayData(infoTable.ElvUI_Options, totalMEM, totalCPU)
		displayData(infoTable.ElvUI_Libraries, totalMEM, totalCPU)
		DT.tooltip:AddLine(' ')
	else
		for addon, searchString in pairs(CombineAddOns) do
			local addonIndex, memoryUsage, cpuUsage = 0, 0, 0
			for i, data in pairs(infoDisplay) do
				if data and data.name == addon then
					cpuUsage = data.cpu or 0
					memoryUsage = data.mem
					addonIndex = i
					break
				end
			end

			for k, data in pairs(infoDisplay) do
				if type(data) == 'table' then
					local name, mem, cpu = data.title, data.mem, data.cpu
					local stripName = E:StripString(data.title)
					if name and (strmatch(stripName, searchString) or data.name == addon) then
						if data.name ~= addon and stripName ~= addon then
							memoryUsage = memoryUsage + mem
							if showByCPU and cpuProfiling then
								cpuUsage = cpuUsage + cpu
							end

							infoDisplay[k] = false
						end
					end
				end
			end

			local data = addonIndex > 0 and infoDisplay[addonIndex]
			if data then
				local mem = memoryUsage > 0 and memoryUsage
				local cpu = cpuUsage > 0 and cpuUsage

				if mem then data.mem = mem end
				if cpu then data.cpu = cpu end
				if mem or cpu then
					data.sort = (showByCPU and cpu) or mem
				end
			end
		end

		for i = count, 1, -1 do
			local data = infoDisplay[i]
			if type(data) == 'boolean' then
				tremove(infoDisplay, i)
			end
		end

		sort(infoDisplay, displaySort)

		for i = 1, count do
			displayData(infoDisplay[i], totalMEM, totalCPU)
		end

		DT.tooltip:AddLine(' ')
		if showByCPU then
			DT.tooltip:AddLine(L["(Hold Shift) Memory Usage"])
		end
	end

	DT.tooltip:AddLine(L["(Shift Click) Collect Garbage"])
	DT.tooltip:AddLine(L["(Ctrl & Shift Click) Toggle CPU Profiling"])
	DT.tooltip:Show()
end

local function OnLeave()
	enteredFrame = false
end

local function OnEvent(self, event)
	if event == 'MODIFIER_STATE_CHANGED' then
		OnEnter(self)
	else
		local addOnCount = GetNumAddOns()
		if addOnCount == #infoTable then return end

		wipe(infoTable)

		for i = 1, addOnCount do
			local name, title, _, _, loadable, reason = GetAddOnInfo(i)
			if loadable or reason == 'DEMAND_LOADED' then
				tinsert(infoTable, {name = name, index = i, title = title})
			end
		end
	end
end

local wait, delay = 10, 0 -- initial delay for update (let the ui load)
local function OnUpdate(self, elapsed)
	if wait < 1 then
		wait = wait + elapsed
	else
		wait = 0

		local _, _, worldPing = GetNetStats()
		local fps = E.FPS.rate or 0

		self.text:SetFormattedText(db.NoLabel and '%s%d|r | %s%d|r' or 'FPS: %s%d|r MS: %s%d|r', statusColor(fps), fps, statusColor(nil, worldPing), worldPing)

		if not enteredFrame then return end

		if not enteredFrame then
			return
		elseif InCombatLockdown() then
			if delay > 3 then
				OnEnter(self)
				delay = 0
			else
				OnEnter(self, delay)
				delay = delay + 1
			end
		else
			OnEnter(self)
		end
	end
end

local function ApplySettings(self)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end
end

DT:RegisterDatatext('System', nil, 'MODIFIER_STATE_CHANGED', OnEvent, OnUpdate, OnClick, OnEnter, OnLeave, L["System"], nil, ApplySettings)
