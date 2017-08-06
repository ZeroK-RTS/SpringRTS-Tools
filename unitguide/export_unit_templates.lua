local exportAsJson = false
local infoboxOnly = true	-- only for mediawiki format; json is always infobox-only

local function to_string(data, indent)
    local str = ""

    if(indent == nil) then
        indent = 0
    end
	local indenter = "    "
    -- Check the type
    if(type(data) == "string") then
        str = str .. (indenter):rep(indent) .. data .. "\n"
    elseif(type(data) == "number") then
        str = str .. (indenter):rep(indent) .. data .. "\n"
    elseif(type(data) == "boolean") then
        if(data == true) then
            str = str .. "true"
        else
            str = str .. "false"
        end
    elseif(type(data) == "table") then
        local i, v
        for i, v in pairs(data) do
            -- Check for a table in a table
            if(type(v) == "table") then
                str = str .. (indenter):rep(indent) .. i .. ":\n"
                str = str .. to_string(v, indent + 2)
            else
                str = str .. (indenter):rep(indent) .. i .. ": " .. to_string(v, 0)
            end
        end
	elseif(type(data) == "function") then
		str = str .. (indenter):rep(indent) .. 'function' .. "\n"
    else
        print(1, "Error: unknown data type: %s", type(data))
    end

    return str
end

