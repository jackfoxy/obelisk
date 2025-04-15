::  Demonstrate unit testing queries on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *test
/=  agent  /app/obelisk
|%
::
::  Build an example bowl manually
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)]  :: (our src dap sap)
      [~ ~ ~]                                              :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]       :: (act eny now byk)
  ==
::
::  Build a reference state mold
+$  state
  $:  %0
      =server
      ==
::
--
|%
::
::  no predicate, one column
::++  test-update-00
::
::  no predicate, 3 columns
::++  test-update-01
::
::  no predicate, one key column, changes canonical order
::++  test-update-02
::
::  no predicate, all columns
::++  test-update-03
::
::  predicate, no updates
::++  test-update-04
::
::  predicate, one column, one update
::++  test-update-05
::
::  predicate, one column, three updates
::++  test-update-06
::
::  predicate, 3 columns, one update
::++  test-update-07
::
::  predicate, 3 columns, three updates
::++  test-update-08
::
::  predicate, one key column, changes canonical order
::++  test-update-09
::
::  predicate, all columns, one update
::++  test-update-10
::
::  predicate, no updates
::++  test-update-11
::
::  predicate, AS OF = prior data state, one update
::++  test-update-12
::
::  predicate, AS OF > prior data state, one update
::++  test-update-13
::
::  predicate, AS OF > prior data state, one update, same script
::++  test-update-14
::
::  fail on no predicate, create dup key
++  test-fail-delete-00
::
::  fail on predicate, create dup key
++  test-fail-delete-01
--