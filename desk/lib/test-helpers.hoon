::
/-  ast, *obelisk, *server-state
/+  *test, *scalars, parse
/=  agent  /app/obelisk
|%
::
++  bowl
  ::  Build an example bowl manually
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
++  exec-0-r
  ::  init/resolve → compare cmd-result only
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          expect=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  [%tape2 db.init uql.init]
  ::
  (eval-results expect ;;(cmd-result ->+>+>+>+>+<.mov1))
::
++  exec-0-l
  ::  init/resolve → compare 1 results
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
++  exec-0-1
  ::  init + 1 resolve → compare 1 results
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
++  exec-0-0c2
  |=  $:  run=@ud
          resolve-1=[tmsp=@da cmds=action]
          resolve-2=[tmsp=@da db=@tas uql=tape]
          expect-1=cmd-result
          expect-2=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  cmds.resolve-1
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  %+  expect-eq
              !>  expect-1
              !>  ->+>+>-.mov1
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov2))


::
++  exec-0-02
  ::  init + 2 resolve
  |=  $:  run=@ud
          resolve-1=[tmsp=@da db=@tas uql=tape]
          resolve-2=[tmsp=@da db=@tas uql=tape]
          expect-1=cmd-result
          expect-2=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov1))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov2))
::
++  debug-0-02
  |=  $:  run=@ud
          resolve-1=[tmsp=@da db=@tas uql=tape]
          resolve-2=[tmsp=@da db=@tas uql=tape]
          expect-1=cmd-result
          expect-2=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  %+  expect-fail-message
        'placeholder for debugging'
        |.  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
                %obelisk-action
                !>([%test db.resolve-2 uql.resolve-2])
::
++  exec-0-ls 
  ::  init +1 resolves → compare 2 results ((list cmd-result) & resolve)
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
++  exec-0-2
  ::  init + 2 resolve → compare 2 results
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
++  exec-1-1
  ::  init + 1 action + 1 resolve → compare  result
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
++  exec-1-l
  ::  init + 1 action + 1 resolves → compare 1 result (list cmd-result)
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
++  exec-1-2
  ::  init + 1 action + 2 resolves → compare 2 results (resolve-1 & resolve-2)
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
++  exec-1-ls
  ::  init + 1 action + 2 resolves
  ::  → compare 2 results (resolve-1 (list cmd-result) & resolve-2)
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
++  exec-1-ll
  ::  init + 1 action + 2 resolves
  ::  → compare 2 results
  ::    (resolve-1 (list cmd-result) & resolve-2 (list cmd-result))
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
++  exec-2-1
  ::  init + 2 actions + 1 resolves → compare 1 result
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
++  debug-2-1
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
  ::
  %+  expect-fail-message
        'placeholder for debugging'
        |.  %+  ~(on-poke agent (bowl [run tmsp.resolve]))
                %obelisk-action
                !>([%test db.resolve uql.resolve])

::
++  exec-2-2
  ::  init + 2 actions + 2 resolves → compare 2 results (resolve-1 & resolve-2)
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
++  exec-2-ls
  ::  init + 2 action + 2 resolves → compare 2 results (resolve-1 (list cmd-result) & resolve-2)
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
++  exec-3-1
  ::  init + 3 actions + 1 resolves → compare 1 result
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
++  exec-3-2
  ::  init + 4 actions + 2 resolves
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov5))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov6))
::
++  exec-4-2
  ::  init + 4 actions + 2 resolves
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov6))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov7))
::
++  exec-5-1
  ::  init + 5 actions + 1 resolve
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape]
          action-5=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  [%tape2 db.action-5 uql.action-5]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve]))
      %obelisk-action
      !>  [%tape2 db.resolve uql.resolve]
  ::
  (eval-results expect ;;(cmd-result ->+>+>+<.mov7))
::
++  exec-5-2
  ::  init + 5 actions + 2 resolve
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape]
          action-5=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  [%tape2 db.action-5 uql.action-5]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov8  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov7))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov8))
::
++  exec-5-2-68
  ::  init + 5 actions + 2 resolve
  ::  note resolve is on mov6 & mov8
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape]
          resolve-1=[tmsp=@da db=@tas uql=tape]
          action-5=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  [%tape2 db.action-5 uql.action-5]
  =^  mov8  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov6))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov8))
::
++  exec-5-2xx
  ::  init + 5 actions + 2 resolve
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape]
          action-5=[tmsp=@da cmds=action]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]

  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  cmds.action-5

  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov8  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov7))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov8))
