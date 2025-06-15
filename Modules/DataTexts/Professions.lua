local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local join = string.join

--WoW API / Variables

local index = 1
local max_index = 1
local displayString = ""
local lastPanel

local function AddTexture(texture)
	return texture and "|T" .. texture .. ":20:20:0:0:64:64:4:55:4:55|t" or ""
end

local function OnEvent(self, event)
	lastPanel = self
	self.text:SetFormattedText(displayString, "Профессии", "")
	C_Timer:After(3,function()
		for i = 1, 4 do
			local button = _G["PrimaryProfession" .. i .. "LearnSpellButtonBottom"]
			if (button and button.data) then
				local name, _, icon = GetSpellInfo(button.data)
				if (name and icon) then
					max_index = i
				end
			end
		end
	end)
end

local function OnEnter(self)
	lastPanel = self
	DT:SetupTooltip(self)
	for i = 1, 4 do
		local button = _G["PrimaryProfession" .. i .. "LearnSpellButtonBottom"]
		if (button and button.data) then
			local name, _, icon = GetSpellInfo(button.data)
			if (name and icon) then
				if i == index then
					DT.tooltip:AddLine(join(" ", AddTexture(icon and icon or nil), name and name or ""), .31, .99, .46)
				else
					DT.tooltip:AddLine(join(" ", AddTexture(icon and icon or nil), name and name or ""), 1, 1, 1)
				end
			end
			-- local name = GetSpellInfo(PrimaryProfession4LearnSpellButtonBottom.data)
			-- DT.tooltip:AddLine(name)
		end
	end
	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine("ЛКМ", "Открыть", 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddDoubleLine("Колесико", "Выбор", 1, 1, 1, 1, 1, 0)
	DT.tooltip:Show()
end

local function OnClick(self, button)
	if button == "LeftButton" then
		local btn = _G["PrimaryProfession" .. index .. "LearnSpellButtonBottom"]
		if btn then
			btn:Click()
		end
	end
end

local function OnMouseWheel(self, delta)
	index = index - delta
	if index > max_index then
		index = max_index
	elseif index <= 1 then
		index = 1
	end
	DT.tooltip:Hide()
	OnEnter(self)
end

local function ValueColorUpdate(hex)
	displayString = join(" ", "%s%s")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end


E.valueColorUpdateFuncs[ValueColorUpdate] = true


DT:RegisterDatatext("Профессии", { "ADDON_LOADED", "TRAINER_UPDATE", "SKILL_LINES_CHANGED" }, OnEvent, nil, OnClick, OnEnter, nil,
	"Профессии", OnMouseWheel)