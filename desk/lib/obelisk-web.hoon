::  Pure state lifecycle helpers for %obelisk-web.
::
/-  web=obelisk-web
|%
::
++  empty-durable-state
  ^-  durable-state:web
  ~
::
++  empty-transient-state
  ^-  transient-state:web
  :*  %unbound
      0
      ~
      ~
      ~
  ==
::
++  max-readiness-failures
  ^-  @ud
  3
::
++  readiness-delay
  ^-  @dr
  ~s1
::
++  readiness-step
  |=  [live=? failures=@ud]
  ^-  readiness-decision:web
  ?:  live
    [%ready ~]
  =/  next-failures=@ud  +(failures)
  ?:  (lth next-failures max-readiness-failures)
    [%retry next-failures]
  [%exhausted ~]
::
++  empty-saved-state
  ^-  saved-state-0:web
  [%0 empty-durable-state]
::
++  make-live-state
  |=  durable=durable-state:web
  ^-  live-state:web
  [%0 durable empty-transient-state]
::
++  empty-live-state
  ^-  live-state:web
  (make-live-state empty-durable-state)
::
++  save-state
  |=  state=live-state:web
  ^-  saved-state-0:web
  [%0 durable.state]
::
++  migrate-saved-state
  |=  old=versioned-saved-state:web
  ^-  saved-state-0:web
  ?-  -.old
    %0  old
  ==
::
++  load-state
  |=  old=versioned-saved-state:web
  ^-  live-state:web
  (make-live-state durable:(migrate-saved-state old))
::
++  load-vase
  |=  old-vase=vase
  ^-  (each live-state:web tang)
  %-  mule  |.
  =/  old  !<(versioned-saved-state:web old-vase)
  (load-state old)
::
++  page
  ^-  @t
  %-  crip
  %-  en-xml:html
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;title: Obelisk
      ;link(rel "stylesheet", href "/apps/obelisk/app.css");
      ;script(src "/apps/obelisk/app.js", defer "");
    ==
    ;body
      ;main#obelisk-app
        ;h1: Obelisk
        ;p: Native Sail workbench loading…
      ==
    ==
  ==
::
++  css
  ^-  @t
  '''
  :root {
    color-scheme: light dark;
    font-family: ui-monospace, monospace;
  }

  html, body {
    height: 100%;
    margin: 0;
  }

  #obelisk-app {
    box-sizing: border-box;
    min-height: 100%;
    padding: 1.5rem;
  }
  '''
::
++  javascript
  ^-  @t
  '''
  document.documentElement.dataset.obelisk = 'ready';
  '''
--
