local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.deathRecap ~= true then return end

	DeathRecapFrame:StripTextures()
	S:HandleCloseButton(DeathRecapFrame.CloseXButton)
	S:HandleButton(DeathRecapFrame.CloseButton)
	S:HandleButton(DeathRecapFrame.HeadHuntingButton)
	DeathRecapFrame:SetTemplate("Transparent")

	for i = 1, 5 do
		local iconBorder = DeathRecapFrame["Recap"..i].SpellInfo.IconBorder
		local icon = DeathRecapFrame["Recap"..i].SpellInfo.Icon
		iconBorder:SetAlpha(0)
		icon:SetTexCoord(unpack(E.TexCoords))
		DeathRecapFrame["Recap"..i].SpellInfo:CreateBackdrop()
		DeathRecapFrame["Recap"..i].SpellInfo.backdrop:SetOutside(icon)
		icon:SetParent(DeathRecapFrame["Recap"..i].SpellInfo.backdrop)
	end
end

S:AddCallback("Sirus_DeathRecap", LoadSkin)