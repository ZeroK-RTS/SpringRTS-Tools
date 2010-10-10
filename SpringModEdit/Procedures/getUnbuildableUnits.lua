-- $Id: getUnbuildableUnits.lua 3444 2008-12-15 02:52:40Z licho $
local buildables = {}
local result = {}

for unitID, unit in pairs (Units) do
  buildables[unit.unitname] = false
end

for unitID, unit in pairs (Units) do
  if (unit.buildoptions) then
    for optID, option in pairs (unit.buildoptions) do
      buildables[option] = true
    end
  end
end

for unitname, buildable in pairs (buildables) do
  if (not buildable) then
    Editor.Echo(ToString(unitname) .. "\n")
    table.insert(result, unitname)
  end
end

return result