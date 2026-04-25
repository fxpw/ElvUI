local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = "Whitelist",
	spells = {
	-- Death Knight
		[47476] = List(2), -- Strangulate
		[51209] = List(2), -- Hungering Cold
	-- Druid
		[99] = List(2), -- Demoralizing Roar
		[339] = List(2), -- Entangling Roots
		[2637] = List(2), -- Hibernate
		[5211] = List(2), -- Bash
		[9005] = List(2), -- Pounce
		[22570] = List(2), -- Maim
		[33786] = List(2), -- Cyclone
		[45334] = List(2), -- Feral Charge Effect
	-- Hunter
		[1513] = List(2), -- Scare Beast
		[3355] = List(2), -- Freezing Trap Effect
		[19386] = List(2), -- Wyvern Sting
		[19503] = List(2), -- Scatter Shot
		[24394] = List(2), -- Intimidation
		[34490] = List(2), -- Silencing Shot
		[50245] = List(2), -- Pin
		[50519] = List(2), -- Sonic Blast
		[50541] = List(2), -- Snatch
		[54706] = List(2), -- Venom Web Spray
		[56626] = List(2), -- Sting
		[60210] = List(2), -- Freezing Arrow Effect
		[64803] = List(2), -- Entrapment
	-- Mage
		[118] = List(2), -- Polymorph (Sheep)
		[122] = List(2), -- Frost Nova
		[18469] = List(2), -- Silenced - Improved Counterspell (Rank 1)
		[31589] = List(2), -- Slow
		[31661] = List(2), -- Dragon's Breath
		[33395] = List(2), -- Freeze
		[44572] = List(2), -- Deep Freeze
		[55080] = List(2), -- Shattered Barrier
		[61305] = List(2), -- Polymorph (Black Cat)
		[55021] = List(2), -- Silenced - Improved Counterspell (Rank 2)
	-- Paladin
		[853] = List(2), -- Hammer of Justice
		[10326] = List(2), -- Turn Evil
		[20066] = List(2), -- Repentance
		[31935] = List(2), -- Avenger's Shield
	-- Priest
		[605] = List(2), -- Mind Control
		[8122] = List(2), -- Psychic Scream
		[9484] = List(2), -- Shackle Undead
		[15487] = List(2), -- Silence
		[64044] = List(2), -- Psychic Horror
	-- Rogue
		[408] = List(2), -- Kidney Shot
		[1330] = List(2), -- Garrote - Silence
		[1776] = List(2), -- Gouge
		[1833] = List(2), -- Cheap Shot
		[2094] = List(2), -- Blind
		[6770] = List(2), -- Sap
		[18425] = List(2), -- Silenced - Improved Kick
		[51722] = List(2), -- Dismantle
	-- Shaman
		[3600] = List(2), -- Earthbind
		[8056] = List(2), -- Frost Shock
		[39796] = List(2), -- Stoneclaw Stun
		[51514] = List(2), -- Hex
		[63685] = List(2), -- Freeze
		[64695] = List(2), -- Earthgrab
	-- Warlock
		[710] = List(2), -- Banish
		[5782] = List(2), -- Fear
		[6358] = List(2), -- Seduction
		[6789] = List(2), -- Death Coil
		[17928] = List(2), -- Howl of Terror
		[24259] = List(2), -- Spell Lock
		[30283] = List(2), -- Shadowfury
	-- Warrior
		[676] = List(2), -- Disarm
		[7922] = List(2), -- Charge Stun
		[18498] = List(2), -- Silenced - Gag Order
		[20511] = List(2), -- Intimidating Shout
	-- Racial
		[25046] = List(2), -- Arcane Torrent
		[20549] = List(2), -- War Stomp
	-- The Lich King
		[73787] = List(2), -- Necrotic Plague
	}
}

G.unitframe.aurafilters.TurtleBuffs = {
	type = "Whitelist",
	spells = {
	-- Mage
		[45438] = List(5), -- Ice Block
	-- Death Knight
		[48707] = List(5), -- Anti-Magic Shell
		[48792] = List(), -- Icebound Fortitude
		[49039] = List(), -- Lichborne
		[50461] = List(), -- Anti-Magic Zone
		[55233] = List(), -- Vampiric Blood
	-- Priest
		[33206] = List(3), -- Pain Suppression
		[47585] = List(5), -- Dispersion
		[47788] = List(), -- Guardian Spirit
	-- Warlock

	-- Druid
		[22812] = List(2), -- Barkskin
		[61336] = List(), -- Survival Instincts
	-- Hunter
		[19263] = List(5), -- Deterrence
		[53480] = List(), -- Roar of Sacrifice
	-- Rogue
		[5277] = List(5), -- Evasion
		[31224] = List(), -- Cloak of Shadows
		[45182] = List(), -- Cheating Death
	-- Shaman
		[30823] = List(), -- Shamanistic Rage
	-- Paladin
		[498] = List(2), -- Divine Protection
		[642] = List(5), -- Divine Shield
		[1022] = List(5), -- Hand of Protection
		[6940] = List(), -- Hand of Sacrifice
		[31821] = List(3), -- Aura Mastery
	-- Warrior
		[871] = List(3), -- Shield Wall
		[55694] = List(), -- Enraged Regeneration
	}
}

