# Preliminaries

## Introduction

A _first principles_ approach guided the design and implementation of the _urQL_ query language and Obelisk RDBMS. Where the original SQL design was hurried or neglected theoretical considerations (like nullable columns) urQL emphasizes set and relational theory, composability, and type safety. Influenced by _The Third Manifesto_ (Darwen and Date), urQL is closer to the ideal _Query Language_ that Codd and Date would have endorsed than SQL.

An Urbit-native RDBMS implementation presents new opportunities for cross-application composability. Any desk's data persisted to an RDBMS is readily available for _mash up_ apps and _ad hoc_ queries, and has search functionality already built-in.

## Functionality

The Urbit RDBMS, Obelisk, consists of:

1. A scripting query language, urQL, and parser.
2. A database engine, Obelisk.
3. A front-end agent app using the parser and Obelisk APIs.

The scripting language, _urQL_, is derived from SQL with a few significant variations that enhance readability, promote composability, and are consistent with underlying theory.

* Queries are constructed in FROM..WHERE..SELECT.. order, mirroring the order of events in plan execution.

* All observable results from Obelisk, whether from a Table, View, or any Query, are proper _sets_ with no duplicate rows, unlike SQL which routinely returns duplicate rows.

* Columns are typed atoms.

* Table definitions do not permit nullable columns.

* All user-defined names, except aliases, follow the hoon term naming standard.

* Functions, apart from the simplest ones, are grouped in their own clause and inlined into SELECT and predicate clauses by alias.

* Inlined sub-queries are prohibited. JOINs and/or Common Table Expressions accommodate all related use cases.

* Predicates can reference CTEs for certain use cases.

* Relational division is supported with a DIVIDED BY operator. (not yet implemented in the urQL parser or Obelisk)

* Reading and/or updating data on foreign ships is permissible if the ship's pilot has granted permission. Cross database joins are allowed, but cross ship joins are not. (Not yet implemented in Obelisk.)

* Views cannot be defined on foreign databases.

* Queries can operate on previous database states (schema versions and persisted data) through the the AS OF clause.)

## urQL language diagrams and general syntax

* \[ ] indicate optional entries.
* { } nest options | delimited. If there is a default, it is the first entry.
* In some cases { } groups a portion of the diagram to indicate optional repeating [ ,...n ].
* \<...> Represents a user-supplied argument that either expands to a diagram defined elsewhere or hints at user input, e.g. `<alias>`, `<new-table>`.
* Text outside of brackets represents required keywords.
* Keywords are represented in uppercase. Uppercasing is not a requirement, but is strongly suggested for readability.
* All whitespace is treated the same; a single space or line feed suffices.
* Whitespace around delimiting `;` and `,` is optional.
* Whitespace is required on the outside of parentheses and optional on the inside.
* Multiple commands must be delimited by `;`.
* All object names follow the hoon rules for terms, i.e. character set restricted to lower-case alpha-numeric and hyphen characters and first character must be alphabetic.
* Column, table, and other aliases offer an alternative to referencing the qualified object name. They follow the hoon term naming standard, except that upper-case alphabetic characters are allowed. Alias evaluation is case agnostic, e.g. `t1` and `T1` represent the same alias. Aliases can be referenced in clauses subsequent to the defining clause.
* Qualified object names without the database specified assume the default database.
* All Views in the database *sys* and namespace *sys* are system-owned and read-only for all user commands. 
*  User-defined databases may not specify the namespace *sys*.

## Common documentation structures

The following are some common language structures used throughout the reference.

```
<db-qualifier> ::=
  { <database>.<namespace>.
  | <database>..
  | <namespace>. }
```

**\<db-qualifier>** provides the fully qualified path prefix to a `<table>` or `<view>` object on the host ship.

`<database>` defaults to the current-database property of the Obelisk agent.

`<namespace>` defaults to 'dbo' (database owner).

```
<ship-qualifier> ::=
  { @p.<database>.<namespace>.
  | @p.<database>..
  | <db-qualifier> }
```

**\<ship-qualifier>** adds ship qualification to the database/namespace qualifier.

```
<common-table-expression> ::=
  <selection> [ AS ] <alias>
```
**\<common-table-expression>** produces a row result set, `<table-set>`, for further manipulation by other CTEs, JOINS, SELECT clauses, or predicates.

