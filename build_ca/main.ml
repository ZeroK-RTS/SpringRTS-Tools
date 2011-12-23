open ExtString

let main svn_root log_root modinfo store_path current_rev prefix =
	let paths = Paths.create store_path in
	Paths.init paths;
	let _ = Unix.umask 0o0002 in

	let svn_path = Filename.dirname modinfo in
	let modinfo_base = Filename.basename modinfo in
	let modinfo_path = Printf.sprintf "%s/%s" svn_root modinfo in
	let svn_mod_path = Printf.sprintf "%s/%s" svn_root svn_path in
	let current_rev = int_of_string current_rev in

	let entries, summaries =
		match Last.get paths modinfo with
		| None ->
			Printf.printf "Unable to perform incrmental update.\n";
			flush stdout;
			let entries = Store.create paths in
			let summaries = Svn.summarize svn_root 0 svn_mod_path current_rev in
			entries, summaries
		| Some(latest_rev, digest) -> 
			Printf.printf "Performing incremental update from %d to %d\n" latest_rev current_rev;
			flush stdout;
			let entries = Store.load paths digest in
			let summaries = Svn.summarize svn_mod_path latest_rev svn_mod_path current_rev in
			entries, summaries
	in

	let add store name =
		let full_path = Printf.sprintf "%s/%s" svn_mod_path name in
		let out_pool = Store.open_pool store name in
		let write data = Store.write_pool out_pool data in
		Svn.cat full_path current_rev write;
		Store.close_pool out_pool
	in

	let handle_summary summary =
		match summary.Svn.summarize_kind, summary.Svn.node_kind with
		| `Added, `File ->
			Printf.printf "A\t%s\n" summary.Svn.path;
			flush stdout;
			add entries summary.Svn.path
						
		| `Modified, `File ->
			Printf.printf "M\t%s\n" summary.Svn.path;
			flush stdout;
			add entries summary.Svn.path
					
		| `Deleted, `File ->
			Printf.printf "D\t%s\n" summary.Svn.path;
			flush stdout;
			Store.remove entries summary.Svn.path
						
		| `Deleted, `Dir ->
			Printf.printf "D\t%s/\n" summary.Svn.path;
			flush stdout;
			Store.remove_dir entries summary.Svn.path
						
		| `Normal, `File ->
			if not summary.Svn.prop_changed
			then begin
				Printf.printf "P\t%s\n" summary.Svn.path;
				flush stdout;
				add entries summary.Svn.path
			end

		| _ -> ()
	in	
	List.iter handle_summary summaries;

	let log = Svn.log svn_root log_root current_rev in

	let branch, version, make_zip =
		try
			let m = Pcre.extract ~pat:"^VERSION{([^}]+)}" log.Svn.message in
			"stable", m.(1), true
		with
		| Not_found -> begin
			if Pcre.pmatch ~pat:"^STABLE" log.Svn.message
			then "stable", (Printf.sprintf "stable-%d" current_rev), true
			else "test", (Printf.sprintf "test-%d" current_rev), false
		end

	in

	let buffer = Buffer.create 65536 in
	let write_modinfo string = Buffer.add_string buffer string in
	Svn.cat modinfo_path current_rev write_modinfo;
	let modinfo_data = Buffer.contents buffer in
	let modinfo_data = Pcre.replace ~pat:(Pcre.quote "$VERSION") ~templ:version modinfo_data in

	let out_pool = Store.open_pool entries modinfo_base in
	Store.write_pool out_pool modinfo_data;
	Store.close_pool out_pool;
	let digest = Store.md5_hash entries in
	let hex = Hex.encode digest in

	Last.save paths modinfo current_rev digest;

	let versions = Versions.load paths in
	let rev_branch = Printf.sprintf "%s:revision:%d" prefix current_rev in
	let versions = Versions.add versions rev_branch hex entries.Store.depends entries.Store.modname in
	let tag_branch = Printf.sprintf "%s:%s" prefix branch in
	let versions = Versions.add versions tag_branch hex entries.Store.depends entries.Store.modname in
	Versions.write paths versions;

	Store.write entries;

	let logpath = Paths.log paths prefix in
	let logfile = open_out_gen [Open_append; Open_creat] 0o644 logpath in
	let header = Printf.sprintf "r%d | %s | %s" current_rev log.Svn.author log.Svn.date in
	let sep = String.make (String.length header) '-' in
	Printf.fprintf logfile "%s\n" header;
	Printf.fprintf logfile "%s\n" sep;
	Printf.fprintf logfile "%s\n\n" log.Svn.message;
	close_out logfile;

	if make_zip
	then begin
		let output = Paths.build paths prefix version in
		Printf.printf "Generating zip file: %s\n" output;
		flush stdout;
		Sdz.make paths digest output;
		let command = Printf.sprintf "/home/packages/build_ca/upload.py %s %s %s" output hex tag_branch in
		let status = Unix.system command in
		match status with
		| Unix.WEXITED 0 -> ()
		| Unix.WEXITED n -> Printf.printf "upload.py exited abnormally, error code: %d" n
		| _ -> ()
	end
		
		
let () = main Sys.argv.(1) Sys.argv.(2) Sys.argv.(3) Sys.argv.(4) Sys.argv.(5) Sys.argv.(6)


