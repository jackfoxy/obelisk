::  Pure Obelisk reply conversion for %obelisk-web.
::
/-  ast=obelisk-ast, web=obelisk-web
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
++  result-column
  |=  cell=vector-cell:ast
  ^-  result-column-dto:web
  [p.cell p.q.cell]
::
++  result-cell
  |=  cell=vector-cell:ast
  ^-  result-cell-dto:web
  [p.cell p.q.cell (crip (scow q.cell))]
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
--
