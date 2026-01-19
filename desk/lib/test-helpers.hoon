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
::  exec-0-l: init/resolve → compare 1 results
++  exec-0-l
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          expect=(list cmd-result)
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  [%tape2 db.init uql.init]
  ::
  %+  expect-eq
    !>  expect
    !>  ;;((list cmd-result) ->+>+>+.mov1)
::
::  exec-0-1: init + 1 resolve → compare 1 results
++  exec-0-1
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          resolve=[tmsp=@da db=@tas uql=tape]
          expect=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  [%tape2 db.init uql.init]
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve]))
      %obelisk-action
      !>  [%tape2 db.resolve uql.resolve]
  ::
  (eval-results expect ;;(cmd-result ->+>+>+<.mov2))
::
++  debug-0-1
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          resolve=[tmsp=@da db=@tas uql=tape]
          expect=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  [%tape2 db.init uql.init]
  %+  expect-fail-message
        'placeholder for debugging'
        |.  %+  ~(on-poke agent (bowl [run tmsp.resolve]))
                %obelisk-action
                !>([%test db.resolve uql.resolve])
::
::  exec-0-ls: init +1 resolves → compare 2 results ((list cmd-result) & resolve)
++  exec-0-ls
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          resolve=[tmsp=@da db=@tas uql=tape]
          expect-1=(list cmd-result)
          expect-2=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  [%tape2 db.init uql.init]
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve]))
      %obelisk-action
      !>  [%tape2 db.resolve uql.resolve]
  ::
  %+  weld  %+  expect-eq
                !>  expect-1
                !>  ;;((list cmd-result) ->+>+>+.mov1)
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov2))
::
::  exec-0-2: init + 2 resolve → compare 2 results
++  exec-0-2
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov3  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov2))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov3))
::
::  exec-1-1: init + 1 action + 1 resolve → compare  result
++  exec-1-1
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action=[tmsp=@da db=@tas uql=tape]
          resolve=[tmsp=@da db=@tas uql=tape]
          expect=cmd-result
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
  (eval-results expect ;;(cmd-result ->+>+>+<.mov3))
::
::  exec-1-l: init + 1 action + 1 resolves → compare 1 result (list cmd-result)
++  exec-1-l
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action=[tmsp=@da db=@tas uql=tape]
          resolve=[tmsp=@da db=@tas uql=tape]
          expect=(list cmd-result)
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
  %+  expect-eq
    !>  expect
    !>  ;;((list cmd-result) ->+>+>+.mov3)
::
::  exec-1-2: init + 1 action + 2 resolves → compare 2 results (resolve-1 & resolve-2)
++  exec-1-2
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action]))
      %obelisk-action
      !>  [%tape2 db.action uql.action]
  =^  mov3  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov4  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov3))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov4))
::
::  exec-1-ls: init + 1 action + 2 resolves → compare 2 results (resolve-1 (list cmd-result) & resolve-2)
++  exec-1-ls
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action=[tmsp=@da db=@tas uql=tape]
          resolve-1=[tmsp=@da db=@tas uql=tape]
          resolve-2=[tmsp=@da db=@tas uql=tape]
          expect-1=(list cmd-result)
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
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov4  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  %+  expect-eq
                !>  expect-1
                !>  ;;((list cmd-result) ->+>+>+.mov3)
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov4))
::
::  exec-1-ll: init + 1 action + 2 resolves → compare 2 results (resolve-1 (list cmd-result) & resolve-2 (list cmd-result))
++  exec-1-ll
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action=[tmsp=@da db=@tas uql=tape]
          resolve-1=[tmsp=@da db=@tas uql=tape]
          resolve-2=[tmsp=@da db=@tas uql=tape]
          expect-1=(list cmd-result)
          expect-2=(list cmd-result)
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
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov4  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  %+  expect-eq
                !>  expect-1
                !>  ;;((list cmd-result) ->+>+>+.mov3)
            %+  expect-eq
                !>  expect-2
                !>  ;;((list cmd-result) ->+>+>+.mov4)
::
::  exec-2-1: init + 2 actions + 1 resolves → compare 1 result
++  exec-2-1
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          resolve=[tmsp=@da db=@tas uql=tape]
          expect=cmd-result
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
  %+  ~(on-poke agent (bowl [run tmsp.resolve]))
      %obelisk-action
      !>  [%tape2 db.resolve uql.resolve]
  ::
  (eval-results expect ;;(cmd-result ->+>+>+<.mov4))
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
::  exec-2-ls: init + 2 action + 2 resolves → compare 2 results (resolve-1 (list cmd-result) & resolve-2)
++  exec-2-ls
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          resolve-1=[tmsp=@da db=@tas uql=tape]
          resolve-2=[tmsp=@da db=@tas uql=tape]
          expect-1=(list cmd-result)
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
  %+  weld  %+  expect-eq
                !>  expect-1
                !>  ;;((list cmd-result) ->+>+>+.mov4)
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov5))
::

::
::  exec-3-1: init + 3 actions + 1 resolves → compare 1 result
++  exec-3-1
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          resolve=[tmsp=@da db=@tas uql=tape]
          expect=cmd-result
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve]))
      %obelisk-action
      !>  [%tape2 db.resolve uql.resolve]
  ::
  (eval-results expect ;;(cmd-result ->+>+>+<.mov5))
::
::  failon: init + fail on 1st action
++  failon
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
::  failon-c: init + 1 action (action) that should fail
++  failon-c
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action=[tmsp=@da =action]
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
              !>  action.action
::
::  failon-2: init + fail on 2nd action
++  failon-2
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          expect=@t
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  [%tape2 db.init uql.init]
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-1]))
      %obelisk-action
      !>  [%tape2 db.action-1 uql.action-1]
  ::
  %+  expect-fail-message
      expect
      |.  %+  ~(on-poke agent (bowl [run tmsp.action-2]))
              %obelisk-action
              !>  [%test db.action-2 uql.action-2]
::
::  failon-3: init + fail on 2nd action
++  failon-3
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          expect=@t
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
  ::
  %+  expect-fail-message
      expect
      |.  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
              %obelisk-action
              !>  [%test db.action-3 uql.action-3]
::
::  failon-4: init + fail on 2nd action
++  failon-4
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape]
          expect=@t
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  ::
  %+  expect-fail-message
      expect
      |.  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
              %obelisk-action
              !>  [%test db.action-4 uql.action-4]
--