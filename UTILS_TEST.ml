open Utils

let assert_equal a b =
  OUnit2.(>::)
        (string_of_float a)
        (fun _ ->
         OUnit2.assert_equal
           ~cmp:(OUnit2.cmp_float ~epsilon:Pervasives.epsilon_float)
           ~printer:string_of_float
           a b)

let _ =
  [
    OUnit2.(>:::) "[UTILS]"
          [
            assert_equal 0. (mkdatetime 1970 1 1 0 0 0) ;
            assert_equal 1. (mkdatetime 1970 1 1 0 0 1) ;
            assert_equal 60. (mkdatetime 1970 1 1 0 1 0) ;
            assert_equal 3600. (mkdatetime 1970 1 1 1 0 0) ;
            assert_equal (31. *. 24. *. 3600.)
                         (mkdatetime 1970 2 1 0 0 0) ;
            assert_equal (365. *. 24. *. 3600.) (* not leap year *)
                         (mkdatetime 1971 1 1 0 0 0) ;

            assert_equal 0. (mkdate 1970 1 1) ;
            assert_equal (24. *. 3600.) (mkdate 1970 1 2) ;
            assert_equal (31. *. 24. *. 3600.) (mkdate 1970 2 1) ;

            assert_equal 0. (mktime 0. 0. 0.) ;
            assert_equal 60. (mktime 0. 1. 0.) ;
            assert_equal 1. (mktime 0. 0. 1.) ;
          ]
  ]
  |> List.map OUnit2.run_test_tt_main
