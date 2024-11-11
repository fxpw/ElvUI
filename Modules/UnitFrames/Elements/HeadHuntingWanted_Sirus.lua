local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

local ipairs = ipairs
local tinsert = table.insert

local frames = {}

local event = CreateFrame("Frame")
-- local HeadHuntingWantedFrameMixin = {}
-- function HeadHuntingWantedFrameMixin:OnLoad()
-- 	-- if self.RegisterEventListener then
-- 		self:RegisterEventListener()
-- 	-- end
-- end
-- function HeadHuntingWantedFrameMixin:ASMSG_HEADHUNTING_IS_PLAYER_WANTED(msg)
-- 	local wantedStorage 	= C_CacheInstance:Get("ASMSG_HEADHUNTING_IS_PLAYER_WANTED", {})
-- 	local messageStorage 	= C_Split(msg, ",")
-- 	local GUID 				= tonumber(messageStorage[E_HEADHUNTING_PLAYER_IS_WANTED.GUID])
-- 	local isWanted 			= messageStorage[E_HEADHUNTING_PLAYER_IS_WANTED.ISWANTED] and tonumber(messageStorage[E_HEADHUNTING_PLAYER_IS_WANTED.ISWANTED])

-- 	if not isWanted then
-- 		return
-- 	end

-- 	wantedStorage[GUID] = isWanted == 1

-- 	for _, frame in ipairs(frames) do
-- 		UF:Update_HeadHuntingWanted(frame, true)
-- 	end
-- end
-- Mixin(event, HeadHuntingWantedFrameMixin)
-- do
-- 	event:OnLoad()
-- end

event:RegisterEvent("CHAT_MSG_ADDON")
event:SetScript("OnEvent",function(a1, prefix, eventIn, msg, sender)

	-- if eventIn ~= "ASMSG_HEADHUNTING_IS_PLAYER_WANTED" then return end

	-- local wantedStorage 	= C_CacheInstance:Get("ASMSG_HEADHUNTING_IS_PLAYER_WANTED", {})
	-- local messageStorage 	= C_Split(msg, ",")
	-- local GUID 				= tonumber(messageStorage[E_HEADHUNTING_PLAYER_IS_WANTED.GUID])
	-- local isWanted 			= messageStorage[E_HEADHUNTING_PLAYER_IS_WANTED.ISWANTED] and tonumber(messageStorage[E_HEADHUNTING_PLAYER_IS_WANTED.ISWANTED])

	-- if not isWanted then
	-- 	return
	-- end
	-- if not GUID then return end
	-- wantedStorage[GUID] = isWanted == 1

	for _, frame in ipairs(frames) do
		UF:Update_HeadHuntingWanted(frame, true)
	end
end)

local function PostUpdate(frame, e)
	if e == "OnShow" or e == "PLAYER_TARGET_CHANGED" then
		UF:Update_HeadHuntingWanted(frame)
	end
end

function UF:Construct_HeadHuntingWanted(frame)
	frame.PostUpdate = PostUpdate

	local wantedFrame = CreateFrame("PlayerModel", nil, frame.RaisedElementParent)
	wantedFrame:SetSize(100, 100)
	wantedFrame:SetPoint("CENTER", frame.Health)

	tinsert(frames, frame)
	return wantedFrame
end

function UF:Update_HeadHuntingWanted(frame, dontSendRequest)
	local isWanted
	if frame.unit and UnitExists(frame.unit) and UnitIsPlayer(frame.unit) then
		local guid = UnitGUID(frame.unit)
		if guid then
			-- local wantedStorage = C_CacheInstance:Get("ASMSG_HEADHUNTING_IS_PLAYER_WANTED", {})
			isWanted = C_Unit.IsHeadHuntingWanted(frame.unit)


			if not dontSendRequest then
				SendServerMessage("ACMSG_HEADHUNTING_IS_PLAYER_WANTED", guid)
			end
		end
	end

	if isWanted then
		frame.HeadHuntingWantedFrame:Show()
		frame.HeadHuntingWantedFrame:SetModel("SPELLS/DarkmoonVengeance_Impact_Head.m2")
		frame.HeadHuntingWantedFrame:SetPosition(3, 0, 1.9)
	else
		frame.HeadHuntingWantedFrame:Hide()
	end
end
