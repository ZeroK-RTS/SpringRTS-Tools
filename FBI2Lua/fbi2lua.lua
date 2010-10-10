-- $Id: fbi2lua.lua 6473 2009-12-28 18:20:53Z jk $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    fbi2lua.lua
--  brief:   Exports *.lua Unit/Feature/Weapon/CEG-Def files
--  author:  Dave Rodgers
--  CEG additions by:  jK
--
--  Copyright (C) 2007,2008,2009.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = 'FBI2LUA',
    desc      = 'Exports *.lua Unit/Feature/Weapon/CEG-Def files',
    author    = 'trepan (CEG addition by jK)',
    date      = '2007,2008,2009',
    license   = 'GNU GPL, v2 or later',
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function isbool(x)   return (type(x) == 'boolean') end
local function istable(x)  return (type(x) == 'table')   end
local function isnumber(x) return (type(x) == 'number')  end
local function isstring(x) return (type(x) == 'string')  end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function ParseParams(filename)
  local fullName = LUAUI_DIRNAME .. 'Widgets/paramMaps/' .. filename
  local maps = VFS.Include(fullName, nil, VFS.RAW)
  
  local caseMap = {}

  local function AddCaseEntries(map)
    if (map == nil) then
      return
    end
    for param in pairs(map) do
      caseMap[string.lower(param)] = param
    end
  end
  AddCaseEntries(maps.intMap)
  AddCaseEntries(maps.boolMap)
  AddCaseEntries(maps.floatMap)
  AddCaseEntries(maps.float3Map)
  AddCaseEntries(maps.stringMap)

  local function ArrayToLowerMap(array)
    local map = {}
    for name in pairs(array) do
      map[string.lower(name)] = name
    end
    return map
  end

  return {
    intMap    = ArrayToLowerMap(maps.intMap),
    boolMap   = ArrayToLowerMap(maps.boolMap),
    floatMap  = ArrayToLowerMap(maps.floatMap),
    float3Map = ArrayToLowerMap(maps.float3Map),
    stringMap = ArrayToLowerMap(maps.stringMap),
    caseMap   = caseMap,  
  }
end

--------------------------------------------------------------------------------

local unitParamMaps    = ParseParams('ud.params.lua')
local weaponParamMaps  = ParseParams('wd.params.lua')
local featureParamMaps = ParseParams('fd.params.lua')
local cegParamMaps     = ParseParams('ceg.params.lua')

local paramMaps

local defsEnv  = {}
defsEnv.Spring = {}
defsEnv.VFS    = {}
_G = widget


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Remove any raw mode access
--

local VFS_DirList    = VFS.DirList
local VFS_Include    = VFS.Include
local VFS_LoadFile   = VFS.LoadFile
local VFS_FileExists = VFS.FileExists

local function StripRawMode(modes)
  return string.gsub(modes, VFS.RAW, '')
end


defsEnv.VFS.DirList = function(dir, pat, modes)
  if (modes) then
    return VFS_DirList(dir, pat, StripRawMode(modes))
  elseif (pat) then
    return VFS_DirList(dir, pat)
  else
    return VFS_DirList(dir)
  end
end


defsEnv.VFS.Include = function(name, fenv, modes)
  if (modes) then
    return VFS_Include(name, fenv, StripRawMode(modes))
  elseif (fenv) then
    return VFS_Include(name, fenv)
  else
    return VFS_Include(name)
  end
end


defsEnv.VFS.LoadFile = function(name, modes)
  if (modes) then
    return VFS_LoadFile(name, StripRawMode(modes))
  else
    return VFS_LoadFile(name)
  end
end


defsEnv.VFS.FileExists = function(name, modes)
  if (modes) then
    return VFS_FileExists(name, StripRawMode(modes))
  else
    return VFS_FileExists(name)
  end
end

--------------------------------------------------------------------------------

defsEnv.Spring.Echo = Spring.Echo

function defsEnv.Spring.TimeCheck(prefix, func, ...)
  local t0 = Spring.GetTimer()
  func(...)
  local t1 = Spring.GetTimer()
  local diff = Spring.DiffTimers(t1, t0)
  Spring.Echo(string.format('%s%.3f', prefix, diff))
end

function defsEnv.Spring.GetModOptions()
  return {}
end

-- FIXME: ew
setmetatable(defsEnv.Spring, { __index = Spring, __newindex = Spring })
setmetatable(defsEnv, { __index = widget, __newindex = widget })


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function CopyTable(t)
  local n = {}
  for k,v in pairs(t) do
    local nk = istable(k) and CopyTable(k) or k
    local nv = istable(v) and CopyTable(v) or v
    n[nk] = nv
  end
  return n
