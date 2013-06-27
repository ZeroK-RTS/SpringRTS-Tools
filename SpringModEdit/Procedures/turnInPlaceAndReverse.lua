local doPreviewOnly = true 

local facs = { -- These factory names are completely wrong
	"armvp",
	"corvp",
	"armfhp",
	"corfhp",
	"coravp",
	"armavp",
	"corsy",
	"armsy",
	"factoryveh",
	"factorytank",
	"factoryship",
	"factoryhover",
	"nest",
	"roostfac",
}

for unitID, unit in pairs(Units) do
	if facs[unitID] then
		for index, unitname in pairs(unit.buildoptions) do
			local un = Units[unitname]
			if un ~= nil then 
				SetTableValue(un, "turninplace", 0 , doPreviewOnly, unitname)
			end
		end
	end
	if unit.side == "THUNDERBIRDS" and unit.maxVelocity > 0 and not unit.canFly then
		SetTableValue(unit, "turninplace", 0 , doPreviewOnly, unitID)
	end
end


for name, ud in pairs(Units) do
  if (not ud.TEDClass) or ud.TEDClass:find("SHIP",1,true) or ud.TEDClass:find("TANK",1,true) then
    --Editor.Echo(name) -- ud.maxreversevelocity = ud.maxvelocity * 0.55
  end
end 