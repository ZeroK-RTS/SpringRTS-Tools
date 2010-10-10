-- $Id: getCombatStats.lua 3171 2008-11-06 09:06:29Z det $
local aoePow = 1
local aoeBase = 64

local function GetUnitDefaultDPS(unit)
  return GetUnitDPS(unit, "default", false, nil, aoePow, aoeBase)
end

local function GetUnitLinearDPS(unit)
  return GetUnitDPS(unit, "default", false, 1, aoePow, aoeBase)
end

local function GetUnitQuadDPS(unit)
  return GetUnitDPS(unit, "default", false, 2, aoePow, aoeBase)
end

local function GetUnitCubeDPS(unit)
  return GetUnitDPS(unit, "default", false, 3, aoePow, aoeBase)
end

local requestTitles = "Unitname;Name;Description;Metal Cost;Hit Points;Range;Speed;Default DPS;Linear DPS;Quad DPS;Cube DPS"

local requestTable = {
  "name", 
  "description", 
  "buildCostMetal", 
  "maxDamage", 
  GetUnitRange, 
  "maxVelocity", 
  GetUnitDefaultDPS, 
  GetUnitLinearDPS, 
  GetUnitQuadDPS, 
  GetUnitCubeDPS,
}

GetsUnitCSV(requestTable, nil, requestTitles)
