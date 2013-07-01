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

local fileList = scandir(path ..'/units')
for n,fileName in ipairs(fileList) do	
	if fileName:find('.lua') then

		local unitDefsTable = openfile2(path ..'/units/'.. fileName)
		if not unitDefsTable then 
			print('Error #1 ' .. fileName)
		else
			for k,v in pairs(unitDefsTable) do
				unitDefs[k] = v
			end
		end
	end
end

local langNames = {'en', 'es', 'fr', 'bp', 'fi', 'pl', 'my', 'it', 'de',}
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
}

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
toc = toc .. '<a name="toc"></a>'
local function writeml(ml)
	for word in ml:gmatch('<a name="(fac%-[^"]*)"') do 
		toc = toc .. '<br /><a href="#'..word..'">'
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



local morphDefs = openfile2(path .. '/morphdefs/morph_defs.lua')

function trac_html (html)
	writeml(html)	
end

function buildPic(buildPicName)
	return '<img src="http://zero-k.info/img/unitpics/'.. string.lower(buildPicName) ..'" width="85" height="64" title="'.. buildPicName  ..'" class="buildpic" >'
		
end

function getDescription(unitDef, forcelang)
	local lang_to_use = forcelang or lang

	if lang_to_use == 'en' then
		return unitDef.description or ''
	else
		return unitDef.customparams and unitDef.customparams['description_' .. lang_to_use] or ''
	end
end	

function getHelpText(unitDef, forcelang)
	local lang_to_use = forcelang or lang	

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

	local wd = unitDef.weapondefs
	if not wd then return '' end

	for i, weaponDef in pairs(unitDef.weapons) do
		local weaponName = string.lower( weaponDef.def )
		
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
					if wsTemp.paralyzer then
						wsTemp.damw = wsTemp.bestTypeDamagew * wsTemp.burst * wsTemp.projectiles
					else
						wsTemp.dam = wsTemp.bestTypeDamage * wsTemp.burst * wsTemp.projectiles
					end
					
					-- [[
					if wd[weaponName].customparams and wd[weaponName].customparams.extra_damage then
						wsTemp.dam = wd[weaponName].customparams.extra_damage * wsTemp.burst * wsTemp.projectiles
					end
					--]]
					
					wsTemp.reloadtime = wd[weaponName].reloadtime or ''
					wsTemp.airWeapon = wd[weaponName].toAirWeapon or false
					wsTemp.range = wd[weaponName].range or ''
					wsTemp.wname = wd[weaponName].name or 'NoName Weapon'
					wsTemp.dps = 0
					wsTemp.dpsw = 0
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
			
			if not wsTemp.wname then print("BAD unit ", unitDef.unitname) return '' end -- stupid negative in corhurc is breaking me.
			weaponStats[i] = wsTemp

		end
	end
	--fixme, check for need of this var
	local weaponList = weaponStats

	local cells = ''

	for index,ws in pairs(weaponList) do
		local mainweapon = merw and merw[index]
		if not ws.slaveTo then
			local dam = ws.finalDamage
		
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
			
			if not (ws.wname:find('Fake') or ws.wname:find('fake') ) then
				cells = cells .. 
					'<td align="right" valign="top">' ..nl..
						'<table cellspacing="0" border="1" cellpadding="2" class="statstable">' ..nl..		
							tableHeader('<img src="http://zero-k.info/img/luaui/commands/Bold/attack.png" width="20" alt="Weapon" title="Weapon" style="vertical-align:top;" />' .. ws.wname ) .. 
							tableRow('Damage', dam_str, 'class="statsfield"')..
							tableRow('Reloadtime', ws.reloadtime, 'class="statsfield"')..
							tableRow('Damage/second', dps_str, 'class="statsfield"')..
							tableRow('Range', comma_value(ws.range), 'class="statsfield"' ) ..
						'</table>' ..nl..
					'</td>' ..nl
			end
		end

	end
	return cells
end


