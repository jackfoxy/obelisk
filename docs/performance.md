# Performance

## Parse, INSERT, and SELECT performance on sample database

Unscientific performance measurements of parsing, inserting, and querying sample data using the `animal-shelter` sample database in v0.5-alpha.

Timings use the `%bout` hint and are typical of many observed iterations.

The measurements were taken on a fake zod 2GB loom, 411k, vere 3.1, executing a single urQL script running under Mint Linux on a 3rd generation Intel Core i7 with 32GB of RAM. The script included CREATE TABLE before each INSERT. Only the INSERT was timed.

Parsing is the step of applying the %obelisk parser to an urQL INSERT script command, producing an AST object.

Inserting is the step of applying the %obelisk API to the INSERT data structure. Hence parsing can be skipped when working directly with the API. Of course the host program still must construct the data structure.

The smaller table loads of the sample database have been omitted. 

Other than rows and columns the major variable is the table column types. The columns are mostly of aura types @t, @ud, @da, and @rs; and because of this variable nature per row and per cell performance, especially in parsing, is not perfectly linear.

| TABLE | Rows | Columns | Cells | Parse Time | Insert Time | Parse / Row | Parse / Cell | Insert / Row | Insert / Cell |
| :---- | ---: | ------: | ----: | ---------: | ----------: | ----------: | -----------: | -----------: | ------------: |
|adoptions|	70|	5|	350|	41.69|	8.08|		0.596|	0.119|		0.115|	0.023|
|vaccinations|	95|	7|	665|	74.48|	13.04|		0.784|	0.112|		0.137|	0.020|
|animals|	100|	8|	800|	92.02|	14.46|		0.920|	0.115|		0.145|	0.018|
|common-person-names|	100|	4|	400|	38.11|	6.03|		0.381|	0.095|		0.060|	0.015|
|persons|	120|	8|	960|	101.42|	16.97|		0.845|	0.106|		0.141|	0.018|
|common-animal-names|	300|	4|	1,200|	106.48|	25.62|		0.355|	0.089|		0.085|	0.021|
|breeds|	469|	3|	1,407|	253.05|	90.10|		0.540|	0.180|		0.192|	0.064|
|calendar-us-fed-holiday|	601|	2|	1,202|	202.09|	42.66|		0.336|	0.168|		0.071|	0.035|
|cities|	4,065|	4|	16,260|	1,803.99|	784.78|		0.444|	0.111|		0.193|	0.048|
|city-zip-codes|	15,503|	3|	46,509|	3,954.35|	6,489.42|		0.255|	0.085|		0.419|	0.140|
|calendar|	21,916|	9|	197,244|	28,085.77|	2,300.30|		1.282|	0.142|		0.105|	0.012|

The insert performance of city-zip-codes is noteworthy, possibly explained by a predominance of larger values in @t columns.

## Parse and SELECT performance on sample database

### FROM reference.calendar SELECT *

parse: ms/13.604
query: s/10.539

%obelisk-result:
  %results
    [ %message 'SELECT' ]
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
    [ %server-time ~2025.4.7..20.31.17..ca98 ]
    [ %message 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2025.4.7..18.19.48..f509 ]
    [ %data-time ~2025.4.7..18.19.48..f509 ]
    [ %vector-count 21.916 ]

### FROM reference.calendar SELECT day-name

parse: ms/14.621
query: s/8.603

%obelisk-result:
  %results
    [ %message 'SELECT' ]
    %result-set
      day-name
      Tuesday
      Thursday
      Wednesday
      Saturday
      Friday
      Monday
      Sunday
    [ %server-time ~2025.4.7..20.44.08..035d ]
    [ %message 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2025.4.7..18.19.48..f509 ]
    [ %data-time ~2025.4.7..18.19.48..f509 ]
    [ %vector-count 7 ]

### JOIN

parse: ms/34.649
query: s/7.272

%obelisk-result:
  %results
    [ %message 'SELECT' ]
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
    [ %message 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2025.4.7..18.19.48..f509 ]
    [ %data-time ~2025.4.7..18.19.48..f509 ]
    [ %message 'animal-shelter.reference.calendar-us-fed-holiday' ]
    [ %schema-time ~2025.4.7..18.19.48..f509 ]
    [ %data-time ~2025.4.7..18.19.48..f509 ]
    [ %vector-count 10 ]