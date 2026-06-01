local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

-- glowStyle style1-8 = Border/Background/Top/Side arrow combinations

function NP:Update_Glow(frame)
	local ti = frame.TargetIndicator
	if not ti then return end
	local sf = NP:StyleFilterChanges(frame)
	if sf.ShowTargetIndicator then
		return
	end
	if sf.NameOnly and not sf.ShowTargetIndicator then
		ti.TopIndicator:Hide()
		ti.LeftIndicator:Hide()
		ti.RightIndicator:Hide()
		ti.Shadow:Hide()
		ti.Spark:Hide()
		return
	end

	local showIndicator

	if frame.isTarget then
		showIndicator = 1
	elseif self.db.lowHealthThreshold > 0 then
		local health = frame.Health:GetValue()
		local _, maxHealth = frame.Health:GetMinMaxValues()
		local perc = maxHealth > 0 and (health / maxHealth) or 0

		if health > 1 and perc <= self.db.lowHealthThreshold then
			if perc <= self.db.lowHealthThreshold / 2 then
				showIndicator = 2
			else
				showIndicator = 3
			end
		end
	end

	local glowStyle = self.db.units.TARGET.glowStyle
	local healthIsShown = NP:Health_IsVisible(frame)
	local t = frame.Name:GetText(); local nameExists = frame.Name:IsShown() and t and t ~= ''

	if not healthIsShown and nameExists then
		if glowStyle == "style1" then
			glowStyle = "none"
		elseif glowStyle == "style5" then
			glowStyle = "style3"
		elseif glowStyle == "style7" then
			glowStyle = "style4"
		end
	end

	if showIndicator and glowStyle ~= "none" then
		local r, g, b

		if showIndicator == 1 then
			local color = self.db.colors.glowColor
			r, g, b = color.r, color.g, color.b
		else
			local c = showIndicator == 2 and self.db.colors.lowHealthHalf or self.db.colors.lowHealthColor
			r, g, b = c.r, c.g, c.b
		end

		-- Indicators
		ti.TopIndicator:SetVertexColor(r, g, b)
		ti.LeftIndicator:SetVertexColor(r, g, b)
		ti.RightIndicator:SetVertexColor(r, g, b)

		if glowStyle == "style3" or glowStyle == "style5" or glowStyle == "style6" then
			ti.LeftIndicator:Hide()
			ti.RightIndicator:Hide()

			if healthIsShown or nameExists then
				ti.TopIndicator:Show()
			end
		elseif glowStyle == "style4" or glowStyle == "style7" or glowStyle == "style8" then
			ti.TopIndicator:Hide()

			if healthIsShown or nameExists then
				ti.LeftIndicator:Show()
				ti.RightIndicator:Show()
			end
		end

		-- Spark / Shadow
		ti.Shadow:SetBackdropBorderColor(r, g, b)
		ti.Spark:SetVertexColor(r, g, b)

		if glowStyle == "style1" or glowStyle == "style5" or glowStyle == "style7" then
			ti.Spark:Hide()

			if healthIsShown then
				ti.Shadow:Show()
			end
		elseif glowStyle == "style2" or glowStyle == "style6" or glowStyle == "style8" then
			ti.Shadow:Hide()

			if healthIsShown or nameExists then
				ti.Spark:Show()
			end
		elseif glowStyle == "style3" or glowStyle == "style4" then
			ti.Shadow:Hide()
			ti.Spark:Hide()
		end
	else
		ti.TopIndicator:Hide()
		ti.LeftIndicator:Hide()
		ti.RightIndicator:Hide()
		ti.Shadow:Hide()
		ti.Spark:Hide()
	end
end

