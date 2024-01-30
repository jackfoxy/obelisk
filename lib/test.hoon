::  testing utilities meant to be directly used from files in %/tests
::
|%
::
::  +vary: pretty-print diff between two vases using +sell.
::
++  vary
  |=  [vax=vase vas=vase]
  ^-  (pair tank tank)
  ~|  %vary
  =.  p.vas   (wipe p.vas)
  =.  p.vas   (~(redo ut p.vas) p.vax)
  [(sell vax) (sell vas)]
::
::  +dunt: pretty-print diff between two types using +dunk.
::
++  dunt
  |=  [ref=[p=term q=type] sut=[p=term q=type]]
  ^-  (pair tank tank)
  =.  q.ref  (wipe q.ref)
  =.  q.ref  (~(redo ut q.ref) q.sut)
  [(~(dunk ut q.ref) p.ref) (~(dunk ut q.sut) p.sut)]
::
::  +wipe: clear type faces.
::
++  wipe
  |=  sut=type
  ^-  type
  =+  gil=*(set type)
  |-
  ?+  sut  sut
    [%cell *]  [%cell $(sut p.sut) $(sut q.sut)]
    [%face *]  $(sut q.sut)
    [%fork *]  (fork (turn ~(tap in p.sut) |=(=type ^$(sut type))))
    [%hint *]  (hint p.sut $(sut q.sut))
    [%hold *]
    ?:  (~(has in gil) sut)  sut
    $(gil (~(put in gil) sut), sut ~(repo ut sut))
  ==
::
--
|%
::  +expect-eq: compares :expected and :actual and pretty-prints the result
::
++  expect-eq
  |=  [expected=vase actual=vase]
  ^-  tang
  ::
  ::~&  "expected: {<q.expected>}"
  ::~&  ""
  ::~&  "actual: {<q.actual>}"
  ::
  =|  result=tang
  ::
  =?  result  !=(q.expected q.actual)
    =/  diff=(pair tank tank)  (vary [expected actual])
    %+  weld  result
    ^-  tang
    :~  [%palm [": " ~ ~ ~] [leaf+"expected" p.diff ~]]
        [%palm [": " ~ ~ ~] [leaf+"actual  " q.diff ~]]
    ==
  ::
  =?  result  !(~(nest ut p.actual) | p.expected)
    =/  diff=(pair tank tank)  (dunt [[%actual p.actual] [%expected p.expected]])
    %+  weld  result
    ^-  tang
    :~  :+  %palm  [": " ~ ~ ~]
        :~  [%leaf "failed to nest"]
            p.diff
            q.diff
    ==  ==
  result
::  +expect: compares :actual to %.y and pretty-prints anything else
::
++  expect
  |=  actual=vase
  (expect-eq !>(%.y) actual)
::  +expect-fail: kicks a trap, expecting crash. pretty-prints if succeeds
::
++  expect-fail
  |=  a=(trap)
  ^-  tang
  =/  b  (mule a)
  ?-  -.b
    %|  ~
    %&  ['expected failure - succeeded' ~]
  ==
::  +expect-runs: kicks a trap, expecting success; returns trace on failure
::
++  expect-success
  |=  a=(trap)
  ^-  tang
  =/  b  (mule a)
  ?-  -.b
    %&  ~
    %|  ['expected success - failed' p.b]
  ==
::  $a-test-chain: a sequence of tests to be run
::
::  NB: arms shouldn't start with `test-` so that `-test % ~` runs
::
+$  a-test-chain
  $_
  |?
  ?:  =(0 0)
    [%& p=*tang]
  [%| p=[tang=*tang next=^?(..$)]]
::  +run-chain: run a sequence of tests, stopping at first failure
::
++  run-chain
  |=  seq=a-test-chain
  ^-  tang
  =/  res  $:seq
  ?-  -.res
    %&  p.res
    %|  ?.  =(~ tang.p.res)
          tang.p.res
        $(seq next.p.res)
  ==
::  +category: prepends a name to an error result; passes successes unchanged
::
++  category
  |=  [a=tape b=tang]  ^-  tang
  ?:  =(~ b)  ~  :: test OK
  :-  leaf+"in: '{a}'"
  (turn b |=(c=tank rose+[~ "  " ~]^~[c]))
--