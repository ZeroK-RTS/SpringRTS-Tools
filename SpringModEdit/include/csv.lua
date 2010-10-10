-- $Id: csv.lua 3444 2008-12-15 02:52:40Z licho $
--csv.lua
--by Evil4Zerggin
--for outptting comma-separated values tables

local thisFile = "csv"

Editor.Echo("Include \"" .. thisFile .. ".lua\" loaded.\n", "Brown")


local function ToCSVString(x)
  local result = ToString(x)
  result = string.gsub(result, "\"", "\"\"")
  result = "\"" .. result .. "\""
  return result
end

--requestTable: a table consisting of tags and functions; these will be evaluated on every unit and put into a comma-separated values table
--make up your own functions, or check other includes for functions
--filter (optional): if set, only units for which the filter function returns true will be printed
--titles (optional): what To print as the first row of the .csv
function GetsUnitCSV(requestTable, filter, titles)
  --titles
  Editor.Echo("unitname,", "Black")
  if (titles) then
    Editor.Echo(ToString(titles) .. ";", "Black")
  else
    for _, tag in pairs(requestTable) do
      Editor.Echo(ToCSVString(tag) .. ";", "Black")
    end
  end
  Editor.Echo("\n", "Black")
  
  for id, unit in pairs(Units) do
    if (not filter or filter(unit)) then
      Editor.Echo(ToCSVString(unit.unitname) .. ";", "Black")
      for _, tag in pairs(requestTable) do
        if (type(tag) == "string") then
          Editor.Echo(ToCSVString(unit[tag]), "Black")
        elseif (type(tag) == "function") then
          Editor.Echo(ToCSVString(tag(unit)), "Black")
        end
        Editor.Echo(";", "Black")
      end
      Editor.Echo("\n", "Black")
    end
  end
end

--requestTable: a table consisting of tags and functions; these will be evaluated on every weaponDef and put into a comma-separated values table
--functions in requestTable can optionally take the owning unit as a second argument
--filter (optional): if set, only weapons for which the filter function returns true will be printed
--filter function can optionally take the owning unit as a second argument
--titles (optional): what To print as the first row of the .csv

function GetsWeaponDefCSV(requestTable, filter, titles)
  --titles
  Editor.Echo("unitname,", "Black")
  if (titles) then
    Editor.Echo(ToString(titles) .. ";", "Black")
  else
    for _, tag in pairs(requestTable) do
      Editor.Echo(ToCSVString(tag) .. ";", "Black")
    end
  end
  Editor.Echo("\n", "Black")
  
  for unitID, unit in pairs(Units) do
    if (unit.weaponDefs) then
      for weaponDefID, weaponDef in pairs(unit.weaponDefs) do
        if (not filter or filter(weaponDef, unit)) then
          Editor.Echo(ToCSVString(unit.name .. " weapon " .. weaponDefID) .. ";", "Black")
          for _, tag in pairs(requestTable) do
            if (type(tag) == "string") then
              Editor.Echo(ToCSVString(weaponDef[tag]), "Black")
            elseif (type(tag) == "function") then
              Editor.Echo(ToCSVString(tag(weaponDef, unit)), "Black")
            end
            Editor.Echo(";", "Black")
          end
          Editor.Echo("\n", "Black")
        end
      end
    end
  end
end