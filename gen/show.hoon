::  delayed tape
/-  ast
/+  show-me, parse
!:
:-  %say
::|=  [[* eny=@uvJ *] [length=@ud ~] *]
|=  [[now=@da eny=@uvJ bec=*] [length=@ud ~] *]
:-  %noun
::^-  (list command:ast)
::=/  x=tape  $.show-me
::(parse:parse(default-database 'db1') x)
^-  @ud
(lent $.show-me)
