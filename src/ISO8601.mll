{}

let num = ['0'-'9']
let year = num num num num
let year_ext = ['+''-'] num year
let month = ('0'num) | ('1'['0'-'2'])
let day = (['0'-'2']num) | ('3'['0''1'])

(* FIXME: 00 should not be allowed *)
let week = ('0'num) | (['1'-'4']num) | ('5'['0'-'3'])

let week_day = ['1'-'7']
let hour = (['0'-'1']num) | ('2'['0'-'4'])
let minute = (['0'-'5']num)
let second = (['0'-'5']num) | '6''0' ([',''.']num+)?

(* FIXME: 000 should not be allowed *)
let year_day = (['0'-'2'] num num) | ('3' (['0'-'5'] num | '6' ['0'-'6']))

rule date = parse

(* YYYY / ±YYYYY *)
| (year | year_ext) as y
  {}

(* YYYY-MM *)
| (year as y) '-' (month as m)
  {}

(* YYYYMMDD / YYYY-MM-DD *)
| ((year as y) (month as m) (day as d))
| ((year as y) '-' (month as m) '-' (day as d))
  {}

(* YYYYWww / YYYY-Www *)
| (year as y) 'W' (week as w)
| (year as y) "-W" (week as w)
  {}

(* YYYYWwwD / YYYY-Www-D *)
| (year as y) 'W' (week as w) (week_day as d)
| (year as y) '-' 'W' (week as w) '-' (week_day as d)
  {}

(* YYYYDDD / YYYY-DDD *)
| (year as y) (year_day as d)
| (year as y) '-' (year_day as d)
  {}

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
