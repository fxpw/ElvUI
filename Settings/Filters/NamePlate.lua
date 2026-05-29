--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

G.nameplates.filters = {
	ElvUI_Boss = {
		triggers = {
			level = true,
			curlevel = -1,
			nameplateType = {
				enable = true,
				enemyNPC = true
			}
		},
		actions = {
			scale = 1.15
		}
	},
}

E.StyleFilterDefaults = {
	triggers = {
		priority = 1,
		isTarget = false,
		notTarget = false,
		isMouseover = false,
		notMouseover = false,
		requireTarget = false,
		noTarget = false,
		targetMe = false,
		notTargetMe = false,
		targetPet = false,
		notTargetPet = false,
		level = false,
		mylevel = false,
		negativeMatch = false,
		casting = {
			isCasting = false,
			isChanneling = false,
			notCasting = false,
			notChanneling = false,
			interruptible = false,
			notInterruptible = false,
			notSpell = false,
			spells = {}
		},
		class = {}, -- per-class subtable: { WARRIOR = { enabled = true } }
		faction = {
			Alliance = false,
			Horde = false,
			Neutral = false,
			Renegade = false,
		},
		role = {
			tank = false,
			healer = false,
			damager = false
		},
		classification = {
			worldboss = false,
			rareelite = false,
			elite = false,
			rare = false,
			normal = false,
			trivial = false,
			minus = false
		},
		raidTarget = {
			star = false,
			circle = false,
			diamond = false,
			triangle = false,
			moon = false,
			square = false,
			cross = false,
			skull = false
		},
		curlevel = 0,
		maxlevel = 0,
		minlevel = 0,
		healthThreshold = false,
		healthUsePlayer = false,
		underHealthThreshold = 0,
		overHealthThreshold = 0,
		powerThreshold = false,
		powerUsePlayer = false,
		underPowerThreshold = 0,
		overPowerThreshold = 0,
		names = {},
		nameplateType = {
			enable = false,
			friendlyPlayer = false,
			friendlyNPC = false,
			enemyPlayer = false,
			enemyNPC = false
		},
		reactionType = {
			enable = false,
			hostile = false,
			neutral = false,
			friendly = false
		},
		instanceType = {
			none = false,
			sanctuary = false,
			party = false,
			raid = false,
			arena = false,
			pvp = false
		},
		instanceDifficulty = {
			dungeon = {
				normal = false,
				heroic = false
			},
			raid = {
				normal = false,
				heroic = false
			}
		},
		cooldowns = {
			names = {},
			mustHaveAll = false
		},
		buffs = {
			mustHaveAll = false,
			missing = false,
			names = {},
			minTimeLeft = 0,
			maxTimeLeft = 0,
			fromMe = false,
			fromPet = false,
			onMe = false,
			onPet = false
		},
		debuffs = {
			mustHaveAll = false,
			missing = false,
			names = {},
			minTimeLeft = 0,
			maxTimeLeft = 0,
			fromMe = false,
			fromPet = false,
			onMe = false,
			onPet = false
		},
		inCombat = false,
		outOfCombat = false,
		inCombatUnit = false,
		outOfCombatUnit = false,
		inVehicle = false,
		outOfVehicle = false,
		inVehicleUnit = false,
		outOfVehicleUnit = false,
		isResting = false,
		notResting = false
	},
	actions = {
		color = {
			health = false,
			border = false,
			name = false,
			healthClass = false,
			borderClass = false,
			nameClass = false,
			healthColor = { r = 1, g = 1, b = 1, a = 1 },
			borderColor = { r = 1, g = 1, b = 1, a = 1 },
			nameColor = { r = 1, g = 1, b = 1, a = 1 }
		},
		texture = {
			enable = false,
			texture = "ElvUI Norm"
		},
		flash = {
			enable = false,
			color = { r = 1, g = 1, b = 1, a = 1 },
			speed = 4
		},
		text = {
			enableName = false,
			nameTag = '[name:long]',
			enableLevel = false,
			levelTag = '[smartlevel]',
			enablePower = false,
			powerTag = '',
		},
		hide = false,
		nameOnly = false,
		showHealth = false,
		showTargetIndicator = false,
		targetIndicatorStyle = 'style4',
		targetIndicatorArrow = 'ArrowUp',
		targetIndicatorArrowSize = 20,
		targetIndicatorArrowXOffset = 3,
		targetIndicatorArrowYOffset = 0,
		showMouseoverHighlight = false,
		scale = 1.0,
		alpha = -1,
		frameLevel = 0
	}
}

G.nameplates.specialFilters = {
	Personal = true,
	nonPersonal = true,
	blockNonPersonal = true,
	blockNoDuration = true
}