local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

local ipairs = ipairs
local tinsert = table.insert

local frames = {}

local event = CreateFrame("Frame")
local HeadHuntingWantedFrameMixin = {}
function HeadHuntingWantedFrameMixin:OnLoad()
	self:RegisterEventListener()
end
function HeadHuntingWantedFrameMixin:ASMSG_HEADHUNTING_IS_PLAYER_WANTED(msg)
	local wantedStorage 	= C_CacheInstance:Get("ASMSG_HEADHUNTING_IS_PLAYER_WANTED", {})
	local messageStorage 	= C_Split(msg, ",")
	local GUID 				= tonumber(messageStorage[E_HEADHUNTING_PLAYER_IS_WANTED.GUID])
	local isWanted 			= messageStorage[E_HEADHUNTING_PLAYER_IS_WANTED.ISWANTED] and tonumber(messageStorage[E_HEADHUNTING_PLAYER_IS_WANTED.ISWANTED])

	if not isWanted then
		return
	end

	wantedStorage[GUID] = isWanted == 1

	for _, frame in ipairs(frames) do
		UF:Update_HeadHuntingWanted(frame, true)
	end
end
Mixin(event, HeadHuntingWantedFrameMixin)
event:OnLoad()

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
			local wantedStorage = C_CacheInstance:Get("ASMSG_HEADHUNTING_IS_PLAYER_WANTED", {})
			isWanted = wantedStorage[tonumber(guid)]

			if not dontSendRequest then
				SendServerMessage("ACMSG_HEADHUNTING_IS_PLAYER_WANTED", guid)
			end
		end
	end

	if isWanted then
		frame.HeadHuntingWantedFrame:Show()
		frame.HeadHuntingWantedFrame:SetModel("SPELLS\\HuntersMark_Impact_Chest.m2")
		frame.HeadHuntingWantedFrame:SetPosition(3, 0, 1.3)
	else
		frame.HeadHuntingWantedFrame:Hide()
	end
end