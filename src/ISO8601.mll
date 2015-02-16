{

  (* Unix module says t0 is 1970-01-01T00:00:00  *)

  (* Final unit required to use only optional arguments. *)
  let ymd_hms_hm
        ?(y=1970) ?(m=1) ?(d=1)
        ?(h=0) ?(mi=0) ?(s=0)
        ?(oh=0) ?(om=0)
      : unit -> float =
    fun () ->
    {
      Unix.tm_sec = s ;
      tm_min = mi + om ;
      tm_hour = h + oh ;
      tm_mday = d ;
      tm_mon = m - 1 ;
      tm_year = y - 1900 ;
      tm_wday = -1 ;
      tm_yday = -1 ;
      tm_isdst = false ;
    }
    |> Unix.mktime
    |> fst

  let int = int_of_string

  let ymd y m d = ymd_hms_hm ~y:(int y) ~m:(int m) ~d:(int d) ()
  let ym y m = ymd_hms_hm ~y:(int y) ~m:(int m) ()
  let y x = ymd_hms_hm ~y:(int x) ()

  let yd y d = ymd_hms_hm ~y:(int y) ~d:(int d) ()

}

(* FIXME: Some 0 values should not be allowed. *)

let num = ['0'-'9']
let year = num num num num
let year_ext = ['+''-'] num year
let month = ('0'num) | ('1'['0'-'2'])
let day = (['0'-'2']num) | ('3'['0''1'])
let week = ('0'num) | (['1'-'4']num) | ('5'['0'-'3'])
let week_day = ['1'-'7']
let hour = (['0'-'1']num) | ('2'['0'-'4'])
let minute = (['0'-'5']num)
let second = (['0'-'5']num) | '6''0' ([',''.']num+)?
let year_day = (['0'-'2'] num num) | ('3' (['0'-'5'] num | '6' ['0'-'6']))

rule date = parse

(* YYYY / ±YYYYY *)
| (year | year_ext) as x
  { y x }

(* YYYY-MM *)
| (year as y) '-' (month as m)
  { ym y m }

(* YYYYMMDD / YYYY-MM-DD *)
| ((year as y) (month as m) (day as d))
| ((year as y) '-' (month as m) '-' (day as d))
  { ymd y m d}

(* YYYYWww / YYYY-Www *)
| (year as y) 'W' (week as w)
| (year as y) "-W" (week as w)
  { assert false }

(* YYYYWwwD / YYYY-Www-D *)
| (year as y) 'W' (week as w) (week_day as d)
| (year as y) '-' 'W' (week as w) '-' (week_day as d)
  { assert false }

(* YYYYDDD / YYYY-DDD *)
| (year as y) (year_day as d)
| (year as y) '-' (year_day as d)
  { yd y d }

and time = parse

(* hhmmss / hh:mm:ss *)
| (hour as h) (minute as m) (second as s)
| (hour as h) ':' (minute as m) ':' (second as s)
  {}

(* hhmm / hh:mm *)
| (hour as h) ':'? (minute as m)
  {}

(* hh *)
| hour as h
  {}

and timezone = parse

(* Z *)
| 'Z'
  {}

(* ±hhmm / ±hh:mm *)
| (['+''-'] as sign) (hour as h) ':'? (minute as m)
  {}

(* ±hh *)
| (['+''-'] as sign) (hour as h)
  {}

{}
