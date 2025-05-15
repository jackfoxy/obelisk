::  unit tests on statistics
::
/-  ast, *obelisk
/+  *test, parse, utils
/=  agent  /app/obelisk
|%
::
::  Build an example bowl manually.
++  bowl
  |=  [run=@ud src=(unit @p) now=@da]
  ^-  bowl:gall
  ?~  src
    :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)] :: (our src dap sap)
        [~ ~ ~]                                          :: (wex sup sky)
        [run `@uvJ`(shax run) now [~zod %base ud+run]]   :: (act eny now byk)
    ==
  :*  [~zod (need src) %obelisk `path`(limo `path`/test-agent)]
      [~ ~ ~]
      [run `@uvJ`(shax run) now [~zod %base ud+run]]
  ==
::
::  Build a reference state mold.
+$  state
  $:  %0
      =server
      ==
--
|%
++  sample-data
  :~
  ~[[%species 'Dog'] [%adopter-email 'patrick.hughes@animalshelter.com'] [%adoption-date ~2018.8.30] [%adoption-fee 58]]
  ~[[%species 'Dog'] [%adopter-email 'justin.ruiz@hotmail.com'] [%adoption-date ~2019.10.26] [%adoption-fee 68]]
  ~[[%species 'Cat'] [%adopter-email 'patrick.hughes@animalshelter.com'] [%adoption-date ~2018.8.30] [%adoption-fee 82]]
  ==
  ::~[[%species 'Dog'] [%adopter-email 'wayne.turner@icloud.com'] [%adoption-date ~2019.7.26] [%adoption-fee 50]]
  ::~[[%species 'Rabbit'] [%adopter-email 'jesse.cox@yahoo.com'] [%adoption-date ~2017.12.16] [%adoption-fee 58]]
  ::~[[%species 'Dog'] [%adopter-email 'shirley.williams@outlook.com'] [%adoption-date ~2018.4.15] [%adoption-fee 90]]
  ::~[[%species 'Dog'] [%adopter-email 'sharon.davis@animalshelter.com'] [%adoption-date ~2018.11.18] [%adoption-fee 97]]
  ::~[[%species 'Dog'] [%adopter-email 'george.scott@hotmail.com'] [%adoption-date ~2019.2.21] [%adoption-fee 83]]
  ::~[[%species 'Dog'] [%adopter-email 'virginia.baker@gmail.com'] [%adoption-date ~2019.1.28] [%adoption-fee 66]]
  ::~[[%species 'Cat'] [%adopter-email 'karen.smith@icloud.com'] [%adoption-date ~2019.9.27] [%adoption-fee 73]]
  ::~[[%species 'Dog'] [%adopter-email 'peter.smith@hotmail.com'] [%adoption-date ~2018.9.6] [%adoption-fee 57]]
  ::~[[%species 'Dog'] [%adopter-email 'lori.smith@icloud.com'] [%adoption-date ~2019.12.29] [%adoption-fee 86]]
  ::~[[%species 'Rabbit'] [%adopter-email 'adam.brown@gmail.com'] [%adoption-date ~2018.5.27] [%adoption-fee 65]]
  ::~[[%species 'Cat'] [%adopter-email 'melissa.lopez@gmail.com'] [%adoption-date ~2019.12.15] [%adoption-fee 56]]
  ::~[[%species 'Dog'] [%adopter-email 'lisa.perez@icloud.com'] [%adoption-date ~2018.1.10] [%adoption-fee 61]]
  ::~[[%species 'Cat'] [%adopter-email 'diane.thompson@hotmail.com'] [%adoption-date ~2019.6.16] [%adoption-fee 100]]
  ::~[[%species 'Dog'] [%adopter-email 'laura.young@gmail.com'] [%adoption-date ~2019.12.30] [%adoption-fee 93]]
  ::~[[%species 'Dog'] [%adopter-email 'melissa.moore@icloud.com'] [%adoption-date ~2019.12.28] [%adoption-fee 76]]
  ::~[[%species 'Cat'] [%adopter-email 'jerry.mitchell@icloud.com'] [%adoption-date ~2018.2.23] [%adoption-fee 96]]
  ::~[[%species 'Cat'] [%adopter-email 'kevin.diaz@hotmail.com'] [%adoption-date ~2018.9.13] [%adoption-fee 97]]
  ::~[[%species 'Dog'] [%adopter-email 'julie.adams@gmail.com'] [%adoption-date ~2017.3.7] [%adoption-fee 79]]
  ::~[[%species 'Dog'] [%adopter-email 'lori.smith@icloud.com'] [%adoption-date ~2019.12.26] [%adoption-fee 54]]
  ::~[[%species 'Cat'] [%adopter-email 'gerald.reyes@animalshelter.com'] [%adoption-date ~2017.9.9] [%adoption-fee 82]]
  ::~[[%species 'Dog'] [%adopter-email 'frances.cook@yahoo.com'] [%adoption-date ~2018.12.29] [%adoption-fee 96]]
  ::~[[%species 'Cat'] [%adopter-email 'timothy.anderson@gmail.com'] [%adoption-date ~2017.11.8] [%adoption-fee 73]]
  ::~[[%species 'Rabbit'] [%adopter-email 'kathy.thomas@gmail.com'] [%adoption-date ~2019.12.24] [%adoption-fee 57]]
  ::~[[%species 'Rabbit'] [%adopter-email 'kelly.allen@hotmail.com'] [%adoption-date ~2019.1.17] [%adoption-fee 85]]
  ::~[[%species 'Dog'] [%adopter-email 'shirley.williams@outlook.com'] [%adoption-date ~2019.11.12] [%adoption-fee 84]]
  ::~[[%species 'Dog'] [%adopter-email 'wayne.turner@icloud.com'] [%adoption-date ~2018.4.1] [%adoption-fee 85]]
  ::~[[%species 'Cat'] [%adopter-email 'james.ramos@hotmail.com'] [%adoption-date ~2019.12.1] [%adoption-fee 87]]
  ::~[[%species 'Dog'] [%adopter-email 'charles.phillips@gmail.com'] [%adoption-date ~2019.7.18] [%adoption-fee 57]]
  ::~[[%species 'Dog'] [%adopter-email 'virginia.baker@gmail.com'] [%adoption-date ~2018.7.28] [%adoption-fee 54]]
  ::~[[%species 'Dog'] [%adopter-email 'mildred.gray@yahoo.com'] [%adoption-date ~2019.9.1] [%adoption-fee 99]]
  ::~[[%species 'Dog'] [%adopter-email 'richard.castillo@icloud.com'] [%adoption-date ~2018.7.7] [%adoption-fee 78]]
  ::~[[%species 'Dog'] [%adopter-email 'ryan.garcia@hotmail.com'] [%adoption-date ~2018.5.4] [%adoption-fee 65]]
  ::~[[%species 'Rabbit'] [%adopter-email 'ryan.wright@hotmail.com'] [%adoption-date ~2019.4.14] [%adoption-fee 55]]
  ::~[[%species 'Dog'] [%adopter-email 'randy.bailey@icloud.com'] [%adoption-date ~2018.6.12] [%adoption-fee 51]]
  ::~[[%species 'Dog'] [%adopter-email 'theresa.carter@icloud.com'] [%adoption-date ~2017.9.18] [%adoption-fee 87]]
  ::~[[%species 'Dog'] [%adopter-email 'roy.rogers@hotmail.com'] [%adoption-date ~2017.9.23] [%adoption-fee 62]]
  ::~[[%species 'Dog'] [%adopter-email 'richard.castillo@icloud.com'] [%adoption-date ~2018.5.21] [%adoption-fee 98]]
  ::~[[%species 'Cat'] [%adopter-email 'anna.thompson@hotmail.com'] [%adoption-date ~2019.11.11] [%adoption-fee 83]]
  ::~[[%species 'Cat'] [%adopter-email 'frances.hill@animalshelter.com'] [%adoption-date ~2019.12.13] [%adoption-fee 86]]
  ::~[[%species 'Dog'] [%adopter-email 'roger.adams@hotmail.com'] [%adoption-date ~2019.7.22] [%adoption-fee 93]]
  ::~[[%species 'Dog'] [%adopter-email 'wayne.turner@icloud.com'] [%adoption-date ~2019.7.26] [%adoption-fee 77]]
  ::~[[%species 'Cat'] [%adopter-email 'walter.edwards@icloud.com'] [%adoption-date ~2018.9.3] [%adoption-fee 98]]
  ::~[[%species 'Cat'] [%adopter-email 'bruce.harris@hotmail.com'] [%adoption-date ~2018.11.19] [%adoption-fee 79]]
  ::~[[%species 'Dog'] [%adopter-email 'doris.young@icloud.com'] [%adoption-date ~2019.8.2] [%adoption-fee 51]]
  ::~[[%species 'Rabbit'] [%adopter-email 'richard.castillo@icloud.com'] [%adoption-date ~2019.3.21] [%adoption-fee 83]]
  ::~[[%species 'Cat'] [%adopter-email 'doris.young@icloud.com'] [%adoption-date ~2019.10.13] [%adoption-fee 94]]
  ::~[[%species 'Cat'] [%adopter-email 'emily.perez@gmail.com'] [%adoption-date ~2018.6.2] [%adoption-fee 54]]
  ::~[[%species 'Dog'] [%adopter-email 'virginia.baker@gmail.com'] [%adoption-date ~2018.10.22] [%adoption-fee 54]]
  ::~[[%species 'Cat'] [%adopter-email 'roy.rogers@hotmail.com'] [%adoption-date ~2017.4.8] [%adoption-fee 66]]
  ::~[[%species 'Dog'] [%adopter-email 'margaret.campbell@hotmail.com'] [%adoption-date ~2016.6.16] [%adoption-fee 61]]
  ::~[[%species 'Dog'] [%adopter-email 'phyllis.moore@gmail.com'] [%adoption-date ~2019.3.15] [%adoption-fee 93]]
  ::~[[%species 'Dog'] [%adopter-email 'virginia.baker@gmail.com'] [%adoption-date ~2018.3.13] [%adoption-fee 95]]
  ::~[[%species 'Cat'] [%adopter-email 'scott.gutierrez@gmail.com'] [%adoption-date ~2019.9.12] [%adoption-fee 64]]
  ::~[[%species 'Dog'] [%adopter-email 'charles.phillips@gmail.com'] [%adoption-date ~2019.1.6] [%adoption-fee 61]]
  ::~[[%species 'Dog'] [%adopter-email 'jesse.cox@yahoo.com'] [%adoption-date ~2019.4.29] [%adoption-fee 61]]
  ::~[[%species 'Dog'] [%adopter-email 'sara.nelson@icloud.com'] [%adoption-date ~2019.9.30] [%adoption-fee 54]]
  ::~[[%species 'Cat'] [%adopter-email 'patricia.wright@icloud.com'] [%adoption-date ~2019.11.21] [%adoption-fee 60]]
  ::~[[%species 'Dog'] [%adopter-email 'julie.adams@gmail.com'] [%adoption-date ~2019.8.7] [%adoption-fee 86]]
  ::~[[%species 'Dog'] [%adopter-email 'jacqueline.phillips@gmail.com'] [%adoption-date ~2016.4.23] [%adoption-fee 50]]
  ::~[[%species 'Cat'] [%adopter-email 'jonathan.mez@hotmail.com'] [%adoption-date ~2018.12.7] [%adoption-fee 85]]
  ::~[[%species 'Cat'] [%adopter-email 'bruce.cook@icloud.com'] [%adoption-date ~2018.2.9] [%adoption-fee 55]]
  ::~[[%species 'Cat'] [%adopter-email 'frances.cook@yahoo.com'] [%adoption-date ~2018.12.29] [%adoption-fee 51]]
  ::~[[%species 'Dog'] [%adopter-email 'wayne.turner@icloud.com'] [%adoption-date ~2018.4.1] [%adoption-fee 73]]
  ::~[[%species 'Dog'] [%adopter-email 'jerry.mitchell@icloud.com'] [%adoption-date ~2016.9.25] [%adoption-fee 67]]
  ::~[[%species 'Cat'] [%adopter-email 'george.scott@hotmail.com'] [%adoption-date ~2019.5.23] [%adoption-fee 96]]
  ::~[[%species 'Rabbit'] [%adopter-email 'phyllis.moore@gmail.com'] [%adoption-date ~2019.11.26] [%adoption-fee 96]]
  ::~[[%species 'Rabbit'] [%adopter-email 'margaret.campbell@hotmail.com'] [%adoption-date ~2019.7.17] [%adoption-fee 75]]
  ::==

