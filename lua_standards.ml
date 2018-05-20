open ExtString

let iter_entries f root =
  let rec loop root path =
    let full_path = Filename.concat root path in
      match (Unix.stat full_path).Unix.st_kind with
          Unix.S_REG -> f full_path
        | Unix.S_DIR ->
	    if (String.compare path ".svn" != 0) then
	      Array.iter (loop full_path) (Sys.readdir full_path)
        | _ -> ()
  in
    loop root ""

let replace_newlines string length =
  let rec loop0 pop_pos push_pos =
    if pop_pos = length then
      push_pos
    else
      let pop_char = string.[pop_pos] in
	if pop_char = '\r' then
	  loop1 (pop_pos+1) push_pos
	else
	  (string.[push_pos] <- pop_char;
	   loop0 (pop_pos+1) (push_pos+1))
  and loop1 pop_pos push_pos =
    if pop_pos = length then
      (string.[push_pos] <- '\n';
       push_pos+1)
    else
      let pop_char = string.[pop_pos] in
	if pop_char = '\n' then
	  (string.[push_pos] <- '\n';
	   loop0 (pop_pos+1) (push_pos+1))
	else
	  (string.[push_pos] <- '\n';
	   loop0 (pop_pos) (push_pos+1))
  in
    loop0 0 0

let read path =
  let string = String.create 4096 in
  let buffer = Buffer.create 4096 in
  let in_chan = open_in_bin path in
    
  let rec f () =
    let n = input in_chan string 0 (String.length string) in
      if n = 0 then
        ()
      else
        begin
          Buffer.add_substring buffer string 0 n;
          f ()
        end in
    
    f ();
    close_in in_chan;
    Buffer.contents buffer

let set_props path =
  let keywords = Printf.sprintf "svn propset svn:keywords Id %s" path in
  let eol_style = Printf.sprintf "svn propset svn:eol-style native %s" path in
    ignore (Unix.system keywords);
    ignore (Unix.system eol_style)

let add_id_if_not_exists path out_chan =
  let in_chan = open_in path in
  let line = input_line in_chan in
    if String.exists line "$Id" then
      ()
    else
      output_string out_chan "-- $Id$\n";
    close_in in_chan

let handle_file path =
  if String.ends_with path ".lua" then
    let temp_path = Printf.sprintf "%s.idify" path in
    let data = read path in
    let length = replace_newlines data (String.length data) in
    let out_chan = open_out_bin temp_path in
      add_id_if_not_exists path out_chan;
      output out_chan data 0 length;
      close_out out_chan;
      Unix.rename temp_path path;
      set_props path
  else
    ()

let () = iter_entries handle_file Sys.argv.(1)
