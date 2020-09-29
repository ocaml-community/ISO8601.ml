let with_utc f =
  let old = try Unix.getenv "TZ" with Not_found -> "" in
  Unix.putenv "TZ" "UTC";
  try
    let x = f() in
    Unix.putenv "TZ" old;
    x
  with e ->
    Unix.putenv "TZ" old;
    raise e

let local_offset = fst (Unix.mktime (Unix.gmtime 0.))

let mkdatetime y m d h mi s =
  let t, _tm =
    with_utc (fun () ->
        Unix.mktime
          { Unix.tm_sec = s ; tm_min = mi ; tm_hour = h ;
            tm_wday = -1 ; tm_yday = -1 ; tm_isdst = false ;
            tm_mday = d ;
            tm_mon = m - 1 ;
            tm_year = y - 1900 ; })
  in
  t

(*
let mkdatetime y m d h mi s =
  let t, _tm =
    Unix.mktime { Unix.tm_sec = s ; tm_min = mi ; tm_hour = h ;
                  tm_wday = -1 ; tm_yday = -1 ; tm_isdst = false ;
                  tm_mday = d ;
                  tm_mon = m - 1 ;
                  tm_year = y - 1900 ; } in
  let t', _ = Unix.mktime (Unix.gmtime t) in
  let local_unix_time = t -. (t' -. t) in
  fst Unix.(mktime (gmtime local_unix_time))
  (*   t -. local_offset +. (if tm.Unix.tm_isdst then 3600. else 0.) *)
   *)

let mkdate y m d = mkdatetime y m d 0 0 0

let mktime h m s = h *. 3600. +. m *. 60. +. s
