open ExtString
module StringMap = Map.Make (String)

type entry = {
	size: int32;
	md5_digest: string;
	crc32_digest: int32
}

type t = {
	paths: Paths.t;
	mutable entries: entry StringMap.t;
	mutable modname: string;
	mutable depends: string array
}
	
let md5_hash t =
	let md5 = Md5.create () in

	let f name entry =
		let name_md5 = Md5.create () in
		Md5.update name_md5 name;
		let name_digest = Md5.final name_md5 in
		Md5.update md5 name_digest;
		Md5.update md5 entry.md5_digest
	in

	StringMap.iter f t.entries;
	Md5.final md5

let crc32_hash t =
	let crc32 = Crc32.create () in

	let f name entry =
		let name_crc32 = Crc32.create () in
		Crc32.update name_crc32 name;
		let name_digest = Crc32.final name_crc32 in
		Crc32.update_int32 crc32 name_digest;
		Crc32.update_int32 crc32 entry.crc32_digest
	in

	StringMap.iter f t.entries;
	Crc32.final crc32

let create paths = {
	paths = paths;
	entries = StringMap.empty;
	modname = "";
	depends = [||]
}

let entry_size t entry =
	let path = Paths.pool_file t.paths entry.md5_digest in
	let stats = Unix.stat path in
	stats.Unix.st_size

let print_entry t entry =
	let path = Paths.pool_file t.paths entry.md5_digest in
	let in_file = open_in path in	
	let string = String.create 4096 in

	let rec loop () =
		let read = input in_file string 0 4096 in
		if read != 0
		then begin
			output stdout string 0 read;
			loop ()
		end
	in
	loop ();
	close_in in_file


let add_entry t name entry =
	let gz_path = Paths.pool_file t.paths entry.md5_digest in
	t.entries <- StringMap.add name entry t.entries;

	let modinfo =
		if name = "modinfo.lua"
		then
			let data = Gz.read_file gz_path in
			Some (Lua.modinfo data)
		else if name = "modinfo.tdf"
		then
			let data = Gz.read_file gz_path in
			Some (Tdf.modinfo data)
		else
			None
	in

	begin match modinfo with
	| None -> ()
	| Some(name, version, deps) ->
		if String.exists name version
		then
			t.modname <- name
		else begin
			let name = Printf.sprintf "%s %s" name version in
			t.modname <- name
		end;

		t.depends <- deps;
	end

let load paths digest =
	let sdp_path = Paths.sdp paths digest in
	let in_gzip = Gzip.open_in sdp_path in
	let t = create paths in

	let rec loop () = 
		match Gz.input_byte in_gzip with
		| None -> ()
		| Some length ->
			let name = String.create length in
			let md5_digest = String.create 16 in
			let crc32_digest = String.create 4 in
			let size_string = String.create 4 in

			Gzip.really_input in_gzip name 0 length;
			Gzip.really_input in_gzip md5_digest 0 16;
			Gzip.really_input in_gzip crc32_digest 0 4;
			Gzip.really_input in_gzip size_string 0 4;

			let entry = {
				size = Serialize.parse_int32 size_string;
				md5_digest = md5_digest;
				crc32_digest = Serialize.parse_int32 crc32_digest
			} in

			add_entry t name entry;
			loop ()
	in
	loop ();
	Gzip.close_in in_gzip;
	t
			
let write t =
	let index_path = Paths.temp t.paths in
	let index_gzip = Gzip.open_out ~level:9 index_path in
	
	let f name entry =
		Gzip.output_char index_gzip (Char.chr (String.length name));
		Gzip.output index_gzip name 0 (String.length name);
		Gzip.output index_gzip entry.md5_digest 0 (String.length entry.md5_digest);
		let crc32_string = Serialize.format_int32 entry.crc32_digest in
		Gzip.output index_gzip crc32_string 0 (String.length crc32_string);
		let size_string = Serialize.format_int32 entry.size in
		Gzip.output index_gzip size_string 0 (String.length size_string)
	in

	StringMap.iter f t.entries;
	Gzip.close_out index_gzip;
	
	let digest = md5_hash t in
	let sdp_path = Paths.sdp t.paths digest in
	Sys.rename index_path sdp_path

let remove t name =
	let entries = StringMap.remove (String.lowercase name) t.entries in
	t.entries <- entries

let remove_dir t dir =
	let dir = Printf.sprintf "%s/" dir in
	let idir = String.lowercase dir in
	
	let combine name _ accu =
		if String.starts_with name idir
		then name :: accu
		else accu
	in

	let to_remove = StringMap.fold combine t.entries [] in
	let remove entries name = StringMap.remove name entries in
	let entries = List.fold_left remove t.entries to_remove in
	t.entries <- entries

type out_pool = {
	t: t;
	name: string;
	temp_path: string;
	out_gzip: Gzip.out_channel;
	md5: Md5.t;
	crc32: Crc32.t;
	mutable size_accu: int32
}

let open_pool t name =
	let temp_path = Paths.temp t.paths in
	{
		t = t;
		name = String.lowercase name;
		temp_path = temp_path;
		out_gzip = Gzip.open_out ~level:9 temp_path;
		md5 = Md5.create ();
		crc32 = Crc32.create ();
		size_accu = Int32.zero
	}
		
let write_pool op string = 
	let len = String.length string in
	if len != 0
	then begin
		Gzip.output op.out_gzip string 0 len;
		Md5.update op.md5 string;
		Crc32.update op.crc32 string;
		op.size_accu <- Int32.add op.size_accu (Int32.of_int len)
	end

let close_pool op =
	Gzip.close_out op.out_gzip;
	let md5_digest = Md5.final op.md5 in
	let crc32_digest = Crc32.final op.crc32 in
	let gz_path = Paths.pool_file op.t.paths md5_digest in
	
	if Sys.file_exists gz_path
	then Unix.unlink op.temp_path
	else Sys.rename op.temp_path gz_path
	;
	
	let entry = {
		size = op.size_accu;
		md5_digest = md5_digest;
		crc32_digest = crc32_digest
	} in
	
	add_entry op.t op.name entry 


let iter_entries f t =
	let f2 name entry =
		let gz_path = Paths.pool_file t.paths entry.md5_digest in
		let in_gzip = Gzip.open_in gz_path in
		f name in_gzip;
		Gzip.close_in in_gzip
	in

	StringMap.iter f2 t.entries

