-- $Id: categories.lua 3444 2008-12-15 02:52:40Z licho $
local thisFile = "categories"

Editor.Echo("Include \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

----------------------------------------------------------------
--category functions
----------------------------------------------------------------

function CategoriesToTable(cats)
  if (not cats) then
    return {}
  end
  
  local result = {}
  --no gmatch in this version of lua =(
  --for cat in string.gmatch(cats, "[^%s]+") do
  --  table.insert(result, cat)
  --end
  repeat 
    local front, back = string.find(cats, "[^%s]+")
    result[string.sub(cats, front, back)] = true
    cats = string.sub(cats, back + 1)
  until (not string.find(cats, "[^%s]+"))
  
  return result
end

function TableToCategories(catTable)
  local result = ""
  for cat, _ in pairs(catTable) do
    result = result .. cat .. " "
  end
  if (result == "") then
    result = nil
  else 
    result = string.sub(result, 1, -2)
  end
  return result
end
