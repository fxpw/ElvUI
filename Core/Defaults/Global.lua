local E, L, V, P, G = unpack(ElvUI)

--Global Settings
G.general = {
	UIScale = 0.64,
	locale = E:GetLocale(),
	eyefinity = false,
	ultrawide = false,
	smallerWorldMap = true,
	allowDistributor = false,
	smallerWorldMapScale = 0.9,
	fadeMapWhenMoving = true,
	mapAlphaWhenMoving = 0.2,
	fadeMapDuration = 0.2,
	WorldMapCoordinates = {
		enable = true,
		position = 'BOTTOMLEFT',
		xOffset = 0,
		yOffset = 0
	},
	AceGUI = {
		width = 1024,
		height = 768
	},
	disableTutorialButtons = true
}

G.classtimer = {}

G.chat = {
	classColorMentionExcludedNames = {}
}

G.bags = {
	ignoredItems = {}
}

G.datatexts = {
	customPanels = {},
	customCurrencies = {},
	settings = {
		Agility = { Label = '', NoLabel = false },
		Armor = { Label = '', NoLabel = false },
		['Attack Power'] = { Label = '', NoLabel = false },
		Avoidance = { Label = '', NoLabel = false, decimalLength = 1 },
		Bags = { textFormat = 'USED_TOTAL', Label = '', NoLabel = false },
		CallToArms = { Label = '', NoLabel = false },
		Combat = { TimeFull = true, NoLabel = false },
		CombatIndicator = { OutOfCombat = '', InCombat = '', OutOfCombatColor = {r = 0, g = 0.8, b = 0}, InCombatColor = {r = 0.8, g = 0, b = 0} },
		Currencies = { goldFormat = 'BLIZZARD', goldCoins = true, displayedCurrency = 'BACKPACK', displayStyle = 'ICON', tooltipData = {}, idEnable = {}, headers = true, maxCurrency = false },
		Crit = { Label = '', NoLabel = false, decimalLength = 1 },
		Durability = { Label = '', NoLabel = false, percThreshold = 30, goldFormat = 'BLIZZARD', goldCoins = true },
		DualSpecialization = { NoLabel = false },
		ElvUI = { Label = '' },
		['Equipment Sets'] = { Label = '', NoLabel = false, NoIcon = false },
		Experience = { textFormat = 'CUR' },
		Friends = {
			Label = '', NoLabel = false,
			--status
			hideAFK = false,
			hideDND = false,
		},
		Gold = { goldFormat = 'BLIZZARD', goldCoins = true },
		Guild = { Label = '', NoLabel = false },
		Haste = { Label = '', NoLabel = false, decimalLength = 1 },
		Hit = { Label = '', NoLabel = false, decimalLength = 1 },
		Intellect = { Label = '', NoLabel = false},
		['Item Level'] = { onlyEquipped = false, rarityColor = true },
		Location = { showZone = true, showSubZone = true, showContinent = false, color = 'REACTION', customColor = {r = 1, g = 1, b = 1} },
		Mastery = { Label = '', NoLabel = false, decimalLength = 1 },
		MovementSpeed = { Label = '', NoLabel = false, decimalLength = 1 },
		Reputation = { textFormat = 'CUR' },
		['Talent Specialization'] = { iconSize = 16, iconOnly = false },
		SpellPower = { school = 0 },
		['Spell Crit Chance'] = { school = 0 },
		Speed = { Label = '', NoLabel = false, decimalLength = 1 },
		Stamina = { Label = '', NoLabel = false },
		Strength = { Label = '', NoLabel = false },
		System = { NoLabel = false, ShowOthers = true, latency = 'WORLD', showTooltip = true },
		Time = { time24 = _G.GetCVar('portal') ~= 'en', localTime = true, flashInvite = true },
		Versatility = { Label = '', NoLabel = false, decimalLength = 1 },
		Dodge = { decimalLength = 1 },
		Parry = { decimalLength = 1 },
		Block = { decimalLength = 1 },
		['Mana Regen'] = { Label = '', NoLabel = false, decimalLength = 1 },
		HealPower = { Label = '', NoLabel = false },
		['Spell Hit'] = { Label = '', NoLabel = false, decimalLength = 0 }
	},
	newPanelInfo = {
		growth = 'HORIZONTAL',
		width = 300,
		height = 22,
		frameStrata = 'LOW',
		numPoints = 3,
		frameLevel = 1,
		backdrop = true,
		panelTransparency = false,
		mouseover = false,
		border = true,
		textJustify = 'CENTER',
		visibility = '[vehicleui] hide;show',
		tooltipAnchor = 'ANCHOR_TOPLEFT',
		tooltipXOffset = -17,
		tooltipYOffset = 4,
		fonts = {
			enable = false,
			font = 'PT Sans Narrow',
			fontSize = 12,
			fontOutline = 'OUTLINE',
		}
	},
}

