-- $Id: globaltest.lua 3171 2008-11-06 09:06:29Z det $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    globaltest.lua
--  brief:   reports global usage
--  author:  quantum
--
--  Copyright (C) 2008.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- requires a lua compiler
-- needs lfs for FindAllGlobals() (http://www.keplerproject.org/luafilesystem/)

local COMPILER   = 'luac'
local WIDGET_DIR = "LuaUI/Widgets"
local GADGET_DIR = "LuaRules/Gagets"


local function FindLines(output, s1, s2)
  print("\tGlobal "..s2..":")
  local text = {}
  for line in output:gmatch("[^\n]*") do
    if (string.find(line, s1)) then
      local lineNumber = line:match("%[(%d*)%]")
      local globalName = line:match(";%s([%w_]*)%s*$")
      text[#text+1] = "\t\t"..lineNumber.."\t"..globalName
    end
  end
  if (#text == 0) then
    print("\t\tNo global "..s2.." found.")
  else
    print("\t\tLine:\tVariable:")
    print(table.concat(text, "\n"))
  end
end


local function FindGlobals(path, file)
  print("\n"..file.."\n")
  local s = string.format(COMPILER..' -l -p "'..path..'/'..file..'"') 
  local output = io.popen(s):read("*a")
  local found
  FindLines(output, "SETGLOBAL", "assignments")
  FindLines(output, "GETGLOBAL", "reads")
  print""
end


local function ProcessDir(path)
  for file in lfs.dir(path) do
    if (file ~= "." and file ~= "..") then
      local attr = assert(lfs.attributes(path..'/'..file))
      if (attr.mode == "directory") then
        ProcessDir(path..'/'..file)
      elseif (attr.mode == "file" and
              string.sub(file, -4) == ".lua") then
        FindGlobals(path, file)
      end
    end
  end
end


local function FindAllGlobals()
  require"lfs" 
  ProcessDir(WIDGET_DIR)
  ProcessDir(GADGET_DIR)
end


FindAllGlobals()
-- FindGlobals(WIDGET_DIR, "gui_jumpjets.lua")


