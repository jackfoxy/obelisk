::  urui-http: eyre response helpers.
::
::  Exact asset lookup and HTTP payloads; policy belongs to the consumer.
::
|%
::
+$  asset  [content-type=@t body=octs]
::
++  respond
  ::  Preserve the supplied content type, byte length, and body bytes.
  |=  [status=@ud =asset]
  ^-  simple-payload:http
  [[status ~[['content-type' content-type.asset]]] `body.asset]
::
++  asset-route
  ::  Suffixes are literal, including '' and '/'. Ignore only the query.
  ::  First matching entry wins; no prefix or directory fallback.
  |=  [base=@t url=@t assets=(list [suffix=@t =asset])]
  ^-  (unit asset)
  =/  raw=tape  (trip url)
  =/  query  (find "?" raw)
  =/  clean=@t  ?~(query url (crip (scag u.query raw)))
  |-  ^-  (unit asset)
  ?~  assets  ~
  ?:  =(clean (cat 3 base suffix.i.assets))  `asset.i.assets
  $(assets t.assets)
::
++  require-auth
  ::  The consumer supplies its refusal, including status and body policy.
  |=  $:  authenticated=?
          payload=simple-payload:http
          refused=simple-payload:http
      ==
  ^-  simple-payload:http
  ?:  authenticated  payload
  refused
::
++  give
  ::  The three cards that answer one eyre request: header, data, kick.
  ::
  ::  Example:
  ::    (give eyre-id (respond 200 asset))
  |=  [eyre-id=@ta =simple-payload:http]
  ^-  (list card:agent:gall)
  =/  =path  /http-response/[eyre-id]
  =/  header=cage
    [%http-response-header !>(response-header.simple-payload)]
  =/  data=cage  [%http-response-data !>(data.simple-payload)]
  :~  [%give %fact ~[path] header]
      [%give %fact ~[path] data]
      [%give %kick ~[path] ~]
  ==
--
