-- $Id: impactOnly.lua 8583 2010-10-03 11:50:56Z kingraptor $
local doPreviewOnly = true

for unit, weapon, weaponDef in IteratorWeapons() do
  if weaponDef.areaOfEffect and weaponDef.areaOfEffect <= 24 then
    local echoFront = "Unit " .. ToString(unit.unitname) .. " weapon " .. ToString(weaponDef.name) .. " (AoE: " .. weaponDef.areaOfEffect .. ")"
    SetTableValue(weaponDef, "impactOnly", true, doPreviewOnly, echoFront, "Black")
	SetTableValue(weaponDef, "craterBoost", 0, doPreviewOnly, echoFront, "Black")
	SetTableValue(weaponDef, "craterMult", 0, doPreviewOnly, echoFront, "Black")
    if (not weaponDef.explosionGenerator) then
      SetTableValue(weaponDef, "explosionGenerator", "custom:DEFAULT", doPreviewOnly, echoFront, "Red")
    end
  end
end
