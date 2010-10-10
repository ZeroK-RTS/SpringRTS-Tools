let caseless = [`CASELESS]
let depend_re = Pcre.regexp ~flags:caseless "depend\\d+\\s*=\\s*(.+)\\s*;"
let name_re = Pcre.regexp ~flags:caseless "name\\s*=\\s*(.+)\\s*;"
let version_re = Pcre.regexp ~flags:caseless "version\\s*=\\s*(.+)\\s*;"

let deps data =
	try
		let matches = Pcre.extract_all ~rex:depend_re data in
		let f inner = inner.(1) in
		Array.map f matches
	with
	| Not_found -> [||]

let name data =
	try
		let strings = Pcre.extract ~rex:name_re data in
		strings.(1)
	with
	| Not_found -> ""

let version data =
	try
		let strings = Pcre.extract ~rex:version_re data in
		strings.(1)
	with
	| Not_found -> ""


let modinfo data = name data, version data, deps data