G.unitframe.aurafilters.PlayerBuffs = {
	type = "Whitelist",
	spells = {
	-- Mage
		[12042] = List(), -- Arcane Power
		[12051] = List(), -- Evocation
		[12472] = List(), -- Icy Veins
		[32612] = List(), -- Invisibility
		[45438] = List(), -- Ice Block
	-- Death Knight
		[48707] = List(), -- Anti-Magic Shell
		[48792] = List(), -- Icebound Fortitude
		[49016] = List(), -- Hysteria
		[49039] = List(), -- Lichborne
		[49222] = List(), -- Bone Shield
		[50461] = List(), -- Anti-Magic Zone
		[51271] = List(), -- Unbreakable Armor
		[55233] = List(), -- Vampiric Blood
	-- Priest
		[6346] = List(), -- Fear Ward
		[10060] = List(), -- Power Infusion
		[27827] = List(), -- Spirit of Redemption
		[33206] = List(), -- Pain Suppression
		[47585] = List(), -- Dispersion
		[47788] = List(), -- Guardian Spirit
	-- Warlock

	-- Druid
		[1850] = List(), -- Dash
		[22812] = List(), -- Barkskin
		[52610] = List(), -- Savage Roar
	-- Hunter
		[3045] = List(), -- Rapid Fire
		[5384] = List(), -- Feign Death
		[19263] = List(), -- Deterrence
		[53480] = List(), -- Roar of Sacrifice (Cunning)
		[54216] = List(), -- Master's Call
	-- Rogue
		[2983] = List(), -- Sprint
		[5277] = List(), -- Evasion
		[11327] = List(), -- Vanish
		[13750] = List(), -- Adrenaline Rush
		[31224] = List(), -- Cloak of Shadows
		[45182] = List(), -- Cheating Death
	-- Shaman
		[2825] = List(), -- Bloodlust
		[8178] = List(), -- Grounding Totem Effect
		[16166] = List(), -- Elemental Mastery
		[16188] = List(), -- Nature's Swiftness
		[16191] = List(), -- Mana Tide
		[30823] = List(), -- Shamanistic Rage
		[32182] = List(), -- Heroism
		[58875] = List(), -- Spirit Walk
	-- Paladin
		[498] = List(), -- Divine Protection
		[1022] = List(), -- Hand of Protection
		[1044] = List(), -- Hand of Freedom
		[6940] = List(), -- Hand of Sacrifice
		[31821] = List(), -- Aura Mastery
		[31842] = List(), -- Divine Illumination
		[31850] = List(), -- Ardent Defender
		[31884] = List(), -- Avenging Wrath
		[53563] = List(), -- Beacon of Light
	-- Warrior
		[871] = List(), -- Shield Wall
		[1719] = List(), -- Recklessness
		[3411] = List(), -- Intervene
		[12292] = List(), -- Death Wish
		[12975] = List(), -- Last Stand
		[18499] = List(), -- Berserker Rage
		[23920] = List(), -- Spell Reflection
		[46924] = List(), -- Bladestorm
	-- Racial
		[20594] = List(), -- Stoneform
		[59545] = List(), -- Gift of the Naaru
		[20572] = List(), -- Blood Fury
		[26297] = List(), -- Berserking
	}
}

