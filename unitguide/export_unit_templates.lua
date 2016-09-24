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

path = arg[1]
output = arg[2]
lang = arg[3]

local nl = "\n"
local nlnl = "\n\n"
local br = "<br />"
local brbr = "<br /><br />"

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
-- synonyms
UnitDefs = unitDefs
WeaponDefs = weaponDefs
DEFS = {
	unitDefs = unitDefs
}

-- dummy
commDefs = {}

dofile(path .. "/gamedata/unitdefs_post.lua")
dofile(path .. "/gamedata/weapondefs_post.lua")

--------------------------------------------------------------------------------
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

local function writeTemplateLine(key, value, indents)
	if not key or not value then
		return ""
	end
	indents = indents or 0
	local str = "\n"
	for i=1,indents do
		str = str .. "\t"		
	end
	str = str .. "| " .. key .. " = " .. value
	return str

end

--local morphDefs = openfile2(path .. '/morphdefs/morph_defs.lua')
local morphDefs = openfile2(path .. '/extradefs/morph_defs.lua') or {}

function buildPic(buildPicName)
	return faction_data.path ..'/unitpics/'.. string.lower(buildPicName)	
end

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
	AircraftBomb = true,	-- HAX
}

function printWeaponsTemplates(unitDef)
	local weaponStats = {}
	local bestDamage, bestDamageIndex, bestTypeDamage = 0,0,0

	local merw = {}

	local wd = weaponDefs
	if not wd then return '' end
	
	local str = ''

	for i, weaponDef in pairs(unitDef.weapons) do 
		
		local weaponName = string.lower( unitDef.weapondefs and weaponDef.def or weaponDef.name ) --jw
		--weaponName = unitDef.unitname .. "_" .. weaponName
		if (wd[weaponName] and wd[weaponName].damage and wd[weaponName].weapontype:lower() ~= 'shield') then
		
			local wsTemp = {}
			wsTemp.slaveTo = weaponDef.slaveto --fixme - lowercase?
			if wsTemp.slaveTo then
				merw[wsTemp.slaveTo] = merw[wsTemp.slaveTo] or {}
				merw[wsTemp.slaveTo][#(merw[wsTemp.slaveTo])+1] = i
			end
			local wdEntry = wd[weaponName]
			local cp = wdEntry.customparams or {}
			
			wsTemp.wname 			= wdEntry.name or 'NoName Weapon'
			wsTemp.bestTypeDamage = 0
			wsTemp.bestTypeDamagew = 0
			wsTemp.range = cp.truerange or wdEntry.range
			wsTemp.paralyzer = wdEntry.paralyzer
			wsTemp.show_projectile_speed = not cp.stats_hide_projectile_speed and not hitscan[wdEntry.weapontype]
			wsTemp.shieldDamage = cp.damage_vs_shield
			
			if cp.setunitsonfire then
				local afterburn_frames = (cp.burntime or (450 * (wdEntry.fireStarter or 0)))
				wsTemp.afterburn = afterburn_frames/30
			end
			
			if (wdEntry.sprayangle or 0 > 0) then
				wsTemp.inaccuracy = wdEntry.sprayangle * 90 / 0xafff
			end
			
			if wdEntry.tracks and wdEntry.turnrate > 0 then
				wsTemp.homing = wdEntry.turnrate * 30 * 180 / 32768
			end
			
			if (wdEntry.wobble or 0) > 0 then
				wsTemp.wobble = wdEntry.wobble * 30 * 180 / 32768
			end
			
			if (wdEntry.trajectoryheight or 0) > 0 then
				wsTemp.arcing = math.atan(wdEntry.trajectoryheight) * 180 / math.pi
			end
			
			if wdEntry.type == "BeamLaser" and wdEntry.beamtime > 0.2 then
				wsTemp.burstTime = wdEntry.beamtime	
			end
			
			for unitType, damage in pairs(wdEntry.damage) do
				
				damage = math.max(damage, 0) --shadow has negative damage, breaks the below logic.
				
				if (wsTemp.bestTypeDamage <= (damage+0) and not wsTemp.paralyzer)
					or (wsTemp.bestTypeDamagew <= (damage+0) and wsTemp.paralyzer)
					then

					if wsTemp.paralyzer then
						wsTemp.bestTypeDamagew = (damage+0)
					else
						wsTemp.bestTypeDamage = (damage+0)
					end
					
					wsTemp.burst = wdEntry.burst or 1
					wsTemp.projectiles = wdEntry.projectiles or 1
					wsTemp.dam = 0
					wsTemp.damw = 0
					
					if wsTemp.paralyzer then
						wsTemp.damw = wsTemp.bestTypeDamagew * wsTemp.burst * wsTemp.projectiles
					else
						wsTemp.dam = wsTemp.bestTypeDamage * wsTemp.burst * wsTemp.projectiles
						if wsTemp.projectiles > 1 or wsTemp.burst > 1 then
							wsTemp.damBreakdown = wsTemp.bestTypeDamage .. ' × ' .. (wsTemp.projectiles * wsTemp.burst)
						end
					end
					
					-- [[
					if wdEntry.customparams and wdEntry.customparams.extra_damage then
						wsTemp.dam = wdEntry.customparams.extra_damage * wsTemp.burst * wsTemp.projectiles
						if wsTemp.projectiles > 1 or wsTemp.burst > 1 then
							wsTemp.damBreakdown = wdEntry.customparams.extra_damage .. ' × ' .. (wsTemp.projectiles * wsTemp.burst)
						end
					end
					--]]
					
					wsTemp.dps 				= 0
					wsTemp.dpsw 				= 0
					
					if wsTemp.paralyzer then
						wsTemp.stuntime = wdEntry.paralyzetime
					end
					
					local tempDPS = 0	
					if wsTemp.reloadtime and wsTemp.reloadtime > 0 then
						tempDPS = math.floor(wsTemp.dam/wdEntry.reloadtime + 0.5)
					end
					
					if cp.disarmdamagemult then
						wsTemp.dpsd = tempDPS * cp.disarmdamagemult
						if (cp.disarmdamageonly == "1") then
							wsTemp.dam = 0
						end
						wsTemp.stuntime = tonumber(cp.disarmtimer)
					end
					
					if cp.timeslow_damagefactor then
						wsTemp.dpss = tempDPS * cp.timeslow_damagefactor
						if (cp.timeslow_onlyslow == "1") then
							wsTemp.dam = 0
						end
					end
					
					if wdEntry.reloadtime and wdEntry.reloadtime > 0 then
						if wsTemp.paralyzer then
							wsTemp.dpsw = math.floor(wsTemp.damw/wdEntry.reloadtime + 0.5)
							if cp.extra_damage then
								wsTemp.dps = math.floor(wsTemp.dam/wdEntry.reloadtime + 0.5)
							end
						else
							wsTemp.dps = math.floor(wsTemp.dam/wdEntry.reloadtime + 0.5)
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
					ws.damw = ws.damw + wsm.bestTypeDamagew
					ws.dpsw = ws.dpsw + wsm.dpsw
					ws.dam = ws.dam + wsm.bestTypeDamage
					ws.dps = ws.dps + wsm.dps
				end
			end
			
			if not (ws.wname:find('Fake') or ws.wname:find('fake') ) then
				str = str .. "\t{{ Infobox zkweapon"
				local mult = (weaponCounts[ws.wname] > 1) and (" × " .. weaponCounts[ws.wname]) or ""
				str = str .. writeTemplateLine("name", ws.wname .. mult, 1)
				str = str .. writeTemplateLine("damage", ws.damBreakdown or ws.bestTypeDamage, 1)
				if ws.reloadtime then
					str = str .. writeTemplateLine("reloadtime", ws.reloadtime, 1)
				end
				str = str .. writeTemplateLine("dps", ws.dps, 1)
				if ws.paralyzer then
					str = str .. writeTemplateLine("empdps", ws.dpsw, 1)
				end
				if ws.dpss then
					str = str .. writeTemplateLine("slowdps", ws.dpss, 1)
				end
				if ws.dpsd then
					str = str .. writeTemplateLine("disarmdps", ws.dpsd, 1)
				end
				if ws.shieldDamage then
					str = str .. writeTemplateLine("shielddamage", ws.shieldDamage, 1)
				end
				if ws.afterburn then
					str = str .. writeTemplateLine("afterburn", ws.afterburn, 1)
				end
				if ws.stuntime then
					str = str .. writeTemplateLine("stuntime", ws.stuntime, 1)
				end
				if ws.range then
					str = str .. writeTemplateLine("range", ws.range, 1)
				end
				if ws.areaofeffect then
					str = str .. writeTemplateLine("aoe", ws.areaofeffect/2, 1)
				end
				if ws.show_projectile_speed then
					str = str .. writeTemplateLine("projectilespeed", ws.weaponvelocity, 1)
				end
				if ws.inaccuracy then
					str = str .. writeTemplateLine("inaccuracy", math.floor(ws.inaccuracy), 1)
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
				if ws.manualFire then
					str = str .. writeTemplateLine("manualfire", true, 1)	
				end
				if ws.aa_only then
					str = str .. writeTemplateLine("antiair", true, 1)	
				end
				str = str .. "\n\t}}"
				weaponsPrinted[ws.wname] = true
			end
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

local function getCost(unitDef)
	return unitDef.buildcostmetal and (unitDef.buildcostmetal > 0) and unitDef.buildcostmetal or unitDef.buildtime or unitDef.buildcostenergy or -1
end

function printUnitStatsTemplate(unitDef)
	local str = "{{ Infobox zkunit"
	str = str .. writeTemplateLine("name", unitDef.name)
	str = str .. writeTemplateLine("description", getDescription(unitDef, lang))
	str = str .. writeTemplateLine("image", buildPic(unitDef.buildpic or unitDef.unitname .. '.png'))
	str = str .. writeTemplateLine("cost", getCost(unitDef))
	str = str .. writeTemplateLine("hitpoints", unitDef.maxdamage)
	if unitDef.mass then
		str = str .. writeTemplateLine("mass", comma_value(unitDef.mass))
	end
	if unitDef.maxvelocity and (unitDef.maxvelocity+0) > 0 then
		str = str .. writeTemplateLine("movespeed", unitDef.maxvelocity * 30)
	end
	if unitDef.turnrate then
		str = str .. writeTemplateLine("turnrate", comma_value(unitDef.turnrate * 30 * 360 / 65536))
	end
	
	local energy = (unitDef.energymake or 0) + ((unitDef.energyuse or 0) < 0 and -unitDef.energyuse or 0)
	if energy > 0 then
		str = str .. writeTemplateLine("energy", energy)
	end
	str = str .. writeTemplateLine("sight", unitDef.sightdistance)
	if unitDef.sonardistance then
		str = str .. writeTemplateLine("sonar", unitDef.sonardistance)
	end
	if not (unitDef.canfly or unitDef.cantbetransported) then
		str = str .. writeTemplateLine("transportable", ((((unitDef.mass > 350) or ((unitDef.xsize or 0) > 4) or ((unitDef.zsize or 0) > 4)) and "Heavy") or "Light"))
	end
	if unitDef.customparams.pylonrange then
		str = str .. writeTemplateLine("gridlink", unitDef.customparams.pylonrange)
	end
	
	if (unitDef.weapons) then
		str = str .. writeTemplateLine("weapons", printWeaponsTemplates(unitDef))
	end
	
	local abilities = ""
	if (unitDef.workertime or 0) > 0 then
		abilities = abilities .. "\n\t" .. "{{ Infobox zkability construction"
			.. writeTemplateLine("buildpower", unitDef.workerTime, 1)
			.. "\n\t}}"
	end
	if unitDef.cloakcost then
		abilities = abilities .. "\n\t" .. "{{ Infobox zkability cloak"
			.. writeTemplateLine("upkeepidle", unitDef.cloakcost, 1)
			.. writeTemplateLine("upkeepmobile", unitDef.cloakcostmoving, 1)
			.. writeTemplateLine("decloakradius", unitDef.mincloakdistance, 1)
		if unitDef.decloakOnFire == false then
			abilities = abilities .. writeTemplateLine("customdata1", "No decloak while shooting", 1)	
		end
		abilities = abilities .. "\n\t}}"	
	end
	if unitDef.radardistance or unitDef.radardistancejam or unitDef.customparams.area_cloak_upkeep then
		abilities = abilities .. "\n\t" .. "{{ Infobox zkability intel"
		if unitDef.radardistance then
			abilities = abilities .. writeTemplateLine("radar", unitDef.radardistance, 1)	
		end
		if unitDef.radardistancejam then
			abilities = abilities .. writeTemplateLine("radar", unitDef.radardistancejam, 1)	
		end
		if unitDef.customparams.area_cloak_upkeep then
			abilities = abilities .. writeTemplateLine("energycost", unitDef.customparams.area_cloak_upkeep, 1)	
		end
		abilities = abilities .. "\n\t}}"
	end
	
	if abilities ~= "" then
		str = str .. writeTemplateLine("abilities", abilities)
	end
	
	
		
	--[[
{{ Infobox zkability intel
| radar =
| jam =
| energycost =
	]]
		
	str = str .. "\n}}"
	
	return str
end

local function printDeathStats(unitDef)
	if not unitDef.explodeas then
		return ''
	end
	local weaponName = string.lower( unitDef.explodeas )
	local weapon = weaponDefs[weaponName] or unitDef.weapondefs and unitDef.weapondefs[weaponName]
	if not weapon then
		return ''
	end
	
	
	local damage = weapon.damage and weapon.damage.default or -1
	local paraTime = weapon.paralyzetime and tableRow('Stun Time', weapon.paralyzetime, 'class="statsfield"') or ''

	local disp = unitDef.kamikaze and 'inline-block' or 'none'
	local tableId = 'explosion-'..unitDef.name:gsub('[^%a]', '_')
	local cells = [[
			<table cellspacing="0" border="1" cellpadding="2"
				class="statstable" style="display:]]..disp..[[;
				vertical-align:top;" id="]]..tableId..[["
			>
		]] 
		.. tableHeader('<img src="http://zero-k.info/img/luaui/dgun.png" width="16" alt="Explosion" title="Explosion" /> ' .. weapon.name ) 
		.. tableRow('Damage', comma_value(damage), 'class="statsfield"')
		
		.. tableRow('Area of Effect', comma_value(weapon.areaofeffect), 'class="statsfield"' )
		.. paraTime
		.. '</table>'
	
	local deathStats = cells
	if not unitDef.kamikaze then
		local js = [[
			<a href="#" onclick="$('#]]..tableId..[[').css( 'display', 'inline-block'); $(this).hide(); return false;">
				<img src="http://zero-k.info/img/luaui/dgun.png" width="16" alt="Explosion" title="Explosion" />
			</a>
		]]
		deathStats = js..deathStats
	end
	return deathStats
end

function printUnit(unitname, parentFac)
	if printedunitlistkeys[unitname] then
		return	
	end
	print('Printing unit:', unitname)
	
	local unitDef = unitDefs[unitname]
	
	if not unitDef then return false; end
	
	
	if not unitDef.unitname then 
		--return false; 
		print("ERROR", unitname, unitDef.unitname, unitDef.name)
		--print( to_string(unitDef) )
		--return false;
	end
	
	-- write template
	local str = printUnitStatsTemplate(unitDef)
	
	-- write intro text
	str = str .. "The '''{{PAGENAME}}''' is a " .. string.lower(getDescription(unitDef, lang))
	if parentFac then
		local factoryDef = unitDefs[parentFac]
		if factoryDef then
			str = str .. " built from the [[" .. factoryDef.name .. "]]." 
		end
	else
		str = str .. "."	
	end
	
	-- write description
	str = str .. "\n\n==Description==" .. "\n" .. getHelpText(unitDef, lang)
	
	-- write infobox
	str = str .. "\n\n{{Navbox units}}"
	

	--[[
	writeml('<span class="helptext"> '.. getHelpText(unitDef) .. '</span>' .. nlnl .. brbr)
	
	local morphs = morphDefs[unitDef.unitname]
	if morphs then
		local morphstr = '<span class="morphs"> Morphs to: '
		if morphs.into then
			local unitDef = unitDefs[morphs.into]
			local cost = ' (' .. (morphs.rank and morphs.rank ~= 0 and (morphs.rank .. ' Rank, ') or '') .. (morphs.time or '0') .. 's)'
			morphstr = morphstr .. '<a href="#unit-' .. unitDef.name .. '">' .. unitDef.name .. '</a>' .. cost .. ', '
		else
			for k,v in ipairs(morphs) do
				local unitDef = unitDefs[v.into]
				local cost = ' (' .. (v.rank and v.rank ~= 0 and (v.rank .. ' Rank, ') or '') .. (v.time or '0') .. 's)'
				morphstr = morphstr .. '<a href="#unit-' .. unitDef.name .. '">' .. unitDef.name .. '</a>' ..  cost .. ', '
			end
		end
		morphstr = morphstr:sub(1,-3) -- remove final ", "
		morphstr = morphstr .. '</span>'
		writeml(morphstr .. nlnl)
	end
	--]]
	local name = string.gsub(unitDef.name, "/", "&#47;")
	local file = io.open(output .. "/" .. name .. ".txt", 'w')
	file:write(str)
	io.close(file)
	printedunitlistkeys[unitname] = true
end


function printFac(facname, printMobileOnly)
	curFacDef = unitDefs[facname]
	printUnit(facname)

	for _,unitname in pairs(curFacDef.buildoptions) do
		printUnit(unitname, facname)
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
