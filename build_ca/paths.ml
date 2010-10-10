type t = {
	store: string;
	tmp: string;
	pool: string;
	packages: string;
	last: string;
	deps: string;
	builds: string;
	log: string;
}

let create store_path = {
	store = store_path;
	tmp = Filename.concat store_path "tmp";
	pool = Filename.concat store_path "pool";
	packages = Filename.concat store_path "packages";
	last = Filename.concat store_path "last";
	deps = Filename.concat store_path "deps";
	builds = Filename.concat store_path "builds";
	log = Filename.concat store_path "log";
}

let store t = t.store
let tmp t = t.tmp
let pool t = t.pool
let packages t = t.packages
let last t = t.last
let deps t = t.deps
let builds t = t.builds
let log t = t.log

let pool_file t digest =
	let hex = Hex.encode digest in
	let prefix = String.sub hex 0 2 in
	let postfix = String.sub hex 2 30 in
	let prefix_path = Filename.concat t.pool prefix in
	let path = Filename.concat prefix_path postfix in
	let gz_path = Printf.sprintf "%s.gz" path in
	gz_path

let temp t = Temp.file t.tmp
let concat t f s = Filename.concat (f t) s

let last_modinfo paths modinfo =
	let digest = Md5.of_string modinfo in
	let hex = Hex.encode digest in
	concat paths last hex

let sdp t digest =
	let hex = Hex.encode digest in
	let basename = Printf.sprintf "%s.sdp" hex in
	concat t packages basename

let log t prefix =
	let basename = Printf.sprintf "%s.txt" prefix in
	concat t log basename

let dep t digest =
	let hex = Hex.encode digest in
	let basename = Printf.sprintf "%s.gz" hex in
	concat t deps basename

let build t prefix version =
	let version = Pcre.replace ~pat:(Pcre.quote " ") ~templ:"_" version in
	let basename = Printf.sprintf "%s-%s.sdz" prefix version in
	concat t builds basename

let init t =
	let mkdir_if_not_exists dir =
		if not (Sys.file_exists dir)
		then Unix.mkdir dir 0o755
	in
	mkdir_if_not_exists t.store;
	mkdir_if_not_exists t.tmp;
	mkdir_if_not_exists t.packages;
	mkdir_if_not_exists t.pool;
	mkdir_if_not_exists t.last;
	mkdir_if_not_exists t.deps;
	mkdir_if_not_exists t.builds;
	mkdir_if_not_exists t.log;

	(* Create pool hex subdirs *)
	let f x y =
		let s = Printf.sprintf "%c%c" x y in
		let path = concat t pool s in
		mkdir_if_not_exists path
	in
	let hex = "0123456789abcdef" in
	String.iter (fun x -> String.iter (fun y -> f x y) hex) hex