-- Buffs that really we dont need to see
G.unitframe.aurafilters.Blacklist = {
	type = "Blacklist",
	spells = {
		[6788] = List(), -- Weakened Soul
		[8326] = List(), -- Ghost
		[15007] = List(), -- Resurrection Sickness
		[23445] = List(), -- Evil Twin
		[24755] = List(), -- Tricked or Treated
		[25771] = List(), -- Forbearance
		[26013] = List(), -- Deserter
		[36032] = List(), -- Arcane Blast
		[36893] = List(), -- Transporter Malfunction
		[36900] = List(), -- Soul Split: Evil!
		[36901] = List(), -- Soul Split: Good
		[41425] = List(), -- Hypothermia
		[55711] = List(), -- Weakened Heart
		[57723] = List(), -- Exhaustion
		[57724] = List(), -- Sated
		[58539] = List(), -- Watcher's Corpse
		[67604] = List(), -- Powering Up
		[69127] = List(), -- Chill of the Throne
		[71041] = List(), -- Dungeon Deserter
	-- Festergut
		[70852] = List(), -- Malleable Goo
		[72144] = List(), -- Orange Blight Residue
		[73034] = List(), -- Blighted Spores
	-- Rotface
		[72145] = List(), -- Green Blight Residue
	-- Professor Putricide
		[72460] = List(), -- Choking Gas
		[72511] = List(), -- Mutated Transformation
	-- Blood Prince Council
		[71911] = List(), -- Shadow Resonance
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc..
]]
G.unitframe.aurafilters.Whitelist = {
	type = "Whitelist",
	spells = {
		[1022] = List(), -- Hand of Protection
		[1490] = List(), -- Curse of the Elements
		[2825] = List(), -- Bloodlust
		[12051] = List(), -- Evocation
		[18708] = List(), -- Fel Domination
		[29166] = List(), -- Innervate
		[31821] = List(), -- Aura Mastery
		[32182] = List(), -- Heroism
		[47788] = List(), -- Guardian Spirit
		[54428] = List(), -- Divine Plea
	-- Turtling abilities
		[871] = List(), -- Shield Wall
		[19263] = List(), -- Deterrence
		[22812] = List(), -- Barkskin
		[31224] = List(), -- Cloak of Shadows
		[33206] = List(), -- Pain Suppression
		[48707] = List(), -- Anti-Magic Shell
	-- Immunities
		[642] = List(), -- Divine Shield
		[45438] = List(), -- Ice Block
	-- Offensive
		[12292] = List(), -- Death Wish
		[31884] = List(), -- Avenging Wrath
		[34471] = List(), -- The Beast Within
	}
}

