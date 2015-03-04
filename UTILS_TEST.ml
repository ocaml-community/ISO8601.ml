let test a b =
  OUnit2.(>::)
        (string_of_float a)
        (fun _ -> OUnit2.assert_equal
                    ~cmp:(OUnit2.cmp_float ~epsilon:Pervasives.epsilon_float)
                    ~printer:string_of_float
                    a b)

let _ =
  let mkdatetime = Utils.mkdatetime in
  let mkdate = Utils.mkdate in
  let mktime = Utils.mktime in
  [
    OUnit2.(>:::) "[UTILS mkdatetime]"
          [
            test 0. (mkdatetime 1970 1 1 0 0 0) ;
            test 1. (mkdatetime 1970 1 1 0 0 1) ;
            test 60. (mkdatetime 1970 1 1 0 1 0) ;
            test 3600. (mkdatetime 1970 1 1 1 0 0) ;
            test (31. *. 24. *. 3600.)
                         (mkdatetime 1970 2 1 0 0 0) ;
            test (365. *. 24. *. 3600.) (* not leap year *)
                         (mkdatetime 1971 1 1 0 0 0) ;
          ] ;
    OUnit2.(>:::) "[UTILS mkdate]"
          [
            test 0. (mkdate 1970 1 1) ;
            test (24. *. 3600.) (mkdate 1970 1 2) ;
            test (31. *. 24. *. 3600.) (mkdate 1970 2 1) ;
            test 583804800. (mkdate 1988 7 2) ;
          ] ;
    OUnit2.(>:::) "[UTILS mktime]"
          [
            test 0. (mktime 0. 0. 0.) ;
            test 60. (mktime 0. 1. 0.) ;
            test 1. (mktime 0. 0. 1.) ;
          ]
  ]
  |> List.map OUnit2.run_test_tt_main
