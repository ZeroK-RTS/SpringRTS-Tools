dofile("json.lua")

local zk_folder=arg[1]
local output=arg[2]
local lang=arg[3] or 'en'

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

function getDescription(unitDef)
	local lang_to_use = lang

	if lang_to_use == 'en' then
		return unitDef.description or nil
	else
		return unitDef.customparams and unitDef.customparams['description_' .. lang_to_use] or nil
	end
end	

function getHelpText(unitDef)
	local lang_to_use = lang	

	local suffix = (lang_to_use == 'en') and '' or ('_' .. lang_to_use)	
	return unitDef.customparams and unitDef.customparams['helptext' .. suffix] or nil
end	

local function loadFromUnitdefs()
	local lang_data={}
	local files=scandir(zk_folder.."/units")
	for n,fileName in ipairs(files) do	
		if fileName:find('.lua$') then
			local unitDefsTable = openfile2(zk_folder ..'/units/'.. fileName)
			if not unitDefsTable then 
				print('Error #1 ' .. fileName)
			else
				for unitname, unitDef in pairs(unitDefsTable) do
					local unit_data={}
					unit_data["name"]=unitDef.name
					unit_data["description"]=getDescription(unitDef)
					unit_data["helptext"]=getHelpText(unitDef)
					lang_data[unitname]=unit_data
					print('\tDone unit ' .. unitname)
				end
				print('Done ' .. fileName)
			end
		end
	end
	return lang_data
end

local function loadFromLuaFile()
	local lang_data={}
	local lang_file=openfile2(zk_folder .."/LuaUI/Configs/nonlatin/".. lang ..".lua")
	if lang_file then
		for name,texts in pairs(lang_file.units) do
			local unit_data={}
			unit_data["name"]=name
			unit_data["description"]=texts.description
			unit_data["helptext"]=texts.helptext
			lang_data[name]=unit_data
			print("Done unit " .. name)
		end
		return lang_data
	else
		return nil
	end
end

local lang_data=loadFromLuaFile() or loadFromUnitdefs()
local fd = io.open(output, 'w')
fd:write(encode(lang_data))
fd:close()

