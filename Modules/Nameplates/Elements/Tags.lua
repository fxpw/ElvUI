local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

function NP:Construct_TagText(nameplate)
	local Text = nameplate:CreateFontString(nil, 'OVERLAY')
	Text:FontTemplate(LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	return Text
end

function NP:Update_TagText(nameplate, element, db, hide, anchor)
	if not db then return end

	-- textFormat (new oUF style: '[name:long]') takes precedence over format (old style)
	local tagFormat = db.textFormat or db.format

	if db.enable and not hide and tagFormat and tagFormat ~= '' then
		nameplate:Tag(element, tagFormat)
		element:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
		element:UpdateTag()

		element:ClearAllPoints()
		element:Point(E.InversePoints[db.position], anchor or nameplate.Health or nameplate, db.position, db.xOffset, db.yOffset)
		element:Show()
	else
		nameplate:Untag(element)
		element:Hide()
	end
end

function NP:Update_Tags(nameplate, nameOnlySF)
	local db = NP:PlateDB(nameplate)
	local hide = db.nameOnly or nameOnlySF

	-- Name uses oUF tag system (textFormat = '[name:long]' etc.)
	NP:Update_TagText(nameplate, nameplate.Name, db.name, nil, nameplate.Health)
	-- nameOnly: center the name in the plate regardless of db.name.position settings
	if db.nameOnly then
		nameplate.Name:ClearAllPoints()
		nameplate.Name:SetJustifyH('CENTER')
		nameplate.Name:SetPoint('CENTER', nameplate.RaisedElement or nameplate)
		nameplate.Name:SetParent(nameplate.RaisedElement or nameplate)
	end

	-- Level uses smartlevel oUF tag
	if db.level and db.level.enable and not hide then
		local lvlFmt = db.level.textFormat or db.level.format or '[smartlevel]'
		nameplate:Tag(nameplate.Level, lvlFmt)
		nameplate.Level:FontTemplate(LSM:Fetch('font', db.level.font), db.level.fontSize, db.level.fontOutline)
		nameplate.Level:UpdateTag()
		nameplate.Level:ClearAllPoints()
		nameplate.Level:Point(
			E.InversePoints[db.level.position],
			nameplate.Health or nameplate,
			db.level.position,
			db.level.xOffset,
			db.level.yOffset
		)
		nameplate.Level:Show()
	else
		nameplate:Untag(nameplate.Level)
		nameplate.Level:Hide()
	end

	-- Health/Power text: use E:GetFormattedText via a direct tag if configured
	if db.health and db.health.text then
		NP:Update_TagText(nameplate, nameplate.Health.Text, db.health.text, hide, nameplate.Health)
	end
	if db.power and db.power.text then
		NP:Update_TagText(nameplate, nameplate.Power.Text, db.power.text, hide, nameplate.Power)
	end
end
