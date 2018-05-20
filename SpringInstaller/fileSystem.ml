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

let fold_left f accu in_chan block_size =
  let string = String.create block_size in

  let rec loop accu =
    let n = input in_chan string 0 block_size in
      if n = 0 then
        accu
      else
        loop (f accu string n) in    

    loop accu
        
let copy src dst =
  let in_chan = open_in_bin src in
  let out_chan = open_out_bin dst in
  let f () string n = output out_chan string 0 n in
    fold_left f () in_chan 4096;
    close_in in_chan;
    close_out out_chan
      
let read src =
  let in_chan = open_in_bin src in
  let buffer = Buffer.create 4096 in
  let f () string n = Buffer.add_substring buffer string 0 n in
    fold_left f () in_chan 4096;
    close_in in_chan;
    Buffer.contents buffer
    
let move src dst =
  if src != dst then
    try
      Sys.rename src dst
    with Sys_error _ ->
      copy src dst;
      Sys.remove src
  else
    ()

let size path = (Unix.stat path).Unix.st_size

let make_dir path =
  if Sys.file_exists path then
    if Sys.is_directory path then
      ()
    else
      raise (Sys_error 
               (Printf.sprintf
                  "Error creating directory %s: File exists but is not a directory"
                  path))
  else
    try
      Unix.mkdir path 0o755;
    with
        Unix.Unix_error (error, _, _) ->
          raise (Sys_error
                   (Printf.sprintf
                      "Error creating directory %s: %s"
                      path
                      (Unix.error_message error)))

module Base64 = struct
  let encoding_table =
    [|'A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L';'M';'N';'O';'P';'Q';'R';
      'S';'T';'U';'V';'W';'X';'Y';'Z';'a';'b';'c';'d';'e';'f';'g';'h';'i';'j';
      'k';'l';'m';'n';'o';'p';'q';'r';'s';'t';'u';'v';'w';'x';'y';'z';'0';'1';
      '2';'3';'4';'5';'6';'7';'8';'9';'-';'_'|]
      
  let decoding_table = Base64.make_decoding_table encoding_table
    
  let encode string =
    Base64.str_encode ~tbl:encoding_table string
      
  let decode string =
    Base64.str_decode ~tbl:decoding_table string
end
