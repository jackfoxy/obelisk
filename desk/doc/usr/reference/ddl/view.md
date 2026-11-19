# DDL: View

A `<view>` is a named, read-only `<relation>` defined by a stored `<query>`. Each reference to a view in a `<query>` produces the rows of its stored query, evaluated at the time in effect for the referencing query.

Views are not updateable. `INSERT`, `UPDATE`, `UPSERT`, `DELETE`, `MERGE`, and `TRUNCATE TABLE` always resolve to a `<table>`, never to a `<view>`.

## Name resolution

A view may have the same name as a table in the same namespace. The view then *shadows* the table: wherever a `<query>` names that `<relation>`, the view is used and the table ignored. The shadowed table remains reachable by:

* data manipulation commands, which always resolve to tables
* the body of the view shadowing it, see below
* scries and subscriptions, which read tables and system views only

Within a view body:

* Unqualified and partially qualified object names default to the view's own database and the namespace *dbo*, not to the script's current database.
* A name resolves to a live view of that namespace and name if one exists, otherwise to a table.
* The view's own name resolves to the table it shadows. This allows a view to present a filtered or reshaped version of the table it hides.
* Names in namespace *sys* resolve to system views.

Name resolution happens once, when the view is created or altered. Each reference is stored fully qualified, together with whether it is a table or a view. Objects created later do not change what an existing view refers to.

## Dependencies

A view *references* every table and view named in its body. A view is *live* from its creation until it is dropped; it remains visible to queries with an `AS OF` time in that interval.

While any live view references a `<table>`, that table cannot be:

* altered by `ALTER TABLE`, including `RENAME TO`
* transferred by `ALTER NAMESPACE ... TRANSFER TABLE`
* shadowed by a new view, whether by `CREATE VIEW` or by `ALTER NAMESPACE ... TRANSFER VIEW`
* dropped by `DROP TABLE` without `FORCE`

While any live view references a `<view>`, that view cannot be:

* altered by `ALTER VIEW`
* transferred by `ALTER NAMESPACE ... TRANSFER VIEW`
* dropped by `DROP VIEW` without `FORCE`

`FORCE` cascades. `DROP TABLE FORCE` and `DROP VIEW FORCE` also drop every view that references the dropped object, directly or through other views.

`DROP NAMESPACE` drops the views in the namespace along with its tables. Without `FORCE`, it is rejected when a live view outside the namespace references a table or view inside it. With `FORCE`, those outside views are dropped too, cascading as above.

`DROP DATABASE` drops all views in the database.

`TRUNCATE TABLE` and all other data changes are permitted on referenced tables.

Because a view can only reference views that already exist, and a referenced view cannot be altered, circular view references cannot occur.

## Columns

The columns of a view are the output columns of its body, in `SELECT` order, with the auras the body produces.

Column names must be unique. A body producing duplicate column names, whether inherited from source relations or assigned by alias, is rejected. Alias columns as needed.

`*` and `<alias>.*` are expanded when the view is created or altered. Columns later added to a source table do not appear in the view.

## Ordering

`ORDER BY` in a view body determines which rows `TOP` retains, and the row order of the view. An `ORDER BY` in the referencing query takes precedence.

## Time

A view's definition is versioned with the database schema. A query uses the definition in effect at its `AS OF` time.

When a query references a view with `AS OF <time>`, that time applies to every relation in the view body that does not have an `AS OF` of its own. A relative `AS OF` (`@dr`) in the body counts back from that time.

## Caching

Views are cached in the same way as system views. The cache of a view holds entries keyed by time:

* `CREATE VIEW` and `ALTER VIEW` add an empty entry at the time of the command.
* Every data change to a table at time `t` adds an empty entry at `t` for each live view that references the table, directly or through other views. This includes changes made by foreign-key referential actions.
* Adding an empty entry evicts the content of every earlier entry of that view. The earlier entries remain as empty entries.
* A query at time `t` uses the latest entry at or before `t`. An empty entry is filled by evaluating the view, and keeps its content until the view's next empty entry is added.

A view is not cacheable, and is evaluated each time it is referenced, when its body contains:

* an `AS OF` with a relative time (`@dr`)
* a scalar function whose result depends on the current time
* a random scalar function
* a reference to a view that is not cacheable

Scries do not populate view caches.

## CREATE VIEW

Creates a `<view>`.

```
<create-view> ::=
  CREATE VIEW [ <db-qualifier> ]<view>
    [ <as-of> ]
  AS [ WITH <common-table-expression> [ ,...n ] ] <query>
```

`<query>` is a `<query>` as defined in [Select](../select.md), with or without set operations.

### Examples

