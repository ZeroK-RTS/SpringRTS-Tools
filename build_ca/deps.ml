open ExtString
module StringSet = Set.Make(String)

let ignored_deps = [
	"Spring Bitmaps"; "Spring Cursors"; "Map Helper v1"; "Spring content v1";
	"TA Content version 2"; "tatextures.sdz"; "TA Textures v0.62";
	"tacontent.sdz"; "springcontent.sdz"; "cursors.sdz"
]

let ignored_set =
	let f accu dep = StringSet.add dep accu in
	List.fold_left f StringSet.empty ignored_deps

let format deps =
	let list = Array.to_list deps in
	let f dep = not (StringSet.mem dep ignored_set) in
	let list = List.filter f list in
	String.join "|" list

let parse deps =
	let deps = String.nsplit deps "|" in
	Array.of_list deps
