	
function widget:GetInfo()
  return {
    name      = "Debug Metal Spot to Infolog",
    desc      = "Prints and marks detected metal spots in config format.",
    author    = "Google Frog", 
    date      = "23 April 2012",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = false  --  loaded by default?
  }
end
	
local metalSpotsNil = true
	
function widget:Update()
	if metalSpotsNil and WG.metalSpots ~= nil then
		if WG.metalSpots then
			Spring.Echo("Metal Spots")
			for i = 1, #WG.metalSpots do
				local spot = WG.metalSpots[i]
				Spring.Echo("{x = " .. spot.x .. ", z = " .. spot.z .. ", metal = " .. spot.metal .. "},")
			end
			for i = 1, #WG.metalSpots do
				local spot = WG.metalSpots[i]
				Spring.MarkerAddPoint(spot.x, 0, spot.z, i .. ": " .. spot.metal)
			end
		else
			Spring.Echo("Invalid Metal Map")
		end
		metalSpotsNil = false
	end
end
	