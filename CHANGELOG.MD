# CHANGELOG

## 0.2.0

- Breaking change in API: functions with optionnal time zone
  argument splitted into 2 different functions. With and without
  time zone argument.
- Used format-like function to be able to customize printing.
- Added printers for basic format.
- Important bugfix when using mktime.

## 0.1.3

- Printer bugfix.

## 0.1.2

- Printer bugfix.

## 0.1.1

- Fixed OCaml 3.12.1 compatibility.

## 0.1.0

- Permissive module will parse a superset of (a part of)
  the ISO8601 spec.
- Printing of date / times / ... with the form defined as
  the extended format.
