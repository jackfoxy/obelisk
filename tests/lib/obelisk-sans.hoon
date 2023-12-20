::  unit tests on %obelisk library simulating pokes
::
/-  ast, *obelisk
/+  *test, *obelisk, parse
|%
::  Build an example bowl manually.
::
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk `path`(limo ~[%test-agent])] :: (our src dap sap)
      [~ ~ ~]                                          :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]   :: (act eny now byk)
  ==
::  Build a reference state mold.
::
+$  state
  $:  %0 
      =databases
      ==
--
|%
::
::
++  schema-ns
  [n=[p=%dbo q=~2023.7.9..22.24.54..4b8a] l=~ r=[n=[p=%sys q=~2023.7.9..22.24.54..4b8a] l=~ r=~]]
++  schema-my-table
  [p=[%dbo %my-table] q=[%table agent='/test-agent' tmsp=~2023.7.9..22.24.54..4b8a pri-indx=[%index unique=%.y clustered=%.y columns=~[[%ordered-column name=%col1 is-ascending=%.y]]] columns=~[[%column name=%col1 type=%t]] indices=~]]
++  schema-table-3
  [p=[%dbo %my-table-3] q=[%table agent='/test-agent' tmsp=~2023.7.9..22.24.54..4b8a pri-indx=pri-indx-table-3 columns=~[[%column name=%col1 type=%t] [%column name=%col2 type=%p] [%column name=%col3 type=%ud]] indices=~]]
++  pri-indx-table-3
  [%index unique=%.y clustered=%.y columns=~[[%ordered-column name=%col1 is-ascending=%.y] [%ordered-column name=%col3 is-ascending=%.n]]]
::
++  file-my-table
  [p=[%dbo %my-table] q=[%file ship=~zod agent='/test-agent' tmsp=~2023.7.9..22.27.32..49e3 clustered=%.y length=0 column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~] key=~[[%t %.y]] pri-idx=~ data=~]]
++  file-my-table-3
  [p=[%dbo %my-table-3] q=[%file ship=~zod agent='/test-agent' tmsp=~2023.7.9..22.35.34..7e90 clustered=%.y length=0 column-lookup=col-lu-table-3 key=~[[%t %.y] [%ud %.n]] pri-idx=~ data=~]]
++  col-lu-table-3
  [n=[p=%col3 q=[%ud 2]] l=[n=[p=%col2 q=[%p 1]] l=~ r=~] r=[n=[p=%col1 q=[%t 0]] l=~ r=~]]
::
++  gen0-intrnl
  [%schema agent='/test-agent' tmsp=~2023.7.9..22.24.54..4b8a namespaces=schema-ns tables=~]
++  gen1-intrnl
  [%schema agent='/test-agent' tmsp=~2023.7.9..22.27.32..49e3 namespaces=schema-ns tables=[n=schema-my-table l=~ r=~]]
++  gen2-intrnl
  [%schema agent='/test-agent' tmsp=~2023.7.9..22.35.34..7e90 namespaces=schema-ns tables=[n=schema-my-table l=[n=schema-table-3 l=~ r=~] r=~]]
::
++  gen0-data
  [%data ship=~zod agent='/test-agent' tmsp=~2023.7.9..22.24.54..4b8a files=~]
++  gen1-data
  [%data ship=~zod agent='/test-agent' tmsp=~2023.7.9..22.27.32..49e3 files=[n=file-my-table l=~ r=~]]
++  gen2-data
  [%data ship=~zod agent='/test-agent' tmsp=~2023.7.9..22.35.34..7e90 files=[n=file-my-table l=[n=file-my-table-3 l=~ r=~] r=~]]
::
++  start-db1-row
  [%db-row name=%db1 created-by-agent='/test-agent' created-tmsp=~2023.7.9..22.24.54..4b8a sys=~[gen2-intrnl gen1-intrnl gen0-intrnl] user-data=~[gen2-data gen1-data gen0-data]]
