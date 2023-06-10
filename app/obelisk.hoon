/-  *obelisk, ast
/+  default-agent, dbug, *obelisk, *parse
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  [%0 =databases]
  ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %n) bowl)
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
:: sending agent provenance coming soon^{TM} https://github.com/urbit/urbit/pull/6605
:: expected in kelvin 412
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?=(%obelisk-action mark)
  =/  act  !<(action vase)
  ?-    -.act
  ::
      %tape
    `this  :: (values [10 values])
  ::
      %commands
::    `this  :: (values [10 values])
    :_  this(databases (process-cmds databases bowl +<.act +>.act))
    :~  [%give %fact ~[/databases] %obelisk-response !>([%result "success"])]
    ==
  ::
      %tape-create-db
    ?:  =(our.bowl src.bowl)
      :_  this(databases (new-database databases now.bowl -:(parse(default-database 'dummy') +.act)))
::      :_  this(databases %:  new-database 
::                         databases 
::                         now.bowl 
::                         -:(parse(default-database 'dummy') +.act)
::                         ==)
      :~  [%give %fact ~[/databases] %obelisk-response !>([%result "success"])]
      ==
    ~|("database must be created by local agent" !!)
  ::
      %cmd-create-db
    ?:  =(our.bowl src.bowl)
      :_  this(databases (new-database databases now.bowl +.act))
      :~  [%give %fact ~[/databases] %obelisk-response !>([%result "success"])]
      ==
    ~|("database must be created by local agent" !!)
  ==
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
