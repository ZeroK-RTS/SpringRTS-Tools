-- $Id: movedefs.lua 3598 2008-12-30 20:45:38Z evil4zerggin $
local thisFile = "movedefs"

Editor.Echo("Include \"" .. thisFile .. ".lua\" loaded.\n", "Brown")

moveDefs = {

	KBOT1 = {
		footprintx = 1,
		footprintz = 1,
		maxwaterdepth = 15,
		maxslope = 36,
		crushstrength = 5,
	},

	KBOT2 = {
		footprintx = 2,
		footprintz = 2,
		maxwaterdepth = 22,
		maxslope = 36,
		crushstrength = 50,
	},

	KBOT4 = {
		footprintx = 4,
		footprintz = 4,
		maxwaterdepth = 22,
		maxslope = 36,
		crushstrength = 500,
	},
	
	AKBOT2 = {
		footprintx = 2,
		footprintz = 2,
		maxwaterdepth = 5000,
		depthmod = 0,
		maxslope = 36,
		crushstrength = 50,
	},
	
	AKBOT6 = {
		footprintx = 6,
		footprintz = 6,
		maxwaterdepth = 5000,
		depthmod = 0,
		maxslope = 37,
		crushstrength = 5000,
	},
	
	TKBOT1 = {
		footprintx = 1,
		footprintz = 1,
		maxwaterdepth = 15,
		maxslope = 72,
		crushstrength = 5,
	},

	TKBOT3 = {
		footprintx = 3,
		footprintz = 3,
		maxwaterdepth = 22,
		maxslope = 72,
		crushstrength = 150,
	},
	
	TANK2 = {
		footprintx = 2,
		footprintz = 2,
		maxwaterdepth = 22,
		maxslope = 18,
		crushstrength = 50,
	},
	
	TANK3 = {
		footprintx = 3,
		footprintz = 3,
		maxwaterdepth = 22,
		maxslope = 18,
		crushstrength = 150,
	},

	TANK4 = {
		footprintx = 4,
		footprintz = 4,
		maxwaterdepth = 22,
		maxslope = 18,
		crushstrength = 500,
	},
	
	HOVER3 = {
		footprintx = 3,
		footprintz = 3,
		maxslope = 36,
		slopemod = 36.7,
		crushstrength = 5,
	},
	
	BOAT3 = {
		footprintx = 3,
		footprintz = 3,
		minwaterdepth = 5,
		crushstrength = 150,
	},

	BOAT4 = {
		footprintx = 4,
		footprintz = 4,
		minwaterdepth = 10,
		crushstrength = 500,
	},
	
	BOAT6 = {
		footprintx = 6,
		footprintz = 6,
		minwaterdepth = 15,
		crushstrength = 5000,
	},
	
	UBOAT3 = {
		footprintx = 3,
		footprintz = 3,
		minwaterdepth = 15,
		crushstrength = 5,
		subMarine = 1,
	},
}
