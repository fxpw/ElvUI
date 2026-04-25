local E, L, V, P, G = unpack(ElvUI)

local CopyTable = CopyTable -- Our function doesn't exist yet.
local next = next

P.gridSize = 64
P.layoutSetting = "tank"
P.hideTutorial = true
P.dbConverted = nil -- use this to let DBConversions run once per profile

--Core
P.general = {
	messageRedirect = _G.DEFAULT_CHAT_FRAME:GetName(),
	smoothingAmount = 0.33, -- AMOUNT should match in general/smoothie file
	taintLog = false,
	stickyFrames = true,
	loginmessage = true,
	interruptAnnounce = 'NONE',
	autoRepair = 'NONE',
	autoTrackReputation = false,
	autoAcceptInvite = false,
	hideErrorFrame = true,
	hideZoneText = false,
	enhancedPvpMessages = true,
	objectiveFrameHeight = 480,
	objectiveFrameAutoHide = true,
	objectiveFrameAutoHideInKeystone = false,
	bonusObjectivePosition = 'LEFT',
	vehicleSeatIndicatorSize = 128,
	resurrectSound = false,
	questRewardMostValueIcon = true,
	questXPPercent = true,
	durabilityScale = 1,
	gameMenuScale = 1,
	lockCameraDistanceMax = true,
	cameraDistanceMax = 50,
	afk = true,
	afkChat = true,
	afkSpin = true,
	cropIcon = 2,
	objectiveTracker = true,
	numberPrefixStyle = 'ENGLISH',
	tagUpdateRate = 0.2, -- eventTimerThreshold
	decimalLength = 1,
	fontSize = 12,
	font = 'PT Sans Narrow',
	fontStyle = 'OUTLINE',
	topPanel = false,
	bottomPanel = true,
	bottomPanelSettings = {
		transparent = true,
		height = 22,
		width = 0
	},
	topPanelSettings = {
		transparent = true,
		height = 22,
		width = 0
	},
	raidUtility = {
		showTooltip = true
	},
	fonts = {
		cooldown = { enable = true, font = 'Expressway', size = 20, outline = 'SHADOWOUTLINE' },
		errortext = { enable = true, font = 'Expressway', size = 18, outline = 'SHADOW' },
		worldzone = { enable = false, font = 'Expressway', size = 26, outline = 'OUTLINE' },
		worldsubzone = { enable = false, font = 'Expressway', size = 24, outline = 'OUTLINE' },
		pvpzone = { enable = false, font = 'Expressway', size = 26, outline = 'OUTLINE' },
		pvpsubzone = { enable = false, font = 'Expressway', size = 24, outline = 'OUTLINE' },
		objective = { enable = false, font = 'Expressway', size = 14, outline = 'SHADOW' },
		mailbody = { enable = false, font = 'Expressway', size = 14, outline = 'SHADOW' },
		questtitle = { enable = false, font = 'Expressway', size = 18, outline = 'NONE' },
		questtext = { enable = false, font = 'Expressway', size = 14, outline = 'NONE' },
		questsmall = { enable = false, font = 'Expressway', size = 13, outline = 'NONE' },
	},
	classColors = {
		HUNTER = { b = 0.44, g = 0.82, r = 0.66 },
		WARRIOR = { b = 0.42, g = 0.60, r = 0.77 },
		ROGUE = { b = 0.40, g = 0.95, r = 1 },
		MAGE = { b = 0.92, g = 0.78, r = 0.24 },
		PRIEST = { b = 1, g = 1, r = 1 },
		SHAMAN = { b = 0.86, g = 0.43, r = 0 },
		WARLOCK = { b = 0.93, g = 0.53, r = 0.52 },
		DEATHKNIGHT = { b = 0.22, g = 0.11, r = 0.76 },
		DRUID = { b = 0.03, g = 0.48, r = 1 },
		PALADIN = { b = 0.72, g = 0.54, r = 0.95 }
	},
	debuffColors = { -- handle colors of LibDispel
		none = { r = 0.8, g = 0, b = 0 },
		Magic = { r = 0.2, g = 0.6, b = 1 },
		Curse = { r = 0.6, g = 0, b = 1 },
		Disease = { r = 0.6, g = 0.4, b = 0 },
		Poison = { r = 0, g = 0.6, b = 0 },

		-- These dont exist in Blizzards color table
		EnemyNPC = { r = 0.9, g = 0.1, b = 0.1 },
		BadDispel = { r = 0.05, g = 0.85, b = 0.94 },
		Bleed = { r = 1, g = 0.2, b = 0.6 },
		Stealable = { r = 0.93, g = 0.91, b = 0.55 },
	},
	bordercolor = { r = 0, g = 0, b = 0 }, -- updated in E.Initialize
	backdropcolor = { r = 0.1, g = 0.1, b = 0.1 },
	backdropfadecolor = { r = .06, g = .06, b = .06, a = 0.8 },
	valuecolor = { r = 0.09, g = 0.52, b = 0.82 },
	itemLevel = {
		displayCharacterInfo = true,
		displayInspectInfo = true,
		enchantAbbrev = true,
		showItemLevel = true,
		showEnchants = true,
		showGems = true,
		itemLevelRarity = true,
		itemLevelFont = 'PT Sans Narrow',
		itemLevelFontSize = 12,
		itemLevelFontOutline = 'OUTLINE',
		totalLevelFont = 'PT Sans Narrow',
		totalLevelFontSize = 18,
		totalLevelFontOutline = 'OUTLINE',
	},
	customGlow = {
		style = 'Pixel Glow',
		color = { r = 0.09, g = 0.52, b = 0.82, a = 0.9 },
		startAnimation = true,
		useColor = false,
		duration = 1,
		speed = 0.3,
		lines = 8,
		size = 1,
	},
	minimap = {
		size = 175,
		scale = 1,
		circle = false,
		rotate = false,
		clusterDisable = true,
		clusterBackdrop = true,
		locationText = "MOUSEOVER",
		locationFontSize = 14,
		locationFontOutline = "OUTLINE",
		locationFont = "Expressway",
		timeFontSize = 14,
		timeFontOutline = "OUTLINE",
		timeFont = "Expressway",
		resetZoom = {
			enable = false,
			time = 3,
		},
		icons = {
			tracking = {
				scale = 0.65,
				position = "BOTTOMLEFT",
				xOffset = 3,
				yOffset = 3,
			},
			calendar = {
				scale = 1,
				position = "TOPRIGHT",
				xOffset = 0,
				yOffset = 0,
				hide = true,
			},
			mail = {
				scale = 1,
				texture = "Mail3",
				position = "TOPRIGHT",
				xOffset = 3,
				yOffset = 4,
			},
			lfgEye = {
				scale = 1,
				position = "BOTTOMRIGHT",
				xOffset = 3,
				yOffset = -3
			},
			battlefield = {
				scale = 1.1,
				position = "BOTTOMRIGHT",
				xOffset = 4,
				yOffset = -4,
			},
			difficulty = {
				scale = 1,
				position = "TOPLEFT",
				xOffset = 0,
				yOffset = 0,
			}
		}
	},
	lootRoll = {
		width = 325,
		height = 30,
		spacing = 4,
		maxBars = 5,
		buttonSize = 20,
		leftButtons = false,
		qualityName = false,
		qualityItemLevel = false,
		qualityStatusBar = true,
		qualityStatusBarBackdrop = true,
		statusBarColor = { r = 0, g = .4, b = 1 },
		statusBarTexture = 'ElvUI Norm',
		style = 'halfbar',
		nameFont = 'Expressway',
		nameFontSize = 12,
		nameFontOutline = 'OUTLINE',
	},
	totems = { -- totem tracker
		growthDirection = "VERTICAL",
		sortDirection = "DESCENDING",
		size = 40,
		height = 40,
		spacing = 4,
		keepSizeRatio = true,
	},
	guildBank = {
		itemQuality = true,
		itemLevel = true,
		itemLevelThreshold = 1,
		itemLevelFont = 'Homespun',
		itemLevelFontSize = 10,
		itemLevelFontOutline = 'MONOCHROMEOUTLINE',
		itemLevelCustomColorEnable = false,
		itemLevelCustomColor = { r = 1, g = 1, b = 1 },
		itemLevelPosition = 'BOTTOMRIGHT',
		itemLevelxOffset = 0,
		itemLevelyOffset = 2,
		countFont = 'Homespun',
		countFontSize = 10,
		countFontOutline = 'MONOCHROMEOUTLINE',
		countFontColor = { r = 1, g = 1, b = 1 },
		countPosition = 'BOTTOMRIGHT',
		countxOffset = 0,
		countyOffset = 2,
	}
}

--DataBars
P.databars = {
	transparent = true,
	statusbar = "ElvUI Norm",
	customTexture = false,
	colors = {
		reputationAlpha = 1,
		useCustomFactionColors = false,
		petExperience = { r = 1, g = 1, b = .41, a = .8 },
		experience = { r = 0, g = .4, b = 1, a = .8 },
		rested = { r = 1, g = 0, b = 1, a = .4 },
		quest = { r = 0, g = 1, b = 0, a = .4 },
		factionColors = {
			{ r = .8, g = .3, b = .22 },	-- 1
			{ r = .8, g = .3, b = .22 },	-- 2
			{ r = .75, g = .27, b = 0 },	-- 3
			{ r = .9, g = .7, b = 0 },		-- 4
			{ r = 0, g = .6, b = .1 },		-- 5
			{ r = 0, g = .6, b = .1 },		-- 6
			{ r = 0, g = .6, b = .1 },		-- 7
			{ r = 0, g = .6, b = .1 },		-- 8
		}
	}
}

for _, databar in next, {"experience", "reputation", "threat", "petExperience"} do
	P.databars[databar] = {
		enable = true,
		width = 222,
		height = 10,
		textFormat = "NONE",
		fontSize = 11,
		font = "PT Sans Narrow",
		fontOutline = "SHADOW",
		xOffset = 0,
		yOffset = 0,
		displayText = true,
		anchorPoint = "CENTER",
		mouseover = false,
		clickThrough = false,
		hideInCombat = false,
		orientation = "AUTOMATIC",
		reverseFill = false,
		showBubbles = false,
		frameStrata = "LOW",
		frameLevel = 1
	}
end

P.databars.threat.hideInCombat = nil -- always on in code
P.databars.threat.tankStatus = true
P.databars.threat.smoothbars = true

