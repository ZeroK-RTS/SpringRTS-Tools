let get paths modinfo =
	try
		let path = Paths.last_modinfo paths modinfo in
		let in_file = open_in path in
		let rev_string = String.create 4 in
		let md5_digest = String.create 16 in
		really_input in_file rev_string 0 4;
		really_input in_file md5_digest 0 16;
		close_in in_file;
		Some(Int32.to_int (Serialize.parse_int32 rev_string), md5_digest)
	with
	| Sys_error _ -> None
		
let save paths modinfo rev md5_digest =
	let path = Paths.last_modinfo paths modinfo in
	let out_file = open_out path in
	output out_file (Serialize.format_int32 (Int32.of_int rev)) 0 4;
	output out_file md5_digest 0 16;
	close_out out_file

