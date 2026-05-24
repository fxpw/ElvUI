ClassNameplateBarDeathKnight = {};

function ClassNameplateBarDeathKnight:OnLoad()
	self.scale = 0.71
	self.class = "DEATHKNIGHT";
	self.powerToken = "RUNES";

	ClassNameplateBar.OnLoad(self);

	self:Setup()
end

function ClassNameplateBarDeathKnight:Setup()
	if self:MatchesClass() then
		self:RegisterEvent("RUNE_POWER_UPDATE");
		self:RegisterEvent("RUNE_TYPE_UPDATE");
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
	end

	return ClassNameplateBar.Setup(self);
end

function ClassNameplateBarDeathKnight:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		local isInitialLogin = ...
		if isInitialLogin then
			RuneFrame_FixRunes(self);
		end
		for rune in next, self.runes do
			RuneButton_Update(self.runes[rune], rune, true);
		end
	elseif event == "RUNE_POWER_UPDATE" then
		local rune, usable = ...;
		if not usable and rune and self.runes[rune] then
			self.runes[rune]:SetScript("OnUpdate", RuneButton_OnUpdate);
		elseif usable and rune and self.runes[rune] then
			self.runes[rune].shine:SetVertexColor(1, 1, 1);
			RuneButton_ShineFadeIn(self.runes[rune].shine)
		end
	elseif event == "RUNE_TYPE_UPDATE" then
		local rune = ...;
		if rune then
			RuneButton_Update(self.runes[rune], rune);
		end
	end

	return ClassNameplateBar.OnEvent(self, event, ...);
end

function ClassNameplateBarDeathKnightRuneButton_OnLoad(self)
	local parent = self:GetParent();
	if not parent.runes then
		parent.runes = {};
	end
	RuneFrame_AddRune(parent, self);

	self.rune = _G[self:GetName().."Rune"];
	self.fill = _G[self:GetName().."Fill"];
	self.shine = _G[self:GetName().."ShineTexture"];
	RuneButton_Update(self);
end