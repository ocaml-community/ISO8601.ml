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

let time_tests f = [
  "before_1900",      `Quick, f 1861  9  1 8 0 0 Local;
  "before_epoch",     `Quick, f 1969  1  1 0 0 1 Local;
  "nowish",           `Quick, f 2015 12 27 0 0 1 Local;
  "before_1900_z",    `Quick, f 1861  9  1 8 0 0 Z;
  "before_epoch_z",   `Quick, f 1969  1  1 0 0 1 Z;
  "nowish_z",         `Quick, f 2015 12 27 0 0 1 Z;
  "before_1900_est",  `Quick, f 1861  9  1 8 0 0 (Tz (Neg,5,0));
  "before_epoch_est", `Quick, f 1969  1  1 0 0 1 (Tz (Neg,5,0));
  "nowish_est",       `Quick, f 2015 12 27 0 0 1 (Tz (Neg,5,0));
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
  if year < 1900
  then Alcotest.check_raises "< 1900 is ERANGE" erange (fun () ->
    ignore (ISO8601.Permissive.datetime "1861-01-01T00:00:00Z")
  )
  else
    let str, tm = str_tm year month day hour minute second tz in
    let parsed = ISO8601.Permissive.datetime str in
    let output = match tz with
      | Local    -> Unix.localtime parsed
      | Z | Tz _ -> Unix.gmtime parsed
    in
    Alcotest.(check tm_struct ("parse "^str) tm output)

let parse_tests = time_tests parse_test

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

let print_tests = time_tests print_test

let rt_test year month day hour minute second tz () =
  if year < 1900
  then Alcotest.check_raises "< 1900 is ERANGE" erange (fun () ->
    ignore (ISO8601.Permissive.datetime "1861-01-01T00:00:00")
  )
  else
    let str, _ = str_tm year month day hour minute second tz in
    let output = string_of_datetime (ISO8601.Permissive.datetime str) tz in
    Alcotest.(check string ("roundtrip "^str) str output)

let rt_tests = time_tests rt_test

let suites = [
  "parse", parse_tests;
  "print", print_tests;
  "rt",    rt_tests;
]

;;
Alcotest.run "ISO8601" suites
