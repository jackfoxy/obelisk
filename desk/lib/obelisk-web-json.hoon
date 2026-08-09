::  Typed JSON boundary for %obelisk-web.
::
/-  web=obelisk-web
|%
::
++  max-body-bytes  1.048.576
::
++  json-text
  |=  jon=json
  ^-  @t
  (en:json:html jon)
::
++  path-json
  |=  path=relative-path:web
  ^-  json
  :-  %a
  (turn path |=(part=@ta s+part))
::
++  field
  |=  [key=@t jon=json]
  ^-  (unit json)
  ?.  ?=(%o -.jon)  ~
  (~(get by p.jon) key)
::
++  text-field
  |=  [key=@t jon=json]
  ^-  (unit @t)
  =/  val=(unit json)  (field key jon)
  ?~  val  ~
  =/  parsed=(each @t tang)
    (mule |.((so:dejs:format u.val)))
  ?:(?=(%.n -.parsed) ~ `p.parsed)
::
++  path-field
  |=  [key=@t jon=json]
  ^-  (unit relative-path:web)
  =/  val=(unit json)  (field key jon)
  ?~  val  ~
  =/  parsed=(each relative-path:web tang)
    %-  mule  |.
    =/  parts=(list @t)  ((ar so):dejs:format u.val)
    (turn parts |=(part=@t ;;(@ta part)))
  ?:(?=(%.n -.parsed) ~ `p.parsed)
