local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
-- local MM = {}
local MM = E:GetModule("MapMarkers")
local ElvUI_AllMarkers = {};
local ElvUI_ShowedMarkers = {};
local debug = false
-- local _print = print
local dprint = function(...)
	if debug then print(...) end
end
local IgnoreList = {};
-- LibStub("AceComm-3.0"):Embed(MM);
-- LibStub("AceSerializer-3.0"):Embed(MM);
local coords = {0.499, 0.751, 0.276, 0.484};
-- local mapX,mapY = WorldMapButton:GetSize()
local prefix = "ElvUI_Marker";
local texturePath = "Interface\\AddOns\\ElvUI\\Media\\Textures\\RaidIcons";
local SYNC_INFO = "|Hplayer:%1$s|h[%1$s]|h ставит метку на карту " ..
	": \n|Helvm:show:%2$s:%3$s:%4$s:nil|h|cff3588ff[Показать место]|r|h  |Helvm:ignore:%1$s|h|cff3588ff[Игнорировать метки от %1$s]|r|h"

function MM:SendMark(text, distribution)
	MM:SendCommMessage(prefix, text, distribution or "RAID");
end

local pname = UnitName("player");
function MM:ReseiveMark(text, distribution, target)
	dprint(text, distribution);
	local success, mapid, x, y, who = MM:Deserialize(text);
	mapid = tonumber(mapid)
	if success and mapid and x and y and who ~= pname and not IgnoreList[who] then
		MM:PrintMarkInfo(mapid, x, y, who);
	end
end

function MM:PrintMarkInfo(mapid, x, y, who)
	DEFAULT_CHAT_FRAME:AddMessage(string.format(SYNC_INFO,who,mapid,x,y), 0.41, 0.8, 0.94);
end

function MM:HideAll()
	for i = 1, #ElvUI_ShowedMarkers do
		ElvUI_ShowedMarkers[i]:Hide();
	end
	table.wipe(ElvUI_ShowedMarkers);
	dprint("All Hided");
end
function MM:ShowMark(i,mapid)
	local marker = ElvUI_AllMarkers[mapid][i];

	if marker.showed then
		marker:Show()
		table.insert(ElvUI_ShowedMarkers, marker);
		dprint("update(s) Marker"..mapid..i);
	elseif not marker.showed then
		marker:Hide()
		dprint("update(h) Marker"..mapid..i);
	end
end
function MM:CreateMark(mapid,IsSendedMark,x,y)
	mapid = mapid or GetCurrentMapAreaID();
	mapid = tonumber(mapid)
	if not WorldMapFrame:IsShown() and IsSendedMark then
		ToggleFrame(WorldMapFrame)
		SetMapByID(mapid-1)
	end
	local curX, curY = GetCursorPosition();
	local scale = WorldMapDetailFrame:GetEffectiveScale();
	local width, height = WorldMapDetailFrame:GetSize();
	local centerX, centerY = WorldMapDetailFrame:GetCenter();
	local adjustedX = (curX / scale - (centerX - (width * 0.5))) / width;
	local adjustedY = (centerY + (height * 0.5) - curY / scale) / height;
	x = IsSendedMark and x or adjustedX * 100;
	y = IsSendedMark and y or adjustedY * 100;
	ElvUI_AllMarkers[mapid] = ElvUI_AllMarkers[mapid] or {};
	local lastIndex = #ElvUI_AllMarkers[mapid];
	ElvUI_AllMarkers[mapid][lastIndex+1] = CreateFrame("Frame", "Marker"..mapid..lastIndex+1, WorldMapDetailFrame);
	local marker = ElvUI_AllMarkers[mapid][lastIndex+1];
	marker.name = "Marker"..mapid..lastIndex;
	marker.index = lastIndex+1;
	marker.x = x;
	marker.y = y;
	marker.Texture = marker:CreateTexture();
	marker.Texture:SetTexture(texturePath);
	marker.Texture:SetAllPoints();
	marker.Texture:SetTexCoord(unpack(coords))
	marker:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", (x / 100) * WorldMapDetailFrame:GetWidth(), (-y / 100) * WorldMapDetailFrame:GetHeight());
	marker:SetWidth(31);
	marker:SetHeight(31);
	marker:SetFrameStrata("DIALOG");
	marker:EnableMouse(true);
	marker:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("SHIFT + СКМ убрать метку", 1, 1, 1)
		GameTooltip:Show()
	end)
	marker:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	marker:SetScript("OnMouseDown",function(self,click)
		if IsShiftKeyDown() and click == "MiddleButton" then
			self:Hide();
			self.showed = false;
			dprint(self.name," Hided");
			MM:RefreshAll();
		end
	end)
	marker.showed = true;
	table.insert(ElvUI_ShowedMarkers, marker);
	marker:Show();
	dprint('added ' .. "Marker"..mapid..(lastIndex+1).. " IsSendedMark " .. (IsSendedMark and "true" or "false"));
	if IsSendedMark then
		print("Метка с координатами MapID "..mapid .." x ".. x .." y ".. y .." была добавлена на карту");
	else
		MM:SendMark(MM:Serialize(mapid, x, y, pname));
	end
end

function MM:RefreshAll()
	MM:HideAll();
	local mapid = GetCurrentMapAreaID();
	mapid = tonumber(mapid)
	ElvUI_AllMarkers[mapid] = ElvUI_AllMarkers[mapid] or {};
	local leng = #ElvUI_AllMarkers[mapid];
	if leng and leng > 0 then
		for i = 1, leng do
			MM:ShowMark(i,mapid);
		end
	end
end

local function createMark(self, link)
	local _,_, mapid, x, y = strsplit(":", link);
	mapid = tonumber(mapid)
	MM:CreateMark(mapid,true,x,y);
end
local function AddToIgnore(self,link)
	local _,_, name = strsplit(":", link);
	-- MM:CreateMark(mapid,true,x,y)
	IgnoreList[name] = true;
	print(name.." был добавлен в игнор лист меток");
end
function MM:Initialize()
	if not E.db.general.mapMarkers.enable then return end

	local _SetItemRef = SetItemRef
	function SetItemRef(link, textref, button, chatFrame)
		dprint(link, textref, button, chatFrame);
		if link:match("elvm:show") then
			createMark(chatFrame,link);
		elseif link:match("elvm:ignore") then
			AddToIgnore(chatFrame,link);
		else
			_SetItemRef(link, textref, button, chatFrame);
		end
	end


	WorldMapButton:RegisterForClicks("LeftButtonDownm", "RightButtonDown","MiddleButtonDown");
	WorldMapButton:HookScript("OnClick",function(self,click)
		dprint(click);
		if click == "MiddleButton" and not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() then
			MM:CreateMark(nil,false);
			dprint(self,click);
		end
	end)

	local function EventHandler(self, event, ...)
		MM:RefreshAll();
	end
	MM.imFrame = CreateFrame("Frame",nil,UIParent);

	MM.imFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	MM.imFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	MM.imFrame:RegisterEvent("WORLD_MAP_UPDATE");
	MM.imFrame:RegisterEvent("WORLD_MAP_NAME_UPDATE");
	MM.imFrame:SetScript("OnEvent", EventHandler);

	if E.db.general.mapMarkers.showRaidMarkers then
		MM:RegisterComm(prefix, MM.ReseiveMark);
	end

end


local function InitializeCallback()
	MM:Initialize()
end

E:RegisterInitialModule(MM:GetName(), InitializeCallback)