-- RAID DEBUFFS: This should be pretty self explainitory
G.unitframe.aurafilters.RaidDebuffs = {
	type = "Whitelist",
	spells = {
	-- Naxxramas
		-- Anub'Rekhan
		[54022] = List(), -- Locust Swarm
		-- Grand Widow Faerlina
		[54098] = List(), -- Poison Bolt Volley
		-- Maexxna
		[54121] = List(), -- Necrotic Poison
		[54125] = List(), -- Web Spray
		-- Gluth
		[29306] = List(), -- Infected Wound
		[54378] = List(), -- Mortal Wound
		-- Gothik the Harvester
		[27825] = List(), -- Shadow Mark
		[28679] = List(), -- Harvest Soul
		[55645] = List(), -- Death Plague
		-- The Four Horsemem
		[28832] = List(), -- Mark of Korth'azz
		[28833] = List(), -- Mark of Blaumeux
		[28834] = List(), -- Mark of Rivendare
		[28835] = List(), -- Mark of Zeliek
		[57369] = List(), -- Unholy Shadow
		-- Noth the Plaguebringer
		[29212] = List(), -- Cripple
		[29213] = List(), -- Curse of the Plaguebringer
		[29214] = List(), -- Wrath of the Plaguebringer
		-- Heigan the Unclean
		[29310] = List(), -- Spell Disruption
		[29998] = List(), -- Decrepit Fever
		-- Loatheb
		[55052] = List(), -- Inevitable Doom
		[55053] = List(), -- Deathbloom
		-- Sapphiron
		[28522] = List(), -- Icebolt
		[55665] = List(), -- Life Drain
		[55699] = List(), -- Chill
		-- Kel'Thuzad
		[28410] = List(), -- Chains of Kel'Thuzad
		[27819] = List(), -- Detonate Mana
		[27808] = List(), -- Frost Blast

	-- Ulduar
		-- Ignis the Furnace Master
		[62717] = List(), -- Slag Pot

		-- XT-002
		[63024] = List(), -- Gravity Bomb
		[63018] = List(), -- Light Bomb

		-- The Assembly of Iron
		[61903] = List(), -- Fusion Punch
		[61912] = List(), -- Static Disruption

		-- Kologarn
		[64290] = List(), -- Stone Grip

		-- Thorim
		[62130] = List(), -- Unbalancing Strike

		-- Yogg-Saron
		[63134] = List(), -- Sara's Blessing
		[64157] = List(), -- Curse of Doom

		-- Algalon
		[64412] = List(), -- Phase Punch

	-- Trial of the Crusader
		-- Beast of Northrend
		-- Gormok the Impaler
		[66331] = List(), -- Impale
		[66406] = List(), -- Snowbolled!
		-- Jormungar Behemoth
		[66869] = List(), -- Burning Bile
		[67618] = List(), -- Paralytic Toxin
		-- Icehowl
		[66689] = List(), -- Arctic Breathe

		-- Lord Jaraxxus
		[66237] = List(), -- Incinerate Flesh
		[66197] = List(), -- Legion Flame

		-- Faction Champions
		[65812] = List(), -- Unstable Affliction

		-- The Twin Val'kyr
		[67309] = List(), -- Twin Spike

		-- Anub'arak
		[66013] = List(), -- Penetrating Cold
		[67574] = List(), -- Pursued by Anub'arak
		[67847] = List(), -- Expose Weakness

	-- Icecrown Citadel
		-- Lord Marrowgar
		[69065] = List(), -- Impaled

		-- Lady Deathwhisper
		[72109] = List(), -- Death and Decay
		[71289] = List(), -- Dominate Mind
		[71237] = List(), -- Curse of Torpor

		-- Deathbringer Saurfang
		[72293] = List(), -- Mark of the Fallen Champion
		[72442] = List(), -- Boiling Blood
		[72449] = List(), -- Rune of Blood
		[72769] = List(), -- Scent of Blood

		-- Festergut
		[71218] = List(), -- Vile Gas
		[72219] = List(), -- Gastric Bloat
		[69279] = List(), -- Gas Spore

		-- Rotface
		[71224] = List(), -- Mutated Infection

		-- Professor Putricide
		[71278] = List(), -- Choking Gas Bomb
		[70215] = List(), -- Gaseous Bloat
		[72549] = List(), -- Malleable Goo
		[70953] = List(), -- Plague Sickness
		[72856] = List(), -- Unbound Plague
		[70447] = List(), -- Volatile Ooze Adhesive

		-- Blood Prince Council
		[72796] = List(), -- Glittering Sparks
		[71822] = List(), -- Shadow Resonance

		-- Blood-Queen Lana'thel
		[72265] = List(), -- Delirious Slash
		[71473] = List(), -- Essence of the Blood Queen
		[71474] = List(), -- Frenzied Bloodthirst
		[71340] = List(), -- Pact of the Darkfallen
		[71265] = List(), -- Swarming Shadows
		[70923] = List(), -- Uncontrollable Frenzy

		-- Valithria Dreamwalker
		[71733] = List(), -- Acid Burst
		[71738] = List(), -- Corrosion
		[70873] = List(), -- Emerald Vigor
		[71283] = List(), -- Gut Spray

		-- Sindragosa
		[70106] = List(), -- Chilled to the Bone
		[70126] = List(), -- Frost Beacon
		[70157] = List(), -- Ice Tomb
		[69766] = List(), -- Instability
		[69762] = List(), -- Unchained Magic

		-- The Lich King
		[72762] = List(), -- Defile
		[70541] = List(), -- Infest
		[70337] = List(), -- Necrotic plague
		[72149] = List(), -- Shockwave
		[69409] = List(), -- Soul Reaper
		[69242] = List(), -- Soul Shriek

	-- The Ruby Sanctum
		-- Trash
		-- Baltharus the Warborn
		[75887] = List(), -- Blazing Aura
		[74502] = List(), -- Enervating Brand
		-- General Zarithrian
		[74367] = List(), -- Cleave Armor

		-- Halion
		[74562] = List(), -- Fiery Combustion
		[74567] = List(), -- Mark of Combustion
		[74792] = List(), -- Soul Consumption
		[74795] = List(), -- Mark of Consumption
	},
}

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

-- BuffWatch: List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local r, g, b = unpack(color)

	local r2, g2, b2 = 1, 1, 1
	if textColor then
		r2, g2, b2 = unpack(textColor)
	end

	return {
		enabled = true,
		id = id,
		point = point,
		color = {r = r, g = g, b = b},
		anyUnit = anyUnit,
		onlyShowMissing = onlyShowMissing,
		style = style or "coloredIcon",
		displayText = displayText or false,
		decimalThreshold = decimalThreshold or 5,
		textColor = {r = r2, g = g2, b = b2},
		textThreshold = textThreshold or -1,
		xOffset = xOffset or 0,
		yOffset = yOffset or 0,
		sizeOverride = sizeOverride or 0
	}
end

