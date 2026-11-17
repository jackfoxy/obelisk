# Roadmap


##  V1.0

* __Numeric key ordering__ -- primary keys and indices on @rh, @rs, @rq, @sb, @sv, @sw, @sx, and sized signed (e.g. @sdD) columns sort by atom value, so negative values sort wrong; order as floats like @rd and as signed like @sd (requires state migration to re-sort existing indices).

* __Aggregate functions__ -- functions on a column, depends on GROUP BY, e.g. COUNT(\*), SUM(\*).

* __GROUP BY...HAVING__ -- as in SQL.

* __Views__ -- views are cached queries and can shadow user-defined tables.

* __path column type__ -- support path and pith types. (Is path the same as @ta? What about pith?)

* __@uc aura__ -- Bitcoin address 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa


## other planned functionality

*  Who will build the first database with agent-ai inside? Meaning I can put an agent call into my select statement? Bonus if you can write self repairing queries.
    https://x.com/rickasaurus/status/2100686628406641103

    Don't know, but I do know I'm adding it to the Obelisk roadmap.

    Self-repairing query too. Should be fairly straight forward prompt generation, given every schema and data state is immutable and persistent
    https://x.com/foxyjackfox/status/2100723391468822881
   
* __Temporary tables__ -- similar to INSERT format. Temp relations as CTEs. (possibly in V1.0)

* __Security__ -- (cf. Permissions document) the current permissions model proposal is incomplete, notably lacking per table/view permissions. Currently a foreign ship cannot alter the schema but it can discover the database schemas and modify data.

* __Additional system views__ -- security, views, etc.

* __Support column cells and/or jammed nouns__ -- currently only aura-typed atoms supported.

* __Regex__ -- predicate matching and scalar support

* __SELECT `<database>`, SELECT `<namespace>`, SELECT `<table>`__ -- Return the noun of an entire database, namespace, table for export, backup, or any other purpose. It's a noun. Do with it what you will. %hawk/%oxal compatibility via path?.

* __Stored procedures__ -- Parameterized queries, to be designed (TBD). Possibly urQL + inlined hoon...who knows.

* __Triggers__ -- TBD. Kick off some other process inside or outside of %obelisk.

* __Localization of date/time__ -- pass timezoneoffset @dr to server

* __Advanced aggregate features__ -- DISTINCT, like Grouping Sets, Rollup, Cube, GROUPING function. (cf. Feature T301 'Functional dependencies' from SQL 1999 specification). (Not to be confused with SELECT DISTINCT, which does not exist in %obelisk because every relation is a proper set.)

* __String formatting__ -- date formatting, other string formatting (extension of STRING())

* __Pivoting__ -- similar to SQL.

* __Windowing__ -- and windowing functions, similar to SQL.

* __MERGE__ -- a much maligned SQL command that could be better implemented in urQL/%obelisk. (cf. Merge document, which is incomplete)

* __B+ trees__ -- a performance thing.

* __%quiz__ -- property tests on database, namespace, table, insert, query, etc.

* __alternate urQL grammar__ -- row tuple in square brackets and/or pith for from...maybe in SPROCs?

* __CLONE DATABASE__ -- copy schema and data to a new database with optional effective <as-of-time>.
