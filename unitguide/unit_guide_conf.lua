
local faction_names = {
	one = ''
}
local cons = {
	one = 'armcom',
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
		
	'factoryplane',
	'factorygunship',
	'corsy',
	'armcsa',
}
staticw.one =
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

local faction_data = {
	faction_names = faction_names,
	facs = facs, 
	staticw = staticw, 
	faction_descriptions = faction_descriptions, 
	ignoreweapon = ignoreweapon,
	cons = cons,
}

return faction_data