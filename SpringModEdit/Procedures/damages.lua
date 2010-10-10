-- $Id: damages.lua 4035 2009-03-08 02:17:14Z licho $
-- reports units with invalid damages
-- fixes anti-air and anti-ground damages against ground and air if desired
-- fixes EMP damages if desired

local doPreviewOnly = true

local doAAToGround = true
local doGroundToAir = true
local doSub = true
local doEMP = true

local aaToGroundMult = 0.1
local groundToAirMult = 1
local commanderEMPMult = 0.01
local planeEMPMult     = 0.01

local subMult = 0.05
local subFlameMult = 0.01
local subSubMult = 1

local aaThreshold = 0.5 --tracking weapons whose aa damage is at least their multiple of their anti-ground damage are considered aa

local explicitAA = {
  chickens = true,
}

local exclude = {
  armdecom = true,
  cordecom = true,
  armsilo = true,
  corsilo = true,
}

local armorDefs = {
  subs = true,
  commanders= true,
  empresistant99 = true,
  empresistant75 = true,
  mines = true,
  flamethrowers = true,
  planes = true, 
  chicken = true,
  ["else"]   = true,
  default = true,
}

function GetWeaponIsAA(weapon, weaponDef)
  local aaDamage = ToNumber(GetWeaponDefDamage(weaponDef, "planes"))
  local baseDamage = ToNumber(GetWeaponDefDamage(weaponDef, "default"))
  if (baseDamage == 0) then
    return true
  end
  return ToBool(weaponDef.toAirWeapon) or (ToBool(weaponDef.guidance) and ToBool(weaponDef.tracks) and aaDamage >= aaThreshold * baseDamage)
end

for unit, weapon, weaponDef in IteratorWeapons() do
  if (not unit.commander and not exclude[unit.unitname] and weaponDef.damage and not ToBool(weaponDef.isShield) and GetWeaponDefMaxDamage(weaponDef) > 0) then
    local echoFront = "Unit " .. ToString(unit.unitname) .. " weapon " .. ToString(weaponDef.name) .. " damage"
  
    for damageType,damage in pairs(weaponDef.damage) do
      if (not armorDefs[damageType]) then
        Editor.Echo(echoFront .. " " .. damageType .." is invalid\n", "Red")
      end 
    end
    
    --dedicated AA deals 10% to default
    if (GetWeaponIsToAirWeapon(weapon, weaponDef) and weaponDef.damage["default"] and weaponDef.damage["planes"]) then
      if (doAAToGround) then
        local newDamage = ToNumber(weaponDef.damage["planes"]) * aaToGroundMult
        local echoColor = "Blue"
        SetTableValue(weaponDef.damage, "default", newDamage , doPreviewOnly, echoFront, echoColor)
      end
	  SetTableValue(weaponDef,"cylinderTargetting",1, doPreviewOnly, echoFront, echoColor)
    --dedicated anti-ground deals ? to planes (excludes air weapons and paralyzers)
    elseif (not GetWeaponIsAA(weapon, weaponDef) and not ToBool(unit.canFly) and not ToBool(weaponDef.paralyzer) and not explicitAA[unit]) then
      if (doGroundToAir) then
        local newDamage = ToNumber(weaponDef.damage["default"]) * groundToAirMult
        local echoColor = "Green"
        SetTableValue(weaponDef.damage, "planes", newDamage , doPreviewOnly, echoFront, echoColor)
      end
    end
    
    --non-waterweapons do 10% to subs
    if (not ToBool(weaponDef.waterWeapon) and doSub) then
      local maxDamage = GetWeaponDefMaxDamage(weaponDef)
      if (ToNumber(weaponDef.renderType) == 5) then
        maxDamage = maxDamage * subFlameMult
      end
      local echoColor = "Blue"
      SetTableValue(weaponDef.damage, "subs", maxDamage * subMult , doPreviewOnly, echoFront, echoColor)  
    end
    
    --subs do 25% to each other
    if (ToBool(weaponDef.waterWeapon) and not GetUnitIsLandOnly(unit) and not GetUnitIsFloating(unit) and not ToBool(unit.canFly) and doSub) then
      local baseDamage = ToNumber(weaponDef.damage["default"])
      local echoColor = "Purple"
      SetTableValue(weaponDef.damage, "subs", baseDamage * subSubMult , doPreviewOnly, echoFront, echoColor)  
    end
    
    --EMP weapons
    if (doEMP and ToBool(weaponDef.paralyzer) and weaponDef.damage["default"]) then
      local baseDamage = ToNumber(weaponDef.damage["default"])        
      local echoColor = "Orange"
      SetTableValue(weaponDef, "impulseMult", 0, doPreviewOnly, echoFront, echoColor)
      SetTableValue(weaponDef, "impulseBoost", 0, doPreviewOnly, echoFront, echoColor)   
      SetTableValue(weaponDef, "craterMult", 0, doPreviewOnly, echoFront, echoColor)
      SetTableValue(weaponDef, "craterBoost", 0, doPreviewOnly, echoFront, echoColor)
      SetTableValue(weaponDef.damage, "empresistant99", baseDamage * 0.01 , doPreviewOnly, echoFront, echoColor)           
      SetTableValue(weaponDef.damage, "empresistant75", baseDamage * 0.25 , doPreviewOnly, echoFront, echoColor)
      SetTableValue(weaponDef.damage, "commanders", baseDamage * commanderEMPMult , doPreviewOnly, echoFront, echoColor)
      SetTableValue(weaponDef.damage, "planes", baseDamage * planeEMPMult , doPreviewOnly, echoFront, echoColor)
    end
  end
end
