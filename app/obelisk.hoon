/-  *obelisk, ast
/+  default-agent, dbug, *obelisk, *parse
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  %0 
      =databases
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
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?=(%obelisk-action mark)
  =/  act  !<(action vase)
  ?-    -.act
  ::
  %tape
    =/  res  %:  process-cmds
                 databases
                 bowl
                 (parse(default-database +<.act) +>.act)
                 ==
    ~&  >  "results:  {<-.res>}"
    :_  this(databases +.res)
    ::https://github.com/urbit/urbit/issues/6692
    :~  [%give %fact ~[/databases] %obelisk-result !>(-.res)]
        [%give %kick ~[/databases] ~]
    ==
  ::
  %commands
    =/  res  (process-cmds databases bowl +.act)
    ~&  >  "results:  {<-.res>}"
    :_  this(databases +.res)
    :~  [%give %fact ~[/databases] %obelisk-result !>(-.res)]
        [%give %kick ~[/databases] ~]
    ==
  ::
  %tape-create-db
    ?.  =(our.bowl src.bowl)  ~|("database must be created by local agent" !!)
    =/  res  %:  new-database 
                 databases 
                 bowl 
                 -:(parse(default-database 'dummy') +.act)
             ==
    :_
      %=  this
        databases  -.res
      ==
    :~  [%give %fact ~[/databases] %obelisk-result !>(+.res)]
        [%give %kick ~[/databases] ~]
    ==
  ::
  %cmd-create-db
    ?.  =(our.bowl src.bowl)  ~|("database must be created by local agent" !!)
    =/  res  (new-database databases bowl +.act)
    :_  this(databases -.res)
    :~  [%give %fact ~[/databases] %obelisk-result !>(+.res)]
        [%give %kick ~[/databases] ~]
    ==
  ==
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
