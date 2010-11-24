local doPreviewOnly = true

local baseUnit = "armzeus"	--set to nil to manually specifiy the base values
local baseAccel = 0
local baseBrake = 0
local baseTurn = 0

--proportion of difference to used as the increase amount
local accelFactor = 0.1	
local brakeFactor = 0.1
local turnFactor = 0.13

for id,unit in pairs(Units) do
	if unit.unitname == baseUnit then
		baseAccel = unit.acceleration
		baseBrake = unit.brakeRate
		baseTurn = unit.turnRate
		Editor.Echo("--------Base acceleration set to "..baseAccel.."-------\n")
		Editor.Echo("--------Base brakeRate set to "..baseBrake.."-------\n")
		Editor.Echo("--------Base turnRate set to "..baseTurn.."-------\n")
		break
	end
end

for id,unit in pairs(Units) do
	if not unit.canFly then
		if unit.acceleration and unit.acceleration > 0 and unit.acceleration < baseAccel then
			local diff = baseAccel - unit.acceleration
			local newVal = unit.acceleration + diff*accelFactor
			local echoFront = unit.unitname
			--Editor.Echo(unit.name.."\t"..unit.acceleration.."\t"..newVal.."\n")
			--SetTableValue(unit, "acceleration", newVal, doPreviewOnly, echoFront, echoColor)
		end
		if unit.brakeRate and unit.brakeRate > 0 and unit.brakeRate < baseBrake then
			local diff = baseBrake - unit.brakeRate
			local newVal = unit.brakeRate + diff*brakeFactor
			local echoFront = unit.unitname
			--Editor.Echo(unit.name.."\t"..unit.brakeRate.."\t"..newVal.."\n")
			--SetTableValue(unit, "brakeRate", newVal, doPreviewOnly, echoFront, echoColor)
		end
		if unit.turnRate and unit.turnRate > 1 and unit.turnRate < baseTurn then
			local diff = baseTurn - unit.turnRate
			local newVal = math.ceil(unit.turnRate + diff*turnFactor)
			local echoFront = unit.unitname
			--Editor.Echo(unit.name.."\t"..unit.turnRate.."\t"..newVal.."\n")
			--SetTableValue(unit, "turnRate", newVal, doPreviewOnly, echoFront, echoColor)
		end
	end
end