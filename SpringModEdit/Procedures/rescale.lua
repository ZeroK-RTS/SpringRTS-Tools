-- $Id: rescale.lua 3444 2008-12-15 02:52:40Z licho $
--rescales metal, energy, and buildTime at your option
--make sure to change other LUA files! this only affects unitDefs!

--current list of LuaRules files:
--\Configs\cloak_shield_defs.lua
--\Configs\deployment.lua
--\Configs\stealh_defs.lua
--\Configs\tactics.lua
--\Gadgets\unit_dgun_cost.lua
--\Gadgets\unit_metal_hax.lua
--\Gadgets\unit_mex_rate.lua
--\Gadgets\unit_windmill_control.lua
--\Widgets\gui_mex_energy.lua

--and SpringModEdit scripts:
--\include\unit.lua: 
--  energyThreshold (if energy rescaled)
--  costEnergyPerMetal (if energy or metal rescaled; optional)
--\include\standardMetal.lua: 
--  massMult (if metal rescaled)
--  reclaimTimeMult (if metal or buildTime rescaled)
--\include\standardResourcing.lua: 
--  builderMetalMakeMult (if metal or buildTime rescaled)
--  builderEnergyMakeMult (if energy or buildTime rescaled)
--  energyStructureThreshold (if energy rescaled)
--  terraformMult (if buildTime rescaled)

local doPreviewOnly = true

--modes: nil does all
--"make" does production
--"cost" does storage and cost
local mode = "make"

local scales = {
  metal = nil,
  energy = 1.2,
  buildTime = nil,
}

local tagsToMod = {
  metal = {
    buildCostMetal = "cost",
    extractsMetal = "make",
    makesMetal = "make",
    metalMake = "make",
    metalStorage = "cost",
    metalUse = "cost",
    weaponDefs = {
      metalpershot = "cost",
    },
    featureDefs = {
      metal = "cost",
    },
  },
  energy = {
    buildCostEnergy = "cost",
    cloakCost = "cost",
    cloakCostMoving = "cost",
    energyMake = "make",
    energyStorage = "cost",
    energyUse = "cost",
    tidalGenerator = "make",
    windGenerator = "make",
    weaponDefs = {
      energypershot = "cost",
      energyUse = "cost",
      powerRegenEnergy = "cost",
      shieldEnergyUse = "cost",
      shieldPowerRegenEnergy = "cost",
    },
    featureDefs = {
      energy = "cost",
    },
  },
  buildTime = {
    buildTime = "cost",
    captureSpeed = "make",
    maxRepairSpeed = "make",
    reclaimSpeed = "make",
    repairSpeed = "make",
    resurrectSpeed = "make",
    terraformSpeed = "make",
    workerTime = "make",
    featureDefs = {
      reclaimTime = "cost",
    },
  },
}

--generates a muliplier function
local function Multiplier(scale)

  local function Result(oldValue)
    if (oldValue) then
      return oldValue * scale
    else
      return nil
    end
  end
  
  return Result
end

for unitID, unit in pairs(Units) do
  Editor.Echo(unitID .. "\n", "Black")
  
  for resourceType, resourceScale in pairs(scales) do
  
    local modFunc = Multiplier(resourceScale)
    for tagToMod, subTable in pairs(tagsToMod[resourceType]) do
      if (type(subTable) == "table") then
        if (unit[tagToMod]) then
          for defID, def in pairs(unit[tagToMod]) do
            for subTagToMod, subMode in pairs(subTable) do
              if (not mode or mode == subMode) then
                ModTableValue(def, subTagToMod, modFunc, doPreviewOnly, "  " .. defID, "Black")
              end
            end
          end
        end
      else
        if (not mode or mode == subTable) then
          ModTableValue(unit, tagToMod, modFunc, doPreviewOnly, "", "Black")
        end
      end
    end
  end
  
  Editor.Echo("----------------------------------------------------------------\n", "Black")
end