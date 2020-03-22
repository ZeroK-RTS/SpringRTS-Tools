function gadget:GetInfo()
	return {
		name      = "UnitRulesParam checker",
		desc      = "Tool checking for uncleared unitrulesparams",
		author    = "GoogleFrog",
		date      = "22 March 2020",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true --  loaded by default?
	}
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

if (not gadgetHandler:IsSyncedCode()) then
	return
end

local idStrings = {}
for j = 1, 100000 do
	idStrings[j] = "test" .. j
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
function gadget:UnitCreated(unitID)
	for j = 1, 100000 do
		Spring.SetUnitRulesParam(unitID, idStrings[j], 1)
	end
end

local function CheckParams(objectID, obType)
	local rulesParams = Spring["Get" .. obType .. "RulesParams"](objectID)
	if not rulesParams then
		return
	end
	
	local params = {}
	for k, v in pairs(rulesParams) do
		params[#params + 1] = k
	end
	
	if #params > 0 then
		--Spring.Utilities[obType .. "Echo"](objectID, obType .. ": " .. (#params))
		--Spring.Echo(obType .. "RulesParams", unpack(params))
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	CheckParams(unitID, "Unit")
end

function gadget:FeatureDestroyed(featureID, allyTeam)
	CheckParams(featureID, "Feature")
end
