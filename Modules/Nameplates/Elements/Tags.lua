local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM
local pairs = pairs

local function CustomTextAnchor(nameplate)
	return (nameplate and nameplate.Health) or nameplate
end

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
	if hide then
		nameplate.Name:ClearAllPoints()
		nameplate.Name:SetJustifyH('CENTER')
		nameplate.Name:SetPoint('CENTER', nameplate.Health or nameplate)
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

	if nameplate.unit then
		NP:RegisterAuraUnitEvents(nameplate, nameplate.unit)
	end
end

function NP:Update_CustomTexts(nameplate)
	local db = NP:PlateDB(nameplate)
	local customDB = db and db.customTexts
	nameplate.customTexts = nameplate.customTexts or {}

	-- Hide stale texts that were removed from profile.
	for objectName, object in pairs(nameplate.customTexts) do
		if not (customDB and customDB[objectName]) then
			nameplate:Untag(object)
			object:Hide()
			nameplate.customTexts[objectName] = nil
		end
	end

	if not customDB then return end

	for objectName, objectDB in pairs(customDB) do
		local object = nameplate.customTexts[objectName]
		if not object then
			local parent = nameplate.RaisedElement or nameplate
			object = parent:CreateFontString(nil, 'OVERLAY')
			nameplate.customTexts[objectName] = object
		end

		if objectDB.enable == nil then
			objectDB.enable = true
		end
		objectDB.attachTextTo = 'Health'

		object:FontTemplate(
			LSM:Fetch('font', objectDB.font or NP.db.font),
			objectDB.size or NP.db.fontSize,
			objectDB.fontOutline or NP.db.fontOutline
		)
		object:SetJustifyH(objectDB.justifyH or 'CENTER')
		object:ClearAllPoints()
		object:Point(
			objectDB.justifyH or 'CENTER',
			CustomTextAnchor(nameplate),
			objectDB.justifyH or 'CENTER',
			objectDB.xOffset or 0,
			objectDB.yOffset or 0
		)

		if objectDB.enable and objectDB.text_format and objectDB.text_format ~= '' then
			nameplate:Tag(object, objectDB.text_format)
			object:UpdateTag()
			object:Show()
		else
			nameplate:Untag(object)
			object:Hide()
		end
	end
end
