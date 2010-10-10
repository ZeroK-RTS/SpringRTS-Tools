-- $Id: flightTimes.lua 3171 2008-11-06 09:06:29Z det $
local doPreviewOnly = true

local echoColor = "Black"

local groundTargetV = 100
local airTargetV = 300

for unit, weapon, weaponDef in IteratorWeapons() do
  if weaponDef.weaponType == "MissileLauncher" then
    local echoFront = "Unit " .. ToString(unit.unitname) .. " weapon " .. ToString(weaponDef.name)
    
    local targetV = groundTargetV
    if (string.find(weapon.onlyTargetCategory or "", "VTOL")) then
      targetV = airTargetV
    end
    
    local v0 = weaponDef.startVelocity or 0.01
    local v1 = weaponDef.weaponVelocity or v0
    local deltav = v1 - v0
    local a = weaponDef.weaponAcceleration
    if (a == 0) then
      deltav = 0
      a = 1
    end
    local range = weaponDef.range or 10
    
    local t = math.ceil((range + 0.5 * deltav * deltav / a) / math.max(v1 - targetV, 0.01)) + 1
    
    SetTableValue(weaponDef, "flightTime", t, doPreviewOnly, echoFront, echoColor)
    
  end
end
