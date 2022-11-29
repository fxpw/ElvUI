local MAJOR, MINOR = "LibDualSpec-1.0", 6
assert(LibStub, MAJOR.." requires LibStub")
local lib, minor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")

lib.registry = lib.registry or {}
lib.options = lib.options or {}
lib.mixin = lib.mixin or {}
lib.upgrades = lib.upgrades or {}
lib.currentSpec = lib.currentSpec or 0

if minor and minor < 5 then
	lib.talentsLoaded, lib.talentGroup = nil, nil
	lib.specLoaded, lib.specGroup = nil, nil
	lib.eventFrame:UnregisterAllEvents()
	wipe(lib.options)
end

local registry = lib.registry
local options = lib.options
local mixin = lib.mixin
local upgrades = lib.upgrades

local AceDB3 = LibStub('AceDB-3.0', true)
local AceDBOptions3 = LibStub('AceDBOptions-3.0', true)
local AceConfigRegistry3 = LibStub('AceConfigRegistry-3.0', true)

local L_ENABLED = "Включить профили раскладки талантов"
local L_ENABLED_DESC = "Если включено, ваш профиль будет зависеть от выбранной раскладки талантов."
local L_CURRENT = "%s (Текущий)"

local idToString = {
	[1] = "Первый профиль",
	[2] = "Второй профиль",
	[3] = "Третий профиль",
	[4] = "Четверный профиль",
	[5] = "Пятый профиль",
	[6] = "Шестой профиль",
	[7] = "Седьмой профиль",
	[8] = "Восьмой профиль",
	[9] = "Девятый профиль",
	[10] = "Десятый профиль",
}

function mixin:IsDualSpecEnabled()
	return registry[self].db.char.enabled
end

function mixin:SetDualSpecEnabled(enabled)
	local db = registry[self].db.char
	db.enabled = not not enabled

	local currentProfile = self:GetCurrentProfile()
	for i = 1, C_Talent.GetNumTalentGroups() do
		db[i] = enabled and (db[i] or currentProfile) or nil
	end

	self:CheckDualSpecState()
end

function mixin:GetDualSpecProfile(talent)
	return registry[self].db.char[talent or lib.currentSpec] or self:GetCurrentProfile()
end

function mixin:SetDualSpecProfile(profileName, talent)
	talent = talent or lib.currentSpec
	if talent > C_Talent.GetNumTalentGroups() then return end

	registry[self].db.char[talent] = profileName
	self:CheckDualSpecState()
end

function mixin:CheckDualSpecState()
	if not registry[self].db.char.enabled then return end
	if lib.currentSpec == 0 then return end

	local profileName = self:GetDualSpecProfile()
	if profileName ~= self:GetCurrentProfile() then
		self:SetProfile(profileName)
	end
end

local function EmbedMixin(target)
	for k,v in next, mixin do
		rawset(target, k, v)
	end
end

local function UpgradeDatabase(target)
	if lib.currentSpec == 0 then
		upgrades[target] = true
		return
	end

	local db = target:GetNamespace(MAJOR, true)
	if db and db.char.profile then
		for i = 1, C_Talent.GetNumTalentGroups() do
			if i == lib.currentSpec then
				db.char[i] = target:GetCurrentProfile()
			else
				db.char[i] = db.char.profile
			end
		end
		db.char.profile = nil
		db.char.specGroup = nil
	end
end

function lib:OnProfileDeleted(event, target, profileName)
	local db = registry[target].db.char
	if not db.enabled then return end

	for i = 1, C_Talent.GetNumTalentGroups() do
		if db[i] == profileName then
			db[i] = target:GetCurrentProfile()
		end
	end
end

function lib:_EnhanceDatabase(event, target)
	registry[target].db = target:GetNamespace(MAJOR, true) or target:RegisterNamespace(MAJOR)
	EmbedMixin(target)
	target:CheckDualSpecState()
end

function lib:EnhanceDatabase(target, name)
	AceDB3 = AceDB3 or LibStub('AceDB-3.0', true)
	if type(target) ~= "table" then
		error("Usage: LibDualSpec:EnhanceDatabase(target, name): target should be a table.", 2)
	elseif type(name) ~= "string" then
		error("Usage: LibDualSpec:EnhanceDatabase(target, name): name should be a string.", 2)
	elseif not AceDB3 or not AceDB3.db_registry[target] then
		error("Usage: LibDualSpec:EnhanceDatabase(target, name): target should be an AceDB-3.0 database.", 2)
	elseif target.parent then
		error("Usage: LibDualSpec:EnhanceDatabase(target, name): cannot enhance a namespace.", 2)
	elseif registry[target] then
		return
	end
	registry[target] = { name = name }
	UpgradeDatabase(target)
	lib:_EnhanceDatabase("EnhanceDatabase", target)
	target.RegisterCallback(lib, "OnDatabaseReset", "_EnhanceDatabase")
	target.RegisterCallback(lib, "OnProfileDeleted")
