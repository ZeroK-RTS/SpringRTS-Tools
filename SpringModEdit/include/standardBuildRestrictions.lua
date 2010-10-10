-- $Id: standardBuildRestrictions.lua 3603 2008-12-31 06:18:45Z evil4zerggin $
local thisFile = "standardMaxSlope"

Editor.Echo("Standard \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

function StandardBuildRestrictions(doPreviewOnly)
  Editor.Echo("----------------------------------------------------------------\n")
  Editor.Echo("Begin " .. thisFile .. "\n", "Black")
  Editor.Echo("----------------------------------------------------------------\n")
  
  local largeSlope = 255
  local factorySlope = 15
  local nonLevelSlope = 36
  local levelSlope = 18
  local mobileSlope = 18
	
  
  local function FixSlope(unit)
    local echoFront = unit.unitname
    
    if (unit.canFly) then
      SetTableValue(unit, "maxSlope", nil, doPreviewOnly, echoFront, "Blue")
      return
    end
    
    if (GetUnitIsMetalExtractor(unit) or GetUnitIsGeothermal(unit)) then
      SetTableValue(unit, "maxSlope", largeSlope, doPreviewOnly, echoFront, "Green")
      return
    end
    
    if (GetUnitIsStatic(unit)) then
    
      --ignore max slope
      if (ToBool(unit.isFeature)
					or (unit.footprintX == 1 and unit.footprintZ == 1)) then
        SetTableValue(unit, "maxSlope", largeSlope, doPreviewOnly, echoFront, "Blue")
        return
      end
      
      if (GetUnitIsFactory(unit)) then
        SetTableValue(unit, "maxSlope", factorySlope, doPreviewOnly, echoFront, "Orange")
        return
      end
      
      if (unit.levelGround == false) then
        SetTableValue(unit, "maxSlope", nonLevelSlope, doPreviewOnly, echoFront, "Green")
        return
      end
      
      SetTableValue(unit, "maxSlope", levelSlope, doPreviewOnly, echoFront, "Brown")
      return
    end
    
    if (unit.movementClass) then
      local maxSlope = moveDefs[unit.movementClass].maxslope
      SetTableValue(unit, "maxSlope", maxSlope, doPreviewOnly, echoFront, "Blue")
      return
    end
    
    SetTableValue(unit, "maxSlope", largeSlope, doPreviewOnly, echoFront, "Red")
    return
  end
  
  local function FixWaterDepth(unit)
    local echoFront = unit.unitname
    if (GetUnitIsMobile(unit)) then
      if (unit.movementClass) then
        local minWaterDepth = moveDefs[unit.movementClass].minwaterdepth
        local maxWaterDepth = moveDefs[unit.movementClass].maxwaterdepth
        SetTableValue(unit, "minWaterDepth", minWaterDepth, doPreviewOnly, echoFront, "Blue")
        SetTableValue(unit, "maxWaterDepth", maxWaterDepth, doPreviewOnly, echoFront, "Blue")
      else
        SetTableValue(unit, "minWaterDepth", nil, doPreviewOnly, echoFront, "Blue")
        SetTableValue(unit, "maxWaterDepth", nil, doPreviewOnly, echoFront, "Blue")
      end
    end
  end
  
  for unitID, unit in pairs(Units) do
    FixSlope(unit)
    FixWaterDepth(unit)
  end
end
