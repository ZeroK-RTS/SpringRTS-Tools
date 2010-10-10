external init : unit -> unit = "ml_svn_init"
let () = init ()

type summarize_kind = [`Added | `Deleted | `Modified | `Normal ]
type node_kind = [`None | `File | `Dir | `Unknown]
type summary = {
	path: string;
	summarize_kind: summarize_kind;
	node_kind: node_kind;
	prop_changed: bool
}

type summarize_callback = summary -> unit
external _summarize : string -> int -> string -> int -> summarize_callback -> unit = "ml_svn_client_summarize"

let summarize source_path source_rev dest_path dest_rev = 
	let accu = ref [] in
	let callback summary = accu := summary :: !accu in
	_summarize source_path source_rev dest_path dest_rev callback;
	List.rev !accu

type write_callback = string -> unit
external cat : string -> int -> write_callback -> unit = "ml_svn_client_cat"

type log = {
	author: string;
	date: string;
	message: string;
}

type log_callback = log -> unit
external _log : string -> string -> int -> log_callback -> unit = "ml_svn_client_log"

let log url path revision =
	let log = ref None in
	let f tuple = log := Some tuple in
	_log url path revision f;
	match !log with
	| None -> failwith "No log message"
	| Some tuple -> tuple