local function SplitString(str, sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(str, pattern, function(c) fields[#fields+1] = c end)
  return fields
end

-- not always correct but better than nothing
local vowels = {a = true, e = true, i = true, o = true, u = true}
local function getArticle(text)
	text = string.lower(text)
	local firstLetter = string.sub(text, 0, 1)
	if vowels[firstLetter] then
		return "an"
	end
	return "a"
end

local function tobool(val)
  local t = type(val)
  if (t == 'nil') then
    return false
  elseif (t == 'boolean') then
    return val
  elseif (t == 'number') then
    return (val ~= 0)
  elseif (t == 'string') then
    return ((val ~= '0') and (val ~= 'false'))
  end
  return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

path = arg[1]
output = arg[2]
lang = arg[3]

local nl = "\n"
local nlnl = "\n\n"

local f = loadfile('./unit_guide_conf.lua')
local faction_data = f()

local unitDefs = {}
local weaponDefs = {}

local printedunitlistkeys = {}

Spring = { 
	GetModOptions = function() end,
	GetPlayerList = function() return {}; end,
	GetModOptions = function() return 'asdf' end,
	Echo = function(...) print(...) end
}

local DO_NOT_INCLUDE = {	-- FIXME HAX
	["gamedata/modularcomms/unitdefgen.lua"] = true,
	["gamedata/planetwars/pw_unitdefgen.lua"] = true,
	["gamedata/planetwars/pw_unitdefgen.lua"] = true,
}

VFS = {
	Include = function(subpath)
		if DO_NOT_INCLUDE[subpath] then
			return	
		end
		return dofile(path .. "/" .. subpath)
	end,
	DirList = function() return {} end
}

function lowerkeys(t) --must be before openfile
	local tn = {}
	for i,v in pairs(t) do
		local typ = type(i)
		if type(v)=="table" then
			v = lowerkeys(v)
		end
		if typ=="string" then
			tn[i:lower()] = v
		else
			tn[i] = v
		end
	end
	return tn
end


function openfile2(filename)
	--local success,errors = pcall(dofile, path .. '/' .. filename ..'.lua')
	local f = loadfile(filename )
	return f and f() or nil
end

--[[
There is no directory listing function in Lua as
it's a compact language ... but there may be some
alternatives in your environment library. Here's
a Linux example of a directory parser
]]

local function scandir(dirname)
	callit = os.tmpname()
	os.execute("ls -a1 "..dirname .. " >"..callit)
	fs = io.open(callit,"r")
	rv = fs:read("*all")
	fs:close()
	os.remove(callit)

	tabby = {}
	local from  = 1
	local delim_from, delim_to = string.find( rv, "\n", from  )
	while delim_from do
		table.insert( tabby, string.sub( rv, from , delim_from-1 ) )
		from  = delim_to + 1
		delim_from, delim_to = string.find( rv, "\n", from  )
	end
	-- table.insert( tabby, string.sub( rv, from  ) )
	-- Comment out eliminates blank line on end!
	return tabby
end

local function GetRevision()
	callit = os.tmpname()
	
	--os.execute("svn info " .. faction_data.svnurl .." >"..callit)
	
	--os.execute("git rev-list --count HEAD >"..callit)
	
	os.execute("date >"..callit)
	
	fs = io.open(callit,"r")
	rv = fs:read("*all")
	fs:close()
	os.remove(callit)
	--return rv:match( 'Last Changed Rev:%s*(%d+)' )
	return rv
end

local fileList = scandir(path ..'/units')
for n,fileName in ipairs(fileList) do	
	if fileName:find('.lua$') then

		local unitDefsTable = openfile2(path ..'/units/'.. fileName)
		if not unitDefsTable then 
			print('Error #1 ' .. fileName)
		else
			for k,v in pairs(unitDefsTable) do
				v.unitname = k --jw
				unitDefs[k] = v
			end
		end
	end
end

fileList = scandir(path ..'/weapons')
for n,fileName in ipairs(fileList) do	
	if fileName:find('.lua$') then

		local weaponDefsTable = openfile2(path ..'/weapons/'.. fileName)
		if not weaponDefsTable then 
			print('Error #2 ' .. fileName)
		else
			for k,v in pairs(weaponDefsTable) do
				weaponDefs[ k:lower() ] = v
			end
		end
	end
end

--------------------------------------------------------------------------------
-- unitdefs_post, weapondefs_post
--------------------------------------------------------------------------------
-- synonyms
UnitDefs = unitDefs
UnitDefNames = UnitDefs
WeaponDefs = weaponDefs
DEFS = {
	unitDefs = unitDefs
}
local UnitDefsByFakeID = {}

do
	local count = 0
	for name,data in pairs(UnitDefNames) do
		count = count + 1
		data.id = count
		UnitDefsByFakeID[data.id] = data
	end
end
-- dummy
commDefs = {}

dofile(path .. "/gamedata/unitdefs_post.lua")
dofile(path .. "/gamedata/weapondefs_post.lua")

local droneCarriers = {}
do
	-- use this to supply drone_defs.lua with the fake unit IDs and other stuff it needs
	local temp = UnitDefs
	UnitDefs = UnitDefsByFakeID
	for i=1,#UnitDefs do
		UnitDefs[i].health = UnitDefs[i].maxdamage	
	end
	
	droneCarriers = dofile(path .. "/LuaRules/Configs/drone_defs.lua")
	
	UnitDefs = temp
	for i=1,#UnitDefs do
		UnitDefs[i].health = nil
	end
end

--------------------------------------------------------------------------------
-- Text stuff
--------------------------------------------------------------------------------

local nonLatinTrans = {}
--[[
fileList = scandir(path ..'/nonlatin')
for n,fileName in ipairs(fileList) do	
	if fileName:find('.lua$') then
		local lang = fileName:gsub('.lua', '')
		nonLatinTrans[lang] = openfile2(path ..'/nonlatin/'.. fileName)
	end
end
]]
local nonlatin = {ru=1}


function comma_value(amount, displayPlusMinus)
	local formatted

	-- amount is a string when ToSI is used before calling this function
	if type(amount) == "number" then
		if (amount ==0) then formatted = "0" else 
			if (amount < 2 and (amount * 100)%100 ~=0) then 
				if displayPlusMinus then formatted = string.format("%+.2f", amount)
				else formatted = string.format("%.2f", amount) end 
			elseif (amount < 20 and (amount * 10)%10 ~=0) then 
				if displayPlusMinus then formatted = string.format("%+.1f", amount)
				else formatted = string.format("%.1f", amount) end 
			else
				amount = math.floor(amount + 0.5)
				if displayPlusMinus then formatted = string.format("%+d", amount)
				else formatted = string.format("%d", amount) end 
			end 
		end
	else
		formatted = amount .. ""
	end

  	return formatted
end

local function writeTemplateLine(key, value, indents, dataType)
	if not key or not value then
		return ""
	end
	indents = indents or 0
	local str = "\n"
	for i=1,indents do
		str = str .. "\t"		
	end
	if exportAsJson then
		if dataType == "table" then
			str = str .. "\"" .. key .. "\" : {" .. value .. "\n},"
		elseif dataType == "list" then	
			str = str .. "\"" .. key .. "\" : [" .. value .. "\n],"
		elseif tonumber(str) ~= nil then
			str = str .. "\"" .. key .. "\" : " .. value .. ","
		else
			str = str .. "\"" .. key .. "\" : \"" .. value .. "\","
		end
	else
		str = str .. "| " .. key .. " = " .. value
	end
	return str
end

local function writeHeaderLine(text)
	if exportAsJson then
		return "\"" .. text .. "\":{"
	else
		return	"{{ " .. text
	end
end

local function writeClosingLine()
	return "\n\t" .. (exportAsJson and "}" or "}}")
end

--local morphDefs = openfile2(path .. '/morphdefs/morph_defs.lua')
local morphDefs = openfile2(path .. '/extradefs/morph_defs.lua') or {}

function buildPic(buildPicName)
	return faction_data.path ..'/unitpics/'.. string.lower(buildPicName)	
end

-- FIXME: read from JSON with i18n library
function getDescription(unitDef, forcelang)
	local lang_to_use = forcelang or lang

	if lang_to_use == 'en' then
		return unitDef.description or ''
	elseif nonLatinTrans[lang_to_use] then
		local unitTrans = nonLatinTrans[lang_to_use].units[unitDef.unitname]
		return unitTrans and unitTrans.description or ''
	else
		return unitDef.customparams and unitDef.customparams['description_' .. lang_to_use] or ''
	end
end	

function getHelpText(unitDef, forcelang)
	local lang_to_use = forcelang or lang	

	
	if nonLatinTrans[lang_to_use] then
		local unitTrans = nonLatinTrans[lang_to_use].units[unitDef.unitname]
		return unitTrans and unitTrans.helptext or ''
	end
	
	local suffix = (lang_to_use == 'en') and '' or ('_' .. lang_to_use)	
	return unitDef.customparams and unitDef.customparams['helptext' .. suffix] or ''
end

local hitscan = {
	BeamLaser = true,
	LightningCannon = true,
}

local function processWeapon(unitWeaponEntry, weaponName, bestDamage, bestDamageIndex, bestTypeDamage)
	local wd = weaponDefs
	if not wd then return {} end
	
	bestDamage = bestDamage or 0
	bestDamageIndex = bestDamageIndex or 0
	bestTypeDamage = bestTypeDamage or 0

	local wsTemp = {}
	wsTemp.slaveTo = unitWeaponEntry.slaveto --fixme - lowercase?
	if wsTemp.slaveTo then
		merw[wsTemp.slaveTo] = merw[wsTemp.slaveTo] or {}
		merw[wsTemp.slaveTo][#(merw[wsTemp.slaveTo])+1] = i
	end
	local wdEntry = wd[weaponName]
	local cp = wdEntry.customparams or {}
	
	--print("Processing weapon " .. wdEntry.name)
	
	wsTemp.wname 			= wdEntry.name or 'NoName Weapon'
	wsTemp.bestTypeDamage = 0
	wsTemp.bestTypeDamageW = 0
	wsTemp.range = cp.truerange or wdEntry.range
	wsTemp.paralyzer = wdEntry.paralyzer or ((wdEntry.paralyzetime or 0) > 0)
	wsTemp.show_projectile_speed = not cp.stats_hide_projectile_speed and not hitscan[wdEntry.weapontype]
	wsTemp.hitscan = hitscan[wdEntry.weapontype]
	wsTemp.shieldDamage = cp.damage_vs_shield
	
	if cp.setunitsonfire then
		local afterburn_frames = (cp.burntime or (450 * 0.01 * (wdEntry.firestarter or 0)))
		wsTemp.afterburn = afterburn_frames/30
	end
	
	if (wdEntry.sprayangle or 0 > 0) then
		wsTemp.inaccuracy = wdEntry.sprayangle * 90 / 0xafff
	end
	
	if wdEntry.tracks and wdEntry.turnrate > 0 then
		wsTemp.homing = wdEntry.turnrate * 180 / 32768
	end
	
	if (wdEntry.wobble or 0) > 0 then
		wsTemp.wobble = wdEntry.wobble * 180 / 32768
	end
	
	if (wdEntry.trajectoryheight or 0) > 0 then
		wsTemp.arcing = math.atan(wdEntry.trajectoryheight) * 180 / math.pi
	end
	
	if wdEntry.type == "BeamLaser" and wdEntry.beamtime > 0.2 then
		wsTemp.burstTime = wdEntry.beamtime	
	end
	
	if unitWeaponEntry.onlytargetcategory then
		wsTemp.aa_only = true
		local targetcats = SplitString(unitWeaponEntry.onlytargetcategory, " ")
		if #targetcats == 0 then
			wsTemp.aa_only = false
		end
		for i,cat in pairs(targetcats) do
			cat = string.lower(cat)
			if (cat ~= "fixedwing") and (cat ~= "gunship") and (cat ~= "satellite") then
				wsTemp.aa_only = false
				break;
			end
		end
		--if wsTemp.aa_only then print("AA only", wsTemp.wname, unitWeaponEntry.onlytargetcategory) end
	end
	
	for unitType, damage in pairs(wdEntry.damage) do
		damage = tonumber(damage)
		damage = math.max(damage, 0) --shadow has negative damage, breaks the below logic.
		
		if (wsTemp.bestTypeDamage <= (damage+0) and not wsTemp.paralyzer)
			or (wsTemp.bestTypeDamageW <= (damage+0) and wsTemp.paralyzer)
			then
	
			if wsTemp.paralyzer and not wdEntry.customparams.extra_damage then
				wsTemp.bestTypeDamageW = (damage+0)
			else
				wsTemp.bestTypeDamage = (damage+0)
			end
			
			if cp.statsdamage then
				wsTemp.bestTypeDamage = tonumber(cp.statsdamage)
			end
			
			wsTemp.burst = tonumber(wdEntry.customparams.script_burst) or wdEntry.burst or 1
			wsTemp.projectiles = wdEntry.projectiles or 1			
			wsTemp.dam = 0	-- physical damage
			wsTemp.damw = 0 -- EMP
			
			if wsTemp.paralyzer and not wdEntry.customparams.extra_damage then
				wsTemp.damw = wsTemp.bestTypeDamageW * wsTemp.burst * wsTemp.projectiles
				if wsTemp.projectiles > 1 or wsTemp.burst > 1 then
					wsTemp.damwBreakdown = wsTemp.bestTypeDamageW .. ' × ' .. (wsTemp.projectiles * wsTemp.burst)
				end
			else
				wsTemp.dam = wsTemp.bestTypeDamage * wsTemp.burst * wsTemp.projectiles
				if wsTemp.projectiles > 1 or wsTemp.burst > 1 then
					wsTemp.damBreakdown = wsTemp.bestTypeDamage .. ' × ' .. (wsTemp.projectiles * wsTemp.burst)
				end
			end
			
			if wdEntry.customparams.extra_damage then
				wsTemp.damw = wdEntry.customparams.extra_damage * wsTemp.burst * wsTemp.projectiles
				if wsTemp.projectiles > 1 or wsTemp.burst > 1 then
					wsTemp.damwBreakdown = wdEntry.customparams.extra_damage .. ' × ' .. (wsTemp.projectiles * wsTemp.burst)
				end
				wsTemp.bestTypeDamageW = wsTemp.damw
			end
			
			if cp.damage_vs_shield then	-- Wolverine
				wsTemp.dam = tonumber(cp.damage_vs_shield)
				wsTemp.bestTypeDamage = wsTemp.dam
			end
			
			wsTemp.dps 	= 0
			wsTemp.dpsw = 0
			
			if wsTemp.paralyzer then
				wsTemp.stuntime = wdEntry.paralyzetime
			end
			
			local tempDPS = 0
			local reload = tonumber(wdEntry.customparams.script_reload) or wdEntry.reloadtime
			if reload and reload > 0 then
				if wsTemp.paralyzer then
					tempDPS = math.floor(wsTemp.damw/reload + 0.5)
				else
					tempDPS = math.floor(wsTemp.dam/reload + 0.5)
				end
			end
			
			if cp.disarmdamagemult then
				wsTemp.dpsd = tempDPS * cp.disarmdamagemult
				wsTemp.bestTypeDamageD = wsTemp.bestTypeDamage * cp.disarmdamagemult
				if tobool(cp.disarmdamageonly) then
					wsTemp.dam = 0
					wsTemp.bestTypeDamage = 0
				end
				wsTemp.stuntime = tonumber(cp.disarmtimer)
			end
			
			if cp.timeslow_damagefactor then
				wsTemp.dpss = tempDPS * cp.timeslow_damagefactor
				wsTemp.bestTypeDamageS = wsTemp.bestTypeDamage * cp.timeslow_damagefactor
				if tobool(cp.timeslow_onlyslow) then
					wsTemp.dam = 0
					wsTemp.bestTypeDamage = 0
				end
			end
			
			if reload and reload > 0 then
				if wsTemp.paralyzer then
					wsTemp.dpsw = math.floor(wsTemp.damw/reload + 0.5)
					if cp.extra_damage then
						wsTemp.dps = math.floor(wsTemp.dam/reload + 0.5)
					end
				else
					wsTemp.dps = math.floor(wsTemp.dam/reload + 0.5)
				end
			end
			--print('test', unitDef.unitname, wsTemp.wname, bestDamage, bestDamageIndex)
			if wsTemp.dam > bestDamage then
				bestDamage = wsTemp.dam	
				bestDamageIndex = i
			end
			if wsTemp.damw > bestDamage then
				bestDamage = wsTemp.damw
				bestDamageIndex = i
			end
			
		end
	end
	
	for i,v in pairs(wdEntry) do
		wsTemp[i] = wsTemp[i] or v		
	end

	return wsTemp, bestDamage, bestDamageIndex, bestTypeDamage
end

local function writeCustomDataLine(key, value, count, indents)
	count = count + 1
	local str = ""
	if key then
		str = writeTemplateLine("customlabel"..count, key, indents) .. writeTemplateLine("customdata"..count, value, indents)
	else
		str = writeTemplateLine("special"..count, value, indents)
	end
	return str, count
end

local function printWeaponTemplate(ws, unitDef, mult)
	local str = "\t{{ Infobox zkweapon"
	if exportAsJson then
		str = "{"
	end
	
	local str2 = ''
	local mult = (mult > 1) and (" × " .. mult) or ""
	local numSpecial = 0
	local numCustom = 0
	local cp = ws.customparams
	local udcp = unitDef.customparams
	
	str = str .. writeTemplateLine("name", ws.wname .. mult, 1)
	str = str .. writeTemplateLine("type", ws.weapontype, 1)
	str = str .. writeTemplateLine("damage", ws.damBreakdown or comma_value(ws.bestTypeDamage), 1)
	if ws.reloadtime then
		str = str .. writeTemplateLine("reloadtime", comma_value(ws.customparams.script_reload or ws.reloadtime), 1)
	end
	if ws.dps > 0 then
		str = str .. writeTemplateLine("dps", comma_value(ws.dps), 1)
	end
	if ws.dpsd then	-- disarm
		str = str .. writeTemplateLine("disarmdamage", ws.damdBreakdown or comma_value(ws.bestTypeDamageD), 1)
		str = str .. writeTemplateLine("disarmdps", comma_value(ws.dpsd), 1)
	elseif ws.paralyzer or ((ws.stuntime or 0) > 0) then	-- EMP
		str = str .. writeTemplateLine("empdamage", ws.damwBreakdown or comma_value(ws.bestTypeDamageW), 1)
		str = str .. writeTemplateLine("empdps", comma_value(ws.dpsw), 1)
	end
	if ws.dpss then	-- slow
		str = str .. writeTemplateLine("slowdamage", ws.damdBreakdown or comma_value(ws.bestTypeDamageS), 1)
		str = str .. writeTemplateLine("slowdps", comma_value(ws.dpss), 1)
	end
	
	local lowerName = ws.wname:lower()
	if lowerName:find("flamethrower") or lowerName:find("flame thrower") then
		str = str .. writeTemplateLine("shielddamage", 300, 1)
	elseif lowerName:find("gauss") then
		str = str .. writeTemplateLine("shielddamage", 150, 1)
	end
	
	if ws.afterburn then
		str = str .. writeTemplateLine("afterburn", comma_value(ws.afterburn), 1)
	end
	if ws.stuntime then
		str = str .. writeTemplateLine("stuntime", comma_value(ws.stuntime), 1)
	end
	if ws.range then
		str = str .. writeTemplateLine("range", ws.range, 1)
	end
	if ws.areaofeffect and not ws.impactonly then
		str = str .. writeTemplateLine("aoe", comma_value(ws.areaofeffect/2), 1)
	end
	if cp.shield_drain then
		str2, numCustom = writeCustomDataLine("Shield drain (HP/shot)", cp.shield_drain, numCustom, 1)
		str = str .. str2
	end
	if ws.inaccuracy then
		str = str .. writeTemplateLine("inaccuracy", comma_value(ws.inaccuracy), 1)
	end
	if ws.homing then
		str = str .. writeTemplateLine("homing", comma_value(ws.homing), 1)
	end
	if ws.wobble then
		str = str .. writeTemplateLine("wobbly", comma_value(ws.wobble), 1)	
	end
	if ws.arcing then
		str = str .. writeTemplateLine("arcing", comma_value(ws.arcing), 1)		
	end
	if ws.firing_arc and (ws.firing_arc > -1) then
		str = str .. writeTemplateLine("firearc", comma_value(360*math.acos(ws.firing_arc)/math.pi), 1)
	end
	if ws.burstTime then
		str = str .. writeTemplateLine("bursttime", ws.burstTime, 1)	
	end
	if ws.commandfire then
		str = str .. writeTemplateLine("manualfire", "Yes", 1)	
	end
	if ws.aa_only then
		str = str .. writeTemplateLine("antiair", "Yes", 1)	
	end
	if cp.needs_link then
		str2, numCustom = writeCustomDataLine("Grid needed", cp.needs_link, numCustom, 1)
		str = str .. str2
	end
	
	if cp.spawns_name then
		local spawnDef = unitDefs[cp.spawns_name]
		str2, numCustom = writeCustomDataLine("Spawns Unit", "[["..spawnDef.name.."]]", numCustom, 1)
		str = str .. str2
		if tonumber(cp.spawns_expire) and tonumber(cp.spawns_expire) > 0 then
			str2, numCustom = writeCustomDataLine("Spawn Life (s)", cp.spawns_expire, numCustom, 1)
			str = str .. str2
		end
	end

	if cp.area_damage then
		local grav = tobool(cp.area_damage_is_impulse)
		local text = grav and "Gravity Well" or "Ground Burn"

		if not grav then
			str2, numCustom = writeCustomDataLine(text .. " DPS", cp.area_damage_dps, numCustom, 1)
			str = str .. str2
		end
		str2, numCustom = writeCustomDataLine(text .. " radius (elmo)", cp.area_damage_radius, numCustom, 1)
		str = str .. str2
		str2, numCustom = writeCustomDataLine(text .. " duration (s)", cp.area_damage_duration, numCustom, 1)
		str = str .. str2
	end

	if ws.stockpile then
		local time = (((tonumber(udcp.stockpiletime) or 0) > 0) and tonumber(udcp.stockpiletime) or ws.stockpiletime)
		str2, numCustom = writeCustomDataLine("Stockpile time (s)", time, numCustom, 1)
		str = str .. str2
		if ((not udcp.freestockpile) and ((tonumber(udcp.stockpilecost) or ws.metalcost or 0) > 0)) then
			local cost = udcp.stockpilecost or ws.metalcost .. " M"
			str2, numCustom = writeCustomDataLine("Stockpile cost (M)", cost, numCustom, 1)
			str = str .. str2
		end
	end
	
	if ws.show_projectile_speed and ws.weaponvelocity then
		str = str .. writeTemplateLine("projectilespeed", comma_value(ws.weaponvelocity), 1)
	elseif ws.hitscan then
		str2, numSpecial = writeCustomDataLine(nil, "Instantly hits", numSpecial, 1)
		str = str .. str2
	end
	if ws.interceptedbyshieldtype == 0 then
		str2, numSpecial = writeCustomDataLine(nil, "Ignores shields", numSpecial, 1)
		str = str .. str2
	end
	if cp.smoothradius then
		str2, numSpecial = writeCustomDataLine(nil, "Smooths ground", numSpecial, 1)
		str = str .. str2
	end
	
	local highTraj = ws.hightrajectory or unitDef.hightrajectory
	if highTraj == 1 then
		str2, numSpecial = writeCustomDataLine(nil, "High trajectory", numSpecial, 1)
		str = str .. str2
	elseif highTraj == 2 then
		str2, numSpecial = writeCustomDataLine(nil, "Trajectory toggle", numSpecial, 1)
		str = str .. str2
	end
	
	if ws.waterWeapon and (ws.type ~= "TorpedoLauncher") then
		str2, numSpecial = writeCustomDataLine(nil, "Water capable", numSpecial, 1)
		str = str .. str2
	end
	if (not ws.avoidfriendly) and ws.collidefriendly then
		str2, numSpecial = writeCustomDataLine(nil, "Potential friendly fire", numSpecial, 1)
		str = str .. str2
	elseif cp.nofriendlyfire then
		str2, numSpecial = writeCustomDataLine(nil, "No friendly fire", numSpecial, 1)
		str = str .. str2
	end
	if ws.collideground == false then
		str2, numSpecial = writeCustomDataLine(nil, "Passes through ground", numSpecial, 1)
		str = str .. str2
	end
	
	if ws.noexplode then
		str2, numSpecial = writeCustomDataLine(nil, "Piercing", numSpecial, 1)
		str = str .. str2
		if not cp.single_hit then
			str2, numSpecial = writeCustomDataLine(nil, "Damage increase vs large units", numSpecial, 1)
			str = str .. str2
		end
	end

	if cp.dyndamageexp then
		str2, numSpecial = writeCustomDataLine(nil, "Damage falls off with range", numSpecial, 1)
		str = str .. str2
	end

	-- does anything actually use this?
	--[[
	if cp.aim_delay then
		cells[#cells+1] = ' - Aiming time:'
		cells[#cells+1] = numformat(tonumber(cp.aim_delay)/1000) .. "s"
	end
	]]
	
	if (ws.targetmoveerror or 0) > 0 then
		str2, numSpecial = writeCustomDataLine(nil, "Inaccuracy vs moving targets", numSpecial, 1)
		str = str .. str2
	end
	if ws.targetable and ((ws.targetable == 1) or (ws.targetable == true)) then
		str2, numSpecial = writeCustomDataLine(nil, "Can be shot down by antinukes", numSpecial, 1)
		str = str .. str2
	end
	
	str = str .. writeClosingLine()
	
	return str
end

-- note shields are written separately
function printWeaponsTemplates(unitDef)
	local weaponStats = {}
	local bestDamage, bestDamageIndex, bestTypeDamage = 0,0,0	-- unused apparently

	local merw = {}

	local wd = weaponDefs
	if not wd then return '' end
	
	local str = ''

	for i, weaponDef in pairs(unitDef.weapons or {}) do 
		local weaponName = string.lower( unitDef.weapondefs and weaponDef.def or weaponDef.name ) --jw
		--weaponName = unitDef.unitname .. "_" .. weaponName
		if (wd[weaponName] and wd[weaponName].damage and wd[weaponName].weapontype:lower() ~= 'shield') then
			local wsTemp
			wsTemp, bestDamage, bestDamageIndex, bestTypeDamage = processWeapon(weaponDef, weaponName, bestDamage, bestDamageIndex, bestTypeDamage)	
			-- may be broken
			if not wsTemp.wname then
				print("BAD unit ", unitDef.unitname) return ''
			else
				weaponStats[i] = wsTemp
			end 
		end
	end
	--fixme, check for need of this var
	local weaponList = weaponStats
	local weaponCounts = {}	-- [weaponName] = count
	local weaponsPrinted = {}
	
	for index,ws in pairs(weaponList) do
		if not ws.slaveTo then
			weaponCounts[ws.wname] = (weaponCounts[ws.wname] or 0) + 1
		end
	end
	
	for index,ws in pairs(weaponList) do
		--print("Processing weapon " .. ws.wname)
		local mainweapon = merw and merw[index]
		if weaponsPrinted[ws.wname] then
			-- do nothing
		elseif not ws.slaveTo then
			--local dam = ws.finalDamage
		
			if mainweapon then
				for _,index2 in ipairs(mainweapon) do
					--print('test', unitDef.unitname, index, index2)
					wsm = weaponStats[index2]
					ws.damw = ws.damw + wsm.bestTypeDamageW
					ws.dpsw = ws.dpsw + wsm.dpsw
					ws.dam = ws.dam + wsm.bestTypeDamage
					ws.dps = ws.dps + wsm.dps
				end
			end
			
			if not (ws.wname:find('Fake') or ws.wname:find('fake') or ws.wname:find('Bogus')) then
				str = str .. "\n" .. printWeaponTemplate(ws, unitDef, weaponCounts[ws.wname])
				weaponsPrinted[ws.wname] = true
			end
		end
	end
	
	-- write death explosion if needed
	if unitDef.kamikaze or tobool(unitDef.customparams.stats_show_death_explosion) then
		local weaponName = unitDef.explodeas
		if wd[weaponName] then
			local ws = processWeapon({}, weaponName)	
			str = str .. "\n" .. printWeaponTemplate(ws, unitDef, 1)
		else
			--print("SOMETHING WRONG HERE", unitDef.name, weaponName)
		end
	end
	return str
	--[[
	{{ Infobox zkweapon
	
	<!-- leave blank for no, put anything for yes -->
	| wateronly =
	
	<!-- 1-9 available for each -->
	| customlabel1 =
	| customdata1 = 
	| special1 = 
	
	| specialheadercolour = 
	]]
end

local function GetShieldRegenDrain(wd)
	local shieldRegen = wd.shieldpowerregen
	if shieldRegen == 0 and wd.customparams and wd.customparams.shield_rate then
		shieldRegen = wd.customparams.shield_rate
	end
	
	local shieldDrain = wd.shieldpowerregenenergy
	if shieldDrain == 0 and wd.customparams and wd.customparams.shield_drain then
		shieldDrain = wd.customparams.shield_drain
	end
	return shieldRegen, shieldDrain
end

function printShields(unitDef)
	local wd = weaponDefs
	if not wd then return '' end
	if not unitDef.weapons then return '' end
		
	local str = ''
	local shieldStats = {}
	for i, weaponDef in pairs(unitDef.weapons) do 
		local shieldName = string.lower( unitDef.weapondefs and weaponDef.def or weaponDef.name ) --jw
		local shieldDef = wd[shieldName]
		--weaponName = unitDef.unitname .. "_" .. weaponName
		if (shieldDef and shieldDef.weapontype:lower() == 'shield') then
			local ssTemp = {}
			ssTemp.name = shieldDef.name
			ssTemp.shield = true
			ssTemp.shieldpower = shieldDef.shieldpower
			ssTemp.shieldpowerregen, ssTemp.shieldregenenergy = GetShieldRegenDrain(shieldDef)
			ssTemp.shieldradius = shieldDef.shieldradius
			
			-- may be broken
			if not ssTemp.name then
				print("BAD unit ", unitDef.unitname) return ''
			else
				shieldStats[i] = ssTemp
			end
			for i,v in pairs(shieldDef) do
				ssTemp[i] = ssTemp[i] or v		
			end
		end
	end
	
	for index,ss in pairs(shieldStats) do
		if not (ss.name:find('Fake') or ss.name:find('fake') ) then
			str = str .. "\n\t" .. writeHeaderLine("Infobox zkability shield")
				.. writeTemplateLine("name", ss.name, 1)
				.. writeTemplateLine("strength", ss.shieldpower, 1)
				.. writeTemplateLine("regen", ss.shieldpowerregen, 1)
				.. writeTemplateLine("regencost", ss.shieldregenenergy, 1)
				.. writeTemplateLine("radius", ss.shieldradius, 1)
				.. writeClosingLine()
		end
	end
	return str
end

local function getCost(unitDef)
	return unitDef.buildcostmetal and (unitDef.buildcostmetal > 0) and unitDef.buildcostmetal or unitDef.buildtime or unitDef.buildcostenergy or -1
end

function printUnitStatsTemplate(unitDef)
	local cp = unitDef.customparams
	local isBuilding = not unitDef.maxvelocity or tonumber(unitDef.maxvelocity) < 0.1
	
	local str = exportAsJson and "{" or "{{ Infobox zkunit"
	str = str .. writeTemplateLine("name", unitDef.name)
	str = str .. writeTemplateLine("defname", unitDef.unitname)
	str = str .. writeTemplateLine("description", getDescription(unitDef, lang))
	str = str .. writeTemplateLine("image", buildPic(unitDef.buildpic or unitDef.unitname .. '.png'))
	str = str .. writeTemplateLine("icontype", unitDef.icontype)
	str = str .. writeTemplateLine("cost", getCost(unitDef))
	str = str .. writeTemplateLine("hitpoints", unitDef.maxdamage)
	
	if not isBuilding then
		-- screw mass
		--[[
		local mass = unitDef.mass
		if mass and (mass < 999999) then
			print("Unit " .. unitDef.name .. " has mass " .. mass)
			str = str .. writeTemplateLine("mass", comma_value(mass))
		end
		]]
		str = str .. writeTemplateLine("movespeed", comma_value(unitDef.maxvelocity * 30))
		if unitDef.turnrate then
			str = str .. writeTemplateLine("turnrate", comma_value(unitDef.turnrate * 30 * 360 / 65536))
		end
	end
	
	local energy = (unitDef.customparams.income_energy or 0)
	if (unitDef.customparams.upkeep_energy or 0) > 0 then
		energy = energy - unitDef.customparams.upkeep_energy
	end
	if energy ~= 0 then
		str = str .. writeTemplateLine("energy", energy)
	end
	str = str .. writeTemplateLine("sight", unitDef.sightdistance)
	if unitDef.sonardistance then
		str = str .. writeTemplateLine("sonar", unitDef.sonardistance)
	end
	if not (unitDef.canfly or unitDef.cantbetransported or isBuilding) then
		str = str .. writeTemplateLine("transportable", ((((unitDef.mass > 350) or ((unitDef.xsize or 0) > 4) or ((unitDef.zsize or 0) > 4)) and "Heavy") or "Light"))
	end
	if cp.pylonrange then
		str = str .. writeTemplateLine("gridlink", cp.pylonrange)
	end
	
	if (unitDef.weapons or unitDef.kamikaze) then
		local weapons = printWeaponsTemplates(unitDef)
		if weapons ~= '' then
			str = str .. writeTemplateLine("weapons", weapons, nil, "list")
		end
	end
	
	-- write abilities
	local abilities = ""
	
	-- drones
	local droneData = droneCarriers[unitDef.id]	
	if droneData then
		for i=1,#droneData do
			local droneEntry = droneData[i]
			abilities = abilities .. "\n\t" .. writeHeaderLine("Infobox zkability drone")
			.. writeTemplateLine("drone", "[[" .. UnitDefsByFakeID[droneEntry.drone].name .. "]]", 1)
			.. writeTemplateLine("maxdrones", droneEntry.maxDrones, 1)
			.. writeTemplateLine("range", droneEntry.range, 1)
			.. writeTemplateLine("interval", droneEntry.reloadTime, 1)
			.. writeTemplateLine("spawnsize", droneEntry.spawnSize, 1)
			.. writeTemplateLine("buildtime", droneEntry.buildTime, 1)
			.. writeTemplateLine("maxbuilding", droneEntry.maxBuild, 1)
			abilities = abilities .. writeClosingLine()
		end
	end
	
	-- builder
	if (unitDef.workertime or 0) > 0 then
		abilities = abilities .. "\n\t" .. writeHeaderLine("Infobox zkability construction")
			.. writeTemplateLine("buildpower", unitDef.workertime, 1)
			.. writeClosingLine()
	end
	-- cloak
	if unitDef.cloakcost or cp.idle_cloak then
		abilities = abilities .. "\n\t" .. writeHeaderLine("Infobox zkability cloak")
		if (unitDef.cloakcost or 0) > 0 then
			abilities = abilities ..  writeTemplateLine("upkeepidle", unitDef.cloakcost, 1)
				.. writeTemplateLine("upkeepmobile", unitDef.cloakcostmoving, 1)
		elseif cp.idle_cloak then
			abilities = abilities ..  writeTemplateLine("customdata1", "Only when idle", 1)
				.. writeTemplateLine("customdata2", "Free and automated", 1)
		end
		abilities = abilities .. writeTemplateLine("decloakradius", unitDef.mincloakdistance, 1)
		if unitDef.decloakOnFire == false then
			abilities = abilities .. writeTemplateLine("customdata1", "No decloak while shooting", 1)	
		end
		abilities = abilities .. writeClosingLine()
	end
	-- shield
	local shields = printShields(unitDef)
	if shield ~= '' then
		abilities = abilities .. shields	
	end
	
	-- radar/jammer
	if unitDef.radardistance or unitDef.radardistancejam or unitDef.customparams.area_cloak_upkeep then
		abilities = abilities .. "\n\t" .. writeHeaderLine("Infobox zkability intel")
		if unitDef.radardistance then
			abilities = abilities .. writeTemplateLine("radar", unitDef.radardistance, 1)	
		end
		if unitDef.radardistancejam then
			abilities = abilities .. writeTemplateLine("jam", unitDef.radardistancejam, 1)	
		end
		if unitDef.customparams.area_cloak_upkeep then
			abilities = abilities .. writeTemplateLine("energycost", unitDef.customparams.area_cloak_upkeep, 1)	
		end
		abilities = abilities .. writeClosingLine()
	end
	-- jump
	if tobool(cp.canjump) then
		abilities = abilities .. "\n\t" .. writeHeaderLine("Infobox zkability jump")
			.. writeTemplateLine("range", cp.jump_range, 1)
			.. writeTemplateLine("reload", cp.jump_reload, 1)
			.. writeTemplateLine("speed", cp.jump_speed, 1)
			.. writeTemplateLine("midairjump", tobool(cp.jump_from_midair) and "Yes" or "No", 1)
		abilities = abilities .. writeClosingLine()
	end
	-- regen
	if (unitDef.idletime < 1800) or (cp.amph_regen) or (cp.armored_regen) then
		abilities = abilities .. "\n\t" .. writeHeaderLine("Infobox zkability regen")
		if unitDef.idletime < 1800 then
			if unitDef.idletime > 0 then
				abilities = abilities .. writeTemplateLine("idleregen", cp.idle_regen, 1)
				abilities = abilities .. writeTemplateLine("timetoenable", unitDef.idletime / 30, 1)
			else
				abilities = abilities .. writeTemplateLine("combatregen", cp.idle_regen, 1)
			end
		end
		if cp.amph_regen then
			abilities = abilities .. writeTemplateLine("waterregen", cp.amph_regen, 1)
			abilities = abilities .. writeTemplateLine("atdepth", cp.amph_submerged_at, 1)
		end
		if cp.armored_regen then
			abilities = abilities .. writeTemplateLine("customlabel1", "Closed regen (HP/s)", 1)
			abilities = abilities .. writeTemplateLine("customdata1", cp.armored_regen, 1)
		end
		abilities = abilities .. writeClosingLine()
	end
	-- morph
	if cp.morphto then
		local to = unitDefs[cp.morphto]
		local cost = to.buildtime - unitDef.buildtime
		if cost < 0 then cost = 0 end
		abilities = abilities .. "\n\t" .. writeHeaderLine("Infobox zkability morph")
			.. writeTemplateLine("to", "[[" .. to.name .. "]]", 1)
			.. writeTemplateLine("cost", cost, 1)
			.. writeTemplateLine("time", cp.morphtime, 1)
			.. writeTemplateLine("disabled", tobool(cp.combatmorph) and "No" or "Yes", 1)
		abilities = abilities .. writeClosingLine()
	end
	-- armored
	if (unitDef.damagemodifier or 1) < 1 then
		abilities = abilities .. "\n\t" .. writeHeaderLine("Infobox zkability armored")
			.. writeTemplateLine("reduction", comma_value((1-unitDef.damagemodifier)*100) .. '%', 1)
		if cp.force_close then
			abilities = abilities .. writeTemplateLine("special1", "Forced for " .. cp.force_close .. "s on damage" , 1)
		end
		abilities = abilities .. writeClosingLine()
	end
	
	-- custom abilities
	local miscAble = ""
	do
		local num = 1
		if cp.ismex then
			miscAble = miscAble .. writeTemplateLine("customdata".. num, "Extracts metal", 1)
			num = num + 1
		end
		if unitDef.stealth then
			miscAble = miscAble .. writeTemplateLine("customdata".. num, "Invisible to radar", 1)
			num = num + 1
		end
		if tobool(cp.fireproof) then
			miscAble = miscAble .. writeTemplateLine("customdata".. num, "Immunity to afterburn", 1)
			num = num + 1
		end
		if tobool(cp.dontfireatradarcommand) then
			miscAble = miscAble .. writeTemplateLine("customdata".. num, "Can ignore unidentified targets", 1)
			num = num + 1
		end
		if (unitDef.selfdestructcountdown or 5) <= 1 then
			miscAble = miscAble .. writeTemplateLine("customdata".. num, "Instant self-destruction", 1)
			num = num + 1
		end
		-- doesn't work and I cba to parse the yardmap
		--if unitDef.needgeo then
		--	miscAble = miscAble .. writeTemplateLine("customdata".. num, "Requires thermal vent to build", 1)
		--	num = num + 1
		--end
		
	end
	if miscAble ~= '' then
		abilities = abilities .. "\n\t" .. writeHeaderLine("Infobox zkability line") .. miscAble .. writeClosingLine()
	end
	
	if abilities ~= "" then
		str = str .. writeTemplateLine("abilities", abilities, nil, "table")
	end
		
	str = str .. (exportAsJson and "\n}" or "\n}}")
	
	return str
end

function printUnit(unitname, parentFac)
	if printedunitlistkeys[unitname] then
		return	
	end
	if faction_data.ignore[unitname] then
		return
	end
	--print('Printing unit:', unitname)
	
	local unitDef = unitDefs[unitname]
	
	if not unitDef then return false; end
	
	if not unitDef.unitname then 
		--return false; 
		print("ERROR", unitname, unitDef.unitname, unitDef.name)
		--print( to_string(unitDef) )
		--return false;
	end
	
	local isBuilding = not unitDef.maxvelocity or tonumber(unitDef.maxvelocity) < 0.1
	local isFac = isBuilding and #(unitDef.buildoptions or {}) > 0
	
	local str = ''
	-- write intro text
	if not (exportAsJson or infoboxOnly) then
		local desc = ''
		if isFac then
			desc = "factory that " .. SplitString(string.lower(getDescription(unitDef, lang)), ",")[1]
		else
			desc = string.lower(getDescription(unitDef, lang))
			desc = string.gsub(desc, " %- ", " that ")
			desc = string.gsub(desc, ", builds at %d.-%d- m/s", "")
		end
		local article = getArticle(desc)
		str = str .. "The '''{{PAGENAME}}''' is " .. article .. " " .. desc
		if unitname:find("chicken") then
			str = str .. " [[Chicken Defense|chicken]]"
		end
		if parentFac then
			local factoryDef = unitDefs[parentFac]
			if factoryDef then
				str = str .. " from the [[" .. factoryDef.name .. "]]."
			end
		else
			str = str .. "."	
		end
	end
	-- write template
	str = str .. printUnitStatsTemplate(unitDef, isJson)
	
	if not (exportAsJson or infoboxOnly) then
		-- write description
		str = str .. "==Description==" .. "\n" .. getHelpText(unitDef, lang)
		if isFac then
			str = str .. "\n\nThe " .. unitDef.name .. " builds:"
			for _,unitname in pairs(unitDef.buildoptions) do
				if not (unitname:find("dynhub")) then
					str = str .. "\n* [[" .. unitDefs[unitname].name .. "]]"
				end
			end
		end
		
		-- write navbox
		if isBuilding then str = str .. "\n\n{{Navbox buildings}}"
		else str = str .. "\n\n{{Navbox units}}"
		end
	end
	
	local name = string.gsub(unitDef.name, "/", "&#47;")
	local ext = exportAsJson and ".json" or ".txt"
	local file = io.open(output .. "/" .. name .. ext, 'w')
	file:write(str)
	io.close(file)
	printedunitlistkeys[unitname] = true
end


function printFac(facname, printMobileOnly)
	curFacDef = unitDefs[facname]
	printUnit(facname)

	if facname ~= "armcsa" then
		for _,unitname in pairs(curFacDef.buildoptions) do
			printUnit(unitname, facname)
		end
	end
end


function printFaction(intname, image)
	local faclist = faction_data.facs[intname]
	local dlist = faction_data.staticw[intname]
	local name = faction_data.faction_names[intname]
	local description = faction_data.faction_descriptions[intname]
	local somecon = faction_data.cons[intname]
	local printMobileOnly = faction_data.printMobileOnly
	local useBuildOptionFile = faction_data.useBuildOptionFile
	
	for _, fac in pairs(faclist) do
		printFac(fac, printMobileOnly[fac])
	end

	local buildopts = {}
	if useBuildOptionFile then
		buildopts = openfile2(path ..'/gamedata/buildoptions.lua')
	elseif somecon then
		local unitDef = unitDefs[somecon]
		if not unitDef then return false; end
		buildopts = unitDef.buildoptions or {}
	end
	local weaponStructs = {}
	local regularStructs = {}
		
	for _,unitname in pairs(buildopts) do
		if not printedunitlistkeys[unitname] then
			if unitDefs[unitname].weapons and #(unitDefs[unitname].weapons) > 0 then
				weaponStructs[#weaponStructs+1] = unitname
			else
				regularStructs[#regularStructs+1] = unitname
			end
		end
	end
	
	for _,unitname in pairs(weaponStructs) do	
		printUnit(unitname)
	end
	
	for _,unitname in pairs(regularStructs) do	
		printUnit(unitname)
	end
		
	for _,unitname in pairs(faction_data.extra_units) do	
		printUnit(unitname)
	end
end


--[[
if false and lang ~= 'all' then
	local roles_file = '/home/ca/bin/manual/roles.txt'
	if lang ~= 'en' then
		roles_file = '/home/ca/bin/manual/roles_'.. lang ..'.txt'
	end
	--[=[
	for line in io.lines(roles_file) do 
		writeml(line)
	end
	--]=]
	fhroles = io.open(roles_file, "rb")
	writeml(fhroles:read("*all"))
	fhroles:close()
end
--]]

for faction, con in pairs(faction_data.cons) do
	printFaction( faction, '', cons )
end
