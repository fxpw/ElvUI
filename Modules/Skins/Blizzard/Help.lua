local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins");

--Lua functions
local _G = _G
local select = select
--WoW API / Variables


local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.help then return end
	S:HandleFrame(HelpFrame,true);
	S:HandleCloseButton(HelpFrameCloseButton);
	S:HandleFrame(HelpFrameHeader,true);
	local btn
	for i = 1,16 do
		btn = _G["HelpFrameButton"..i];
		if btn then
			S:HandleButton(btn);
			btn:StripTextures(nil,true);
			btn.icon:SetAlpha(1);
		end
	end
	local handledButtons = {
		"HelpFrameAccountSecurityTwoFA",
		"HelpFrameSupportSubmitSuggestion",
		"HelpFrameSupportItemRestoration",
		"HelpFrameSupportBugReport",
	}
	for i = 1, #handledButtons do
		btn = _G[handledButtons[i]]
		if btn then
			S:HandleButton(btn);
			btn:StripTextures(nil,true);
			btn.icon:SetAlpha(1);
		end
	end
	local texture = select(3,HelpFrameTicket:GetChildren())
	texture:StripTextures()
	texture:CreateBackdrop("Transparent")
	-- S:HandleButton(HelpFrameCharacterStuckHearthstone)
	S:HandleIcon(HelpFrameCharacterStuckHearthstone.IconTexture);
	S:HandleScrollBar(HelpFrameKnowledgebaseScrollFrameScrollBar);
	S:HandleScrollBar(HelpFrameKnowledgebaseScrollFrame2ScrollBar);
	HelpFrameMainInset:Hide();
	HelpFrameLeftInset:Hide();
	S:HandleEditBox(HelpFrameKnowledgebaseSearchBox);
	S:HandleButton(HelpFrameKnowledgebaseSearchButton);
	S:HandleButton(GMChatOpenLog);
	S:HandleButton(HelpFrameCharacterStuckStuck);
	S:HandleButton(HelpFrameTicketSubmit);
	S:HandleButton(HelpFrameTicketCancel);
	-- S:HandleEditBox(HelpFrameOpenTicketEditBox);
	S:HandleScrollBar(HelpFrameTicketScrollFrameScrollBar);
end

-- S:RemoveCallback("Skin_Help")
S:AddCallback("Skin_Help", LoadSkin)