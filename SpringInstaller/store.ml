(*************************************************************************)
(* spring-installer: GUI tools for installing Spring mods/maps           *)
(* Copyright (C) 2009 Chris Clearwater                                   *)
(*                                                                       *)
(* This program is free software: you can redistribute it and/or modify  *)
(* it under the terms of the GNU General Public License as published by  *)
(* the Free Software Foundation, either version 3 of the License, or     *)
(* (at your option) any later version.                                   *)
(*                                                                       *)
(* This program is distributed in the hope that it will be useful,       *)
(* but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(* GNU General Public License for more details.                          *)
(*                                                                       *)
(* You should have received a copy of the GNU General Public License     *)
(* along with this program.  If not, see <http://www.gnu.org/licenses/>. *)
(*************************************************************************)

open ExtString
exception Error

module Entry = struct
  let make pool_dir digest name size compressed_size =
    let hex = Hex.encode digest in
    let path = Filename.concat pool_dir hex in
    let gz_path = Printf.sprintf "%s.gz" path in
  object (self)
    method compressed_size = compressed_size
    method name = name
    method size = size
    method cat f =
      let in_gzip = Gzip.open_in gz_path in
      let string = String.create 4096 in

      let rec loop () =
        let read = Gzip.input in_gzip string 0 (String.length string) in
         if read = 0 then
          ()
        else
          (f string 0 read;
           loop ()) in
    
      loop ();
      Gzip.close_in in_gzip
 
    method digest = digest
  end
end  

module In = struct
  let load store_dir rev =
    let revs_dir = Filename.concat store_dir "revs" in
    let pool_dir = Filename.concat store_dir "pool" in
    let path = Filename.concat revs_dir rev in
    let gz_path = Printf.sprintf "%s.gz" path in
    let in_gzip = Gzip.open_in gz_path in
    let in_io = IO.create_in
      ~read:(fun () -> Gzip.input_char in_gzip)
      ~input:(Gzip.input in_gzip)
      ~close:(fun () -> Gzip.close_in in_gzip) in
      
    let rec loop accu =
      try
        let line = IO.read_line in_io in
          match String.nsplit line "," with
              [name; hex; size; compressed_size] ->
                let digest = Hex.decode hex in
                let size = int_of_string size in
                let compressed_size = int_of_string compressed_size in
                let entry = Entry.make pool_dir digest name size compressed_size in
                  loop (entry :: accu)
            | _ -> raise Error
      with
          End_of_file -> accu in
      
    let entries = loop [] in
      IO.close_in in_io;
  object
    method entries = entries
    method unload = ()
  end
end
