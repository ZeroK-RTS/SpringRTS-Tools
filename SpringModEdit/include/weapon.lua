-- $Id: weapon.lua 4035 2009-03-08 02:17:14Z licho $
--weapon.lua
--by Evil4Zerggin

local thisFile = "weapon"

Editor.Echo("Include \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

if (not constants) then
  constants = {}
end

constants[thisFile] = {
  antiAirThreshold = 3,  --units whose anti-air DPS is at least this multiple of their default damage are considered dedicated anti-air
  fps = 30,
}

function ToRealFrameTime(rawTime)
  return math.max(1, (rawTime or 0) * constants[thisFile].fps) / constants[thisFile].fps
end

function GetWeaponIsBeamWeapon(weaponDef)
  return ToBool(weaponDef.beamWeapon) and ToNumber(weaponDef.renderType) == 0 and not ToBool(weaponDef.isShield)
end

function GetWeaponIsBeamlaser(weaponDef)
  return not ToBool(weaponDef.beamWeapon) and ToBool(weaponDef.beamlaser) and ToNumber(weaponDef.renderType) == 0 and not ToBool(weaponDef.isShield)
end

function GetWeaponIsGuidedMissile(weaponDef)
  return ToBool(weaponDef.selfprop) and ToBool(weaponDef.tracks) and ToBool(weaponDef.guidance)
end

function GetWeaponIsFlamethrower(weaponDef)
  return (ToNumber(weaponDef.renderType) == 5)
end

function GetWeaponIsMinesweeper(weaponDef)
  return weaponDef.explosionGenerator and string.find(weaponDef.explosionGenerator, "MINESWEEP")
end

function GetWeaponIsMelee(weapon, weaponDef)
  return (ToNumber(weaponDef.targetborder) == 1)
           or string.find(weapon.def, "KICK")
           or string.find(weapon.def, "CRUSH")
           or string.find(weapon.def, "MELEE")
end

function GetWeaponIsToAirWeapon(weapon, weaponDef)
  local catTable = CategoriesToTable(weapon.onlyTargetCategory)
  return ToBool(weaponDef.toAirWeapon)
           or ((catTable["FIXEDWING"] or catTable["GUNSHIP"]) and not (catTable["LAND"] or catTable["HOVER"] or catTable["SHIP"] or catTable["SINK"]))
end

function GetWeaponDefDamage(weaponDef, damageType)
  if (weaponDef.damage) then
    if (weaponDef.damage[damageType]) then
      return ToNumber(weaponDef.damage[damageType])
    elseif (weaponDef.damage.default) then
      return ToNumber(weaponDef.damage.default)
    end
  end
  return 0
end

function GetWeaponDefMaxDamage(weaponDef, paralyzer)
  local result = 0
  if (weaponDef.damage) then
    for damageType, damage in pairs(weaponDef.damage) do
      if (ToBool(weaponDef.paralyzer) == ToBool(paralyzer)) then
        result = math.max(result, weaponDef.damage[damageType])
      end
    end
  end
  return result
end

function GetWeaponIsBogusMissile(weaponDef)
  return GetWeaponDefMaxDamage(weaponDef) == 0 and GetWeaponDefMaxDamage(weaponDef, true) == 0 and weaponDef.weaponAcceleration
end

--if paralyzer is false, returns 0 for paralyzers
--if paralyzer is true, returns 0 for non-paralyzers
function GetWeaponDefDPS(weapon, weaponDef, damageType, paralyzer)
  if (GetWeaponIsToAirWeapon(weapon, weaponDef) and damageType ~= "planes" 
       or weaponDef.isShield 
       or weaponDef.stockpile) then
    return 0
  end
  if (ToBool(paralyzer) ~= ToBool(weaponDef.paralyzer)) then
    return 0
  end
  local salvoSize = (weaponDef.burst or 1) * (weaponDef.projectiles or 1)
  local reloadTime = math.max(((weaponDef.burst or 1) - 1) * ToRealFrameTime(weaponDef.burstRate), ToRealFrameTime(weaponDef.reloadtime))
  return GetWeaponDefDamage(weaponDef, damageType) * salvoSize / reloadTime
end

function GetWeaponDefMaxDPS(weaponDef, paralyzer)
  local damage = GetWeaponDefMaxDamage(weaponDef, paralyzer)
  local salvoSize = (weaponDef.burst or 1) * (weaponDef.projectiles or 1)
  local reloadTime = math.max(((weaponDef.burst or 1) - 1) * ToRealFrameTime(weaponDef.burstRate), ToRealFrameTime(weaponDef.reloadtime))
  return damage * salvoSize / reloadTime
end

function GetWeaponDefMaxGravity(weaponDef)
  return (weaponDef.weaponVelocity or 0) * (weaponDef.weaponVelocity or 0) / (weaponDef.range or 10)
end

function GetUnitHasWeaponWithTag(unit, tagName, value)
  if (unit.weapons and unit.weaponDefs) then
    for weaponID, weapon in pairs(unit.weapons) do
      if (weapon.def and unit.weaponDefs[weapon.def]
           and unit.weaponDefs[weapon.def][tagName]
           and (value == nil or unit.weaponDefs[weapon.def][tagName] == value)) then
        return true
      end
    end
  end
  return false
end

function GetUnitHasUnderwaterAttack(unit)
  if (unit.weapons and unit.weaponDefs) then
    for weaponID, weapon in pairs(unit.weapons) do
      if (weapon.def and unit.weaponDefs[weapon.def]
           and ToBool(unit.weaponDefs[weapon.def].waterWeapon)) then
        return true
      end
    end
  end
  return false
end

function GetUnitHasShield(unit)
  return GetUnitHasWeaponWithTag(unit, "isShield")
end

function GetUnitIsBomber(unit)
  return GetUnitHasWeaponWithTag(unit, "dropped")
end

function GetUnitHasInterceptor(unit)
  return GetUnitHasWeaponWithTag(unit, "interceptor")
end

function GetUnitWeaponSum(unit, func)
  local result = 0
  if (unit.weapons and unit.weaponDefs) then
    for weaponID, weapon in pairs(unit.weapons) do
      if (weapon.def and unit.weaponDefs[weapon.def]) then
        result = result + func(unit.weaponDefs[weapon.def])
      end
    end
  end
  return result
end

--rangePow: each weapon's DPS is multiplied by range ^ rangePow
--aoeBase, aoePower: each weapon's DPS is multiplied by (areaOfEffect + aoeBase)^aoePow
function GetUnitDPS(unit, damageType, paralyzer, rangePow, aoePow, aoeBase)
  local result = 0
  if (unit.weapons and unit.weaponDefs) then
    for weaponID, weapon in pairs(unit.weapons) do
      --exclude weapons unable to shoot air in aa damage calculation
      if (weapon.def and unit.weaponDefs[weapon.def]
           and (damageType ~= "planes" or weapon.onlyTargetCategory ~= "NOTAIR")
           and weapon.onlyTargetCategory ~= "NONE") then
        local weaponDef = unit.weaponDefs[weapon.def]
        local dps = GetWeaponDefDPS(weapon, weaponDef, damageType, paralyzer)
        local aoe = weaponDef.areaOfEffect or 8
        if (rangePow) then
          dps = dps * math.pow(ToNumber(weaponDef.range), rangePow)
          if (weaponDef.dynDamageExp) then
            dps = dps / (rangePow + 1)
          end
        end
        if (aoePow) then
          dps = math.pow((dps + (aoeBase or 0)), aoePow)
        end
        result = result + dps
      end
    end
  end
  return result
end

function GetUnitHasAttack(unit)
  return GetUnitDPS(unit, "default") ~= 0 or GetUnitDPS(unit, "default", true) ~= 0 or GetUnitDPS(unit, "planes") ~= 0 or GetUnitDPS(unit, "subs") ~= 0 or unit.kamikaze
end

function GetUnitIsAntiAir(unit)
  if (GetUnitDPS(unit, "planes") > constants[thisFile].antiAirThreshold * GetUnitDPS(unit, "default")) then
    return true
  else
    return false
  end
end

function GetUnitRange(unit)
  local result = 0
  if (unit.weapons and unit.weaponDefs) then
    for weaponID, weapon in pairs(unit.weapons) do
      if (weapon.def and unit.weaponDefs[weapon.def]) then
        result = math.max(result, ToNumber(unit.weaponDefs[weapon.def].range))
      end
    end
  end
  return result
end

function PrintsUnitDPS(damageType)
  for id, unit in pairs(Units) do
    local dps = GetUnitDPS(unit, damageType)
    Editor.Echo(unit.unitname .. " does " .. dps .. " DPS To " .. damageType .. "\n", "Black")
  end
end

function PrintsUnitIsAntiAir()
  for id, unit in pairs(Units) do
    if (GetIsAntiAir(unit)) then
      Editor.Echo(unit.unitname .. " is anti-air\n", "Blue")
    else
      Editor.Echo(unit.unitname .. " is not anti-air\n", "Black")
    end
  end
end

function SetUnitWeaponTag(unit, weaponIndex, tagName, value, doPreviewOnly, color)
  if (not unit.weapons)  then
    Editor.Echo("Unit " .. unit.unitname .. " has no weapons.\n" , "Red")
  end
  
  if (not unit.weapons[weaponIndex])  then
    Editor.Echo("Unit " .. unit.unitname .. " has no weapon " .. weaponIndex .. ".\n" , "Red")
  end
  
  local echoFront = "Unit " .. unit.unitname .. " weapon " .. weaponIndex .. " " .. ToString(unit.weapons[weaponIndex].def)
  
  return SetTableValue(unit.weapons[weaponIndex], tagName, value, doPreviewOnly, echoFront, color)
end

function ReplaceUnitWeaponTag(unit, weaponIndex, tagName, oldValue, newValue, doPreviewOnly, color)
  if (not unit.weapons)  then
    Editor.Echo("Unit " .. unit.unitname .. " has no weapons.\n" , "Red")
  end
  
  if (not unit.weapons[weaponIndex])  then
    Editor.Echo("Unit " .. unit.unitname .. " has no weapon " .. weaponIndex .. ".\n" , "Red")
  end
  
  local echoFront = "Unit " .. unit.unitname .. " weapon " .. weaponIndex .. " " .. ToString(unit.weapons[weaponIndex].def)
  
  return ReplaceTableValue(unit.weapons[weaponIndex], tagName, oldValue, newValue, doPreviewOnly, echoFront, color)
end