module Lexer = ISO8601_lexer

module Permissive = struct

    let date_lex lexbuf = Lexer.date lexbuf

    let time_lex lexbuf =
      let t = Lexer.time lexbuf in
      match Lexer.timezone lexbuf with None -> t | Some o -> t -. o

    let datetime_lex ?(reqtime=true) lexbuf =
      let d = Lexer.date lexbuf in
      match Lexer.delim lexbuf with
      | Some _ -> d +. Lexer.time lexbuf
      | _      -> if reqtime then assert false else d

    let date s = date_lex (Lexing.from_string s)
    let time s = time_lex (Lexing.from_string s)
    let datetime ?(reqtime=true) s =
      datetime_lex ~reqtime:reqtime (Lexing.from_string s)

    let pp_date fmt x =
      let open Unix in
      let x = gmtime x in
      Format.fprintf fmt "%04d%02d-%02d"
                     (x.tm_year + 1900) (x.tm_mon + 1) x.tm_mday

    let pp_time fmt x =
      let open Unix in
      let x = gmtime x in
      Format.fprintf fmt "%02d:%02d:%02dZ"
                     x.tm_hour x.tm_min x.tm_sec

    let pp_datetime fmt x =
      let open Unix in
      let x = gmtime x in
      Format.fprintf fmt "%04d%02d-%02dT%02d:%02d:%02dZ"
                     (x.tm_year + 1900) (x.tm_mon + 1) x.tm_mday
                     x.tm_hour x.tm_min x.tm_sec

    let string_of_aux printer x =
      ignore (Format.flush_str_formatter ()) ;
      printer Format.str_formatter x ;
      Format.flush_str_formatter ()

    let string_of_date = string_of_aux pp_date

    let string_of_time = string_of_aux pp_time

    let string_of_datetime = string_of_aux pp_datetime

end
