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

exception Error of string

external init: unit -> unit = "ml_sevenzip_init"
let () = init ()

type origin = SeekSet | SeekCur | SeekEnd

type readable = {
  read: int -> (string * int);
  seek: int -> origin -> unit
}

type db
type in_file = readable * db

type entry = {
  index: int;
  filename: string;
  uncompressed_size: int;
  is_directory: bool
}

external _open_readable: readable -> db = "ml_sevenzip_open_readable"
let open_readable readable =
  try
    (readable, _open_readable readable)
  with
      Failure s -> raise (Error s)

external _entries: db -> entry array = "ml_sevenzip_entries"
let entries (_, db) = _entries db

let open_in path =
  let file = open_in_bin path in
  let buffer = String.create 65536 in
    
  let read n =
    let length = String.length buffer in
    let n = if n > length then length else n in
    let n = input file buffer 0 n in
      (buffer, n) in
    
  let seek pos origin =
    let pos =
      match origin with
          SeekSet -> pos
        | SeekCur -> (pos_in file) + pos
        | SeekEnd -> (in_channel_length file) + pos in
      seek_in file pos in

    open_readable {read=read; seek=seek}


let close_in t = ()
