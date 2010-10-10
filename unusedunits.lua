-- $Id: unusedunits.lua 3171 2008-11-06 09:06:29Z det $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file: unusedunits.lua
--  brief: Finds and deletes unused units.
--           
--  author:  quantum
--
--  Copyright (C) 2007.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


require"lfs" -- http://www.keplerproject.org/luafilesystem/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local exceptions = {
  "fakeunit_smallping",
  "fakeunit",
  "armcomlite",
  "corcomlite",
  "corcdrone",
  "armcdrone",
  "fakeunit_aatarget",
  "chicken_digger_b",
  "chicken_listener_b",
  "tinyradar",
  "dughole",
}


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function lowerkeys(t)
  local a, b = next(t)
  return string.lower(a), b
end


local function SetCount(set)
  local count = 0
  for k in pairs(set) do
    count = count + 1
  end
  return count
end


local function ListToSet(list)
  set = {}
  for _, v in ipairs(list) do
    set[v] = true
  end
  return set
end


local function Difference(a, ...)
  local c = {}
  for k in pairs(a) do
    c[k] = true
    for _, b in ipairs{...} do
      if (b[k]) then
        c[k] = nil
      end
    end
  end
  return c
end


local function Intersection(a, b)
  local c = {}
  for k in pairs(a) do
    if (b[k]) then
      c[k] = true
    end
  end
  return c
end


local function Union(...)
  local c = {}
  for _, t in ipairs{...} do
    for k in pairs(t) do
      c[k] = true
    end
  end
  return c
end


local function TagBuildables(unit, units)
  buildable = {}
  local morphDefs = dofile"LuaRules/Configs/morph_defs.lua"
  
  local function Tag(unit)
    if (not units[unit])  then
      error(unit.." not found!")
    end
    if (buildable[unit]) then
      return
    end
    buildable[unit] = true
    if (units[unit].buildoptions) then
      for _, buildoption in ipairs(units[unit].buildoptions) do
        Tag(buildoption)
      end
    end
    if (morphDefs[unit]) then
      if (morphDefs[unit].into) then
        Tag(morphDefs[unit].into)
      else
        for _, t in ipairs(morphDefs[unit]) do
          Tag(t.into)
        end
      end        
    end
  end
  
  Tag(unit, units)
  return buildable
end


local function GetMorphs(active)
  local morphDefs = dofile"LuaRules/Configs/morph_defs.lua"
  local morphs = {}
  for unit, def in pairs(morphDefs) do
    if (active[unit]) then
      if (def.into) then
        morphs[def.into] = true
      else
        for _, t in ipairs(def) do
          morphs[t.into] = true
        end
      end
    end
  end
  return morphs
end


local function GetSpecialAir()
  local specialAir = {}
  local replacements = dofile"LuaRules/Configs/specialair.lua"
  for _, category in pairs(replacements) do
    for _, replacement in pairs(category) do
      specialAir[replacement] = true
    end
  end
  return specialAir
end


local function LoadUnits()
  local units = {}
  for file in lfs.dir"units" do
    if (file ~= "." and file ~= ".." and file ~= ".svn") then
      local fileName = "units/"..file
      local unitName, unitDef = dofile(fileName)
      units[unitName] = unitDef
    end
  end
  return units
end


local function GetChickens()
  io.input"LuaRules/Configs/spawn_defs.lua"
  local spawnString = io.read"*a"
  io.close()
  local spawnFn = loadstring(spawnString.." return chickenTypes, defenders, burrowName")
  setfenv(spawnFn, {pairs=pairs, type=type})
  local chickentypes, defenders, burrowName = spawnFn()
  local chickens = Union(chickentypes, defenders)
  chickens[burrowName] = true
  return chickens
end


local function PrintCounts(couples)
  for _, t in ipairs(couples) do
    print(t[1]..":", SetCount(t[2]))
  end
end


local function DeleteFile(file)
  print("Deleting "..file)
  print(os.remove(file))
end


local function CheckUsed(object, group, units)
  local used
  for unit in pairs(group) do
    local o = string.lower(units[unit].objectName)
    if (string.sub(object, -4) == ".3do") then
      o = string.sub(o, 1, #o-4)
    end
    if (object == o) then
      print(object.." used")
      used = true
    end
    local buildPic = units[unit].buildPic or units[unit].buildpic
    if (buildPic) then
      buildPic = string.lower(buildPic)
      if (object == buildPic) then
        print(object.." used")
        used = true
      end
    end
  end
  return used
end


local function DeleteUnit(unit, units, used)
  DeleteFile(string.format("scripts/%s.bos", unit))
  DeleteFile(string.format("scripts/%s.cob", unit))
  DeleteFile(string.format("units/%s.lua", unit))
  local object = string.lower(units[unit].objectName)
  if (string.sub(object, -4) == ".3do") then
    object = string.sub(object, 1, #object-4)
  end
  if (not CheckUsed(object, used, units)) then
    if (string.sub(object, -4) == ".s3o") then
      DeleteFile(string.format("Objects3d/%s", object))
    else
      DeleteFile(string.format("Objects3d/%s.3do", object))
    end
  end
  local buildPic = units[unit].buildPic or units[unit].buildpic
  if (buildPic) then
    buildPic = string.lower(buildPic)
    if (not CheckUsed(buildPic, used, units)) then
      DeleteFile(string.format("unitpics/%s", buildPic))
    end
  end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local units = LoadUnits()


local armUnits     = TagBuildables("armcom", units)
local coreUnits    = TagBuildables("corcom", units)
local conceptUnits = TagBuildables("concept_factory", units)


local specialAir   = GetSpecialAir()
local chickens     = GetChickens()
local morphs       = GetMorphs(Union(armUnits, coreUnits, conceptUnits, specialAir, chickens))
local exceptions   = ListToSet(exceptions)


local unused = Difference(units, armUnits, coreUnits, conceptUnits, chickens, specialAir, morphs, exceptions)
local used   = Difference(units, unused)

--[[
PrintCounts{
  {"arm"            , armUnits},
  {"core"           , coreUnits},
  {"total standard" , Union(armUnits, coreUnits)},
  {"concept"        , Difference(conceptUnits, Union(armUnits, coreUnits))},
  {"total standard + concept", Union(armUnits, coreUnits, conceptUnits)},
  {"special air" , specialAir},
  {"non concept chickens"    , Difference(chickens, conceptUnits)},
  {"unused", unused},
}
--]]

--[[
for unit in pairs(unused) do
  print(unit)
end
--]]

---[[
for unit in pairs(unused) do
  DeleteUnit(unit, units, used)
end
--]]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------