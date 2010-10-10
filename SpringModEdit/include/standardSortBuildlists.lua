-- $Id: standardSortBuildlists.lua 3444 2008-12-15 02:52:40Z licho $
local thisFile = "standardSortBuildLists"

Editor.Echo("Standard \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

function StandardSortBuildlists(doPreviewOnly)

  local ignore = {
    roostfac = true,
  }

  Editor.Echo("----------------------------------------------------------------\n")
  Editor.Echo("Begin " .. thisFile .. "\n", "Black")
  Editor.Echo("----------------------------------------------------------------\n")
  
  local builderIsWaterUnit = false
  
  local function BuildlistComp(a, b)
    local unitA = Units[a];
    local unitB = Units[b];
    local result = true
    
    local function CompBoolean(a, b, tf)
      if (tf(a)) then
        if (tf(b)) then
          return "both"
        else
          return "a"
        end
      else
        if (tf(b)) then
          return "b"
        else
          return "none"
        end
      end
    end
    
    local function CompBooleanFinal(unitA, unitB, tf)
      local result = "both"
      if (tf) then
        result = CompBoolean(unitA, unitB, tf)
      end
      
      if (result == "a") then 
        return true 
      elseif (result == "b") then
        return false
      elseif (result == "both") then
        if (GetUnitCost(unitA) ~= GetUnitCost(unitB)) then
          return GetUnitCost(unitA) < GetUnitCost(unitB)
        else
          return unitA.unitname < unitB.unitname
        end
      else
        return nil
      end
    end
    
    local function CompDetectOrShield(unitA, unitB)
      local result
      --radar
      result = CompBooleanFinal(unitA, unitB, GetUnitIsRadar)
      if (result ~= nil) then
        return result
      end
      
      --sonar
      result = CompBooleanFinal(unitA, unitB, GetUnitIsSonar)
      if (result ~= nil) then
        return result
      end
      
      --seismic
      result = CompBooleanFinal(unitA, unitB, GetUnitIsSeismic)
      if (result ~= nil) then
        return result
      end
      
      --jammer
      result = CompBooleanFinal(unitA, unitB, GetUnitIsJammer)
      if (result ~= nil) then
        return result
      end
      
      --shield
      result = CompBooleanFinal(unitA, unitB, GetUnitHasShield)
      return result
    end
    --------------------------------
    --water/non-water priority
    --------------------------------
    if (builderIsWaterUnit) then
      --land-only structures at end
      result = CompBoolean(unitA, unitB, GetUnitIsLandOnly)
      if (result == "b") then 
        return true 
      elseif (result == "a") then
        return false
      end  
    else
      --water-only structures at end
      result = CompBoolean(unitA, unitB, GetUnitIsWaterOnly)
      if (result == "b") then 
        return true 
      elseif (result == "a") then
        return false
      end
    end
    
    --------------------------------
    --statics
    --------------------------------
    result = CompBoolean(unitA, unitB, GetUnitIsStatic)
    if (result == "a") then 
      return true 
    elseif (result == "b") then
      return false
    elseif (result == "both") then
      --mexes
      result = CompBooleanFinal(unitA, unitB, GetUnitIsMetalExtractor)
      if (result ~= nil) then
        return result
      end
      
      --artificial energy
      result = CompBooleanFinal(unitA, unitB, GetUnitIsArtificialEnergy)
      if (result ~= nil) then
        return result
      end
      
      --other (natural) energy
      result = CompBooleanFinal(unitA, unitB, GetUnitIsEnergy)
      if (result ~= nil) then
        return result
      end
      
      --metal makers
      result = CompBooleanFinal(unitA, unitB, GetUnitIsMetalMaker)
      if (result ~= nil) then
        return result
      end
      
      --metal storage
      result = CompBooleanFinal(unitA, unitB, GetUnitHasMetalStorage)
      if (result ~= nil) then
        return result
      end
      
      --energy storage
      result = CompBooleanFinal(unitA, unitB, GetUnitHasEnergyStorage)
      if (result ~= nil) then
        return result
      end
      
      --workers (nanos, facs)
      result = CompBooleanFinal(unitA, unitB, GetUnitIsWorker)
      if (result ~= nil) then
        return result
      end
      
      --detectors and shields
      result = CompDetectOrShield(unitA, unitB)
      if (result ~= nil) then
        return result
      end
      
      --statics with attack
      result = CompBoolean(unitA, unitB, GetUnitHasAttack)
      if (result == "a") then 
        return true 
      elseif (result == "b") then
        return false
      elseif (result == "both") then 
        --non-aa
        result = CompBoolean(unitA, unitB, GetUnitIsAntiAir)
        if (result == "b") then 
          return true 
        elseif (result == "a") then
          return false
        elseif (result == "none") then
          return CompBooleanFinal(unitA, unitB)
        end
    
        --aa units
        return CompBooleanFinal(unitA, unitB)
      end
      
      --other non-terraform statics
      result = CompBoolean(unitA, unitB, GetUnitIsTerraform)
      if (result == "b") then 
        return true 
      elseif (result == "a") then
        return false
      elseif (result == "none") then
        return CompBooleanFinal(unitA, unitB)
      end
      
      --terraform units
      return CompBooleanFinal(unitA, unitB)
    end
  
    --------------------------------
    --mobiles
    --------------------------------
    
    --full constructors (mobile with buildoptions and can assist)
    result = CompBoolean(unitA, unitB, GetUnitIsConstructor)
    if (result == "a") then 
      return true 
    elseif (result == "b") then
      return false
    elseif (result == "both") then
      return (unitA.workerTime or 0) > (unitB.workerTime or 0)
    end
    
    --other constructors (non-assisting constructors)
    result = CompBoolean(unitA, unitB, GetUnitIsBuilder)
    if (result == "a") then 
      return true 
    elseif (result == "b") then
      return false
    elseif (result == "both") then
      return (unitA.workerTime or 0) > (unitB.workerTime or 0)
    end
  
    --mobiles with attack
    result = CompBoolean(unitA, unitB, GetUnitHasAttack)
    if (result == "a") then 
      return true 
    elseif (result == "b") then
      return false
    elseif (result == "both") then
      --air units
      
      result = CompBooleanFinal(unitA, unitB, GetUnitCanFly)
      if (result ~= nil) then
        return result
      end
  
      --non-aa units
      result = CompBoolean(unitA, unitB, GetUnitIsAntiAir)
      if (result == "b") then 
        return true 
      elseif (result == "a") then
        return false
      elseif (result == "none") then
        return CompBooleanFinal(unitA, unitB)
      end
  
      --aa units
      return CompBooleanFinal(unitA, unitB)
    end
  
    --detectors and shields
    result = CompDetectOrShield(unitA, unitB)
    if (result ~= nil) then
      return result
    end
  
    --other
    return CompBooleanFinal(unitA, unitB)
  end
  
  for id, unit in pairs(Units) do
    if (unit.buildoptions and not unit.commander and not ignore[id]) then
      builderIsWaterUnit = GetUnitIsWaterOnly(unit)
      local newBuildOptions = CopyTable(unit.buildoptions)
      table.sort(newBuildOptions, BuildlistComp)
      local i = 1
      repeat
        if newBuildOptions[i] == newBuildOptions[i+1] then
          table.remove(newBuildOptions, i)
        else
          i = i + 1
        end
      until newBuildOptions[i+1] == nil
      SetSubtable(unit, "buildoptions", newBuildOptions, true, doPreviewOnly, unit.unitname, "Black")
    end
  end
end
