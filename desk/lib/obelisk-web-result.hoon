::  Pure Obelisk reply conversion for %obelisk-web.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  format
|%
::
++  tank-text
  |=  =tank
  ^-  @t
  (crip ~(ram re tank))
::
++  tang-details
  |=  =tang
  ^-  (list @t)
  (turn tang tank-text)
::
++  dime-text
  |=  value=dime
  ^-  @t
  (crip (render-dime:format value))
::
++  result-column
  |=  cell=vector-cell:ast
  ^-  result-column-dto:web
  [p.cell p.q.cell]
::
++  result-cell
  |=  cell=vector-cell:ast
  ^-  result-cell-dto:web
  [p.cell p.q.cell (dime-text q.cell)]
::
++  result-set
  |=  vectors=(list vector:ast)
  ^-  result-set-dto:web
  =/  columns=(list result-column-dto:web)
    ?~  vectors  ~
    (turn +.i.vectors result-column)
  =/  rows=(list (list result-cell-dto:web))
    (turn vectors |=(vector=vector:ast (turn +.vector result-cell)))
  [columns rows]
::
++  result-dto
  |=  result=result:ast
  ^-  result-dto:web
  ?-  -.result
    %action  [%action action.result]
    %relation-name  [%relation-name name.result]
    %message  [%message msg.result]
    %vector-count  [%vector-count count.result]
    %server-time  [%server-time date.result]
    %security-time  [%security-time date.result]
    %schema-time  [%schema-time date.result]
    %data-time  [%data-time date.result]
    %result-set  [%result-set (result-set +.result)]
    %relations  [%relations (crip (text !>(+.result)))]
    %select-relation  [%select-relation (crip (text !>(+.result)))]
  ==
::
++  command-dtos
  |=  [commands=(list cmd-result:ast) index=@ud]
  ^-  (list command-dto:web)
  ?~  commands  ~
  :-  [index (turn +.i.commands result-dto)]
  $(commands t.commands, index +(index))
::
++  run-response
  |=  commands=(list cmd-result:ast)
  ^-  web-response:web
  (run-response-with commands %.n)
::
++  run-response-with
  |=  [commands=(list cmd-result:ast) schema-changed=?]
  ^-  web-response:web
  [%run (command-dtos commands 0) schema-changed]
::
++  parse-response
  |=  commands=(list command:ast)
  ^-  web-response:web
  =/  command-texts=(list @t)
    (turn commands |=(command=command:ast (crip (text !>(command)))))
  [%parse command-texts (crip (text !>(commands)))]
::
::  +|  Export and Paging
::
++  result-page-size
  ^-  @ud
  500
::
++  result-paging-threshold
  ^-  @ud
  800
::
++  should-page
  |=  row-count=@ud
  ^-  ?
  (gte row-count result-paging-threshold)
::
++  page-count
  |=  row-count=@ud
  ^-  @ud
  ?:  =(0 row-count)  0
  (div (sub (add row-count result-page-size) 1) result-page-size)
::
++  delimiter-tape
  |=  delimiter=export-delimiter:web
  ^-  tape
  ?-  delimiter
    %comma  ","
    %space  " "
    %tab  "\09"
  ==
::
++  join-tapes
  |=  [separator=tape values=(list tape)]
  ^-  tape
  ?~  values  ""
  ?~  t.values  i.values
  (weld i.values (weld separator $(values t.values)))
::
++  export-row
  |=  $:  row=(list result-cell-dto:web)
          delimiter=export-delimiter:web
      ==
  ^-  tape
  %+  join-tapes  (delimiter-tape delimiter)
  (turn row |=(cell=result-cell-dto:web (trip value.cell)))
::
++  export-result-set
  |=  $:  result-set=result-set-dto:web
          delimiter=export-delimiter:web
      ==
  ^-  @t
  ?~  columns.result-set  ''
  =/  header=tape
    %+  join-tapes  (delimiter-tape delimiter)
    %+  turn  columns.result-set
    |=  column=result-column-dto:web
    (trip name.column)
  =/  row-lines=(list tape)
    %+  turn  rows.result-set
    |=  row=(list result-cell-dto:web)
    (export-row row delimiter)
  =/  lines=(list tape)  [header row-lines]
  (crip (join-tapes "\0a" lines))
::
++  result-sets
  |=  commands=(list command-dto:web)
  ^-  (list result-set-dto:web)
  ?~  commands  ~
  =/  sets=(list result-set-dto:web)
    %+  turn
      %+  skim  results.i.commands
      |=  result=result-dto:web
      ?=(%result-set -.result)
    |=  result=result-dto:web
    ?>  ?=(%result-set -.result)
    value.result
  (weld sets $(commands t.commands))
::
++  result-export-text
  |=  $:  commands=(list command-dto:web)
          delimiter=export-delimiter:web
      ==
  ^-  @t
  =/  chunks=(list @t)
    %+  skim
      %+  turn  (result-sets commands)
      |=(set=result-set-dto:web (export-result-set set delimiter))
    |=(chunk=@t !=(chunk ''))
  ?~  chunks  ''
  %-  crip
  %+  weld
    (join-tapes "\0a\0a" (turn chunks trip))
  "\0a"
::
++  metadata-line
  |=  result=result-dto:web
  ^-  (unit @t)
  =/  label=tape
    ?-  -.result
      ?(%action %relation-name %message)  "message: "
      %vector-count  "vector count: "
      %server-time  "server-time: "
      %security-time  "security-time: "
      %schema-time  "schema-time: "
      %data-time  "data-time: "
      %result-set  ""
      %relations  "relations: "
      %select-relation  "select-relation: "
    ==
  ?:  =(%result-set -.result)  ~
  =/  value=tape
    ?-  -.result
      ?(%action %relation-name %message %relations %select-relation)
        (trip value.result)
      %vector-count  (scow %ud value.result)
      ?(%server-time %security-time %schema-time %data-time)
        (scow %da value.result)
      %result-set  ""
    ==
  `(crip (weld label value))
::
++  metadata-results
  |=  results=(list result-dto:web)
  ^-  (list @t)
  ?~  results  ~
  =/  line=(unit @t)  (metadata-line i.results)
  ?~  line  $(results t.results)
  [u.line $(results t.results)]
::
++  metadata-lines
  |=  commands=(list command-dto:web)
  ^-  (list @t)
  ?~  commands  ~
  %+  weld  (metadata-results results.i.commands)
  $(commands t.commands)
::
++  metadata-text
  |=  commands=(list command-dto:web)
  ^-  @t
  =/  lines=(list @t)  (metadata-lines commands)
  ?~  lines  ''
  %-  crip
  (weld (join-tapes "\0a" (turn lines trip)) "\0a")
::
++  query-copy-text
  |=  $:  commands=(list command-dto:web)
          delimiter=export-delimiter:web
      ==
  ^-  @t
  =/  results=@t  (result-export-text commands delimiter)
  =/  metadata=@t  (metadata-text commands)
  ?:  =(results '')  metadata
  ?:  =(metadata '')  results
  (cat 3 results (cat 3 '\0a' metadata))
::
++  parse-export-text
  |=  text=@t
  ^-  @t
  =/  characters=tape  (trip text)
  ?~  characters  '\0a'
  ?:  =(10 (rear characters))  text
  (cat 3 text '\0a')
--
