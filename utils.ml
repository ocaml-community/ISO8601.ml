let local_offset = fst (Unix.mktime (Unix.gmtime 0.))

let mkdatetime y m d h mi s =
  ({ Unix.tm_sec = s ; tm_min = mi ; tm_hour = h ;
     tm_wday = -1 ; tm_yday = -1 ;tm_isdst = false ;
     tm_mday = d ;
     tm_mon = m - 1 ;
     tm_year = y - 1900 ; }
   |> Unix.mktime
   |> fst) -. local_offset

let mkdate y m d = mkdatetime y m d 0 0 0

let mktime h m s = h *. 3600. +. m *. 60. +. s
