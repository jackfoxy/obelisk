# Releases

## v0.5 alpha

* SELECT all from table in JOIN
* CROSS JOIN
* natural JOIN on primary keys when key column ordering differs
* support multiple natural JOINs and CROSS JOINs
* sys.tables view changed and sys.table-keys view added
* refactored multiple AST components
* add unqualified-column to AST/API
* fixed several JOIN bugs
* updated docs

## v0.4a alpha

* GRANT and REVOKE parsing and AST updated. 

## v0.4 alpha

### DDL

CREATE DATABASE
DROP DATABASE
CREATE NAMESPACE
CREATE TABLE
DROP TABLE

* Database schemas are time-travelling (cf. Preliminaries: Time section).
* Several other DDL commands can be parsed, but the %obelisk engine does not yet enable them.

### Data manipulation and query

INSERT
TRUNCATE TABLE
FROM...SELECT...

* FROM user-defined tables and system views (views on the database schema and history).
* Natural JOINs -- a natural join has no predicate, rather it joins on columns that match both in name and aura.
* Cross-database JOINs -- natural joins.
* Tables and views are time-travelling.
* SELECT any or all available columns and literals.
* WHERE clause predicates for filtering query results.