```
CREATE VIEW high-value-orders AS
FROM orders
WHERE amount > 1.000
SELECT order-id, customer-id, amount
ORDER BY amount DESC
```

A view shadowing the table it reads:

```
CREATE VIEW customer AS
FROM customer
WHERE active = %.y
SELECT customer-id, name
```

### Arguments

**`<view>`**
User-defined name for the new view. It must adhere to the Hoon term naming standard.

If not explicitly qualified, it defaults to the Obelisk agent's current database and the *dbo* namespace.

**`<as-of>`**
Timestamp of view creation. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

**`<query>`**
The query producing the rows of the view. See Name resolution, Columns, and Ordering above.

### API
```
+$  create-view
  $:  %create-view
    view=qualified-table
    text=@t
    =crud-txn
    as-of=(unit as-of)
  ==
```

`text` is the source text of the body following `AS`, as written. The `body` of `crud-txn` is always `%query` or `%set-query`.

### Remarks

This command mutates the state of the Obelisk agent.

Views cannot be defined on foreign ship databases. A view body may only reference relations in the view's own database.

Views cannot be created in namespace *sys*.

### Produced Metadata

message: CREATE VIEW <name>
server time: <timestamp>
schema time: <timestamp>

Adds the view to `sys.views`, its references to `sys.view-references`, and its columns to `sys.columns`. Records a `create` `view` event in `sys.sys-log`.

### Exceptions

view must be created by local agent
database `<database>` does not exist
namespace `<namespace>` does not exist
views cannot be created in namespace *sys*
views cannot be defined on foreign ship databases
`<view>` as-of schema time out of order
`<view>` as-of data time out of order
`<view>` exists in `<namespace>`
view body must be a query
`<relation>` does not exist
view references another database
duplicate column names `<columns>`
`<view>` would shadow `<table>` used in `<view>`
state change after query in script

## ALTER VIEW

Replaces the definition of an existing `<view>`. The new definition is subject to all the rules of `CREATE VIEW`.

```
<alter-view> ::=
  ALTER VIEW [ <db-qualifier> ]<view>
    [ <as-of> ]
  AS [ WITH <common-table-expression> [ ,...n ] ] <query>
```

### Arguments

**`<view>`**
Name of the view to alter.

**`<as-of>`**
Timestamp of view alteration. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

**`<query>`**
The query producing the rows of the view.

### API
```
+$  alter-view
  $:  %alter-view
    view=qualified-table
    text=@t
    =crud-txn
    as-of=(unit as-of)
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

`ALTER VIEW` is rejected when the view is referenced by any live view.

The view's name continues to resolve to the table it shadows, if any, within the new body.

### Produced Metadata

message: ALTER VIEW <name>
server time: <timestamp>
schema time: <timestamp>

Updates the view in `sys.views`, `sys.view-references`, and `sys.columns`. Records an `alter` `view` event in `sys.sys-log`.

### Exceptions

view must be altered by local agent
database `<database>` does not exist
namespace `<namespace>` does not exist
`<view>` does not exist in `<namespace>`
`<view>` as-of schema time out of order
`<view>` as-of data time out of order
`<view>` used in `<view>`
view body must be a query
`<relation>` does not exist
view references another database
duplicate column names `<columns>`
state change after query in script

## DROP VIEW

Deletes a `<view>`.

```
<drop-view> ::=
  DROP VIEW [ FORCE ] [ <db-qualifier> ]<view>
    [ <as-of> ]
```

### Arguments

**`FORCE`**
Drop the view even when other views reference it, also dropping those views.

**`<view>`**
Name of the view to delete.

**`<as-of>`**
Timestamp of view deletion. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

### API
```
+$  drop-view
  $:  %drop-view
    view=qualified-table
    force=?
    as-of=(unit as-of)
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

Without `FORCE`, `DROP VIEW` is rejected when the view is referenced by any live view. With `FORCE`, every view referencing it, directly or through other views, is also dropped.

A dropped view remains available to queries with an `AS OF` time before the drop. The same view name may be created again after the drop time.

Dropping a view that shadows a table makes the table visible to queries again.

### Produced Metadata

message: DROP VIEW <name>
server time: <timestamp>
schema time: <timestamp>

The result also includes a message for each view dropped by `FORCE`. Removes the view from `sys.views`, `sys.view-references`, and `sys.columns`. Records a `drop` `view` event in `sys.sys-log`.

### Exceptions

view must be dropped by local agent
database `<database>` does not exist
namespace `<namespace>` does not exist
`<view>` does not exist in `<namespace>`
`<view>` as-of schema time out of order
`<view>` as-of data time out of order
`<view>` used in `<view>`, use `FORCE` to `DROP`
state change after query in script
