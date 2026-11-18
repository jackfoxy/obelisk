# Releases

## next-release
* ORDER BY, by output name, column (selected or not), or ordinal, ordered by aura
* SELECT TOP n, requires ORDER BY to be a total ordering of the result
* warning when ORDER BY is not a total ordering of the result set
* TOP in CTEs and in set operation queries before the last
* ordered results of several row types format as one table with empty cells
* INSERT and UPSERT from a query, set operation query, or CTE
* system views ordered by aura
* inline scalars directly without SCALARS clause entry
* VERSION() scalar added, returns %obelisk version
* DIVIDED BY and DIVIDED BY WITH REMAINDER set operations
* fix set operations comparing rows by source primary key instead of data
* LEFT JOIN, RIGHT JOIN, OUTER JOIN
* EXISTS, NOT EXISTS, EQUIV, NOT EQUIV predicates
* COALESCE tests existence
* fix SCALARS clause arithmetic led by IF, CASE, or COALESCE, or using %
* fix arithmetic operands and scalars named end-*
* @rh, @rs, @rq arithmetic and numeric functions; float results keep their aura
* @rh and @rq literals
* predicates compare @rh, @rs, @rq as floats
* @ub, @ux, @uv, @uw, @sb, @sx, @sv, @sw arithmetic and numeric functions, as @ud and @sd
* @uv literals, dotted form 0v1f.ab3ck
* predicates compare @sb, @sx, @sv, @sw as signed
* sized integer column types, e.g. @udD, @sdD, @uxF; values and results must fit the bit width
* fix a column named e, pi, tau, or phi read as the constant in arithmetic
* mixed numeric arithmetic, functions, and comparison: operands convert to their common type, float > signed > unsigned, widest float and bit width
* comparisons, IN, simple CASE, and JOIN ON across numeric types compare exact values
* negative exponents: x ^ -y is 1 / x ^ y; an integer base with a negative literal or non-literal signed exponent gives @rd
* fix simple CASE not matching a sized target to an unsized WHEN value
* fix a signed literal (--5, -3) in SCALARS arithmetic or a CASE WHEN, THEN, or ELSE value read as operators
* primary keys on @rh, @rs, @rq, @sb, @sv, @sw, @sx, and sized signed auras order by value; state migration re-sorts existing tables
* aggregate functions AVG, BOOL-AND, BOOL-OR, COUNT, MAX, MIN, STDEV, STDEVP, SUM, VAR, VARP, with ALL and DISTINCT
* GROUP BY and HAVING
* loobean literals %.y and %.n; the legacy Y and N are still accepted, and are now loobeans, not column names, in predicates and scalar function arguments
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