function printUnit(unitname, mobile_only)
	
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
		writeml("<b>Unitname:</b> " .. unitname .. brbr.. nlnl)
		for _, curlang in ipairs(langNames) do
			writeml('<div class="'.. curlang ..'_trans"> ' .. br.. nl)
			writeml('<img src="http://zero-k.info/img/luaui/flags/'.. flags[curlang]  ..'.png" > ')
			writeml("<b>Language:</b> " .. curlang .. br.. nl)
			writeml("<b>Description</b>" ..br.. nl.. '>> ' .. (getDescription(unitDef, curlang) or '') .. br.. nl)
			writeml("<b>Helptext</b> " ..br.. nl.. '>> ' .. (getHelpText(unitDef, curlang) or '') .. br.. nl)
			writeml('</div> ' ..  nlnl)
		end
		writeml('<hr />' .. br.. nlnl)
		return
	elseif lang == 'featured' then
		writeml(unitname .. '\t' .. unitDef.name .. '\t' .. getDescription(unitDef, 'en') .. '\t' .. getHelpText(unitDef, 'en') .. '\n' )
		return
	end
	
	writeml('<blockquote>')
	
	local weaponStats = ''
	local buildPower = ''
	if (unitDef.weapons) then
		weaponStats = printWeapons(unitDef)
	end
	--[[
	if (unitDef.workerTime and unitDef.workerTime ~= 0) then
		buildPower = tableRow('Buildpower', unitDef.workerTime)
	end
	--]]
	
	local description = getDescription(unitDef)
	writeml(''
		..'<a name="unit-' .. unitDef.name .. '"></a> <a href="#unit-' .. unitDef.name .. '" class="unitname">'
		.. unitDef.name .. '</a> - <span class="unitdesc">'.. description .. '</span></a> &nbsp;&nbsp;&nbsp;&nbsp;' 
		.. nl
		..'<a href="#toc"> [ ^ ] </a>'
		.. nl
		)

	local cost = unitDef.buildcostmetal and (unitDef.buildcostmetal > 0) and unitDef.buildcostmetal or unitDef.buildtime or unitDef.buildcostenergy

	trac_html(
		'<table border="0" width="100%">' ..nl
		..'<tr>' ..nl
			..'<td align="left" valign="top">' ..nl
				..buildPic(unitDef.buildpic or unitDef.unitname .. '.png') ..nl
			..'</td>' ..nl
			..'<td align="right" valign="top" width="100%">' ..nl
				..'<table cellspacing="0" border="1" cellpadding="2" class="statstable">' ..nl
					..tableRow('<img src="http://zero-k.info/img/luaui/ibeam.png" width="20" alt="Cost" title="Cost" />', comma_value(cost)) 
					..tableRow('<img src="http://zero-k.info/img/luaui/commands/Bold/health.png" width="20" alt="Health Points" title="Health Points" />', comma_value(unitDef.maxdamage)) 
					..(unitDef.maxvelocity and (unitDef.maxvelocity+0) > 0 and tableRow('<img src="http://zero-k.info/img/luaui/draggrip.png" width="20" alt="Speed" title="Speed" />', unitDef.maxvelocity) or '') 
				..'</table>' ..nl
			..'</td>' ..nl
			..weaponStats 
		..'</tr>' ..nl
		..'</table>'.. nl
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
	
	writeml('<hr />' ..nlnl)
	
	writeml('</blockquote>')
	
end


function printFac(facname, printMobileOnly)
	curFacDef = unitDefs[facname]

	if lang == 'all' then
		writeml('<h3> Factory: ' .. facname .. ' </h3>' ..nlnl)
		for _, curlang in ipairs(langNames) do
				writeml('<div class="'.. curlang ..'_trans"> ' .. br.. nl)
				writeml('<img src="http://zero-k.info/img/luaui/flags/'.. flags[curlang]  ..'.png"> ')
				writeml("<b>Language:</b> " .. curlang .. br.. nl)
				writeml("<b>Description</b>" .. br.. nl.. '>> ' .. (getDescription(curFacDef, curlang) or '') .. br..nl)
				writeml("<b>Helptext</b> " ..br..nl.. '>> ' .. (getHelpText(curFacDef, curlang) or '') .. br.. nlnl)
				writeml('</div> ' ..  nlnl)
		end
		writeml('<hr />' .. br.. nlnl)
		writeml('<blockquote>'.. nlnl)
	elseif lang == 'featured' then
		writeml(facname .. '\t' .. curFacDef.name .. '\t' .. getDescription(curFacDef, 'en') .. '\t' .. getHelpText(curFacDef, 'en') .. '\n' )
	else


		writeml('<a name="fac-'.. curFacDef.name ..'"></a><h3><a href="#fac-'.. curFacDef.name ..'">'.. curFacDef.name ..'</a></h3>' ..nlnl)
		writeml("<b>".. getDescription(curFacDef)  .."</b>" ..nlnl .. brbr)	
		trac_html(
			buildPic(curFacDef.buildpic or curFacDef.unitname .. '.png') ..nl
		)
	
		
		writeml(brbr .. '<span class="helptext">' .. getHelpText(curFacDef) .. '</span>' .. nlnl)
		writeml('<hr />' ..nlnl)
	end

	for _,unitname in pairs(curFacDef.buildoptions) do
		printUnit(unitname, printMobileOnly)
	end
	
	if lang == 'all' then
		writeml('</blockquote>'.. nlnl)
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
	
	
	
	toc = toc .. brbr .. name
	
	toc = toc .. '<br /> <b><a href="#factories">Factories</a></b> <blockquote>'

	
	local printedunitlistkeys = {}
	if lang ~= 'featured' then
		writeml('<a name="factories"></a><h3> Factories </h3> ' ..nlnl)
	end
	for _, fac in pairs(faclist) do
		printFac(fac, printMobileOnly[fac])
		printedunitlistkeys[fac] = true
	end
	toc = toc .. '</blockquote>'
	toc = toc .. '<b><a href="#staticweapons">Static Weapons</a></b>'

	if lang ~= 'featured' then
		writeml('<a name="staticweapons"></a><h3> Static Weapons </h3> ' ..nlnl)
	end
	for _, d in pairs(dlist) do
		printUnit(d)
		printedunitlistkeys[d] = true
	end
	toc = toc .. '<br /><br /><b><a href="#otherstructures">Other Structures</a></b>'

	if somecon then
		
		local slist = {}
		local unitDef = unitDefs[somecon]
		if not unitDef then return false; end
		
		local buildopts = useBuildOptionFile and openfile2(path ..'/buildoptions.lua') or unitDef.buildoptions or {}
		
		if lang ~= 'featured' then
			writeml('<a name="otherstructures"></a><h3> Other Structures </h3> ' ..nlnl)
		end
		for _,unitname in pairs(buildopts) do
			if not printedunitlistkeys[unitname] then
				printUnit(unitname)
			end
		end
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

			

toc = toc .. brbr
if lang ~= 'featured' then
	f:write(toc)
end

if lang == 'all' then
	local checkboxes = '';
	for _, curlang in ipairs(langNames) do
		checkboxes = checkboxes .. [[
			<label for="]] .. curlang .. [[_show">]] .. curlang .. [[</label>
			<input type="checkbox" id="]] .. curlang .. [[_show" checked="checked" >
		]]
	end
	
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
