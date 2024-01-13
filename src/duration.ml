type date = Duration_type.date = {
  year : float;
  month : float;
  day : float;
  hour : float;
  minute : float;
  second : float;
}

type t = Duration_type.t = Week of float | Date of date

let date_zero = Duration_type.zero
let is_zero = function Date d -> d = date_zero | Week i -> i = 0.

let pp fmt d =
  let aux fmt (f, c) =
    (* don't print if 0 *)
    if f = 0. then ()
    else if Float.is_integer f then Format.fprintf fmt "%d%c" (int_of_float f) c
    else
      (* TODO rm trailing zeros (%g can use scientific notation on big number) *)
      Format.fprintf fmt "%f%c" f c
  in
  match d with
  | Week f -> Format.fprintf fmt "P%a" aux (f, 'W')
  | Date d ->
      if d.hour <> 0. || d.minute <> 0. || d.second <> 0. then
        Format.fprintf fmt "P%a%a%aT%a%a%a" aux (d.year, 'Y') aux (d.month, 'M')
          aux (d.day, 'D') aux (d.hour, 'H') aux (d.minute, 'M') aux (d.second, 'S')
      else if d.year <> 0. || d.month <> 0. || d.day <> 0. then
        Format.fprintf fmt "P%a%a%a" aux (d.year, 'Y') aux (d.month, 'M') aux
          (d.day, 'D')
      else
        (* at least one number and its designator shall be present *)
        Format.fprintf fmt "P0W"

let parse_lex lexbuf = Duration_parser.main Duration_lexer.token lexbuf

let parse s =
  let lexbuf = Lexing.from_string s in
  parse_lex lexbuf

let to_string x =
  (* TODO why?
     use a local buffer, [str_formatter] is not recommended *)
  let buf = Buffer.create 64 in
  let fmt = Format.formatter_of_buffer buf in
  pp fmt x;
  Format.pp_print_flush fmt ();
  Buffer.contents buf
