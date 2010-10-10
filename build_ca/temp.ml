let () = Random.self_init ()

let file dir_path =
	let string = String.create 4 in

	let rec loop i x =
		if i = 0
		then ()
		else
			let int = Random.int 255 in
			let char = Char.chr int in
			string.[x] <- char;
			loop (i-1) (x+1)
	in

	loop 4 0;
	let hex = Hex.encode string in
	Filename.concat dir_path hex
