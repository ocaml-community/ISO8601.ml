module Permissive : sig

    (** {2 Date parsing}

        [date], [time] and [datetime] parse a [string] and return the
        corresponding timestamp (as [float]).

        For each of these functions, a [_lex] suffixed function read
        from a [Lexing.lexbuf] instead of a [string].

        [datetime] functions also take an optional boolean [reqtime]
        indicating if parsing must fail if a date is given and not
        a complete datetime. (Default is true).
     *)

    val date_lex : Lexing.lexbuf -> float
    val time_lex : Lexing.lexbuf -> float
    val datetime_lex : ?reqtime:bool -> Lexing.lexbuf -> float

    val date : string -> float
    val time : string -> float
    val datetime : ?reqtime:bool -> string -> float


    (** {2 Printing functions}

        [pp_X] functions will take a [Format.formatter] to
        print the representation of a [X].

        [string_of_X] functions return a string representation
        of a [X].

        [X] define the format used:
        - date: [ YYYY-MM-DD ]
        - time: [ hh:mm:ssZ ]
        - datetime: [ YYYY-MM-DDThh:mm:ssZ ]
     *)

    val pp_date : Format.formatter -> float -> unit
    val pp_time : Format.formatter -> float -> unit
    val pp_datetime : Format.formatter -> float -> unit

    val string_of_date : float -> string
    val string_of_time : float -> string
    val string_of_datetime : float -> string

end