::
::  Update Table Metadata
::
::  no indexed rows
++  test-metadata-00
  %+  expect-eq
      !>  [0 ~ ~]
      !>  (update-cat:utils ~)
::
::  one indexed row
++  test-metadata-01
  =/  aa  sample-data
  =/  column-addrs  :+  n=[%adoption-date 2]
                        l=~
                        :+  n=[%adopter-email 14]
                            l=~
                            r=[[%adoption-fee 62] [[%species 252] ~ ~] ~]
  =/  column-catalog
        :+  :-  %adoption-date
                :^  %column-mta
                    addr=2
                    distinct=1
                    values=[[170.141.184.503.478.752.038.767.313.124.799.283.200 [first=0 last=0 domain=~[0]]] ~ ~]
            l=~
            :+  :-  %adopter-email
                    :^  %column-mta
                        addr=14
                        distinct=1
                        values=[[49.498.905.044.859.653.273.534.984.479.647.971.735.548.487.048.996.602.282.196.669.754.798.507.319.664 [first=0 last=0 domain=~[0]]] ~ ~]
                l=~
                :+  :-  %adoption-fee 
                        :^  %column-mta
                            addr=62
                            distinct=1
                            values=[[58 [first=0 last=0 domain=~[0]]] ~ ~]
                    :+  :-  %species
                            :^  %column-mta
                                addr=252
                                distinct=1
                                values=[[6.778.692 [first=0 last=0 domain=~[0]]] ~ ~]
                        ~
                        ~
                    r=~
  %+  expect-eq
      !>  [1 column-addrs column-catalog]
      !>  %-  update-cat:utils
              ~[[~[`@`1] (malt (turn (limo -.aa) |=(a=[@tas @] a)))]]