G.unitframe.buffwatch = {
	PRIEST = {
		[6788] = ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true),				-- Weakened Soul
		[10060] = ClassBuff(10060, "RIGHT", {0.89, 0.09, 0.05}),			-- Power Infusion
		[48066] = ClassBuff(48066, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Power Word: Shield
		[48068] = ClassBuff(48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}),			-- Renew
		[48111] = ClassBuff(48111, "TOPRIGHT", {0.2, 0.7, 0.2}),			-- Prayer of Mending
	},
	DRUID = {
		[48441] = ClassBuff(48441, "TOPRIGHT", {0.8, 0.4, 0.8}),			-- Rejuvenation
		[48443] = ClassBuff(48443, "BOTTOMLEFT", {0.2, 0.8, 0.2}),			-- Regrowth
		[48451] = ClassBuff(48451, "TOPLEFT", {0.4, 0.8, 0.2}),				-- Lifebloom
		[53251] = ClassBuff(53251, "BOTTOMRIGHT", {0.8, 0.4, 0}),			-- Wild Growth
	},
	PALADIN = {
		[1038] = ClassBuff(1038, "BOTTOMRIGHT", {0.9, 0.78, 0}, true),		-- Hand of Salvation
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {0.86, 0.45, 0}, true),		-- Hand of Freedom
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {0.89, 0.09, 0.05}, true),	-- Hand of Sacrifice
		[10278] = ClassBuff(10278, "BOTTOMRIGHT", {0.2, 0.2, 1}, true),		-- Hand of Protection
		[53563] = ClassBuff(53563, "TOPLEFT", {0.7, 0.3, 0.7}),				-- Beacon of Light
		[53601] = ClassBuff(53601, "TOPRIGHT", {0.4, 0.7, 0.2}),			-- Sacred Shield
	},
	SHAMAN = {
		[16237] = ClassBuff(16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}),			-- Ancestral Fortitude
		[49284] = ClassBuff(49284, "TOPRIGHT", {0.2, 0.7, 0.2}),			-- Earth Shield
		[52000] = ClassBuff(52000, "BOTTOMRIGHT", {0.7, 0.4, 0}),			-- Earthliving
		[61301] = ClassBuff(61301, "TOPLEFT", {0.7, 0.3, 0.7}),				-- Riptide
	},
	ROGUE = {
		[57933] = ClassBuff(57933, "TOPRIGHT", {0.89, 0.09, 0.05}),			-- Tricks of the Trade
	},
	MAGE = {
		[54646] = ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}),				-- Focus Magic
	},
	WARRIOR = {
		[3411] = ClassBuff(3411, "TOPRIGHT", {0.89, 0.09, 0.05}),			-- Intervene
		[59665] = ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}),				-- Vigilance
	},
	DEATHKNIGHT = {
		[49016] = ClassBuff(49016, "TOPRIGHT", {0.89, 0.09, 0.05})			-- Hysteria
	},
	PET = {
		[1539] = ClassBuff(1539, "TOPLEFT", {0.81, 0.85, 0.1}, true),		-- Feed Pet
		[48990] = ClassBuff(48990, "TOPRIGHT", {0.2, 0.8, 0.2}, true)		-- Mend Pet
	},
	HUNTER = {},
	WARLOCK = {},
}

-- Profile specific BuffIndicator
P.unitframe.filters = {
	buffwatch = {}
}

-- Ticks
G.unitframe.ChannelTicks = {
	-- Warlock
	[1120] = 5,	-- Drain Soul
	[689] = 5,	-- Drain Life
	[5138] = 5,	-- Drain Mana
	[5740] = 4,	-- Rain of Fire
	[755] = 10,	-- Health Funnel
	[1949] = 15,	-- Hellfire
	-- Druid
	[44203] = 4,	-- Tranquility
	[16914] = 10, -- Hurricane
	-- Priest
	[15407] = 3,	-- Mind Flay
	[48045] = 5,	-- Mind Sear
	[47540] = 3,	-- Penance
	[64843] = 4,	-- Divine Hymn
	[64901] = 4,	-- Hymn of Hope
	-- Mage
	[5143] = 5,	-- Arcane Missiles
	[10] = 8,	-- Blizzard
	[12051] = 4,	-- Evocation
	-- Hunter
	[58434] = 6,	-- Volley
	-- Death Knight
	[42650] = 8,	-- Army of the Dead
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825] = {r = 0.98, g = 0.57, b = 0.10},		-- Bloodlust
	[32182] = {r = 0.98, g = 0.57, b = 0.10},	-- Heroism
}

G.unitframe.DebuffHighlightColors = {
	[25771] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}}, -- Forbearance
}

G.unitframe.specialFilters = {
	-- Whitelists
	Personal = true,
	nonPersonal = true,
	CastByUnit = true,
	notCastByUnit = true,
	Dispellable = true,
	notDispellable = true,

	-- Blacklists
	blockNonPersonal = true,
	blockNoDuration = true,
	blockDispellable = true,
	blockNotDispellable = true,
}