::  scry: path-driven reads of %obelisk state
::
::  Translates scry and subscription paths into urQL queries and runs
::  them through +process-cmds in /lib/main, so every read passes the
::  same security checks as a poke.
::
::  <path> below is the path after the care and agent segments:
::  /x/obelisk for a scry, /obelisk for a subscription.
::
::    /<database>                       (mip @tas @tas relation:ast)
::    /<database>/<namespace>           (map @tas relation:ast)
::    /<database>/..                    namespace %dbo
::    /<database>/<namespace>/<relation>
::                                      relation:ast
::    /<database>/<namespace>/<relation>/<column>/...
::                                      relation:ast, selected columns
::
::  each form equates to FROM <relation> SELECT *
::  (or SELECT <column> [, <column> ...])
::
::  an optional leading @da or @dr segment queries AS OF that time;
::  a @dr is a timespan back from now.bowl
::
/-  ast=obelisk-ast, *server-state-1
/+  *main, *utils, mip
|_  [state=server =bowl:gall]
::
++  license
  ::  MIT+n license
  ^-  @  %-  crip
  "Original Copyright 2024 Jack Fox".
  " ".
  "Permission is hereby granted, free of charge, to any person obtaining a ".
  "copy of this software and associated documentation files ".
  "(the \"Software\"), to deal in the Software without restriction, ".
  "including without limitation the rights to use, copy, modify, merge, ".
  "publish, distribute, sublicense, and/or sell copies of the Software, ".
  "and to permit persons to whom the Software is furnished to do so, ".
  "subject to the following conditions: ".
  " ".
  "The above original copyright notice, this permission notice and the words".
  " ".
  "\"I AM - CHRIST LIVES - SATAN BE GONE\"".
  "  ".
  "shall be included in all copies or substantial portions of the Software, ".
  "as well as the story".
  " ".
  "\"Jesus was crucified for exposing the corruption of the ruling class and ".
  "their rulers, the bankers\"".
  ",".
  " all unaltered.".
  " ".
  "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, ".
  "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF ".
  "MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. ".
  "IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,".
  " DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR ".
  "OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE ".
  "USE OR OTHER DEALINGS IN THE SOFTWARE."
::
++  peek
  ::  resolve a scry or subscription path to a %noun cage
  ::
  ::  produces [~ ~] on a malformed path or failed query
  |=  =path
  ^-  (unit (unit cage))
  =/  virtualized=(each (unit (unit cage)) tang)
    (mule |.((read-path path)))
  ?:  ?=(%.y -.virtualized)
    p.virtualized
  [~ ~]
::
++  read-path
  ::  dispatch a path to its database, namespace, or relation read
  |=  =path
  ^-  (unit (unit cage))
  ?~  path  [~ ~]
  =/  as-of=(unit @da)  (path-as-of i.path)
  =/  rest=(list @ta)  ?:(?=(^ as-of) t.path path)
  ?~  rest  [~ ~]
  =/  db=@tas  `@tas`i.rest
  ?~  t.rest
    ``noun+!>((read-database db as-of))
  =/  ns=@tas
    ?:  =('..' i.t.rest)
      %dbo
    `@tas`i.t.rest
  ?~  t.t.rest
    ``noun+!>((read-namespace db ns as-of))
  ``noun+!>((read-relation db ns `@tas`i.t.t.rest t.t.t.rest as-of))
