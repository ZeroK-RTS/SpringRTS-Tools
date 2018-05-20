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

Spring = { 
	GetModOptions = function() end,
	GetPlayerList = function() return {}; end,
	GetModOptions = function() return 'asdf' end
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


local nonLatinTrans = {}
fileList = scandir(path ..'/nonlatin')
for n,fileName in ipairs(fileList) do	
	if fileName:find('.lua$') then
		local lang = fileName:gsub('.lua', '')
		nonLatinTrans[lang] = openfile2(path ..'/nonlatin/'.. fileName)
	end
end


local langNames = {'en', 'es', 'fr', 'bp', 'fi', 'pl', 'my', 'it', 'de', 'ru', }
local flags = {
	en='us',
	es='es',
	fr='fr',
	bp='br',
	it='it',
	fi='fi',
	pl='pl',
	my='my',
	de='de',
	ru='ru',
}
local nonlatin = {ru=1}

function comma_value(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
    if (k==0) then
      break
    end
  end
  return formatted
end

f = io.open(output, 'w')


local html = ''
local toc = ''
toc = toc .. '<div class="infoCell">'
toc = toc .. '<a name="toc"></a>'
local function writeml(ml)
	for word in ml:gmatch('<a name="(fac%-[^"]*)"') do 
		toc = toc .. '<a href="#'..word..'">'
			..word:gsub('fac%-', '')
			..'</a> ' 
	end
	for word in ml:gmatch('<a name="(unit%-[^"]*)">') do 
		toc = toc .. ' - <a href="#'..word..'" style="font-size:x-small">'
			..word:gsub('unit%-', '')
			..'</a> ' 
	end
	
	html = html .. ml
end



--local morphDefs = openfile2(path .. '/morphdefs/morph_defs.lua')
local morphDefs = openfile2(path .. '/extradefs/morph_defs.lua') or {}

function trac_html (html)
	writeml(html)	
end

function buildPic(buildPicName)
	return '<img src="'.. faction_data.path ..'/unitpics/'.. string.lower(buildPicName) ..'" width="80" height="64" title="'.. buildPicName  ..'" class="buildpic" >'	
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
	
function tableRow (name, value, style)
	return 	'<tr '.. (style or '') ..'>' ..nl..
			'<td align="right"> '.. name ..' </td>' ..nl..
			'<td align="left" class="statsnumval"> '.. value .. '</td>'..nl..
		'</tr>' ..nl
end

function tableHeader (header, style)
	return 	'<tr '.. (style or '') ..'>' ..nl..
			'<th align="center" colspan="2" valign="top">'.. header ..'</th>' ..nl..
		'</tr>' ..nl
end

function printWeapons(unitDef)
	local weaponStats = {}
	local bestDamage, bestDamageIndex, bestTypeDamage = 0,0,0

	local merw = {}

	local wd = unitDef.weapondefs or weaponDefs
	if not wd then return '' end

	for i, weaponDef in pairs(unitDef.weapons) do 
	
		local weaponName = string.lower( unitDef.weapondefs and weaponDef.def or weaponDef.name ) --jw
		
		if (wd[weaponName] and wd[weaponName].damage) then
		
			local wsTemp = {}
			wsTemp.slaveTo = weaponDef.slaveto --fixme - lowercase?
			if wsTemp.slaveTo then
				merw[wsTemp.slaveTo] = merw[wsTemp.slaveTo] or {}
				merw[wsTemp.slaveTo][#(merw[wsTemp.slaveTo])+1] = i
			end
			wsTemp.bestTypeDamage = 0
			wsTemp.bestTypeDamagew = 0
			wsTemp.paralyzer = wd[weaponName].paralyzer	
			for unitType, damage in pairs(wd[weaponName].damage) do
				
				damage = math.max(damage, 0) --shadow has negative damage, breaks the below logic.
				
				if (wsTemp.bestTypeDamage <= (damage+0) and not wsTemp.paralyzer)
					or (wsTemp.bestTypeDamagew <= (damage+0) and wsTemp.paralyzer)
					then

					if wsTemp.paralyzer then
						wsTemp.bestTypeDamagew = (damage+0)
					else
						wsTemp.bestTypeDamage = (damage+0)
					end
					
					wsTemp.burst = wd[weaponName].burst or 1
					wsTemp.projectiles = wd[weaponName].projectiles or 1
					wsTemp.dam = 0
					wsTemp.damw = 0
					wsTemp.damBreakdown = ''
					if wsTemp.paralyzer then
						wsTemp.damw = wsTemp.bestTypeDamagew * wsTemp.burst * wsTemp.projectiles
					else
						wsTemp.dam = wsTemp.bestTypeDamage * wsTemp.burst * wsTemp.projectiles
						if wsTemp.projectiles > 1 or wsTemp.burst > 1 then
							wsTemp.damBreakdown = ' (' .. wsTemp.bestTypeDamage .. ' x ' .. (wsTemp.projectiles * wsTemp.burst) .. ')'
						end
					end
					
					
					
					
					-- [[
					if wd[weaponName].customparams and wd[weaponName].customparams.extra_damage then
						wsTemp.dam = wd[weaponName].customparams.extra_damage * wsTemp.burst * wsTemp.projectiles
					end
					--]]
					
					wsTemp.reloadtime 		= wd[weaponName].reloadtime or ''
					wsTemp.range 			= wd[weaponName].range or ''
					wsTemp.wname 			= wd[weaponName].name or 'NoName Weapon'
					wsTemp.areaofeffect 	= wd[weaponName].areaofeffect or ''
					wsTemp.dps 				= 0
					wsTemp.dpsw 			= 0
					
					if wd[weaponName].weapontype:lower() == 'shield' then
						wsTemp.shield 				= true
						wsTemp.shieldpower			= wd[weaponName].shieldpower or ''
						wsTemp.shieldpowerregen		= wd[weaponName].shieldpowerregen or ''
						wsTemp.shieldregenenergy	= wd[weaponName].shieldpowerregenenergy or ''
						wsTemp.shieldradius			= wd[weaponName].shieldradius or ''
					
					end
					
					if  wsTemp.reloadtime ~= '' and wsTemp.reloadtime > 0 then
						if wsTemp.paralyzer then
							wsTemp.dpsw = math.floor(wsTemp.damw/wsTemp.reloadtime + 0.5)
							if wd[weaponName].customparams and wd[weaponName].customparams.extra_damage then
								wsTemp.dps = math.floor(wsTemp.dam/wsTemp.reloadtime + 0.5)
							end
						else
							wsTemp.dps = math.floor(wsTemp.dam/wsTemp.reloadtime + 0.5)
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

	local cells = ''

	for index,ws in pairs(weaponList) do
		local mainweapon = merw and merw[index]
		if not ws.slaveTo then
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
		
			local dps_str, dam_str = '', ''
			if ws.dps > 0 then
				dam_str = dam_str .. comma_value(ws.dam)
				dps_str = dps_str .. comma_value(ws.dps)
			end
			if ws.dpsw > 0 then
				if dps_str ~= '' then
					dps_str = dps_str .. ' + '
					dam_str = dam_str .. ' + '
				end
				dam_str = '<span class="paralyze">' .. dam_str .. comma_value(ws.damw) .. ' (P)</span>'
				dps_str = '<span class="paralyze">' .. dps_str .. comma_value(ws.dpsw) .. ' (P)</span>'
			end
			
			dam_str = dam_str .. ws.damBreakdown
			
			if not (ws.wname:find('Fake') or ws.wname:find('fake') ) then
				cells = cells .. '<table cellspacing="0" border="1" cellpadding="2" class="statstable" style="display:inline-block; vertical-align:top;" >' ..nl
						
				if not ws.shield then
					cells = cells
						.. tableHeader('<img src="http://zero-k.info/img/luaui/commands/Bold/attack.png" width="20" alt="Weapon" title="Weapon" /> ' .. ws.wname ) 
						.. tableRow('Damage', dam_str, 'class="statsfield"')
						.. tableRow('Reloadtime', ws.reloadtime, 'class="statsfield"')
						.. tableRow('Damage/second', dps_str, 'class="statsfield"')
						.. tableRow('Range', comma_value(ws.range), 'class="statsfield"' )
						.. tableRow('Area of Effect', comma_value(ws.areaofeffect), 'class="statsfield"' ) 
				else
					cells = cells
						.. tableHeader('<img src="http://zero-k.info/img/luaui/commands/Bold/guard.png" width="20" alt="Weapon" title="Shield" /> ' .. ws.wname )
						.. tableRow('Power', 				ws.shieldpower, 		'class="statsfield"')
						.. tableRow('Regeneration', 		ws.shieldpowerregen, 	'class="statsfield"')
						.. tableRow('Energy to Regen', 	ws.shieldregenenergy, 	'class="statsfield"')
						.. tableRow('Radius', 				ws.shieldradius, 		'class="statsfield"')
						
				end
				cells = cells .. '</table>' ..nl
			end
		end

	end
	return cells
end

function GetDefName(k)
	
	local defNames = {
		brakerate = 'Brake Rate',
		buildtime = 'Build Time',
		footprintx = 'Footprint X',
		footprintz = 'Footprint Z',
		idleautoheal = 'Idle Autoheal',
		idletime = 'Idle Time',
		maxslope = 'Max Slope',
		maxwaterdepth = 'Max Water Depth',
		mincloakdistance = 'Decloak Distance',
		sightdistance = 'Sight Distance',
		turnrate = 'Turn Rate',
		workertime = 'Build Power',
	}
	
	local defName
	
	if k:sub(1,3) == 'can' then
		defName = 'Can ' .. k:sub(4,4):upper() .. k:sub(5):lower()
	else
		defName = defNames[ k:lower() ] or ( k:sub(1,1):upper() .. k:sub(2) )
	end
	
	return defName
	
end

function PrintRemainingStats(unitDef)
	
	local ignoreDefs = {
		name=1,
		unitname=1,
		maxdamage=1,
		sightdistance=1,
		description=1,
		maxvelocity=1,
		buildpic=1,
		buildcostmetal=1,
		buildcostenergy=1,
		
		activatewhenbuilt=1,
		buildtime=1,
		category=1,
		corpse=1,
		explodeas=1,
		firestate=1,
		icontype=1,
		initcloaked=1,
		modelcenteroffset=1,
		movementclass=1,
		movestate=1,
		nochasecategory=1,
		objectname=1,
		script=1,
		seismicsignature=1,
		selfdestructas=1,
		shownanospray=1,
		side=1,
		upright=1,
		
		collisionvolumeoffsets=1,
		collisionvolumescales=1,
		collisionvolumetype=1,
		
		leavetracks=1,
		trackoffset=1,
		trackstrength=1,
		trackstretch=1,
		tracktype=1,
		trackwidth=1,
	}
	local unitDef2 = {}
	for k,v in pairs(unitDef) do
		if type(v) ~= 'table' and not ignoreDefs[k] and k:sub(1,3) ~= 'can' then
			local defName = GetDefName(k)
			unitDef2[#unitDef2+1] = {defName,v}
		end
	end
	table.sort(unitDef2, function(a,b) return a[1]<b[1] end)
	
	local stats = ''
	
	for i,v2 in pairs(unitDef2) do
		local k = v2[1]
		local v = v2[2]
		
		if type(v) == 'boolean' then
			v = v and 'Yes' or 'No'
		end
		--writeml(k .. ' : ' .. v .. br)
		
		stats = stats .. k  .. ' : ' .. v .. '\\n'
		
	end
	return '<a href="#" onclick="alert(\''..stats..'\'); return false;" >More Stats</a>'
	
end

function printUnitMainStats(unitDef)
	
	local cost = unitDef.buildcostmetal and (unitDef.buildcostmetal > 0) and unitDef.buildcostmetal or unitDef.buildtime or unitDef.buildcostenergy or -1

	return '<table cellspacing="0" border="1" cellpadding="2" class="statstable" style="display:inline-block; vertical-align:top; " >' ..nl
		..tableRow('<img src="http://zero-k.info/img/luaui/ibeam.png" width="20" alt="Cost" title="Cost" />', comma_value(cost)) 
		..tableRow('<img src="http://zero-k.info/img/luaui/commands/Bold/health.png" width="20" alt="Health Points" title="Health Points" />', comma_value(unitDef.maxdamage)) 
		..tableRow('<img src="http://zero-k.info/img/battles/spec.png" width="20" alt="Sight Distance" title="Sight Distance" />', comma_value(unitDef.sightdistance)) 
		..(unitDef.maxvelocity and (unitDef.maxvelocity+0) > 0 and tableRow('<img src="http://zero-k.info/img/luaui/draggrip.png" width="20" alt="Speed" title="Speed" />', unitDef.maxvelocity) or '')
		..'<tr><td colspan="2">' .. PrintRemainingStats(unitDef).. '</tr>'
	..'</table>'
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

function printUnit(unitname, mobile_only)
	--print('Printing unit:', unitname)
	
	local unitDef = unitDefs[unitname]
	
	if not unitDef then return false; end
	
	
	if not unitDef.unitname then 
		--return false; 
		print("ERROR", unitname, unitDef.unitname, unitDef.name)
		--print( to_string(unitDef) )
		--return false;
	end
	
	if mobile_only and (not unitDef.maxvelocity or (unitDef.maxvelocity+0) < 0.1) then
		return
	end

	if lang == 'all' then
		
		
		writeml( buildPic(unitDef.buildpic or unitDef.unitname .. '.png') ..nl )
		writeml('<b>Unitname:</b> <a name="unit-' .. unitDef.name .. '">' .. unitname .. '</a>' .. brbr.. nlnl)
		writeml('<a href="#toc" style="white-space:nowrap;"> [ ^ ] </a>' .. nl ..br)
		
		for _, curlang in ipairs(langNames) do
			writeml('<div class="'.. curlang ..'_trans"> ' .. br.. nl)
			writeml('<img src="http://zero-k.info/img/luaui/flags/'.. flags[curlang]  ..'.png" > ')
			writeml("<b>Language:</b> " .. curlang .. br.. nl)
			writeml("<b>Description:</b>" .. (getDescription(unitDef, curlang) or '') .. br.. nl)
			writeml("<b>Helptext:</b> " .. (getHelpText(unitDef, curlang) or '') .. br.. nl)
			writeml('</div> ' ..  nlnl)
		end
		writeml('<hr />' .. br.. nlnl)
		return
	elseif lang == 'featured' then
		writeml(unitname .. '\t' .. unitDef.name .. '\t' .. getDescription(unitDef, 'en') .. '\t' .. getHelpText(unitDef, 'en') .. '\n' )
		return
	end
	
	writeml('<div class="infoCell unitCell">')
	
	local weaponStats = ''
	local buildPower = ''
	if (unitDef.weapons) then
		weaponStats = printWeapons(unitDef)
	end
	
	local mainStats = printUnitMainStats(unitDef)
	--[[
	if (unitDef.workerTime and unitDef.workerTime ~= 0) then
		buildPower = tableRow('Buildpower', unitDef.workerTime)
	end
	--]]
	
	local deathStats = printDeathStats(unitDef)
	
	local description = getDescription(unitDef)
	
	trac_html(''
		..'<div style="display:table; width:100%; ">' ..nl
			..'<div style="display:table-row; ">' ..nl
		
				..'<div style="display:table-cell;   ">' ..nl
				
					..'<a name="unit-' .. unitDef.name .. '"></a> <a href="#unit-' .. unitDef.name .. '" class="unitname">'
					.. unitDef.name .. '</a> - <span class="unitdesc">'.. description .. '</span></a> &nbsp;&nbsp;&nbsp;&nbsp;' .. nl
					..'<a href="#toc" style="white-space:nowrap;"> [ ^ ] </a>' .. nl ..br
				
					..buildPic(unitDef.buildpic or unitDef.unitname .. '.png') ..nl
				..'</div>' ..nl
				
				..'<div style="display:table-cell; text-align:right; vertical-align: top; ">' ..nl
					..'<div style="float:right">' ..nlnl
						..deathStats ..nlnl
						..weaponStats ..nlnl
						..mainStats ..nlnl
					..'</div>'
				..'</div>' ..nl
			 ..'</div>'.. nl
		 ..'</div>'.. nl
	)

	writeml('<span class="helptext"> '.. getHelpText(unitDef) .. '</span>' .. nlnl .. brbr)
	-- [[
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
	
	
	
	writeml('</div>')
	
end


function printFac(facname, printMobileOnly)
	curFacDef = unitDefs[facname]
	toc = toc .. '<div>'
	if lang == 'all' then
		
		writeml( buildPic(curFacDef.buildpic or curFacDef.unitname .. '.png') ..nl )
		writeml('Factory: <b>' .. '<a name="fac-'.. curFacDef.name ..'">' .. facname .. '</a></b> ' ..nlnl)
		
		for _, curlang in ipairs(langNames) do
				writeml('<div class="'.. curlang ..'_trans"> ' .. br.. nl)
				writeml('<img src="http://zero-k.info/img/luaui/flags/'.. flags[curlang]  ..'.png"> ')
				writeml("<b>Language:</b> " .. curlang .. br.. nl)
				writeml("<b>Description:</b>" .. (getDescription(curFacDef, curlang) or '') .. br..nl)
				writeml("<b>Helptext:</b> " .. (getHelpText(curFacDef, curlang) or '') .. br.. nlnl)
				writeml('</div> ' ..  nlnl)
		end
		writeml('<hr />' .. br.. nlnl)
		writeml('<blockquote>'.. nlnl)
	elseif lang == 'featured' then
		writeml(facname .. '\t' .. curFacDef.name .. '\t' .. getDescription(curFacDef, 'en') .. '\t' .. getHelpText(curFacDef, 'en') .. '\n' )
	else


		writeml('<div class="infoCell">' ..nlnl)
		writeml('<a name="fac-'.. curFacDef.name ..'"></a><h3><a href="#fac-'.. curFacDef.name ..'">'.. curFacDef.name ..'</a></h3>' ..nlnl)
		writeml("<b>".. getDescription(curFacDef)  .."</b>" ..nlnl .. brbr)	
		trac_html(
			buildPic(curFacDef.buildpic or curFacDef.unitname .. '.png') ..nl
		)
	
		
		writeml(brbr .. '<span class="helptext">' .. getHelpText(curFacDef) .. '</span>' .. nlnl)
		
		writeml('</div>' ..nlnl)
	end

	
	for _,unitname in pairs(curFacDef.buildoptions) do
		printUnit(unitname, printMobileOnly)
	end
	
	if lang == 'all' then
		writeml('</blockquote>'.. nlnl)
	end
	toc = toc .. '</div>'
	
	
end


function printFaction(intname, image)
	local faclist = faction_data.facs[intname]
	local dlist = faction_data.staticw[intname]
	local name = faction_data.faction_names[intname]
	local description = faction_data.faction_descriptions[intname]
	local somecon = faction_data.cons[intname]
	local printMobileOnly = faction_data.printMobileOnly
	local useBuildOptionFile = faction_data.useBuildOptionFile
	
	
	
	toc = toc .. name .. brbr..nlnl
	
	toc = toc .. '<b><a href="#factories">Factories</a></b> <blockquote>'

	
	local printedunitlistkeys = {}
	if lang ~= 'featured' then
		writeml('<a name="factories"></a><h2> Factories </h2> ' ..nlnl)
	end
	for _, fac in pairs(faclist) do
		printFac(fac, printMobileOnly[fac])
		printedunitlistkeys[fac] = true
	end
	toc = toc .. '</blockquote>'

	local buildopts = {}
	if useBuildOptionFile then
		buildopts = openfile2(path ..'/extradefs/buildoptions.lua')
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
	
	toc = toc .. '<b><a href="#staticweapons">Static Weapons</a></b>'
	if lang ~= 'featured' then
		writeml('<a name="staticweapons"></a><h2> Static Weapons & Defense</h2> ' ..nlnl)
	end
	for _,unitname in pairs(weaponStructs) do	
		printUnit(unitname)
	end
	
	
	toc = toc .. '<br /><br /><b><a href="#otherstructures">Other Structures</a></b>'
	if lang ~= 'featured' then
		writeml('<a name="otherstructures"></a><h2> Other Structures </h2> ' ..nlnl)
	end
	for _,unitname in pairs(regularStructs) do	
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

			

toc = toc .. '</div>'
if lang ~= 'featured' then
	html = toc .. html
	html = [[
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
		<h1>Unit Guide</h1> 
		<div style="font-size:x-small">Revision: ]].. GetRevision() ..[[</div>
		<link rel="stylesheet" type="text/css" href="]]..faction_data.path..[[/style.css">
		]] ..nlnl .. html


end


if lang == 'all' then
	local checkboxes = '';
	for _, curlang in ipairs(langNames) do
		checkboxes = checkboxes .. [[
			<label for="]] .. curlang .. [[_show">[ ]] .. curlang .. [[</label>
			<input type="checkbox" id="]] .. curlang .. [[_show" checked="checked" > ]
		]]
	end
	
	--fixme: jquery loaded twice
	html = [[
		<!DOCTYPE html>
		
		<html>
			<head>
			
			<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
			<script type="text/javascript"> 
				$(document).ready(function() {
					$("input[id$=_show]").click(function(){
						var lang;
						lang = $(this).attr("id").substr(0, 2);
						if( $(this).attr("checked") )
						{
							$("." + lang + "_trans").show();
						}
						else
						{
							$("." + lang + "_trans").hide();
						}
					});
					
					$("input[id$=_show]").attr("checked", "checked");
				});
				
			</script>
				
		</head>
		
		<body>
		
			<form>
				]]
				.. checkboxes ..
				[[
			</form>
	]] .. html .. [[ </body> ]]
end

f:write(html)
io.close(f)
