local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select = select
--WoW API / Variables


local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.help then return end

end

-- S:RemoveCallback("Skin_Help")
S:AddCallback("Skin_Help", LoadSkin)