::
++  exec-6-2
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape] 
          action-5=[tmsp=@da db=@tas uql=tape]
          action-6=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  [%tape2 db.action-5 uql.action-5]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-6]))
      %obelisk-action
      !>  [%tape2 db.action-6 uql.action-6]
  =^  mov8  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov9  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov8))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov9))
::
++  exec-6-4
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape] 
          action-5=[tmsp=@da db=@tas uql=tape]
          action-6=[tmsp=@da db=@tas uql=tape]
          resolve-1=[tmsp=@da db=@tas uql=tape]
          resolve-2=[tmsp=@da db=@tas uql=tape]
          resolve-3=[tmsp=@da db=@tas uql=tape]
          resolve-4=[tmsp=@da db=@tas uql=tape]
          expect-1=cmd-result
          expect-2=cmd-result
          expect-3=cmd-result
          expect-4=cmd-result
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
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  [%tape2 db.action-5 uql.action-5]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-6]))
      %obelisk-action
      !>  [%tape2 db.action-6 uql.action-6]
  =^  mov8  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov9  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  =^  mov10  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-3]))
      %obelisk-action
      !>  [%tape2 db.resolve-3 uql.resolve-3]
  =^  mov11  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-4]))
      %obelisk-action
      !>  [%tape2 db.resolve-4 uql.resolve-4]
  ::
  %-  zing  :~  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov8))
                (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov9))
                (eval-results expect-3 ;;(cmd-result ->+>+>+<.mov10))
                (eval-results expect-4 ;;(cmd-result ->+>+>+<.mov11))
                ==
::
++  exec-7-2
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape] 
          action-5=[tmsp=@da db=@tas uql=tape]
          action-6=[tmsp=@da db=@tas uql=tape]
          action-7=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  [%tape2 db.action-5 uql.action-5]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-6]))
      %obelisk-action
      !>  [%tape2 db.action-6 uql.action-6]
  =^  mov8  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-7]))
      %obelisk-action
      !>  [%tape2 db.action-7 uql.action-7]
  =^  mov9  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov10  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov9))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov10))
::
++  exec-7-6
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape] 
          action-5=[tmsp=@da db=@tas uql=tape]
          action-6=[tmsp=@da db=@tas uql=tape]
          action-7=[tmsp=@da db=@tas uql=tape]
          resolve-1=[tmsp=@da db=@tas uql=tape]
          resolve-2=[tmsp=@da db=@tas uql=tape]
          resolve-3=[tmsp=@da db=@tas uql=tape]
          resolve-4=[tmsp=@da db=@tas uql=tape]
          resolve-5=[tmsp=@da db=@tas uql=tape]
          resolve-6=[tmsp=@da db=@tas uql=tape]
          expect-1=cmd-result
          expect-2=cmd-result
          expect-3=cmd-result
          expect-4=cmd-result
          expect-5=cmd-result
          expect-6=cmd-result
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
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  [%tape2 db.action-5 uql.action-5]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-6]))
      %obelisk-action
      !>  [%tape2 db.action-6 uql.action-6]
  =^  mov8  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-7]))
      %obelisk-action
      !>  [%tape2 db.action-7 uql.action-7]
  =^  mov9  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov10  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  =^  mov11  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-3]))
      %obelisk-action
      !>  [%tape2 db.resolve-3 uql.resolve-3]
  =^  mov12  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-4]))
      %obelisk-action
      !>  [%tape2 db.resolve-4 uql.resolve-4]
  =^  mov13  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-5]))
      %obelisk-action
      !>  [%tape2 db.resolve-5 uql.resolve-5]
  =^  mov14  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-6]))
      %obelisk-action
      !>  [%tape2 db.resolve-6 uql.resolve-6]
  ::
  %-  zing  :~  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov9))
                (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov10))
                (eval-results expect-3 ;;(cmd-result ->+>+>+<.mov11))
                (eval-results expect-4 ;;(cmd-result ->+>+>+<.mov12))
                (eval-results expect-5 ;;(cmd-result ->+>+>+<.mov13))
                (eval-results expect-6 ;;(cmd-result ->+>+>+<.mov14))
                ==
