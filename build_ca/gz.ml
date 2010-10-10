let fold_lines f accu in_gzip =
	let buffer = Buffer.create 4096 in
	
	let rec loop accu =
		match
			try	Some (Gzip.input_char in_gzip) with
			| End_of_file -> None
		with
		| None ->
			let line = Buffer.contents buffer in
			if line = ""
			then accu
			else f accu line
		| Some char ->
			if char = '\n'
			then
				let accu = f accu (Buffer.contents buffer) in
				Buffer.clear buffer;
				loop accu
			else begin
				Buffer.add_char buffer char;
				loop accu
			end
	in
	loop accu

let read in_gzip =
	let buffer = Buffer.create 65536 in
	let string = String.create 4096 in
	
	let rec loop () =
		let read = Gzip.input in_gzip string 0 4096 in
		if read != 0
		then begin
			Buffer.add_substring buffer string 0 read;
			loop ()
		end
	in

	loop ();
	Buffer.contents buffer

let read_file path =
	let in_gzip = Gzip.open_in path in
	let data = read in_gzip in
	Gzip.close_in in_gzip;
	data

let read_stdin () =
	let in_gzip = Gzip.open_in_chan stdin in
	let data = read in_gzip in
	Gzip.close_in in_gzip;
	data

let write_file path string =
	let out_gzip = Gzip.open_out path in
	Gzip.output out_gzip string 0 (String.length string);
	Gzip.close_out out_gzip

let input_byte in_gzip	=
	try Some(Gzip.input_byte in_gzip)
	with End_of_file -> None
