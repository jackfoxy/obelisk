# Roadmap


##  V1.0

* __Views__ -- views are cached queries and can shadow user-defined tables.

* __Outer JOINs__ -- LEFT JOIN, RIGHT JOIN, OUTER JOIN,

* __GROUP BY...HAVING__ -- as in SQL.

* __Aggregate functions__ -- functions on a column, depends on GROUP BY, e.g. COUNT(\*), SUM(\*).

* __ORDER BY ...__ -- order result set

* __Set operators__ -- DIVIDED BY, DIVIDED BY WITH REMAINDER

* __Mixed numeric system arithmetic__  -- @rd > @sd > @ud, emit greater of the numeric systems in an expression

* __INSERT FROM...SELECT... INTO table__ -- INSERT data defined by a query.

* __SELECT TOP n ...__ -- dependent on total ordering

* __path column type__ -- support path and pith types. (Is path the same as @ta? What about pith?)

* __@uv aura__ -- requires research: what flavor of RFC 4648 is urbit supporting?

* __@uc aura__ -- Bitcoin address 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa

## other planned functionality

* __Temporary tables__ -- similar to INSERT format. Temp relations as CTEs. (possibly in V1.0)

* __Security__ -- (cf. Permissions document) the current permissions model proposal is incomplete, notably lacking per table/view permissions. Currently a foreign ship cannot alter the schema but it can discover the database schemas and modify data.

* __Additional system views__ -- security, views, etc.

* __Support column cells and/or jammed nouns__ -- currently only aura-typed atoms supported.

* __@rh, @rs, @rq arithmetic__ -- @rh, @rs, @rq 

* __Regex__ -- predicate matching and scalar support

* __SELECT `<database>`, SELECT `<namespace>`, SELECT `<table>`__ -- Return the noun of an entire database, namespace, table for export, backup, or any other purpose. It's a noun. Do with it what you will. %hawk/%oxal compatibility via path?.

* __Stored procedures__ -- Parameterized queries, to be designed (TBD). Possibly urQL + inlined hoon...who knows.

* __Triggers__ -- TBD. Kick off some other process inside or outside of %obelisk.

* __Localization of date/time__ -- pass timezoneoffset @dr to server

* __Advanced aggregate features__ -- DISTINCT, like Grouping Sets, Rollup, Cube, GROUPING function. (cf. Feature T301 'Functional dependencies' from SQL 1999 specification). (Not to be confused with SELECT DISTINCT, which does not exist in %obelisk because every relation is a proper set.)

* __String formatting__ -- date formatting, other string formatting (extension of STRING())

* __Pivoting__ -- similar to SQL.

* __Windowing__ -- and windowing functions, similar to SQL.

* __INSERT `<columns>` ... AS `<name> <key columns>`__ -- Skip CREATE TABLE and define new table in the INSERT command.

* __MERGE__ -- a much maligned SQL command that could be better implemented in urQL/%obelisk. (cf. Merge document, which is incomplete)

* __B+ trees__ -- a performance thing.

* __%quiz__ -- property tests on database, namespace, table, insert, query, etc.

* __alternate urQL grammar__ -- row tuple in square brackets and/or pith for from...maybe in SPROCs?

* __CLONE DATABASE__ -- copy schema and data to a new database with optional effective <as-of-time>.