`<selection> ::=` from selection diagram. (More on `<selection>` under `<table-set>`.)

`<alias> ::= @t` case-agnostic, see alias naming discussion above.

CTEs are always referenced by alias, never inlined.

```
<table-set> ::=
  [ <ship-qualifier> ]{ <table> | <view> }
  | <common-table-expression>
  | *
```
**\<table-set>** is sets of data cells arranged as row sets (of one or more row types), either as an interim result type or end result.

Each simple row type is itself a set defined by its component columns (and literals). Rows of `<table-set>`s that are not also `<table>`s may be of varying length (jagged). Hence the row type of a `<table-set>` may be a union type.

The order of rows may be determined in the `<selection>` command by an ORDER BY clause, and so in the case of ordering `<table-set>`s are not strictly *sets* (which have no defined order) in the mathematical sense.

When a `<view>`  and a `<table>` have the same name within a namespace, `<view>` is said to "shadow" `<table>` wherever syntax accepts `<table>` or `<view>`. That is the `<view>` will be referenced and the `<table>` ignored.

User-defined tables, `<table>`, are the sole source of content in an Obelisk database and the only manifestation of `<table-set>` that is not the result of some computation (selecting data).

The `<selection>` command returns a `<table-set>`, hence every `<table-set>` is typed by one or more equivalent urQL `<selection>` commands. This is true because every `<selection>` command is idempotent, provided all selection objects are within the samve database. The idempotence guarantee does not extend to cross-database selections. (More on this in the section on __Time__.)

More generally, a `<table-set>` is a user-defined table, view, common table expression, join, or result of a query. Most importantly, it is a proper set of its rows. 

```
<as-of-time> ::=
  AS OF { NOW
          | <timestamp>
          | n { SECOND[S] | MINUTE[S] | HOUR[S] | DAY[S] | WEEK[S] | MONTH[S] | YEAR[S] } AGO
          | <time-offset>
        }
```

Specifying **\<as-of-time>** overrides setting the schema and/or content timestamps in data and schema access and state changes.

`NOW` default, current computer time.

`<timestamp>` any valid time in @da format.

`n ... AGO` sets the schema and/or content (data) timestamp in state changes back from `NOW` according to the time units specified.

`<time-offset>` any valid timespan in @dr format; sets the schema and/or content timestamp in state changes back from `NOW`.

## Literals

urQL supports most aura types implemented in Urbit as literals for the INSERT and SELECT commands and predicates. The *loobean* Urbit literal types, %.y %.n, are supported by *different* literals in urQL than normally in Urbit, Y/N. urQL supports some literal types in multiple ways. Dates, timespans, and ships can all be represented in INSERT without the leading **~**. Unsigned decimal can be represented without the dot thousands separator. In some cases the support between INSERT and SELECT is not the same.

Column types (auras) not supported for INSERT can only be inserted into tables through the API.