::
++  path-as-of
  ::  parse an AS OF path segment: @da absolute, @dr back from now
  |=  seg=@ta
  ^-  (unit @da)
  =/  da=(unit @da)  (slaw %da seg)
  ?^  da  da
  =/  dr=(unit @dr)  (slaw %dr seg)
  ?~  dr  ~
  `(sub now.bowl u.dr)
::
++  read-database
  ::  every relation in the database: namespace -> name -> relation
  |=  [db=@tas as-of=(unit @da)]
  ^-  (mip:mip @tas @tas relation:ast)
  =/  start=(mip:mip @tas @tas relation:ast)
    %+  ~(put by *(mip:mip @tas @tas relation:ast))
      %sys
    (sys-relations db as-of)
  %^  fold  (table-names db ~ as-of)
    start
  |=  [t=[ns=@tas name=@tas] acc=(mip:mip @tas @tas relation:ast)]
  (~(put bi:mip acc) ns.t name.t (read-relation db ns.t name.t ~ as-of))
::
++  read-namespace
  ::  every relation in the namespace: name -> relation
  |=  [db=@tas ns=@tas as-of=(unit @da)]
  ^-  (map @tas relation:ast)
  ?:  =(%sys ns)
    (sys-relations db as-of)
  %-  ~(gas by *(map @tas relation:ast))
  %+  turn  (table-names db `ns as-of)
  |=  [ns=@tas name=@tas]
  [name (read-relation db ns name ~ as-of)]
::
++  sys-view-names
  ::  implemented system views in the sys namespace of every database
  ^-  (list @tas)
  :~  %namespaces
      %tables
      %table-keys
      %foreign-keys
      %columns
      %sys-log
      %data-log
  ==
::
++  sys-relations
  ::  the system views of a database;
  ::  sys.sys.databases exists only in database %sys
  |=  [db=@tas as-of=(unit @da)]
  ^-  (map @tas relation:ast)
  =/  names=(list @tas)
    ?.  =(%sys db)
      sys-view-names
    [%databases sys-view-names]
  %-  ~(gas by *(map @tas relation:ast))
  %+  turn  names
  |=  name=@tas
  [name (read-relation db %sys name ~ as-of)]
::
++  table-names
  ::  [namespace name] for every table in the database,
  ::  optionally restricted to one namespace
  |=  [db=@tas ns=(unit @tas) as-of=(unit @da)]
  ^-  (list [ns=@tas name=@tas])
  =/  tables=relation:ast  (read-relation db %sys %tables ~ as-of)
  %+  murn  data-rows.tables
  |=  row=data-row:ast
  ^-  (unit [@tas @tas])
  ?.  ?=(%indexed-row -.row)  ~
  =/  row-ns=@tas  `@tas`(~(got by data.row) %namespace)
  ?:  &(?=(^ ns) !=(u.ns row-ns))  ~
  `[row-ns `@tas`(~(got by data.row) %name)]
::
++  read-relation
  ::  execute FROM <db>.<ns>.<relation> [AS OF <time>]
  ::  SELECT { * | <column> [, <column> ...] }
  |=  $:  db=@tas
          ns=@tas
          rel=@tas
          columns=(list @ta)
          as-of=(unit @da)
      ==
  ^-  relation:ast
  =/  select=tape
    ?~  columns  "*"
    (zing (join ", " (turn columns trip)))
  =/  source=tape  "{(trip db)}.{(trip ns)}.{(trip rel)}"
  (run-query db "FROM {source}{(as-of-tape as-of)} SELECT {select}")
::
++  as-of-tape
  |=  as-of=(unit @da)
  ^-  tape
  ?~  as-of  ""
  " AS OF {(date-tape u.as-of)}"
::
++  run-query
  ::  parse and execute a single query, extracting its relation;
  ::  +process-cmds applies the same security as poked commands
  |=  [db=@tas urql=tape]
  ^-  relation:ast
  =/  r=[results=(list cmd-result:ast) =server]
    (process-cmds(state state, bowl bowl) (parse-urql db urql))
  ~|  "scry: query returned no relation: {urql}"
  ?~  results.r  !!
  =/  rs=(list result:ast)  +.i.results.r
  |-  ^-  relation:ast
  ?~  rs  !!
  ?:  ?=(%relations -.i.rs)
    ?~  +.i.rs  !!
    i.+.i.rs
  $(rs t.rs)
--
