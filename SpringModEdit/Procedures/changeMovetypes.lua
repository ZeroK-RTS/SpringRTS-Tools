-- $Id: changeMovetypes.lua 3171 2008-11-06 09:06:29Z det $
local doPreviewOnly = true

local replacements = {
  HOVER3 = "HOVER2",
  HTANK4 = "TANK4",
  ATANK3 = "AKBOT2",
  HTKBOT5 = "AKBOT6",
  VKBOT5 = "TKBOT1",
  HOVER4 = "HOVER2",
  BOAT5 = "BOAT4",
  TANK3 = "TANK2",
  BOAT4 = "BOAT2",
  HTANK3 = "TANK4",
  DBOAT6 = "BOAT6",
  HAKBOT4 = "AKBOT4",
  TKBOT3 = "TKBOT2",
  HTKBOT4 = "TKBOT2",
  HDBOAT8 = "BOAT6",
  ATKBOT1 = "TKBOT1",
  DBOAT3 = "UBOAT4",
  HKBOT4 = "KBOT4",
}

for unitID, unit in pairs(Units) do
  local movetype = unit.movementClass
  if (movetype and replacements[movetype]) then
    movetype = replacements[movetype]
  end
  SetTableValue(unit, "movementClass", movetype, doPreviewOnly, unitID, "Blue")
  
  if (movetype and GetUnitIsMobile(unit) and not ToBool(unit.canFly)) then
    local footprint = ToNumber(string.sub(movetype, -1))
    SetTableValue(unit, "footprintX", footprint, doPreviewOnly, unitID, "Black")
    SetTableValue(unit, "footprintZ", footprint, doPreviewOnly, unitID, "Black")
  end
end

