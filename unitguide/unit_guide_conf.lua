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
	'athena',
	'staticmissilesilo',
	'striderhub',
}

local extra_units = {
	'nebula', 'turretsunlance', 'iwin', 'energyheavygeo',
	'bomberassault', 'bomberskirm', 'bomberstrike', 'subscout', 'destroyer', 'assaultcruiser',
	'hoversonic', 'hoverskirm2', 'hovershotgun', 'grebe',
	'dronecarry', 'dronefighter', 'droneheavyslow', 'dronelight',
	'wolverine_mine', 'tele_beacon', 'starlight_satellite',
	
	'chicken',
	'chickena',
	'chicken_blimpy',
	'chickenblobber',
	'chickenbroodqueen',
	'chickenc',
	'chickend',
	'chicken_digger',
	'chicken_dodo',
	'chicken_dragon',
	'chickenf',
	'chickenflyerqueen',
	'chickenlandqueen',
	'chicken_leaper',
	'chicken_listener',
	'chicken_listener_b',
	'chicken_pigeon',
	'chickenlandqueen',
	'chickenr',
	'chicken_rafflesia',
	'chicken_roc',
	'chickens',
	'chicken_shield',
	'chicken_spidermonkey',
	'chickenspire',
	'chicken_sporeshooter',
	'chicken_tiamat',
	'chickenwurm',
	'roost'
}

local ignore = {}

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
	ignore = ignore,
	printMobileOnly = printMobileOnly,
	useBuildOptionFile = true,
	path='http://manual.zero-k.info',
	svnurl='http://zero-k.googlecode.com/svn/trunk/mods/zk'
}

return faction_data