::
/-  ast, *obelisk, *server-state
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
::
::  exec-1-2: init + 1 action + 1 resolve → compare 2 results (action & resolve)
++  exec-1-2
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action=[tmsp=@da db=@tas uql=tape]
          resolve=[tmsp=@da db=@tas uql=tape]
          expect-1=cmd-result
          expect-2=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  [%tape2 db.init uql.init]
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run tmsp.action]))
      %obelisk-action
      !>  [%tape2 db.action uql.action]
  =^  mov3  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve]))
      %obelisk-action
      !>  [%tape2 db.resolve uql.resolve]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov2))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov3))
::
::  exec-2-2: init + 2 actions + 2 resolves → compare 2 results (resolve-1 & resolve-2)
++  exec-2-2
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          resolve-1=[tmsp=@da db=@tas uql=tape]
          resolve-2=[tmsp=@da db=@tas uql=tape]
          expect-1=cmd-result
          expect-2=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  [%tape2 db.init uql.init]
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-1]))
      %obelisk-action
      !>  [%tape2 db.action-1 uql.action-1]
  =^  mov3  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-2]))
      %obelisk-action
      !>  [%tape2 db.action-2 uql.action-2]
  =^  mov4  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov4))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov5))
::
::  failon-1: init + 1 action that should fail
++  failon-1
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action=[tmsp=@da db=@tas uql=tape]
          expect=@t
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  [%tape2 db.init uql.init]
  ::
  %+  expect-fail-message
      expect
      |.  %+  ~(on-poke agent (bowl [run tmsp.action]))
              %obelisk-action
              !>  [%test db.action uql.action]
::
::
++  failon
  |=  [run=@ud init=tape action=tape expect1=@t]
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run ~2012.4.30]))
      %obelisk-action
      !>  [%tape2 %db1 init]                        :: <==
  ::
  %+  expect-fail-message
      expect1
      |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
              %obelisk-action
              !>  [%test %db1 action]
--