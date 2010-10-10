-- $Id: explicitWeaponTypes.lua 2490 2008-07-17 13:35:15Z det $
local doPreviewOnly = true

for unit, weapon, weaponDef in IteratorWeapons() do
	if (weaponDef.areaofeffect and weaponDef.areaofeffect <= 16) or (weaponDef.impactOnly and not weaponDef.noexpode) or (weaponDef.damage.default and weaponDef.damage.default <= 20) then
	  Editor.Echo("---------Unit "..unit.name.." weapon "..weaponDef.name.."------------\n")
	  SetTableValue(weaponDef, "craterBoost", 0, doPreviewOnly, echoFront, "Black")
	  SetTableValue(weaponDef, "craterMult", 0, doPreviewOnly, echoFront, "Black")
	end
end
