# Performance

## Parse, INSERT, and SELECT performance on sample database

Unscientific performance measurements of parsing, inserting, and querying sample data using the `animal-shelter` sample database in v0.7-beta.

Timings use the `%bout` hint and are typical of many observed iterations.

The measurements were taken on a comet 2GB loom, 409k, vere 4.3, executing a single urQL script running under Mint Linux on a 3rd generation Intel Core i7 with 32GB of RAM. The script included CREATE TABLE before each INSERT. Only the INSERT was timed.

Parsing is the step of applying the %obelisk parser to an urQL INSERT script command, producing an AST object.

Inserting is the step of applying the resulting %obelisk INSERT API data structure to the %obelisk run-time. Hence parsing can be skipped when working directly with the API. Of course the host program still must construct the data structure.

The smaller table loads of the sample database have been omitted. 

Other than rows and columns the major variable is the table column types; and because of this variable nature per row and per cell performance is not perfectly linear.

| TABLE | Rows | Columns | Cells | Parse (ms) | Insert (ms) | Parse/Row (ms) | Parse/Cell (ms) | Insert/Row (ms) | Insert/Cell (ms) |
|-------|------|---------|-------|------------|-------------|----------------|-----------------|-----------------|------------------|
| adoptions | 70 | 5 | 350 | 43.268 | 8.163 | 0.618 | 0.124 | 0.117 | 0.023 |
|    @t,@t,@t,@da,@ud |
| vaccinations | 95 | 7 | 665 | 81.239 | 11.397 | 0.855 | 0.122 | 0.120 | 0.017 |
| @t,@t,@da,@t,@t,@t,@t |
| animals | 100 | 8 | 800 | 81.000 | 14.216 | 0.810 | 0.101 | 0.142 | 0.018 |
| @t,@t,@t,@t,@t,@da,@t,@da |
| common-person-names | 100 | 4 | 400 | 39.041 | 7.041 | 0.390 | 0.098 | 0.070 | 0.018 |
| @ud,@t,@t,@t |
| persons | 120 | 8 | 960 | 107.424 | 27.985 | 0.895 | 0.112 | 0.233 | 0.029 |
| @t,@t,@t,@da,@t,@t,@t,@t |
| common-animal-names | 300 | 4 | 1,200 | 106.006 | 26.669 | 0.353 | 0.088 | 0.089 | 0.022 |
| @t,@ud,@t,@t |
| breeds | 469 | 3 | 1,407 | 268.252 | 125.968 | 0.572 | 0.191 | 0.269 | 0.090 |
| @t,@t,@t |
| calendar-us-fed-holiday | 601 | 2 | 1,202 | 172.648 | 39.468 | 0.287 | 0.144 | 0.066 | 0.033 |
| @da,@t |
| cities | 4,065 | 4 | 16,260 | 1,862.969 | 763.885 | 0.458 | 0.115 | 0.188 | 0.047 |
| @t,@t,@t,@ud |
| city-zip-codes | 15,503 | 3 | 46,509 | 4,050.402 | 2,977.670 | 0.261 | 0.087 | 0.192 | 0.064 |
| @t,@t,@t  |
| calendar | 21,916 | 9 | 197,244 | 25,116.182 | 2,430.198 | 1.146 | 0.127 | 0.111 | 0.012 |
| @da,@ud,@ud,@t,@ud,@t,@ud,@ud,@ud |

#### Conclusions

Parsing and insertion is close to linear in number of cells, with cords (@t) and especially long cords having the most impact.
The insert performance of city-zip-codes is noteworthy, probably explained by a predominance of larger values in @t columns.

## Parse and SELECT performance on sample database

#### SELECT * from large table

FROM reference.calendar
SELECT *

parse: ms/6.093
query: s/2.043

```
%obelisk-result:
  %results
    [ %action 'SELECT' ]
    %result-set
      date  year  month  month-name  day  day-name  day-of-year  weekday  year-week
      ~1993.12.9  1.993  12  December  9  Thursday  343  5  50
      ~2034.11.30  2.034  11  November  30  Thursday  334  5  48
      ~2045.5.21  2.045  5  May  21  Sunday  141  1  21
      ~2003.4.13  2.003  4  April  13  Sunday  103  1  16
      ~2016.5.4  2.016  5  May  4  Wednesday  125  4  19
      ~2012.5.20  2.012  5  May  20  Sunday  141  1  21
      ~1995.1.27  1.995  1  January  27  Friday  27  6  4
      ~2001.11.23  2.001  11  November  23  Friday  327  6  47
      ~2026.5.19  2.026  5  May  19  Tuesday  139  3  21
     ...
      ~2044.4.9  2.044  4  April  9  Saturday  100  7  15
    [ %server-time ~2026.4.28..17.19.20..e4d8 ]
    [ %relation 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %vector-count 21.916 ]
```

#### SELECT column from large table

FROM reference.calendar
SELECT day-name

parse: ms/4.822
query: s/1.067

