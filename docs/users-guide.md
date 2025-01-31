# Introduction

If you have worked with SQL, Obelisk should seem very familiar. If you have no experience with relational databases don't worry, this guide is your friend.

It is recommended to read the *Preliminaries* chapter of the Reference document before proceeding.

Examples in this article rely on the Urbit %obelisk agent which prints results to the dojo.

# Commands

Obelisk commands are DDL (Data Definition Language) commands, data manipulation commands, and Query/Selection. Commands not available in the current release are marked in the Reference. You can string commands together, delimiting with semicolons, to create scripts. Script commands execute sequentially, but all *happen at the same time* in that timestamps recorded in the system are all the same (assuming no times have been overridden). Scripts are atomic in that all commands succeed or the entire script fails. 

DDL commands define databases, their data tables and other components, data manipulation commands are responsible for the content of databases, and *SELECT* performs queries.

### DDL
| | |
|:------------ |:-------------------- |
|ALTER INDEX       |*not implemented*|
|ALTER NAMESPACE   |*not implemented*|
|ALTER TABLE       |*not implemented*|
|CREATE DATABASE   | |
|CREATE INDEX      |*not implemented*|
|CREATE NAMESPACE  | |
|CREATE TABLE      | |
|CREATE VIEW       |*not implemented*|
|DROP DATABASE     | |
|DROP INDEX        |*not implemented*|
|DROP NAMESPACE    |*not implemented*|
|DROP TABLE        | |
|DROP VIEW         |*not implemented*|

### Data Manipulation
| | |
|:------------ |:-------------------- |
|DELETE            |*not implemented*|
|INSERT            | |
|TRUNCATE TABLE    | |
|UPDATE            |*not implemented*|


### Query
SELECT

# Database Schema

## CREATE DATABASE

The first thing to do is define a database. In the dojo enter the following poke:

```
:obelisk &obelisk-action [%tape %sys "CREATE DATABASE db1"]
```

Let's review the obelisk-action:

**%tape** -- This indicates we are submitting a script in the form of a hoon tape. The alternative for this position is **%commands**, which indicates submitting a list of API commands. Submitting API commands skips the parsing step and is an advanced topic which we will not cover. But if you are interested in figuring it out for yourself, all the command APIs are in *sur/ast/hoon*.

**%sys** -- This tells the parser to insert *%sys* as the default database for any objects which we do not fully qualify. There are no such holes in CREATE DATABASE, and no user-defined databases exist at this point, so we use *%sys* for convenience. Every Obelisk server has a *%sys* database which does nothing more than track all the user-defined databases.

**CREATE DATABASE** -- The DDL to create a new user-defined database. CREATE DATABASE is all caps. This is not required. urQL key words can be mixed case, but it is *strongly* encouraged to write key words in all caps for human-readability.

**db1** -- The name we give to our new database.

The database name is in lower case, that is because all object names (database, table, view, column, etc.) follow the rules for hoon terms, i.e. their aura is *@tas*.

Aliases, which we will get to later, can be mixed case, but keeping them upper or title case helps with readability. (But we get ahead of ourselves.)

Submitting this poke will print to the dojo:

```
%obelisk-result:
  %results
    [ %message 'created database %db1' ]
    [ %server-time ~2024.9.26..21.14.00..7fc8 ]
    [ %schema-time ~2024.9.26..21.14.00..7fc8 ]
```
Every successful command returns metadata about the state of the server and effected databases. Scripts are atomic, so if there is any failure the entire script fails. Failure results in a crash with stack trace and error message.

**%results** -- One block of results for every command in a script.

**%server-time** -- The time, according to the server, the script executed. This corresponds to `now.bowl` in the agent. Unless the command was submitted with an `AS OF` clause (which overrides server time) Obelisk will record this time to any internal timestamps. In this case the time of database creation.

**%schema-time** -- In this case, since we mutated the server state, it is the time recorded for database creation. In general *%schema-time* is either the result of schema state mutation (for DDL commands) or the highest timestamp in the database for schema components directly effecting the command (in the case of data manipulation and selection commands).<sup>1</sup>

Let's look at the state of our server by querying a system view on the database schema.