::
++  exec-8-2
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape] 
          action-5=[tmsp=@da db=@tas uql=tape]
          action-6=[tmsp=@da db=@tas uql=tape]
          action-7=[tmsp=@da db=@tas uql=tape]
          action-8=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  [%tape2 db.action-5 uql.action-5]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-6]))
      %obelisk-action
      !>  [%tape2 db.action-6 uql.action-6]
  =^  mov8  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-7]))
      %obelisk-action
      !>  [%tape2 db.action-7 uql.action-7]
  =^  mov9  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-8]))
      %obelisk-action
      !>  [%tape2 db.action-8 uql.action-8]
  =^  mov10  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov11  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov10))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov11))
::
++  exec-9-2
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da db=@tas uql=tape]
          action-4=[tmsp=@da db=@tas uql=tape] 
          action-5=[tmsp=@da db=@tas uql=tape]
          action-6=[tmsp=@da db=@tas uql=tape]
          action-7=[tmsp=@da db=@tas uql=tape]
          action-8=[tmsp=@da db=@tas uql=tape]
          action-9=[tmsp=@da db=@tas uql=tape]
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
  %+  ~(on-poke agent (bowl [run tmsp.action-3]))
      %obelisk-action
      !>  [%tape2 db.action-3 uql.action-3]
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-4]))
      %obelisk-action
      !>  [%tape2 db.action-4 uql.action-4]
  =^  mov6  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-5]))
      %obelisk-action
      !>  [%tape2 db.action-5 uql.action-5]
  =^  mov7  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-6]))
      %obelisk-action
      !>  [%tape2 db.action-6 uql.action-6]
  =^  mov8  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-7]))
      %obelisk-action
      !>  [%tape2 db.action-7 uql.action-7]
  =^  mov9  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-8]))
      %obelisk-action
      !>  [%tape2 db.action-8 uql.action-8]
  =^  mov10  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-9]))
      %obelisk-action
      !>  [%tape2 db.action-9 uql.action-9]
  =^  mov11  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-1]))
      %obelisk-action
      !>  [%tape2 db.resolve-1 uql.resolve-1]
  =^  mov12  agent
  %+  ~(on-poke agent (bowl [run tmsp.resolve-2]))
      %obelisk-action
      !>  [%tape2 db.resolve-2 uql.resolve-2]
  ::
  %+  weld  (eval-results expect-1 ;;(cmd-result ->+>+>+<.mov11))
            (eval-results expect-2 ;;(cmd-result ->+>+>+<.mov12))
::
++  failon-0
  ::  failon: init
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          expect=@t
          ==
  ::
  %+  expect-fail-message
      expect
      |.  %+  ~(on-poke agent (bowl [run tmsp.init]))
              %obelisk-action
              !>  [%test db.init uql.init]
::
++  failon-1
  ::  failon: init + fail on 1st action
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
++  failon-1c
  ::  failon: initc + failc on 1st action
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action=[tmsp=@da cmds=action]
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
              !>  cmds.action
::
++  failon-1cc
  ::  failon: initc + failc on 1st action
  |=  $:  run=@ud
          init=[tmsp=@da cmds=action]
          action=[tmsp=@da cmds=action]
          expect=@t
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  cmds.init
  ::
  %+  expect-fail-message
      expect
      |.  %+  ~(on-poke agent (bowl [run tmsp.action]))
              %obelisk-action
              !>  cmds.action
::
++  failon-c
  ::  init + 1 action (action) that should fail
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
++  failon-2
  ::  init + fail on 2nd action
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
++  failon-2c
  ::  initc + failc on 2nd action
  |=  $:  run=@ud
          init=[tmsp=@da cmds=action]
          action-1=[tmsp=@da cmds=action]
          action-2=[tmsp=@da cmds=action]
          expect=@t
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run tmsp.init]))
      %obelisk-action
      !>  cmds.init
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run tmsp.action-1]))
      %obelisk-action
      !>  cmds.action-1
  ::
  %+  expect-fail-message
      expect
      |.  %+  ~(on-poke agent (bowl [run tmsp.action-2]))
              %obelisk-action
              !>  cmds.action-2
::
++  failon-3
  ::  init + fail on 2nd action
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
++  failon-3c
  ::  init + fail on 2nd action
  |=  $:  run=@ud
          init=[tmsp=@da db=@tas uql=tape]
          action-1=[tmsp=@da db=@tas uql=tape]
          action-2=[tmsp=@da db=@tas uql=tape]
          action-3=[tmsp=@da cmds=action]
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
              !>  cmds.action-3
