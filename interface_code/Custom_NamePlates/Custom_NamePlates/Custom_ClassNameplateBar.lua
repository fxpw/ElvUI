ClassNameplateBar = {};

function ClassNameplateBar:OnLoad()
	-- Initialize these variables in the class-specific OnLoad mixin function. Also make sure to implement
	-- an UpdatePower() mixin function that handles UI changes for whenever the power display changes

	self:SetScale(self.scale or 1);
	self:Setup();
end

function ClassNameplateBar:OnEvent(event, ...)
	if ( event == "UNIT_POWER_FREQUENT" ) then
		local unitTag, powerToken = ...;
		if (unitTag == "player" and self.powerToken == powerToken ) then
			self:UpdatePower();
			return true;
		end
	elseif ( event == "UNIT_MAXPOWER" ) then
		local unitTag = ...;
		if (unitTag == "player") then
			self:UpdateMaxPower();
			return true;
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdatePower();
		return true;
	elseif (event == "PLAYER_TALENT_UPDATE" ) then
		self:Setup();
		self:UpdatePower();
		return true;
	end
	return false;
end

function ClassNameplateBar:OnShow()
	self:OnSizeChanged();
end

function ClassNameplateBar:OnSizeChanged()
	-- override if needed
end

function ClassNameplateBar:MatchesClass()
	local _, myclass = UnitClass("player");
	return myclass == self.class;
end

function ClassNameplateBar:MatchesSpec()
--	if ( not self.spec ) then
		return true;
--	end
--	local myspec = GetSpecialization();
--	return myspec == self.spec;
end

function ClassNameplateBar:Setup()
	local showBar = false;

	if self:MatchesClass() then
		if self:MatchesSpec() then
			self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			showBar = true;
		else
			self:UnregisterEvent("UNIT_MAXPOWER");
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		end

		self:RegisterEvent("PLAYER_TALENT_UPDATE");
	end

	if showBar then
		self:ShowNameplateBar();
		self:UpdateMaxPower();
	else
		self:HideNameplateBar();
	end

	return showBar;
end

function ClassNameplateBar:ShowNameplateBar()
	self:Show();
	NamePlateDriverFrame:SetClassNameplateBar(self);
end

function ClassNameplateBar:HideNameplateBar()
	self:Hide();
	if (NamePlateDriverFrame:GetClassNameplateBar() == self) then
		NamePlateDriverFrame:SetClassNameplateBar(nil);
	end
end

function ClassNameplateBar:TurnOn(frame, texture, toAlpha)
--	ClassPowerBar:TurnOn(frame, texture, toAlpha);
end

function ClassNameplateBar:TurnOff(frame, texture, toAlpha)
--	ClassPowerBar:TurnOff(frame, texture, toAlpha);
end

function ClassNameplateBar:UpdateMaxPower()
end

function ClassNameplateBar:UpdatePower()
end

function ClassNameplateBar:OnOptionsUpdated()
end

function ClassNameplateBar:GetUnit()
	return "player";
end

--------------------------------------------------------------------------------
--
-- ClassNameplateManaBar
--
--------------------------------------------------------------------------------

ClassNameplateManaBar = {};

local NameplatePowerBarColor = {
	["MANA"] = { r = 0.1, g = 0.25, b = 1.00 }
};

function ClassNameplateManaBar:OnLoad()
	ClassNameplateBar.OnLoad(self);

	self.Border:SetVertexColor(0, 0, 0, 1);

	self:SetupBar()
	self:SetScript("OnUpdate", self.UpdatePower)
end

function ClassNameplateManaBar:OnEvent(event, ...)
	if event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD"
			or event == "UNIT_MAXMANA" or event == "UNIT_MAXRAGE" or event == "UNIT_MAXFOCUS" or event == "UNIT_MAXENERGY" or event == "UNIT_MAXRUNIC_POWER" then
		self:SetupBar();
		if event == "UNIT_MAXMANA" or event == "UNIT_MAXRAGE" or event == "UNIT_MAXFOCUS" or event == "UNIT_MAXENERGY" or event == "UNIT_MAXRUNIC_POWER" then
			ClassNameplateBar.OnEvent(self, event, ...);
		end
	elseif event == "UNIT_MANA" or event == "UNIT_RAGE" or event == "UNIT_FOCUS" or event == "UNIT_ENERGY" or event == "UNIT_RUNIC_POWER" then
		self:UpdatePower();
	else
		ClassNameplateBar.OnEvent(self, event, ...);
	end
end

function ClassNameplateManaBar:Setup()
	self:RegisterUnitEvent("UNIT_MANA", "player");
	self:RegisterUnitEvent("UNIT_RAGE", "player");
	self:RegisterUnitEvent("UNIT_FOCUS", "player");
	self:RegisterUnitEvent("UNIT_ENERGY", "player");
	self:RegisterUnitEvent("UNIT_RUNIC_POWER", "player");
	self:RegisterUnitEvent("UNIT_MAXMANA", "player");
	self:RegisterUnitEvent("UNIT_MAXRAGE", "player");
	self:RegisterUnitEvent("UNIT_MAXFOCUS", "player");
	self:RegisterUnitEvent("UNIT_MAXENERGY", "player");
	self:RegisterUnitEvent("UNIT_MAXRUNIC_POWER", "player");
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	NamePlateDriverFrame:SetClassNameplateManaBar(self);
end

function ClassNameplateManaBar:SetupBar()
	local powerType, powerToken = UnitPowerType("player");
	if powerToken and powerToken ~= "" then
		local info = NameplatePowerBarColor[powerToken];
		if not info then
			info = PowerBarColor[powerToken];
		end
		self:SetStatusBarColor(info.r, info.g, info.b);
	end

	self:UpdateMaxPower();
	self:UpdatePower();
	self:OnOptionsUpdated();
end

function ClassNameplateManaBar:UpdateMaxPower()
	local maxValue = UnitPowerMax("player", self.powerType);
	self:SetMinMaxValues(0, maxValue);
end

function ClassNameplateManaBar:UpdatePower()
	local currValue = UnitPower("player", self.powerType);
	if currValue ~= self.currValue then
		self:SetValue(currValue);
		self.currValue = currValue;
	end
end

function ClassNameplateManaBar:OnOptionsUpdated()
	self:OnSizeChanged();
end

function ClassNameplateManaBar:OnSizeChanged(width, height, script) -- override
	if script and width then
		self:SetWidth(width)
		return
	end
	PixelUtil.SetHeight(self, DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight);
	self.Border:UpdateSizes();
end

function ClassNameplateManaBar:GetUnit()
	return "player";
end
