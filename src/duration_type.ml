type date = {
  year : float;
  month : float;
  day : float;
  hour : float;
  minute : float;
  second : float;
}

type t = Week of float | Date of date

let zero = { year = 0.; month = 0.; day = 0.; hour = 0.; minute = 0.; second = 0. }