```
FROM sys.sys.databases
SELECT *
```
From here on we will dispense with the full poke command and only specify the urQL script. We could have used any valid database, *%sys* or *%db1* at this point, as the default database for the script parser. The object of our query, the *databases* system view, is fully qualified by the name of the database it resides in, *%sys*, and the namespace, also *%sys*.

```
%obelisk-result:
  %results
    [ %message 'SELECT' ]
    %result-set
      database  sys-agent  sys-tmsp  data-ship  data-agent  data-tmsp
      db1  /gall/dojo  ~2024.9.26..21.14.00..7fc8  ~zod  /gall/dojo  ~2024.9.26..21.14.00..7fc8
      sys  /gall/dojo  ~2024.9.26..21.14.00..7fc8  ~zod  /gall/dojo  ~2024.9.26..21.14.00..7fc8
    [ %server-time ~2024.9.26..22.03.39..2233 ]
    [ %message 'sys.sys.databases' ]
    [ %schema-time ~2024.9.26..21.14.00..7fc8 ]
    [ %data-time ~2024.9.26..21.14.00..7fc8 ]
    [ %vector-count 2 ]
```
You see the server now has a user-defined database as well as the %sys system database, which gets created at the same time as the creation of the first user database on the server.

The first row of the *%result-set* is the column labels of the view followed by the returned data.

The formatting of *%result-set* is the result of a print utility used by the %obelisk agent. The actual format of the returned data cells is

```
[@tas dime]
```
The first atom is the column label or alias, and the *dime* is the data aura and atom.

We will talk more about selection (querying) later.

*sys.sys.databases* records a row for every event that mutates the state of the server, in other words every event that changes the state of a database's schema or data contents.

All the other system views describing database schemas are in the *%sys* namespace of each user database and documented in the Appendix of this article.

## CREATE TABLE

All user data resides in user-defined tables, so let's define some tables. Notice the commands are separated by semicolon.

```
CREATE TABLE db1..my-table-1 (col1 @t, col2 @da) PRIMARY KEY (col1) ;
CREATE TABLE dbo.my-table-2 (col1 @t, col2 @da, col3 @ud) PRIMARY KEY (col1)
```

Database objects like tables and views have names qualified by database and namespace. In standard SQL namespace is called *schema*, which gets confusing because *schema* also refers to the structure of the database. In any event *namespace* is just like *namespace* in any programming environment, a way to organize named objects where any given name may only occur once within each namespace.

In the first command we explicitly qualified the database name for table creation, but left a hole in the place for namespace. The default namespace is always *dbo*, for *database owner*. For the second command we are dependent on the parser filling in the database name from the default we specified (not shown), and we specify the namespace (which in this case is unnecessary). 

The table's columns are defined by pairs of name/aura separated by comma, and finally we need a `PRIMARY KEY`, a column or columns whose values must be unique within the table's data contents.

(Refer to the urQL reference for the full syntax of all commands.)

```
%obelisk-result:
  %results
    [ %message 'CREATE TABLE %my-table-1' ]
    [ %server-time ~2024.9.26..22.28.55..f02a ]
    [ %schema-time ~2024.9.26..22.28.55..f02a ]
  %results
    [ %message 'CREATE TABLE %my-table-2' ]
    [ %server-time ~2024.9.26..22.28.55..f02a ]
    [ %schema-time ~2024.9.26..22.28.55..f02a ]
```
Two commands and two %results blocks, all recorded at the same time.

<sup>1</sup> In the current release of Obelisk `%schema-time` is generally the time of the Table or View schema (structure definition), but once *FOREIGN KEY* is introduced it will be the time of the entire Database schema, for reasons having to do with overriding execution time and idempotence.

# Data Manipulation
## INSERT

A database with no data isn't of much use, so let's insert some data:

```
INSERT INTO my-table-1
(col1, col2)
VALUES
  ('today', ~2024.9.26)
  ('tomorrow', ~2024.9.27)
  ('next day', ~2024.9.28);
INSERT INTO my-table-2
VALUES
  ('today', ~2024.9.26, 1)
  ('tomorrow', ~2024.9.27, 2)
  ('next day', ~2024.9.28, 3);
```
Notice the difference in the two INSERT commands. In the first example we specify the columns associated with the following comma separated data, in the second we do not.