| Aura |     Description      |     INSERT         |     SELECT         |
| :--- |:-------------------- |:------------------ |:------------------ |
| @c   | UTF-32               | ~-~45fed. | **not supported** |
| @da  | date                 | ~2020.12.25 | ~2020.12.25 |
|      |                      | ~2020.12.25..7.15.0 | ~2020.12.25..7.15.0 |
|      |                      | ~2020.12.25..7.15.0..1ef5 | ~2020.12.25..7.15.0..1ef5 |
|      |                      | 2020.12.25 | 2020.12.25 |
|      |                      | 2020.12.25..7.15.0 | 2020.12.25..7.15.0 |
|      |                      | 2020.12.25..7.15.0..1ef5 | 2020.12.25..7.15.0..1ef5 
| @dr  | timespan             | ~d71.h19.m26.s24..9d55 | ~d71.h19.m26.s24..9d55 |
|      |                      | ~d71.h19.m26.s24 | ~d71.h19.m26.s24 |
|      |                      | ~d71.h19.m26 | ~d71.h19.m26 |
|      |                      | ~d71.h19 | ~d71.h19 |
|      |                      | ~d71 | ~d71 |
|      |                      | d71.h19.m26.s24..9d55 |  |
|      |                      | d71.h19.m26.s24 |  |
|      |                      | d71.h19.m26 |  |
|      |                      | d71.h19 |  |
|      |                      | d71 |  |
| @f   | loobean              | y, n, Y, N | Y, N |
| @if  | IPv4 address         | .195.198.143.90 | .195.198.143.90 |
| @is  | IPv6 address         | .0.0.0.0.0.1c.c3c6.8f5a | .0.0.0.0.0.1c.c3c6.8f5a |
| @p   | ship name            | ~sampel-palnet | ~sampel-palnet |
|      |                      | sampel-palnet  |  |
| @q   | phonemic base        | **not supported** | **not supported** |
| @rh  | half float (16b)     | **not supported** | **not supported** |
| @rs  | single float (32b)   | .3.14, .-3.14 | .3.14, .-3.14 |
| @rd  | double float (64b)   | \.\~3.14, .~-3.14 | \.\~3.14, .~-3.14 |
| @rq  | quad float (128b)    | **not supported** | **not supported** |
| @sb  | signed binary        | --0b10.0000 | --0b10.0000 |
|      |                      | -0b10.0000 | -0b10.0000 |
| @sd  | signed decimal       | --20, -20 | --20, -20 |
| @sv  | signed base32        | --0v201.4gvml.245kc | --0v201.4gvml.245kc |
|      |                      | -0v201.4gvml.245kc | -0v201.4gvml.245kc |
| @sw  | signed base64        | --0w2.04AfS.G8xqc | --0w2.04AfS.G8xqc |
|      |                      | -0w2.04AfS.G8xqc | -0w2.04AfS.G8xqc |
| @sx  | signed hexadecimal   | --0x2004.90fd | --0x2004.90fd |
|      |                      | -0x2004.90fd | -0x2004.90fd |
| @t   | UTF-8 text (cord)    | 'cord', 'cord\\\\'s' <sup>1</sup> | 'cord', 'cord\\\\'s' <sup>1</sup> |
| @ta  | ASCII text (knot)    | *support pending* | *support pending* |
| @tas | ASCII text (term)    | *support pending* | *support pending* |
| @ub  | unsigned binary      | 10.1011 | 10.1011 |
| @ud  | unsigned decimal     | 2.222 | 2.222 |
|      |                      | 2222 | 2222 |
| @uv  | unsigned base32      | **not supported** | **not supported** |
| @uw  | unsigned base64      | e2O.l4Xpm | **not supported** |
| @ux  | unsigned hexadecimal | 0x12.6401 | 0x12.6401 |

 <sup>1</sup> Example of embedding single quote in @t literal.

## Comments
Comment syntax in urQL differs from SQL comment syntax. urQL supports two types of comments, line comments and block comments. 

### Line Comments
```
:: two semicolons comment out the remainder of the line
```

```
CREATE DATABASE db1; :: the remainder of this line is a comment
```

### Block Comments
```
/* this is a block comment
block comments begin with the characters "/*"
these characters must be in columns one and two

block comments end with the characters "*/"
likewise these must be in columns one and two
*/
```

## Types
All data representations (nouns) of the Obelisk system are strongly typed.

### Column Types
The fundamental data element in Obelisk is an atom that is typed by an aura. Data cells, which are intersections of a `<table-set>` row and column, are typed atoms.

Obelisk supports the following auras (see the __Literals__ section for representing the atomic types):

| Aura |         Description          |
| :--- |:---------------------------- |
| @c   | UTF-32                       |
| @da  | date                         |
| @dr  | timespan                     |
| @f   | loobean                      |
| @if  | IPv4 address                 |
| @is  | IPv6 address                 |
| @p   | ship name                    |
| @q   | phonemic base                |
| @rh  | half float (16b)             |
| @rs  | single float (32b)           |
| @rd  | double float (64b)           |
| @rq  | quad float (128b)            |
| @sb  | signed (low bit) binary      |
| @sd  | signed (low bit) decimal     |
| @sv  | signed (low bit) base32      |
| @sw  | signed (low bit) base64      |
| @sx  | signed (low bit) hexadecimal |
| @t   | UTF-8 text (cord)            |
| @ta  | ASCII text (knot, url safe)  |
| @tas | ASCII text (term)            |
| @ub  | unsigned binary              |
| @ud  | unsigned decimal             |
| @uv  | unsigned base32              |
| @uw  | unsigned base64              |
| @ux  | unsigned hexadecimal         |

