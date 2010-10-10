-- $Id: getUsedCats.lua 3444 2008-12-15 02:52:40Z licho $
local cats = {}

for unitID, unit in pairs(Units) do
  local unitCats = CategoriesToTable(unit.category)
  local noChaseCats = CategoriesToTable(unit.noChaseCategory)
  local weapons = unit.weapons
  
  for cat, _ in unitCats do
    cats[cat] = true
  end
  
  for cat, _ in noChaseCats do
    cats[cat] = true
  end
  
  if (weapons) then
    for weaponID, weapon in pairs(weapons) do
      local onlyTargetCats = CategoriesToTable(weapon.onlyTargetCategory)
      local badTargetCats = CategoriesToTable(weapon.badTargetCategory) 
      
      for cat, _ in onlyTargetCats do
        cats[cat] = true
      end
      
      for cat, _ in badTargetCats do
        cats[cat] = true
      end
    end
  end
end

for cat, _ in pairs(cats) do
  Editor.Echo(cat .. "\n", "Black")
end