::
++  failon-4
  ::  init + fail on 2nd action
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
::
::  scalar test helpers
::
+$  table-test-row  $:  fn=scalar-function:ast
                        expected=dime
                        ==
::
++  scalar-test-helper
  |=  $:  =named-ctes
          =qualifier-lookup
          =map-meta
          resolved-scalars=(map @tas resolved-scalar)
          =data-row
          row=table-test-row
         ==
  =/  scalar-to-apply
    %:  prepare-scalar  fn.row
                        named-ctes
                        qualifier-lookup
                        map-meta
                        resolved-scalars
                        (bowl [0 ~2026.4.21])
                        ==
  %+  expect-eq
    !>  expected.row
    !>  (apply-scalar data-row scalar-to-apply)
::
::  row structure:
::  [@tas(test-name) [fn expected]]
::
++  run-scalar-tests
  |=  $:  =named-ctes
          =qualifier-lookup
          =map-meta
          resolved-scalars=(map @tas resolved-scalar)
          =data-row
          rows=(list [@tas table-test-row])
         ==
  ^-  tang
  %-  zing
  |-
  ?~  rows
    ~
  =/  row  -.rows
  ::  category to prepend the test name in case of result mismatch
  ::  the ~| to prepend test name in case of crash
  =/  result
    %+  category
      (trip -.row)
    ~|  (weld "CRASH - " (trip -.row))
        %:  scalar-test-helper  named-ctes
                                qualifier-lookup
                                map-meta
                                resolved-scalars
                                data-row
                                +.row
                                ==
  :-  result
  $(rows +.rows)
::
::  parse test helper
::
++  failon-parse
  ::  parse fail test: run parse and expect crash with message
  |=  $:  db=@tas
          uql=tape
          expect=@t
          ==
  %+  expect-fail-message
      expect
      |.  %-  parse:parse(default-database db)
              uql
