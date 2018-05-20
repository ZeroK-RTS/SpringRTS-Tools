
function widget:GetInfo()
	return {
		name      = "Stats Process",
		desc      = "Processes stats",
		author    = "GoogleFrog",
		date      = "20 May 2018",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Data processing

local factoryOrder = {
	factorycloak   = 1,
	factoryshield  = 2,
	factoryveh     = 3,
	factoryhover   = 4,
	factoryspider  = 5,
	factoryjump    = 6,
	factorytank    = 7,
	factoryamph    = 8,
	factoryplane   = 9,
	factorygunship = 10,
	factoryship    = 11,
	none           = 12,
}

local factoryList = {
	"factorycloak",
	"factoryshield",
	"factoryveh",
	"factoryhover",
	"factoryspider",
	"factoryjump",
	"factorytank",
	"factoryamph",
	"factoryplane",
	"factorygunship",
	"factoryship",
	"none",
}

local factoryName = {
	"C",
	"L",
	"R",
	"H",
	"D",
	"J",
	"T",
	"A",
	"P",
	"G",
	"S",
	"N",
}

local factoryLongName = {
	"Cloaky",
	"Shield",
	"Rover",
	"Hover",
	"Spider",
	"Jump",
	"Tank",
	"Amph",
	"Plane",
	"Gunship",
	"Ship",
	"None",
}

local function GetMatchupData(battles, eloMinLimit, eloRangeLimit)
	local factoryMatchup = {}
	for i = 1, 12 do
		local tbl = {}
		for j = 1, 12 do
			tbl[j] = 0
		end
		factoryMatchup[i] = tbl
	end
	
	local gameCount = 0
	for i = 1, #battles do
		local data = battles[i]
		local minElo = math.min(data.LoserElo or 0, data.WinnerElo or 0)
		local maxElo = math.max(data.LoserElo or 0, data.WinnerElo or 0)
		if minElo >= eloMinLimit and maxElo - minElo <= eloRangeLimit then
			gameCount = gameCount + 1
			local winPlop = data.WinnerPlop or "none"
			local losePlop = data.LoserPlop or "none"
			
			local winIndex = factoryOrder[winPlop]
			local loseIndex = factoryOrder[losePlop]
			factoryMatchup[winIndex][loseIndex] = factoryMatchup[winIndex][loseIndex] + 1
		end
	end
	
	Spring.Echo("=========== factory matchups ===========")
	Spring.Echo("eloMinLimit", eloMinLimit, "eloRangeLimit", eloRangeLimit, "gameCount", gameCount)
	
	Spring.Echo("Row against column - raw wins")
	local echoLine = "|| || "
	for i = 1, 12 do
		echoLine = echoLine .. factoryName[i] .. " || "
	end
	Spring.Echo(echoLine)
	
	for i = 1, 12 do
		echoLine = "|| " .. factoryName[i] .. " || "
		for j = 1, 12 do
			echoLine = echoLine .. factoryMatchup[i][j] .. " || "
		end
		Spring.Echo(echoLine)
	end
	
	Spring.Echo("Row against column - win chance")
	local echoLine = "|| || "
	for i = 1, 12 do
		echoLine = echoLine .. factoryName[i] .. " || "
	end
	Spring.Echo(echoLine)
	
	for i = 1, 12 do
		echoLine = "|| " .. factoryName[i] .. " || "
		for j = 1, 12 do
			if factoryMatchup[i][j] + factoryMatchup[j][i] == 0 then
				echoLine = echoLine .. "---" .. " || "
			else
				echoLine = echoLine .. string.format("%.0f", 100*factoryMatchup[i][j]/(factoryMatchup[i][j] + factoryMatchup[j][i])) .. " || "
			end
		end
		Spring.Echo(echoLine)
	end
end

local function GetPickrateData(battles, eloMinLimit, eloRangeLimit)
	local factoryStats = {}
	local gameCount = 0
	for i = 1, #battles do
		local data = battles[i]
		local minElo = math.min(data.LoserElo or 0, data.WinnerElo or 0)
		local maxElo = math.max(data.LoserElo or 0, data.WinnerElo or 0)
		if minElo >= eloMinLimit and maxElo - minElo <= eloRangeLimit then
			gameCount = gameCount + 1
			local winPlop = data.WinnerPlop or "none"
			local losePlop = data.LoserPlop or "none"
			
			factoryStats[winPlop] = factoryStats[winPlop] or {0, 0, 0}
			factoryStats[losePlop] = factoryStats[losePlop] or {0, 0, 0}
			if winPlop == losePlop then
				factoryStats[winPlop][3] = factoryStats[winPlop][3] + 1
			else
				factoryStats[winPlop][1] = factoryStats[winPlop][1] + 1
				factoryStats[winPlop][2] = factoryStats[winPlop][2] + 1
				factoryStats[losePlop][1] = factoryStats[losePlop][1] + 1
			end
		end
	end
	
	Spring.Echo("=========== factory stats ===========")
	Spring.Echo("eloMinLimit", eloMinLimit, "eloRangeLimit", eloRangeLimit, "gameCount", gameCount)
	Spring.Echo([[|| Factory || Winrate (excluding mirror) || Pick Count || Mirror Matches ||]])
	for i = 1, #factoryList do
		local data = factoryStats[factoryList[i]]
		if data then
			Spring.Echo([[|| ]] .. factoryLongName[i] .. [[ || ]] .. string.format("%.2f%%", 100*(data[2] + data[3])/(data[1] + data[3]*2)) .. [[ (]] .. string.format("%.2f%%", 100*data[2]/data[1]) .. [[) || ]] .. data[1] + data[3]*2 .. [[ || ]] .. data[3] .. [[ ||]])
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization
local hasRun = false
function widget:Update()
	if hasRun then
		return
	end
	local battleData = VFS.Include("LuaUI/replays.lua", nil, VFS.RAW_FIRST)
	hasRun = true
	
	for i = 1, #battleData do
		battleData[i] = Spring.Utilities.json.decode(battleData[i])
	end
	GetMatchupData(battleData, 500, 500)
	GetPickrateData(battleData, 500, 500)
	
	GetMatchupData(battleData, 1500, 500)
	GetPickrateData(battleData, 1500, 500)
	
	GetMatchupData(battleData, 2000, 500)
	GetPickrateData(battleData, 2000, 500)
end
