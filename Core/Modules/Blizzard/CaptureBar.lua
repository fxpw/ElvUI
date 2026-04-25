local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc

local numAlwaysUpFrames = 0
local captureBarHolder = CreateFrame('Frame', 'ElvUI_CaptureBarHolder', E.UIParent)

local function captureBarUpdate(id)
	local captureBar = _G['WorldStateCaptureBar'..id]
	if captureBar then
		captureBar:ClearAllPoints()

		if id == 1 then
			captureBar:Point('CENTER', captureBarHolder, 'CENTER', 0, 0)
			captureBar.SetPoint = E.noop
		else
			captureBar:Point('TOPLEFT', _G['WorldStateCaptureBar'..id - 1], 'TOPLEFT', 0, -45)
		end
	end
end

function BL:WorldStateAlwaysUpFrame_Update()
	if numAlwaysUpFrames < _G.NUM_ALWAYS_UP_UI_FRAMES then
		for id = numAlwaysUpFrames + 1, _G.NUM_ALWAYS_UP_UI_FRAMES do
			numAlwaysUpFrames = id
		end
	end
end

function BL:PositionCaptureBar()
	captureBarHolder:SetSize(172, 16)
	captureBarHolder:Point('TOP', E.UIParent, 'TOP', 0, -150)

	hooksecurefunc('WorldStateAlwaysUpFrame_Update', BL.WorldStateAlwaysUpFrame_Update)
	hooksecurefunc(ExtendedUI['CAPTUREPOINT'], 'create', captureBarUpdate)

	if _G.NUM_EXTENDED_UI_FRAMES and _G.NUM_EXTENDED_UI_FRAMES > 0 then
		for id = 1, _G.NUM_EXTENDED_UI_FRAMES do
			captureBarUpdate(id)
		end
	end

	E:CreateMover(captureBarHolder, 'CaptureBarMover', L["Capture Bar"], nil, nil, nil, 'ALL')
end