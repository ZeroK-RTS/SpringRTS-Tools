-- $Id: explicitWeaponTypes.lua 3171 2008-11-06 09:06:29Z det $
local doPreviewOnly = true

for unit, weapon, weaponDef in IteratorWeapons() do
  if (not weaponDef.weaponType) then
    local echoFront = unit.unitname .. " weapon " .. weapon.def
    local weaponType
    if (weaponDef.dropped) then
      weaponType = "AircraftBomb";
    elseif (weaponDef.vlaunch) then
      weaponType = "StarburstLauncher";
    elseif (weaponDef.beamlaser) then
      weaponType = "BeamLaser";
    elseif (weaponDef.isShield) then
      weaponType = "Shield";
    elseif (weaponDef.waterWeapon) then
      weaponType = "TorpedoLauncher";
    elseif (string.find(weaponDef.name, "Disintegrator")) then
      weaponType = "DGun";
    elseif (weaponDef.lineOfSight) then
      if (weaponDef.renderType == 7) then
        weaponType = "LightingCannon";
      elseif (weaponDef.beamWeapon) then
        weaponType = "LaserCannon";
      elseif (weaponDef.model and string.find(weaponDef.model, "Laser")) then
        weaponType = "LaserCannon";
      elseif (weaponDef.smokeTrail) then
        weaponType = "MissileLauncher";
      elseif (weaponDef.renderType == 4 and weaponDef.color == 2) then
        weaponType = "EmgCannon";
      elseif (weaponDef.renderType == 5) then
        weaponType = "Flame";
      else
        weaponType = "Cannon";
      end
    else
      weaponType = "Cannon";
    end
    
    SetTableValue(weaponDef, "weaponType", weaponType, doPreviewOnly, echoFront, "Black")
  end
end