P.databars.experience.hideAtMaxLevel = true
P.databars.experience.showLevel = false
P.databars.experience.width = 348
P.databars.experience.fontSize = 12
P.databars.experience.showQuestXP = true
P.databars.experience.questTrackedOnly = false
P.databars.experience.questCompletedOnly = false
P.databars.experience.questCurrentZoneOnly = false

P.databars.reputation.enable = false
P.databars.reputation.hideBelowMaxLevel = false
P.databars.reputation.showReward = true
P.databars.reputation.rewardPosition = "LEFT"

P.databars.petExperience.hideAtMaxLevel = true
P.databars.petExperience.width = 230

--Bags
P.bags = {
	sortInverted = true,
	bagSize = 34,
	bagButtonSpacing = 1,
	bankButtonSpacing = 1,
	bankSize = 34,
	bagWidth = 406,
	bankWidth = 406,
	currencyFormat = "ICON_TEXT_ABBR",
	moneyFormat = "SMART",
	moneyCoins = true,
	questIcon = true,
	junkIcon = false,
	junkDesaturate = false,
	newItemGlow = true,
	ignoredItems = {},
	itemLevel = true,
	itemLevelThreshold = 1,
	itemLevelFont = "Homespun",
	itemLevelFontSize = 10,
	itemLevelFontOutline = "MONOCHROMEOUTLINE",
	itemLevelCustomColorEnable = false,
	itemLevelCustomColor = { r = 1, g = 1, b = 1 },
	itemLevelPosition = "BOTTOMRIGHT",
	itemLevelxOffset = 0,
	itemLevelyOffset = 2,
	itemInfo = true,
	itemInfoFont = "Homespun",
	itemInfoFontSize = 10,
	itemInfoFontOutline = "MONOCHROMEOUTLINE",
	itemInfoColor = { r = 0, g = .75, b = .98 },
	countFont = "Homespun",
	countFontSize = 10,
	countFontOutline = "MONOCHROMEOUTLINE",
	countFontColor = {r = 1, g = 1, b = 1},
	countPosition = "BOTTOMRIGHT",
	countxOffset = 0,
	countyOffset = 2,
	reverseSlots = false,
	clearSearchOnClose = false,
	disableBagSort = false,
	disableBankSort = false,
	strata = 'HIGH',
	qualityColors = true,
	specialtyColors = true,
	showBindType = false,
	transparent = false,
	colors = {
		profession = {
			ammoPouch		= { r = 1.00, g = 0.69, b = 0.41 },
			enchanting		= { r = 0.72, g = 0.22, b = 0.74 },
			engineering		= { r = 0.91, g = 0.46, b = 0.18 },
			gems			= { r = 0.03, g = 0.65, b = 0.75 },
			herbs			= { r = 0.28, g = 0.74, b = 0.07 },
			inscription		= { r = 0.32, g = 0.34, b = 0.98 },
			keyring			= { r = 0.67, g = 0.87, b = 0.37 },
			leatherworking	= { r = 0.74, g = 0.55, b = 0.20 },
			mining			= { r = 0.54, g = 0.40, b = 0.04 },
			quiver			= { r = 1.00, g = 0.69, b = 0.41 },
			soulBag			= { r = 1.00, g = 0.69, b = 0.41 },
		},
		items = {
			questStarter	= { r = 1.00, g = 0.96, b = 0.41 },
			questItem		= { r = 0.90, g = 0.30, b = 0.30 },
		}
	},
	vendorGrays = {
		enable = false,
		interval = 0.2,
		details = false,
		progressBar = true,
	},
	split = {
		bagSpacing = 5,
		bankSpacing = 5,
		player = false,
		bank = false,
	},
	shownBags = {},
	autoToggle = {
		enable = true,
		bank = true,
		mail = true,
		vendor = true,
		soulBind = true,
		auctionHouse = true,
		professions = false,
		guildBank = false,
		trade = false,
	},
	spinner = {
		enable = true,
		size = 48,
		color = { r = 1, g = 0.82, b = 0 }
	},
	bagBar = {
		growthDirection = "VERTICAL",
		sortDirection = "ASCENDING",
		size = 30,
		spacing = 4,
		backdropSpacing = 4,
		showBackdrop = false,
		mouseover = false,
		showCount = true,
		justBackpack = false,
		visibility = "show",
		font = "PT Sans Narrow",
		fontOutline = "OUTLINE",
		fontSize = 12,
	}
}

for i = -3, 12 do
	local name = "bag"..i
	P.bags.shownBags[name] = true

	if i >= 1 then
		P.bags.split[name] = false
	end
end

