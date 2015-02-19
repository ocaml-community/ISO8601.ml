(** {2 ISO 8601 and RFC 3339 parsing and printing} *)

module Permissive : sig

    (** {2 Date parsing}

        [date], [time] and [datetime] parse a [string] and return the
        corresponding timestamp (as [float]).

        Times are {b always} converted to UTC representation.

        For each of these functions, a [_lex] suffixed function read
        from a [Lexing.lexbuf] instead of a [string].

        [datetime] functions also take an optional boolean [reqtime]
        indicating if parsing must fail if a date is given and not
        a complete datetime. (Default is true).

        Functions with [_tz] in their name return a [float * float option]
        representing [timestamp * offset option (timezone)]. [timestamp]
        will be the UTC time, and [offset option] is just an information
        about the original timezone.
     *)

    val date_lex : Lexing.lexbuf -> float
    val time_lex : Lexing.lexbuf -> float
    val datetime_lex : ?reqtime:bool -> Lexing.lexbuf -> float

    val time_tz_lex : Lexing.lexbuf -> (float * float option)
    val datetime_tz_lex : ?reqtime:bool -> Lexing.lexbuf -> (float * float option)

    val date : string -> float
    val time : string -> float
    val datetime : ?reqtime:bool -> string -> float

    val time_tz : string -> (float * float option)
    val datetime_tz : ?reqtime:bool -> string -> (float * float option)

    (** {2 Printing functions}

        [pp_X] functions will take a [Format.formatter] to
        print the representation of a [X].

        [string_of_X] functions return a string representation
        of a [X].

        Times relative function take an optionnal timezone argument.

        [X] define the format used:
        - date: [ YYYY-MM-DD ]
        - time: [ hh:mm:ss ]
        - datetime: [ YYYY-MM-DDThh:mm:ss ]

        {b NB: fractionnal part of timestamps will be lost when printing
         with current implementation.}
     *)

    val pp_date : Format.formatter -> float -> unit
    val pp_time : ?tz:float option -> Format.formatter -> float -> unit
    val pp_datetime : ?tz:float option -> Format.formatter -> float -> unit

    val string_of_date : float -> string
    val string_of_time : ?tz:float option -> float -> string
    val string_of_datetime : ?tz:float option -> float -> string

end
