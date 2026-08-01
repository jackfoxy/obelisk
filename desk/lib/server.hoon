=,  eyre
|%
++  app
  |%
  ::
  ::  Produce Eyre's header, body, and completion cards.
  ::
  ++  give-simple-payload
    |=  [eyre-id=@ta payload=simple-payload:http]
    ^-  (list card:agent:gall)
    =/  header-cage
      [%http-response-header !>(response-header.payload)]
    =/  data-cage
      [%http-response-data !>(data.payload)]
    :~  [%give %fact ~[/http-response/[eyre-id]] header-cage]
        [%give %fact ~[/http-response/[eyre-id]] data-cage]
        [%give %kick ~[/http-response/[eyre-id]] ~]
    ==
  --
--