::
++  bool-field
  |=  [key=@t jon=json]
  ^-  (unit ?)
  =/  val=(unit json)  (field key jon)
  ?~  val  ~
  ?.  ?=(%b -.u.val)  ~
  `p.u.val
::
++  term-text
  |=  txt=@t
  ^-  @tas
  `@tas`(slav %tas txt)
::
++  request-json
  |=  req=web-request:web
  ^-  json
  ?-    -.req
      %run
    %-  pairs:enjs:format
    :~  ['type' s+'run']
        ['defaultDatabase' s+default-database.req]
        ['script' s+script.req]
    ==
  ::
      %parse
    %-  pairs:enjs:format
    :~  ['type' s+'parse']
        ['defaultDatabase' s+default-database.req]
        ['script' s+script.req]
    ==
  ::
      %schema
    %-  pairs:enjs:format
    :~  ['type' s+'schema']
        :-  'defaultDatabase'
        ?~(default-database.req ~ s+u.default-database.req)
    ==
  ::
      %file-browse
    %-  pairs:enjs:format
    ~[['type' s+'file-browse'] ['path' (path-json path.req)]]
  ::
      %file-load
    %-  pairs:enjs:format
    ~[['type' s+'file-load'] ['path' (path-json path.req)]]
  ::
      %file-save
    %-  pairs:enjs:format
    :~  ['type' s+'file-save']
        ['path' (path-json path.req)]
        ['content' s+content.req]
        ['overwrite' b+overwrite.req]
    ==
  ==
::
++  request-from-json
  ::  Decode a request; any missing or ill-typed field crashes into ~.
  ::
  |=  jon=json
  ^-  (unit web-request:web)
  =/  parsed=(each web-request:web tang)
    %-  mule  |.
    ^-  web-request:web
    =/  kind=@t  (need (text-field 'type' jon))
    ?:  =(kind 'run')
      =/  database=@t  (need (text-field 'defaultDatabase' jon))
      =/  script=@t  (need (text-field 'script' jon))
      [%run (term-text database) script]
    ?:  =(kind 'parse')
      =/  database=@t  (need (text-field 'defaultDatabase' jon))
      =/  script=@t  (need (text-field 'script' jon))
      [%parse (term-text database) script]
    ?:  =(kind 'schema')
      =/  database=(unit @t)  (text-field 'defaultDatabase' jon)
      [%schema ?~(database ~ `(term-text u.database))]
    ?:  =(kind 'file-browse')
      [%file-browse (need (path-field 'path' jon))]
    ?:  =(kind 'file-load')
      [%file-load (need (path-field 'path' jon))]
    ?:  =(kind 'file-save')
      :*  %file-save
          (need (path-field 'path' jon))
          (need (text-field 'content' jon))
          (need (bool-field 'overwrite' jon))
      ==
    !!
  ?:(?=(%.n -.parsed) ~ `p.parsed)
::
++  request-from-text
  |=  txt=@t
  ^-  (unit web-request:web)
  =/  jon=(unit json)  (de:json:html txt)
  ?~  jon  ~
  (request-from-json u.jon)
::
++  request-matches
  |=  [operation=api-operation:web request=web-request:web]
  ^-  ?
  =(operation -.request)
::
++  key-json
  |=  key=key-dto:web
  ^-  json
  %-  pairs:enjs:format
  ~[['ordinal' n+(scot %ud ordinal.key)] ['ascending' b+ascending.key]]
::
++  column-json
  |=  column=column-dto:web
  ^-  json
  %-  pairs:enjs:format
  :~  ['name' s+name.column]
      ['aura' s+aura.column]
      ['ordinal' n+(scot %ud ordinal.column)]
      ['key' ?~(key.column ~ (key-json u.key.column))]
  ==
::
++  relation-json
  |=  relation=relation-dto:web
  ^-  json
  %-  pairs:enjs:format
  :~  ['database' s+database.relation]
      ['namespace' s+namespace.relation]
      ['name' s+name.relation]
      ['kind' s+kind.relation]
      ['columns' [%a (turn columns.relation column-json)]]
  ==
::
++  namespace-json
  |=  namespace=namespace-dto:web
  ^-  json
  %-  pairs:enjs:format
  :~  ['name' s+name.namespace]
      ['relations' [%a (turn relations.namespace relation-json)]]
  ==
::
++  database-json
  |=  database=database-dto:web
  ^-  json
  %-  pairs:enjs:format
  :~  ['name' s+name.database]
      ['default' b+default.database]
      ['namespaces' [%a (turn namespaces.database namespace-json)]]
  ==
::
++  schema-json
  |=  schema=schema-dto:web
  ^-  json
  %-  pairs:enjs:format
  :~  ['defaultDatabase' s+default-database.schema]
      ['databases' [%a (turn databases.schema database-json)]]
  ==
::
++  result-column-json
  |=  column=result-column-dto:web
  ^-  json
  %-  pairs:enjs:format
  ~[['name' s+name.column] ['aura' s+aura.column]]
::
++  result-cell-json
  |=  cell=result-cell-dto:web
  ^-  json
  %-  pairs:enjs:format
  ~[['name' s+name.cell] ['aura' s+aura.cell] ['value' s+value.cell]]
::
++  result-set-json
  |=  result-set=result-set-dto:web
  ^-  json
  %-  pairs:enjs:format
  :~  :-  'columns'
      [%a (turn columns.result-set result-column-json)]
      :-  'rows'
      :-  %a
      %+  turn  rows.result-set
      |=  row=(list result-cell-dto:web)
      [%a (turn row result-cell-json)]
  ==
::
++  result-json
  |=  result=result-dto:web
  ^-  json
  =/  kind=@t  `@t`-.result
  %-  pairs:enjs:format
  :~  ['type' s+kind]
      :-  'value'
      ?-  -.result
        ?(%action %relation-name %message %relations %select-relation)
          s+value.result
        %vector-count  n+(scot %ud value.result)
        ?(%server-time %security-time %schema-time %data-time)
          s+(scot %da value.result)
        %result-set  (result-set-json value.result)
      ==
  ==
::
++  command-json
  |=  command=command-dto:web
  ^-  json
  %-  pairs:enjs:format
  :~  ['index' n+(scot %ud index.command)]
      ['results' [%a (turn results.command result-json)]]
  ==
::
++  file-entry-json
  |=  entry=file-entry-dto:web
  ^-  json
  %-  pairs:enjs:format
  ~[['path' (path-json path.entry)] ['kind' s+kind.entry]]
::
++  error-json
  |=  error=web-error:web
  ^-  json
  %-  pairs:enjs:format
  :~  ['code' s+code.error]
      ['status' n+(scot %ud status.error)]
      ['message' s+message.error]
      ['retryable' b+retryable.error]
      ['details' [%a (turn details.error |=(detail=@t s+detail))]]
  ==
::
++  response-json
  |=  response=web-response:web
  ^-  json
  ?-    -.response
      %run
    %-  pairs:enjs:format
    :~  ['type' s+'run']
        ['commands' [%a (turn commands.response command-json)]]
        ['schemaChanged' b+schema-changed.response]
    ==
  ::
      %parse
    %-  pairs:enjs:format
    :~  ['type' s+'parse']
        ['commands' [%a (turn commands.response |=(cmd=@t s+cmd))]]
        ['text' s+text.response]
    ==
  ::
      %schema
    %-  pairs:enjs:format
    ~[['type' s+'schema'] ['value' (schema-json value.response)]]
  ::
      %file-list
    %-  pairs:enjs:format
    :~  ['type' s+'file-list']
        ['entries' [%a (turn entries.response file-entry-json)]]
    ==
  ::
      %file
    %-  pairs:enjs:format
    :~  ['type' s+'file']
        ['path' (path-json path.response)]
        ['content' s+content.response]
    ==
  ::
      %saved
    %-  pairs:enjs:format
    ~[['type' s+'saved'] ['path' (path-json path.response)]]
  ::
      %error
    %-  pairs:enjs:format
    ~[['type' s+'error'] ['error' (error-json value.response)]]
  ==
--
