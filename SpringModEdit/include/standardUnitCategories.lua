-- $Id: standardUnitCategories.lua 3628 2009-01-01 19:39:40Z evil4zerggin $
local thisFile = "standardUnitCategories"

Editor.Echo("Standard \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

function StandardUnitCategories(doPreviewOnly)
	Editor.Echo("----------------------------------------------------------------\n")
	Editor.Echo("Begin " .. thisFile .. "\n", "Black")
	Editor.Echo("----------------------------------------------------------------\n")
	
	local doCategory = true
	local deleteUnitTargetTags = true
	local doOnlyTarget = true
	local doBadTarget = true
	local doShields = true
	local doNoChase = true
	
	local unsafeAoE = 64
	local noFixedWingReload = 5
	local badToF = 1
	local badBeamTime = 0.5
	
	local allCats = "SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK FEATURE"
	
	local ignore = {
		--armcarry = true,
		--corcarry = true,
		--fakeunit_smallping = true,
		--tinyradar = true,
		--chicken_digger_b = true,
		--chickenq = true,
		--armcent = true,
	}
	----------------------------------------------------------------
	-- 1. Set new category
	----------------------------------------------------------------
	local function SetNewCategory(unit)
		local echoFront = unit.unitname
		local newCatTable = {}
		
		if GetUnitIsMobile(unit) then
			--main cats: what the unit does when you place it in water
			if (unit.unitname == "owl") then
				newCatTable["SATELLITE"] = true
			elseif (unit.unitname == "chickenq") then
				SetTableValue(unit, "category", allCats, doPreviewOnly, echoFront, "Black")
				return
			elseif (ToBool(unit.canFly)) then
				if (GetUnitIsGunship(unit)) then
					newCatTable["GUNSHIP"] = true
				else
					newCatTable["FIXEDWING"] = true
				end
			elseif unit.movementClass and string.find(unit.movementClass, "HOVER") then
				if (ToBool(unit.canHover)) then
		 			newCatTable["HOVER"] = true
		 		else
		 			newCatTable["SWIM"] = true
		 		end
			elseif (GetUnitIsFloating(unit)) then
				newCatTable["SHIP"] = true
			elseif GetUnitIsSub(unit) then
				newCatTable["SUB"] = true
			else
				newCatTable["LAND"] = true
			end
		else
		if (ToBool(unit.isFeature)) then
				newCatTable["FEATURE"] = true
			elseif (GetUnitIsFloating(unit)) then
				newCatTable["FLOAT"] = true
			else
				newCatTable["SINK"] = true
			end
		end
		
		--miscellaneous
		
		if (GetUnitIsFireproof(unit)) then
			newCatTable["FIREPROOF"] = true
		end
		
		if (not GetUnitHasAttack(unit)) then
			newCatTable["UNARMED"] = true
		end
		
		SetTableValue(unit, "category", TableToCategories(newCatTable), doPreviewOnly, echoFront, "Black")
	end
	
	----------------------------------------------------------------
	-- 2. Remove unit-level tags
	----------------------------------------------------------------
	local function DeleteUnitTargetTags(unit)
		local echoFront = unit.unitname
		SetTableValue(unit, "badTargetCategory", nil, doPreviewOnly, echoFront, "Orange")
		SetTableValue(unit, "onlyTargetCategory", nil, doPreviewOnly, echoFront, "Orange")
	end
	
	----------------------------------------------------------------
	-- 3. Weapons
	----------------------------------------------------------------
	
	local function SetNewWeaponCategories(unit)
	
	----------------------------------------------------------------
	-- 3a. OnlyTarget
	----------------------------------------------------------------
	
		local function SetNewOnlyTargetCategory(weapon, weaponDef)
			local echoFront = unit.unitname .. " weapon " .. weapon.def
			
			SetTableValue(weaponDef, "toAirWeapon", nil, doPreviewOnly, echoFront, "Green")
			
			local newCatTable = {}
			local oldCatTable = CategoriesToTable(weapon.onlyTargetCategory)
			
			local shootSatellites = {
				screamer = true,
				mercury = true,
			}
			
			local groundOnly = {
				armbrawl = true,
				armcybr2 = true,
				armthund2 = true,
				corgripn2 = true,
				armpnix2 = true,
				armcybr = true,
			}
			
			local ignore = {
				noruas = true,
			}
			
			if (ignore[unit.unitname]) then return end
			
			if (weapon.slaveTo) then
				local master = unit.weapons[ToNumber(weapon.slaveTo)]
				if (master) then
					SetTableValue(weapon, "onlyTargetCategory", master.onlyTargetCategory, doPreviewOnly, echoFront, "Green")
					return
				end
			end
			
			if (oldCatTable and oldCatTable["NONE"]) then
				SetTableValue(weapon, "onlyTargetCategory", "NONE", doPreviewOnly, echoFront, "Green")
				return
			end
			
			if (string.find(weapon.def, "DISINT")
					or ToBool(weaponDef.isShield)
					or ToBool(weaponDef.interceptor)
					or GetWeaponIsBogusMissile(weaponDef)) then
				SetTableValue(weapon, "onlyTargetCategory", nil, doPreviewOnly, echoFront, "Green")
				return
			end
			
			if string.find(weapon.def, "GRAVITY") then
				SetTableValue(weapon, "onlyTargetCategory", "FIXEDWING HOVER SWIM LAND", doPreviewOnly, echoFront, "Green")
				return
			end
			
			if (GetWeaponDefIsToAirWeapon(weaponDef) or (weapon.onlyTargetCategory == "VTOL") or (weapon.onlyTargetCategory == "FIXEDWING GUNSHIP")) then
				if shootSatellites[unit.unitname] then
					SetTableValue(weapon, "onlyTargetCategory", "FIXEDWING GUNSHIP SATELLITE", doPreviewOnly, echoFront, "Green")
				else
					SetTableValue(weapon, "onlyTargetCategory", "FIXEDWING GUNSHIP", doPreviewOnly, echoFront, "Green")
				end
				SetTableValue(weaponDef, "canattackground", false, doPreviewOnly, echoFront, "Green")
				return
			end
			
			if shootSatellites[unit.unitname] then
				newCatTable["SATELLITE"] = true
			end 
			
			if (weaponDef.weaponType == "TorpedoLauncher") then
				newCatTable["FIXEDWING"] = true
				newCatTable["GUNSHIP"] = true
				newCatTable["SHIP"] = true
				newCatTable["SUB"] = true
				newCatTable["FLOAT"] = true
				newCatTable["SINK"] = true
				newCatTable["LAND"] = true
				newCatTable["SWIM"] = true
				SetTableValue(weapon, "onlyTargetCategory", TableToCategories(newCatTable), doPreviewOnly, echoFront, "Green")
				return
			end
			
			if ( --don't target any air
						--unsafe AoE
						((ToNumber(weaponDef.areaOfEffect) >= unsafeAoE)
							and not (
								ToBool(weaponDef.burnblow)
								or GetWeaponIsGuidedMissile(weaponDef)
							)
						)
						or ToBool(weaponDef.dropped)
						or GetWeaponIsFlamethrower(weaponDef)
						or ToBool(unit.highTrajectory)
						or GetWeaponIsMelee(weapon, weaponDef)
						or ToBool(weaponDef.paralyzer)
						or weaponDef.weaponType == "StarburstLauncher"
						or groundOnly[unit.unitname]
				 ) then
				newCatTable["HOVER"] = true
				newCatTable["FLOAT"] = true
				newCatTable["SINK"] = true
				newCatTable["SHIP"] = true
				newCatTable["SUB"] = true
				newCatTable["LAND"] = true
				newCatTable["SWIM"] = true
			elseif (not GetWeaponIsGuidedMissile(weaponDef)
				and (ToNumber(weaponDef.reloadtime) >= noFixedWingReload
						)	
					) then --target gunships but not fixed wing
				newCatTable["HOVER"] = true
				newCatTable["FLOAT"] = true
				newCatTable["GUNSHIP"] = true
				newCatTable["SINK"] = true
				newCatTable["SHIP"] = true
				newCatTable["SUB"] = true
				newCatTable["LAND"] = true
				newCatTable["SWIM"] = true
			else
				newCatTable["HOVER"] = true
				newCatTable["FIXEDWING"] = true
				newCatTable["FLOAT"] = true
				newCatTable["GUNSHIP"] = true
				newCatTable["SINK"] = true
				newCatTable["SHIP"] = true
				newCatTable["SUB"] = true
				newCatTable["LAND"] = true
				newCatTable["SWIM"] = true
			end
			
			if not (ToBool(weaponDef.waterWeapon)) then
				newCatTable["SUB"] = nil
			end
			
			SetTableValue(weapon, "onlyTargetCategory", TableToCategories(newCatTable), doPreviewOnly, echoFront, "Green")
		end
		
		local function SetNewBadTargetCategory(weapon, weaponDef)
			local echoFront = unit.unitname .. " weapon " .. weapon.def
			local onlyCatTable = CategoriesToTable(weapon.onlyTargetCategory)
			local newCatTable = {}
			
			if (weapon.slaveTo) then
				local master = unit.weapons[ToNumber(weapon.slaveTo)]
				if (master) then
					SetTableValue(weapon, "badTargetCategory", master.badTargetCategory, doPreviewOnly, echoFront, "Green")
					return
				end
			end
			
			if (string.find(weapon.def, "DISINT")
					or ToBool(weaponDef.isShield)
					or ToBool(weaponDef.interceptor)) then
				SetTableValue(weapon, "badTargetCategory", nil, doPreviewOnly, echoFront, "Blue")
				return
			end
			
			if (weapon.onlyTargetCategory == "NONE") then
				SetTableValue(weapon, "badTargetCategory", nil, doPreviewOnly, echoFront, "Blue")
				return
			end
			
			if (GetWeaponIsBogusMissile(weaponDef)) then
				SetTableValue(weapon, "badTargetCategory", allCats, doPreviewOnly, echoFront, "Blue")
				return
			end
			
			if (GetWeaponIsFlamethrower(weaponDef)) then
				newCatTable["FIREPROOF"] = true
			end
			
			--[[
			if (ToBool(weaponDef.waterWeapon)) then
				newCatTable["UNARMED"] = true
			end
			]]
			
			--prefer statics
			if (ToBool(weaponDef.dropped) or ToBool(weaponDef.vlaunch) or ToBool(unit.highTrajectory)) then
				newCatTable["SATELLITE"] = true
				newCatTable["GUNSHIP"] = true
				newCatTable["FIXEDWING"] = true
				newCatTable["HOVER"] = true
				newCatTable["SHIP"] = true
				newCatTable["SUB"] = true
				newCatTable["LAND"] = true
				newCatTable["SWIM"] = true
			end
			
			--prefer not to shoot fixed wing unless guided missile or hitscan
			if (not GetWeaponIsGuidedMissile(weaponDef) 
			and not (weaponDef.weaponType == "BeamLaser" and ToNumber(weaponDef.beamTime) < badBeamTime and ToNumber(weaponDef.targetMoveError) < 0.01)) then
				if (onlyCatTable and onlyCatTable["FIXEDWING"]) then
					newCatTable["FIXEDWING"] = true
				else
					newCatTable["GUNSHIP"] = true
				end
			elseif GetWeaponDefIsToAirWeapon(weaponDef) then --aa missiles and lasers prefer fixedwing
				newCatTable["GUNSHIP"] = true
			end
			
			--prefer land or air
			if (GetWeaponDefDamage(weaponDef, "planes") < GetWeaponDefDamage(weaponDef, "default")) then
				newCatTable["SATELLITE"] = true
				newCatTable["GUNSHIP"] = true
				newCatTable["FIXEDWING"] = true
			elseif (GetWeaponDefDamage(weaponDef, "planes") > GetWeaponDefDamage(weaponDef, "default")) then
				newCatTable["HOVER"] = true
				newCatTable["FLOAT"] = true
				newCatTable["SINK"] = true
				newCatTable["SHIP"] = true
				newCatTable["SUB"] = true
				newCatTable["LAND"] = true
				newCatTable["SWIM"] = true
			end
			
			if (weapon.onlyTargetCategory) then
				if (not onlyCatTable["GUNSHIP"]) then
					newCatTable["GUNSHIP"] = nil
				end
				if (not onlyCatTable["FIXEDWING"]) then
					newCatTable["FIXEDWING"] = nil
				end
				if (not onlyCatTable["HOVER"]) then
					newCatTable["HOVER"] = nil
				end
				if (not onlyCatTable["FLOAT"]) then
					newCatTable["FLOAT"] = nil
				end
				if (not onlyCatTable["SINK"]) then
					newCatTable["SINK"] = nil
				end
				if (not onlyCatTable["SATELLITE"]) then
					newCatTable["SATELLITE"] = nil
				end
				if (not onlyCatTable["LAND"]) then
					newCatTable["LAND"] = nil
				end
				if (not onlyCatTable["SHIP"]) then
					newCatTable["SHIP"] = nil
				end
				if (not onlyCatTable["SUB"]) then
					newCatTable["SUB"] = nil
				end
				if (not onlyCatTable["SWIM"]) then
					newCatTable["SWIM"] = nil
				end
			end
			
			SetTableValue(weapon, "badTargetCategory", TableToCategories(newCatTable), doPreviewOnly, echoFront, "Blue")
		end
		
		local function SetNewShieldType(weapon, weaponDef)
			local echoFront = unit.unitname .. " weapon " .. weapon.def
			if (ToBool(weaponDef.isShield)) then
			
			else
				if (GetWeaponIsMinesweeper(weaponDef) or GetWeaponIsMelee(weapon, weaponDef) or ToBool(weaponDef.interceptor)) then
					SetTableValue(weaponDef, "interceptedByShieldType", 0, doPreviewOnly, echoFront, "Teal")
					return
				end
				
				if (ToNumber(weaponDef.renderType) == 4) then
					SetTableValue(weaponDef, "interceptedByShieldType", 1, doPreviewOnly, echoFront, "Teal")
					return
				end
				
				if (ToBool(weaponDef.selfprop) and not ToBool(weaponDef.stockpile) and not ToBool(weaponDef.waterWeapon)) then
					SetTableValue(weaponDef, "interceptedByShieldType", 2, doPreviewOnly, echoFront, "Teal")
					return
				end
				
				SetTableValue(weaponDef, "interceptedByShieldType", 0, doPreviewOnly, echoFront, "Teal")
			end
		end
	
		local weapons = unit.weapons
		local weaponDefs = unit.weaponDefs
		if (weapons and weaponDefs) then
			for _, weapon in pairs(weapons) do
				local weaponID = weapon.def
				local weaponDef = weaponDefs[weaponID]
				if (weaponID and weaponDef) then
					if (doOnlyTarget) then
						SetNewOnlyTargetCategory(weapon, weaponDef)
					end
					if (doBadTarget) then
						SetNewBadTargetCategory(weapon, weaponDef)
					end
					if (doShields) then
						SetNewShieldType(weapon, weaponDef)
					end
				end
			end
		end
	end
	
	----------------------------------------------------------------
	
	----------------------------------------------------------------
	
	local function SetNewNoChaseCategory(unit)
		local echoFront = unit.unitname
		local newCatTable = {}
		
		--unarmed units shouldn't chase
		if (not GetUnitHasAttack(unit)) then
			if (GetUnitIsMobile(unit)) then
				SetTableValue(unit, "noChaseCategory", allCats, doPreviewOnly, echoFront, "Red")
			else
				SetTableValue(unit, "noChaseCategory", nil, doPreviewOnly, echoFront, "Red")
			end
			return
		end
		
		--commanders shouldn't chase
		if (unit.commander) then
			SetTableValue(unit, "noChaseCategory", allCats, doPreviewOnly, echoFront, "Red")
			return
		end
		
		--start with all true
		newCatTable["HOVER"] = true
		newCatTable["FLOAT"] = true
		newCatTable["SINK"] = true
		newCatTable["SHIP"] = true
		newCatTable["SUB"] = true
		newCatTable["LAND"] = true
		newCatTable["SWIM"] = true
		newCatTable["SATELLITE"] = true
		newCatTable["GUNSHIP"] = true
		newCatTable["FIXEDWING"] = true
		
		--look through weapons; if unit 
		local weapons = unit.weapons
		local weaponDefs = unit.weaponDefs
		if (weapons and weaponDefs) then
			for _, weapon in pairs(weapons) do
				local weaponID = weapon.def
				local weaponDef = weaponDefs[weaponID]
				if (weaponID and weaponDef and not GetWeaponIsBogusMissile(weaponDef)) then
					local onlyCatTable = CategoriesToTable(weapon.onlyTargetCategory)
					local badCatTable = CategoriesToTable(weapon.badTargetCategory)
					if GetWeaponDefIsToAirWeapon(weaponDef) then
						newCatTable["GUNSHIP"] = nil
						newCatTable["FIXEDWING"] = nil
					elseif onlyCatTable then
						if badCatTable then
							for cat, val in pairs(newCatTable) do
								if onlyCatTable[cat] and not badCatTable[cat] then
									newCatTable[cat] = nil
								end
							end
						else
							for cat, val in pairs(newCatTable) do
								if onlyCatTable[cat] then
									newCatTable[cat] = nil
								end
							end
						end
					else
						if badCatTable then
							for cat, val in pairs(newCatTable) do
								if not badCatTable[cat] then
									newCatTable[cat] = nil
								end
							end
						else
							SetTableValue(unit, "noChaseCategory", nil, doPreviewOnly, echoFront, "Red")
							return
						end
					end
				end
			end
		end
		
		if (GetUnitIsStatic(unit)) then
			newCatTable["HOVER"] = true
			newCatTable["SHIP"] = true
			newCatTable["SUB"] = true
			newCatTable["LAND"] = true
			newCatTable["SWIM"] = true
			newCatTable["SATELLITE"] = true
			newCatTable["GUNSHIP"] = true
			newCatTable["FIXEDWING"] = true
		end
		
		SetTableValue(unit, "noChaseCategory", TableToCategories(newCatTable), doPreviewOnly, echoFront, "Red")
	end
	
	for unitID, unit in pairs(Units) do
		if (not ignore[unitID]) then
			if (doCategory) then
				SetNewCategory(unit)
			end
			if (deleteUnitTargetTags) then
				DeleteUnitTargetTags(unit)
			end
			SetNewWeaponCategories(unit)
			if (doNoChase) then
				SetNewNoChaseCategory(unit)
			end
		end
	end
end
