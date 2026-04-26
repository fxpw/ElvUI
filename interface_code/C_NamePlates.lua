---@alias C_Nameplate.CVars
---| '"nameplateDistance"'					# [(number) default=41] Sets the display distance of nameplates in yards
---| '"nameplateEnableNew"'
---| '"nameplateOffsetY"'
---| '"nameplateTargetRadialPosition"'
---| '"nameplateOtherAtBase"'
---| '"nameplateMaxDistance"'
---| '"nameplateShowSelf"'
---| '"NameplatePersonalShowAlways"'
---| '"NameplatePersonalShowInCombat"'
---| '"NameplatePersonalShowWithTarget"'
---| '"NameplatePersonalOffsetY"'
---| '"NameplatePersonalClickThrough"'
---| '"nameplateGlobalScale"'
---| '"nameplateMinScale"'
---| '"nameplateMinScaleDistance"'
---| '"nameplateMaxScale"'
---| '"nameplateMaxScaleDistance"'
---| '"nameplateSelectedScale"'
---| '"nameplateMinAlpha"'
---| '"nameplateMinAlphaDistance"'
---| '"nameplateMaxAlpha"'
---| '"nameplateMaxAlphaDistance"'
---| '"nameplateSelectedAlpha"'
---| '"nameplateSelfAlpha"'
---| '"nameplateOccludedAlphaMult"'
---| '"nameplateVerticalScale"'
---| '"nameplateHorizontalScale"'
---| '"nameplateShowOnlyNames"'
---| '"nameplateShowDebuffsOnFriendly"'
---| '"nameplateResourceOnTarget"'
---| '"nameplateClassResourceTopInset"'
---| '"ShowClassColorInFriendlyNameplate"'
---| '"ShowNamePlateLoseAggroFlash"'



---@alias C_Nameplate.Events
---| '"NAME_PLATE_CREATED"'			# (table) namePlateObject
---| '"NAME_PLATE_UNIT_ADDED"'		# (string) unitToken
---| '"NAME_PLATE_UNIT_REMOVED"'	# (string) unitToken






---Improved version with 'useExtendedColors' argument
---@param unitToken string
---@param useExtendedColors bool?
---@return number red
---@return number green
---@return number blue
---@return number alpha
function UnitSelectionColor(unitToken, useExtendedColors) end



---@param unitToken string
---@return bool shouldDisplayName
function UnitShouldDisplayName(unitToken) end






C_NamePlate = {}

---@return bool isVisible
function C_NamePlate.GetInWorldUIVisibility() end

---@param isVisible bool
function C_NamePlate.SetInWorldUIVisibility(isVisible) end



---return 1/nil
---@return bool isClickThrough
function C_NamePlate.GetNamePlateEnemyClickThrough() end

---@param isClickThrough bool
function C_NamePlate.SetNamePlateEnemyClickThrough(isClickThrough) end



---return 1/nil
---@return number? isClickThrough
function C_NamePlate.GetNamePlateFriendlyClickThrough() end

---@param isClickThrough bool
function C_NamePlate.SetNamePlateFriendlyClickThrough(isClickThrough) end



---@return number left
---@return number right
---@return number top
---@return number bottom
function C_NamePlate.GetNamePlateEnemyPreferredClickInsets() end

---@param left number
---@param right number
---@param top number
---@param bottom number
function C_NamePlate.SetNamePlateEnemyPreferredClickInsets(left, right, top, bottom) end



---@return number left
---@return number right
---@return number top
---@return number bottom
function C_NamePlate.GetNamePlateFriendlyPreferredClickInsets() end

---@param left number
---@param right number
---@param top number
---@param bottom number
function C_NamePlate.SetNamePlateFriendlyPreferredClickInsets(left, right, top, bottom) end



---@return number width
---@return number height
function C_NamePlate.GetNamePlateEnemySize() end

---@param width number
---@param height number
function C_NamePlate.SetNamePlateEnemySize(width, height) end



---@return number width
---@return number height
function C_NamePlate.GetNamePlateFriendlySize() end

---@param width number
---@param height number
function C_NamePlate.SetNamePlateFriendlySize(width, height) end



---return 1/nil
---@return number? isClickThrough
function C_NamePlate.GetNamePlateSelfClickThrough() end

---@param isClickThrough bool
function C_NamePlate.SetNamePlateSelfClickThrough(isClickThrough) end


---@return number left
---@return number right
---@return number top
---@return number bottom
function C_NamePlate.GetNamePlateSelfPreferredClickInsets() end

---@param left number
---@param right number
---@param top number
---@param bottom number
function C_NamePlate.SetNamePlateSelfPreferredClickInsets(left, right, top, bottom) end



---@return number left
---@return number right
---@return number top
---@return number bottom
function C_NamePlate.GetTargetClampingInsets() end

---@param left number
---@param right number
---@param top number
---@param bottom number
function C_NamePlate.SetTargetClampingInsets(left, right, top, bottom) end



---@return number width
---@return number height
function C_NamePlate.GetNamePlateSelfSize() end

---@param width number
---@param height number
function C_NamePlate.SetNamePlateSelfSize(width, height) end



---@param unitToken string
---@return table? namePlateObject
function C_NamePlate.GetNamePlateForUnit(unitToken) end



---@return table<integer, table> @table<index, namePlateObject>
function C_NamePlate.GetNamePlates() end