function NP:Configure_Glow(frame)
	local ti = frame.TargetIndicator
	if not ti then return end
	local sf = NP:StyleFilterChanges(frame)
	if sf.ShowTargetIndicator then
		return
	end
	if sf.NameOnly and not sf.ShowTargetIndicator then
		ti.TopIndicator:Hide()
		ti.LeftIndicator:Hide()
		ti.RightIndicator:Hide()
		ti.Shadow:Hide()
		ti.Spark:Hide()
		return
	end

	local glowStyle = self.db.units.TARGET.glowStyle
	local healthIsShown = NP:Health_IsVisible(frame)
	local t = frame.Name:GetText(); local nameExists = frame.Name:IsShown() and t and t ~= ''

	if not healthIsShown and nameExists then
		if glowStyle == "style1" then
			glowStyle = "none"
		elseif glowStyle == "style5" then
			glowStyle = "style3"
		elseif glowStyle == "style7" then
			glowStyle = "style4"
		end
	end

	if glowStyle ~= "none" then
		local color = self.db.colors.glowColor
		local arrowTex = E.Media.Arrows.ArrowUp
		local arrowSize = 20
		local arrowXOffset, arrowYOffset = 0, 0
		local r, g, b, a = color.r, color.g, color.b, color.a

		-- Indicators
		ti.LeftIndicator:SetTexture(arrowTex)
		ti.LeftIndicator:SetVertexColor(r, g, b)
		ti.LeftIndicator:SetSize(arrowSize, arrowSize)

		ti.RightIndicator:SetTexture(arrowTex)
		ti.RightIndicator:SetVertexColor(r, g, b)
		ti.RightIndicator:SetSize(arrowSize, arrowSize)

		ti.TopIndicator:SetTexture(arrowTex)
		ti.TopIndicator:SetVertexColor(r, g, b)
		ti.TopIndicator:SetSize(arrowSize, arrowSize)

		ti.TopIndicator:ClearAllPoints()
		ti.LeftIndicator:ClearAllPoints()
		ti.RightIndicator:ClearAllPoints()

		if glowStyle == "style3" or glowStyle == "style5" or glowStyle == "style6" then
			if healthIsShown then
				ti.TopIndicator:SetPoint("BOTTOM", frame.Health, "TOP", arrowXOffset, arrowYOffset)
			else
				ti.TopIndicator:SetPoint("BOTTOM", frame.Name, "TOP", arrowXOffset, arrowYOffset)
			end
		elseif glowStyle == "style4" or glowStyle == "style7" or glowStyle == "style8" then
			if healthIsShown then
				ti.LeftIndicator:SetPoint("LEFT", frame.Health, "RIGHT", arrowXOffset, arrowYOffset)
				ti.RightIndicator:SetPoint("RIGHT", frame.Health, "LEFT", -arrowXOffset, arrowYOffset)
			else
				ti.LeftIndicator:SetPoint("LEFT", frame.Name, "RIGHT", arrowXOffset, arrowYOffset)
				ti.RightIndicator:SetPoint("RIGHT", frame.Name, "LEFT", -arrowXOffset, arrowYOffset)
			end
		end

		-- Spark / Shadow
		ti.Shadow:SetBackdropBorderColor(r, g, b)
		ti.Shadow:SetAlpha(a)

		ti.Spark:SetVertexColor(r, g, b, a)
		ti.Spark:ClearAllPoints()

		if glowStyle == "style1" or glowStyle == "style5" or glowStyle == "style7" then
			ti.Shadow:SetOutside(frame.Health, E:Scale(E.PixelMode and 6 or 8), E:Scale(E.PixelMode and 6 or 8))
		elseif glowStyle == "style2" or glowStyle == "style6" or glowStyle == "style8" then
			if healthIsShown then
				local size = E.Border + 14
				ti.Spark:SetPoint("TOPLEFT", frame.Health, -(size * 2), size)
				ti.Spark:SetPoint("BOTTOMRIGHT", frame.Health, (size * 2), -size)
			else
				ti.Spark:SetPoint("TOPLEFT", frame.Name, -20, 8)
				ti.Spark:SetPoint("BOTTOMRIGHT", frame.Name, 20, -8)
			end
		end
	end
end

-- Construct_Glow is a no-op: TargetIndicator.lua creates Shadow/Spark/Indicators under frame.TargetIndicator
function NP:Construct_Glow(frame) end