local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

--Lua functions
--WoW API / Variables
local SetCVar = SetCVar



local function SetFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
	if not obj then return end

	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb, sa) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then
		obj:SetTextColor(r, g, b)
	elseif r then
		obj:SetAlpha(r)
	end
end

function E:UpdateBlizzardFonts()
	local NORMAL                       = self.media.normFont
	local NUMBER                       = self.media.normFont
	local COMBAT                       = LSM:Fetch("font", self.private.general.dmgfont)
	local NAMEFONT                     = LSM:Fetch("font", self.private.general.namefont)
	local MONOCHROME                   = ""

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS                  = { 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }

	if self.db.general.font == "Homespun" then
		MONOCHROME = "MONOCHROME"
	end
	if self.private.general.pixelPerfect then
		if not self.private.general.stillOnCombatText then
			InterfaceOptionsCombatTextPanelTargetDamage:Hide()
			InterfaceOptionsCombatTextPanelPeriodicDamage:Hide()
			InterfaceOptionsCombatTextPanelPetDamage:Hide()
			InterfaceOptionsCombatTextPanelHealing:Hide()
			SetCVar("CombatLogPeriodicSpells", 0)
			SetCVar("PetMeleeDamage", 0)
			SetCVar("CombatDamage", 0)
			SetCVar("CombatHealing", 0)
			-- set an invisible font for xp, honor kill, etc
			COMBAT = E.Media.Fonts.Invisible
		end
	end

	UNIT_NAME_FONT     = NAMEFONT
	NAMEPLATE_FONT     = NAMEFONT
	DAMAGE_TEXT_FONT   = COMBAT
	STANDARD_TEXT_FONT = NORMAL
	if self.private.general.replaceBlizzFonts then
		SetFont(GameTooltipHeader, NORMAL, self.db.general.fontSize)
		SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(NumberFont_Outline_Huge, NUMBER, 28, MONOCHROME .. "THICKOUTLINE", 28)
		SetFont(NumberFont_Outline_Large, NUMBER, 15, MONOCHROME .. "OUTLINE")
		SetFont(NumberFont_Outline_Med, NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(NumberFont_Shadow_Med, NORMAL, self.db.general.fontSize)
		SetFont(NumberFont_Shadow_Small, NORMAL, self.db.general.fontSize)
		SetFont(ChatFontSmall, NORMAL, self.db.general.fontSize)
		SetFont(QuestFontHighlight, NORMAL, self.db.general.fontSize)
		SetFont(QuestFont, NORMAL, self.db.general.fontSize)
		SetFont(QuestFont_Large, NORMAL, 14)
		SetFont(QuestTitleFont, NORMAL, self.db.general.fontSize + 8)
		SetFont(QuestTitleFontBlackShadow, NORMAL, self.db.general.fontSize + 8)
		SetFont(SystemFont_Large, NORMAL, 15)
		SetFont(GameFontNormalMed3, NORMAL, 15)
		SetFont(SystemFont_Shadow_Huge1, NORMAL, 20, MONOCHROME .. "OUTLINE")
		SetFont(SystemFont_Med1, NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Med3, NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_OutlineThick_Huge2, NORMAL, 20, MONOCHROME .. "THICKOUTLINE")
		SetFont(SystemFont_Outline_Small, NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(SystemFont_Shadow_Large, NORMAL, 15)
		SetFont(SystemFont_Shadow_Med1, NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Shadow_Med3, NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Shadow_Outline_Huge2, NORMAL, 20, MONOCHROME .. "OUTLINE")
		SetFont(SystemFont_Shadow_Small, NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Tiny, NORMAL, self.db.general.fontSize)
		SetFont(Tooltip_Med, NORMAL, self.db.general.fontSize)
		SetFont(Tooltip_Small, NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Normal, NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Small, NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Large, NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_UserText, NORMAL, self.db.general.fontSize)
		SetFont(SpellFont_Small, NORMAL, self.db.general.fontSize * 0.9)
		SetFont(ZoneTextString, NORMAL, 32, MONOCHROME .. "OUTLINE")
		SetFont(SubZoneTextString, NORMAL, 25, MONOCHROME .. "OUTLINE")
		SetFont(PVPInfoTextString, NORMAL, 22, MONOCHROME .. "OUTLINE")
		SetFont(PVPArenaTextString, NORMAL, 22, MONOCHROME .. "OUTLINE")
		SetFont(CombatTextFont, COMBAT, 100, MONOCHROME .. "OUTLINE")
		SetFont(SystemFont_OutlineThick_WTF, NORMAL, 32, MONOCHROME .. "OUTLINE")
		SetFont(SubZoneTextFont, NORMAL, 24, MONOCHROME .. "OUTLINE")
		SetFont(MailFont_Large, NORMAL, 14)
		SetFont(InvoiceFont_Med, NORMAL, 12)
		SetFont(InvoiceFont_Small, NORMAL, self.db.general.fontSize)
		SetFont(AchievementFont_Small, NORMAL, self.db.general.fontSize)
		SetFont(ReputationDetailFont, NORMAL, self.db.general.fontSize)

		SetFont(Fancy12Font, NORMAL, 12)                                         -- Added in 7.3.5
		SetFont(Fancy14Font, NORMAL, 14)                                         -- Added in 7.3.5 used for ?
		SetFont(Fancy22Font, NORMAL, self.db.general.fontSize and 22 or 20)      -- Talking frame Title font
		SetFont(Fancy24Font, NORMAL, self.db.general.fontSize and 24 or 20)      -- Artifact frame - weapon name

		SetFont(BossEmoteNormalHuge, NORMAL, 24)                                 -- Talent Title

		SetFont(GameFont_Gigantic, NORMAL, 32)                                   -- Used at the install steps
		SetFont(GameFontHighlightMedium, NORMAL, self.db.general.fontSize * 1.1 or 15) -- 14  Fix QuestLog Title mouseover
		SetFont(GameFontHighlightSmall2, NORMAL, self.db.general.fontSize * 0.9 or 15) -- 11  Skill or Recipe description on TradeSkill frame

		SetFont(GameFontNormalLarge, NORMAL, self.db.general.fontSize * 1.3 or 16) -- 16
		SetFont(GameFontNormalLarge2, NORMAL, self.db.general.fontSize * 1.3 or 15) -- 18  Garrison Follower Names
		SetFont(GameFontNormalMed1, NORMAL, self.db.general.fontSize * 1.1 or 14) -- 13  WoW Token Info
		SetFont(GameFontNormalMed2, NORMAL, self.db.general.fontSize * 1.1 or 15) -- 14  Quest tracker
		SetFont(GameFontNormalMed3, NORMAL, self.db.general.fontSize * 1.1 or 15) -- 14
		SetFont(GameFontNormalSmall2, NORMAL, self.db.general.fontSize * 0.9 or 12) -- 11  MissionUI Followers names

		SetFont(Number11Font, NUMBER, 11)
		SetFont(Number12Font, NORMAL, 12)

		SetFont(Number13Font, NUMBER, 13)
		SetFont(Number13FontGray, NUMBER, 13)
		SetFont(Number13FontWhite, NUMBER, 13)
		SetFont(Number13FontYellow, NUMBER, 13)
		SetFont(Number14FontGray, NUMBER, 14)
		SetFont(Number14FontWhite, NUMBER, 14)
		SetFont(Number15Font, NORMAL, 15)
		SetFont(Number18Font, NUMBER, 18)
		SetFont(Number18FontWhite, NUMBER, 18)
		SetFont(NumberFontNormalSmall, NORMAL, self.db.general.fontSize * 0.9 or 11, 'OUTLINE') -- 12  Calendar, EncounterJournal
		SetFont(PriceFont, NORMAL, 13)
		SetFont(QuestFont_Enormous, NORMAL, self.db.general.fontSize * 1.9 or 24)               -- 30  Garrison Titles
		SetFont(QuestFont_Huge, NORMAL, self.db.general.fontSize * 1.5 or 15)                   -- 18  Quest rewards title(Rewards)
		SetFont(QuestFont_Shadow_Huge, NORMAL, self.db.general.fontSize * 1.5 or 15)            -- 18  Quest Title
		SetFont(QuestFont_Shadow_Small, NORMAL, self.db.general.fontSize or 14)                 -- 14
		SetFont(QuestFont_Super_Huge, NORMAL, self.db.general.fontSize * 1.7 or 22)             -- 24
		SetFont(SubSpellFont, NORMAL, 10)                                                       -- Spellbook Sub Names
		SetFont(SystemFont_Huge1, NORMAL, 20)                                                   -- Garrison Mission XP
		SetFont(SystemFont_Outline, NORMAL, self.db.general.fontSize or 13, MONOCHROME .. "OUTLINE") -- 13  Pet level on World map
		SetFont(SystemFont_Shadow_Huge3, NORMAL, 22)                                            -- 25  FlightMap
		SetFont(SystemFont_Shadow_Huge4, NORMAL, 27, nil, nil, nil, nil, nil, 1, -1)
		SetFont(SystemFont_Shadow_Large2, NORMAL, 18)                                           -- Auction House ItemDisplay
		SetFont(SystemFont_Shadow_Med2, NORMAL, self.db.general.fontSize * 1.1 or 14.3)         -- 14  Shows Order resourses on OrderHallTalentFrame
		SetFont(SystemFont_Small, NORMAL, self.db.general.fontSize * 0.9 or self.db.general.fontSize) -- 10
		SetFont(GameFontNormal9, NORMAL, self.db.general.fontSize)
		SetFont(GameFontNormal11, NORMAL, self.db.general.fontSize)
		SetFont(GameFontNormal12, NORMAL, self.db.general.fontSize)
		SetFont(GameFontNormal13, NORMAL, self.db.general.fontSize)
		SetFont(GameFontNormal14, NORMAL, self.db.general.fontSize * 1.1)
		SetFont(GameFontNormal17, NORMAL, 18)
		SetFont(SystemFont_Med2, NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Shadow_Med2, NORMAL, self.db.general.fontSize)
		SetFont(QuestFont_Super_Huge, NORMAL, 22)
		SetFont(Fancy15Font, NORMAL, 15)
		SetFont(Fancy16Font, NORMAL, 16)
		SetFont(Fancy17Font, NORMAL, 17)
		SetFont(QuestFont15, NORMAL, 15)

		SetFont(_G.ObjectiveTrackerHeaderFont, NORMAL, self.db.general.fontSize)
		SetFont(_G.ObjectiveTrackerLineFont, NORMAL, self.db.general.fontSize)
		SetFont(_G.ObjectiveTrackerFont12, NORMAL, 12)
		SetFont(_G.ObjectiveTrackerFont13, NORMAL, 13)
		SetFont(_G.ObjectiveTrackerFont14, NORMAL, 14)
		SetFont(_G.ObjectiveTrackerFont15, NORMAL, 15)
		SetFont(_G.ObjectiveTrackerFont16, NORMAL, 16)
		SetFont(_G.ObjectiveTrackerFont17, NORMAL, 17)
		SetFont(_G.ObjectiveTrackerFont18, NORMAL, 18)
		SetFont(_G.ObjectiveTrackerFont19, NORMAL, 19)
		SetFont(_G.ObjectiveTrackerFont20, NORMAL, 20)
		SetFont(_G.ObjectiveTrackerFont21, NORMAL, 21)
		SetFont(_G.ObjectiveTrackerFont22, NORMAL, 22)
	end
end