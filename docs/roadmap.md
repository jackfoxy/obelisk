# Roadmap

Features coming after the initial v0.4 alpha release, in no particular order, although what I consider some of the more important are clustered at the top.

Most of the commands and clauses in the list below already exist in the urQL grammar and are supported by the parser.

Prioritization depends on user feedback and bribery.

* __Security__ -- (cf. Permissions document) the current permissions model proposal is incomplete, notably lacking per table/view permissions. Currently a foreign ship cannot alter the schema but it can discover the database schemas and modify data.

* __Views__ -- views are cached queries and can shadow user-defined tables.
* __Additional system views__ -- likely breaking change on sys.tables view. You have been warned.

* __DELETE__ -- Operates on user-defined tables, not on views; optional predicate. (If you skip the predicate you should be using TRUNCATE TABLE...maybe I'll make the predicate mandatory.)
* __UPDATE__ -- Operates on user-defined tables, not on views; optional predicate.
* __UPSERT__ -- INSERT that does not fail on duplicate key, but rather updates the row.

* __ORDER BY ...__ -- order result set.

* __path column type__ -- support atoms as path type
* __Support cells and/or jammed nouns__ -- currently only aura-typed atoms supported.
* __Set operators__ -- UNION, INTERSECT, EXCEPT, DIVIDED BY, DIVIDED BY WITH REMAINDER
* __Foreign Keys__ -- enforce referential integrity and allow natural join even when names do not match.
* __Scalar functions__ -- functions on one row of a table-set returning a noun. (A table-set is a user-defined table, view, result of a CTE, or join of any or all of the above.)
* __GROUP BY...HAVING__ -- as in SQL.
* __More JOINs__ -- JOIN ON `<predicate>`, CROSS JOIN, and 3 kinds of outer joins.
* __Common Table Expressions (CTE)__ -- improved urQL composability and required by the urQL grammar for some predicate operations. (cf. SQL Server, I forget what this is called in the SQL specification)
* __Aggregate functions__ -- functions on a column, depends on GROUP BY, e.g. COUNT(*).
* __Stored procedures__ -- Parameterized queries, to be designed (TBD). Possibly urQL + inlined hoon...who knows.
* __Triggers__ -- TBD. Kick off some other process inside or outside of %obelisk.
* __Localization of date/time__ -- TBD. (cf. https://github.com/sigilante/l10n) Not sure this is really important, but I can be persuaded.
* __Advanced aggregate features__ -- DISTINCT, like Grouping Sets, Rollup, Cube, GROUPING function. (cf. Feature T301 'Functional dependencies' from SQL 1999 specification). (Not to be confused with SELECT DISTINCT, which does not exist in %obelisk because every table-set is a proper set.)
* __Pivoting__ -- similar to SQL.
* __Windowing__ -- and windowing functions, similar to SQL.
* __INSERT FROM...SELECT...__ -- INSERT data defined by a query.
* __INSERT `<columns>` ... AS `<name> <key columns>`__ -- Skip CREATE TABLE and define new table in the INSERT command.
* __MERGE__ -- a much maligned SQL command that could be better implemented in urQL/%obelisk. (cf. Merge document, which is incomplete)
* __B+ trees__ -- a performance thing.

* __Aura @uc__ -- Bitcoin address 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa
* __INSERT aura validation__ -- probably as an option, +sane impact on performance unknown. Currently possible to mix-up auras.
* __Support @ta and @tas auras__ -- would require +sane.

* __%quiz__ -- property tests on database, namespace, table, insert, query, etc.

* __remove SELECT TOP and BOTTOM__ -- TOP and BOTTOM are not idempotent, unless ORDER BY is complete ordering. Likely remove them from the grammar and the parser as determining complete ordering is probably not worthwhile.
* __in-line table-set__ -- much infrastructure is in place for this, not sure it is a good idea (idea floated at Re-Assembly 2023)
* __update urQL grammar__ -- SELECT should be after WHERE clause.
* __alternate urQL grammar__ -- row tuple in square brackets and/or pith for from.
* __SELECT `<database>`, SELECT `<namespace>`, SELECT `<table>`__ -- Return the noun of an entire database, namespace, table for export, backup, or any other purpose. It's a noun. Do with it what you will.
* __aliases in predicates__ -- enable using column aliases in predicates.

