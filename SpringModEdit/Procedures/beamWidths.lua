-- $Id: beamWidths.lua 4037 2009-03-08 02:41:37Z licho $
local doPreviewOnly = true

local minBase = 0.5

local heatRayMult = 2
local toAirMult = 0.5
local beamttlMult = 0.5
local ttl = 15

local laserScale = 0.010
local weaponScale = 0.005
local coreThickness = 0.5
local flareMult = 1.5

local ttlThickMult = 1
local ttlThreshold = 0.04
local decayEnd = 0.01

local largeBeamTimeThreshold = 0.15
--compensates for thinness of large beam texture
local largeBeamMult = 1.5
local continuousThreshold = 0.05

local round = 2

local wavelengths = {
  ["1 0 0"] = 650,
  ["1 0.1 0"] = 625,
  ["1 0.25 0"] = 600,
  ["1 1 0"] = 575,
  ["0 1 0"] = 525,
  ["0 1 1"] = 500,
  ["0 0 1"] = 475,
  ["0.5 0.5 1"] = 425,
  ["0.25 0 1"] = 425,
  ["other"] = 500,
}

local ignore = {
  armpnix2 = true,
  armcybr2 = true,
  armthund2 = true,
  corgripn2 = true,
  tawf003 = true,
  core_slicer = true,
  corcan = true,
  mahlazer = true,
}

local function GetBeamLaserBaseWidth(weapon, weaponDef)
  local damage = GetWeaponDefMaxDamage(weaponDef)
  
  local beamTime = weaponDef.beamTime or 1
  
  local wavelength = wavelengths[weaponDef.rgbColor or "other"] or wavelengths["other"]
  
  local result = math.sqrt(damage / beamTime * wavelength) * laserScale
  
  if (GetWeaponIsToAirWeapon(weapon, weaponDef)) then
    result = result * toAirMult
  end
  
  if (ToNumber(weaponDef.beamTime) <= ttlThreshold) then
    result = result * ttlThickMult
  end
  
  if (weaponDef.beamttl) then
    result = result * beamttlMult
  end
  
  return result
end

local function GetBeamWeaponBaseWidth(weapon, weaponDef)
  local damage = GetWeaponDefMaxDamage(weaponDef)
  
  local duration = weaponDef.duration or 0.05
  
  local wavelength = wavelengths[weaponDef.rgbColor or "other"] or wavelengths["other"]
  
  local result = math.sqrt(damage / duration * wavelength) * weaponScale
  
  if (GetWeaponIsToAirWeapon(weapon, weaponDef)) then
    result = result * toAirMult
  end
  
  if (weaponDef.dynDamageExp) then
    result = result * heatRayMult
  end
  
  return result
end

local function FixBeamWeapon(weapon, weaponDef, unit)
  local thickness = GetBeamWeaponBaseWidth(weapon, weaponDef)
  
  local echoFront = unit.unitname .. " weapon " .. weaponDef.name
  
  if (thickness <= 0) then
    return nil
  end
  
  SetTableValue(weaponDef, "coreThickness", coreThickness, doPreviewOnly, echoFront, "Red")
  SetTableValue(weaponDef, "thickness", thickness, doPreviewOnly, echoFront, "Red")
  SetTableValue(weaponDef, "laserFlareSize", nil, doPreviewOnly, echoFront, "Red")
  
  Editor.Echo("--------------------------------\n", "Black")
end

local function FixBeamlaser(weapon, weaponDef, unit)

  local thickness = GetBeamLaserBaseWidth(weapon, weaponDef)
  
  if (thickness <= 0) then
    return nil
  end
  
  if (ToNumber(weaponDef.beamTime) >= math.min(largeBeamTimeThreshold, ToNumber(weaponDef.reloadtime) - continuousThreshold)) then
    SetTableValue(weaponDef, "largeBeamLaser", true, doPreviewOnly, echoFront, "Blue")
    --SetTableValue(weaponDef, "texture1", "largelaser", doPreviewOnly, echoFront, "Black")
    SetTableValue(weaponDef, "texture2", "flare", doPreviewOnly, echoFront, "Blue")
    SetTableValue(weaponDef, "texture3", "flare", doPreviewOnly, echoFront, "Blue")
    SetTableValue(weaponDef, "texture4", "smallflare", doPreviewOnly, echoFront, "Blue")
  end  
  
  local echoFront = unit.unitname .. " weapon " .. weaponDef.name
  
  local flare = RoundDecimal(thickness * flareMult, round)
  
  if (ToNumber(weaponDef.beamTime) >= math.min(largeBeamTimeThreshold, ToNumber(weaponDef.reloadtime) - continuousThreshold)) then
    thickness = thickness * largeBeamMult
  end
  
  SetTableValue(weaponDef, "coreThickness", coreThickness, doPreviewOnly, echoFront, "Blue")
  SetTableValue(weaponDef, "thickness", thickness, doPreviewOnly, echoFront, "Blue")
  SetTableValue(weaponDef, "laserFlareSize", flare, doPreviewOnly, echoFront, "Blue")
  SetTableValue(weaponDef, "rgbColor2", nil, doPreviewOnly, echoFront, "Blue")
  
  if (ToNumber(weaponDef.beamTime) <= ttlThreshold) then
    local decay = RoundDecimal(decayEnd^(1 / ttl), 3)
    SetTableValue(weaponDef, "beamttl", ttl, doPreviewOnly, echoFront, "Blue")
    SetTableValue(weaponDef, "beamDecay", decay, doPreviewOnly, echoFront, "Blue")
  end
  Editor.Echo("--------------------------------\n", "Black")
end


for unit, weapon, weaponDef in IteratorWeapons() do
  if ignore[unit.unitname] then
    --nothing
  elseif (GetWeaponIsBeamlaser(weaponDef)) then
    FixBeamlaser(weapon, weaponDef, unit)
  elseif (GetWeaponIsBeamWeapon(weaponDef)) then
    FixBeamWeapon(weapon, weaponDef, unit)
  end
end
