-- $Id: icons.lua 3444 2008-12-15 02:52:40Z licho $
-- Generates icon list for icon builder

local addSubIcons = false -- generate instrunctions to add stealth/cloak etc subicons
local changeIconExtension = false

local colors = {
  eco = {40/255,252/255,3/255},
  build = {3/255,252/255,244/255},
  unit = {252/255,23/255,3/255},
  turret = {244/255,3/255,252/255},
  other = {252/255,244/255,3/255},
}

local iconSeparator = "|"
local separator = ";"


function AddIcon(name, x,y,w,h) 
  return iconSeparator .. name..separator..x..separator..y..separator..w..separator..h..separator
end

function AddColor(r,g,b)
  return r..separator..g..separator..b..separator
end


for id,unit in pairs(Units) do 
  line = (unit.buildPic or id..".pcx")
  if (changeIconExtension) then
    local name = string.sub(line,1,string.len(line)-4) .. ".png"
    SetTableValue(unit, "buildPic", name , false, id, "Black")
  end

  line = line .. AddIcon((unit.iconType or "default")..".png", 96-40, 0,40,40)
  
  local cat = "other"
  if (GetUnitIsEnergy(unit) or GetUnitIsMetal(unit)) and not GetUnitIsWorker(unit) then
    cat = "eco"
  elseif (GetUnitIsWorker(unit)) then
   cat = "build"
  elseif (GetUnitIsStatic(unit) and GetUnitHasAttack(unit)) then
   cat = "turret"
  elseif (GetUnitHasAttack(unit)) then
   cat = "unit"
  end

  line = line .. AddColor(unpack(colors[cat]))
  
  if (addSubIcons) then 
  
    local count = 0
    if (GetUnitCanCloak(unit)) then
     line = line .. AddIcon("cloak.png", count*32, 0, 32,32)
     count = count + 1
    end
 
    if (unit.stealth or false) then
      line = line .. AddIcon("stealth.png", count*32,0,32,32)
      count = count + 1
    end
  end
 

  Editor.Echo(line .. "\n")  
end