```
%obelisk-result:
  %results
    [ %action 'SELECT' ]
    %result-set
      day-name
      Tuesday
      Thursday
      Wednesday
      Saturday
      Friday
      Monday
      Sunday
    [ %server-time ~2026.4.28..17.22.07..ee8c ]
    [ %relation 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %vector-count 7 ]
```

#### Generating random number on large table select

FROM animal-shelter.reference.calendar
SCALARS rando RAND(.~0, .~1000) * .~0.001 END 
SELECT rando, *

parse: ms/12.547
query: s/6.592.039

```
%obelisk-result:
  %results
    [ %message 'warning: results are non-deterministic' ]
    [ %action 'SELECT' ]
    %result-set
      rando  date  year  month  month-name  day  day-name  day-of-year  weekday  year-week
      .~0.9289999999999999  ~2028.8.20  2.028  8  August  20  Sunday  233  1  35
      .~0.075  ~2041.6.28  2.041  6  June  28  Friday  179  6  26
      .~0.881  ~2043.3.21  2.043  3  March  21  Saturday  80  7  12
      .~0.19599999999999998  ~1997.8.17  1.997  8  August  17  Sunday  229  1  34
      .~0.485  ~2009.11.15  2.009  11  November  15  Sunday  319  1  47
      .~0.412  ~1999.8.18  1.999  8  August  18  Wednesday  230  4  34
      .~0.7729999999999999  ~2010.12.21  2.010  12  December  21  Tuesday  355  3  52
      .~0.698  ~2035.9.25  2.035  9  September  25  Tuesday  268  3  39
      .~0.412  ~2047.12.6  2.047  12  December  6  Friday  340  6  49
      ...
      .~0.26099999999999995  ~2033.2.11  2.033  2  February  11  Friday  42  6  7
    [ %server-time ~2026.4.28..18.52.26..8c0f ]
    [ %relation 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %vector-count 21.916 ]
```

#### Select system view

FROM animal-shelter.sys.tables
SELECT namespace, name, agent, tmsp, row-count

parse: ms/17.520
query: ms/8.371

```
%obelisk-result:
  %results
    [ %action 'SELECT' ]
    %result-set
      namespace  name  agent  tmsp  row-count
      reference  federal-holidays-floating  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  6
      reference  species  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  5
      reference  calendar  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  21.916
      reference  common-street-names  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  50
      reference  species-vital-signs-ranges  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  3
      dbo  vaccinations  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  95
      dbo  animals-breed  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  32
      reference  calendar-us-fed-holiday  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  601
      dbo  adoptions  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  70
      ...
      reference  federal-holidays-fixed  ~./gall/dojo  ~2026.4.28..16.13.01..89bb  4
    [ %server-time ~2026.4.28..17.54.19..4404 ]
    [ %relation 'animal-shelter.sys.tables' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %vector-count 25 ]
```

#### Natural JOIN on primary keys

21,916 X 601 rows

FROM reference.calendar T1
JOIN reference.calendar-us-fed-holiday T2
WHERE T1.date BETWEEN ~2025.1.1 AND ~2025.12.31
SELECT T1.date, day-name, us-federal-holiday

parse: ms/12.915
query: ms/122.265

```
%obelisk-result:
  %results
    [ %action 'SELECT' ]
    %result-set
      date  day-name  us-federal-holiday
      ~2025.1.1  Wednesday  New Year's Day
      ~2025.5.26  Monday  Memorial Day
      ~2025.10.13  Monday  Columbus Day
      ~2025.12.25  Thursday  Christmas Day
      ~2025.9.1  Monday  Labor Day
      ~2025.11.27  Thursday  Thanksgiving Day
      ~2025.2.17  Monday  Washington's Birthday
      ~2025.7.4  Friday  Independence Day
      ~2025.11.11  Tuesday  Veterans Day
      ~2025.1.20  Monday  Birthday of Martin Luther King Jr.
    [ %server-time ~2025.4.7..20.52.53..d6b4 ]
    [ %relation 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2025.4.7..18.19.48..f509 ]
    [ %data-time ~2025.4.7..18.19.48..f509 ]
    [ %relation 'animal-shelter.reference.calendar-us-fed-holiday' ]
    [ %schema-time ~2025.4.7..18.19.48..f509 ]
    [ %data-time ~2025.4.7..18.19.48..f509 ]
    [ %vector-count 10 ]
```

#### Natural JOIN no indices

21,916 X 4 rows

FROM reference.calendar ".
"JOIN reference.federal-holidays-fixed ".
"SELECT date, month-name, day-name, holiday, day-of-month

parse: ms/11.037
query: ms/432.952

