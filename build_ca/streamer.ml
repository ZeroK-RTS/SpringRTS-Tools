let main () =
	let store_path = Sys.getenv "DOCUMENT_ROOT" in
	let paths = Paths.create store_path in
	let hex = Sys.getenv "QUERY_STRING" in
	let digest = Hex.decode hex in
	let store = Store.load paths digest in

	let s = Gz.read_stdin () in
	let bitarray = Serialize.parse_bitarray s in

	let f _ entry (i, total_size, pairs) =
		let total_size, pairs =
			if BitArray.get bitarray i
			then
				let size = Store.entry_size store entry in
				let pairs = (size, entry) :: pairs in
				(total_size + size + 4), pairs
			else
				total_size, pairs
		in
		i + 1, total_size, pairs
	in

	let _, total_size, list = Store.StringMap.fold f store.Store.entries (0, 0, []) in
	let list = List.rev list in

	Printf.printf "Content-Type: application/octet-stream\n";
	Printf.printf "Content-Transfer-Encoding: binary\n";
	Printf.printf "Content-Length: %d\n" total_size;
	print_newline();	

	let print_int32 i = print_string (Serialize.format_int32 (Int32.of_int i)) in
	let f (size, entry) =
		print_int32 size;
		Store.print_entry store entry
	in
	List.iter f list

let () = main ()

