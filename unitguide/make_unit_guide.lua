path = arg[1]
output = arg[2]
lang = arg[3]


local nl = "\n"
local nlnl = "\n\n"
local br = "<br />"
local brbr = "<br /><br />"

local langNames = {'en', 'es', 'fr', 'bp', 'fi', 'pl', 'my', 'it'}
local flags = {
	en='us',
	es='es',
	fr='fr',
	bp='br',
	it='it',
	fi='fi',
	pl='pl',
	my='my',
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

armfacs = {
	'factorycloak',
	'factoryshield',
	'factoryjump',
	'factoryspider',
	'factoryveh',
	'factorytank',
	'factoryhover',
		
	'factoryplane',
	'factorygunship',
	'corsy',
	'armcsa',

}

chickenfacs = {
	'nest',
}

armdefenses =
{
	'corllt',
	'corhlt',
	'corgrav',
	'armdeva',
	'armartic',
	'armpb',
	
	'corrl',
	'screamer',
	'corrazor',
	'corflak',
	'missiletower',
	'armcir',
	'cortl',
	
	'corsilo',
	'missilesilo',
	'armanni',
	'cordoom',
	'corbhmth',
	'armbrtha',
}

chickendefenses =
{
	"chickend",
	"chickenspire",
}
local ignoreweapon =
{
	armaak = {1},
	armcrus = {3},
	armcarry = {1},
	armaas = {1},
	armraz = {2},
	
	coraak = {1},
	corcrus = {3},
	coramph = {2},

	armcom = {1,2,3},
	armadvcom = {1,2},	
	corcom = {1,2,3},
	coradvcom = {1},
	commadvrecon = {2},
	commadvsupport = {2},
}
for unitname,indeces in pairs(ignoreweapon) do
	local newtable = {}

	for _,index in ipairs(indeces) do
		newtable[index]=true
	end

	ignoreweapon[unitname] = newtable
end

function lowerkeys()
end

local html = ''
local toc = ''
toc = toc .. '<a name="toc"></a>'
toc = toc .. '<b><a href="#factories">Factories</a></b> <blockquote>'
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
	--f:write(ml)
end

function openfile(filename)
    --local success,errors = pcall(dofile, path .. '/' .. filename ..'.lua')
	return dofile(path .. '/' .. filename .. '.lua')
	
end

Spring = {
	GetModOptions = function() return 'asdf' end
}

local morphDefs = openfile('morph_defs')

function trac_html (html)
	--[[
	writeml('{{{'..nl..
		'#!html' ..nl..
		html ..
		'}}}'..nl
	)
	--]]
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
		return unitDef.customParams and unitDef.customParams['description_' .. lang_to_use] or ''
	end
end	

function getHelpText(unitDef, forcelang)
	--local lang_to_use = forcelang
	--if not forcelang then
	--	lang_to_use = lang
	--end
	local lang_to_use = forcelang or lang	

	local suffix = (lang_to_use == 'en') and '' or ('_' .. lang_to_use)	
	return unitDef.customParams and unitDef.customParams['helptext' .. suffix] or ''
end	
	
function tableRow (name, value, style)
	return 	'<tr '.. (style or '') ..'>' ..nl..
			'<td align="right"> '.. name ..' </td>' ..nl..
			'<td align="left"> '.. value .. '</td>'..nl..
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

	local wd = unitDef.weaponDefs
	if not wd then return '' end	
	for i, weaponDef in pairs(unitDef.weapons) do
		local weaponName = weaponDef.def
		if (wd[weaponName] and wd[weaponName].damage) then
			
			local wsTemp = {}
			wsTemp.slaveTo = weaponDef.slaveTo
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
					wsTemp.reloadtime = wd[weaponName].reloadtime or ''
					wsTemp.airWeapon = wd[weaponName].toAirWeapon or false
					wsTemp.range = wd[weaponName].range or ''
					wsTemp.wname = wd[weaponName].name or 'NoName Weapon'
					wsTemp.dps = 0
					wsTemp.dpsw = 0
					if  wsTemp.reloadtime ~= '' and wsTemp.reloadtime > 0 then
						if wsTemp.paralyzer then
							wsTemp.dpsw = math.floor(wsTemp.damw/wsTemp.reloadtime + 0.5)
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
			
			if not wsTemp.wname then print("BAD", unitDef.unitname) return '' end -- stupid negative in corhurc is breaking me.
			weaponStats[i] = wsTemp

		end
	end
	--fixme, check for need of this var
	local weaponList = weaponStats

	local cells = ''

	for index,ws in pairs(weaponList) do
		if not (ignoreweapon[unitDef.unitname] and ignoreweapon[unitDef.unitname][index]) then

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
					dps_str = dps_str .. ' || '
					dam_str = dam_str .. ' || '
				end
				dam_str = '<span class="paralyze">' .. dam_str .. comma_value(ws.damw) .. ' (P)</span>'
				dps_str = '<span class="paralyze">' .. dps_str .. comma_value(ws.dpsw) .. ' (P)</span>'
			end
			
			cells = cells .. 
				'<td align="right" valign="top">' ..nl..
					'<table cellspacing="0" border="1" cellpadding="2" class="statstable">' ..nl..		
						tableHeader('<img src="http://zero-k.info/img/luaui/commands/Bold/attack.png" width="20" alt="Weapon" title="Weapon" style="vertical-align:top;" />' .. ws.wname ) .. 
						tableRow('Damage', dam_str, 'style="white-space:nowrap"')..
						tableRow('Reloadtime', ws.reloadtime, 'style="white-space:nowrap"')..
						tableRow('Damage/second', dps_str, 'style="white-space:nowrap"')..
						tableRow('Range', ws.range) ..
					'</table>' ..nl..
				'</td>' ..nl
		end

		end
	end
	return cells
end

function printUnit(unitname, mobile_only)
	openfile(unitname)

	if mobile_only and (not unitDef.maxVelocity or (unitDef.maxVelocity+0) < 0.1) then
		return
	end

	if lang == 'all' then
		writeml("<b>Unitname:</b> " .. unitname .. nlnl)
		for _, curlang in ipairs(langNames) do
			--writeml('[[Image(source:/trunk/mods/ca/LuaUI/Images/flags/'.. flags[curlang]  ..'.png)]] ')
			writeml('<img src="/trunk/mods/ca/LuaUI/Images/flags/'.. flags[curlang]  ..'.png" > ')
			writeml("<b>Language:</b> " .. curlang .. nlnl)
			writeml("> <b>Description</b>" ..nl.. '>>' .. (getDescription(unitDef, curlang) or '') .. nl)
			writeml("> <b>Helptext</b> " ..nl.. '>>' .. (getHelpText(unitDef, curlang) or '') .. nlnl)
		end
		writeml('<hr />' .. nlnl)
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
	writeml(
		'<a name="unit-' .. unitDef.name .. '"></a> <a href="#unit-' .. unitDef.name .. '" class="unitname">'
		.. unitDef.name .. '</a> - <span class="unitdesc">'.. description .. '</a> &nbsp;&nbsp;&nbsp;&nbsp;' 
		.. nl
		..'<a href="#toc"> [ ^ ] </a>'
		.. nl
		)

	local cost = unitDef.buildCostMetal > 0 and unitDef.buildCostMetal or unitDef.buildTime

	trac_html(
		'<table border="0" width="100%">' ..nl..
		'<tr>' ..nl..
		'<td align="left">' ..nl..
			buildPic(unitDef.buildPic or unitDef.unitname .. '.png') ..nl..
		'</td>' ..nl..
		'<td align="right" valign="top" width="100%">' ..nl..
			'<table cellspacing="0" border="1" cellpadding="2" class="statstable">' ..nl..
				tableRow('<img src="http://zero-k.info/img/luaui/ibeam.png" width="20" alt="Cost" title="Cost" />', comma_value(cost)) ..
				tableRow('<img src="http://zero-k.info/img/luaui/commands/Bold/health.png" width="20" alt="Health Points" title="Health Points" />', comma_value(unitDef.maxDamage)) ..
				(unitDef.maxVelocity and (unitDef.maxVelocity+0) > 0 and tableRow('<img src="http://zero-k.info/img/luaui/draggrip.png" width="20" alt="Speed" title="Speed" />', unitDef.maxVelocity) or '') ..
			'</table>' ..nl..
		'</td>' ..nl..
		weaponStats ..
		'</tr>' ..nl..
		'</table>'.. nl
	)

	writeml('<span class="helptext"> '.. getHelpText(unitDef) .. '</span>' .. nlnl .. brbr)
	
	local morphs = morphDefs[unitDef.unitname]
	if morphs then
		local morphstr = '<span class="morphs"> Morphs to: '
		if morphs.into then
			openfile(morphs.into)
			local cost = ' (' .. (morphs.rank and morphs.rank ~= 0 and (morphs.rank .. ' Rank, ') or '') .. (morphs.time or '0') .. 's)'
			morphstr = morphstr .. '<a href="#unit-' .. unitDef.name .. '">' .. unitDef.name .. '</a>' .. cost .. ', '
		else
			for k,v in ipairs(morphs) do
				openfile(v.into)
				local cost = ' (' .. (v.rank and v.rank ~= 0 and (v.rank .. ' Rank, ') or '') .. (v.time or '0') .. 's)'
				morphstr = morphstr .. '<a href=#unit-' .. unitDef.name .. '>' .. unitDef.name .. '</a>' ..  cost .. ', '
			end
		end
		morphstr = morphstr .. '</span>'
		writeml(morphstr:sub(1,-3) .. nlnl)
	end
	
	writeml('<hr />' ..nlnl)
	
	writeml('</blockquote>')
	
end


function printFac(facname)
	openfile(facname)
	curFacDef = unitDef

        if lang == 'all' then
                writeml('<h3> Factory: ' .. facname .. ' </h3>' ..nlnl)
                for _, curlang in ipairs(langNames) do
                        writeml('[[Image(source:/trunk/mods/ca/LuaUI/Images/flags/'.. flags[curlang]  ..'.png)]] ')
                        writeml("<b>Language:</b> " .. curlang .. nlnl)
                        writeml("> <b>Description</b>" ..nl.. '>>' .. (getDescription(curFacDef, curlang) or '') .. nl)
                        writeml("> <b>Helptext</b> " ..nl.. '>>' .. (getHelpText(curFacDef, curlang) or '') .. nlnl)
                end
                writeml('<hr />' .. nlnl)
        else


		writeml('<a name="fac-'.. curFacDef.name ..'"></a><h3><a href="#fac-'.. curFacDef.name ..'">'.. curFacDef.name ..'</a></h3>' ..nlnl)
		writeml("<b>".. getDescription(curFacDef)  .."</b>" ..nlnl .. brbr)	
		trac_html(
			buildPic(curFacDef.buildPic) ..nl
		)
	
		
		writeml(brbr .. getHelpText(curFacDef) .. nlnl)
		writeml('<hr />' ..nlnl)
	end

	for _,unitname in pairs(curFacDef.buildoptions) do
		printUnit(unitname,true)
	end
end


function printFaction(name, image, description, faclist, dlist, somecon)
	--writeml('<h1> '.. name ..' </h1>' ..nlnl)
	--writeml('<img src="'.. image ..'" /> ' )	
	--writeml(description ..' '.. nlnl)

	--writeml('<hr />' ..nlnl)
	local printedunitlistkeys = {}
	writeml('<a name="factories"></a><h3> Factories </h3> ' ..nlnl)
	for _, fac in pairs(faclist) do
		printFac(fac)
		printedunitlistkeys[fac] = true
	end
	toc = toc .. '</blockquote>'
	toc = toc .. '<b><a href="#staticweapons">Static Weapons</a></b>'

	writeml('<a name="staticweapons"></a><h3> Static Weapons </h3> ' ..nlnl)
	for _, d in pairs(dlist) do
		printUnit(d)
		printedunitlistkeys[d] = true
	end
	toc = toc .. '<br /><br /><b><a href="#otherstructures">Other Structures</a></b>'

	if somecon then
		local slist = {}
		openfile(somecon)
		writeml('<a name="otherstructures"></a><h3> Other Structures </h3> ' ..nlnl)
		for _,unitname in pairs(unitDef.buildoptions) do
			if not printedunitlistkeys[unitname] then
				printUnit(unitname)
			end
		end
	end
end

trac_html(
	'<style type="text/css">' ..nl..
	'tr.blue { border-color: #00DD00 }' ..nl..
	'</style>' ..nl
)


if false and lang ~= 'all' then
	local roles_file = '/home/ca/bin/manual/roles.txt'
	if lang ~= 'en' then
		roles_file = '/home/ca/bin/manual/roles_'.. lang ..'.txt'
	end
	--[[
	for line in io.lines(roles_file) do 
		writeml(line)
	end
	--]]
	fhroles = io.open(roles_file, "rb")
	writeml(fhroles:read("*all"))
	fhroles:close()
else
	--writeml('[[PageOutline]]' ..nl)
end

local faction_descriptions = {
	en = {
		nova = 'Nova favors mobility, range and affordability. Its Commanders should try to take an indirect approach whenever possible.', 
		logos = "The Logos' doctrine dictates that Commanders should make the most out of the Logos' superiority in firepower and defense by executing direct attacks and attacking the opponent with brute force.", 
		chicken = 'The Chickens are a force to be reckoned with.', 
	},
	fr = {
		nova = 'Nova ...', 
		logos = "Logos ...", 
		chicken = 'The Chickens ...', 
	},
	bp = {
		nova = 'Nova ...', 
		logos = "Logos ...", 
		chicken = 'The Chickens ...', 
	},
	pl = {
		nova = 'Nove cechuje mobilnosc, zasieg i dostepnosc. Dowódcom radzi sie uzywac sprytnego podejscia kiedy tylko sie da. ', 
		logos = "Logos ...", 
		chicken = 'The Chickens ...', 
	},
	fi = {
		nova = 'Nova suosii edullisia, ketterästi liikkuvia ja pitkän kantaman omaavia yksiköitä. Nova komentajien tulee käyttää epäsuoraa lähestymistapaa aina, kuin mahdollista.', 
		logos = "Logos ...", 
		chicken = 'The Chickens ...', 
	},

	my = {
			nova = 'Nova.... ',
			logos = "Logos ...",
			chicken = 'The Chickens ...',
	},
	
	es = {
			nova = 'Nova.... ',
			logos = "Logos ...",
			chicken = 'The Chickens ...',
	},
	
	it = {
			nova = 'Nova.... ',
			logos = "Logos ...",
			chicken = 'The Chickens ...',
	},
	
	
	all = {nova='', logos='', chicken=''}
}


printFaction('Nova (formerly ARM)', 
			'http://trac.caspring.org/export/head/trunk/mods/ca/sidepics/arm_16.png',
			faction_descriptions[lang].nova,
			armfacs, armdefenses, 'armcom')

			

toc = toc .. '<br /><br />'
f:write(toc)
f:write(html)
io.close(f)
