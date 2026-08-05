::  Shared state and boundary types for %obelisk-web.
::
/-  ast=obelisk-ast
|%
::
::  +|  Saved and Live State
::
+$  durable-state  ~
::
+$  saved-state-0  [%0 durable=durable-state]
::
+$  versioned-saved-state  $%(saved-state-0)
::
+$  binding-state
  $~  %unbound
  ?(%unbound %binding %bound)
::
+$  request-id  @ud
::
+$  transient-state
  $:  binding=binding-state
      next-request-id=request-id
      queue=(list queued-request)
      active=(unit active-obelisk)
      readiness=(unit pending-readiness)
      file-save=(unit pending-file-save)
  ==
::
+$  live-state
  $:  %0
      durable=durable-state
      transient=transient-state
  ==
::
::  +|  HTTP Work
::
+$  api-operation
  ?(%run %parse %schema %file-browse %file-load %file-save)
::
+$  relative-path  (list @ta)
::
+$  web-request
  $%  [%run default-database=@tas script=@t]
      [%parse default-database=@tas script=@t]
      [%schema default-database=(unit @tas)]
      [%file-browse path=relative-path]
      [%file-load path=relative-path]
      $:  %file-save
          path=relative-path
          content=@t
          overwrite=?
      ==
  ==
::
+$  queued-request
  $:  request-id=request-id
      eyre-id=@ta
      received-at=@da
      request=web-request
  ==
::
+$  pending-file-save
  $:  eyre-id=@ta
      path=relative-path
      content=@t
      verify-wire=wire
      timeout-wire=wire
      desk=desk
  ==
::
+$  pending-readiness
  $:  job=queued-request
      failures=@ud
      retry-wire=wire
  ==
::
+$  readiness-decision
  $%  [%ready ~]
      [%retry failures=@ud]
      [%exhausted ~]
  ==
::
+$  obelisk-work-kind
  ?(%run-parse %run-script %parse %schema)
::
+$  obelisk-reply-kind  ?(%query %parse)
::
+$  obelisk-phase  ?(%watching %poking %waiting)
::
+$  obelisk-context
  $%  [%none ~]
      [%run commands=(list command:ast)]
      [%schema-databases requested=(unit @tas)]
      $:  %schema-details
          requested=(unit @tas)
          databases=(list @tas)
      ==
  ==
::
+$  active-obelisk
  $:  job=queued-request
      action=action:ast
      work-kind=obelisk-work-kind
      reply-kind=obelisk-reply-kind
      context=obelisk-context
      phase=obelisk-phase
      watch-wire=wire
      poke-wire=wire
      timeout-wire=wire
      retries=@ud
      stage=@ud
  ==
::
::  +|  Errors
::
+$  error-code
  $?  %bad-request
      %unauthorized
      %not-found
      %conflict
      %unprocessable
      %queue-full
      %payload-too-large
      %unsupported-media
      %internal
      %unavailable
      %timeout
  ==
::
+$  web-error
  $:  code=error-code
      status=@ud
      message=@t
      retryable=?
      details=(list @t)
  ==
::
::  +|  Schema DTOs
::
+$  key-dto
  $:  ordinal=@ud
      ascending=?
  ==
::
+$  column-dto
  $:  name=@tas
      aura=@ta
      ordinal=@ud
      key=(unit key-dto)
  ==
::
+$  relation-kind  ?(%table %view)
::
+$  relation-dto
  $:  database=@tas
      namespace=@tas
      name=@tas
      kind=relation-kind
      columns=(list column-dto)
  ==
::
+$  namespace-dto
  $:  name=@tas
      relations=(list relation-dto)
  ==
::
+$  database-dto
  $:  name=@tas
      default=?
      namespaces=(list namespace-dto)
  ==
::
+$  schema-dto
  $:  default-database=@tas
      databases=(list database-dto)
  ==
::
::  +|  Query DTOs
::
+$  export-delimiter  ?(%comma %space %tab)
::
+$  result-column-dto
  $:  name=@tas
      aura=@t
  ==
::
+$  result-cell-dto
  $:  name=@tas
      aura=@t
      value=@t
  ==
::
+$  result-set-dto
  $:  columns=(list result-column-dto)
      rows=(list (list result-cell-dto))
  ==
::
+$  result-dto
  $%  [%action value=@t]
      [%relation-name value=@t]
      [%message value=@t]
      [%vector-count value=@ud]
      [%server-time value=@da]
      [%security-time value=@da]
      [%schema-time value=@da]
      [%data-time value=@da]
      [%result-set value=result-set-dto]
      [%relations value=@t]
      [%select-relation value=@t]
  ==
::
+$  command-dto
  $:  index=@ud
      results=(list result-dto)
  ==
::
::  +|  File DTOs
::
+$  file-kind  ?(%directory %file)
::
+$  file-entry-dto
  $:  path=relative-path
      kind=file-kind
  ==
::
::  +|  API Responses
::
+$  web-response
  $%  $:  %run
          commands=(list command-dto)
          schema-changed=?
      ==
      [%parse commands=(list @t) text=@t]
      [%schema value=schema-dto]
      [%file-list entries=(list file-entry-dto)]
      [%file path=relative-path content=@t]
      [%saved path=relative-path]
      [%error value=web-error]
  ==
--
