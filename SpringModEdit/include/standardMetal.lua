-- $Id: standardMetal.lua 8003 2010-06-05 14:09:24Z kingraptor $
local thisFile = "standardMetal"

Editor.Echo("Standard \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

--fixes metal-based stats

function StandardMetal(doPreviewOnly)
  Editor.Echo("----------------------------------------------------------------\n")
  Editor.Echo("Begin " .. thisFile .. "\n", "Black")
  Editor.Echo("----------------------------------------------------------------\n")
  
  --corpses
  local defaultCorpseLevel = 0.5
  local corpseDamageMult =   2
  local heapMult =           0.5 --heap metal = corpse metal * heapMult
  local reclaimTimeMult =  1 --reclaim time per metal
  
  --mass
  local massCostMult =     0.5 --mass =  massConst +  (metal * massCostMult + hp*massHpMult) * massMult
  local massHpMult =       0
  local massConst =        0
  local massMult  =        1
  local useStaticMass =      false --use staticMass for statics; otherwise, treat same as mobiles
  
  
  
  local corpseLevels = {
	armcom=0.5,
  }
  
  local ignoreCorpse = {
    armfdrag = true,
    armclaw = true, 
    armdrag = true, 
    armdtm = true,
    corclog = true, 
    cordrag = true, 
    cormaw = true, 
    armfort = true, 
    corfor = true,
    corfdrag = true,
    corfort = true,
  }
  
  local ignoreMass = {
    --decoy commanders
    armdecom = true,
    cordecom = true,
    
    --minesweepers
    cormlv = true,
    armmlv = true,
  
    --underground units
    chicken_digger_b = true,
    chicken_listener_b = true,
		
		--misc
		corclog = true,
  }
  
  local alwaysBlock = {
	armmex = true,
	cormex = true,
  }
  
  function fixMass(unit)
    local echoFront = unit.unitname
    if (unit.commander) then
      return false
    elseif (unit.kamikaze) then
      return false
    elseif (ignoreMass[unit.unitname]) then
      return false
    elseif (unit.mass == 100000) then
      return false
		elseif (ToNumber(unit.buildCostMetal) == 0) then
			return false
    elseif (GetUnitIsFakeStatic(unit)) then
      return SetTableValue(unit, "mass", constants.unit.staticMass, doPreviewOnly, echoFront, "Green")
    elseif (GetUnitIsStatic(unit) and useStaticMass) then
      return SetTableValue(unit, "mass", constants.unit.staticMass, doPreviewOnly, echoFront, "Green")
    else
      return SetTableValue(unit, "mass", (unit.buildCostMetal * massCostMult + unit.maxDamage * massHpMult) * massMult + massConst, doPreviewOnly, echoFront, "Orange")
    end
  end

  function fixEnergyBuildtime(unit)
     local m = unit.buildCostMetal or 0
     local echoFront = unit.unitname
     if (m > 0) then
       local change = SetTableValue(unit, "buildCostEnergy", m, doPreviewOnly, echoFront, "Green")
                      or SetTableValue(unit, "buildTime", m, doPreviewOnly, echoFront, "Green")
     end
     return change or false
  end
  
  for id,unit in pairs(Units) do
     if (unit == nil) then Editor.Echo(id,"Red")
     return
     end
     local unitModified = false
  
	 if (unit.featureDefs and not ignoreCorpse[unit.unitname] and not string.find(unit.unitname, "chicken")) then
       local corpseLevel = corpseLevels[unit.unitname] or defaultCorpseLevel
       local damage = unit.maxDamage * corpseDamageMult
       local corpseMetal = (unit.buildCostMetal or 0) * corpseLevel
  
       unitModified = SetUnitFeatureDefTag(unit, "DEAD", "damage", damage, doPreviewOnly, "Blue") or unitModified
       unitModified = SetUnitFeatureDefTag(unit, "DEAD", "metal", corpseMetal, doPreviewOnly, "Blue") or unitModified
       unitModified = SetUnitFeatureDefTag(unit, "DEAD", "description", "Wreckage - " .. unit.name, doPreviewOnly, "Blue") or unitModified
       unitModified = SetUnitFeatureDefTag(unit, "DEAD", "featureDead", "DEAD2", doPreviewOnly, "Blue") or unitModified
       unitModified = SetUnitFeatureDefTag(unit, "DEAD", "reclaimTime", corpseMetal * reclaimTimeMult, doPreviewOnly, "Blue") or unitModified
       
       if (unit.featureDefs["DEAD"] and unit.waterline and not alwaysBlock[unit.unitname]) then
         unitModified = SetUnitFeatureDefTag(unit, "DEAD", "blocking", false, doPreviewOnly, "Blue") or unitModified
       end


       if (unit.featureDefs["DEAD"] ~= nil and unit.featureDefs["HEAP"] ~= nil) then
         local dead2 = CopyTable(unit.featureDefs["HEAP"], false)
         local d = unit.featureDefs["DEAD"]
         dead2.featureDead = "HEAP"
         dead2.damage = d.damage
         dead2.reclaimTime = d.reclaimTime
         dead2.metal = d.metal
         unit.featureDefs["DEAD2"] = dead2
       end


       if (unit.featureDefs["DEAD"] and not GetUnitHasFeatureDef(unit, "HEAP")) then
         local heap = CreateHeap(unit)   
         unitModified = SetSubtable(unit.featureDefs, "HEAP", heap, true, doPreviewOnly, unit.unitname) or unitModified
       end
       unitModified = SetUnitFeatureDefTag(unit, "HEAP", "damage", damage, doPreviewOnly, "Purple") or unitModified
       unitModified = SetUnitFeatureDefTag(unit, "HEAP", "metal", corpseMetal * heapMult, doPreviewOnly, "Purple") or unitModified
       unitModified = SetUnitFeatureDefTag(unit, "HEAP", "description", "Debris - " .. unit.name, doPreviewOnly, "Purple") or unitModified
       unitModified = SetUnitFeatureDefTag(unit, "HEAP", "reclaimTime", corpseMetal * heapMult * reclaimTimeMult, doPreviewOnly, "Purple") or unitModified
    end 
    unitModified = fixMass(unit) or unitModified
    unitModified = fixEnergyBuildtime(unit) or unitModified
    if (unitModified) then
       Editor.Echo("--------------------------------\n", "Black")
    end
  end
end
