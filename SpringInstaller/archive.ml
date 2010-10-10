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
exception Error of string
  
type kind = Mod | Map | Unknown
    
let load path =
  try
    if String.ends_with path ".sdz" then
      Sdz.In.load path
    else if String.ends_with path ".sd7" then
      Sd7.In.load path
    else
      raise (Error (Printf.sprintf "Unknown archive type: %s" path))
  with
      Zip.Error (path, _, s) -> raise (Error (Printf.sprintf "%s: %s" path s))
    | Sevenzip.Error s -> raise (Error (Printf.sprintf "%s: %s" path s))
    | Sys_error s -> raise (Error s)      
      
let detect_kind path =
  let archive = load path in
  let entries = archive#entries in

  let test_files func =
    let f entry = func (String.lowercase entry#name) in
      List.exists f entries in

  let is_map path =
    let dirname = Filename.dirname path in
    let basename = Filename.basename path in
      if dirname = "maps" then
        if String.ends_with basename ".smf" then
          true
        else if String.ends_with basename ".sm3" then
          true
        else
          false
      else
        false in
    
    archive#unload;
    if test_files is_map then Map
    else if test_files (fun filename -> filename = "modinfo.tdf") then Mod
    else if test_files (fun filename -> filename = "modinfo.lua") then Mod
    else Unknown

