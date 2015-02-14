{}

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

rule date = parse

(* YYYY *)
| year
  {}

(* ±YYYYY *)
| year_ext
  {}

(* YYYYMMDD *)
| year month day
  {}

(* YYYY-MM-DD *)
| year '-' month '-' day
  {}

(* YYYY-MM *)
| year '-' month
  {}

(* YYYY-Www *)
| year "-W" week
  {}

(* YYYYWww *)
| year 'W' week
  {}

(* YYYY-Www-D *)
| year '-' 'W' week '-' week_day
  {}

(* YYYYWwwD *)
| year 'W' week week_day
  {}

and time = parse

(* hh:mm:ss *)
| hour ':' minute ':' second
  {}

(* hhmmss *)
| hour minute second
  {}

(* hh:mm *)
| hour ':' minute
  {}

(* hhmm *)
| hour minute
  {}

(* hh *)
| hour
  {}

and timezone = parse

(* Z *)
| 'Z'
  {}

(* ±hh:mm *)
| ['+''-'] hour ':' minute
  {}

(* ±hhmm *)
| ['+''-'] hour minute
  {}

(* ±hh *)
| ['+''-'] hour
  {}

{}
