local doPreviewOnly = true

for id,unit in pairs(Units) do
	if unit.mass > 60000 then
		Editor.Echo("--------Unit "..unit.unitname.." has mass "..unit.mass..", ignoring--------\n")
	elseif not unit.commander then
		local echoFront = unit.unitname
		local mass = unit.buildTime/2 + unit.maxDamage/10
		mass = (mass^0.55)*9
		mass = math.ceil(mass)
		SetTableValue(unit, "mass", mass, doPreviewOnly, echoFront, echoColor)
	end
end