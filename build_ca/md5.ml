type t

external create : unit -> t = "ml_md5_create"
external update : t -> string -> unit = "ml_md5_update"
external final : t -> string = "ml_md5_final"

let of_string s =
	let md5 = create () in
	update md5 s;
	final md5

