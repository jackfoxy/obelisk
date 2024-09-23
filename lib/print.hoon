/-  *obelisk
|% 
::
::  +print:  (list cmd-result) -> ?
++  print
  |=  a=(list cmd-result)
  ^-  @f
  ~&  "%obelisk-result:"
  |-
  ?~  a  %.y
  =/  rc=?  (print-cmd-result -.a)
  $(a +.a)
::
++  print-cmd-result
  |=  a=cmd-result
  ^-  @f
  ~&  "  %results"
  =/  results=(list result)  +.a
  |-
  ?~  results  %.y
  =/  b=result  -.results
    ?-  -.b
      %message
        ~&  "    [ {<-.b>} {<msg.b>} ]"
        $(results +.results)
      %vector-count
        ~&  "    [ {<-.b>} {<count.b>} ]"
        $(results +.results)
      %server-time
        ~&  "    [ {<-.b>} {<date.b>} ]"
        $(results +.results)
      %schema-time
        ~&  "    [ {<-.b>} {<date.b>} ]"
        $(results +.results)
      %data-time
        ~&  "    [ {<-.b>} {<date.b>} ]"
        $(results +.results)
      %result-set
        =/  rc=?  (print-result-set +.b)
        $(results +.results)
      ==
::
++  print-result-set
  |=  a=(list vector)
  ^-  @f
  ~&  "    %result-set"
  ?:  =(~ a)  ~&  "      result set empty"  %.y
  =/  rc1  (print-heading -.a)
  =/  i  ?:  (lth (lent a) 11)  0  1
  =/  print-elipsis=?  (gte (lent a) 11)
  |-
  ?~  a  %.y
  =/  rc2  (print-row -.a)
  =/  rc3   ?:  &(=(i 9) print-elipsis)  ~&  "      ..."  (print-row (rear a))
            %.n
  %=  $
    a  ?:  =(i 9)  ~  +.a
    i  +(i)
  ==
::
++  print-row
  |=  a=vector
  ^-  @f
  =/  cells=(list vector-cell)  +.a
  =/  row=tape  "    "
  |-
  ?~  cells  ~&  "{<(crip (flop row))>}"  %.y
  =/  b=vector-cell  -.cells
  =/  print-cell  ?:  =(p.q.b ~.t)  (trip `@t`q.q.b)
      ~(rend co %$ q.b)
  $(cells +.cells, row (weld (flop print-cell) (weld "  " row)))
::
++  print-heading
  |=  a=vector
  ^-  @f
  =/  cells=(list vector-cell)  +.a
  =/  heading=tape  "    "
  |-
  ?.  =(~ cells)
        $(cells +.cells, heading (weld (flop (trip -<.cells)) (weld "  " heading)))
  =/  head  (flop heading)
  ~&  "{<(crip head)>}"  %.y
--