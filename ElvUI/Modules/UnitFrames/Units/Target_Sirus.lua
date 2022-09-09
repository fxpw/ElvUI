local E, L, V, P, G = unpack(select(2,...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

local frame = ElvUF_Target
if not frame then return end

frame.HeadHuntingWantedFrame = UF:Construct_HeadHuntingWanted(frame)