--NamePlate
P.nameplates = {
	statusbar = "ElvUI Norm",
	smoothbars = false,
	clickThrough = {
		friendly = false,
		enemy = false,
	},
	plateSize ={
		friendlyWidth = 150,
		friendlyHeight = 30,
		enemyWidth = 150,
		enemyHeight = 30,
	},
	plateScale = false,
	font = "PT Sans Narrow",
	fontSize = 11,
	fontOutline = "OUTLINE",

	useTargetScale = true,
	targetScale = 1.15,
	nonTargetTransparency = 0.40,

	motionType = "OVERLAP",

	lowHealthThreshold = 0.4,

	showFriendlyCombat = "DISABLED",
	showEnemyCombat = "DISABLED",

	nameColoredGlow = false,
	highlight = true,

	cutawayHealth = false,
	cutawayHealthLength = 0.3,
	cutawayHealthFadeOutTime = 0.6,

	alwaysShowTargetHealth = true,

	colors = {
		glowColor = {r = 1, g = 1, b = 1, a = 1},
		castColor = {r = 1, g = 0.81, b = 0},
		castNoInterruptColor = {r = 0.78, g = 0.25, b = 0.25},
		castInterruptedColor = {r = 0.30, g = 0.30, b = 0.30},
		castbarDesaturate = true,
		reactions = {
			friendlyPlayer = {r = 0.31, g = 0.45, b = 0.63},
			good = {r = .29, g = .68, b = .30},
			neutral = {r = .85, g = .77, b = .36},
			bad = {r = 0.78, g = 0.25, b = 0.25},
		},
		threat = {
			goodColor = {r = 75/255, g = 175/255, b = 76/255},
			badColor = {r = 0.78, g = 0.25, b = 0.25},
			goodTransition = {r = 218/255, g = 197/255, b = 92/255},
			badTransition = {r = 235/255, g = 163/255, b = 40/255},
		},
		comboPoints = {
			[1] = {r = .69, g = .31, b = .31},
			[2] = {r = .69, g = .31, b = .31},
			[3] = {r = .65, g = .63, b = .35},
			[4] = {r = .65, g = .63, b = .35},
			[5] = {r = .33, g = .59, b = .33}
		}
	},
	cooldown = {
		override = true,
		reverse = false,
		threshold = 3,
		expiringColor = {r = 1, g = 0, b = 0},
		secondsColor = {r = 1, g = 1, b = 1},
		minutesColor = {r = 1, g = 1, b = 1},
		hoursColor = {r = 1, g = 1, b = 1},
		daysColor = {r = 1, g = 1, b = 1},
		expireIndicator = {r = 1, g = 1, b = 1},
		secondsIndicator = {r = 1, g = 1, b = 1},
		minutesIndicator = {r = 1, g = 1, b = 1},
		hoursIndicator = {r = 1, g = 1, b = 1},
		daysIndicator = {r = 1, g = 1, b = 1},
		hhmmColorIndicator = {r = 1, g = 1, b = 1},
		mmssColorIndicator = {r = 1, g = 1, b = 1},

		checkSeconds = false,
		targetAuraDuration = 3600,
		modRateColor = { r = 0.6, g = 1, b = 0.4 },
		hhmmColor = {r = 0.43, g = 0.43, b = 0.43},
		mmssColor = {r = 0.56, g = 0.56, b = 0.56},
		hhmmThreshold = -1,
		mmssThreshold = -1,

		fonts = {
			enable = false,
			font = "PT Sans Narrow",
			fontOutline = "OUTLINE",
			fontSize = 18
		}
	},
	fadeIn = true,
	threat = {
		goodScale = 0.8,
		badScale = 1.2,
		useThreatColor = true
	},
	filters = {
		ElvUI_Boss = {triggers = {enable = false}},
		ElvUI_Target = {triggers = {enable = false}},
		ElvUI_NonTarget = {triggers = {enable = true}},
		ElvUI_Totem = {triggers = {enable = true}}
	},
	visibility = {
		showAll = true,
		showOnlyNames = false,
		enemy = {
			guardians = false,
			minions = false,
			minus = true,
			pets = false,
			totems = false,
		},
		friendly = {
			guardians = false,
			minions = false,
			npcs = true,
			pets = false,
			totems = false,
		},
	},
	units = {
		TARGET = {
			enable = true,
			glowStyle = "style2",
			arrow = "Arrow9",
			arrowSize = 20,
			arrowXOffset = 3,
			arrowYOffset = 0,
			comboPoints = {
				enable = true,
				width = 8,
				height = 4,
				spacing = 5,
				xOffset = 0,
				yOffset = 0
			},
		},
		FRIENDLY_PLAYER = {
			health = {
				enable = false,
				height = 10,
				width = 150,
				glowStyle = "TARGET_THREAT",
				text = {
					enable = false,
					format = "CURRENT",
					position = "CENTER",
					parent = "Health",
					xOffset = 0,
					yOffset = 0,
					font = "PT Sans Narrow",
					fontOutline = "OUTLINE",
					fontSize = 11,
				},
				useClassColor = true,
			},
			name = {
				enable = true,
				useClassColor = true,
				abbrev = false,
				position = "TOPLEFT",
				parent = "Health",
				xOffset = 0,
				yOffset = 2,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			level = {
				enable = false,
				position = "TOPRIGHT",
				parent = "Health",
				xOffset = 0,
				yOffset = 2,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			castbar = {
				enable = true,
				width = 150,
				height = 8,
				hideSpellName = false,
				hideTime = false,
				textPosition = "BELOW",
				castTimeFormat = "CURRENT",
				channelTimeFormat = "CURRENT",
				timeToHold = 0,
				iconPosition = "RIGHT",
				iconSize = 20,
				iconOffsetX = 2,
				iconOffsetY = 0,
				showIcon = true,
				xOffset = 0,
				yOffset = -2,
				font = "PT Sans Narrow",
				fontSize = 11,
				fontOutline = "OUTLINE"
			},
			buffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				growthX = "RIGHT",
				growthY = "UP",
				spacing = 1,
				yOffset = 20,
				xOffset = 0,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,Personal,TurtleBuffs" --NamePlate FriendlyPlayer Buffs
				},
			},
			debuffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 1,
				xOffset = 0,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				growthX = "LEFT",
				growthY = "UP",
				onlyShowPlayer = false,
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,Personal,CCDebuffs" --NamePlate FriendlyPlayer Debuffs
				},
			},
			raidTargetIndicator = {
				size = 24,
				position = "LEFT",
				xOffset = -4,
				yOffset = 0
			}
		},
		ENEMY_PLAYER = {
			markHealers = true,
			health = {
				enable = true,
				height = 10,
				width = 150,
				glowStyle = "TARGET_THREAT",
				text = {
					enable = false,
					format = "CURRENT",
					position = "CENTER",
					parent = "Health",
					xOffset = 0,
					yOffset = 0,
					font = "PT Sans Narrow",
					fontOutline = "OUTLINE",
					fontSize = 11
				},
				useClassColor = true
			},
			name = {
				enable = true,
				useClassColor = true,
				abbrev = false,
				position = "TOPLEFT",
				parent = "Health",
				xOffset = 0,
				yOffset = 2,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			level = {
				enable = true,
				position = "TOPRIGHT",
				parent = "Health",
				xOffset = 0,
				yOffset = 2,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			castbar = {
				enable = true,
				width = 150,
				height = 8,
				hideSpellName = false,
				hideTime = false,
				textPosition = "BELOW",
				castTimeFormat = "CURRENT",
				channelTimeFormat = "CURRENT",
				timeToHold = 0,
				iconPosition = "RIGHT",
				iconSize = 20,
				iconOffsetX = 2,
				iconOffsetY = 0,
				showIcon = true,
				xOffset = 0,
				yOffset = -2,
				font = "PT Sans Narrow",
				fontSize = 11,
				fontOutline = "OUTLINE"
			},
			comboPoints = {
				enable = true,
				width = 8,
				height = 4,
				spacing = 5,
				xOffset = 0,
				yOffset = 0
			},
			buffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 20,
				xOffset = 0,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				growthX = "RIGHT",
				growthY = "UP",
				onlyShowPlayer = false,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				spacing = 1,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 300,
					priority = "Blacklist,PlayerBuffs,TurtleBuffs" --NamePlate EnemyPlayer Buffs
				},
			},
			debuffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 1,
				xOffset = 0,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				growthX = "LEFT",
				growthY = "UP",
				onlyShowPlayer = false,
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,Personal,CCDebuffs,RaidDebuffs" --NamePlate EnemyPlayer Debuffs
				},
			},
			raidTargetIndicator = {
				size = 24,
				position = "LEFT",
				xOffset = -4,
				yOffset = 0
			},
		},
		FRIENDLY_NPC = {
			health = {
				enable = false,
				height = 10,
				width = 150,
				glowStyle = "TARGET_THREAT",
				text = {
					enable = false,
					format = "CURRENT",
					position = "CENTER",
					parent = "Health",
					xOffset = 0,
					yOffset = 0,
					font = "PT Sans Narrow",
					fontOutline = "OUTLINE",
					fontSize = 11
				}
			},
			name = {
				enable = true,
				abbrev = false,
				position = "TOPLEFT",
				parent = "Health",
				xOffset = 0,
				yOffset = 2,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			level = {
				enable = true,
				position = "TOPRIGHT",
				parent = "Health",
				xOffset = 0,
				yOffset = 2,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			castbar = {
				enable = true,
				width = 150,
				height = 8,
				hideSpellName = false,
				hideTime = false,
				textPosition = "BELOW",
				castTimeFormat = "CURRENT",
				channelTimeFormat = "CURRENT",
				timeToHold = 0,
				iconPosition = "RIGHT",
				iconSize = 20,
				iconOffsetX = 2,
				iconOffsetY = 0,
				showIcon = true,
				xOffset = 0,
				yOffset = -2,
				font = "PT Sans Narrow",
				fontSize = 11,
				fontOutline = "OUTLINE"
			},
			buffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 20,
				xOffset = 0,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				growthX = "RIGHT",
				growthY = "UP",
				onlyShowPlayer = false,
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,Personal,TurtleBuffs" --NamePlate FriendlyNPC Buffs
				},
			},
			debuffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 1,
				xOffset = 0,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				growthX = "LEFT",
				growthY = "UP",
				onlyShowPlayer = false,
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,CCDebuffs,RaidDebuffs" --NamePlate FriendlyNPC Debuffs
				},
			},
			eliteIcon = {
				enable = false,
				size = 15,
				position = "RIGHT",
				xOffset = 10,
				yOffset = 0
			},
			raidTargetIndicator = {
				size = 24,
				position = "LEFT",
				xOffset = -4,
				yOffset = 0
			},
			iconFrame = {
				enable = false,
				size = 24,
				parent = "Nameplate",
				position = "CENTER",
				xOffset = 0,
				yOffset = 42
			}
		},
		ENEMY_NPC = {
			health = {
				enable = true,
				height = 10,
				width = 150,
				glowStyle = "TARGET_THREAT",
				text = {
					enable = false,
					format = "CURRENT",
					position = "CENTER",
					parent = "Health",
					xOffset = 0,
					yOffset = 0,
					font = "PT Sans Narrow",
					fontOutline = "OUTLINE",
					fontSize = 11
				}
			},
			name = {
				enable = true,
				abbrev = false,
				position = "TOPLEFT",
				parent = "Health",
				xOffset = 0,
				yOffset = 2,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			level = {
				enable = true,
				position = "TOPRIGHT",
				parent = "Health",
				xOffset = 0,
				yOffset = 2,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			castbar = {
				enable = true,
				width = 150,
				height = 8,
				hideSpellName = false,
				hideTime = false,
				textPosition = "BELOW",
				castTimeFormat = "CURRENT",
				channelTimeFormat = "CURRENT",
				timeToHold = 0,
				iconPosition = "RIGHT",
				iconSize = 20,
				iconOffsetX = 2,
				iconOffsetY = 0,
				showIcon = true,
				xOffset = 0,
				yOffset = -2,
				font = "PT Sans Narrow",
				fontSize = 11,
				fontOutline = "OUTLINE"
			},
			comboPoints = {
				enable = true,
				width = 8,
				height = 4,
				spacing = 5,
				xOffset = 0,
				yOffset = 0
			},
			buffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 20,
				xOffset = 0,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				growthX = "RIGHT",
				growthY = "UP",
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,PlayerBuffs,TurtleBuffs" --NamePlate EnemyNPC Buffs
				},
			},
			debuffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 1,
				xOffset = 0,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				growthX = "LEFT",
				growthY = "UP",
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,Personal,CCDebuffs" --NamePlate EnemyNPC Debuffs
				},
			},
			eliteIcon = {
				enable = false,
				size = 15,
				position = "RIGHT",
				xOffset = 10,
				yOffset = 0
			},
			raidTargetIndicator = {
				size = 24,
				position = "LEFT",
				xOffset = -4,
				yOffset = 0
			},
			iconFrame = {
				enable = false,
				size = 24,
				parent = "Nameplate",
				position = "CENTER",
				xOffset = 0,
				yOffset = 42
			}
		}
	}
}

local TopAuras = {
	barColor = { r = 0, g = .8, b = 0 },
	barColorGradient = false,
	barSize = 2,
	barNoDuration = true,
	barPosition = 'BOTTOM',
	barShow = false,
	barSpacing = 2,
	barTexture = 'ElvUI Norm',
	countFont = 'Homespun',
	countFontOutline = 'MONOCHROMEOUTLINE',
	countFontSize = 10,
	countXOffset = 0,
	countYOffset = 0,
	timeFont = 'Homespun',
	timeFontOutline = 'MONOCHROMEOUTLINE',
	timeFontSize = 10,
	timeXOffset = 0,
	timeYOffset = 0,
	fadeThreshold = 6,
	growthDirection = 'LEFT_DOWN',
	horizontalSpacing = 6,
	maxWraps = 3,
	seperateOwn = 1,
	showDuration = true,
	size = 32,
	height = 32,
	keepSizeRatio = true,
	sortDir = '-',
	sortMethod = 'TIME',
	verticalSpacing = 16,
	wrapAfter = 12,
	smoothbars = false,
}

--Auras
P.auras = {
	buffs = CopyTable(TopAuras),
	debuffs = CopyTable(TopAuras),
	colorEnchants = true,
	colorDebuffs = true,
}

P.auras.debuffs.maxWraps = 1

--Chat
P.chat = {
	url = true,
	panelSnapLeftID = nil, -- set by the snap code
	panelSnapRightID = nil, -- same deal
	panelSnapping = true,
	shortChannels = true,
	hyperlinkHover = true,
	throttleInterval = 45,
	scrollDownInterval = 15,
	fade = true,
	inactivityTimer = 100,
	font = "PT Sans Narrow",
	fontOutline = "SHADOW",
	fontSize = 10,
	sticky = true,
	emotionIcons = true,
	keywordSound = "None",
	noAlertInCombat = false,
	flashClientIcon = true,
	chatHistory = true,
	lfgIcons = true,
	maxLines = 100,
	channelAlerts = {
		CHANNEL = {},
		GUILD = "None",
		OFFICER = "None",
		INSTANCE = "None",
		PARTY = "None",
		RAID = "None",
		WHISPER = "Whisper Alert",
	},
	showHistory = {
		WHISPER = true,
		GUILD = true,
		PARTY = true,
		RAID = true,
		INSTANCE = true,
		CHANNEL = true,
		SAY = true,
		YELL = true,
		EMOTE = true
	},
	historySize = 100,
	editboxHistorySize = 20,
	tabSelector = "ARROW1",
	tabSelectedTextEnabled = true,
	tabSelectedTextColor = { r = 1, g = 1, b = 1 },
	tabSelectorColor = { r = .3, g = 1, b = .3 },
	timeStampFormat = "NONE",
	timeStampLocalTime = false,
	keywords = "ElvUI",
	separateSizes = false,
	panelWidth = 412,
	panelHeight = 180,
	panelWidthRight = 412,
	panelHeightRight = 180,
	panelBackdropNameLeft = "",
	panelBackdropNameRight = "",
	panelBackdrop = "SHOWBOTH",
	panelTabBackdrop = false,
	panelTabTransparency = false,
	LeftChatDataPanelAnchor = "BELOW_CHAT",
	RightChatDataPanelAnchor = "BELOW_CHAT",
	editBoxPosition = "BELOW_CHAT",
	fadeUndockedTabs = false,
	fadeTabsNoBackdrop = true,
	fadeChatToggles = true,
	hideChatToggles = false,
	hideCopyButton = false,
	useAltKey = false,
	classColorMentionsChat = true,
	enableCombatRepeat = true,
	numAllowedCombatRepeat = 5,
	useCustomTimeColor = true,
	customTimeColor = {r = 0.7, g = 0.7, b = 0.7},
	numScrollMessages = 3,
	socialQueueMessages = false,
	tabFont = "PT Sans Narrow",
	tabFontSize = 12,
	tabFontOutline = "SHADOW",
	copyChatLines = false,
	panelColor = {r = .06, g = .06, b = .06, a = 0.8},
	pinVoiceButtons = true,
	hideVoiceButtons = false,
	desaturateVoiceIcons = true,
	mouseoverVoicePanel = false,
	voicePanelAlpha = 0.25
}

