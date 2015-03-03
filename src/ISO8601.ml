module Lexer = ISO8601_lexer

module Permissive = struct

    let date_lex lexbuf = Lexer.date lexbuf

    let time_tz_lex lexbuf =
      let t = Lexer.time lexbuf in
      let tz = Lexer.timezone lexbuf in
      let t = match tz with None -> t | Some o -> t -. o in
      (t, tz)

    let datetime_tz_lex ?(reqtime=true) lexbuf =
      let d = date_lex lexbuf in
      match Lexer.delim lexbuf with
      | None -> if reqtime then assert false else (d, None)
      | Some _ -> let (t, tz) = time_tz_lex lexbuf in
                  (d +. t, tz)

    let time_lex lexbuf =
      fst (time_tz_lex lexbuf)

    let datetime_lex ?(reqtime=true) lexbuf =
      fst (datetime_tz_lex ~reqtime:reqtime lexbuf)

    let date s = date_lex (Lexing.from_string s)

    let time s = time_lex (Lexing.from_string s)

    let time_tz s = time_tz_lex (Lexing.from_string s)

    let datetime_tz ?(reqtime=true) s =
      datetime_tz_lex ~reqtime:reqtime (Lexing.from_string s)

    let datetime ?(reqtime=true) s =
      datetime_lex ~reqtime:reqtime (Lexing.from_string s)

    let pp_date fmt x =
      let open Unix in
      let x = gmtime x in
      Format.fprintf fmt "%04d-%02d-%02d"
                     (x.tm_year + 1900) (x.tm_mon + 1) x.tm_mday

    let pp_time_tz_aux t tz =
      let (t, tz) =
        match tz with
        | None -> (t, "")
        | Some 0. -> (t, "Z")
        | Some x -> (t -. x, Format.sprintf "%2.0f:%2.0f"
                                            (x /. 3600.)
                                            (abs_float (x /. 60.))) in
      (Unix.gmtime t, tz)

    let pp_time ?(tz=None) fmt x =
      let open Unix in
      let (x, tz) = pp_time_tz_aux x tz in
      Format.fprintf fmt "%02d:%02d:%02d%s"
                     x.tm_hour x.tm_min x.tm_sec tz

    let pp_datetime ?(tz=None) fmt  x =
      let open Unix in
      let (x, tz) = pp_time_tz_aux x tz in
      Format.fprintf fmt "%04d-%02d-%02dT%02d:%02d:%02d%s"
                     (x.tm_year + 1900) (x.tm_mon + 1) x.tm_mday
                     x.tm_hour x.tm_min x.tm_sec tz

    let string_of_aux printer x =
      ignore (Format.flush_str_formatter ()) ;
      printer Format.str_formatter x ;
      Format.flush_str_formatter ()

    let string_of_date = string_of_aux pp_date

    let string_of_time ?(tz=None) = string_of_aux (pp_time ~tz:tz)

    let string_of_datetime ?(tz=None) = string_of_aux (pp_datetime ~tz:tz)

end