++  start-dbs
[n=[p=%db1 q=start-db1-row] l=~ r=~]
::
::

::
::  select one literal 
++  test-select-1-literal
  =|  run=@ud 
  =/  my-select  "SELECT 0"
  =/  x  (process-cmds [start-dbs (bowl [run ~2023.2.1]) (parse:parse(default-database 'db1') my-select)])
  %+  expect-eq                         
    !>  [%results ~[[%result-set qualifier=~.literals columns=~[[%literal-0 %ud]] data=[i=~[0] t=~]]]]
    !>  -.x
::
::  select all literals mixed with aliases
++  test-select-literals
  =|  run=@ud 
  =/  rslt-cols  ~[[%date %da] [%literal-1 %da] [%literal-2 %da] [%literal-3 %da] [%literal-4 %da] [%literal-5 %da] [%timespan %dr] [%literal-7 %dr] [%literal-8 %dr] [%literal-9 %dr] [%literal-10 %dr] [%loobean %f] [%literal-12 %f] [%ipv4-address %if] [%ipv6-address %is] [%ship %p] [%single-float %rs] [%literal-17 %rs] [%double-float %rd] [%literal-19 %rd] [%signed-binary %sb] [%literal-21 %sb] [%signed-decimal %sd] [%literal-23 %sd] [%signed-base32 %sv] [%literal-25 %sv] [%signed-base64 %sw] [%literal-27 %sw] [%signed-hexadecimal %sx] [%literal-29 %sx] [%unsigned-binary %ub] [%unsigned-decimal %ud] [%literal-32 %ud] [%unsigned-hexadecimal %ux]]
  =/  rslt-data  ~[~[~2020.12.25 ~2020.12.25..7.15.0 ~2020.12.25..7.15.0..1ef5 ~2020.12.25 ~2020.12.25..7.15.0 ~2020.12.25..7.15.0..1ef5 ~d71.h19.m26.s24..9d55 ~d71.h19.m26.s24 ~d71.h19.m26 ~d71.h19 ~d71 %.y %.n .195.198.143.90 .0.0.0.0.0.1c.c3c6.8f5a ~sampel-palnet .3.14 .-3.14 .~3.14 .~-3.14 --0b10.0000 -0b10.0000 --20 -20 --0v201.4gvml.245kc -0v201.4gvml.245kc --0w2.04AfS.G8xqc -0w2.04AfS.G8xqc --0x2004.90fd -0x2004.90fd 0b10.1011 2.222 2.222 0x12.6401]]
  =/  my-select  "SELECT ~2020.12.25 AS Date, ~2020.12.25..7.15.0, ".
  "~2020.12.25..7.15.0..1ef5, 2020.12.25, 2020.12.25..7.15.0, 2020.12.25..7.15.0..1ef5, ".
  "~d71.h19.m26.s24..9d55 AS Timespan, ~d71.h19.m26.s24, ~d71.h19.m26, ~d71.h19, ~d71, ".
  "Y AS Loobean, N, .195.198.143.90 AS IPv4-address, .0.0.0.0.0.1c.c3c6.8f5a as IPv6-address, ".
  "~sampel-palnet AS Ship, .3.14 AS Single-float, .-3.14, ~3.14 AS Double-float, ~-3.14, ".
  "--0b10.0000 AS Signed-binary, -0b10.0000, --20 AS Signed-decimal, -20, ".
  "--0v201.4gvml.245kc AS Signed-base32, -0v201.4gvml.245kc, --0w2.04AfS.G8xqc AS Signed-base64, ".
  "-0w2.04AfS.G8xqc, --0x2004.90fd AS Signed-hexadecimal, -0x2004.90fd, ".
  "10.1011 AS Unsigned-binary, 2.222 AS Unsigned-decimal, 2222, 0x12.6401 AS Unsigned-hexadecimal"
  =/  x  (process-cmds [start-dbs (bowl [run ~2023.2.1]) (parse:parse(default-database 'db1') my-select)])
  %+  expect-eq                         
    !>  [%results ~[[%result-set qualifier=~.literals rslt-cols rslt-data]]]
    !>  -.x

