-- $Id: standardResourcing.lua 3444 2008-12-15 02:52:40Z licho $
local thisFile = "standardResourcing"

Editor.Echo("Standard \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

function StandardResourcing(doPreviewOnly)
  Editor.Echo("----------------------------------------------------------------\n")
  Editor.Echo("Begin " .. thisFile .. "\n", "Black")
  Editor.Echo("----------------------------------------------------------------\n")
  
  local ignore = {}
  
  local doResourceMake = true
  local doResourceUse = true
  
  --production standards
  local builderMetalMakeMult      = 0.025  --units with buildoptions and assist capability Get metal production equal To workertime divided by this number
  local builderEnergyMakeMult     = 0.025
  
  --use standards
  local seismicEnergyUse          = 1.5   --energy use of seismic detectors
  local radarEnergyUse            = 1.5
  local sonarEnergyUse            = 1.5
  local jammerEnergyUse           = 1.5
  local shieldEnergyUse           = 1.5
  
  --reclaim levels
  local reclaimLevels = {
    armrectr = 2.5,
    cornecro = 0.5,
    armmlv = 2.5,
    cormlv = 2.5,
    armmls = 2.5,
    cormls = 2.5,
    armrecl = 2.5,
    correcl = 0.5,
  }
  
  --terraform speeds
  local terraformMult            = 100
  local terraformLevels = {
    armrectr = 250,
    cornecro = 50,
    armmlv = 250,
    cormlv = 250,
    armmls = 250,
    cormls = 250,
    armrecl = 250,
    correcl = 50,
  }
  
  for id, unit in pairs(Units) do
  
    if (not ignore[unit.unitname]) then
    
      local unitModified = false
      
      local echoFront = unit.unitname
      
      --production
      if (doResourceMake) then
        if (unit.commander) then
          --commanders
        elseif (GetUnitIsConstructor(unit)) then
          --builders
          unitModified = SetTableValue(unit, "metalMake", (unit.workerTime or 0) * builderMetalMakeMult, doPreviewOnly, echoFront, "Orange") or unitModified
          unitModified = SetTableValue(unit, "energyMake", (unit.workerTime or 0) * builderEnergyMakeMult, doPreviewOnly, echoFront, "Orange") or unitModified
        elseif (GetUnitIsEnergy(unit)) then
          --energy production structures
        elseif (GetUnitIsMetal(unit)) then
          --metal making structures
        else
          --otherwise remove production
          unitModified = SetTableValue(unit, "metalMake", nil, doPreviewOnly, echoFront, "Black") or unitModified
          unitModified = SetTableValue(unit, "energyMake", nil, doPreviewOnly, echoFront, "Black") or unitModified
        end
      end
    
      --energy use
      if (doResourceUse) then
        if (unit.commander) then
          --commanders
        elseif (GetUnitIsEnergy(unit)) then
          --negative use, e.g., solars
        elseif (GetUnitIsMetal(unit)) then
          --metal makers and extractors
        elseif (GetUnitHasEnergyStorage(unit)) then
          --energy storage
        elseif (GetUnitIsSeismic(unit)) then
          --unitModified = SetTableValue(unit, "energyUse", seismicEnergyUse, doPreviewOnly, echoFront, "Purple") or unitModified
        elseif (GetUnitIsRadar(unit)) then
          --radar
          --unitModified = SetTableValue(unit, "energyUse", radarEnergyUse, doPreviewOnly, echoFront, "Green") or unitModified
        elseif (GetUnitIsSonar(unit)) then
          --sonar
          --unitModified = SetTableValue(unit, "energyUse", sonarEnergyUse, doPreviewOnly, echoFront, "Blue") or unitModified
        elseif (GetUnitIsJammer(unit)) then
          --jammer
          --unitModified = SetTableValue(unit, "energyUse", jammerEnergyUse, doPreviewOnly, echoFront, "Red") or unitModified
        elseif (GetUnitHasShield(unit)) then
          --shield
          --unitModified = SetTableValue(unit, "energyUse", shieldEnergyUse, doPreviewOnly, echoFront, "Gray") or unitModified
        else
          --otherwise remove use
          unitModified = SetTableValue(unit, "energyUse", nil, doPreviewOnly, echoFront, "Brown") or unitModified
        end
      end
      
      --storage
      if (not GetUnitHasEnergyStorage(unit)) then
        unitModified = SetTableValue(unit, "energyStorage", nil, doPreviewOnly, echoFront, "Red") or unitModified
      else
        if (unit.description and string.find(unit.description, "Energy Storage")) then
          local descStart = string.find(unit.description, "Energy Storage")
          local newDesc = string.sub(unit.description, 1, descStart - 1) .. "Energy Storage (" .. unit.energyStorage .. ")"
          unitModified = SetTableValue(unit, "description", newDesc, doPreviewOnly, echoFront, "Red") or unitModified
        end
      end
      
      if (not GetUnitHasMetalStorage(unit)) then
        unitModified = SetTableValue(unit, "metalStorage", nil, doPreviewOnly, echoFront, "Red") or unitModified
      else
        if (unit.description and string.find(unit.description, "Metal Storage")) then
          local descStart = string.find(unit.description, "Metal Storage")
          local newDesc = string.sub(unit.description, 1, descStart - 1) .. "Metal Storage (" .. unit.metalStorage .. ")"
          unitModified = SetTableValue(unit, "description", newDesc, doPreviewOnly, echoFront, "Red") or unitModified
        end
      end
      
      
      
      --worker stuff
      if (ToNumber(unit.workerTime) > 0) then
        --reclaim speeds
        if (ToBool(unit.canreclamate)) then
          if (reclaimLevels[unit.unitname]) then
            unitModified = SetTableValue(unit, "reclaimSpeed", unit.workerTime * reclaimLevels[unit.unitname], doPreviewOnly, echoFront, "Purple") or unitModified
          else
            unitModified = SetTableValue(unit, "reclaimSpeed", nil, doPreviewOnly, echoFront, "Purple") or unitModified
          end
        else
          unitModified = SetTableValue(unit, "reclaimSpeed", nil, doPreviewOnly, echoFront, "Purple") or unitModified
        end
        
        --terraform speeds (mobiles only)
        if (ToBool(unit.terraformSpeed)) then
          if (terraformLevels[unit.unitname]) then
            unitModified = SetTableValue(unit, "terraformSpeed", unit.workerTime * terraformLevels[unit.unitname], doPreviewOnly, echoFront, "Green") or unitModified
          else
            unitModified = SetTableValue(unit, "terraformSpeed", unit.workerTime * terraformMult, doPreviewOnly, echoFront, "Green") or unitModified
          end
        end
      end
      
      if (unitModified) then
         Editor.Echo("--------------------------------\n", "Black")
      end
    end
  end
end