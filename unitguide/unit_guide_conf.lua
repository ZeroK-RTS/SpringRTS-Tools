local faction_names = {
	one = ''
}
local cons = {
	one = 'armcom1',
}



local printMobileOnly = {
	armcsa = true,
}


local facs = {}
local staticw = {}

facs.one = {
	'factorycloak',
	'factoryshield',
	'factoryjump',
	'factoryspider',
	'factoryveh',
	'factorytank',
	'factoryhover',
	'factoryamph',
		
	'factoryplane',
	'factorygunship',
	'factoryship',
	'armcsa',
	'missilesilo',
	'striderhub',
}

local extra_units = {
	'nebula', 'heavyturret', 'iwin'
}

local faction_descriptions = {
	en = {
		one = '', 
	},
	fr = {
		
	},
	bp = {
		
	},
	pl = {
		
	},
	fi = {
		
	},

	my = {
		
	},
	
	es = {
	
	},
	
	it = {
	
	},
	
	
	all = { 
	}
}

local faction_data = {
	faction_names = faction_names,
	facs = facs, 
	staticw = staticw, 
	faction_descriptions = faction_descriptions, 
	cons = cons,
	extra_units = extra_units,
	printMobileOnly = printMobileOnly,
	useBuildOptionFile = true,
	path='http://packages.springrts.com/zkmanual',
	svnurl='http://zero-k.googlecode.com/svn/trunk/mods/zk'
}

return faction_data