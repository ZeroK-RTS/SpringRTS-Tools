-- $Id: setDecloakDistances.lua 3171 2008-11-06 09:06:29Z det $
local doPreviewOnly = true

for id,unit in pairs(Units) do 
  local mcd = unit.minCloakDistance or 0
  local cloakCost = unit.cloakCost or 0
  local buildCost = unit.buildCostMetal or 1

  local fx = unit.footprintX and tonumber(unit.footprintX) or 1
  local fz = unit.footprintZ and tonumber(unit.footprintZ) or 1
  local radius = 8 * math.sqrt((fx * fx) + (fz * fz))
  local dist = math.floor(radius + 58)
  
  --local dist = math.floor(buildCost^0.5)*2
 
  if (GetUnitIsStatic(unit)) then dist = dist * 2.5 end
  if (mcd == 75) or (mcd == 150) then SetTableValue(unit, "minCloakDistance", dist , doPreviewOnly, id, "Black")
end
