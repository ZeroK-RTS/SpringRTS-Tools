module Int = struct
	type t = int
	let compare (a: int) (b: int) = compare b a
end

module IntMap = Map.Make (Int)

exception Error of string
let parse_error s = raise (Error s)

type mod_entry = {
	changelog: string;
	hash: string;
	author: string;
	creationtime: string
}
		 
let parse_mod xml =
	let revision = ref None in
	let changelog = ref None in
	let hash = ref None in
	let author = ref None in
	let creationtime = ref None in

	let children =
		match xml with
		| Xml.Element ("ModEntry", [], children) -> children
		| _ -> parse_error "ModEntry"
	in
	
	let f child =
		let (key, value) =
			match child with
			| Xml.Element (key, [], [Xml.PCData value]) -> (key, value)
			| Xml.Element (key, [], []) -> (key, "")
			| _ -> parse_error "Pair"
		in
		
		match key with
		| "Revision" -> revision := Some value
		| "Changelog" -> changelog := Some value
		| "Hash" -> hash := Some value
		| "Author" -> author := Some value
		| "CreationTime" -> creationtime := Some value
		| _ -> parse_error "Key"
	in

	List.iter f children;

	let val_of opt =
		match !opt with
		| None -> parse_error "Not found"
		| Some x -> x
	in

	let revision = int_of_string (val_of revision) in
	let mod_entry = {
		changelog = val_of changelog;
		hash = val_of hash;
		author = val_of author;
		creationtime = val_of creationtime
	} in

	revision, mod_entry

let parse_mods xml =
	let children =
		match xml with
		| Xml.Element ("ArrayOfModEntry", _, children) -> children
		| _ -> parse_error "ArrayOfModEntry"
	in
	
	let combine accu child =
		let (revision, mod_entry) = parse_mod child in
		IntMap.add revision mod_entry accu
	in
	
	List.fold_left combine IntMap.empty children
		
let load paths =
	let path = Paths.concat paths Paths.store "modlist.gz" in
	try
		let data = Gz.read_file path in
		let xml = Xml.parse_string data in
		parse_mods xml
	with
	| Sys_error _ -> IntMap.empty
			
let add mods revision mod_entry =
	IntMap.add revision mod_entry mods

let format_changelog changelog =
	match changelog with
	| "" -> []
	| _ -> [Xml.PCData changelog]

let format_mod revision mod_entry =
	Xml.Element (
		"ModEntry",
		[],
		[
			Xml.Element("Revision",     [], [Xml.PCData (string_of_int revision)]);
			Xml.Element("Changelog",    [], format_changelog mod_entry.changelog);
			Xml.Element("Hash",         [], [Xml.PCData mod_entry.hash]);
			Xml.Element("Author",       [], [Xml.PCData mod_entry.author]);
			Xml.Element("CreationTime", [], [Xml.PCData mod_entry.creationtime])
		]
	)

let format_mods mods =
	let combine revision mod_entry accu = format_mod revision mod_entry :: accu in
	let children = IntMap.fold combine mods [] in

	Xml.Element (
		"ArrayOfModEntry",
		[
			"xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance";
			"xmlns:xsd", "http://www.w3.org/2001/XMLSchema"
		],
		children
	)

let write mods paths =
	let temp_path = Paths.temp paths in
	let xml = format_mods mods in
	let data = Xml.to_string_fmt xml in
	Gz.write_file temp_path data;
	let path = Paths.concat paths Paths.store "modlist.gz" in
	Sys.rename temp_path path