::
::  three indexed rows
++  test-metadata-02
  =/  aa  sample-data
  =/  column-addrs  :+  n=[%adoption-date 2]
                        l=~
                        :+  n=[%adopter-email 14]
                            l=~
                            r=[[%adoption-fee 62] [[%species 252] ~ ~] ~]
  =/  xx  %-  limo  :~  [58 [0 0 (limo ~[0])]]
                        [68 [1 1 (limo ~[1])]]
                        [82 [2 2 (limo ~[2])]]
                        ==
  =/  adoption-fee-mop
        ::(gas:((on @ [@ @ (list @)]) lth) *((mop @ [@ @ (list @)]) lth) 1^1 2^2 3^3 ~)
        (gas:((on @ value-idx) lth) *((mop @ value-idx) lth) xx)
                                             
  =/  column-catalog
        :+  :-  %adoption-date
                :^  %column-mta
                    addr=2
                    distinct=2
                    ::values=[[170.141.184.503.478.752.038.767.313.124.799.283.200 [first=0 last=0 domain=~[0]]] ~ ~]
                    values=[[key=170.141.184.504.151.335.085.090.022.344.359.936.000 val=[first=1 last=1 domain=~[1]]] ~ [[key=170.141.184.503.478.752.038.767.313.124.799.283.200 val=[first=0 last=2 domain=~[0 2]]] ~ ~]]
                    ::{ [key=170.141.184.503.478.752.038.767.313.124.799.283.200 val=[first=0 last=2 domain=~[0 2]]]
                    ::  [key=170.141.184.504.151.335.085.090.022.344.359.936.000 val=[first=1 last=1 domain=~[1]]]
                    ::}
            l=~
            :+  :-  %adopter-email
                    :^  %column-mta
                        addr=14
                        distinct=2
                        values=[[49.498.905.044.859.653.273.534.984.479.647.971.735.548.487.048.996.602.282.196.669.754.798.507.319.664 [first=0 last=2 domain=~[0 2]]] ~ [[10.481.800.856.368.594.426.519.586.349.701.518.096.515.101.215.583.073.642 [first=1 last=1 domain=~[1]]] ~ ~]]
                        ::{ [ key=10.481.800.856.368.594.426.519.586.349.701.518.096.515.101.215.583.073.642
                        ::    val=[first=1 last=1 domain=~[1]]
                        ::  ]
                        ::  [   key
                        ::    49.498.905.044.859.653.273.534.984.479.647.971.735.548.487.048.996.602.282.196.669.754.798.507.319.664
                        ::    val=[first=0 last=2 domain=~[0 2]]
                        ::  ]
                        ::}
                l=~
                :+  :-  %adoption-fee 
                        :^  %column-mta
                            addr=62
                            distinct=3
                            values=adoption-fee-mop
                            ::values=[[key=68 val=[first=1 last=1 domain=~[1]]] [[key=58 val=[first=0 last=0 domain=~[0]]] ~ ~] [[key=82 val=[first=2 last=2 domain=~[2]]] ~ ~]]
                            ::{ [key=58 val=[first=0 last=0 domain=~[0]]]
                            ::  [key=68 val=[first=1 last=1 domain=~[1]]]
                            ::  [key=82 val=[first=2 last=2 domain=~[2]]]
                            ::}

                    :+  :-  %species
                            :^  %column-mta
                                addr=252
                                distinct=2
                                values=[[6.778.692 [first=0 last=1 domain=~[0 1]]] ~ [[key=7.627.075 val=[first=2 last=2 domain=~[2]]] ~ ~]]
                                ::{[key=6.778.692 val=[first=0 last=1 domain=~[0 1]]] [key=7.627.075 val=[first=2 last=2 domain=~[2]]]}
                        ~
                        ~
                    r=~
  %+  expect-eq
      !>  [3 column-addrs column-catalog]
      !>  %-  update-cat:utils
              :~  [~[`@`1] (malt (turn (limo -.aa) |=(a=[@tas @] a)))]
                  [~[`@`2] (malt (turn (limo +<.aa) |=(a=[@tas @] a)))]
                  [~[`@`3] (malt (turn (limo +>-.aa) |=(a=[@tas @] a)))]
                  ==
--