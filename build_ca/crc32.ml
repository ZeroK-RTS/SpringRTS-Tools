type t

external init : unit -> unit = "ml_crc32_init"
external create : unit -> t = "ml_crc32_create"
external update : t -> string -> unit = "ml_crc32_update"
external update_int32 : t -> int32 -> unit = "ml_crc32_update_int32"
external final : t -> int32 = "ml_crc32_final"

let () = init ()
