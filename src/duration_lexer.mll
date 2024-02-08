{
  open Duration_parser

  let frac = function
    | "" -> 0.
    | f -> float_of_string ("." ^ (String.sub f 1 (String.length f - 1)))
}
let digit = ['0'-'9']
let frac = [',''.']digit+
let n = digit+

rule token = parse
| (n as x) (frac? as f) {X (float_of_string x +. (frac f))}
| 'S' {S}
| 'M' {M}
| 'H' {H}
| 'T' {T}
| 'D' {D}
| 'W' {W}
| 'M' {M}
| 'Y' {Y}
| 'P' {P}
| eof {EOF}
