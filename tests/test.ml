(*
 * Copyright (c) 2015 David Sheets <sheets@alum.mit.edu>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

module Tm_struct : Alcotest.TESTABLE with type t = Unix.tm = struct
  type t = Unix.tm

  let pp fmt tm =
    let open Unix in
    let s = Printf.sprintf "%d-%02d-%02dT%02d:%02d:%02d"
        (1900+tm.tm_year) (tm.tm_mon+1) tm.tm_mday
        tm.tm_hour tm.tm_min tm.tm_sec
    in
    Format.pp_print_string fmt s

  let equal a b =
    Unix.(a.tm_sec = b.tm_sec
          && a.tm_min = b.tm_min
          && a.tm_hour = b.tm_hour
          && a.tm_mday = b.tm_mday
          && a.tm_mon = b.tm_mon
          && a.tm_year = b.tm_year)
end

let tm_struct = (module Tm_struct : Alcotest.TESTABLE with type t = Unix.tm)

type hemi = Neg | Pos
type tz = Local | Z | Tz of hemi * int * int

let est = Tz (Neg, 5, 0)
let ist = Tz (Pos, 5, 30)
let vet = Tz (Neg, 4, 30)

let time_tests f = [
  "before_1900",      `Quick, f 1861  9  1 8 0 0 Local;
  "before_epoch",     `Quick, f 1969  1  1 0 0 1 Local;
  "nowish",           `Quick, f 2015 12 27 0 0 1 Local;
  "before_1900_z",    `Quick, f 1861  9  1 8 0 0 Z;
  "before_epoch_z",   `Quick, f 1969  1  1 0 0 1 Z;
  "nowish_z",         `Quick, f 2015 12 27 0 0 1 Z;
  "before_1900_est",  `Quick, f 1861  9  1 8 0 0 est;
  "before_epoch_est", `Quick, f 1969  1  1 0 0 1 est;
  "nowish_est",       `Quick, f 2015 12 27 0 0 1 est;
  "before_1900_ist",  `Quick, f 1861  9  1 8 0 0 ist;
  "before_epoch_ist", `Quick, f 1969  1  1 0 0 1 ist;
  "nowish_ist",       `Quick, f 2015 12 27 0 0 1 ist;
  "before_1900_vet",  `Quick, f 1861  9  1 8 0 0 vet;
  "before_epoch_vet", `Quick, f 1969  1  1 0 0 1 vet;
  "nowish_vet",       `Quick, f 2015 12 27 0 0 1 vet;
]

let fixed_time_tests f = [
  "fixed_unix_time_nowish_utc", `Quick,
  f 1451407335. 0.        "2015-12-29T16:42:15Z";
  "fixed_unix_time_nowish_est", `Quick,
  f 1451407335. (-18000.) "2015-12-29T11:42:15-05:00";
  "fixed_unix_time_nowish_ist", `Quick,
  f 1451407335. 19800.    "2015-12-29T22:12:15+05:30";
  "fixed_unix_time_nowish_vet", `Quick,
  f 1451407335. (-16200.) "2015-12-29T12:12:15-04:30";
]

let str_tm year month day hour minute second tz =
  let str = Printf.sprintf "%d-%02d-%02dT%02d:%02d:%02d%s"
      year month day hour minute second
      (match tz with
       | Local -> ""
       | Z -> "Z"
       | Tz (Neg, hr, mn) -> Printf.sprintf "-%02d:%02d" hr mn
       | Tz (Pos, hr, mn) -> Printf.sprintf "+%02d:%02d" hr mn
      )
  in
  let tm = Unix.({
    tm_sec  = second;
    tm_min  = minute;
    tm_hour = hour;
    tm_mday = day;
    tm_mon  = month - 1;
    tm_year = year - 1900;
    tm_wday = 0;
    tm_yday = 0;
    tm_isdst = false;
  }) in
  let t,  _ = Unix.mktime tm in
  let t', _ = Unix.mktime (Unix.gmtime t) in
  let local_unix_time = t -. (t' -. t) in
  let tm = match tz with
    | Local -> tm
    | Z -> snd Unix.(mktime (gmtime local_unix_time))
    | Tz (Neg, hr, mn) ->
      let t = local_unix_time +. (float_of_int ((hr * 3600) + (mn * 60))) in
      snd Unix.(mktime (gmtime t))
    | Tz (Pos, hr, mn) ->
      let t = local_unix_time -. (float_of_int ((hr * 3600) + (mn * 60))) in
      snd Unix.(mktime (gmtime t))
  in
  (str, tm)

let erange = Unix.Unix_error (Unix.ERANGE, "mktime", "")

let parse_test year month day hour minute second tz () =
  let str, tm = str_tm year month day hour minute second tz in
  let parsed = ISO8601.Permissive.datetime str in
  let output = match tz with
    | Local    -> Unix.localtime parsed
    | Z | Tz _ -> Unix.gmtime parsed
  in
  Alcotest.(check tm_struct ("parse "^str) tm output)

let parse_fixed_unix_time unix_time _tz s () =
  let parsed = int_of_float (ISO8601.Permissive.datetime s) in
  Alcotest.(check int ("parse "^s) (int_of_float unix_time) parsed)

let parse_tests =
  time_tests parse_test @ fixed_time_tests parse_fixed_unix_time

let string_of_datetime unix_time = function
  | Local -> ISO8601.Permissive.string_of_datetime unix_time
  | Z -> ISO8601.Permissive.string_of_datetimezone (unix_time,0.)
  | Tz (Neg,hr,mn) ->
    let tz = float_of_int (- (hr * 3600 + mn * 60)) in
    ISO8601.Permissive.string_of_datetimezone (unix_time, tz)
  | Tz (Pos,hr,mn) ->
    let tz = float_of_int (hr * 3600 + mn * 60) in
    ISO8601.Permissive.string_of_datetimezone (unix_time, tz)

let print_test year month day hour minute second tz () =
  (* We use Unix.mktime to find the epoch time but with year < 1900 it
     will error with ERANGE. *)
  if year < 1900
  then ()
  else
    let str, tm = str_tm year month day hour minute second tz in
    let unix_time, _ = Unix.mktime tm in
    let unix_time = match tz with
      | Local -> unix_time
      | Z | Tz _ ->
        let offt, _ = Unix.mktime (Unix.gmtime unix_time) in
        unix_time -. (offt -. unix_time)
    in
    let output = string_of_datetime unix_time tz in
    Alcotest.(check string ("print "^str) str output)

let print_fixed_unix_time unix_time tz s () =
  let output = ISO8601.Permissive.string_of_datetimezone (unix_time, tz) in
  Alcotest.(check string ("print "^s) s output)

let print_tests =
  time_tests print_test @ fixed_time_tests print_fixed_unix_time

let rt_test year month day hour minute second tz () =
  let str, _ = str_tm year month day hour minute second tz in
  let output = string_of_datetime (ISO8601.Permissive.datetime str) tz in
  Alcotest.(check string ("roundtrip "^str) str output)

let rt_fixed_unix_time unix_time tz s () =
  let output = ISO8601.Permissive.(string_of_datetimezone (datetime s, tz)) in
  Alcotest.(check string ("roundtrip "^s) s output);
  let output = int_of_float ISO8601.Permissive.(
    datetime (string_of_datetimezone (unix_time, tz))
  ) in
  let unix_time = int_of_float unix_time in
  Alcotest.(check int ("roundtrip "^string_of_int unix_time) unix_time output)

let rt_tests =
  time_tests rt_test @ fixed_time_tests rt_fixed_unix_time

module Tm_struct_duration : Alcotest.TESTABLE with type t = ISO8601.Duration.t = struct
  open ISO8601.Duration
  type nonrec t = t

  let pp = pp

  (* do not bother to implement "correct" comparaison of duration
     also use equality on float *)
  let equal a b = is_zero a && is_zero b || a = b
end
let tm_struct_duration = (module Tm_struct_duration : Alcotest.TESTABLE with type t = ISO8601.Duration.t)

let parse_invalid_duration_test s () =
  let open ISO8601.Duration in
  Alcotest.(check bool) ("parse_invalid_duration " ^ s) false (
    try let _ : t = parse s in true with Parsing.Parse_error | Failure _ -> false);
  ()

let parse_invalid_duration_tests =
  let l = ["P1H01M01S"; "P46"; "PT46"; "PT01H46"; "PH1M0S1S"; "1H2M3D"; "AA" ] in
  List.map (fun s -> s,`Quick, parse_invalid_duration_test s) l

let parse_duration_test (s,d) () =
  let open ISO8601.Duration in
  let d2 = parse s in
  Alcotest.check tm_struct_duration ("parse_duration " ^ s) d d2;
  let d3 = parse (to_string d2) in
  Alcotest.check tm_struct_duration ("parse_duration " ^ s) d d3;
  ()

let parse_duration_tests =
  let open ISO8601.Duration in
  let l = [
       ("PT1H33M", Date {date_zero with hour =1.; minute = 33.})
      ;("PT1H33S", Date {date_zero with hour=1.; second=33.})
      ;("PT33M",Date {date_zero with minute=33.})
      ;("P123456789Y33M450DT33H66M99S",Date {year=123456789.;month=33.;day=450.;hour=33.;minute=66.;second=99.})
      ;("P0Y0M1DT0H0M0S",Date {date_zero with day=1.})
      ;("P12W",Week 12.)
      ;("P90001W",Week 90001.)
      ;("P0Y",Date date_zero)
      ;("P0Y0M0DT0H0M0S",Date date_zero)
      ;("PT0H0M0S",Date date_zero)
      ;("PT0S",Date date_zero)
      ;("P0W",Week 0.)
      ;("P0.3W",Week 0.3)
      ;("P12.34Y33.66M450.054DT33.66H66.99M99.66S",Date {year=12.34;month=33.66;day=450.054;hour=33.66;minute=66.99;second=99.66})
      ;("P12,34Y33,66M450,054DT33,66H66,99M99,66S",Date {year=12.34;month=33.66;day=450.054;hour=33.66;minute=66.99;second=99.66})
  ]
  in
  List.map (fun o -> fst o,`Quick, parse_duration_test o) l

let suites = [
  "parse", parse_tests;
  "print", print_tests;
  "rt",    rt_tests;
  "invalid_duration", parse_invalid_duration_tests;
  "parse_duration", parse_duration_tests;
]

let () =
  Alcotest.run "ISO8601" suites