--Datatexts
P.datatexts = {
	font = "PT Sans Narrow",
	fontSize = 12,
	fontOutline = "SHADOW",
	wordWrap = false,
	panels = {
		LeftChatDataPanel = {
			enable = true,
			battleground = true,
			backdrop = true,
			border = true,
			panelTransparency = false,
			"ElvUI",
			"Durability",
			"Mail"
		},
		RightChatDataPanel = {
			enable = true,
			battleground = true,
			backdrop = true,
			border = true,
			panelTransparency = false,
			"System",
			"Time",
			"Gold"
		},
		MinimapPanel = {
			enable = true,
			battleground = false,
			backdrop = true,
			border = true,
			panelTransparency = false,
			numPoints = 2,
			"Guild",
			"Friends"
		}
	},
	battlePanel = {
		LeftChatDataPanel = {
			"PvP: Kills",
			"PvP: Honorable Kills",
			"PvP: Deaths",
		},
		RightChatDataPanel = {
			"PvP: Damage Done",
			"PvP: Heals",
			"PvP: Honor Gained",
		},
		MinimapPanel = {}
	},
	noCombatClick = false,
	noCombatHover = false,
}

--Tooltip
P.tooltip = {
	showElvUIUsers = false,
	cursorAnchor = false,
	cursorAnchorType = "ANCHOR_CURSOR",
	cursorAnchorX = 0,
	cursorAnchorY = 0,
	inspectDataEnable = true,
	alwaysShowRealm = false,
	targetInfo = true,
	playerTitles = true,
	guildRanks = true,
	itemQuality = false,
	modifierCount = true,
	modifierID = "SHOW",
	role = true,
	gender = false,
	font = "PT Sans Narrow",
	fontOutline = "SHADOW",
	textFontSize = 12, -- is fontSize (has old name)
	headerFont = "PT Sans Narrow",
	headerFontOutline = "SHADOW",
	headerFontSize = 13,
	smallTextFontSize = 12,
	colorAlpha = 0.8,
	fadeOut = true,
	itemCount = {
		bags = true,
		stack = false
	},
	visibility = {
		bags = "SHOW",
		unitFrames = "SHOW",
		actionbars = "SHOW",
		combatOverride = "SHOW",
	},
	healthBar = {
		text = true,
		height = 12,
		font = "PT Sans Narrow",
		fontSize = 12,
		fontOutline = "SHADOW",
		statusPosition = "BOTTOM",
	},
	useCustomFactionColors = false,
	factionColors = {
		{r = 0.8, g = 0.3, b = 0.22},
		{r = 0.8, g = 0.3, b = 0.22},
		{r = 0.75, g = 0.27, b = 0},
		{r = 0.9, g = 0.7, b = 0},
		{r = 0, g = 0.6, b = 0.1},
		{r = 0, g = 0.6, b = 0.1},
		{r = 0, g = 0.6, b = 0.1},
		{r = 0, g = 0.6, b = 0.1},
	}
}

