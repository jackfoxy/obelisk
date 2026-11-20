# Releases

## v1.0.0

* user-defined views: in most cased views become cached for faster results
* LEFT JOIN, RIGHT JOIN, OUTER JOIN
* GROUP BY and HAVING
* aggregate functions AVG, BOOL-AND, BOOL-OR, COUNT, MAX, MIN, STDEV, STDEVP, SUM, VAR, VARP
* ORDER BY
* SELECT TOP n
* INSERT and UPSERT from a query
* DIVIDED BY and DIVIDED BY WITH REMAINDER set operations
* EXISTS, NOT EXISTS, EQUIV, NOT EQUIV predicates
* inline scalars directly without SCALARS clause entry
* VERSION() returns %obelisk version
* @rh, @rs, @rq arithmetic, numeric functions, and predicates compare
* @ub, @ux, @uv, @uw, @sb, @sx, @sv, @sw arithmetic and numeric functions, as @ud and @sd
* predicates compare @sb, @sx, @sv, @sw as signed
* sized integer column types, e.g. @udD, @sdD, @uxF; values and results must fit the bit width
* mixed numeric arithmetic, functions, and comparison: operands convert to their common type, float > signed > unsigned, widest float and bit width
* comparisons, IN, simple CASE, and JOIN ON across numeric types compare exact values
* negative exponents: x ^ -y is 1 / x ^ y; an integer base with a negative literal or non-literal signed exponent gives @rd
* loobean literals %.y and %.n; the legacy Y and N are still accepted
* @uc bitcoin address column type; literals 0c<address> or the bare address, verified by checksum; displayed bare

## v0.9.4-beta
* standardize UI on urui v2.0

## v0.9.3-beta
* Optional Vim key bindings
* Alternate screen formats
* Themes

## v0.9.2-beta
* fix slowness on UI startup
* make sure DB has foreign keys view in migration

## v0.9.1-beta
* updates to UI

## v0.9.0-beta
* BREAKING CHANGES affect interacting apps, re-compile with latest sur/obelisk-ast/hoon
* BREAKING CHANGE: relation:obelisk-ast -> relation-id
* BREAKING CHANGE: relation.result:obelisk-ast -> relation-name.result
* Scry database, namespace, relation, relation restricted by columns
* new %script and %list-cmd pokes specify output format, %tape and %commands deprecated
* output formats: %vector, %markdown, %html, %wain, %manx, %tape, %json, %raw
* native sail UI

## v0.8.1-beta

* fix CTE aliased column bug
* UPSERT

## v0.8-beta

* ALTER DATABASE
* ALTER NAMESPACE
* ALTER TABLE
* DROP NAMESPACE
* Foreign Key Relational Integrity
* sys.foreign-keys view
* full @ta and @tas aura support
* action %tape executes silently, %tape-print prints to dojo
* fixed bug where system views were not ordered
* fixed bug where SELECT sub-set of system view columns returned duplicate rows
* fixes to constant scalar function processing and missing scalars
* fixes and improvements to obelisk ui
* UI: all aspects significantly faster
* UI: multi-command scripts have tabbed results
* UI: copy script or result to clipboard
* UI: paging of long result sets

## v0.7 beta

* Common Table Expressions (CTE)
* Scalar Functions
* All Natural Joins
* JOIN ON Predicate
* Set Operators UNION, INTERSECT, EXCEPT
* %hawk UI
* OTA Software Distribution

## v0.6 alpha

* UPDATE
* NOT unary predicate operator fully functional
* documentation reorganized

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
