let format_int32 int32 =
	let string = String.create 4 in

	let char n =
		let shifted = Int32.shift_right_logical int32 n in
		let masked = Int32.logand shifted 0xFFl in
		Char.chr (Int32.to_int masked)
	in

	string.[0] <- char 24;
	string.[1] <- char 16;
	string.[2] <- char 8;
	string.[3] <- char 0;
	string

let parse_int32 string =
	let byte int32 char n =
		let code = Char.code char in
		let shifted = Int32.shift_left (Int32.of_int code) n in
		Int32.logor int32 shifted
	in

	let int32 = Int32.zero in
	let int32 = byte int32 string.[0] 24 in
	let int32 = byte int32 string.[1] 16 in
	let int32 = byte int32 string.[2] 8 in
	let int32 = byte int32 string.[3] 0 in
	int32

let format_bitarray array =
	let len = Array.length array in
	let string = String.create len in
	let f index char = String.set string index (Char.chr char) in
	Array.iteri f array;
	string

let parse_bitarray string =
	let len = String.length string in
	let array = Array.create len 0 in
	let rec loop index =
		if index != len
		then begin
			let char = String.get string index in
			Array.set array index (Char.code char);
			loop (index + 1)
		end
	in
	loop 0;
	array

