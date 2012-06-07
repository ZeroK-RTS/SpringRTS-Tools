-- $Id: flightTimes.lua 3171 2008-11-06 09:06:29Z det $
local doPreviewOnly = true

local echoColor = "Black"

local weapontags = {
	"guidance",
	"lineofsight",
	"beamlaser",
	"beamweapon",
	"color",
	"color2",
	"dropped",
	"rendertype",
	"selfprop",
	"twophase",
	"vlaunch",
	"holdtime",
	"startsmoke",
	"endsmoke",
	--"minbarrelangle",
}

local unittags = {
	"maneuverleashlength",
	"bmcode",
	"canreclamate",
	"scale",
	"steeringmode",
	"tedclass",
	"designation",
	"defaultmissiontype",
}

local featuretags = {
	"seqnamereclamate",
	"worlds",
	"height",
	"featurereclamate",
}

for unit, weapon, weaponDef in IteratorWeapons() do
	Editor.Echo("---------Unit "..unit.name.." weapon "..weaponDef.name.."------------\n")
	for _,tag in pairs(weapontags) do
		SetTableValue(weaponDef, tag, nil, doPreviewOnly, echoFront, echoColor)
	end
end

for id,unit in pairs(Units) do
	Editor.Echo("---------Unit "..unit.name.."------------\n")
	for _,tag in pairs(unittags) do
		SetTableValue(unit, tag, nil, doPreviewOnly, echoFront, echoColor)
	end	
end