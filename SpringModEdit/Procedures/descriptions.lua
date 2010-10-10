-- $Id: descriptions.lua 3171 2008-11-06 09:06:29Z det $
local doPreviewOnly = true

for unitID, unit in pairs(Units) do
  if (not unit.commander 
      and GetUnitIsStatic(unit)
      and not unit.weapons
      and not unit.builder) then
    local energyProduction = (unit.energyMake or 0) - (unit.energyUse or 0)
    if (energyProduction * 50 > unit.buildCostMetal) then
      local newDesc = "Produces Energy (" .. energyProduction .. ")"
      if (unit.explodeAs == "NUCLEAR_MISSILE") then
        newDesc = newDesc .. " - HAZARDOUS"
      end
      SetTableValue(unit, "description", newDesc, doPreviewOnly, unitID, "Orange")
    elseif ((unit.metalStorage or 0) > 0) then
      SetTableValue(unit, "description", "Stores Metal (" .. unit.metalStorage .. ")", doPreviewOnly, unitID, "Black")
    elseif ((unit.energyStorage or 0) > 0) then
      SetTableValue(unit, "description", "Stores Energy (" .. unit.energyStorage .. ")", doPreviewOnly, unitID, "Green")
    end
  end
end
