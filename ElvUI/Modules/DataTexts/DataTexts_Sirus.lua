local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:NewModule("Sirus_DataTexts")
local DT = E:GetModule("DataTexts")

local pairs = pairs

function mod:GetPanelByDataTextName(name)
	for _, data in pairs(DT.RegisteredPanels) do
		for _, panelData in pairs(data.dataPanels) do
			if panelData.name == name then
				return panelData
			end
		end
	end
end

function mod:Initialize()
	self:HookFriens()
	self:HookGuild()
end

local function InitializeCallback()
	mod:Initialize()
end

E:RegisterModule(mod:GetName(), InitializeCallback)