G.nameplates = {}

G.unitframe = {
	aurafilters = {},
	buffwatch = {},
	raidDebuffIndicator = {
		instanceFilter = 'RaidDebuffs',
		otherFilter = 'CCDebuffs'
	},
	newCustomText = {
		text_format = '',
		size = 10,
		font = 'Homespun',
		fontOutline = 'MONOCHROMEOUTLINE',
		xOffset = 0,
		yOffset = 0,
		justifyH = 'CENTER',
		attachTextTo = 'Health'
	},
	rangeCheck = {
		PRIEST = {
			enemySpells = {
				[585] = true, -- Smite (30 yards)
			},
			longEnemySpells = {
				[589] = true, -- Shadow Word: Pain (30 yards)
			},
			friendlySpells = {
				[2050] = true, -- Lesser Heal (40 yards)
			},
			resSpells = {
				[2006] = true, -- Resurrection (40 yards)
			},
			petSpells = {},
		},
		DRUID = {
			enemySpells = {
				[33786] = true, -- Cyclone (20 yards)
			},
			longEnemySpells = {
				[5176] = true, -- Wrath (30 yards)
			},
			friendlySpells = {
				[5185] = true, -- Healing Touch (40 yards)
			},
			resSpells = {
				[50769] = true, -- Revive (30 yards)
				[20484] = true, -- Rebirth (30 yards)
			},
			petSpells = {},
		},
		PALADIN = {
			enemySpells = {
				[20271] = true, -- Judgement (10 yards)
			},
			longEnemySpells = {
				[879] = true, -- Exorcism (30 yards)
			},
			friendlySpells = {
				[635] = true, -- Holy Light (40 yards)
			},
			resSpells = {
				[7328] = true, -- Redemption (30 yards)
			},
			petSpells = {},
		},
		SHAMAN = {
			enemySpells = {
				[51514] = true, -- Hex (20 yards)
				[8042] = true, -- Earth Shock (25 yards)
			},
			longEnemySpells = {
				[403] = true, -- Lightning Bolt (30 yards)
			},
			friendlySpells = {
				[331] = true, -- Healing Wave (40 yards)
			},
			resSpells = {
				[2008] = true, -- Ancestral Spirit (30 yards)
			},
			petSpells = {},
		},
		WARLOCK = {
			enemySpells = {
				[5782] = true, -- Fear (20 yards)
			},
			longEnemySpells = {
				[686] = true, -- Shadow Bolt (30 yards)
			},
			friendlySpells = {
				[5697] = true, -- Unending Breath (30 yards)
			},
			resSpells = {},
			petSpells = {
				[755] = true, -- Health Funnel (45 yards)
			},
		},
		MAGE = {
			enemySpells = {
				[2136] = true, -- Fire Blast (20 yards)
				[12826] = true, -- Polymorph (30 yards)
			},
			longEnemySpells = {
				[133] = true, -- Fireball (35 yards)
				[44614] = true, -- Frostfire Bolt (40 yards)
			},
			friendlySpells = {
				[475] = true, -- Remove Curse (40 yards)
			},
			resSpells = {},
			petSpells = {},
		},
		HUNTER = {
			enemySpells = {
				[75] = true, -- Auto Shot (35 yards)
			},
			longEnemySpells = {},
			friendlySpells = {},
			resSpells = {},
			petSpells = {
				[136] = true, -- Mend Pet (45 yards)
			},
		},
		DEATHKNIGHT = {
			enemySpells = {
				[49576] = true, -- Death Grip (30 yards)
			},
			longEnemySpells = {},
			friendlySpells = {
				[47541] = true, -- Death Coil (40 yards)
			},
			resSpells = {
				[61999] = true, -- Raise Ally (30 yards)
			},
			petSpells = {},
		},
		ROGUE = {
			enemySpells = {
				[2094] = true, -- Blind (10 yards)
			},
			longEnemySpells = {
				[26679] = true, -- Deadly Throw (30 yards)
			},
			friendlySpells = {
				[57934] = true, -- Tricks of the Trade (20 yards)
			},
			resSpells = {},
			petSpells = {},
		},
		WARRIOR = {
			enemySpells = {
				[5246] = true, -- Intimidating Shout (8 yards)
				[100] = true, -- Charge (25 yards)
			},
			longEnemySpells = {
				[355] = true, -- Taunt (30 yards)
			},
			friendlySpells = {
				[3411] = true, -- Intervene (25 yards)
			},
			resSpells = {},
			petSpells = {},
		}
	}
}

G.profileCopy = {
	selected = 'Default'
}