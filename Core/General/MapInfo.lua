local E, L, V, P, G = unpack(ElvUI)

local pairs = pairs
local IsFalling = IsFalling
local CreateFrame = CreateFrame
local GetUnitSpeed = GetUnitSpeed
local GetRealZoneText = GetRealZoneText
local GetMinimapZoneText = GetMinimapZoneText
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetMapInfo = GetMapInfo
local GetMapZones = GetMapZones
local GetZoneText = GetZoneText


local MapInfo = {}
E.MapInfo = MapInfo

function E:MapInfo_Update()
	local mapID = GetCurrentMapAreaID()

	local mapInfo = mapID and GetMapZones(mapID)
	MapInfo.name = (mapInfo and mapInfo.name) or GetZoneText() or GetMapInfo() or nil
	MapInfo.mapType = (mapInfo and mapInfo.mapType) or nil
	MapInfo.parentMapID = (mapInfo and mapInfo.parentMapID) or nil

	MapInfo.mapID = mapID or nil
	MapInfo.zoneText = (mapID and E:GetZoneText(mapID)) or nil
	MapInfo.subZoneText = GetMinimapZoneText() or nil
	MapInfo.realZoneText = GetRealZoneText() or nil

	E:MapInfo_CoordsUpdate()
end

local coordsWatcher = CreateFrame('Frame')
function E:MapInfo_CoordsStart()
	MapInfo.coordsWatching = true
	MapInfo.coordsFalling = nil

	coordsWatcher:SetScript('OnUpdate', E.MapInfo_OnUpdate)

	if MapInfo.coordsStopTimer then
		E:CancelTimer(MapInfo.coordsStopTimer)
		MapInfo.coordsStopTimer = nil
	end
end

function E:MapInfo_CoordsStopWatching()
	MapInfo.coordsWatching = nil
	MapInfo.coordsStopTimer = nil
	coordsWatcher:SetScript('OnUpdate', nil)
end

function E:MapInfo_CoordsStop(event)
	if event == 'CRITERIA_UPDATE' then
		if not MapInfo.coordsFalling then return end -- stop if we weren't falling
		if (GetUnitSpeed('player') or 0) > 0 then return end -- we are still moving!
		MapInfo.coordsFalling = nil -- we were falling!
	elseif (GetUnitSpeed('player') or 0) == 0 and IsFalling() then
		MapInfo.coordsFalling = true
		return
	end

	if not MapInfo.coordsStopTimer then
		MapInfo.coordsStopTimer = E:ScheduleTimer('MapInfo_CoordsStopWatching', 0.5)
	end
end

function E:MapInfo_CoordsUpdate()
	if MapInfo.mapID then
		MapInfo.x, MapInfo.y = E:GetPlayerMapPos()
	else
		MapInfo.x, MapInfo.y = nil, nil
	end

	if MapInfo.x and MapInfo.y then
		MapInfo.xText = E:Round(100 * MapInfo.x, 2)
		MapInfo.yText = E:Round(100 * MapInfo.y, 2)
	else
		MapInfo.xText, MapInfo.yText = nil, nil
	end
end

function E:MapInfo_OnUpdate(elapsed)
	if GetUnitSpeed('player') == 0 then return end
	self.lastUpdate = (self.lastUpdate or 0) + elapsed
	if self.lastUpdate > 0.1 then
		E:MapInfo_CoordsUpdate()
		self.lastUpdate = 0
	end
end

local x, y = 0, 0
function E:GetPlayerMapPos()
	x, y = GetPlayerMapPosition('player')
	if not x then return end

	return x, y
end

-- Code taken from LibTourist-3.0 and rewritten to fit our purpose
local localizedMapNames = {}
local ZoneIDToContinentName = {
	[104] = 'Outland',
	[107] = 'Outland',
}
local MapIdLookupTable = {
	[101] = 'Outland',
	[104] = 'Shadowmoon Valley',
	[107] = 'Nagrand',
}
local function LocalizeZoneNames()
	local mapInfo
	for mapID, englishName in pairs(MapIdLookupTable) do
		mapInfo = GetMapZones(mapID)
		-- Add combination of English and localized name to lookup table
		if mapInfo and mapInfo.name and not localizedMapNames[englishName] then
			localizedMapNames[englishName] = mapInfo.name
		end
	end
end
LocalizeZoneNames()

--Add ' (Outland)' to the end of zone name for Nagrand and Shadowmoon Valley, if mapID matches Outland continent.
--We can then use this function when we need to compare the players own zone against return values from stuff like GetFriendInfo and GetGuildRosterInfo,
--which adds the ' (Outland)' part unlike the GetRealZoneText() API.
function E:GetZoneText(mapID)
	if not (mapID and MapInfo.name) then return end

	local continent, zoneName = ZoneIDToContinentName[mapID]
	if continent and continent == 'Outland' then
		if MapInfo.name == localizedMapNames.Nagrand or MapInfo.name == 'Nagrand' then
			zoneName = localizedMapNames.Nagrand..' ('..localizedMapNames.Outland..')'
		elseif MapInfo.name == localizedMapNames['Shadowmoon Valley'] or MapInfo.name == 'Shadowmoon Valley' then
			zoneName = localizedMapNames['Shadowmoon Valley']..' ('..localizedMapNames.Outland..')'
		end
	end

	return zoneName or MapInfo.name
end

local function toggleCoordsStartStop()
	if GetUnitSpeed('player') > 0 then
		E:MapInfo_CoordsStart()
	else
		E:MapInfo_CoordsStop()
	end
end

E:ScheduleRepeatingTimer(toggleCoordsStartStop, 0.5)

E:RegisterEvent('CRITERIA_UPDATE', 'MapInfo_CoordsStop') -- when the player goes into an animation (landing)
E:RegisterEventForObject('PLAYER_LOGIN', E.MapInfo, E.MapInfo_Update)
E:RegisterEventForObject('ZONE_CHANGED_NEW_AREA', E.MapInfo, E.MapInfo_Update)
E:RegisterEventForObject('ZONE_CHANGED_INDOORS', E.MapInfo, E.MapInfo_Update)
E:RegisterEventForObject('ZONE_CHANGED', E.MapInfo, E.MapInfo_Update)
