local E, L, V, P, G = unpack(ElvUI)

--Locked Settings, These settings are stored for your character only regardless of profile options.

V.general = {
	loot = true,
	lootRoll = true,
	normTex = "ElvUI Norm",
	glossTex = "ElvUI Norm",
	dmgfont = "Expressway",
	namefont = "Expressway", -- (PT Sans) some dont render for mail room quest
	chatBubbles = "backdrop",
	chatBubbleFont = "PT Sans Narrow",
	chatBubbleFontSize = 12,
	chatBubbleFontOutline = "NONE",
	chatBubbleName = false,
	nameplateFont = "PT Sans Narrow",
	nameplateFontSize = 9,
	nameplateFontOutline = "OUTLINE",
	pixelPerfect = true,
	replaceNameFont = true,
	replaceCombatFont = true,
	replaceCombatText = false,
	replaceNameplateFont = true,
	replaceBlizzFonts = true,
	blizzardFontSize = false,
	noFontScale = false,
	totemTracker = true,
	classColors = false,
	minimap = {
		enable = true,
		hideCalendar = true,
		hideTracking = false,
	},
	classColorMentionsSpeech = true,
	raidUtility = true,
	worldMap = true,
}

V.bags = {
	enable = true,
	bagBar = false
}

V.nameplates = {
	enable = true,
}

V.auras = {
	enable = true,
	disableBlizzard = true,
	buffsHeader = true,
	debuffsHeader = true,
	masque = {
		buffs = false,
		debuffs = false,
	}
}

V.chat = {
	enable = true
}

V.skins = {
	ace3Enable = true,
	libDropdown = true,
	checkBoxSkin = true,
	parchmentRemoverEnable = false,
	blizzard = {
		enable = true,

		achievement = true,
		alertframes = true,
		arena = true,
		arenaregistrar = true,
		auctionhouse = true,
		bags = true,
		barber = true,
		bgmap = true,
		bgscore = true,
		binding = true,
		blizzardOptions = true,
		calendar = true,
		character = true,
		debug = true,
		dressingroom = true,
		eventLog = true,
		friends = true,
		gbank = true,
		guildBank = true,
		glyph = true,
		gmchat = true,
		gossip = true,
		greeting = true,
		guildregistrar = true,
		help = true,
		inspect = true,
		lfd = true,
		lfr = true,
		loot = true,
		macro = true,
		mail = true,
		merchant = true,
		mirrorTimers = true,
		misc = true,
		petition = true,
		pvp = true,
		quest = true,
		raid = true,
		socket = true,
		spellbook = true,
		stable = true,
		tabard = true,
		talent = true,
		taxi = true,
		timemanager = true,
		tooltip = true,
		trade = true,
		tradeskill = true,
		trainer = true,
		tutorial = true,
		watchframe = true,
		worldState = true,
		worldmap = true,
		arenaRegistrar = true,
		tutorials = true,
	}
}

V.tooltip = {
	enable = true,
}

V.unitframe = {
	enable = true,
	disabledBlizzardFrames = {
		player = true,
		target = true,
		focus = true,
		boss = true,
		arena = true,
		party = true,
	}
}

V.actionbar = {
	enable = true,
	masque = {
		actionbars = false,
		petBar = false,
		stanceBar = false,
	}
}

V.worldmap = {
	enable = true
}