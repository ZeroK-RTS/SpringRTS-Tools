let main zip_path store_path =
	let _ = Unix.umask 0o0002 in
	let paths = Paths.create store_path in
	Paths.init paths;
	let zip = Zip.open_in zip_path in

	let store = Store.create paths in
	let f entry =
		if not entry.Zip.is_directory
		then begin
			let data = Zip.read_entry zip entry in
			let pool = Store.open_pool store entry.Zip.filename in
			Store.write_pool pool data;
			Store.close_pool pool
		end
	in
			
	List.iter f (Zip.entries zip);
	Store.write store;

	let versions = Versions.load paths in
	let digest = Store.md5_hash store in
	let hex = Hex.encode digest in
		
	let rec loop i v =
		if i == Array.length Sys.argv
		then v
		else
			let v = Versions.add v Sys.argv.(i) hex store.Store.depends store.Store.modname in
			loop (i+1) v
	in

	let versions = loop 3 versions in
	Versions.write paths versions

let () = main Sys.argv.(1) Sys.argv.(2)