::
::  create and populate test tables
::
++  animal-shelter-animals
  "CREATE TABLE animals ".
  "(".
  "  name            @t,".
  "  species         @t,".
  "  primary-color   @t,".
  "  implant-chip-id @t, ".
  "  gender          @t,".
  "  birth-date      @da,".
  "  pattern         @t,".
  "  admission-date  @da".
  ")".
  "  PRIMARY KEY (name, species);".
  " ".
  "INSERT INTO animals ".
  "(name, species, primary-color, implant-chip-id, gender, birth-date, pattern, admission-date) ".
  "VALUES ".
  "('Abby', 'Dog', 'Black', 'FDFDB6FE.3347.4E80.8C8A.2E3235C6D1DE', 'F', ~1999.2.19, 'Tricolor', ~2016.7.19) ".
  "('Ace', 'Dog', 'Ginger', '33D50C6B.9D2E.4EB1.8171.0466DEE4F349', 'M', ~2005.12.19, 'Bicolor', ~2019.6.25) ".
  "('Angel', 'Dog', 'Brown', 'F0769A5E.1A11.49F1.AC80.3F40A32EA158', 'F', ~2001.9.19, 'Tuxedo', ~2017.2.4) ".
  "('April', 'Rabbit', 'Gray', 'CCFEF7E8.6FAD.4BA0.81EA.0611DD229E42', 'F', ~2005.1.27, 'Broken', ~2019.4.24) ".
  "('Archie', 'Cat', 'Ginger', '970D7094.AB66.4DCA.A0D1.0C16264989AF', 'M', ~2009.8.26, 'Tricolor', ~2016.7.10) ".
  "('Arya', 'Dog', 'Gray', 'CD1528AD.C91D.47EA.9B70.3CACD5BDBE71', 'F', ~2014.4.14, 'Bicolor', ~2018.6.10) ".
  "('Aspen', 'Dog', 'Brown', '51D4CFD1.CD25.4C5A.AA52.0BFD771F8886', 'F', ~2010.4.17, 'Tuxedo', ~2016.2.9) ".
  "('Bailey', 'Dog', 'Ginger', '36438BC9.E225.4038.97B2.1E28FD287957', 'F', ~2014.9.28, 'Bicolor', ~2018.10.1) ".
  "('Baloo', 'Rabbit', 'White', 'F5CE3A02.1EC7.431D.8A76.09369E8D798B', 'M', ~2015.4.27, 'Broken', ~2016.8.21) ".
  "('Beau', 'Dog', 'Cream', '4B94A68C.0C97.4F70.9275.35B3A9EEE8D9', 'M', ~2016.2.9, 'Solid', ~2017.5.24) ".
  "('Benji', 'Dog', 'Gray', '646F0A76.14E4.42E7.9554.3AF1EA6CC78F', 'M', ~2012.5.21, 'Bicolor', ~2018.10.2) ".
  "('Benny', 'Dog', 'Brown', '2AE54BBB.A587.49D5.9A4D.1400A303C4BF', 'M', ~2010.3.4, 'Tuxedo', ~2018.9.30) ".
  "('Blue', 'Dog', 'Ginger', '6D296D1D.E14D.4308.8B4F.27F87FE1534E', 'M', ~2003.9.3, 'Bicolor', ~2016.4.3) ".
  "('Bon bon', 'Rabbit', 'Gray', 'BCE7E239.304A.483D.9E38.05B9B66AF496', 'F', ~2002.6.29, 'Broken', ~2016.1.3) ".
  "('Boomer', 'Dog', 'Black', '01E2AD60.DAA5.4681.B934.40C9DCF7D73A', 'M', ~2013.8.11, 'Tricolor', ~2017.1.11) ".
  "('Brody', 'Dog', 'Black', 'EB517826.E48A.41AE.A5FB.1BBECA23C05D', 'M', ~2007.8.23, 'Tricolor', ~2018.12.5) ".
  "('Brutus', 'Dog', 'Ginger', 'B7FAD096.7CD1.42A7.85D6.0C3E6599DBEB', 'M', ~2011.4.4, 'Bicolor', ~2018.8.3) ".
  "('Buddy', 'Cat', 'White', '6D49B3F6.E075.4F33.97A3.1D4878EE1345', 'M', ~2017.1.26, 'Tortoiseshell', ~2018.12.20) ".
  "('Callie', 'Dog', 'Cream', '2636F17F.5893.482F.94A7.47EEB715047A', 'F', ~2003.8.28, 'Solid', ~2017.12.19) ".
  "('Charlie', 'Cat', 'Gray', 'AB967364.43CC.4DD2.A4D9.080F0DEF56CA', 'M', ~2016.6.16, 'Calico', ~2018.2.16) ".
  "('Chico', 'Dog', 'Brown', 'C6614119.945A.45A9.A5A2.3C8F840EDC01', 'M', ~2014.3.20, 'Tuxedo', ~2019.3.22) ".
  "('Chubby', 'Rabbit', 'Ginger', '561FEA02.9C12.43B1.9EA8.071C9EAE4C55', 'M', ~2013.2.7, 'Broken', ~2017.10.31) ".
  "('Cleo', 'Cat', 'Black', '0897655B.1486.4D5D.AD60.03A855AFCAF3', 'F', ~2015.8.13, 'Tortoiseshell', ~2019.9.6) ".
  "('Cooper', 'Dog', 'Black', '14F9E97B.6CD4.4EE4.9798.1C4F2376141B', 'M', ~2009.11.15, 'Tricolor', ~2017.1.15) ".
  "('Cosmo', 'Cat', 'Cream', '2754B9C9.5DF4.4206.818D.21BDD1A093ED', 'M', ~2017.11.9, 'Solid', ~2019.5.13) ".
  "('Dolly', 'Dog', 'Gray', 'DBDC4F81.1709.49D6.9F73.1D2099ECA35C', 'F', ~2013.9.29, 'Bicolor', ~2018.4.27) ".
  "('Emma', 'Dog', 'Black', 'BAC4C56D.EBB6.43E3.86F3.36506E17F74D', 'F', ~2006.12.26, 'Tricolor', ~2019.3.28) ".
  "('Fiona', 'Cat', 'Gray', '90226140.F54E.419D.82E5.0EA81E0E6384', 'F', ~1999.5.23, 'Calico', ~2017.1.13) ".
  "('Frankie', 'Dog', 'Gray', 'CC96E651.2F1C.45F8.BCE2.26AC8C9868A7', 'M', ~2003.9.10, 'Bicolor', ~2016.6.20) ".
  "('George', 'Cat', 'Brown', '6FEFC95E.7D46.4E25.B90A.0BA75F45D972', 'M', ~2001.10.4, 'Bicolor', ~2017.11.24) ".
  "('Ginger', 'Dog', 'Ginger', '9E241A82.AD77.49DC.AD15.0AC8D2E89DDE', 'F', ~2015.11.17, 'Bicolor', ~2016.11.27) ".
  "('Gizmo', 'Dog', 'Brown', '78556795.4748.447F.A2CE.336B01173A18', 'M', ~2006.1.23, 'Tuxedo', ~2019.8.14) ".
  "('Gracie', 'Cat', 'Black', '66691184.06B1.4AA8.89B3.0DEF5FD9FBE1', 'F', ~2007.11.20, 'Spotted', ~2017.5.21) ".
  "('Gus', 'Dog', 'Cream', '104A1427.D921.4D11.B45C.370C70E1578F', 'M', ~2014.10.29, 'Solid', ~2016.9.28) ".
  "('Hobbes', 'Cat', 'Gray', '8788E7B9.DC20.45EF.8778.0066F60D790D', 'M', ~2002.1.1, 'Spotted', ~2016.7.29) ".
  "('Holly', 'Dog', 'Cream', 'DD737E6E.3B26.43B4.AD4B.28398602DF74', 'F', ~2011.6.13, 'Solid', ~2016.12.30) ".
  "('Hudini', 'Rabbit', 'Cream', 'DE295DD6.502F.43E3.B139.06CEB3FA2128', 'M', ~2018.3.22, 'Brindle', ~2019.12.10) ".
  "('Humphrey', 'Rabbit', 'Cream', '2A423596.5BF8.41A7.906A.0BD3EA15E17C', 'M', ~2008.12.22, 'Brindle', ~2017.12.31) ".
  "('Ivy', 'Cat', 'Brown', '0955C70B.A2B6.4D78.8E4B.1F6386FFC763', 'F', ~2013.5.13, 'Spotted', ~2018.5.20) ".
  "('Jake', 'Dog', 'White', '9209D54C.0238.457B.9922.02171E9DF0E6', 'M', ~2011.2.27, 'Tuxedo', ~2016.12.14) ".
  "('Jax', 'Dog', 'Ginger', '24AD2ED9.E7E6.4571.8A45.3C9361418B07', 'M', ~2009.2.6, 'Bicolor', ~2017.10.3) ".
  "('Kiki', 'Cat', 'Cream', '4E029101.2326.461C.8FF7.0EB809F110CB', 'F', ~2015.7.7, 'Tricolor', ~2019.11.16) ".
  "('King', 'Dog', 'Brown', '793E68EB.B952.4425.B9E2.0406EA01AC53', 'M', ~2015.9.12, 'Tuxedo', ~2017.8.29) ".
  "('Kona', 'Dog', 'Gray', 'C87EE041.973F.482C.B5E4.3310B4D80612', 'F', ~2008.10.16, 'Bicolor', ~2019.12.13) ".
  "('Layla', 'Dog', 'Cream', 'DF2E0BBC.ACB7.413C.90BC.2AAE37ACEB90', 'F', ~2006.3.11, 'Solid', ~2018.6.14) ".
  "('Lexi', 'Dog', 'Brown', 'BFD890AA.AFB6.4E8F.B60B.0124840EB504', 'F', ~2017.9.17, 'Tuxedo', ~2018.6.22);"
