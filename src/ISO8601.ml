module Lexer = ISO8601_lexer

module Permissive = struct

    let date_lex lexbuf = Lexer.date lexbuf

    let time_lex lexbuf =
      let t = Lexer.time lexbuf in
      match Lexer.timezone lexbuf with None -> t | Some o -> t +. o

    let datetime_lex ?(reqtime=true) lexbuf =
      let d = Lexer.date lexbuf in
      match Lexer.delim lexbuf with
      | Some _ -> d +. Lexer.time lexbuf
      | _      -> if reqtime then assert false else d

    let date s = date_lex (Lexing.from_string s)
    let time s = time_lex (Lexing.from_string s)
    let datetime ?(reqtime=true) s =
      datetime_lex ~reqtime:reqtime (Lexing.from_string s)

end
