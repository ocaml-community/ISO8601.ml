%{
  open Duration_type
%}
%token <float> X
%token S
%token M
%token H
%token T
%token D
%token W
%token M
%token Y
%token P
%token EOF
%start main
%type <Duration_type.t> main

%%
second :
  X S
  { {zero with second = $1} }
  | EOF
  { zero }
;
minute:
  X M second
  {
    let minute = $1 in
    let o = $3 in
    {o with minute}}
  | second
  { $1 }
;
hour:
  X H minute
  {
    let hour = $1 in
    let o = $3 in
    {o with hour}}
  | minute
  { $1 }
;
time:
  T hour
  {$2}
 | EOF
 { zero }
;
day:
  X D time
  {
    let day = $1 in
    let o = $3 in
    {o with day}}
  | time
  { $1 }
;
month :
  X M day
  {
    let o = $3 in
    {o with month = $1}
  }
  | day
  { $1 }
;
year:
  X Y month
  {
    let o = $3 in
    {o with year = $1}
  }
  | month
  { $1 }
;
date:
 | year
  { $1 }
;
week :
  X W
  { $1 }
;
duration:
   date
  { Date $1 }
 | week
  { Week $1 }
;
main:
  P duration EOF
  { $2 }
;

%%
