let mkdate y m d =
  { Unix.tm_sec = 0 ; tm_min = 0 ; tm_hour = 0 ;
    tm_wday = -1 ; tm_yday = -1 ;tm_isdst = false ;
    tm_mday = d ;
    tm_mon = m - 1 ;
    tm_year = y - 1900 ; }
  |> Unix.mktime
  |> fst

let mktime h m s = h *. 3600. +. m *. 60. +. s

let test fn input expected =
  let result = fn input in
  let assert_equal = OUnit2.assert_equal
                       ~cmp:(OUnit2.cmp_float ~epsilon:Pervasives.epsilon_float)
                       ~printer:string_of_float in
  OUnit2.(>::) input (fun _ -> assert_equal expected result)

let date = test ISO8601.date

let time = test ISO8601.time

let _ =
  [
    OUnit2.(>:::) "[DATE]"
          [
            date "2009" (mkdate 2009 1 1) ;
            date "2009-05-19" (mkdate 2009 5 19) ;
            date "20090519" (mkdate 2009 5 19) ;
            date "2009-05" (mkdate 2009 5 1) ;
            date "2009-001" (mkdate 2009 1 1);
            date "2009-123" (mkdate 2009 5 3);
            date "2009-222" (mkdate 2009 8 10);
            date "2009-139" (mkdate 2009 5 19);
            date "2012-060" (mkdate 2012 2 29); (* leap year *)
          ] ;
    OUnit2.(>:::) "[TIME WITHOUT TIMEZONE]"
          [
            time "12:34" (mktime 12. 34. 0.) ;
            time "00:00" (mktime 0. 0. 0.) ;
            time "14" (mktime 14. 0. 0.) ;
            time "14:31" (mktime 14. 31. 0.) ;
            time "14:39:22" (mktime 14. 39. 22.) ;
            time "24:00" (mktime 24. 0. 0.) ;
            time "16:23:48.5" (mktime 16. 23. 48.5) ;
            time "16:23:48,444" (mktime 16. 23. 48.444) ;
            time "16:23.4" (mktime 16. 23.4 0.) ;
            time "16:23,25" (mktime 16. 23.25 0.);
            time "16.23334444" (mktime 16.23334444 0. 0.);
            time "16,2283" (mktime 16.2283 0. 0.);
          ] ;
  ]
  |> List.map OUnit2.run_test_tt_main
