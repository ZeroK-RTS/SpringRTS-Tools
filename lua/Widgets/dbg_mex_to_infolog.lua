	
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
local markerFrame = false
	
function widget:Update()
	if metalSpotsNil and WG.metalSpots ~= nil then
		local total = 0
		if WG.metalSpots then
			Spring.Echo("Metal Spots")
			for i = 1, #WG.metalSpots do
				local spot = WG.metalSpots[i]
				Spring.Echo("{x = " .. spot.x .. ", z = " .. spot.z .. ", metal = " .. spot.metal .. "},")
				total = total + spot.metal
			end
			for i = 1, #WG.metalSpots do
				local spot = WG.metalSpots[i]
				Spring.MarkerErasePosition(spot.x,0,spot.z)
			end
			markerFrame = Spring.GetGameFrame()+30
			Spring.Echo("Total Spot Metal " .. total)
		else
			Spring.Echo("Invalid Metal Map")
		end
		metalSpotsNil = false
	end
end
	
	
function widget:GameFrame(f)
	if markerFrame == f then
		for i = 1, #WG.metalSpots do
			local spot = WG.metalSpots[i]
			Spring.MarkerAddPoint(spot.x, 0, spot.z, i .. ": " .. spot.metal)
		end
	end
end