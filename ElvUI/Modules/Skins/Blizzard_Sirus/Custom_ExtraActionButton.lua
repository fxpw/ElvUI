local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.extraButton ~= true then return end

	for i = 1, #ExtraActionBarFrame.ExtraButtons do
		local button = ExtraActionBarFrame.ExtraButtons[i]
		button:SetTemplate()
		button:StyleButton()

		button.icon:SetDrawLayer("BORDER")
		button.icon:SetInside()
		button.icon:SetTexCoord(unpack(E.TexCoords))

		button:SetNormalTexture("")

		if E.private.skins.cleanExtraButton then
			button.style:SetAlpha(0)
		else
			button.style:SetDrawLayer("BACKGROUND")
		end

		button.cooldown:SetInside()
		E:RegisterCooldown(button.cooldown)
		E:CreateCooldownTimer(button.cooldown)
		button.cooldown.timer:SetAlpha(1)
	end
end

S:AddCallback("Custom_ExtraActionButton", LoadSkin)