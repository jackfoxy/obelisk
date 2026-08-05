# Scries and Subscriptions

Obelisk relations can be read directly from other agents, threads, generators,
and the dojo through the Gall scry and subscription interfaces. Each path names
a relation, a namespace, or a whole database and is executed as the equivalent
urQL query

```
FROM <relation> [ <as-of> ] SELECT { * | <column> [ ,...n ] }
```

so every read passes the same security processing as a poked command. Reads by
foreign ships are rejected.

## Scry paths

Scries use care `%x` on agent `%obelisk`. From the dojo the path ends with the
output mark, always `noun`:

```
.^(<mold> %gx /=obelisk=/<path>/noun)
```

```
<path> ::=
  /obelisk/[<as-of>/]<database>
  /obelisk/[<as-of>/]<database>/{ <namespace> | .. }
  /obelisk/[<as-of>/]<database>/{ <namespace> | .. }/<relation>
  /obelisk/[<as-of>/]<database>/{ <namespace> | .. }/<relation>/<column>...

<as-of> ::= { @da | @dr }
```

- `..` is shorthand for the default namespace `dbo`.
- `<relation>` is a table or view.
- One or more trailing `<column>` segments select only those columns, in path
  order; otherwise all columns are selected (`SELECT *`).
- An optional `<as-of>` segment directly after `/obelisk` queries the past server state:
  * `@da` (e.g. `~2024.10.3`) is an absolute `AS OF` time
  * `@dr`  (e.g. `~d30`) is a timespan back from now (`AS OF` now - `@dr`)

## Return molds

All molds are in `/sur/obelisk-ast.hoon` (`relation`) and `/lib/mip.hoon`
(`mip`).

| Path | Produces |
|------|----------|
| `/obelisk/<database>` | `(mip @tas @tas relation)` — namespace → name → relation |
| `/obelisk/<database>/<namespace>` | `(map @tas relation)` — name → relation |
| `/obelisk/<database>/<namespace>/<relation>[/<column>...]` | `relation` |

A malformed path, an unknown object, or a failed query produces `[~ ~]`.

## Examples

```
::  all rows of db1.dbo.my-table
.^(relation:ast %gx /=obelisk=/obelisk/db1/dbo/my-table/noun)

::  only col1 and col2
.^(relation:ast %gx /=obelisk=/obelisk/db1/dbo/my-table/col1/col2/noun)

::  the dbo namespace, two equivalent forms
.^((map @tas relation:ast) %gx /=obelisk=/obelisk/db1/dbo/noun)
.^((map @tas relation:ast) %gx /=obelisk=/obelisk/db1/'..'/noun)

::  the whole database
.^((mip @tas @tas relation:ast) %gx /=obelisk=/obelisk/db1/noun)

::  a system view
.^(relation:ast %gx /=obelisk=/obelisk/db1/sys/tables/noun)

::  the databases system view in database sys
.^(relation:ast %gx /=obelisk=/obelisk/sys/sys/databases/noun)

::  time travel: as of an absolute time
.^(relation:ast %gx /=obelisk=/obelisk/~2024.10.3/db1/dbo/my-table/noun)

::  time travel: 30 days ago
.^(relation:ast %gx /=obelisk=/obelisk/~d30/db1/dbo/my-table/noun)
```

## Subscriptions

Subscription paths are identical to scry paths without the care. A watch resolves the query once, gives the result as a single `%fact` with mark `%noun`, and immediately gives a `%kick`. The fact payload is the same noun a scry on the path produces (`relation`, `(map @tas relation)`, or `(mip @tas @tas relation)`).

```hoon
[%pass /my-wire %agent [our.bowl %obelisk] %watch /obelisk/db1/dbo/my-table]
```

An invalid path — and any subscription by a foreign ship — crashes the watch,
which arrives as a negative `%watch-ack`.

Subscriptions are one-shot reads: they do not (yet) push facts on subsequent changes to the underlying relations.

`AS OF` forms are supported and, like all Obelisk time travel, are idempotent — a kicked subscriber re-subscribing with the same `AS OF` path receives the same result.