::
++  animal-shelter-animals-breed
  "CREATE TABLE animals-breed ".
  "(".
  "  name    @t,".
  "  species @t, ".
  "  breed   @t".
  ")".
  "  PRIMARY KEY (name, species);".
  " ".
  "INSERT INTO animals-breed ".
  "(name, species, breed) ".
  "VALUES ".
  "('Archie', 'Cat', 'Persian') ".
  "('Baloo', 'Rabbit', 'English Lop') ".
  "('Benji', 'Dog', 'English setter') ".
  "('Boomer', 'Dog', 'Schnauzer') ".
  "('Brody', 'Dog', 'Schnauzer') ".
  "('Brutus', 'Dog', 'Weimaraner') ".
  "('Callie', 'Dog', 'English setter') ".
  "('Emma', 'Dog', 'Schnauzer') ".
  "('Frankie', 'Dog', 'English setter') ".
  "('Gus', 'Dog', 'English setter') ".
  "('Humphrey', 'Rabbit', 'Belgian Hare') ".
  "('Ivy', 'Cat', 'Turkish Angora') ".
  "('Jake', 'Dog', 'Bullmastiff') ".
  "('Jax', 'Dog', 'Weimaraner') ".
  "('Lily', 'Dog', 'Schnauzer') ".
  "('Lucy', 'Dog', 'Weimaraner') ".
  "('Mac', 'Dog', 'English setter') ".
  "('Miss Kitty', 'Cat', 'Maine Coon') ".
  "('Misty', 'Cat', 'Siamese') "
--
