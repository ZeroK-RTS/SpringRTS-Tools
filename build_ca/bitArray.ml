type t = char array

let create len bool =
	let byte_index = len / 8 in
	let bit_index = len mod 8 in
	let byte_len =
		if bit_index = 0
		then byte_index
		else byte_index + 1
	in
	let int =
		if bool
		then 255
		else 0
	in
	Array.create byte_len int

let set t index bool =
	let byte_index = index / 8 in
	let bit_index = index mod 8 in
	let byte = Array.get t byte_index in
	let shifted = 1 lsl bit_index in
	let byte_new =
		if bool
		then byte lor shifted
		else byte land ((lnot shifted) land 0xFF)
	in
	Array.set t byte_index byte_new

let get t index =
	let byte_index = index / 8 in
	let bit_index = index mod 8 in
	let byte = Array.get t byte_index in
	let shifted = byte lsr bit_index in
	if (shifted land 1) = 0
	then false
	else true

