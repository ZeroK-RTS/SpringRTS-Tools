
local faction_names = {
	one = ''
}
local cons = {
	one = 'armcom1',
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
	'missilesilo',
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

local faction_data = {
	faction_names = faction_names,
	facs = facs, 
	staticw = staticw, 
	faction_descriptions = faction_descriptions, 
	cons = cons,
}

return faction_data