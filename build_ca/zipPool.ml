let main store_path version output =
	let paths = Paths.create store_path in
	let versions = Versions.load paths in
	let (hex, _, _) = Versions.find versions version in
	let digest = Hex.decode hex in
	Sdz.make paths digest output
	
let () = main Sys.argv.(1) Sys.argv.(2) Sys.argv.(3)