Columns are typed by an aura and indexed by name.
```
<column-type> ::=
  <aura/name>
```

### Table Row and Table Types

All datasets in Obelisk are sets, meaning a given value for any typed element, `<row-type>`, only exists once. 

All tables originate from, or are derived from, user-defined tables created by the `CREATE TABLE` command.

A base-table (`<table>`) row has a default or cannonical type, which is the table's atomic aura-typed columns in a particluar fixed order.
```
<row-type> ::= list <aura>
```
Each user-defined table is typed by its `<row-type>`.
```
<table-type> ::= (list <row-type>)
```
A user-defined table's definition includes a unique primary row order, the primary key ordering, giving it `list column` type rather than `set column` type. This is not true for all `<table-set>` instances, which are always sets, but may have no defined order (i.e. the order in which they appear as results is arbitrary).

Rows from `<view>`s, `<common-table-expression>`s, and the command output from `<selection>`, or any other table<sup>2</sup> that is not a base-table, can only have an immutable row order if it is explicitly specified (i.e., the `SELECT` statement includes an `ORDER BY` clause). In general, these other tables have types that are unions of `<row-type>`s.

When the `<table-set-type>` is a union of `<row-type>`s. There is a `<row-type>` representing the full width of the `SELECT` statement and as many sub-types as necessary to represent any selected unjoined outer `JOIN`s. 

Sub-types align their columns with matching columns in the all-column `<row-type>`, regardless of the SELECT clause's construction.

In general, `<table-set>`s have the type:
```
<table-set-type> ::= 
  (list <row-type>)
  | (set (<all-column-row-type> | <row-sub-type-1> | ... | <row-sub-type-n> ))
```

And since there is ordering involved in typing rows, `<row-type>` is technically not a set in the maths sense.

<sup>2</sup> Much RDBMS literature refers to all these initial, interim, and final data representations as _tables_. We reserve that term for what others refer to as _user-defined tables_.

### Api Types
All static types in the Obelisk API are defined in `sur/ast/hoon`.

### Remarks

Even `<table>`s can be typed as sets, because a `SELECT` statement without an `ORDER BY` clause has an undefined row order.

Regardless of the presence of `ORDER BY`, any `<table-set>` emitted by any step in a `<selection>`, a CTE, or a `<view>` is a list of `<row-type>` in some (possibly arbitrary) order.

Ultimately, "set" is the most important concept because every `<table-set>` will have one unique row value for any given sub-type of `<row-type>`.

## Time

In *urQL* time is both primary and fundamental. Every change of state, whether to a database's schema or content, is indexed by time. Thus every query is idempotent becasue each query is implicitly or explicitly associated with a particular state in the series.

The rules enforcing time primacy in the Obelisk database engine are simple. Each database has a most recent schema time and a most recent content time. Every subsequent state change, whether to schema or content must be subsequent to the latest of the two times. Normally the user never needs to concern himself with this requirement. The database engine just takes care of it because the default `<as-of-time>` for every command is `NOW`, the host schema time carried in the Obelisk agent's `now.bowl`. *urQL* scripts default every command in a script (sequence of commands) to `NOW`, so the time result of script execution is as if everything happened _all at once_ even though the commands executed sequentially. Users only need to be aware of this rule when applying `<as-of-time>` to override `NOW`. Violation of time constraints (or any other error) causes the entire script to fail. (Scripts are always atomic.)

The `CREATE DATABASE` command sets the first schema and content times to the database creation time.

The second, and last, rule is once you introduce a query returning results into a script, all subsequent commands must also be queries. No further schema or data changes are allowed.

Among the metadata returned by queries is the schema and content times (labelled `schema time` and `data time`) used by the engine to create the query results. The query has a de facto `<as-of-time>` of the latest of the two. That is what makes it idempotent. You need to specify this `<as-of-time>` to recreate the same query. By specifying `<as-of-time>` in a query the engine uses the schema and content in effect at that time to create the results.
