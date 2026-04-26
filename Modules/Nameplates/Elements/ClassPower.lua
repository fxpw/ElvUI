local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local _G = _G
local max, next, ipairs = max, next, ipairs

local CreateFrame = CreateFrame
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

-- WotLK classes with class power resources
local MAX_POINTS = {
	DEATHKNIGHT = max(6, MAX_COMBO_POINTS),
	PALADIN     = max(5, MAX_COMBO_POINTS),
	WARLOCK     = max(5, MAX_COMBO_POINTS),
	ROGUE       = max(5, MAX_COMBO_POINTS),
	DRUID       = max(5, MAX_COMBO_POINTS),
}

function NP:ClassPower_SetBarColor(bar, r, g, b)
	bar:SetStatusBarColor(r, g, b)

	if bar.bg then
		bar.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier)
	end
end

function NP:ClassPower_UpdateColor(powerType, rune)
	local colors = NP.db.colors.classResources
	local fallback = NP.db.colors.power and NP.db.colors.power[powerType]

	if powerType == 'RUNES' and rune then
		local color = colors.DEATHKNIGHT and colors.DEATHKNIGHT[rune.runeType or 0]
		if color then
			NP:ClassPower_SetBarColor(rune, color.r, color.g, color.b)
		end
	else
		local classColor = (powerType == 'COMBO_POINTS' and colors.comboPoints)
		for i, bar in ipairs(self) do
			local color = (classColor and classColor[i]) or (colors[E.myclass]) or fallback
			if color then
				NP:ClassPower_SetBarColor(bar, color.r, color.g, color.b)
			end
		end
	end
end

function NP:ClassPower_PostUpdate(Cur, _, needUpdate, powerType)
	if Cur and Cur > 0 then
		self:Show()
	else
		self:Hide()
	end

	if needUpdate then
		NP:Update_ClassPower(self.__owner)
	end

	if powerType == 'COMBO_POINTS' then
		NP.ClassPower_UpdateColor(self, powerType)
	end
end

function NP:Construct_ClassPower(nameplate)
	local frameName = nameplate:GetName()
	local ClassPower = CreateFrame('Frame', frameName..'ClassPower', nameplate)
	ClassPower:CreateBackdrop('Transparent', nil, nil, nil, nil, true, true)
	ClassPower:Hide()
	ClassPower:SetFrameStrata(nameplate:GetFrameStrata())
	ClassPower:SetFrameLevel(5)

	local texture = LSM:Fetch('statusbar', NP.db.statusbar)
	local total = MAX_POINTS[E.myclass] or 0

	for i = 1, total do
		local bar = CreateFrame('StatusBar', frameName..'ClassPower'..i, ClassPower)
		bar:SetStatusBarTexture(texture)
		bar:SetFrameStrata(nameplate:GetFrameStrata())
		bar:SetFrameLevel(6)
		NP.StatusBars[bar] = true

		bar.bg = ClassPower:CreateTexture(frameName..'ClassPower'..i..'bg', 'BORDER')
		bar.bg:SetTexture(texture)
		bar.bg:SetAllPoints()

		if nameplate == _G.ElvNP_Test then
			local colors = NP.db.colors.classResources
			local combo = colors and colors.comboPoints and colors.comboPoints[i]
			if combo then
				bar.bg:SetVertexColor(combo.r, combo.g, combo.b)
			end
		end

		ClassPower[i] = bar
	end

	if nameplate == _G.ElvNP_Test then
		ClassPower.Hide = ClassPower.Show
		ClassPower:Show()
	end

	ClassPower.UpdateColor = NP.ClassPower_UpdateColor
	ClassPower.PostUpdate = NP.ClassPower_PostUpdate

	return ClassPower
end

function NP:Update_ClassPower(nameplate)
	local db = NP:PlateDB(nameplate)

	if nameplate == _G.ElvNP_Test then
		if not db.nameOnly and db.classpower and db.classpower.enable then
			NP.ClassPower_UpdateColor(nameplate.ClassPower, 'COMBO_POINTS')
			nameplate.ClassPower:SetAlpha(1)
		else
			nameplate.ClassPower:SetAlpha(0)
		end
	end

	local target = nameplate.frameType == 'TARGET'
	if (target or nameplate.frameType == 'PLAYER') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('ClassPower') then
			nameplate:EnableElement('ClassPower')
		end

		nameplate.ClassPower:ClearAllPoints()
		nameplate.ClassPower:Point('CENTER', nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)
		nameplate.ClassPower:Size(db.classpower.width, db.classpower.height)

		for i = 1, #nameplate.ClassPower do
			nameplate.ClassPower[i]:Hide()
			nameplate.ClassPower[i].bg:Hide()
		end

		local maxButtons = nameplate.ClassPower.__max
		if maxButtons and maxButtons > 0 then
			local Width = db.classpower.width / maxButtons
			for i = 1, maxButtons do
				local button = nameplate.ClassPower[i]
				button:Show()
				button.bg:Show()
				button:ClearAllPoints()

				if i == 1 then
					button:Point('LEFT', nameplate.ClassPower, 'LEFT', 0, 0)
					button:Size(Width, db.classpower.height)
				else
					button:Point('LEFT', nameplate.ClassPower[i - 1], 'RIGHT', 1, 0)
					button:Size(Width - 1, db.classpower.height)

					if i == maxButtons then
						button:Point('RIGHT', nameplate.ClassPower)
					end
				end
			end
		end
	else
		if nameplate:IsElementEnabled('ClassPower') then
			nameplate:DisableElement('ClassPower')
		end

		nameplate.ClassPower:Hide()
	end
end
