::  testing utilities meant to be directly used from files in %/tests
::
/-  *obelisk
|%
++  parse-results
  |=  [expected=cmd-result actual=cmd-result]
  ^-  [[cmd-result (set vector)] [cmd-result (set vector)]]
  [(parse-results-2 +.expected) (parse-results-2 +.actual)]
++  parse-results-2
  |=  results=(list result)
  ^-  [cmd-result (set vector)]
  =/  out-results=(list result)  ~
  =/  out-vectors=(list vector)  ~
  |-
  ?~  results
    [[%results (flop out-results)] (silt out-vectors)]
  =/  res  i.results
  ?:  =(%result-set -.res)
    $(results t.results, out-vectors ;;((list vector) +.res))
  $(results t.results, out-results [res out-results])
++  eval-results
  |=  [expected=cmd-result actual=cmd-result]
  =/  expct-actual  (parse-results expected actual)
  %+    weld  %+  expect-eq
                !>  -<.expct-actual
                !>  +<.expct-actual
              %+  expect-eq
                !>  ->.expct-actual
                !>  +>.expct-actual
::
::  +expect-eq: compares :expected and :actual and pretty-prints the result
::
++  expect-eq
  |=  [expected=vase actual=vase]
  ^-  tang
  ::
  =|  result=tang
  ::
  =?  result  !=(q.expected q.actual)
    %+  weld  result
    ^-  tang
    :~  [%palm [": " ~ ~ ~] [leaf+"expected" (sell expected) ~]]
        [%palm [": " ~ ~ ~] [leaf+"actual  " (sell actual) ~]]
    ==
  ::
  =?  result  !(~(nest ut p.actual) | p.expected)
    %+  weld  result
    ^-  tang
    :~  :+  %palm  [": " ~ ~ ~]
        :~  [%leaf "failed to nest"]
            (~(dunk ut p.actual) %actual)
            (~(dunk ut p.expected) %expected)
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
::  +expect-fail-message: kicks a trap, expecting crash with message.
::
++  expect-fail-message
    |=  [msg=@t a=(trap)]
    ^-  tang
    =/  b  (mule a)
    ?-  -.b
      %|  |^
          =/  =tang  (flatten +.b)
          ?:  ?=(^ (find (trip msg) tang))
            ~
          
            ~&  "expected:  {<(trip msg)>}"
            ~&  "find in tang:  {<(flatten +.b)>}"

          ['expected error message - not found' ~]
          ++  flatten
            |=  tang=(list tank)
            =|  res=tape
            |-  ^-  tape
            ?~  tang  res
            $(tang t.tang, res (weld ~(ram re i.tang) res))
          --
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
