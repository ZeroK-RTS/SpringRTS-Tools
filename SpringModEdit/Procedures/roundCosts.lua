local cUnits = {}
local i = 1
for name, unit in pairs(Units) do
        if unit.buildCostMetal > 1 then
                cUnits[i] = {unit.buildCostMetal, name}
                i = i + 1
        end
end
table.sort(cUnits, function(a,b) return a[1] < b[1] end)
 
local function round(input, step)
        local rounded = step * math.floor(input / step + 0.501)
        local change = (rounded / input - 1) * 100
        return rounded, change
end
 
local roundSteps = {}
 
for _,unit in pairs(cUnits) do
        local cost, name = unpack(unit)
        if cost > 400 then
                roundSteps = {1000, 100, 50}
        elseif cost > 100 then
                roundSteps = {50, 20, 10}
        else
                roundSteps = {25, 10, 5}
        end
        for i,roundStep in ipairs(roundSteps) do
                local rCost, change = round(cost, roundStep)
                Editor.Echo(cost..'  '..rCost..'  '..change..' '..roundStep)
                if math.abs(change) < 5 or i == 3 then
                        Editor.Echo('  yes\n')
                        unit[3] = rCost
                        unit[4] = change
						Units[unit[2]].buildCostMetal = rCost
						Units[unit[2]].buildCostEnergy = rCost
						Units[unit[2]].buildTime = rCost
                        break
                else
                        Editor.Echo('  no\n')
                end
        end
		
end
 
--table.sort(cUnits, function(a,b) return math.abs(a[4]) > math.abs(b[4]) end)
 
local function Pad(str, len) return string.sub(str,1,len) .. string.rep(' ', len - string.len(str)) end
local function PrintUnit(unit)
        local toPrint = ''
        toPrint = toPrint .. Pad(unit[2], 20)
        toPrint = toPrint .. '   '
        toPrint = toPrint .. Pad(round(unit[1], .1), 10)
        toPrint = toPrint .. '   '
        toPrint = toPrint .. Pad(round(unit[3], .1), 10)
        toPrint = toPrint .. '   '
        toPrint = toPrint .. Pad(round(unit[4], .1), 5)
        toPrint = toPrint .. '%'
        Editor.Echo(toPrint..'\n')
end
 
for _,unit in pairs(cUnits) do
        --if unit[4] > 1 then
                PrintUnit(unit)
        --end
end