If the data in the INSERT command has columns ordered in the same order as the canonical ordering for the table (that is the order in which the columns were defined in the CREATE TABLE command), there is no need to specify column order. If the INSERT data rows have the columns in any other order, you do need to specify how the columns match up. In this case there was no need to specify columns in the first example.
```
%obelisk-result:
  %results
    [ %message 'INSERT INTO %my-table-1' ]
    [ %server-time ~2024.9.27..03.31.34..646d ]
    [ %schema-time ~2024.9.26..22.28.55..f02a ]
    [ %data-time ~2024.9.27..03.31.34..646d ]
    [ %message 'inserted:' ]
    [ %vector-count 3 ]
    [ %message 'table data:' ]
    [ %vector-count 3 ]
  %results
    [ %message 'INSERT INTO %my-table-2' ]
    [ %server-time ~2024.9.27..03.31.34..646d ]
    [ %schema-time ~2024.9.26..22.28.55..f02a ]
    [ %data-time ~2024.9.27..03.31.34..646d ]
    [ %message 'inserted:' ]
    [ %vector-count 3 ]
    [ %message 'table data:' ]
    [ %vector-count 3 ]
```
More meta data from INSERT:

**%data-time** -- timestamp of last changes to data in a table. In this case, when the data was inserted.

**%vector-count** -- count of data rows. Two cases: the count of rows inserted and the resulting count of rows in the table.

## TRUNCATE TABLE

Let's say we want to clear out the data in a table. Currently there is no DELETE command (yet). In any event DELETE is an inefficient command in every RDBMS, and Obelisk is no exception. To efficiently clear the data in a table use TRUNCATE TABLE, which always executes in O(1) time, in other words it is very fast regardless of how much data is in the table.

```
TRUNCATE TABLE my-table-1
```
```
%obelisk-result:
  %results
    [ %message 'TRUNCATE TABLE %my-table-1' ]
    [ %server-time ~2024.9.27..17.03.38..92af ]
    [ %data-time ~2024.9.27..17.03.38..92af ]
    [ %vector-count 3 ]
```
This time *%data-time* references clearing the table's data and *%vector-count* is the number of rows removed.

# Sample Database

