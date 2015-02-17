module Lexer = ISO8601_lexer

module Permissive = struct

    let date_lex lexbuf = Lexer.date lexbuf

    let time_lex lexbuf =
      let t = Lexer.time lexbuf in
      match Lexer.timezone lexbuf with None -> t | Some o -> t +. o

    let datetime_lex lexbuf =
      let d = Lexer.date lexbuf in
      match Lexer.delim lexbuf with
      | Some _ -> d +. Lexer.time lexbuf
      | _        -> assert false

    let date s = date_lex (Lexing.from_string s)
    let time s = time_lex (Lexing.from_string s)
    let datetime s = datetime_lex (Lexing.from_string s)

end
