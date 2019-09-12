let suite = OUnit.(>:::) "ISO8601" [
  ISO8601_PARSER.suite;
  ISO8601_PRINTER.suite;
  UTILS_TEST.suite;
]

let _ =
  ignore (OUnit.run_test_tt_main suite : _ list);
  Alcotest.run "ISO8601" Test_pr_5.suites