Before we get into queries, let's load some more interesting data to work with. The Obelisk distribution comes with a sample "animal shelter" database adapted from Ami Levin's [Animal Shelter](https://github.com/ami-levin/Animal_Shelter) database for learning SQL. Ami is a SQL educator and you can find his [advanced SQL courses here](https://www.linkedin.com/learning/instructors/ami-levin).

Execute the following in the dojo to load the database. It will take a little over a minute to load.

```
:obelisk &obelisk-action [%tape %animal-shelter (reel .^(wain %cx /=obelisk=/gen/animal-shelter/all-animal-shelter/txt) |=([a=cord b=tape] (weld (trip a) b)))]
```

# Query
The simplest possible query is selecting a single literal
```
SELECT 0
```
```
%obelisk-result:
  %results
    [ %message 'SELECT' ]
    %result-set
      literal-0
      0
    [ %server-time ~2024.9.30..17.26.26..d29c ]
    [ %schema-time ~2024.9.30..14.15.21..ad17 ]
    [ %data-time ~2024.9.30..14.15.21..ad17 ]
    [ %vector-count 1 ]
```
Obelisk supports most hoon aura-formatted literals. (See the Reference document *Preliminaries*).

The system inserted a default name for the literal column. We could have specified an alias:

```
SELECT 0 AS My-Alias
```
```
%obelisk-result:
  %results
    [ %message 'SELECT' ]
    %result-set"
      my-alias
      0
    [ %server-time ~2024.9.30..17.33.22..77da ]
    [ %schema-time ~2024.9.30..14.15.21..ad17 ]
    [ %data-time ~2024.9.30..14.15.21..ad17 ]
    [ %vector-count 1 ]
```
Aliases may be entered in mixed-case, but the system will always display them in lower case. For readability it is recommended to use title-case for aliases.

Set the default database to animal-shelter and submit the following script:
```
FROM reference.calendar
SELECT *
```
Unlike the syntax in standard SQL, urQL syntax requires the `FROM` and `WHERE` clauses before SELECT.
```
%obelisk-result:
  %results
    [ %message 'SELECT' ]
    %result-set
      date  year  month  month-name  day  day-name  day-of-year  weekday  year-week
      ~1990.1.1  1.990  1  January  1  Monday  1  2  1
      ~1990.1.2  1.990  1  January  2  Tuesday  2  3  1
      ~1990.1.3  1.990  1  January  3  Wednesday  3  4  1
      ~1990.1.4  1.990  1  January  4  Thursday  4  5  1
      ~1990.1.5  1.990  1  January  5  Friday  5  6  1
      ~1990.1.6  1.990  1  January  6  Saturday  6  7  1
      ~1990.1.7  1.990  1  January  7  Sunday  7  1  2
      ~1990.1.8  1.990  1  January  8  Monday  8  2  2
      ~1990.1.9  1.990  1  January  9  Tuesday  9  3  2
      ...
      ~2050.1.1  2.050  1  January  1  Saturday  1  7  1
    [ %server-time ~2024.9.30..17.49.57..f90d ]
    [ %schema-time ~2024.9.30..14.15.21..ad17 ]
    [ %data-time ~2024.9.30..14.15.21..ad17 ]
    [ %vector-count 21.916 ]
```
According to the %vector-count there are nearly 22,000 rows in this table, but the print utility only prints the first 9 and the last one.

`SELECT *` returns all the columns of the selected object(s). This is fine for ad hoc work, but the best practice for composing production scripts is to specify every column. In a later Obelisk release ALTER TABLE can add or remove columns, in effect altering saved scripts using `SELECT *`.
```
SELECT date, year, month, month-name, day, day-name, day-of-year, weekday, year-week
```

We can select a sub-set of columns:
```
FROM reference.calendar
SELECT day-name AS Day
```
```
%obelisk-result:
  %results
    [ %message 'SELECT' ]
    %result-set
      day
      Thursday
      Saturday
      Wednesday
      Friday
      Tuesday
      Monday
      Sunday
    [ %server-time ~2024.9.30..18.07.14..afcc ]
    [ %message 'animal-shelter.reference.calendar' ]
    [ %schema-time ~2024.9.30..14.15.21..ad17 ]
    [ %data-time ~2024.9.30..14.15.21..ad17 ]
    [ %vector-count 7 ]
```
Here is another difference between Obelisk and any SQL RDBMS. Rows returned from a query are always a proper subset. In SQL you would have to specify the `DISTINCT` keyword.

Without the `ORDER BY` clause (*not yet implemented*), data rows are returned in an arbitrary order.

## The WHERE clause

As with SQL, you can filter query results with a `WHERE` clause.
```
FROM reference.calendar
WHERE day-name = 'Thursday'
SELECT *
```
```
  date  year  month  month-name  day  day-name  day-of-year  weekday  year-week
  ~1990.1.4  1.990  1  January  4  Thursday  4  5  1
  ~1990.1.11  1.990  1  January  11  Thursday  11  5  2
  ~1990.1.18  1.990  1  January  18  Thursday  18  5  3
  ~1990.1.25  1.990  1  January  25  Thursday  25  5  4
  ~1990.2.1  1.990  2  February  1  Thursday  32  5  5
  ~1990.2.8  1.990  2  February  8  Thursday  39  5  6
  ~1990.2.15  1.990  2  February  15  Thursday  46  5  7
  ~1990.2.22  1.990  2  February  22  Thursday  53  5  8
  ~1990.3.1  1.990  3  March  1  Thursday  60  5  9
  ...
  ~2049.12.30  2.049  12  December  30  Thursday  364  5  53
```
Logical operators *AND*, *OR*, and *NOT*<sup>2</sup> provide for compound predicates as with SQL.
```
FROM reference.calendar
WHERE day-name = 'nonsense'
  AND month-name = 'nonsense'
   OR day = 3
SELECT *"
```
```
  date  year  month  month-name  day  day-name  day-of-year  weekday  year-week
  ~1990.1.3  1.990  1  January  3  Wednesday  3  4  1
  ~1990.2.3  1.990  2  February  3  Saturday  34  7  5
  ~1990.3.3  1.990  3  March  3  Saturday  62  7  9
  ~1990.4.3  1.990  4  April  3  Tuesday  93  3  14
  ~1990.5.3  1.990  5  May  3  Thursday  123  5  18
  ~1990.6.3  1.990  6  June  3  Sunday  154  1  23
  ~1990.7.3  1.990  7  July  3  Tuesday  184  3  27
  ~1990.8.3  1.990  8  August  3  Friday  215  6  31
  ~1990.9.3  1.990  9  September  3  Monday  246  2  36
  ...
  ~2049.12.3  2.049  12  December  3  Friday  337  6  49
```
As would be expected the `OR` conjunction operator take precedence over `AND`.

Complex `WHERE` clauses may be defined by nesting parentheses. See the Reference document *Query* for the full syntax available for predicates.
```
FROM reference.calendar
WHERE day-name = 'nonsense'
  AND (month-name = 'nonsense'
       OR day = 3)
SELECT *
```

```
%result-set
  result set empty
```

<sup>2</sup> The `NOT` operator currently does not parse in all expected configurations due to a bug.

# Time Travel

Obelisk's ability to create and reference schema and data objects outside of the current server state is called time traveling. (See the *Time* section in the *Preliminaries* reference document.)

Almost all urQL commands support an `AS OF` clause which determines the working timestamp (the default being the current server time, *NOW*).

In terms of DDL commands, this is most useful for *back dating* new database schemas, or even future dating. Just be aware you may end up making your database unusable by future dating.

For example future dating a new database

```
CREATE DATABASE db2 AS OF ~2030.1.1
```

```
%obelisk-result:
  %results
    [ %message 'created database %db2' ]
    [ %server-time ~2024.9.29..21.14.00..7fc8 ]
    [ %schema-time ~2030.1.1 ]
```
Results in all operations on the database requiring a time subsequent to this future creation date.

```
CREATE NAMESPACE db2.ns1
```
```
...
/lib/obelisk/hoon:<[386 9].[392 36]>
"CREATE NAMESPACE: namespace %ns1 as-of schema time out of order"
/lib/obelisk/hoon:<[388 13].[392 36]>
...
```
And the database is not even visible in the current context.
```
FROM sys.sys.databases AS OF NOW SELECT *
```

```
%obelisk-result:
  %results
    [ %message 'SELECT' ]
    %result-set
      database  sys-agent  sys-tmsp  data-ship  data-agent  data-tmsp
      db1  /gall/dojo  ~2024.9.26..21.14.00..7fc8  ~zod  /gall/dojo  ~2024.9.26..21.14.00..7fc8
      sys  /gall/dojo  ~2024.9.26..21.14.00..7fc8  ~zod  /gall/dojo  ~2024.9.26..21.14.00..7fc8
    [ %server-time ~2024.9.26..22.03.39..2233 ]
    [ %message 'sys.sys.databases' ]
    [ %schema-time ~2024.9.26..21.14.00..7fc8 ]
    [ %data-time ~2024.9.26..21.14.00..7fc8 ]
    [ %vector-count 2 ]
```
We can see it in a future time context.
```
FROM sys.sys.databases AS OF ~2030.1.1 SELECT *
```

```
database  sys-agent  sys-tmsp  data-ship  data-agent  data-tmsp
animal-shelter  /gall/dojo  ~2024.10.1..16.01.34..b6b4  ~zod  /gall/dojo  ~2024.10.1..16.01.34..b6b4
db1  /gall/dojo  ~2024.9.26..21.14.00..7fc8  ~zod  /gall/dojo  ~2024.9.26..21.14.00..7fc8
db2  /gall/dojo  ~2030.1.1  ~zod  /gall/dojo  ~2030.1.1
sys  /gall/dojo  ~2024.9.26..21.12.20..2a1d  ~zod  /gall/dojo  ~2024.9.26..21.12.20..2a1d
```
Let's clean up this situation by dropping that database.
```
DROP DATABASE animal-shelter
```
Whoops, we tried to drop the wrong database. Fortunately since the *animal-shelter* database is already populated Obelisk did not allow our DROP command without the `FORCE` parameter.

```
...
/lib/obelisk/hoon:<[365 7].[365 80]>
"%animal-shelter has populated tables and `FORCE` was not specified"
/lib/obelisk/hoon:<[365 77].[365 79]>
```

```
DROP DATABASE db2
```
Be careful. A future dated database will DROP without the `FORCE` parameter even if it has populated tables. DROP DATABASE is the only command that does not leave traces for time travel. The database is completely erased from the server's state.

```
%obelisk-result:
  %results
    [ %message 'DROP DATABASE %db2' ]
    [ %server-time ~2024.10.2..16.31.43..566d ]
    [ %message 'database %db2 dropped' ]
```

This time let's create the database in the past and populate it. One INSERT is in the past and one is in the present.
```
CREATE DATABASE db2 AS OF ~2000.1.1;
CREATE TABLE db2..my-table-1 (col1 @t, col2 @da) PRIMARY KEY (col1) AS OF ~2000.1.1;
INSERT INTO db2..my-table-1 
  (col1, col2)
VALUES
  ('today', ~2000.1.1)
  ('tomorrow', ~2000.1.2)
  ('next day', ~2000.1.3) AS OF ~2000.1.1;
INSERT INTO db2..my-table-1
  (col1, col2)
VALUES
  ('next-today', ~2000.1.1)
  ('next-tomorrow', ~2000.1.2)
  ('next-next day', ~2000.1.3);
```

```
%obelisk-result:
  %results
    [ %message 'created database %db2' ]
    [ %server-time ~2024.10.2..16.54.41..df15 ]
    [ %schema-time ~2000.1.1 ]
  %results
    [ %message 'CREATE TABLE %my-table-1' ]
    [ %server-time ~2024.10.2..16.54.41..df15 ]
    [ %schema-time ~2000.1.1 ]
  %results
    [ %message 'INSERT INTO %my-table-1' ]
    [ %server-time ~2024.10.2..16.54.41..df15 ]
    [ %schema-time ~2000.1.1 ]
    [ %data-time ~2000.1.1 ]
    [ %message 'inserted:' ]
    [ %vector-count 3 ]
    [ %message 'table data:' ]
    [ %vector-count 3 ]
  %results
    [ %message 'INSERT INTO %my-table-1' ]
    [ %server-time ~2024.10.2..16.54.41..df15 ]
    [ %schema-time ~2000.1.1 ]
    [ %data-time ~2024.10.2..16.54.41..df15 ]
    [ %message 'inserted:' ]
    [ %vector-count 3 ]
    [ %message 'table data:' ]
    [ %vector-count 6 ]
```
Now, if we select data from the current state we get *all* the data we have inserted so far.
```
FROM db2..my-table-1
SELECT *
```

```
%obelisk-result:
  %results
    [ %message 'SELECT' ]
    %result-set
      col1  col2
      next day  ~2000.1.3
      next-next day  ~2000.1.3
      next-today  ~2000.1.1
      next-tomorrow  ~2000.1.2
      today  ~2000.1.1
      tomorrow  ~2000.1.2
    [ %server-time ~2024.10.2..17.00.48..85c2 ]
    [ %message 'db2.dbo.my-table-1' ]
    [ %schema-time ~2000.1.1 ]
    [ %data-time ~2024.10.2..16.54.41..df15 ]
    [ %vector-count 6 ]
```
Notice that *%data-time* is the last time we inserted data.

If we SELECT for a prior time, we get only the first set of data we submitted and the older *%data-time*.
```
FROM db2..my-table-1
  AS OF ~2016.11.11
SELECT *
```

```
%obelisk-result:
  %results
    [ %message 'SELECT' ]
    %result-set
      col1  col2
      next day  ~2000.1.3
      today  ~2000.1.1
      tomorrow  ~2000.1.2
    [ %server-time ~2024.10.2..17.06.08..4b55 ]
    [ %message 'db2.dbo.my-table-1' ]
    [ %schema-time ~2000.1.1 ]
    [ %data-time ~2000.1.1 ]
    [ %vector-count 3 ]
```

# Joins

A `JOIN` is a query clause that combines rows from two or more tables and/or views, possibly based on a related column or columns between them. It allows you to retrieve and manipulate data from multiple tables as if they were a single table.

## Natural Joins

*Natural Joins* rely on columns between two data objects (tables or views) that have a predetermined correspondence, rather than an `ON` predicate determining the join criteria. When specifying a `JOIN` without an `ON` predicate, Obelisk first determines if there is a `FOREIGN KEY` (*not yet implemented*) relating the objects. If no `FOREIGN KEY` exists, but the tables share the same primary key (columns having the same name and aura type) it will join on primary keys. It does not matter if the keys' columns ordered ascending/descending differently between the two.

Let's use the system view *sys.tables* to find like primary keys.

```
FROM sys.tables
WHERE namespace = 'reference'
  AND name = 'calendar'
   OR name = 'calendar-us-fed-holiday' 
SELECT name AS table-name, key-ordinal, key
```

And we find the tables share a common primary key.

```
%result-set"
  table-name  key-ordinal  key
  calendar  1  date
  calendar-us-fed-holiday  1  date
```

What days of the week do federal holidays fall on in 2025?

```
FROM reference.calendar T1
JOIN reference.calendar-us-fed-holiday T2
WHERE T1.date BETWEEN ~2025.1.1 AND ~2025.12.31
SELECT T1.date, day-name, us-federal-holiday
```

In this query we alias the tables so we can distinguish column names shared between the two.

```
%result-set
  date  day-name  us-federal-holiday
  ~2025.1.1  Wednesday  New Year\\'s Day
  ~2025.5.26  Monday  Memorial Day
  ~2025.10.13  Monday  Columbus Day
  ~2025.12.25  Thursday  Christmas Day
  ~2025.9.1  Monday  Labor Day
  ~2025.11.27  Thursday  Thanksgiving Day
  ~2025.2.17  Monday  Washington\\\\\\'s Birthday
  ~2025.7.4  Friday  Independence Day
  ~2025.11.11  Tuesday  Veterans Day
  ~2025.1.20  Monday  Birthday of Martin Luther King Jr.
```

# Commenting urQL

```
CREATE DATABASE db3; :: this is a line comment
:: they can start anywhere on a line 
:: and comment out the remainder of the line
/* this is a block comment

everyting within /* and */
(which must be in columns 1 and 2) is a comment

CREATE TABLE db3..my-table-1
  (col1 @t, col2 @da) PRIMARY KEY (col1)

*/
```

```
%obelisk-result:
  %results
    [ %message 'created database %db3' ]
    [ %server-time ~2024.12.10..20.18.34..3c25 ]
    [ %schema-time ~2024.12.10..20.18.34..3c25 ]
```

# Parsing urQL

The *urQL* parser in Obelisk is completely separable from the rest of the system.

When the parser alone is applied to an *urQL* script it creates an Obelisk API structure, as defined in desk/sur/ast/hoon and documented in the *Reference* documents. In most cases the API structure name is the same as the *urQL* command. For instance CREATE DATABASE parses to the structure *create-database*. The exception to this is queries, which get wrapped in *set-functions* structures and further wrapped in a structure named *selection*.

The parser alone may be run in the dojo from the Obelisk desk as follows:

```
=uql "<query goes here>"
(parse:parse(default-database 'animal-shelter') uql)
```

For instance the joined query we last ran produces the following pretty-printed dojo output (omitting that the `selection` itself is contained within a list):

```
[ %selection
  ctes=~
    set-functions
  { [ %query
        from
      [ ~
        [ %from
            object
          [ %table-set
            object=[%qualified-object ship=~ database=%animal-shelter namespace=%reference name=%calendar]
            alias=[~ 'T1']
          ]
          as-of=~
            joins
          ~[
            [ %joined-object
              join=%join
                object
              [ %table-set
                  object
                [ %qualified-object
                  ship=~
                  database=%animal-shelter
                  namespace=%reference
                  name=%calendar-us-fed-holiday
                ]
                alias=[~ 'T2']
              ]
              as-of=~
              predicate=~
            ]
          ]
        ]
      ]
      scalars=~
        predicate
      [ ~
        { [ %qualified-column
            qualifier=[%qualified-object ship=~ database=%animal-shelter namespace=%reference name=%calendar]
            column=%date
            alias=~
          ]
          %gte
          [p=~.da q=170.141.184.507.169.989.800.102.371.306.084.761.600]
          %between
          [ %qualified-column
            qualifier=[%qualified-object ship=~ database=%animal-shelter namespace=%reference name=%calendar]
            column=%date
            alias=~
          ]
          %lte
          [p=~.da q=170.141.184.507.750.132.522.522.907.220.587.315.200]
        }
      ]
      group-by=~
      having=~
        selection
      [ %select
        top=~
        bottom=~
          columns
        ~[
          [ %qualified-column
            qualifier=[%qualified-object ship=~ database=%animal-shelter namespace=%reference name=%calendar]
            column=%date
            alias=~
          ]
          [ %qualified-column
            qualifier=[%qualified-object ship=~ database=%UNKNOWN namespace=%COLUMN-OR-CTE name=%day-name]
            column=%day-name
            alias=~
          ]
          [ %qualified-column
            qualifier=[%qualified-object ship=~ database=%UNKNOWN namespace=%COLUMN-OR-CTE name=%us-federal-holiday]
            column=%us-federal-holiday
            alias=~
          ]
        ]
      ]
      order-by=~
    ]
  }
]
```

Notice the last two qualified columns have placeholders for *database* and *namespace*, and the qualifier's name is not a table name. This query performs a join, meaning there is more than one data source. The parser does not have enough information to determine which table an unqualified column name belongs to. This will be reconciled in the Obelisk engine at execution time.

# APPENDIX: System Views

Views on database schema metadata available in every database.

## sys.sys.databases

Lists all databases on an Obelisk server and every event that caused a schema or data state change. Only available in database "sys".

This is the only query in Obelisk that is not idempotent. This is because dropping a database results in permanently clearing all references to that database on the server.

### Columns

**database @tas** Database name.

**sys-agent @tas** Agent responsible for the latest database schema state.

**sys-tmsp @da** Timestamp of latest database schema state.

**data-ship @p** Ship making the latest database user data state

**data-agent @tas** Agent responsible for the latest user data state.

**data-tmsp @da** Timestamp of latest user data state.

### Default Ordering

database, sys-tmsp, data-tmsp

## sys.namespaces

Lists the namespaces in a database. Available in every database except "sys".

### Columns

**namespace @tas** Namespace name.

**tmsp @da** Namespace creation timestamp.

### Default Ordering

tmsp, namespace

## sys.tables

Lists tables and their primary keys.

### Columns

**namespace @tas** Namespace of table.

**name @tas** Table name.

**ship @p** Ship making the latest table state change.

**agent @tas** Agent responsible for the latest table state change.

**tmsp @da** Timestamp of latest table state change.

**row-count @ud** Count of rows in table.

**key-ordinal @ud** Ordinal of column in primary key.

**key @tas** Column in primary key.

**key-ascending @f** Indicates whether the column in the primary key is ascending or descending

### Default Ordering

namespace, name, key-ordinal

## sys.columns

Lists table columns.

### Columns

**namespace @tas**  Namespace of the table.

**name @tas** Table name.

**col-ordinal @ud** Ordinal of column in table's canonical ordering.

**col-name @tas** Name of column.

**col-type @ta** Aura type of column.

### Default Ordering

namespace, name, col-ordinal

## sys.sys-log

This view records the times and events that effected the state of the database schema.

DROPs are not recorded.

### Columns

**tmsp @da** Timestamp of database schema change of state.

**agent @tas** Agent responsible for the state change.

**component @tas** (To do: 2 columns, component and namespace along with view rewrite)

**name @tas** Added or altered component.

### Default Ordering

tmsp descending, component, name

## sys.data-log

This view records the times and events that effected the state of the database data.

### Columns

**tmsp @da**  Timestamp of table data change of state.

**ship @p** Ship making the state change.

**agent @tas** Agent responsible for the state change.

**namespace @tas** Table namespace.

**table @tas** Table name.

**row-count @ud** Count of rows in table.

### Default Ordering

tmsp descending, namespace, table

## sys.view-cache

List views and whether their caches are populated/not populated. *not implemented*

### Columns

**namespace @tas**  Namespace of the view.

**name @tas** View name.

...
