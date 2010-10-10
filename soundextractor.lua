-- $Id: soundextractor.lua 3171 2008-11-06 09:06:29Z det $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file: soundextractor.lua
--  brief: extracts unit sounds for use in snd_noises.lua
--           
--  author:  quantum
--
--  Copyright (C) 2007.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local lfs = require"lfs" -- http://www.keplerproject.org/luafilesystem/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local FBI_DIRNAME = "fbi"
local soundTable = {}


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function lowerkeys(t)
  local a, b = next(t)
  return string.lower(a), b
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


dofile("savetable.lua")

for file in lfs.dir(FBI_DIRNAME) do
  if (file ~= "." and file ~= "..") then
    local fileName = FBI_DIRNAME.."\\"..file
    local unitName, unitTable = dofile(fileName)
    soundTable[unitName] = unitTable.sounds
  end
end

table.save(soundTable, "sounds.lua")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------