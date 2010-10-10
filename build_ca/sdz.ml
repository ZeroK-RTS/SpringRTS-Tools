let make paths digest output =
	let store = Store.load paths digest in
	let temp_path = Paths.temp paths in
	let zip = Zip.open_out temp_path in

	let f name in_gzip =
		let data = Gz.read in_gzip in
		Zip.add_entry data zip name
	in

	Store.iter_entries f store;
	Zip.close_out zip;
	Sys.rename temp_path output

