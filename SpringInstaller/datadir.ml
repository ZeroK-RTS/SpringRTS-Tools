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

let detect_home_dir () =
  try
    let home_dir = Sys.getenv "HOME" in
    Some home_dir
  with Not_found -> None
    
let detect_springrc list home_dir =
  try
    let springrc = Filename.concat home_dir ".springrc" in
    let in_file = open_in springrc in

    let rec loop option =
      try 
        let line = input_line in_file in
        try
          let (key, value) = String.split line "=" in
          if key = "SpringData" then
            if value <> "" then
              loop (Some value)
            else
              loop option
          else
            loop option
        with
            Invalid_string -> loop option
      with
          End_of_file -> option in

    let option = loop None in
    close_in in_file;

    match option with
        None -> list
      | Some dir -> dir :: list

  with Sys_error _ -> list
    
let detect_etc list home_dir =
  try
    let in_file = open_in "/etc/spring/datadir" in
    let input = IO.input_channel in_file in
    let line = IO.read_line input in
    let dirs = String.nsplit line ":" in
    List.rev_append dirs list
  with Sys_error _ -> list
    

let detect_env list =
  try
    let datadir = Sys.getenv "SPRING_DATADIR" in
    datadir :: list
  with Not_found -> list

let detect_all_dirs () =
  match detect_home_dir () with
      None -> []
    | Some home_dir ->
        let list = [] in
        let list = detect_env list in
        let list = detect_springrc list home_dir in
        let list = "$HOME/.spring" :: list in
        let list = detect_etc list home_dir in

        let f format =
          let (_, dir) = String.replace format "$HOME" home_dir in
          dir in

        List.rev_map f list
    
let detect_writable_dir () =
  let dirs = detect_all_dirs () in
  
  let rec loop dirs =
    match dirs with
        [] -> failwith "Can't detect a writable datadir"
      | dir :: rest ->
          try
            if not (Sys.file_exists dir) then
              Unix.mkdir dir 0o755;
            
            if Sys.is_directory dir then
              (Unix.access dir [Unix.R_OK; Unix.W_OK];
               dir)
            else
              loop rest

          with Unix.Unix_error _ ->
            loop rest in
  
  loop dirs