end


local function ClipName(name, udName)
  local lowerName  = name:lower()
  local lowerUName = udName:lower()
  if (lowerName:find('^' .. lowerUName)) then
    name = name:sub(#udName + 1)
    if (name:find('^_')) then
      name = name:sub(2)
    end
  end
  return name
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function ProcessWeapons(udName, ud, weaponDefs)
  if (not isstring(udName) or not istable(ud)) then
    return
  end

  local weapons = ud.weapons
  if (not istable(weapons)) then
    return
  end

  local wdMap = {}

  for i = 1, 16 do
    local w = weapons[i]
    if (istable(w)) then
      local wd = weaponDefs[w.name:lower()]
      if (wd) then
        wdMap[wd] = w.name
        w.def = w.name
        w.name = nil
      end
    end
  end

  local wds = {}
  for wd, wdName in pairs(wdMap) do
    wds[wdName] = wd
    wd.filename = nil
  end
  ud.weaponDefs = wds
end


--------------------------------------------------------------------------------

local function ProcessFeatures(udName, ud, featureDefs)
  if (not isstring(udName) or not istable(ud)) then
    return
  end

  if (not isstring(ud.corpse)) then
    return
  end

  local fd, fdCopy

  fd = featureDefs[ud.corpse:lower()]
  if (not fd) then
    return
  end

  local fdMap = {}

  local clipName = ClipName(ud.corpse, udName)
  ud.corpse = clipName
  fdCopy = CopyTable(fd)
  fdMap[fd] = { clipName, fdCopy }

  local count = 0

  -- loop through 'featuredead' chains
  while (isstring(fd.featuredead)) do
    local nfd = featureDefs[fd.featuredead:lower()]
    if (not nfd) then
      break
    end

    local clipName = ClipName(fd.featuredead, udName)
    fdCopy.featuredead = clipName

    fdCopy = CopyTable(nfd)
    fdMap[nfd] = { clipName, fdCopy }
    fd = nfd
    
    count = count + 1
    if (count > 1024) then
      print('FeatureDead loop in unit ' .. udName .. ' ?')
      break
    end
  end

  local fds = {}
  for _, nameDef in pairs(fdMap) do
    local fdName = nameDef[1]
    local fd     = nameDef[2]
    fds[fdName] = fd
    fd.filename = nil
  end
  ud.featureDefs = fds
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- setup a lua keyword map
local keyWords = {
 'and',      'break',    'do',       'else',     'elseif',   'end',
 'false',    'for',      'function', 'if',       'in',       'local',
 'nil',      'not',      'or',       'repeat',   'return',   'then',
 'true',     'until',    'while'
}
local keyWordSet = {}
for _,w in ipairs(keyWords) do
  keyWordSet[w] = true
end
keyWords = nil  -- don't need the array anymore


local function encloseStr(s)
  return string.format('%q', s)
end


local function encloseKey(s)
  local wrap = not (string.find(s, '^[_%a][_%a%d]*$'))
  if (not wrap) then
    if (string.len(s) <= 0) then wrap = true end
  end
  if (not wrap) then
    if (keyWordSet[s]) then wrap = true end
  end
    
  if (wrap) then
    return string.format('[%q]', s)
  else
    return s
  end
end


local function GetKeyString(k, v)
  if (type(k) == 'number') then
    local str = '[' .. k .. ']'
    return string.format('%-4s = ', str)
  else
    local cased = paramMaps.caseMap[k]
    local str = cased or encloseKey(tostring(k))
    if (type(v) == 'table') then
      return string.format('%s = ', str)
    else
      return string.format('%-18s = ', str)
    end
  end
end


--------------------------------------------------------------------------------

local currentName = ''

local function fprint(file, format, ...)
  local success, str = pcall(string.format, format, ...)
  if (success) then
    file:write(str)
    file:write('\n')
  else
    Spring.Echo(currentName .. ': ' .. str)
  end
end


local function tobool(val)
  local t = type(val)
  if (t == 'nil') then
    return false
  elseif (t == 'bool') then
    return val
  elseif (t == 'number') then
    return (val ~= 0)
  elseif (t == 'string') then
    return ((val ~= '0') and (val ~= 'false'))
  end
  return false
end


--------------------------------------------------------------------------------

local function PrintTable(f, t, depth, name)
  local indent = string.rep(' ', depth * 2)
  local sorted = {}
  for k, v in pairs(t) do
    table.insert(sorted, { k, v })
  end

  table.sort(sorted, function(a, b)
    local avt, bvt = type(a[2]), type(b[2])
    if ((avt == 'table') and (bvt ~= 'table')) then return false end
    if ((avt ~= 'table') and (bvt == 'table')) then return true  end
    return a[1] < b[1]
  end)

  for _, kv in ipairs(sorted) do
    local k = kv[1]
    local v = kv[2]
    local keyStr = GetKeyString(k, v)
--    local keyStr = string.format('%-18s = ', GetKeyString(k))
    if ((name == 'UD.buildoptions') or
        (name == 'UD.sfxtypes.explosiongenerators') or
        (string.find(name, '^UD%.sounds%.'))) then
      keyStr = ''
    end

    if (type(v) == 'table') then
      fprint(f, '%s%s{', indent, keyStr)
      PrintTable(f, v, depth + 1, name .. '.' .. k)
      fprint(f, '%s},', indent)
    else
--      if (#keyStr > 0) then
--        keyStr = string.format('%-18s', keyStr)
--      end
      if (paramMaps.boolMap[k]) then
        local valueStr = tobool(v) and 'true' or 'false'
        fprint(f, '%s%s%s,', indent, keyStr, valueStr)
      elseif (paramMaps.intMap[k] or
              paramMaps.floatMap[k]) then
        fprint(f, '%s%s%s,', indent, keyStr, v)
      elseif (paramMaps.float3Map[k]) then
        local valueStr = v -- FIXME, table formatl
        fprint(f, '%s%s[[%s]],', indent, keyStr, valueStr)
      else
        local num = tonumber(v)
        if (num) then
          fprint(f, '%s%s%s,', indent, keyStr, v)
        else
          fprint(f, '%s%s[[%s]],', indent, keyStr, tostring(v))
        end
      end
    end
  end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local dirname = 'fbi2lua'


local function RemoveFiles(dirname)
  Spring.Echo('Removing *.lua files in: $SPRING/' .. dirname)
  local files = VFS.DirList(dirname, '*.lua')
  for _, f in ipairs(files) do
    os.remove(f)
  end
end


local function TestFile(filename)
  lowerkeys = function(t) return t end
  local chunk, err = loadfile(filename)
  if (not chunk) then
    Spring.Echo(err)
    return
  end

  setfenv(chunk, widget)

  local success, err = pcall(chunk)
  if (not success) then
    Spring.Echo(err)
    return
  end
end


local function PrintUnitDef(f, unitName, unitDef)
  unitDef.filename = nil  -- automatic

  local weaponDefs = unitDef.weaponDefs
  local featureDefs = unitDef.featureDefs
  unitDef.weaponDefs = nil
  unitDef.featureDefs = nil

  local function fline(f)
    f:write(string.rep('-', 80) .. '\n')
  end

  paramMaps = unitParamMaps
  fprint(f, '-- UNITDEF -- %s --', string.upper(unitName))
  fline(f)
  fprint(f, '')
  fprint(f, 'local unitName = "%s"', unitName)
  fprint(f, '')
  fline(f)
  fprint(f, '')
  fprint(f, 'local unitDef = {')
  PrintTable(f, unitDef, 1, 'UD')
  fprint(f, '}')
  fprint(f, '')
  fprint(f, '')
 
  if (weaponDefs) then
    paramMaps = weaponParamMaps
    fline(f)
    fprint(f, '')
    fprint(f, 'local weaponDefs = {')
    PrintTable(f, weaponDefs, 1, 'WD')
    fprint(f, '}')
    fprint(f, 'unitDef.weaponDefs = weaponDefs')
    fprint(f, '')
    fprint(f, '')
  end

  if (featureDefs) then
    paramMaps = featureParamMaps
    fline(f)
    fprint(f, '')
    fprint(f, 'local featureDefs = {')
    PrintTable(f, featureDefs, 1, 'FD')
    fprint(f, '}')
    fprint(f, 'unitDef.featureDefs = featureDefs')
    fprint(f, '')
    fprint(f, '')
  end

  fline(f)
  fprint(f, '')
  fprint(f, 'return lowerkeys({ [unitName] = unitDef })')
  fprint(f, '')
  fline(f)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function PrintCEGDefs(f, cegDefs)
  paramMaps = cegParamMaps

  for cegName in pairs(cegDefs) do
    fprint(f, '-- ' .. cegName)
  end
  fprint(f, '')

  fprint(f, 'return {')

  for cegName,cegDef in pairs(cegDefs) do
    fprint(f, '  ["' .. cegName .. '"] = {')
    PrintTable(f, cegDef, 2, 'CD')
    fprint(f, '  },')
    fprint(f, '')
  end

  fprint(f, '}')
  fprint(f, '')
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function TranslateUnitFeatureWeaponDefs()
  -- remove any existing *.lua files
  RemoveFiles(dirname)

  -- create the directory if it does not exist
  Spring.CreateDir(dirname)

  Spring.Echo('Creating *.lua files in: $SPRING/' .. dirname)

  local success, defs = pcall(VFS.Include, 'gamedata/defs.lua', defsEnv)

  if (not success) then
    Spring.Echo(defs) -- the error
    return
  end

  for unitName, unitDef in pairs(defs.unitdefs) do
    currentName = unitName

    local luaFile = dirname .. '/' .. unitName .. '.lua'
    local f, err = io.open(luaFile, 'w')
    if (f == nil) then
      Spring.Echo(err)
    else
      ProcessWeapons(unitName, unitDef, defs.weapondefs)
      ProcessFeatures(unitName, unitDef, defs.featuredefs)

      PrintUnitDef(f, unitName, unitDef)

      f:close()

      TestFile(luaFile)
    end
  end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Load the TDF explosiondef files
--

function TranslateCEGDefs()
  --helper funcs
  local function ParseColorString(str)
    local color = { 1.0, 1.0, 0.8 }
    local i = 1
    for word in string.gmatch(str, '[^,]+') do
      local val = tonumber(word)
      if (val) then
        color[i] = val
      end
      i = i + 1
      if (i > 3) then
        break
      end
    end
    return color
  end

  local function FixGroundFlashColor(ed)
    for spawnName, groundFlash  in pairs(ed) do
      if ((spawnName == 'groundflash') and (type(groundFlash) == 'table')) then
        local colorStr = groundFlash.color
        if (type(colorStr) == 'string') then
          groundFlash.color = ParseColorString(colorStr)
        end
      end
    end
  end

  local function ExtractFileName(filepath)
    filepath = filepath:gsub("\\", "/")
    local lastChar = filepath:sub(-1)
    if (lastChar == "/") then
      filepath = filepath:sub(1,-2)
    end
    local pos,b,e,match,init,n = 1,1,1,1,0,0
    repeat
      pos,init,n = b,init+1,n+1
      b,init,match = filepath:find("/",init,true)
    until (not b)
    if (n~=1) then
      filepath = filepath:sub(pos+1)
    end
    local _,_,_,filename = filepath:find("((.*)%.).*") --// remove the file extension
    return filename or filepath
  end

  local TDF = TDFparser or VFS.Include('gamedata/parse_tdf.lua')

  local dirname = dirname .. '/cegs'

  -- remove any existing *.lua files
  RemoveFiles(dirname)

  -- create the directory if it does not exist
  Spring.CreateDir(dirname)

  Spring.Echo('Creating *.lua files in: $SPRING/' .. dirname)

  local tdfFiles = VFS.DirList('gamedata/explosions/', '*.tdf')

  for _, filename in ipairs(tdfFiles) do
    local eds, err = TDF.Parse(filename)
    if (eds == nil) then
      Spring.Echo('Error parsing ' .. filename .. ': ' .. err)
    else
      local explosionDefs = {}

      for name, ed in pairs(eds) do
        FixGroundFlashColor(ed)
        explosionDefs[name] = ed
      end

      local luaFile = dirname .. '/' .. ExtractFileName(filename) .. '.lua'
      local f, err = io.open(luaFile, 'w')
      if (f == nil) then
        Spring.Echo(err)
      else
        PrintCEGDefs(f, explosionDefs)
        f:close()
        TestFile(luaFile)
      end
    end
  end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
  --// workaround a bug in parse_fbi.lua
  VFS.LoadFile = function(name, modes)
    if (name == 'gamedata/sidedata.tdf')and(not VFS_FileExists('gamedata/sidedata.tdf')) then
      return "[SIDE0]\n{\nname=blah;\n}\n"
    end

    if (modes) then
      return VFS_LoadFile(name, StripRawMode(modes))
    else
      return VFS_LoadFile(name)
    end
  end

  TranslateUnitFeatureWeaponDefs()
  TranslateCEGDefs()

  widgetHandler:RemoveWidget()
  VFS.LoadFile = VFS_LoadFile
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
