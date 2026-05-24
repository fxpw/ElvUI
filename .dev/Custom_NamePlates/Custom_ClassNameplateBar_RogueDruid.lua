ClassNameplateBarRogueDruid = {};

function ClassNameplateBarRogueDruid:OnLoad()
	self.class = "ROGUE"
	self.comboPointSize = 13;
	self.maxUsablePoints = MAX_COMBO_POINTS;
	self:SetWidth(self.comboPointSize * self.maxUsablePoints + 4 * (self.maxUsablePoints - 1));

	ClassNameplateBar.OnLoad(self);

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function ClassNameplateBarRogueDruid:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UpdateMaxPower();
	elseif event == "UNIT_COMBO_POINTS" then
		self:UpdatePower();
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:UpdateMaxPower();
	else
		ClassNameplateBar.OnEvent(self, event, ...);
	end
end

function ClassNameplateBarRogueDruid:Setup()
	local _, myclass = UnitClass("player");
	if self:MatchesClass() or myclass == "DRUID" then
		if UnitExists("target") then
			self:RegisterUnitEvent("UNIT_COMBO_POINTS", "player");

			self:ShowNameplateBar();
			self:UpdatePower();
		else
			self:Reset()
			self:UnregisterEvent("UNIT_COMBO_POINTS");

			self:HideNameplateBar();
		end
	end
end

function ClassNameplateBarRogueDruid:UpdateMaxPower()
	self:Reset()
	self:Setup()
end

function ClassNameplateBarRogueDruid:UpdatePower()
	local comboPoints = GetComboPoints("player", "target");
	if comboPoints <= 0 then
		self:Reset();
		self:HideNameplateBar();
		return
	end

	for i = 1, self.maxUsablePoints do
		local comboPointFrame = self.ComboPoints[i];
		local changed = i <= comboPoints

		if comboPointFrame.changed ~= changed then
			comboPointFrame.Point:SetAlpha(changed and 1 or 0);

			comboPointFrame.changed = changed;
		end
	end
	self:ShowNameplateBar()
end

function ClassNameplateBarRogueDruid:Reset()
	for i = 1, self.maxUsablePoints do
		local comboPointFrame = self.ComboPoints[i];
		comboPointFrame.changed = nil;
	end
end