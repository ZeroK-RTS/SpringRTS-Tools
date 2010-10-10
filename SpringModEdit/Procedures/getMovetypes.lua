-- $Id: getMovetypes.lua 3444 2008-12-15 02:52:40Z licho $
local movetypes = {
  NONE = {},
}

for unitID, unit in pairs(Units) do
  local movetype = unit.movementClass
  if (movetype) then
    if (movetypes[movetype]) then
      table.insert(movetypes[movetype], unit.unitname)
    else
      movetypes[movetype] = {unit.unitname,}
    end
  else
    table.insert(movetypes.NONE, unit.unitname)
  end
end

for movetype, units in pairs(movetypes) do
  Editor.Echo(movetype .. ": ", "Black")
  for _, unitname in pairs(units) do
    Editor.Echo(unitname .. ", ")
  end
  Editor.Echo("\n", "Black")
end
