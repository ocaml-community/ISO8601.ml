let t = ISO8601.ymd_hms_hm

let test fn input expected =
  let expected = expected () in
  let result = fn (Lexing.from_string input) in
  let assert_equal = OUnit2.assert_equal ~printer:string_of_float in
  OUnit2.(>::) input (fun _ -> assert_equal expected result)

let date =
  test ISO8601.date

let time =
  test ISO8601.time

let _ =
  [
    OUnit2.(>:::) "[DATE]"
          [
            date "2009" (t ~y:2009) ;
            date "2009-05-19" (t ~y:2009 ~m:5 ~d:19) ;
            date "20090519" (t ~y:2009 ~m:5 ~d:19) ;
            date "2009-05" (t ~y:2009 ~m:5) ;
            date "2009-001" (t ~y:2009 ~m:1 ~d:1);
            date "2009-123" (t ~y:2009 ~m:5 ~d:3);
            date "2009-222" (t ~y:2009 ~m:8 ~d:10);
            date "2009-139" (t ~y:2009 ~m:5 ~d:19);
            date "2012-060" (t ~y:2012 ~m:2 ~d:29); (* leap year *)
          ] ;
    OUnit2.(>:::) "[TIME WITHOUT TIMEZONE]"
          [
            time "12:34" (t ~h:12 ~mi:34) ;
            time "00:00" (t) ;
            time "14" (t ~h:14) ;
            time "14:31" (t ~h:14 ~mi:31) ;
            time "14:39:22" (t ~h:14 ~mi:39 ~s:22) ;
            time "24:00" (t ~h:24) ;
            time "16:23:48.5" (fun () -> t ~h:16 ~mi:23 ~s:48 () +. 0.5) ;
          (* time "16:23:48,444" (fun () -> t ~h:16 ~mi:23 ~s:48 () +. 0.444) ; *)
          ]
  ]
  |> List.map OUnit2.run_test_tt_main
