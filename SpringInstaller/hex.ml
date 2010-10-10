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

exception Error

let decode hex =
  let length = String.length hex in
  let div = length / 2 in
  let rem = length mod 2 in
    if rem = 0 then
      let string = String.create div in
        
      let to_int char =
        match char with
            '0' -> 0
          | '1' -> 1
          | '2' -> 2
          | '3' -> 3
          | '4' -> 4
          | '5' -> 5
          | '6' -> 6
          | '7' -> 7
          | '8' -> 8
          | '9' -> 9
          | 'a' -> 10
          | 'b' -> 11
          | 'c' -> 12
          | 'd' -> 13
          | 'e' -> 14
          | 'f' -> 15
          | _ -> raise Error in
        
      let rec loop index length =
        if length = 0 then
          ()
        else
          let a = hex.[index * 2] in
          let b = hex.[index * 2 + 1] in
          let a' = to_int a in
          let b' = to_int b in
          let code = a' * 16 + b' in
          let char = Char.chr code in
            String.set string index char;
            loop (index + 1) (length - 1) in
        
        loop 0 div;
        string
    else
      raise Error
        
let encode binary =
  let length = String.length binary in
  let mul = length * 2 in
  let string = String.create mul in

  let to_char int =
    match int with
        0 -> '0'
      | 1 -> '1'
      | 2 -> '2'
      | 3 -> '3'
      | 4 -> '4'
      | 5 -> '5'
      | 6 -> '6'
      | 7 -> '7'
      | 8 -> '8'
      | 9 -> '9'
      | 10 -> 'a'
      | 11 -> 'b'
      | 12 -> 'c'
      | 13 -> 'd'
      | 14 -> 'e'
      | 15 -> 'f'
      | _ -> raise Error in

  let rec loop index length =
    if length = 0 then
      ()
    else
      let char = binary.[index] in
      let code = Char.code char in
      let a = code / 16 in
      let b = code mod 16 in
        string.[index * 2] <- (to_char a);
        string.[index * 2 + 1] <- (to_char b);
        loop (index + 1) (length - 1) in
    
    loop 0 length;
    string
