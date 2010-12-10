-- $Id: standardSensors.lua 3444 2008-12-15 02:52:40Z licho $
local thisFile = "standardSensors"

Editor.Echo("Standard \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

function StandardSensors(doPreviewOnly)
  Editor.Echo("----------------------------------------------------------------\n")
  Editor.Echo("Begin " .. thisFile .. "\n", "Black")
  Editor.Echo("----------------------------------------------------------------\n")
  
  local signatureCloak = 16
  local signatureFloater = 4
  local signatureDefault = 4
  local minSightDistanceRange = 1.1
  local minRadarDistance = 100 --units with less than this radar distance get their radar distance removed
  
  local ignore = {
    tinyradar = true,
    fakeunit_smallping = true,
    dughole = true,
  }
  
  for id, unit in pairs(Units) do
    if (not ignore[id]) then
      local unitModified = false
      local echoFront = unit.unitname
      
      --remove useless radar
      if ((ToNumber(unit.radarDistance or 0)) < minRadarDistance) then
        unitModified = SetTableValue(unit, "radarDistance", nil, doPreviewOnly, echoFront, "Green") or unitModified
      end
      
      --seismic detection
      if (unit.canFly) then
        --aircraft
        unitModified = SetTableValue(unit, "seismicSignature", 0, doPreviewOnly, echoFront, "Red") or unitModified
      elseif (GetUnitCanCloak(unit)) then
        --units with cloak
        unitModified = SetTableValue(unit, "seismicSignature", signatureCloak, doPreviewOnly, echoFront, "Blue") or unitModified
      elseif (unit.floater) then
        --floaters
        unitModified = SetTableValue(unit, "seismicSignature", signatureFloater, doPreviewOnly, echoFront, "Purple") or unitModified
      else
        unitModified = SetTableValue(unit, "seismicSignature", signatureDefault, doPreviewOnly, echoFront, "Green") or unitModified
      end
	  
	  if (unit.sightDistance) then 
		local range = GetUnitRange(unit) 
		if (range > 600) then range = 600 end 
		if (unit.sightDistance < range * minSightDistanceRange) then 
			unitModified = SetTableValue(unit, "sightDistance", range*minSightDistanceRange, doPreviewOnly, echoFront, "Green") or unitModified
		end 
	  end
      
      if (unitModified) then
         Editor.Echo("--------------------------------\n", "Black")
      end
    end
  end
end
