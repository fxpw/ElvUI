local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Sirus")
local DT = E:GetModule("DataTexts")
local DB = E:GetModule("DataBars")

-- function S:GetOptions()
	--ActionBars
	E.Options.args.actionbar.args.microbar.args.buttonsPerRow.max = #SHARED_MICROMENU_BUTTONS

	-- Auras
	E.Options.args.auras.args.buffs.args.filter = {
		order = 15,
		type = "select",
		sortByValue = true,
		name = L["Add Regular Filter"],
		desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the 'Filters' section of the config."],
		values = function()
			local filters = {}
			filters[""] = NONE
			local list = E.global.unitframe.aurafilters
			if list then
				for filter in pairs(list) do
					filters[filter] = filter
				end
			end

			return filters
		end
	}
	E.Options.args.auras.args.debuffs.args.filter = {
		order = 15,
		type = "select",
		sortByValue = true,
		name = L["Add Regular Filter"],
		desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the 'Filters' section of the config."],
		values = function()
			local filters = {}
			filters[""] = NONE
			local list = E.global.unitframe.aurafilters
			if list then
				for filter in pairs(list) do
					filters[filter] = filter
				end
			end

			return filters
		end
	}

	-- General
	E.Options.args.general.args.blizzUIImprovements.args.case = {
		order = 10,
		type = "toggle",
		name = E.NewSign.."Улучшенная рулетка",
		get = function(info) return E.db.sirus[info[#info]] end,
		set = function(info, value)
			E.db.sirus[info[#info]] = value
			E:StaticPopup_Show("PRIVATE_RL")
		end
	}

	--Skins
	E.Options.args.skins.args.blizzard.args.deathRecap = {
		type = "toggle",
		name = DEATH_RECAP_TITLE_DONT_INFO,
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.guild = {
		type = "toggle",
		name = L["Guild"],
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.losscontrol = {
		type = "toggle",
		name = LOSS_OF_CONTROL,
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.store = {
		type = "toggle",
		name = "Магазин",
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.timer = {
		type = "toggle",
		name = "Таймер",
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.transmogrify = {
		type = "toggle",
		name = "Трансмогрификация",
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.collections = {
		type = "toggle",
		name = "Коллекции",
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.encounterjournal = {
		type = "toggle",
		name = "Путеводитель",
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.roulette = {
		type = "toggle",
		name = ROULETTE_TITLE,
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.mountChest = {
		type = "toggle",
		name = MOUNT_CHEST_LABEL,
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.blizzard.args.headhunting = {
		type = "toggle",
		name = HEADHUNTING,
		desc = L["TOGGLESKIN_DESC"]
	}

	E.Options.args.skins.args.blizzard.args.extraButton = {
		type = "toggle",
		name = "Кнопки действий",
		desc = L["TOGGLESKIN_DESC"]
	}
	E.Options.args.skins.args.cleanExtraButton = {
		order = 9,
		type = "toggle",
		name = E.NewSign.."Упрощенные кнопки действий",
		get = function(info) return E.private.skins.cleanExtraButton end,
		set = function(info, value)
			E.private.skins.cleanExtraButton = value
			E:StaticPopup_Show("PRIVATE_RL")
		end
	}

	E.Options.args.databars.args.honor = {
		order = 5,
		type = "group",
		name = PVP_TAB_SERVICES,
		get = function(info) return DB.db.honor[info[#info]] end,
		set = function(info, value)
			DB.db.honor[info[#info]] = value
			DB:UpdateHonorDimensions()
		end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = PVP_TAB_SERVICES
			},
			enable = {
				order = 2,
				type = "toggle",
				name = L["Enable"],
				set = function(info, value)
					DB.db.honor[info[#info]] = value
					DB:EnableDisable_HonorBar()
				end
			},
			mouseover = {
				order = 3,
				type = "toggle",
				name = L["Mouseover"]
			},
			hideOutsidePvP = {
				order = 4,
				type = "toggle",
				name = L["Hide Outside PvP"],
				set = function(info, value)
					DB.db.honor[info[#info]] = value
					DB:UpdateHonor()
				end
			},
			hideInVehicle = {
				order = 5,
				type = "toggle",
				name = L["Hide In Vehicle"],
				set = function(info, value)
					DB.db.honor[info[#info]] = value
					DB:UpdateHonor()
				end
			},
			hideInCombat = {
				order = 6,
				type = "toggle",
				name = L["Hide In Combat"],
				set = function(info, value)
					DB.db.honor[info[#info]] = value
					DB:UpdateHonor()
				end
			},
			spacer = {
				order = 7,
				type = "description",
				name = " "
			},
			orientation = {
				order = 8,
				type = "select",
				name = L["Statusbar Fill Orientation"],
				desc = L["Direction the bar moves on gains/losses"],
				values = {
					["HORIZONTAL"] = L["Horizontal"],
					["VERTICAL"] = L["Vertical"]
				}
			},
			width = {
				order = 9,
				type = "range",
				name = L["Width"],
				min = 5, max = ceil(GetScreenWidth() or 800), step = 1
			},
			height = {
				order = 10,
				type = "range",
				name = L["Height"],
				min = 5, max = ceil(GetScreenHeight() or 800), step = 1
			},
			font = {
				order = 11,
				type = "select", dialogControl = "LSM30_Font",
				name = L["Font"],
				values = AceGUIWidgetLSMlists.font
			},
			textSize = {
				order = 12,
				type = "range",
				name = L["FONT_SIZE"],
				min = 6, max = 22, step = 1
			},
			fontOutline = {
				order = 13,
				type = "select",
				name = L["Font Outline"],
				values = {
					["NONE"] = L["NONE"],
					["OUTLINE"] = "OUTLINE",
					["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
					["THICKOUTLINE"] = "THICKOUTLINE"
				}
			},
			textFormat = {
				order = 14,
				type = "select",
				name = L["Text Format"],
				width = "double",
				values = {
					NONE = L["NONE"],
					CUR = L["Current"],
					REM = L["Remaining"],
					PERCENT = L["Percent"],
					CURMAX = L["Current - Max"],
					CURPERC = L["Current - Percent"],
					CURREM = L["Current - Remaining"],
					CURPERCREM = L["Current - Percent (Remaining)"],
				},
				set = function(info, value)
					DB.db.honor[info[#info]] = value
					DB:UpdateHonor()
				end
			}
		}
	}

	E.Options.args.datatexts.args.ArenaRating = {
		order = 7,
		type = "group",
		name = PVP_YOUR_RATING,
		get = function(info) return E.db.datatexts.ArenaRating[tonumber(info[#info])] end,
		set = function(info, value)
			E.db.datatexts.ArenaRating[tonumber(info[#info])] = value
			DT:LoadDataTexts()
		end,
		args = {
			["1"] = {
				order = 1,
				type = "toggle",
				name = "Solo",
			},
			["2"] = {
				order = 2,
				type = "toggle",
				name = "2x2",
			},
			["3"] = {
				order = 3,
				type = "toggle",
				name = "3x3",
			},
			["4"] = {
				order = 4,
				type = "toggle",
				name = "RGB",
			}
		}
	}
-- end


