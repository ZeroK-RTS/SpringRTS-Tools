-- $Id: resourceRatios.lua 3444 2008-12-15 02:52:40Z licho $
local doPreviewOnly =  true

--modes:
--"total": base new costs on total cost
--"metal": base new costs on metal cost
local mode = "metal"

--how much energy/time is equal to 1 metal
local worthEPerM = 60
local worthTPerM = 120

--energy/time ratios
local ratios = {
  air = {20, 25,},
  mobile = {10, 15,},
  economy = {7, 13,},
  defenses = {10, 15,},
  factory = {2, 7,},
  other = {10, 15,},
}

--ignore these units
--commanders and features are automatically ignored
local ignore = {
--  armsolar = true,
--  corsolar = true,
--  armwin = true,
--  corwin = true,
--  armmex = true,
--  cormex = true,
--  armtide = true,
--  cortide = true,
}

for unitID, unit in pairs(Units) do
  if (not ignore[unitID]) and (not (ToBool(unit.commander) or ToBool(unit.isFeature))) then
    local class
    if (GetUnitIsFactory(unit)) then
      class = "factory"
    elseif (ToBool(unit.canFly)) then
      class = "air"
    elseif (GetUnitIsMobile(unit)) then
      class = "mobile"
    elseif (GetUnitIsMetal(unit) or GetUnitIsEnergy(unit) or GetUnitIsStorage(unit)) then 
      class = "economy"
    elseif (GetUnitIsStatic(unit) and GetUnitHasAttack(unit)) then
      class = "defenses"
    else 
      class = "other"
    end

    Editor.Echo(class.." "..unit.name.." "..unit.description..'\n',"Blue")
    
    if (mode == "total") then
      local totalCost = ToNumber(unit.buildCostMetal) + ToNumber(unit.buildCostEnergy) / worthEPerM + ToNumber(unit.buildTime) / worthTPerM
      
      local totalShares = 1 + ratios[class][1] / worthEPerM + ratios[class][2] / worthTPerM
      
      local costPerShare = totalCost / totalShares
      local metalCost = math.ceil(costPerShare)
      local energyCost = math.ceil(costPerShare * ratios[class][1])
      local timeCost = math.ceil(costPerShare * ratios[class][2])

      SetTableValue(unit, "buildCostMetal", metalCost, doPreviewOnly, unitID, "Black")
      SetTableValue(unit, "buildCostEnergy", energyCost, doPreviewOnly, unitID, "Black")
      SetTableValue(unit, "buildTime", timeCost, doPreviewOnly, unitID, "Black")
    elseif (mode == "metal") then
      local metalCost = ToNumber(unit.buildCostMetal)
      local oldE = ToNumber(unit.buildCostEnergy)
      local oldT = ToNumber(unit.buildTime)

      metalCost = metalCost - (metalCost*8 - oldE)/50 - (metalCost*20 - oldT)/100
      SetTableValue(unit, "buildCostMetal", metalCost , doPreviewOnly, unitID, "Black") -- ratios[class][1]
      SetTableValue(unit, "buildCostEnergy", metalCost * 8 , doPreviewOnly, unitID, "Black") -- ratios[class][1]
      SetTableValue(unit, "buildTime", metalCost * 20, doPreviewOnly, unitID, "Black") -- ratios[class][2]
    else 
      Editor.Echo("resourceRatios.lua: Invalid mode.", "Red")
    end
  end
end