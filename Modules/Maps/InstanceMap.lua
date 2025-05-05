local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local IM = E:GetModule("InstanceMap")


--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

local ICON_COORDS_DUNGEON = { 0, 0.242, 0, 0.242 }
local ICON_COORDS_RAID = { 0.242, 0.484, 0, 0.242 }
local ICON_COORDS_DUNGEON_HIGHLIGHTED = { 0, 0.242, 0.242, 0.484 }
local ICON_COORDS_RAID_HIGHLIGHTED = { 0.242, 0.484, 0.242, 0.484 }

local ICON_COORDS_HUB = ICON_COORDS_DUNGEON
-- local ICON_COORDS_HUB_HIGHLIGHTED = ICON_COORDS_DUNGEON_HIGHLIGHTED

local PinFrames = {}
local MapTooltip = nil
-- local DungeonTable = {}

local Debug = false

local IMIcons = "Interface\\AddOns\\ElvUI\\Media\\Textures\\IMIcons"
local IMDunge = "Interface\\AddOns\\ElvUI\\Media\\Textures\\IMDungeon"
local IMRaid = "Interface\\AddOns\\ElvUI\\Media\\Textures\\IMRaid"



IM.PinDB = {

	[14] = { --[[ KALIMDOR ]] --
		{ 58.91, 85.31, { 734, 733, 521, 775 }, "Пещеры времени" }, -- caverns of time
		-- {53.43, 36.49, {800}}, --firelands
		-- {50.49, 94.50, {747}}, --lost city tol'vir
		-- {51.26, 92.58, {759}}, --halls of origination
		-- {52.66, 96.61, {769}}, --vortex pinnacle
		-- {45.51, 97.37, {773}}, --throne four winds

		{ 57, 71.14, { 718 } }, --onyxia

		{ 41.81, 84.35, { 881, 893 }, "Ан'Кираж" }, -- ruins of ahnqiraj and temple of ahnqiraj
		-- {40.28, 83.97, {893}}, -- temple of ahnqiraj

		{ 54.19, 79.95, { 871 } }, -- zul'farrak


		{ 58.53, 45.10, { 680 } }, -- ragefire chasm
		{ 51.64, 52.95, { 749 } }, -- wailing caverns
		{ 43.98, 36.29, { 688 } }, -- blackfathom deeps
		{ 39.13, 57.55, { 750 } }, -- maraudon
		{ 51.13, 69.61, { 761 } }, -- razorfen kraul
		{ 53.3, 72.48, { 760 } }, -- razorfen downs
		{ 41.94, 66.74, { 699 } }, -- diremaul

	},

	[15] = { --[[ EASTERN KINGDOMS ]] --
		{ 50.87, 36.87, { 898 } }, --scholomance
		{ 46.15, 31.12, { 890, 941, 939, 940 }, "Монастырь Алого ордена" }, --scarlet monastery
		{ 54.45, 79.37, { 687 } }, -- sunken temple
		{ 53.17, 30.36, { 765 } }, -- stratholme
		{ 52.73, 65.19, { 692 } }, -- uldaman
		{ 40.92, 41.66, { 764 } }, -- shadowfang keep
		{ 43.21, 60.42, { 691 } }, -- gnomeregan
		{ 41.3, 82.63, { 756 } }, -- deadmines
		{ 43.3, 73.9, { 690 } }, -- stockade

		{ 46.79, 69.61, { 704, 721, 995, 755, 696 }, "Черная гора" }, --blackrock mountain
		{ 54.3, 31.3, { 537 } }, -- Naxxramas
		{ 47.94, 84.93, { 793 } }, --zul'gurub

		{ 57.26, 25, { 866 } }, --zul'aman
		{ 49.85, 81.29, { 867 } }, -- karazhan
		{ 54.7, 4.51, { 846 } }, -- sunwell plateau
		{ 56.23, 3.17, { 798 } }, -- magisters terrace
		{ 45.59, 80.52, { 5 } }
		-- {31.85, 61.76, {767}}, --throne of the tides
		-- {53.81, 55.44, {757}}, --grim batol
		-- {55.6, 59.46, {758}}, --bastion of twilight
		-- {35, 51.61, {752}}, --baradin hold
	},

	[322] = { --[[ Orgrimmar ]] --
		{ 50.8, 49.9, { 680 } }, -- ragefire chasm
	},

	[5] = { --[[ Durotar ]] --
		{ 45.77, 8.34, { 680 } }, -- ragefire chasm
	},

	[12] = { --[[ Barrens ]] --
		{ 46.0, 36.0, { 749 } }, -- wailing caverns
		{ 43,   90,   { 761 } }, -- razorfen kraul
		{ 50,   92,   { 760 } }, -- razorfen downs
	},

	[44] = { --[[ Ashenvale ]] --
		{ 13.86, 13.70, { 688 } }, -- blackfathom deeps
	},

	[102] = { --[[ Desolace ]] --
		{ 30.1, 61.9, { 750 } }, -- maraudon
	},

	-- [607]={ --[[ Southern Barrens ]]--
	-- 	{43,90, {761}}, -- razorfen kraul
	-- },

	[62] = { --[[ Thousand Needles ]] --
		{ 49.3, 26.4, { 760 } },   -- razorfen downs
	},

	[122] = { --[[ Feralas ]] --
		{ 59, 39, { 699 } }, -- diremaul
	},

	[39] = { --[[ swamp of sorrows ]] --
		{ 69.64, 53.91, { 687 } }, -- sunken temple
	},

	[24] = { --[[ eastern plaguelands ]] --
		{ 26.88, 11.6,  { 765 } },    -- stratholme
		{ 43.21, 18.30, { 765 } },    -- stratholme service entrance
		{ 39.2,  21.1,  { 537 } },    -- Naxxramas
	},

	[18] = { --[[ Badlands ]] --
		{ 42.7, 15.1, { 692 } }, -- uldaman
		{ 65.9, 43.5, { 692 } }, -- uldaman
	},

	[22] = { --[[ Silverpine Forest ]] --
		{ 44.87, 67.31, { 764 } },  -- shadowfang keep
	},

	[28] = { --[[ Dun Morogh ]] --
		{ 24.4, 39.9, { 691 } }, -- gnomeregan
	},
	[35] = {                 -- darkforest
		{ 47.13, 36.79, { 5 } }


	},

	-- [895]={ --[[ New Tinkertown ]]--
	-- 	{32.11, 35.53, {691}}, -- gnomeregan
	-- },

	[40] = { --[[ Westfall ]] --
		{ 44.36, 73.44, { 756 } }, -- deadmines
	},

	[31] = { --[[ Elwynn Forest ]] --
		{ 18.32, 29.21, { 690 } }, -- stockade
	},

	[302] = { --[[ Stormwind ]] --
		{ 51, 68.1, { 690 } }, -- stockade
	},

	[23] = { --[[ Western Plaguelands ]] --
		{ 69.20, 75.40, { 898 } },    --scholomance
	},

	[21] = { --[[ Tirisfall Glades ]] --
		{ 84.3, 33.2, { 890, 941, 939, 940 }, "Монастырь Алого ордена" }, --scarlet monastery
	},

	[29] = { --[[ Searing Gorge ]] --
		{ 35.40, 87.30, { 704, 721, 995, 755, 696 }, "Черная гора" }, --blackrock mountain
	},

	[30] = { --[[ Burning Steppes ]] --
		{ 29.3, 39.9, { 704, 721, 995, 755, 696 }, "Черная гора" }, --blackrock mountain
	},

	[162] = { --[[ Tanaris ]] --
		{ 39.39, 20.98, { 871 } }, -- zul'farrak
		{ 68.20, 49.4, { 734, 733, 521, 775 }, "Пещеры времени" }, -- caverns of time
	},

	[33] = { --[[ Deadwind Pass ]] --
		{ 45.13, 75.16, { 867 } }, -- karazhan
	},

	[262] = { --[[ Silithus ]] --
		{ 30.0, 98.0, { 881 } }, -- ruins of ahnqiraj
		{ 24.9, 97.0, { 893 } }, -- temple of ahnqiraj
	},

	[467] = { --[[ OUTLAND ]] --
		{ 55.72, 53.33, { 797, 835, 710, 865 }, "Цитадель Адского Пламени" }, -- hellfire ramparts, blood furnace, shattered halls, magtheridons lair
		{ 34.54, 44.91, { 838, 836, 727, 862 }, "Резервуар кривого клыка" }, --slave pens, underbog, steamvault, serpentshrine cavern
		{ 72.83, 81.48, { 847 } }, -- black temple
		{ 43.85, 19.45, { 864 } }, -- gruuls lair
		{ 44.62, 78.80, { 722 } }, -- auchenai crypts
		{ 47.17, 79.37, { 833 } }, -- sethekk halls
		{ 45.90, 80.52, { 834 } }, -- shadow labyrinth
		{ 46.15, 77.84, { 842 } }, -- mana tombs
		{ 69.64, 25.57, { 840 } }, -- the mechanar
		{ 69.51, 22.32, { 841 } }, -- the arcatraz
		{ 67.21, 23.08, { 839 } }, -- the botanica
		{ 68.23, 24.23, { 861 } }, -- the eye
	},

	[466] = { --[[ Hellfire Penninsula ]] --
		{ 46.79, 51.80, { 797, 835, 710, 865 }, "Цитадель Адского Пламени" }, -- hellfire ramparts, blood furnace, shattered halls, magtheridons lair
	},

	[468] = { --[[ Zangarmarsh ]] --
		{ 49.98, 40.70, { 838, 836, 727, 862 }, "Резервуар кривого клыка" }, --slave pens, underbog, steamvault, serpentshrine cavern
	},

	[474] = { --[[ Shadowmoon Valley ]] --
		{ 72.19, 44.91, { 847 } },   -- black temple
	},

	[476] = { --[[ Blade's Edge Mountains ]] --
		{ 68.3, 23.4, { 864 } },          -- gruuls lair
	},

	[479] = { --[[ Terokkar Forest ]] --
		{ 37,   65.8, { 722 } },   -- auchenai crypts
		{ 41.9, 65.8, { 833 } },   -- sethekk halls
		{ 39.7, 68.5, { 834 } },   -- shadow labyrinth
		{ 39.6, 62.7, { 842 } },   -- mana tombs
	},

	[480] = { --[[ Netherstorm ]] --
		{ 84.1,  70.6,  { 840 } }, -- the mechanar
		{ 82.3,  59.6,  { 841 } }, -- the arcatraz
		{ 72.6,  60,    { 839 } }, -- the botanica
		{ 76.53, 64.44, { 861 } }, -- the eye
	},

	[500] = { --[[ Quel'danas ]] --
		{ 43.98, 46.25, { 846 } }, -- sunwell plateau
		{ 60.7,  30.55, { 798 } }, -- magisters terrace
	},


	[486] = { --[[ NORTHREND ]] --
		{ 64.15, 55.44, { 534 } }, --draktharon keep
		{ 77.55, 30.74, { 530 } }, --gundrak
		{ 11.94, 57.16, { 520, 528, 527 }, "Нексус" }, --nexus, oculus, eye of eternity
		{ 41, 57.74, { 533, 522 }, "Азжол-Неруб" }, -- azjol-nerub,ahnkahet
		{ 58.53, 53.33, { 535 } }, --naxxramas
		{ 50.36, 55.44, { 531, 609, 924 }, "Храм Драконьего Покоя" }, --wymrest temple
		{ 80.36, 77.27, { 523 } }, --utgarde keep
		{ 80.49, 74, { 524 } }, --utgarde pinnacle

		{ 36.32, 37.63, { 601, 602, 603 }, "Цитадель Ледяной Короны" }, --forge of souls, pit of saron, halls of reflection
		-- {45, 18.3, {542}}, --trial of champion
		{ 46.79, 19.64, { 543 } }, --trial of crusader
		{ 38.24, 36.10, { 604 } }, --ICC
		{ 56.75, 12.74, { 525 } }, --halls of lightning
		{ 60.83, 12.94, { 526 } }, --halls of stone
		{ 58.79, 14.28, { 529 } }, --ulduar
		{ 37.5, 44.29, { 532 } }, --vault of archavon
		{ 48.96, 40.12, { 536 } }, --violet hold
	},

	[142] = { --[[ Dustwallow Marsh ]] --
		{ 53, 77.65, { 718 } },     --onyxia
	},

	[491] = { --[[ Grizzly Hills ]] --
		{ 17.7, 23.3, { 534 } }, --draktharon keep
	},

	[497] = { --[[ Zul'Drak ]] --
		{ 82.15, 19.45, { 530 } }, --gundrak
	},

	[487] = { --[[ Borean Tundra ]] --
		{ 27, 25.96, { 520, 528, 527 }, "Нексус" }, --nexus, oculus, eye of eternity
	},

	[489] = { --[[ Dragonblight ]] --
		{ 26.8, 48.5, { 533, 522 }, "Азжол-Неруб" }, -- azjol-nerub,ahnkahet
		{ 87.4, 46.4, { 535 } }, --naxxramas
		{ 60, 56, { 531, 609, 924 }, "Храм Драконьего Покоя" }, --wymrest temple
	},

	[492] = { --[[ Howling Fjord ]] --
		{ 58.2, 48.9, { 523 } }, --utgarde keep
		{ 58.4, 45,   { 524 } }, --utgarde pinnacle
	},

	[493] = { --[[ Icecrown ]] --

		{ 51.4, 88.3, { 601, 602, 603 }, "Цитадель Ледяной Короны" }, --forge of souls, pit of saron, halls of reflection
		-- {74, 20.9, {542}}, --trial of champion
		{ 75.2, 21.9, { 543 } }, --trial of crusader
		{ 53.4, 85.8, { 604 } }, --ICC
	},

	[793] = { --[[ Storm Peaks ]] --
		{ 45.13, 19.78, { 525 } }, --halls of lightning
		{ 37.73, 26.34, { 526 } }, --halls of stone
		{ 41.5,  16.1,  { 529 } }, --ulduar
	},

	[502] = { --[[ Wintergrasp ]] --
		{ 49.8, 18.2, { 532 } }, --vault of archavon
	},

	[505] = { --[[ Dalaran ]] --
		{ 67.21, 68.65, { 536 } }, --violet hold
	},

	[511] = { --[[ Crystalsong Forest ]] --
		{ 30.58, 36.49, { 536 } },    --violet hold
	},


	[38] = { --[[ STRANGLETHORN VALE ]] --
		{ 53.3, 17.5, { 793 } },
	},

	[464] = { --[[ Ghostlands ]] --
		{ 77.93, 62.72, { 866 } },
	},


	[946] = { --[[ Тол'Гарод ]] --
		{ 51.0, 54.50, { 954 } }, -- тюрьма
	},


}

local InstanceMapDB = {

	--[[ Classic Dungeons ]] --

	[680] = { "Огненная Пропасть", 1, 15, 1 },
	[749] = { "Пещеры Стенаний", 1, 17, 1 },
	[756] = { "Мертвые копи", 1, 17, 1 },
	[764] = { "Крепость Темного Клыка", 1, 18, 1 },
	[688] = { "Непроглядная Пучина", 1, 21, 1 },
	[690] = { "Тюрьма", 1, 22, 1 },
	[761] = { "Лабиринты Иглошкурых", 1, 24, 1 },
	[691] = { "Гномереган", 1, 25, 1 },
	-- [874]={"Монастырь Алого ордена", 1, 29, 1},
	-- {890,941,939,940}
	[890] = { "Монастырь Алого ордена - Кладбище", 1, 29, 1 },
	[941] = { "Монастырь Алого ордена - Собор", 1, 36, 1 },
	[939] = { "Монастырь Алого ордена - Библиотека ", 1, 31, 1 },
	[940] = { "Монастырь Алого ордена - Оружейная", 1, 33, 1 },
	[760] = { "Курганы Иглошкурых", 1, 34, 1 },
	[871] = { "Зул'Фаррак", 1, 34, 1 },
	[692] = { "Ульдаман", 1, 37, 1 },
	[750] = { "Мародон", 1, 41, 1 },
	[687] = { "Храм Атал'Хаккара", 1, 47, 1 },
	[704] = { "Глубины Черной горы", 1, 49, 1 },
	[699] = { "Забытый Город", 1, 55, 1 },
	[765] = { "Стратхольм", 1, 55, 1 },
	[721] = { "Нижний шпиль черной горы", 1, 55, 1 },
	[898] = { "Некроситет", 1, 55, 1 },

	--[[ Classic Raids ]] --

	[995] = { "Верхняя часть пика Черной горы", 2, 57, 1 },
	[793] = { "Зул'Гуруб", 2, 60, 1 },
	[696] = { "Огненные Недра", 2, 60, 1 },
	[755] = { "Логово Крыла Тьмы", 2, 60, 1 },
	[881] = { "Руины Ан'Киража", 2, 60, 1 },
	[893] = { "Храм Ан'Киража", 2, 60, 1 },
	[537] = { "Наксрамас", 2, 60, 1 },

	--[[ Burning Crusade Dungeons ]] --

	[797] = { "Бастионы Адского Пламени", 1, 59, 2 },
	[835] = { "Кузня Крови", 1, 61, 2 },
	[836] = { "Нижетопь", 1, 62, 2 },
	[838] = { "Узилище", 1, 62, 2 },
	[842] = { "Гробницы Маны", 1, 64, 2 },
	[722] = { "Аукенайские гробницы", 1, 65, 2 },
	[734] = { "Старые предгорья Хилсбрада", 1, 66, 2 },
	[833] = { "Сетеккские залы", 1, 67, 2 },
	[834] = { "Темный лабиринт", 1, 67, 2 },
	[840] = { "Механар", 1, 67, 2 },
	[839] = { "Ботаника", 1, 67, 2 },
	[710] = { "Разрушенные залы", 1, 67, 2 },
	[727] = { "Паровое подземелье", 1, 67, 2 },
	[733] = { "Черные топи", 1, 68, 2 },
	[798] = { "Терраса Магистров", 1, 83, 2 },
	[841] = { "Аркатрац", 1, 68, 2 },

	--[[ Burning Crusade Raids ]] --

	[864] = { "Логово Груула", 2, 80, 2 },
	[775] = { "Битва на горе Хиджал", 2, 80, 2 },
	[865] = { "Логово Магтеридона", 2, 80, 2 },
	[862] = { "Змеиное святилище", 2, 80, 2 },
	[861] = { "Око", 2, 80, 2 },
	[866] = { "Зул'Аман", 2, 80, 2 },
	[846] = { "Плато Солнечного Колодца", 2, 83, 2 },
	[847] = { "Черный Храм", 2, 83, 2 },
	[867] = { "Каражан", 2, 80, 2 },


	--[[ Wrath Dungeons ]] --

	[523] = { "Вершина Утгард", 1, 69, 3 },
	[520] = { "Нексус", 1, 71, 3 },
	[533] = { "Азжол-Неруб", 1, 72, 3 },
	[522] = { "Ан'кахет: Старое Королевство", 1, 73, 3 },
	[534] = { "Крепость Драк'Тарон", 1, 74, 3 },
	[536] = { "Аметистовая крепость", 1, 75, 3 },
	[530] = { "Гундрак", 1, 76, 3 },
	[526] = { "Чертоги Камня", 1, 77, 3 },
	[528] = { "Окулус", 1, 79, 3 },
	[602] = { "Яма Сарона", 1, 79, 3 },
	[601] = { "Кузня Душ", 1, 79, 3 },
	[521] = { "Очищение Стратхольма", 1, 83, 3 },
	-- [542]={"Испытание чемпиона", 1, 83, 3},
	[603] = { "Залы Отражений", 1, 79, 3 },
	[525] = { "Чертоги Молний", 1, 79, 3 },
	[524] = { "Крепость Утгард", 1, 79, 3 },

	--[[ Wrath Raids ]] --

	[535] = { "Наксрамас", 2, 80, 3 },
	[718] = { "Логово Ониксии", 2, 80, 3 },
	[527] = { "Око Вечности", 2, 80, 3 },
	[531] = { "Обсидиановое святилище", 2, 80, 3 },
	[924] = { "Бронзовое святилище", 2, 80, 3 },
	[609] = { "Рубиновое святилище", 2, 80, 3 },
	[543] = { "Испытание крестоносца", 2, 80, 3 },
	[529] = { "Ульдуар", 2, 80, 3 },
	[532] = { "Cклеп Аркавона", 2, 80, 3 },
	[604] = { "Цитадель Ледяной Короны", 2, 80, 3 },
	[954] = { "Тол'гародская тюрьма", 2, 80, 3 },
	[5] = { "Категории", 2, 80, 3 },
}

function IM:PrintDebug(t)
	if (Debug) then
		print(t)
	end
end

function IM:FindInstanceByName(name, isRaid)
	if isRaid == nil then
		local id = self:FindInstanceByName(name, true)
		if not id then id = self:FindInstanceByName(name, false) end
		return id
	end

	local i = 1
	local instanceId, instanceName = EJ_GetInstanceByIndex(i, isRaid)
	name = name:lower()

	while instanceId do
		if name == instanceName:lower() then return instanceId end
		i = i + 1
		instanceId, instanceName = EJ_GetInstanceByIndex(i, isRaid)
	end
	return nil
end

function IM:ShowInstance(subInstanceMapIDs, index)
	local name = InstanceMapDB[subInstanceMapIDs[index]][1]
	local type = InstanceMapDB[subInstanceMapIDs[index]][2]
	local tier = InstanceMapDB[subInstanceMapIDs[index]][4]

	-- version, internalVersion, date, uiVersion = GetBuildInfo()

	-- if (uiVersion < 70000) and ((tier <= 3) and (type == 2)) then -- no journal for Vanilla, TBC & WotLK raids before 7.0
	-- SetMapByID(subInstanceMapIDs[index])
	-- else
	ToggleEncounterJournalFrame()
	EJ_SelectTier(tier) -- have to select expansion tier before we can query details or select
	local instanceID = IM:FindInstanceByName(name, (type == 2))
	if not instanceID then
		IM:PrintDebug("Loading instance: " .. "none" .. " for name: " .. name)
		-- EncounterJournal_ResetDisplay(instanceID, -1, -1)
	else
		EncounterJournal_ResetDisplay(instanceID, -1, -1)
	end

	-- end
end

function IM:ShowPin(locationIndex)
	local GCMAID = GetCurrentMapAreaID()
	local instancePortal = IM.PinDB[GCMAID][locationIndex]

	if not (instancePortal) then
		IM:PrintDebug("No pin " .. locationIndex .. " for map: " .. GCMAID)
		return nil
	end

	local x = instancePortal[1]
	local y = instancePortal[2]
	local subInstanceMapIDs = instancePortal[3]
	local hubName = instancePortal[4]

	local type = InstanceMapDB[subInstanceMapIDs[1]][2]

	local pin = CreateFrame("Frame", "Pin" .. GCMAID .. locationIndex, WorldMapDetailFrame)

	pin.Texture = pin:CreateTexture()
	pin.Texture:SetTexture(IMIcons)
	pin.Texture:SetAllPoints()
	pin:EnableMouse(true)
	pin:SetFrameStrata("DIALOG")
	-- pin:SetFrameLevel(WorldMapFrame.UIElementsFrame:GetFrameLevel())

	pin:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", (x / 100) * WorldMapDetailFrame:GetWidth(),
		(-y / 100) * WorldMapDetailFrame:GetHeight())

	pin:SetWidth(31)
	pin:SetHeight(31)
	if (type == 1) then
		pin.Texture:SetTexCoord(unpack(ICON_COORDS_DUNGEON))
	elseif (type == 2) then
		pin.Texture:SetTexCoord(unpack(ICON_COORDS_RAID))
	end

	if (#subInstanceMapIDs > 1) then
		pin.Texture:SetTexCoord(unpack(ICON_COORDS_HUB))
	end

	pin:HookScript("OnEnter", function(pinIn, motion)
		if (type == 1) then
			pinIn.Texture:SetTexCoord(unpack(ICON_COORDS_DUNGEON_HIGHLIGHTED))
		elseif (type == 2) then
			pinIn.Texture:SetTexCoord(unpack(ICON_COORDS_RAID_HIGHLIGHTED))
		end

		MapTooltip:SetOwner(pinIn, "ANCHOR_RIGHT")
		MapTooltip:ClearLines()
		MapTooltip:SetScale(GetCVar("uiScale"))
		if (#subInstanceMapIDs > 1) then
			MapTooltip:AddLine(hubName)
		end
		for i = 1, #subInstanceMapIDs do
			local name = InstanceMapDB[subInstanceMapIDs[i]][1]
			local typeN = InstanceMapDB[subInstanceMapIDs[i]][2]
			local requiredLevel = InstanceMapDB[subInstanceMapIDs[i]][3]
			-- local tier = InstanceMapDB[subInstanceMapIDs[i]][4]

			--local instanceID = FindInstanceByName(name, (type == 2))

			--EJ_SelectTier(tier) -- have to select expansion tier before we can query details or select
			--EncounterJournal_ResetDisplay(instanceID, -1, -1)
			--DumpLootTable()

			MapTooltip:AddDoubleLine(string.format("|cffffffff%s|r", name),
				string.format("|cffff7d0a%d|r", requiredLevel))
			if (typeN == 1) then
				MapTooltip:AddTexture(IMDunge)
			else
				MapTooltip:AddTexture(IMRaid)
			end
		end
		MapTooltip:Show()
	end
	)
	pin:HookScript("OnLeave", function(pinN)
		if (type == 1) then
			pinN.Texture:SetTexCoord(unpack(ICON_COORDS_DUNGEON))
		elseif (type == 2) then
			pinN.Texture:SetTexCoord(unpack(ICON_COORDS_RAID))
		end
		MapTooltip:Hide()
	end)
	pin:HookScript("OnMouseDown", function(self, button)
		if (button == "LeftButton") then
			if (#subInstanceMapIDs == 1) then
				IM:ShowInstance(subInstanceMapIDs, 1)
			else
				local menu = {
					{ text = hubName, isTitle = true },
				}
				for i = 1, #subInstanceMapIDs do
					local name = InstanceMapDB[subInstanceMapIDs[i]][1]
					local line = {
						text = name,
						notCheckable = true,
						func = function()
							IM:ShowInstance(subInstanceMapIDs,
								i);
						end
					}

					table.insert(menu, line)
				end

				local menuFrame = CreateFrame("Frame", "SelectMenuFrame", UIParent, "UIDropDownMenuTemplate")
				EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU");
			end
		end
	end)
	table.insert(PinFrames, pin)
	pin:Show()
end

function IM:HideAllPins()
	for i = 1, #PinFrames do
		PinFrames[i]:Hide()
	end

	wipe(PinFrames)
end

function IM:RefreshPins()
	IM:HideAllPins()
	if not (WorldMapFrame:IsVisible()) then return nil end

	local cityOverride = false

	if ((GetCurrentMapAreaID() == 301) or (GetCurrentMapAreaID() == 321) or (GetCurrentMapAreaID() == 504)) then
		cityOverride = true
	end

	IM:PrintDebug("RefreshPins for map: " .. GetCurrentMapAreaID())

	if ((GetCurrentMapDungeonLevel() == 0) or cityOverride) then
		if IM.PinDB[GetCurrentMapAreaID()] then
			for i = 1, #IM.PinDB[GetCurrentMapAreaID()] do
				IM:ShowPin(i)
			end
		end
	else
		IM:PrintDebug("No pins for this dungeon level")
	end
end


local function EventHandler(self, event, ...)
	IM:RefreshPins()
end


function IM:MapTooltipSetup()
	MapTooltip = CreateFrame("GameTooltip", "MapTooltip", WorldFrame, "GameTooltipTemplate")
	MapTooltip:StripTextures()
	MapTooltip:CreateBackdrop("Transparent")
	MapTooltip:SetFrameStrata("TOOLTIP")
	WorldMapFrame:HookScript("OnSizeChanged", function(self)
		MapTooltip:SetScale(1 / self:GetScale())
	end)
end

function IM:Initialize()
	tinsert(UISpecialFrames, "InstancePortalUI")
	local imFrame = CreateFrame("Frame", nil, UIParent)
	imFrame:RegisterForDrag("LeftButton")
	imFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	imFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	imFrame:RegisterEvent("ADDON_LOADED")
	imFrame:RegisterEvent("WORLD_MAP_UPDATE")
	imFrame:RegisterEvent("WORLD_MAP_NAME_UPDATE")
	imFrame:SetScript("OnEvent", EventHandler)

	-- if(not EncounterJournal) then
	-- LoadAddOn("Blizzard_EncounterJournal")
	-- end

	IM:PrintDebug("InstancePortalUI_OnLoad()")
	IM:MapTooltipSetup()
end

local function InitializeCallback()
	IM:Initialize()
end

E:RegisterInitialModule(IM:GetName(), InitializeCallback)