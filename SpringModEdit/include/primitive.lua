-- $Id: primitive.lua 3444 2008-12-15 02:52:40Z licho $
--primitive.lua
--by Evil4Zerggin

local thisFile = "primitive"

Editor.Echo("Include \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

function ToBool(value)
  if (value == "0" or value == 0) then
    return false
  elseif (value) then
    return true
  else
    return false
  end
end

--use for printing messages
--deepSearch not safe with circular tables! defaults To false
function ToString(value, deep)
  if (value == nil) then
    return "nil"
  elseif (value == true) then
    return "true"
  elseif (value == false) then
    return "false"
  elseif (type(value) == "table") then
    if (deep) then
      local result = "{"
      --indexed portion
      for key, innerValue in ipairs(value) do
        result = result .. ToString(key) .. " = " .. ToString(innerValue, true) .. ", "
      end
      --non-indexed portion
      for key, innerValue in pairs(value) do
        if (type(key) ~= "number") then
          result = result .. ToString(key) .. " = " .. ToString(innerValue, true) .. ", "
        end
      end
      result = result .. "}"
      return result
    else
      return "(table)"
    end
  elseif (type(value) == "function") then
    return "(function)"
  else
    return "" .. value
  end
end

function ToNumber(value)
  if (type(value) == "number") then
    return value
  elseif (type(value) == "string") then
    return value + 0
  elseif (ToBool(value)) then
    return 1
  else
    return 0
  end
end

function NumberToUpperLetter(num)
  if (num < 1 or num > 26) then
    return string.char()
  else
    return string.char(num + 64)
  end
end

function NumberToLowerLetter(num)
  if (num < 1 or num > 26) then
    return string.char()
  else
    return string.char(num + 96)
  end
end

function RoundDecimal(num, places)
  num = num * 10^places
  num = num + 0.5
  num = math.floor(num)
  num = num / 10^places
  return num
end

function RoundSignificantFigures(num, places)
  local msd = math.floor(math.log10(num)) + 1
  num = num * 10^(-msd + places)
  num = num + 0.5
  num = math.floor(num)
  num = num * 10^(msd - places)
  return num
end

function RoundIncrement(num, increment)
  num = num / increment
  num = num + 0.5
  num = math.floor(num)
  num = num * increment
  return num
end

--deep not safe with circular tables! defaults To false
function CopyTable(tableToCopy, deep)
  local copy = {}
  for key, value in pairs(tableToCopy) do
    if (deep and type(value) == "table") then
      copy[key] = CopyTable(value, true)
    else
      copy[key] = value
    end
  end
  return copy
end

function CompareTables(a, b, deep)
  if (type(a) ~= "table" or type(b) ~= "table") then
    return false
  end

  for key, value in pairs(a) do
    if (type(value) == "table" and deep) then
      if (type(b[key]) ~= "table") then
        return false
      elseif (not CompareTables(value, b[key], true)) then
        return false
      end
    elseif (value ~= b[key]) then
      return false
    end
  end
  return true
end

------------------------------------------------
--set and replace: set unconditionally sets a table value, while replace replaces a table value if it matches oldValue
--also echoes a message stating the key name, the original 
--last three arguments are optional:
--doPreviewOnly: If this is true, then the value will not actually be changed, but the change will still be echoed. Good for seeing what something will do without actually doing it.
--echoFront: what To put at the front of the message
--echoColor: the message will be in this color
------------------------------------------------

function SetTableValue(tableToMod, key, newValue, doPreviewOnly, echoFront, echoColor)
  if (tableToMod[key] == newValue) then
    return false
  end

  Editor.Echo((echoFront or "") .. " key " .. ToString(key) .. " to be set from " .. ToString(tableToMod[key]) .. " to " .. ToString(newValue) .. "\n", echoColor or "Black")
  if (not doPreviewOnly) then
      tableToMod[key] = newValue
      Editor.Echo("-> Done.\n", color or "Black")
  end
  return true
end

function SetSubtable(tableToMod, key, newSubtable, deep, doPreviewOnly, echoFront)
  if (newSubtable == nil) then
    Editor.Echo((echoFront or "") .. " key " .. ToString(key) .. " to be set to nil\n", "Red") 
    if (not doPreviewOnly) then
      tableToMod[key] = newSubtable
      Editor.Echo("-> Done.\n", "Black")
    end
    return true
  end

  if (CompareTables(tableToMod[key], newSubtable, deep)) then
    return false
  end

  Editor.Echo((echoFront or "") .. " key " .. ToString(key) .. " to be set from\n", "Black") 
  Editor.Echo(ToString(tableToMod[key], deep) .. "\n", "Red") 
  Editor.Echo(ToString("to\n", "Black"))
  Editor.Echo(ToString(newSubtable, deep) .. "\n", "Green")
  if (not doPreviewOnly) then
      tableToMod[key] = newSubtable
      Editor.Echo("-> Done.\n", "Black")
  end
  return true
end

function ReplaceTableValue(tableToMod, key, oldValue, newValue, doPreviewOnly, echoFront, echoColor)
  if (tableToMod[key] == oldValue) then
    Editor.Echo((echoFront or "") .. " key " .. ToString(key) .. " to be replaced from " .. ToString(tableToMod[key]) .. " to " .. ToString(newValue) .. "\n", echoColor or "Black")
    if (not doPreviewOnly) then
        tableToMod[key] = newValue
        Editor.Echo("-> Done.\n", color or "Black")
    end
    return true
  else
    return false
  end
end

function ModTableValue(tableToMod, key, modFunc, doPreviewOnly, echoFront, echoColor)
  local newValue = modFunc(tableToMod[key])
  return SetTableValue(tableToMod, key, newValue, doPreviewOnly, echoFront, echoColor)
end