end

options.new = {
	name = "New",
	type = "input",
	order = 30,
	get = false,
	set = function(info, value)
		local db = info.handler.db
		if db:IsDualSpecEnabled() then
			db:SetDualSpecProfile(value, lib.currentSpec)
		else
			db:SetProfile(value)
		end
	end,
}

options.choose = {
	name = "Existing Profiles",
	type = "select",
	order = 40,
	get = "GetCurrentProfile",
	set = "SetProfile",
	values = "ListProfiles",
	arg = "common",
	disabled = function(info)
		return info.handler.db:IsDualSpecEnabled()
	end
}

options.enabled = {
	name = "|cffffd200"..L_ENABLED.."|r",
	desc = L_ENABLED_DESC,
	descStyle = "inline",
	type = "toggle",
	order = 41,
	width = "full",
	get = function(info) return info.handler.db:IsDualSpecEnabled() end,
	set = function(info, value) info.handler.db:SetDualSpecEnabled(value) end,
}

function lib:EnhanceOptions(optionTable, target)
	AceDBOptions3 = AceDBOptions3 or LibStub('AceDBOptions-3.0', true)
	AceConfigRegistry3 = AceConfigRegistry3 or LibStub('AceConfigRegistry-3.0', true)
	if type(optionTable) ~= "table" then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): optionTable should be a table.", 2)
	elseif type(target) ~= "table" then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): target should be a table.", 2)
	elseif not AceDBOptions3 or not AceDBOptions3.optionTables[target] then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): optionTable is not an AceDBOptions-3.0 table.", 2)
	elseif optionTable.handler.db ~= target then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): optionTable must be the option table of target.", 2)
	elseif not registry[target] then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): EnhanceDatabase should be called before EnhanceOptions(optionTable, target).", 2)
	end

	options.new.name = optionTable.args.new.name
	options.new.desc = optionTable.args.new.desc
	options.choose.name = optionTable.args.choose.name
	options.choose.desc = optionTable.args.choose.desc

	if not optionTable.plugins then
		optionTable.plugins = {}
	end
	optionTable.plugins[MAJOR] = options
end

for target in next, registry do
	UpgradeDatabase(target)
	EmbedMixin(target)
	target:CheckDualSpecState()
	local optionTable = AceDBOptions3 and AceDBOptions3.optionTables[target]
	if optionTable then
		lib:EnhanceOptions(optionTable, target)
	end
end

local function iterator(registry, key)
	local data
	key, data = next(registry, key)
	if key then
		return key, data.name
	end
end

function lib:IterateDatabases()
	return iterator, lib.registry
end

local function eventHandler(self, event)
	lib.currentSpec = C_Talent.GetActiveTalentGroup()

	if event == "PLAYER_LOGIN" then
		self:UnregisterEvent(event)
		self:RegisterEvent("PLAYER_TALENT_UPDATE")
	end

	for i = 1, C_Talent.GetNumTalentGroups() do
		if not options["specProfile" .. i] then
			options["specProfile" .. i] = {
				type = "select",
				name = function() return lib.currentSpec == i and L_CURRENT:format(idToString[i]) or idToString[i] end,
				order = 42 + i,
				get = function(info) return info.handler.db:GetDualSpecProfile(i) end,
				set = function(info, value) info.handler.db:SetDualSpecProfile(value, i) end,
				values = "ListProfiles",
				arg = "common",
				disabled = function(info) return not info.handler.db:IsDualSpecEnabled() end,
			}
		end
	end

	if lib.currentSpec > 0 and next(upgrades) then
		for target in next, upgrades do
			UpgradeDatabase(target)
		end
		wipe(upgrades)
	end

	for target in next, registry do
		target:CheckDualSpecState()
	end

	if AceConfigRegistry3 and next(registry) then
		for appName in AceConfigRegistry3:IterateOptionsTables() do
			AceConfigRegistry3:NotifyChange(appName)
		end
	end
end

lib.eventFrame:SetScript("OnEvent", eventHandler)
if IsLoggedIn() then
	eventHandler(lib.eventFrame, "PLAYER_LOGIN")
else
	lib.eventFrame:RegisterEvent("PLAYER_LOGIN")
end