-- $Id: unit.lua 3444 2008-12-15 02:52:40Z licho $
--unit.lua
--by Evil4Zerggin

local thisFile = "unit"

Editor.Echo("Include \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

----------------------------------------------------------------
--constants
----------------------------------------------------------------

if (not constants) then
  constants = {}
end

constants[thisFile] = {
  energyThreshold = 1,
  radarThreshold = 1000,
  radarExclude = {
    cordoom = true,
    armanni = true,
  },
  sonarThreshold = 1000,
  seismicThreshold = 500,
  jammerThreshold = 250,
  costEnergyPerMetal = 60,
  antiAirThreshold = 4,
  cloakers = {
    armaser = true,
    armveil = true,
    arm_jammer = true,
    armsjam = true,
  },
  terraformers = {
    armblock = true,
    corblock = true,
    armtrench = true,
    cortrench = true,
    levelterra = true,
    rampdown = true,
    rampup = true,
  },
  staticMass = 100000,
}

----------------------------------------------------------------
--"get" functions
----------------------------------------------------------------

function GetUnitCustomParam(unit, param)
  if (unit.customParams) then
    return unit.customParams[param]
  else
    return nil
  end
end

function GetUnitCost(unit)
  return (unit.buildCostMetal or 0) + (unit.buildCostEnergy or 0) + (unit.buildTime or 0)
end

function GetUnitIsStatic(unit)
  return ToNumber(unit.maxVelocity) == 0
end

function GetUnitIsFakeStatic(unit)
  return GetUnitIsStatic(unit) and not unit.yardMap
end

function GetUnitIsMobile(unit)
  return (unit.maxVelocity or 0) > 0
end

function GetUnitIsMetalExtractor(unit)
  return (unit.extractsMetal or 0) > 0
end

function GetUnitIsArtificialEnergy(unit)
  return (ToNumber(unit.energyMake) > constants[thisFile].energyThreshold) or (ToNumber(unit.energyUse) < 0)
end

function GetUnitIsWind(unit)
  --explicit for now... stupid indexing bug keeps me from using customParams
  return unit.unitname == "armwin" or unit.unitname == "corwin"
end

function GetUnitIsTidal(unit)
  return (unit.tidalGenerator or 0) ~= 0
end

function GetUnitIsGeothermal(unit)
  return unit.yardMap and string.find(unit.yardMap, "[Gg]")
end

function GetUnitIsNaturalEnergy(unit)
  return GetUnitIsWind(unit) or GetUnitIsTidal(unit) or GetUnitIsGeothermal(unit)
end

function GetUnitIsEnergy(unit)
  return GetUnitIsArtificialEnergy(unit) or GetUnitIsNaturalEnergy(unit)
end

function GetUnitIsMetalMaker(unit)
  return (unit.makesMetal or 0) > 0
end

function GetUnitIsMetalGenerator(unit)
  return (unit.metalMake or 0) > 0
end

function GetUnitIsMetal(unit)
  return GetUnitIsMetalExtractor(unit) or GetUnitIsMetalMaker(unit) or GetUnitIsMetalGenerator(unit)
end

function GetUnitHasMetalStorage(unit)
  return (unit.metalStorage or 0) > 0
end

function GetUnitIsStorage(unit)
  return (unit.metalStorage or 0) > 10 or (unit.energyStorage or 0) > 10
end

function GetUnitHasEnergyStorage(unit)
  return (unit.energyStorage or 0) > 0
end

function GetUnitIsWorker(unit)
  return (unit.workerTime or 0) > 0
end

function GetUnitIsBuilder(unit)
  return GetUnitIsWorker(unit) and unit.buildoptions and table.getn(unit.buildoptions) > 0
end

function GetUnitIsConstructor(unit)
  return GetUnitIsBuilder(unit) and unit.canAssist ~= false
end

function GetUnitIsFactory(unit)
  return GetUnitIsStatic(unit) and GetUnitIsBuilder(unit)
end

function GetUnitIsRadar(unit)
  return ((unit.radarDistance or 0) >= constants[thisFile].radarThreshold) and not constants[thisFile].radarExclude[unit.unitname]
end

function GetUnitIsSonar(unit)
  return (unit.sonarDistance or 0) >= constants[thisFile].sonarThreshold
end

function GetUnitIsSeismic(unit)
  return (unit.seismicDistance or 0) >= constants[thisFile].seismicThreshold
end

function GetUnitIsJammer(unit)
  return (unit.radarDistanceJam or 0) >= constants[thisFile].jammerThreshold
end

function GetUnitIsLandOnly(unit)
  return (unit.maxWaterDepth or 1) <= 0
end

function GetUnitIsWaterOnly(unit)
  return ((unit.minWaterDepth or -1) >= 0)
end

function GetUnitCanFly(unit)
  return ToBool(unit.canFly)
end

function GetUnitIsGunship(unit)
  return GetUnitCanFly(unit) and (ToBool(unit.hoverAttack) or GetUnitIsBuilder(unit) or unit.transportCapacity)
end

function GetUnitCanCloak(unit)
  return (unit.cloakCost or -1) >= 0 or constants[thisFile].cloakers[unit.unitname]
end

function GetUnitIsSub(unit)
  return unit.movementClass == "DBOAT3" or (GetUnitIsStatic(unit) and ToNumber(unit.waterline) >= 30)
end

function GetUnitIsFireproof(unit)
  return unit.customParams and ToBool(unit.customParams.fireproof)
end

function GetUnitIsFloating(unit)
  if (GetUnitIsStatic(unit)) then
    return unit.waterline and not GetUnitIsSub(unit)
  else
    return unit.movementClass and (string.find(unit.movementClass, "SHIP") or string.find(unit.movementClass, "BOAT")) and not GetUnitIsSub(unit)
  end
end

function GetUnitIsTerraform(unit)
  return constants[thisFile].terraformers[unit.unitname]
end

----------------------------------------------------------------
--"print" functions
----------------------------------------------------------------

----------------------------------------------------------------
--"set" functions
--return true if unit was modified, false otherwise
----------------------------------------------------------------


