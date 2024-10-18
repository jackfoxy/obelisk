/-  *obelisk, ast
/+  default-agent, dbug, *obelisk, *print, shoe, sole
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  %0  ~
  ==
+$  card  card:agent:shoe
+$  command  @t
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
%-  (agent:shoe command)
^-  (shoe:shoe command)
|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %n) bowl)
    leather  ~(. (default:shoe this command) bowl)
++  on-init  `this(state *state-0)
++  on-save   !>(state)
++  on-load
  |=  =old==vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-vase)
  |-
  ?-  -.old
    %0  `this(state old)
    ::  $(old [%1 +.old])
    ::  %1  `this(state old)
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  `this
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
++  command-parser
  |=  =sole-id:shoe
  ^+  |~(nail *(like [? command]))
  (stag | (boss 256 (more gon qit)))
++  on-command
  |=  [=sole-id:shoe =command]
  ^-  (quip card _this)
  :_  this
  ^-  (list card)
  :~
  :*  %pass  /obelisk-cli  %agent  [our.bowl %obelisk]  %poke
      %obelisk-action  !>([%tape %sys (trip command)])
  ==  ==
++  can-connect
  |=  =sole-id:shoe
  ^-  ?
  ?|  =(~zod src.bowl)
      (team:title [our src]:bowl)
  ==
++  on-connect
  |=  =sole-id:sole
  ^-  (quip card _this)
  :_  this
  ^-  (list card)
  :~  :+  %shoe  ~
      :-  %sole
      ^-  sole-effect:sole
      :-  %pro
      ^-  sole-prompt:sole
      :+  &  dap.bowl
      ^-  styx
      ~[[[`%br ~ `[r=0x12 g=0x78 b=0xdf]] ' urQL> ' ~]]
  ==
++  on-disconnect  on-disconnect:leather
++  tab-list       tab-list:leather
--