::
::  set-tmsp back 0 seconds
++  test-set-tmsp-00
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 0 %seconds) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 65 seconds
++  test-set-tmsp-01
  %+  expect-eq                         
    !>  ~2023.12.25..7.13.55..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 65 %seconds) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 0 minutes
++  test-set-tmsp-02
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 0 %minutes) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 65 minutes
++  test-set-tmsp-03
  %+  expect-eq                         
    !>  ~2023.12.25..6.10.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 65 %minutes) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 0 hours
++  test-set-tmsp-04
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 0 %hours) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 65 hours
++  test-set-tmsp-05
  %+  expect-eq                         
    !>  ~2023.12.22..14.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 65 %hours) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 0 days
++  test-set-tmsp-06
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 0 %days) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 65 days
++  test-set-tmsp-07
  %+  expect-eq                         
    !>  ~2023.10.21..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 65 %days) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 0 weeks
++  test-set-tmsp-08
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 0 %weeks) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 65 weeks
++  test-set-tmsp-09
  %+  expect-eq                         
    !>  ~2022.9.26..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 65 %weeks) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp leap year
++  test-set-tmsp-10
  %+  expect-eq                         
    !>  ~2020.2.27..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 7 %days) ~2020.3.5..7.15.0..1ef5])


::
::  set-tmsp back 0 months
++  test-set-tmsp-11
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 0 %months) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 65 months
++  test-set-tmsp-12
  %+  expect-eq                         
    !>  ~2018.7.25..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 65 %months) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 3 months
++  test-set-tmsp-13
  %+  expect-eq                         
    !>  ~2019.12.5..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 3 %months) ~2020.3.5..7.15.0..1ef5])
::
::  set-tmsp back 2 months
++  test-set-tmsp-14
  %+  expect-eq                         
    !>  ~2020.1.5..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 2 %months) ~2020.3.5..7.15.0..1ef5])
::
::  set-tmsp back 0 years
++  test-set-tmsp-15
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 0 %years) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back 65 years
++  test-set-tmsp-16
  %+  expect-eq                         
    !>  ~1958.12.25..7.15.0..1ef5
    !>  (set-tmsp [`(as-of-offset:ast %as-of-offset 65 %years) ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp to ~1962.2.2..7.15.0..1ef5
++  test-set-tmsp-17
  %+  expect-eq                         
    !>  ~1962.2.2..7.15.0..1ef5
    !>  (set-tmsp [`[%da ~1962.2.2..7.15.0..1ef5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~s65
++  test-set-tmsp-18
  %+  expect-eq                         
    !>  ~2023.12.25..7.13.55..1ef5
    !>  (set-tmsp [`[%dr ~s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65
++  test-set-tmsp-19
  %+  expect-eq                         
    !>  ~2023.12.25..6.10.0..1ef5
    !>  (set-tmsp [`[%dr ~m65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65.s65
++  test-set-tmsp-20
  %+  expect-eq                         
    !>  ~2023.12.25..6.8.55..1ef5
    !>  (set-tmsp [`[%dr ~m65.s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~h2.m12.s5
++  test-set-tmsp-21
  %+  expect-eq                         
    !>  ~2023.12.25..5.2.55..1ef5
    !>  (set-tmsp [`[%dr ~h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d5.h2.m12.s5
++  test-set-tmsp-22
  %+  expect-eq                         
    !>  ~2023.12.20..5.2.55..1ef5
    !>  (set-tmsp [`[%dr ~d5.h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~s0
++  test-set-tmsp-23
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`[%dr ~s0] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d0.h0.m0.s0
++  test-set-tmsp-24
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`[%dr ~d0.h0.m0.s0] ~2023.12.25..7.15.0..1ef5])
--
