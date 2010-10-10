-- $Id: setDecloakDistances.lua 3171 2008-11-06 09:06:29Z det $
local doPreviewOnly = true

for id,unit in pairs(Units) do 
  local mcd = unit.minCloakDistance or 0
  local cost = unit.cloakCost or 0
  if (cost ==0 and mcd == 0 and not (initCloaked or false)) then
        local dist = 75
	if (GetUnitIsStatic(unit)) then dist = 150 end
	SetTableValue(unit, "minCloakDistance", dist , doPreviewOnly, id, "Black")
  end
end

