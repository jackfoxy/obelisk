::  generate password
!:
:-  %say
::|=  [[* eny=@uvJ *] [length=@ud ~] *]
|=  [[now=@da eny=@uvJ bec=*] [length=@ud ~] [bet=@ud ~]]
:-  %noun
^-  tape
=/  chars  (weld (weld (weld (weld (weld (gulf 'a' 'k') (gulf 'm' 'z')) (gulf 'A' 'H')) (gulf 'J' 'N')) (gulf 'P' 'Z')) (gulf '0' '9'))
=/  pw=tape  ~
=/  rng  ~(. og eny)
|-
?:  =(length 0)  pw
=^  val  rng  (rads:rng (lent chars))
$(pw [(snag val chars) pw], length (sub length 1))
