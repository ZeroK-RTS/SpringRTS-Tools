-- $Id: feature.lua 3444 2008-12-15 02:52:40Z licho $
--feature.lua
--by Evil4Zerggin

local thisFile = "feature"

Editor.Echo("Include \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

----------------------------------------------------------------
--constants
----------------------------------------------------------------

if (not constants) then
  constants = {}
end

constants[thisFile] = {
  heapBase = {
        blocking         = false,
        category         = "heaps",
        energy           = 0,
        featurereclamate = "SMUDGE01",
        hitdensity       = "100",
        reclaimable      = true,
        seqnamereclamate = "TREE1RECLAMATE",
        world            = "All Worlds",
  },
  heapObjects = {
    [1] = 6,
    [2] = 6,
    [3] = 6,
    [4] = 6,
    [5] = 4,
    [6] = 4,
    [7] = 4,
  },
  maxHeapSize = 7,
}

function GetUnitHasFeatureDef(unit, featureName)
  return unit.featureDefs and unit.featureDefs[featureName]
end

function SetUnitFeatureDefTag(unit, featureName, tagName, value, doPreviewOnly, color)
  if (not unit.featureDefs) then
    Editor.Echo("Unit " .. unit.unitname .. " has no featureDefs.\n" , "Red")
    return false
  end
  
  if (not unit.featureDefs[featureName]) then
    Editor.Echo("Unit " .. unit.unitname .. " has no feature " .. featureName .. ".\n" , "Red")
    return false
  end
  
  local echoFront = "Unit " .. unit.unitname .. " feature " .. featureName
  
  return SetTableValue(unit.featureDefs[featureName], tagName, value, doPreviewOnly, echoFront , color)
end

function GetRandomHeapObjectName(size)
  size = math.floor(size)

  if (size < 1) then
    size = 1
  elseif (size > constants[thisFile].maxHeapSize) then
    size = constants[thisFile].maxHeapSize
  end

  local heapNumber = math.random(constants[thisFile].heapObjects[size])
  return size .. "X" .. size .. NumberToUpperLetter(heapNumber)
end

function CreateHeap(unit)
  local result = CopyTable(constants[thisFile].heapBase)
  result.footprintX = unit.footprintX or 1
  result.footprintZ = unit.footprintZ or 1
  result.object = GetRandomHeapObjectName(math.min(result.footprintX, result.footprintZ))
  return result
end