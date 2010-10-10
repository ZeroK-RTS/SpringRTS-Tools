-- $Id: iterator.lua 3444 2008-12-15 02:52:40Z licho $
local thisFile = "iterator"

Editor.Echo("Include \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

function IteratorWeapons()
  local currentUnitID, currentUnit
  local currentWeaponID, currentWeapon
  
  local result = function()
    repeat
      if (currentWeaponID) then
        currentWeaponID, currentWeapon = next(currentUnit.weapons, currentWeaponID)
        if (currentWeapon and currentWeapon.def and currentUnit.weaponDefs[currentWeapon.def]) then
          return currentUnit, currentWeapon, currentUnit.weaponDefs[currentWeapon.def]
        end
      else
        currentUnitID, currentUnit = next(Units, currentUnitID)
        if (currentUnit and currentUnit.weapons and currentUnit.weaponDefs) then
          currentWeaponID, currentWeapon = next(currentUnit.weapons, currentWeaponID)
          if (currentWeapon and currentWeapon.def and currentUnit.weaponDefs[currentWeapon.def]) then
            return currentUnit, currentWeapon, currentUnit.weaponDefs[currentWeapon.def]
          end
        end
      end
    until (currentUnitID == nil)
    
    return nil
  end
  
  return result
end

function IteratorUnitSubtable(subtableKey)
  local currentUnitID, currentUnit
  local currentSubID, currentSub
  
  local result = function ()
    repeat
      if (currentSubID) then
        currentSubID, currentSub = next(currentUnit[subtableKey], currentSubID)
        if (currentSubID) then
          return currentUnit, currentSub
        end
      else
        currentUnitID, currentUnit = next(Units, currentUnitID)
        if (currentUnit and currentUnit[subtableKey]) then
          currentSubID, currentSub = next(currentUnit[subtableKey], currentSubID)
          if (currentSubID) then
            return currentUnit, currentSub
          end
        end
      end
    until (currentUnitID == nil)
    
    return nil
  end
  
  return result
end
