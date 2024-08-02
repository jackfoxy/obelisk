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
  :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)] :: (our src dap sap)
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
::  set-tmsp back 0 seconds
++  test-set-tmsp-00
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %seconds)
                ~2023.12.25..7.15.0..1ef5
--
