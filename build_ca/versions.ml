open ExtString
module StringMap = Map.Make (String)

let load paths =
	try
		let path = Paths.concat paths Paths.store "versions.gz" in
		let in_gz = Gzip.open_in path in
		
		let f map line =
			match String.nsplit line "," with
			| [branch; hex; deps; name] ->
				let deps = Deps.parse deps in 
				StringMap.add branch (hex, deps, name) map
			| [branch; hex; _] ->
				let store = Store.load paths (Hex.decode hex) in
				StringMap.add branch (hex, store.Store.depends, store.Store.modname) map
			| _ -> failwith "Versions.load: bad input file"
		in		
		Gz.fold_lines f StringMap.empty in_gz
	with
	| _ -> StringMap.empty

let md5 paths =
	let path = Paths.concat paths Paths.store "versions.gz" in
	let data = Gz.read_file path in
	let md5 = Md5.create () in
	Md5.update md5 data;
	Md5.final md5

let write paths map =
	let path = Paths.concat paths Paths.store "versions.gz" in
	let out_gz = Gzip.open_out path in

	let f branch (digest, deps, name) =
		let string = Printf.sprintf "%s,%s,%s,%s\n" branch digest (Deps.format deps) name in
		Gzip.output out_gz string 0 (String.length string)
	in

	StringMap.iter f map;
	Gzip.close_out out_gz;

	let digest = md5 paths in
	let digest_path = Paths.concat paths Paths.store "versions.digest" in
	let out_file = open_out digest_path in
	output_string out_file digest;
	close_out out_file

let add map branch version deps name =
	StringMap.add branch (version, deps, name) map

let find map version =
	StringMap.find version map