--UnitFrame
P.unitframe = {
	smoothbars = false,
	statusbar = "ElvUI Norm",
	font = "Homespun",
	fontSize = 10,
	fontOutline = "MONOCHROMEOUTLINE",
	debuffHighlighting = "FILL",
	targetOnMouseDown = false,
	smartRaidFilter = true,
	auraBlacklistModifier = "SHIFT",
	thinBorders = false,
	cooldown = {
		override = true,
		reverse = false,
		threshold = 3,
		expiringColor = {r = 1, g = 0, b = 0},
		secondsColor = {r = 1, g = 1, b = 1},
		minutesColor = {r = 1, g = 1, b = 1},
		hoursColor = {r = 1, g = 1, b = 1},
		daysColor = {r = 1, g = 1, b = 1},
		expireIndicator = {r = 1, g = 1, b = 1},
		secondsIndicator = {r = 1, g = 1, b = 1},
		minutesIndicator = {r = 1, g = 1, b = 1},
		hoursIndicator = {r = 1, g = 1, b = 1},
		daysIndicator = {r = 1, g = 1, b = 1},
		hhmmColorIndicator = {r = 1, g = 1, b = 1},
		mmssColorIndicator = {r = 1, g = 1, b = 1},

		checkSeconds = false,
		targetAuraDuration = 3600,
		modRateColor = { r = 0.6, g = 1, b = 0.4 },
		hhmmColor = {r = 0.43, g = 0.43, b = 0.43},
		mmssColor = {r = 0.56, g = 0.56, b = 0.56},
		hhmmThreshold = -1,
		mmssThreshold = -1,

		fonts = {
			enable = false,
			font = "PT Sans Narrow",
			fontOutline = "OUTLINE",
			fontSize = 18
		}
	},
	colors = {
		borderColor = {r = 0, g = 0, b = 0},
		healthclass = false,
		forcehealthreaction = false,
		powerclass = false,
		colorhealthbyvalue = true,
		customhealthbackdrop = false,
		custompowerbackdrop = false,
		customcastbarbackdrop = false,
		customaurabarbackdrop = false,
		customclasspowerbackdrop = false,
		useDeadBackdrop = false,
		classbackdrop = false,
		healthMultiplier = 0,
		auraBarByType = true,
		auraBarTurtle = true,
		auraBarTurtleColor = {r = 0.56, g = 0.39, b = 0.61},
		transparentHealth = false,
		transparentPower = false,
		transparentCastbar = false,
		transparentAurabars = false,
		transparentClasspower = false,
		invertCastBar = false,
		invertAurabars = false,
		invertPower = false,
		invertClasspower = false,
		castColor = {r = 0.31, g = 0.31, b = 0.31},
		castNoInterrupt = {r = 0.78, g = 0.25, b = 0.25},
		castInterruptedColor = {r = 0.30, g = 0.30, b = 0.30},
		castClassColor = false,
		castReactionColor = false,
		health = {r = 0.31, g = 0.31, b = 0.31},
		health_backdrop = {r = 0.8, g = 0.01, b = 0.01},
		health_backdrop_dead = {r = 0.8, g = 0.01, b = 0.01},
		castbar_backdrop = {r = 0.5, g = 0.5, b = 0.5},
		classpower_backdrop = {r = 0.5, g = 0.5, b = 0.5},
		aurabar_backdrop = {r = 0.5, g = 0.5, b = 0.5},
		power_backdrop = {r = 0.5, g = 0.5, b = 0.5},
		tapped = {r = 0.55, g = 0.57, b = 0.61},
		disconnected = {r = 0.84, g = 0.75, b = 0.65},
		auraBarBuff = {r = 0.31, g = 0.31, b = 0.31},
		auraBarDebuff = {r = 0.8, g = 0.1, b = 0.1},
		power = {
			MANA = {r = 0.31, g = 0.45, b = 0.63},
			RAGE = {r = 0.78, g = 0.25, b = 0.25},
			FOCUS = {r = 0.71, g = 0.43, b = 0.27},
			ENERGY = {r = 0.65, g = 0.63, b = 0.35},
			RUNIC_POWER = {r = 0, g = 0.82, b = 1}
		},
		happiness = {
			{r = .69, g = .31, b = .31},
			{r = .65, g = .63, b = .35},
			{r = .33, g = .59, b = .33},
		},
		reaction = {
			BAD = { r = 0.78, g = 0.25, b = 0.25 },
			NEUTRAL = { r = 0.85, g = 0.77, b = 0.36 },
			GOOD = { r = 0.29, g = 0.69, b = 0.30 },
		},
		threat = {
			[ 0] = {r = 0.5, g = 0.5, b = 0.5}, -- low
			[ 1] = {r = 1.0, g = 1.0, b = 0.5}, -- overnuking
			[ 2] = {r = 1.0, g = 0.5, b = 0.0}, -- losing threat
			[ 3] = {r = 1.0, g = 0.2, b = 0.2}, -- tanking securely
		},
		selection = {
			[ 0] = {r = 1.00, g = 0.18, b = 0.18}, -- HOSTILE
			[ 1] = {r = 1.00, g = 0.51, b = 0.20}, -- UNFRIENDLY
			[ 2] = {r = 1.00, g = 0.85, b = 0.20}, -- NEUTRAL
			[ 3] = {r = 0.20, g = 0.71, b = 0.00}, -- FRIENDLY
			[ 5] = {r = 0.40, g = 0.53, b = 1.00}, -- PLAYER_EXTENDED
			[ 6] = {r = 0.40, g = 0.20, b = 1.00}, -- PARTY
			[ 7] = {r = 0.73, g = 0.20, b = 1.00}, -- PARTY_PVP
			[ 8] = {r = 0.20, g = 1.00, b = 0.42}, -- FRIEND
			[ 9] = {r = 0.60, g = 0.60, b = 0.60}, -- DEAD
			[13] = {r = 0.10, g = 0.58, b = 0.28}, -- BATTLEGROUND_FRIENDLY_PVP
		},
		healPrediction = {
			personal = {r = 0, g = 1, b = 0.5, a = 0.25},
			others = {r = 0, g = 1, b = 0, a = 0.25},
			absorbs = {r = 1, g = 1, b = 0, a = 0.25},
			healAbsorbs = {r = 1, g = 0, b = 0, a = 0.25},
			overabsorbs = {r = 1, g = 1, b = 0, a = 0.25},
			overhealabsorbs = {r = 1, g = 0, b = 0, a = 0.25},
			maxOverflow = 0,
		},
		classResources = {
			comboPoints = {
				[1] = {r = 0.69, g = 0.31, b = 0.31},
				[2] = {r = 0.69, g = 0.31, b = 0.31},
				[3] = {r = 0.65, g = 0.63, b = 0.35},
				[4] = {r = 0.65, g = 0.63, b = 0.35},
				[5] = {r = 0.33, g = 0.59, b = 0.33}
			},
			DEATHKNIGHT = {
				[1] = {r = 1, g = 0, b = 0},
				[2] = {r = 0, g = 1, b = 0},
				[3] = {r = 0, g = 1, b = 1},
				[4] = {r = 0.9, g = 0.1, b = 1}
			}
		},
		frameGlow = {
			mainGlow = {
				enable = false,
				class = false,
				color = {r = 1, g = 1, b = 1, a = 1}
			},
			targetGlow = {
				enable = true,
				class = true,
				color = {r = 1, g = 1, b = 1, a = 1}
			},
			mouseoverGlow = {
				enable = true,
				class = false,
				texture = "ElvUI Blank",
				color = {r = 1, g = 1, b = 1, a = 0.1}
			}
		},
		debuffHighlight = {
			Magic = {r = 0.2, g = 0.6, b = 1, a = 0.45},
			Curse = {r = 0.6, g = 0, b = 1, a = 0.45},
			Disease = {r = 0.6, g = 0.4, b = 0, a = 0.45},
			Poison = {r = 0, g = 0.6, b = 0, a = 0.45},
			blendMode = "ADD"
		}
	},
	units = {
		player = {
			enable = true,
			orientation = "LEFT",
			width = 270,
			height = 54,
			lowmana = 30,
			healPrediction = {
				enable = true
			},
			threatStyle = "GLOW",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			health = {
				text_format = "[healthcolor][health:current-percent]",
				position = "LEFT",
				xOffset = 2,
				yOffset = 0,
				attachTextTo = "Health"
			},
			fader = {
				enable = false,
				--range = true, [player doesn't get this option]
				hover = true,
				combat = true,
				playertarget = true,
				--unittarget = false, [player doesn't get this option]
				focus = false,
				health = true,
				power = true,
				vehicle = true,
				casting = true,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "[powercolor][power:current]",
				width = "fill",
				height = 10,
				offset = 0,
				position = "RIGHT",
				hideonnpc = false,
				xOffset = -2,
				yOffset = 0,
				attachTextTo = "Health",
				detachFromFrame = false,
				detachedWidth = 250,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 20,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "",
				xOffset = 0,
				yOffset = 0,
				attachTextTo = "Health"
			},
			pvp = {
				position = "BOTTOM",
				text_format = "||cFFB04F4F[pvptimer][mouseover]||r",
				xOffset = 0,
				yOffset = 0
			},
			RestIcon = {
				enable = true,
				defaultColor = true,
				color = {r = 1, g = 1, b = 1, a = 1},
				anchorPoint = "TOPLEFT",
				xOffset = -3,
				yOffset = 6,
				size = 22,
				texture = "DEFAULT"
			},
			raidRoleIcons = {
				enable = true,
				position = "TOPLEFT"
			},
			CombatIcon = {
				enable = true,
				defaultColor = true,
				color = {r = 1, g = 0.2, b = 0.2, a = 1},
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				size = 20,
				texture = "DEFAULT"
			},
			pvpIcon = {
				enable = false,
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				scale = 1
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 8,
				numrows = 1,
				attachTo = "DEBUFFS",
				anchorPoint = "TOPLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,PlayerBuffs,Whitelist,blockNoDuration,nonPersonal", --Player Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = true,
				perrow = 8,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,nonPersonal", --Player Debuffs
				xOffset = 0,
				yOffset = 0
			},
			castbar = {
				enable = true,
				width = 270,
				height = 18,
				icon = true,
				latency = true,
				format = "REMAINING",
				ticks = true,
				spark = true,
				displayTarget = false,
				iconSize = 42,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				tickWidth = 1,
				tickColor = {r = 0, g = 0, b = 0, a = 0.8},
				timeToHold = 0,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			classbar = {
				enable = true,
				fill = "fill",
				height = 10,
				autoHide = false,
				additionalPowerText = true,
				detachFromFrame = false,
				detachedWidth = 250,
				parent = "FRAME",
				verticalOrientation = false,
				orientation = "HORIZONTAL",
				spacing = 5,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			aurabar = {
				enable = true,
				anchorPoint = "ABOVE",
				attachTo = "DEBUFFS",
				maxBars = 6,
				minDuration = 0,
				maxDuration = 120,
				priority = "Blacklist,blockNoDuration,Personal,RaidDebuffs,PlayerBuffs", --Player AuraBars
				friendlyAuraType = "HELPFUL",
				enemyAuraType = "HARMFUL",
				height = 20,
				sort = "TIME_REMAINING",
				uniformThreshold = 0,
				yOffset = 0,
				spacing = 0
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		target = {
			enable = true,
			width = 270,
			height = 54,
			orientation = "RIGHT",
			threatStyle = "GLOW",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			healPrediction = {
				enable = true
			},
			middleClickFocus = true,
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			health = {
				text_format = "[healthcolor][health:current-percent]",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0,
				attachTextTo = "Health"
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "[powercolor][power:current]",
				width = "fill",
				height = 10,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0,
				detachFromFrame = false,
				detachedWidth = 250,
				attachTextTo = "Health",
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 20,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium] [difficultycolor][smartlevel] [shortclassification]",
				xOffset = 0,
				yOffset = 0,
				attachTextTo = "Health"
			},
			pvpIcon = {
				enable = false,
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				scale = 1
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = true,
				perrow = 8,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,nonPersonal", --Target Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = true,
				perrow = 8,
				numrows = 1,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs,CCDebuffs,Friendly:Dispellable", --Target Debuffs
				xOffset = 0,
				yOffset = 0
			},
			castbar = {
				enable = true,
				width = 270,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				iconSize = 42,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			combobar = {
				enable = true,
				fill = "fill",
				height = 10,
				autoHide = true,
				detachFromFrame = false,
				detachedWidth = 250,
				parent = "FRAME",
				orientation = "HORIZONTAL",
				spacing = 5,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			aurabar = {
				enable = true,
				anchorPoint = "ABOVE",
				attachTo = "DEBUFFS",
				maxBars = 6,
				minDuration = 0,
				maxDuration = 120,
				priority = "Blacklist,Personal,blockNoDuration,PlayerBuffs,RaidDebuffs", --Target AuraBars
				friendlyAuraType = "HELPFUL",
				enemyAuraType = "HARMFUL",
				height = 20,
				sort = "TIME_REMAINING",
				uniformThreshold = 0,
				yOffset = 0,
				spacing = 0
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = false,
				size = 45,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		targettarget = {
			enable = true,
			threatStyle = "NONE",
			orientation = "MIDDLE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 130,
			height = 36,
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			health = {
				text_format = "",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0
			},
			infoPanel = {
				enable = false,
				height = 14,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				xOffset = 0,
				yOffset = 0,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,PlayerBuffs,Dispellable", --TargetTarget Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = true,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs,CCDebuffs,Dispellable,Whitelist", --TargetTarget Debuffs
				xOffset = 0,
				yOffset = 0
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		targettargettarget = {
			enable = false,
			orientation = "MIDDLE",
			threatStyle = "NONE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 130,
			height = 36,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				xOffset = 0,
				yOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,nonPersonal", --TargetTargetTarget Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = true,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,nonPersonal", --TargetTargetTarget Debuffs
				xOffset = 0,
				yOffset = 0
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		focus = {
			enable = true,
			threatStyle = "GLOW",
			orientation = "MIDDLE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 190,
			height = 36,
			healPrediction = {
				enable = true
			},
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0,
				attachTextTo = "Health",
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0,
				attachTextTo = "Health"
			},
			infoPanel = {
				enable = false,
				height = 14,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				xOffset = 0,
				yOffset = 0,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,PlayerBuffs,CastByUnit,Dispellable", --Focus Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = true,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs,Dispellable,Whitelist", --Focus Debuffs
				xOffset = 0,
				yOffset = 0
			},
			castbar = {
				enable = true,
				width = 190,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				iconSize = 32,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			aurabar = {
				enable = false,
				anchorPoint = "ABOVE",
				attachTo = "DEBUFFS",
				maxBars = 3,
				minDuration = 0,
				maxDuration = 120,
				priority = "Blacklist,blockNoDuration,Personal,PlayerBuffs,RaidDebuffs", --Focus AuraBars
				friendlyAuraType = "HELPFUL",
				enemyAuraType = "HARMFUL",
				height = 20,
				sort = "TIME_REMAINING",
				uniformThreshold = 0,
				yOffset = 0,
				spacing = 0
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = true,
				size = 45,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		focustarget = {
			enable = false,
			threatStyle = "NONE",
			orientation = "MIDDLE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 190,
			height = 26,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0,
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = false,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,PlayerBuffs,Dispellable,CastByUnit", --FocusTarget Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = false,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs,Dispellable,Whitelist", --FocusTarget Debuffs
				xOffset = 0,
				yOffset = 0
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		pet = {
			enable = true,
			orientation = "MIDDLE",
			threatStyle = "GLOW",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 130,
			height = 36,
			healPrediction = {
				enable = true
			},
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			health = {
				text_format = "",
				position = "RIGHT",
				yOffset = 0,
				xOffset = -2,
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				yOffset = 0,
				xOffset = 2
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			happiness = {
				enable = false,
				autoHide = false,
				width = 10
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,PlayerBuffs", --Pet Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = false,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,RaidDebuffs,Dispellable,Whitelist", --Pet Debuffs
				xOffset = 0,
				yOffset = 0
			},
			aurabar = {
				enable = false,
				anchorPoint = "ABOVE",
				attachTo = "FRAME",
				maxBars = 6,
				minDuration = 0,
				maxDuration = 120,
				priority = "",
				friendlyAuraType = "HELPFUL",
				enemyAuraType = "HARMFUL",
				height = 20,
				sort = "TIME_REMAINING",
				uniformThreshold = 0,
				yOffset = 2,
				spacing = 2
			},
			buffIndicator = {
				enable = true,
				size = 8,
				fontSize = 10
			},
			castbar = {
				enable = true,
				width = 130,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				iconSize = 26,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		pettarget = {
			enable = false,
			threatStyle = "NONE",
			orientation = "MIDDLE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 130,
			height = 26,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "",
				position = "RIGHT",
				yOffset = 0,
				xOffset = -2,
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = false,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				yOffset = 0,
				xOffset = 2
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,PlayerBuffs,CastByUnit,Whitelist", --PetTarget Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = false,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs", --PetTarget Debuffs
				xOffset = 0,
				yOffset = 0
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		boss = {
			enable = true,
			growthDirection = "DOWN",
			orientation = "RIGHT",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 216,
			height = 46,
			spacing = 25,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "[healthcolor][health:current]",
				position = "LEFT",
				yOffset = 0,
				xOffset = 2,
				attachTextTo = "Health",
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "[powercolor][power:current]",
				width = "fill",
				height = 7,
				offset = 0,
				position = "RIGHT",
				hideonnpc = false,
				yOffset = 0,
				xOffset = -2,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 35,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			infoPanel = {
				enable = false,
				height = 16,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			buffs = {
				enable = true,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,CastByUnit,Whitelist", --Boss Buffs
				xOffset = 0,
				yOffset = 20,
				sizeOverride = 22
			},
			debuffs = {
				enable = true,
				perrow = 3,
				numrows = 2,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,RaidDebuffs,CastByUnit,Whitelist", --Boss Debuffs
				xOffset = 0,
				yOffset = -3,
				sizeOverride = 22
			},
			castbar = {
				enable = true,
				width = 215,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				iconSize = 32,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		arena = {
			enable = true,
			growthDirection = "DOWN",
			orientation = "RIGHT",
			smartAuraPosition = "DISABLED",
			spacing = 25,
			width = 246,
			height = 47,
			healPrediction = {
				enable = true
			},
			colorOverride = "USE_DEFAULT",
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "[healthcolor][health:current]",
				position = "LEFT",
				yOffset = 0,
				xOffset = 2,
				attachTextTo = "Health",
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "[powercolor][power:current]",
				width = "fill",
				height = 7,
				offset = 0,
				attachTextTo = "Health",
				position = "RIGHT",
				hideonnpc = false,
				yOffset = 0,
				xOffset = -2
			},
			infoPanel = {
				enable = false,
				height = 17,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = true,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,TurtleBuffs,PlayerBuffs,Dispellable", --Arena Buffs
				sizeOverride = 27,
				xOffset = 0,
				yOffset = 16
			},
			debuffs = {
				enable = true,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,blockNoDuration,Personal,CCDebuffs,Whitelist", --Arena Debuffs
				sizeOverride = 27,
				xOffset = 0,
				yOffset = -16
			},
			castbar = {
				enable = true,
				width = 256,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				iconSize = 32,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			pvpTrinket = {
				enable = true,
				position = "RIGHT",
				size = 46,
				xOffset = 1,
				yOffset = 0
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		party = {
			enable = true,
			threatStyle = "GLOW",
			orientation = "LEFT",
			visibility = "[@raid6,exists][nogroup] hide;show",
			growthDirection = "UP_RIGHT",
			horizontalSpacing = 0,
			verticalSpacing = 3,
			numGroups = 1,
			groupsPerRowCol = 1,
			groupBy = "GROUP",
			sortDir = "ASC",
			raidWideSorting = false,
			invertGroupingOrder = false,
			startFromCenter = false,
			showPlayer = true,
			healPrediction = {
				enable = false
			},
			colorOverride = "USE_DEFAULT",
			width = 184,
			height = 54,
			groupSpacing = 0,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "[healthcolor][health:current-percent]",
				position = "LEFT",
				orientation = "HORIZONTAL",
				attachTextTo = "Health",
				frequentUpdates = false,
				yOffset = 0,
				xOffset = 2,
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "[powercolor][power:current]",
				attachTextTo = "Health",
				width = "fill",
				height = 7,
				offset = 0,
				position = "RIGHT",
				hideonnpc = false,
				yOffset = 0,
				xOffset = -2
			},
			infoPanel = {
				enable = false,
				height = 15,
				transparent = false
			},
			name = {
				position = "CENTER",
				attachTextTo = "Health",
				text_format = "[namecolor][name:medium] [difficultycolor][smartlevel]",
				yOffset = 0,
				xOffset = 0,
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 4,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,TurtleBuffs", --Party Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = true,
				perrow = 4,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "RIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,RaidDebuffs,CCDebuffs,Dispellable,Whitelist", --Party Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 52
			},
			buffIndicator = {
				enable = true,
				size = 8,
				fontSize = 10,
				profileSpecific = false
			},
			rdebuffs = {
				enable = false,
				showDispellableDebuff = true,
				onlyMatchSpellID = false,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 0,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			castbar = {
				enable = false,
				width = 256,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				iconSize = 32,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			roleIcon = {
				enable = true,
				position = "TOPRIGHT",
				attachTo = "Health",
				xOffset = 0,
				yOffset = 0,
				size = 15,
				tank = true,
				healer = true,
				damager = true,
				combatHide = false
			},
			raidRoleIcons = {
				enable = true,
				position = "TOPLEFT"
			},
			petsGroup = {
				enable = false,
				width = 100,
				height = 22,
				anchorPoint = "TOPLEFT",
				xOffset = -1,
				yOffset = 0,
				name = {
					position = "CENTER",
					text_format = "[namecolor][name:short]",
					yOffset = 0,
					xOffset = 0
				}
			},
			targetsGroup = {
				enable = false,
				width = 100,
				height = 22,
				anchorPoint = "TOPLEFT",
				xOffset = -1,
				yOffset = 0,
				name = {
					position = "CENTER",
					text_format = "[namecolor][name:short]",
					yOffset = 0,
					xOffset = 0
				},
				raidicon = {
					enable = true,
					size = 18,
					attachTo = "TOP",
					attachToObject = "Frame",
					xOffset = 0,
					yOffset = 8
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = true,
				size = 45,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true
			},
			readycheckIcon = {
				enable = true,
				size = 12,
				attachTo = "Health",
				position = "BOTTOM",
				xOffset = 0,
				yOffset = 2
			},
			resurrectIcon = {
				enable = true,
				size = 30,
				attachTo = "CENTER",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 0
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		raid = {
			enable = true,
			threatStyle = "GLOW",
			orientation = "MIDDLE",
			visibility = "[@raid6,noexists][@raid26,exists] hide;show",
			growthDirection = "RIGHT_DOWN",
			horizontalSpacing = 3,
			verticalSpacing = 3,
			numGroups = 5,
			groupsPerRowCol = 1,
			groupBy = "GROUP",
			sortDir = "ASC",
			showPlayer = true,
			healPrediction = {
				enable = false
			},
			colorOverride = "USE_DEFAULT",
			width = 80,
			height = 44,
			groupSpacing = 0,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "[healthcolor][health:deficit]",
				position = "BOTTOM",
				orientation = "HORIZONTAL",
				attachTextTo = "Health",
				frequentUpdates = false,
				yOffset = 2,
				xOffset = 0,
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "BOTTOMRIGHT",
				hideonnpc = false,
				yOffset = 2,
				xOffset = -2
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				attachTextTo = "Health",
				text_format = "[namecolor][name:short]",
				yOffset = 0,
				xOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,TurtleBuffs", --Raid Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "RIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,RaidDebuffs,CCDebuffs,Dispellable", --Raid Debuffs
				xOffset = 0,
				yOffset = 0
			},
			buffIndicator = {
				enable = true,
				size = 8,
				fontSize = 10,
				profileSpecific = false
			},
			rdebuffs = {
				enable = true,
				showDispellableDebuff = true,
				onlyMatchSpellID = false,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 2,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			roleIcon = {
				enable = false,
				position = "TOPRIGHT",
				attachTo = "Health",
				xOffset = 0,
				yOffset = 0,
				size = 15,
				tank = true,
				healer = true,
				damager = true,
				combatHide = false
			},
			raidRoleIcons = {
				enable = true,
				position = "TOPLEFT"
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = true,
				size = 40,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true
			},
			readycheckIcon = {
				enable = true,
				size = 12,
				attachTo = "Health",
				position = "BOTTOM",
				xOffset = 0,
				yOffset = 2
			},
			resurrectIcon = {
				enable = true,
				size = 30,
				attachTo = "CENTER",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 0
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		raid40 = {
			enable = true,
			threatStyle = "GLOW",
			orientation = "MIDDLE",
			visibility = "[@raid26,noexists] hide;show",
			growthDirection = "RIGHT_DOWN",
			horizontalSpacing = 3,
			verticalSpacing = 3,
			numGroups = 8,
			groupsPerRowCol = 1,
			groupBy = "GROUP",
			sortDir = "ASC",
			showPlayer = true,
			healPrediction = {
				enable = false
			},
			colorOverride = "USE_DEFAULT",
			width = 80,
			height = 27,
			groupSpacing = 0,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "[healthcolor][health:deficit]",
				position = "BOTTOM",
				orientation = "HORIZONTAL",
				frequentUpdates = false,
				attachTextTo = "Health",
				yOffset = 2,
				xOffset = 0,
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = false,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "BOTTOMRIGHT",
				hideonnpc = false,
				yOffset = 2,
				xOffset = -2
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:short]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,TurtleBuffs", --Raid40 Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "RIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,RaidDebuffs,CCDebuffs,Dispellable,Whitelist", --Raid40 Debuffs
				xOffset = 0,
				yOffset = 0
			},
			rdebuffs = {
				enable = false,
				showDispellableDebuff = true,
				onlyMatchSpellID = false,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 22,
				xOffset = 0,
				yOffset = 0,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			raidRoleIcons = {
				enable = true,
				position = "TOPLEFT"
			},
			buffIndicator = {
				enable = true,
				size = 8,
				fontSize = 10,
				profileSpecific = false
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = true,
				size = 45,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true
			},
			readycheckIcon = {
				enable = true,
				size = 12,
				attachTo = "Health",
				position = "BOTTOM",
				xOffset = 0,
				yOffset = 2
			},
			resurrectIcon = {
				enable = true,
				size = 30,
				attachTo = "CENTER",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 0
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		raidpet = {
			enable = false,
			orientation = "MIDDLE",
			threatStyle = "GLOW",
			visibility = "[group:raid] show; hide",
			growthDirection = "DOWN_RIGHT",
			horizontalSpacing = 3,
			verticalSpacing = 3,
			numGroups = 2,
			groupsPerRowCol = 1,
			groupBy = "PETNAME",
			sortDir = "ASC",
			raidWideSorting = true,
			invertGroupingOrder = false,
			startFromCenter = false,
			healPrediction = {
				enable = true
			},
			colorOverride = "USE_DEFAULT",
			width = 80,
			height = 30,
			groupSpacing = 0,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			health = {
				text_format = "[healthcolor][health:deficit]",
				position = "BOTTOM",
				orientation = "HORIZONTAL",
				frequentUpdates = true,
				yOffset = 2,
				xOffset = 0,
				attachTextTo = "Health",
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			name = {
				position = "TOP",
				text_format = "[namecolor][name:short]",
				yOffset = -2,
				xOffset = 0,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				style = "3D",
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,PlayerBuffs,blockNoDuration,nonPersonal", --RaidPet Buffs
				xOffset = 0,
				yOffset = 0
			},
			debuffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "RIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,Whitelist,RaidDebuffs,blockNoDuration,nonPersonal", --RaidPet Debuffs
				xOffset = 0,
				yOffset = 0
			},
			buffIndicator = {
				enable = true,
				size = 8,
				fontSize = 10,
			},
			rdebuffs = {
				enable = true,
				showDispellableDebuff = true,
				onlyMatchSpellID = false,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 2,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		tank = {
			enable = true,
			orientation = "LEFT",
			threatStyle = "GLOW",
			colorOverride = "USE_DEFAULT",
			width = 120,
			height = 28,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableDebuffHighlight = true,
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			buffs = {
				enable = false,
				perrow = 6,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "",
				xOffset = 0,
				yOffset = 2
			},
			debuffs = {
				enable = false,
				perrow = 6,
				numrows = 1,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "",
				xOffset = 0,
				yOffset = 1
			},
			buffIndicator = {
				enable = true,
				size = 8,
				fontSize = 10,
				profileSpecific = false
			},
			rdebuffs = {
				enable = true,
				showDispellableDebuff = true,
				onlyMatchSpellID = false,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 0,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			targetsGroup = {
				enable = true,
				anchorPoint = "RIGHT",
				xOffset = 1,
				yOffset = 0,
				width = 120,
				height = 28,
				colorOverride = "USE_DEFAULT",
				name = {
					position = "CENTER",
					text_format = "[namecolor][name:medium]",
					yOffset = 0,
					xOffset = 0,
					attachTextTo = "Health"
				},
				raidicon = {
					enable = true,
					size = 18,
					attachTo = "TOP",
					attachToObject = "Frame",
					xOffset = 0,
					yOffset = 8
				}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		assist = {
			enable = true,
			orientation = "LEFT",
			threatStyle = "GLOW",
			colorOverride = "USE_DEFAULT",
			width = 120,
			height = 28,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableDebuffHighlight = true,
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			buffs = {
				enable = false,
				perrow = 6,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "",
				xOffset = 0,
				yOffset = 2
			},
			debuffs = {
				enable = false,
				perrow = 6,
				numrows = 1,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "",
				xOffset = 0,
				yOffset = 1
			},
			buffIndicator = {
				enable = true,
				size = 8,
				fontSize = 10,
				profileSpecific = false
			},
			rdebuffs = {
				enable = true,
				showDispellableDebuff = true,
				onlyMatchSpellID = false,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 0,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			targetsGroup = {
				enable = true,
				anchorPoint = "RIGHT",
				xOffset = 1,
				yOffset = 0,
				width = 120,
				height = 28,
				colorOverride = "USE_DEFAULT",
				name = {
					position = "CENTER",
					text_format = "[namecolor][name:medium]",
					yOffset = 0,
					xOffset = 0,
					attachTextTo = "Frame"
				},
				raidicon = {
					enable = true,
					size = 18,
					attachTo = "TOP",
					attachToObject = "Frame",
					xOffset = 0,
					yOffset = 8
				}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		}
	}
}

--Cooldown
P.cooldown = {
	threshold = 3,
	roundTime = true,
	targetAura = true,
	hideBlizzard = false,
	useIndicatorColor = false,
	showModRate = false,

	expiringColor = { r = 1, g = 0.2, b = 0.2 },
	secondsColor = { r = 1, g = 1, b = 0.2 },
	minutesColor = { r = 1, g = 1, b = 1 },
	hoursColor = { r = 0.4, g = 1, b = 1 },
	daysColor = { r = 0.4, g = 0.4, b = 1 },

	expireIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	secondsIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	minutesIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	hoursIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	daysIndicator = { r = 0.8, g = 0.8, b = 0.8 },
	hhmmColorIndicator = { r = 1, g = 1, b = 1 },
	mmssColorIndicator = { r = 1, g = 1, b = 1 },

	checkSeconds = false,
	targetAuraDuration = 3600,
	modRateColor = { r = 0.6, g = 1, b = 0.4 },
	hhmmColor = { r = 0.43, g = 0.43, b = 0.43 },
	mmssColor = { r = 0.56, g = 0.56, b = 0.56 },
	hhmmThreshold = -1,
	mmssThreshold = -1,

	fonts = {
		enable = false,
		font = 'PT Sans Narrow',
		fontOutline = 'OUTLINE',
		fontSize = 18,
	},
}

--Actionbar
local ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS or 10
local STANCE_SLOTS = _G.NUM_STANCE_SLOTS or 10

P.actionbar = {
	colorSwipeNormal = { r = 0, g = 0, b = 0, a = 0.8 },
	hotkeyTextPosition = 'TOPRIGHT',
	macroTextPosition = 'TOPRIGHT',
	countTextPosition = 'BOTTOMRIGHT',
	countTextXOffset = 0,
	countTextYOffset = 2,
	desaturateOnCooldown = false,
	equippedItem = false,
	equippedItemColor = { r = 0.4, g = 1.0, b = 0.4 },
	flashAnimation = false,
	flyoutSize = 32, -- match buttonsize default, blizz default is 28
	font = 'Homespun',
	fontColor = { r = 1, g = 1, b = 1 },
	fontOutline = 'MONOCHROMEOUTLINE',
	fontSize = 10,
	globalFadeAlpha = 0,
	handleOverlay = true,
	keyDown = false,
	lockActionBars = true,
	movementModifier = 'SHIFT',
	noPowerColor = { r = 0.5, g = 0.5, b = 1 },
	noRangeColor = { r = 0.8, g = 0.1, b = 0.1 },
	notUsableColor = { r = 0.4, g = 0.4, b = 0.4 },
	checkSelfCast = true,
	checkFocusCast = true,
	rightClickSelfCast = false,
	transparent = false,
	usableColor = { r = 1, g = 1, b = 1 },
	useRangeColorText = false,
	barPet = {
		enabled = true,
		mouseover = false,
		clickThrough = false,
		buttons = ACTION_SLOTS,
		buttonsPerRow = 1,
		point = 'TOPRIGHT',
		backdrop = true,
		heightMult = 1,
		widthMult = 1,
		keepSizeRatio = true,
		buttonSize = 32,
		buttonHeight = 32,
		buttonSpacing = 2,
		backdropSpacing = 2,
		alpha = 1,
		inheritGlobalFade = false,
		visibility = "[pet,novehicleui,nobonusbar:5] show;hide"
	},
	stanceBar = {
		enabled = true,
		style = 'darkenInactive',
		mouseover = false,
		clickThrough = false,
		buttonsPerRow = STANCE_SLOTS,
		buttons = STANCE_SLOTS,
		point = 'TOPLEFT',
		backdrop = false,
		heightMult = 1,
		widthMult = 1,
		keepSizeRatio = true,
		buttonSize = 32,
		buttonHeight = 32,
		buttonSpacing = 2,
		backdropSpacing = 2,
		alpha = 1,
		inheritGlobalFade = false,
		visibility = "[vehicleui] hide; show"
	},
	totemBar = {
		enable = true,
		alpha = 1,
		spacing = 4,
		keepSizeRatio = true,
		buttonSize = 32,
		buttonHeight = 32,
		flyoutDirection = 'UP',
		flyoutSize = 28,
		flyoutHeight = 28,
		flyoutSpacing = 2,
		font = 'PT Sans Narrow',
		fontOutline = 'OUTLINE',
		fontSize = 12,
		mouseover = false,
		visibility = '[vehicleui] hide;show',
		frameStrata = 'LOW',
		frameLevel = 5,
	},
	microbar = {
		enabled = false,
		mouseover = false,
		useIcons = true,
		buttonsPerRow = 12,
		buttonSize = 20,
		keepSizeRatio = false,
		point = 'TOPLEFT',
		buttonHeight = 28,
		buttonSpacing = 2,
		alpha = 1,
		visibility = 'show',
		backdrop = false,
		backdropSpacing = 2,
		heightMult = 1,
		widthMult = 1,
		frameStrata = 'LOW',
		frameLevel = 1,
	},
	vehicleExitButton = {
		enable = true,
		size = 32,
		level = 1,
		strata = 'MEDIUM',
	}
}

local AB_Bar = {
	enabled = false,
	mouseover = false,
	clickThrough = false,
	keepSizeRatio = true,
	buttons = 12,
	buttonsPerRow = 12,
	point = 'BOTTOMLEFT',
	backdrop = false,
	heightMult = 1,
	widthMult = 1,
	buttonSize = 32,
	buttonHeight = 32,
	buttonSpacing = 2,
	backdropSpacing = 2,
	alpha = 1,
	inheritGlobalFade = false,
	showGrid = true,
	flyoutDirection = 'AUTOMATIC',
	paging = {},
	countColor = { r = 1, g = 1, b = 1 },
	countFont = 'Homespun',
	countFontOutline = 'MONOCHROMEOUTLINE',
	countFontSize = 10,
	countFontXOffset = 0,
	countFontYOffset = 2,
	counttext = true,
	countTextPosition = 'BOTTOMRIGHT',
	hotkeyColor = { r = 1, g = 1, b = 1 },
	hotkeyFont = 'Homespun',
	hotkeyFontOutline = 'MONOCHROMEOUTLINE',
	hotkeyFontSize = 10,
	hotkeytext = true,
	hotkeyTextPosition = 'TOPRIGHT',
	hotkeyTextXOffset = 0,
	hotkeyTextYOffset = -3,
	macroColor = { r = 1, g = 1, b = 1 },
	macrotext = false,
	macroFont = 'Homespun',
	macroFontOutline = 'MONOCHROMEOUTLINE',
	macroFontSize = 10,
	macroTextPosition = 'TOPRIGHT',
	macroTextXOffset = 0,
	macroTextYOffset = -3,
	useCountColor = false,
	useHotkeyColor = false,
	useMacroColor = false,
	frameStrata = 'LOW',
	frameLevel = 1,
}
for i = 1, 10 do
	local barN = 'bar'..i
	P.actionbar[barN] = CopyTable(AB_Bar)

	P.actionbar[barN].visibility = '[vehicleui] hide; show'
end

for _, bar in next, {'barPet', 'stanceBar', 'vehicleExitButton'} do
	local db = P.actionbar[bar]
	db.frameStrata = 'LOW'
	db.frameLevel = 1

	if bar == 'barPet' then
		db.countColor = { r = 1, g = 1, b = 1 }
		db.countFont = 'Homespun'
		db.countFontOutline = 'MONOCHROMEOUTLINE'
		db.countFontSize = 10
		db.countFontXOffset = 0
		db.countFontYOffset = 2
		db.counttext = true
		db.countTextPosition = 'BOTTOMRIGHT'
		db.useCountColor = false
	end
end

P.actionbar.bar1.enabled = true
P.actionbar.bar1.visibility = ''

P.actionbar.bar1.paging.ROGUE = '[bonusbar:1] 7; [bonusbar:2] 8;'
P.actionbar.bar1.paging.WARLOCK = '[form:1] 7;'
P.actionbar.bar1.paging.DRUID = '[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 10; [bonusbar:3] 9; [bonusbar:4] 10;'
P.actionbar.bar1.paging.PRIEST = '[bonusbar:1] 7;'
P.actionbar.bar1.paging.WARRIOR = '[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;'

P.actionbar.bar3.enabled = true
P.actionbar.bar3.buttons = 6
P.actionbar.bar3.buttonsPerRow = 6

P.actionbar.bar4.enabled = true
P.actionbar.bar4.buttonsPerRow = 1
P.actionbar.bar4.point = 'TOPRIGHT'
P.actionbar.bar4.backdrop = true

P.actionbar.bar5.enabled = true
P.actionbar.bar5.buttons = 6
P.actionbar.bar5.buttonsPerRow = 6

do -- cooldown stuff
	P.actionbar.cooldown = CopyTable(P.cooldown)
	P.actionbar.cooldown.expiringColor = { r = 1, g = 0.2, b = 0.2 }
	P.actionbar.cooldown.secondsColor = { r = 1, g = 1, b = 1 }
	P.actionbar.cooldown.hoursColor = { r = 1, g = 1, b = 1 }
	P.actionbar.cooldown.daysColor = { r = 1, g = 1, b = 1 }

	P.actionbar.cooldown.targetAuraColor = { r = 1, g = 0.6, b = 0.1 }
	P.actionbar.cooldown.expiringAuraColor = { r = 1, g = 0.4, b = 0.1 }

	P.actionbar.cooldown.targetAuraIndicator = { r = 0.6, g = 0.6, b = 0.6 }
	P.actionbar.cooldown.expiringAuraIndicator = { r = 0.6, g = 0.6, b = 0.6 }

	P.auras.cooldown = CopyTable(P.actionbar.cooldown)
	P.bags.cooldown = CopyTable(P.actionbar.cooldown)
	P.nameplates.cooldown = CopyTable(P.actionbar.cooldown)
	P.unitframe.cooldown = CopyTable(P.actionbar.cooldown)

	P.WeakAuras = {} -- native cooldown support with our module
	P.WeakAuras.cooldown = CopyTable(P.actionbar.cooldown)
	P.WeakAuras.cooldown.override = false

	-- color override
	P.auras.cooldown.override = false
	P.bags.cooldown.override = false
	P.actionbar.cooldown.override = true
	P.nameplates.cooldown.override = true
	P.unitframe.cooldown.override = true

	-- auras doesn't have a reverse option
	P.actionbar.cooldown.reverse = false
	P.nameplates.cooldown.reverse = false
	P.unitframe.cooldown.reverse = false
	P.bags.cooldown.reverse = false

	-- auras don't have override font settings
	P.auras.cooldown.fonts = nil

	-- we gonna need this on by default :3
	P.cooldown.enable = true
end

--Mover positions that are set inside the installation process. ALL is used still to prevent people from getting pissed off
--This allows movers positions to be reset to whatever profile is being used
E.LayoutMoverPositions = {
	ALL = {
		BelowMinimapContainerMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-274',
		BNETMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-274',
		ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,95',
		ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,243',
		LossControlMover = 'BOTTOM,ElvUIParent,BOTTOM,-1,507',
		MirrorTimer1Mover = 'TOP,ElvUIParent,TOP,-1,-96',
		WatchFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-163,-325',
		SocialMenuMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-187',
		VehicleSeatMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-4',
		DurabilityFrameMover = 'TOPLEFT,ElvUIParent,TOPLEFT,141,-4',
		ThreatBarMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,4',
		PetAB = 'RIGHT,ElvUIParent,RIGHT,-4,0',
		ShiftAB = 'BOTTOM,ElvUIParent,BOTTOM,0,58',
		ElvUF_RaidMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269',
		ElvUF_Raid40Mover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269',
		ElvUF_PartyMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,269',
		PetExperienceBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-2,-251',
		ReputationBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-2,-243',
	},
	dpsCaster = {
		ElvUF_PlayerCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,0,243",
		ElvUF_TargetCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,0,97",
	},
	healer = {
		ElvUF_PlayerCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,0,243",
		ElvUF_TargetCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,0,97",
		ElvUF_RaidMover = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,202,373",
		LootFrameMover = "TOPLEFT,ElvUIParent,TOPLEFT,250,-104",
		VOICECHAT = 'TOPLEFT,ElvUIParent,TOPLEFT,250,-82'
	},
	anniversary = {
		AlertFrameMover = 'TOP,ElvUIParent,TOP,0,-95',
		ArenaHeaderMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-365,-252',
		BNETMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,279',
		BagsMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,17',
		BossHeaderMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-365,-252',
		BuffsMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-4',
		DebuffsMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-4',
		DigSiteProgressBarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,315',
		DurabilityFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-167,-215',
		ElvAB_1 = 'BOTTOM,ElvUIParent,BOTTOM,0,44',
		ElvAB_2 = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-522,49',
		ElvAB_3 = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,433,47',
		ElvAB_4 = 'TOPLEFT,ElvUIParent,TOPLEFT,564,-334',
		ElvAB_5 = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-294',
		ElvAB_6 = 'BOTTOM,ElvUIParent,BOTTOM,-271,431',
		ElvUF_AssistMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-260',
		ElvUF_FocusCastbarMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-572,357',
		ElvUF_FocusMover = 'BOTTOMRIGHT,UIParent,BOTTOMRIGHT,-572,369',
		ElvUF_FocusTargetMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-513,277',
		ElvUF_PartyMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,279',
		ElvUF_PetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-187,113',
		ElvUF_PetMover = 'BOTTOM,ElvUIParent,BOTTOM,-187,123',
		ElvUF_PlayerCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,-136,176',
		ElvUF_PlayerMover = 'BOTTOM,ElvUIParent,BOTTOM,-136,187',
		ElvUF_RaidMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,279',
		ElvUF_Raid40Mover = 'TOPLEFT,ElvUIParent,TOPLEFT,192,-295',
		ElvUF_RaidpetMover = 'TOPLEFT,ElvUIParent,BOTTOMLEFT,0,808',
		ElvUF_TankMover = 'TOPLEFT,ElvUIParent,TOPLEFT,4,-186',
		ElvUF_TargetCastbarMover = 'BOTTOM,ElvUIParent,BOTTOM,136,176',
		ElvUF_TargetMover = 'BOTTOM,ElvUIParent,BOTTOM,136,187',
		ElvUF_TargetTargetMover = 'BOTTOM,ElvUIParent,BOTTOM,187,123',
		ElvUIBagMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,49',
		ElvUIBankMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,47',
		ExperienceBarMover = 'TOP,ElvUIParent,TOP,0,-4',
		GMMover = 'TOP,ElvUIParent,TOP,-303,-4',
		PetExperienceBarMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,4',
		LeftChatMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,47',
		LocationMover = 'TOP,ElvUIParent,TOP,0,-7',
		LootFrameMover = 'TOPLEFT,ElvUIParent,TOPLEFT,487,-312',
		LossControlMover = 'BOTTOM,ElvUIParent,BOTTOM,0,382',
		MicroBarAnchor = 'TOP,ElvUIParent,TOP,1,-19',
		MicrobarMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,18',
		MinimapClusterMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,254',
		MinimapMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,49',
		MirrorTimer1Mover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-310,-229',
		MirrorTimer2Mover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-310,-247',
		MirrorTimer3Mover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-310,-265',
		NotificationMover = 'TOP,ElvUIParent,TOP,0,-96',
		ObjectiveFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-79,-293',
		PetAB = 'BOTTOM,ElvUIParent,BOTTOM,0,17',
		PvPMover = 'TOP,ElvUIParent,TOP,0,-28',
		QueueStatusMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-201,49',
		RaidBuffReminderMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,353,16',
		RaidMarkerBarAnchor = 'BOTTOM,ElvUIParent,BOTTOM,0,57',
		ReputationBarMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,4',
		RequestStopButton = 'TOP,ElvUIParent,TOP,0,-161',
		RightChatMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-233,26',
		ShiftAB = 'BOTTOM,ElvUIParent,BOTTOM,0,17',
		SquareMinimapBar = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-2,-185',
		SquareMinimapButtonBarMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-280',
		TargetPortraitMover = 'BOTTOM,ElvUIParent,BOTTOM,365,163',
		TargetPowerBarMover = 'BOTTOM,ElvUIParent,BOTTOM,231,215',
		ThreatBarMover = 'BOTTOM,ElvUIParent,BOTTOM,0,4',
		TooltipMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,255',
		TotemBarMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,560,31',
		TotemTrackerMover = 'BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,534,4',
		UIErrorsFrameMover = 'TOP,ElvUIParent,TOP,0,-195',
		VOICECHAT = 'TOPLEFT,ElvUIParent,TOPLEFT,487,-290',
		VehicleLeaveButton = 'BOTTOM,ElvUIParent,BOTTOM,0,145',
		VehicleSeatMover = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-587,23',
		WatchFrameMover = 'TOPRIGHT,ElvUIParent,TOPRIGHT,-122,-292',
		ZoneAbility = 'BOTTOM,ElvUIParent,BOTTOM,-323,139',
	}
}