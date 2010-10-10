-- $Id: airUnits.lua 3171 2008-11-06 09:06:29Z det $
local doPreviewOnly = true

for id,unit in pairs(Units) do
  if (GetUnitCanFly(unit)) then
    local echoFront = unit.unitname
    SetTableValue(unit, "floater", true, doPreviewOnly, echoFront, echoColor)
    SetTableValue(unit, "amphibious", true, doPreviewOnly, echoFront, echoColor)
    SetTableValue(unit, "canSubmerge", unit.side == "ARM", doPreviewOnly, echoFront, echoColor)
    if (GetUnitIsBomber(unit)) then
      SetTableValue(unit, "noAutoFire", false, doPreviewOnly, echoFront, echoColor)
    end
  end
end

