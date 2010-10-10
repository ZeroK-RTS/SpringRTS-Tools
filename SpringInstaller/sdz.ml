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

module Entry = struct
  let make zip entry = object (self)
    method name = entry.Zip.filename
    method size = entry.Zip.uncompressed_size
    method read = Zip.read_entry zip entry
    method digest = Digest.string self#read
  end
end  

module In = struct

  let make zip path = object
    method unload = Zip.close_in zip
      
    method entries =
      let combine entries entry =
        if entry.Zip.is_directory then
          entries
        else
          (Entry.make zip entry) :: entries
      in
        List.fold_left combine [] (Zip.entries zip)
          
    method path = path
  end
    
  let load path =
    let zip = Zip.open_in path in
      make zip path
end

module Out = struct

  let make zip = object
    method unload = Zip.close_out zip
      
    method add_entry entry =
      let filename = entry#name in
      let (write, close) = Zip.add_entry_generator zip filename in
      entry#cat write;
      close ()
  end
          
  let load path =
    let zip = Zip.open_out path in
      make zip
      
end
