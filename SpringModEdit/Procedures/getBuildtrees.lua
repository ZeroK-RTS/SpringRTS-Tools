-- $Id: getBuildtrees.lua 3444 2008-12-15 02:52:40Z licho $
local buildtree = {}
local procQueue = {}
local alreadySeen = {}
local indentString = ">"

local function ProcessQueue()
  while procQueue[1] do
    local currUnitID = procQueue[1][1]
    local currUnitLocation = procQueue[1][2]
    local currUnit = Units[currUnitID]
    local currUnitSideString
    
    if currUnit then
      if currUnit.buildoptions then
        if alreadySeen[currUnitID] then
          table.insert(currUnitLocation, currUnit.name .. " (...)")
        else
          table.insert(currUnitLocation, {currUnit.name})
          for index, buildoption in ipairs(currUnit.buildoptions) do
            table.insert(procQueue, {buildoption, currUnitLocation[table.getn(currUnitLocation)]})
          end
        end
      else
        table.insert(currUnitLocation, currUnit.name)
      end
      alreadySeen[currUnitID] = true
    end
    table.remove(procQueue, 1)
  end
end

local function printBuildtree(buildtree, level)
  local indent = string.rep(indentString, level)
  for index, subtree in ipairs(buildtree) do
    if (index == 1) then
      Editor.Echo(indent .. subtree .. "[[br]]\n")
    elseif type(subtree) == "table" then
      printBuildtree(subtree, level + 1)
    else
      Editor.Echo(indent .. indentString .. subtree .. "[[br]]\n")
    end
  end
end

for unitID, unit in pairs(Units) do
  if unit.commander then
    table.insert(procQueue, {unitID, buildtree})
  end
end

ProcessQueue()

for unitID, unit in pairs(Units) do
  if not alreadySeen[unitID] and unit.buildoptions then
    table.insert(procQueue, {unitID, buildtree})
  end
end

ProcessQueue()

for unitID, unit in pairs(Units) do
  if not alreadySeen[unitID] then
    table.insert(procQueue, {unitID, buildtree})
  end
end

ProcessQueue()

for index, subtree in ipairs(buildtree) do
  if type(subtree) == "table" then
    printBuildtree(subtree, 0)
  else
    Editor.Echo(subtree .. "[[br]]\n")
  end
end
