local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local format = string.format
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.watchframe or not WatchFrame then return end


end

-- S:RemoveCallback("Skin_WatchFrame")
S:AddCallback("Skin_WatchFrame", LoadSkin)