```
%obelisk-result:
  %results
    [ %action 'SELECT' ]
    %result-set
      date  month-name  day-name  holiday  day-of-month
      ~2046.12.16  December  Sunday  Christmas Day  25
      ~2020.7.21  July  Tuesday  Independence Day  4
      ~1996.12.5  December  Thursday  Christmas Day  25
      ~1998.7.26  July  Sunday  Independence Day  4
      ~2035.7.13  July  Friday  Independence Day  4
      ~2048.12.23  December  Wednesday  Christmas Day  25
      ~2032.12.11  December  Saturday  Christmas Day  25
      ~2040.7.17  July  Tuesday  Independence Day  4
      ~2003.7.19  July  Saturday  Independence Day  4
      ...
      ~1991.11.19  November  Tuesday  Veterans Day  11
    [ %server-time ~2026.4.28..17.43.50..0083 ]
    [ %relation 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %relation 'animal-shelter.reference.federal-holidays-fixed' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %vector-count 7.381 ]

```

#### JOIN ON predicate, partial primary key

4,065 X 15,503 rows

FROM reference.cities T1
JOIN reference.city-zip-codes T2
ON T1.state = T2.state AND T1.city = T2.city
WHERE T1.population > 100000
SELECT T1.state, T1.city, T1.county, T1.population, T2.zip-code

parse: ms/26.533
query: ms/663.616

```
%obelisk-result:
  %results
    [ %action 'SELECT' ]
    %result-set
      state  city  county  population  zip-code
      Texas  Dallas  Dallas  5.668.165  75249
      Texas  Amarillo  Potter  204.357  79117
      Texas  El Paso  El Paso  794.344  88549
      Arizona  Tucson  Pima  875.284  85751
      Maryland  Baltimore  Baltimore  2.205.092  21297
      California  San Diego  San Diego  3.084.174  92027
      Texas  Lubbock  Lubbock  259.946  79412
      Massachusetts  Boston  Suffolk  4.208.580  02126
      Puerto Rico  Carolina  Carolina  139.735  00983
      ...
      New York  Buffalo  Erie  1.004.655  14214
    [ %server-time ~2026.4.28..18.04.11..7338 ]
    [ %relation 'animal-shelter.reference.cities' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %relation 'animal-shelter.reference.city-zip-codes' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %vector-count 8.025 ]
```

#### JOIN ON predicate, no indices

21,916 X 6 rows

FROM reference.calendar T1
JOIN reference.federal-holidays-floating T2
ON T1.month = T2.month AND T1.weekday = T2.day-of-week
WHERE T1.day >= T2.date-min AND T1.day <= T2.date-max
SELECT T1.date, T1.year, T1.month-name, T1.day, T1.day-name, T2.holiday

parse: ms/15.577
query: ms/266.500

```
%obelisk-result:
  %results
    [ %action 'SELECT' ]
    %result-set
      date  year  month-name  day  day-name  holiday
      ~2027.5.31  2.027  May  31  Monday  Memorial Day
      ~2029.2.19  2.029  February  19  Monday  Washington\\\\\\'s Birthday
      ~2026.1.19  2.026  January  19  Monday  Birthday of Martin Luther King Jr.
      ~1990.2.19  1.990  February  19  Monday  Washington\\\\\\'s Birthday
      ~1999.9.6  1.999  September  6  Monday  Labor Day
      ~2002.2.18  2.002  February  18  Monday  Washington\\\\\\'s Birthday
      ~2032.10.11  2.032  October  11  Monday  Columbus Day
      ~2034.1.16  2.034  January  16  Monday  Birthday of Martin Luther King Jr.
      ~1994.9.5  1.994  September  5  Monday  Labor Day
      ..."
      ~1996.11.28  1.996  November  28  Thursday  Thanksgiving Day
    [ %server-time ~2026.4.28..18.10.20..eac2 ]
    [ %relation 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %relation 'animal-shelter.reference.federal-holidays-floating' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %vector-count 360 ]
```

#### JOIN ON predicate, no indices, large result set

4,065 X 15,503 rows

FROM reference.cities T1
JOIN reference.city-zip-codes T2
ON T1.city = T2.city                 :: cannot use primary key
WHERE T1.population > 500000
SELECT T1.state, T1.city, T1.county, T1.population, T2.zip-code

parse: ms/12.018
query: ms/589.860

```
%obelisk-result:
  %results
    [ %action 'SELECT' ]
    %result-set
      state  city  county  population  zip-code
      Texas  Dallas  Dallas  5.668.165  75249
      Texas  El Paso  El Paso  794.344  88549
      Arizona  Tucson  Pima  875.284  85751
      Maryland  Baltimore  Baltimore  2.205.092  21297
      California  San Diego  San Diego  3.084.174  92027
      South Carolina  Columbia  Richland  640.502  21046
      Massachusetts  Boston  Suffolk  4.208.580  02126
      Texas  Dallas  Dallas  5.668.165  75089
      Indiana  Indianapolis  Marion  1.659.305  46239
      ...
      New York  Buffalo  Erie  1.004.655  14214
    [ %server-time ~2026.4.28..18.23.41..7b8a ]
    [ %relation 'animal-shelter.reference.cities' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %relation 'animal-shelter.reference.city-zip-codes' ]
    [ %schema-time ~2026.4.28..16.13.01..89bb ]
    [ %data-time ~2026.4.28..16.13.01..89bb ]
    [ %vector-count 4.795 ]
```
