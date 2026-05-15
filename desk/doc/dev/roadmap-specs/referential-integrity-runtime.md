# `sys.foreign-keys` System View Plan

The previous referential-integrity runtime plan is complete. This file now
tracks the next referential-integrity visibility project: a schema-only system
view for declared foreign keys.

## Goal

Add a user-queryable system view named `sys.foreign-keys` in every user
database. The view exposes declared foreign-key schema metadata only; it does
not expose live `constrained-values`, referenced parent key values, or child
row counts.

The view should be self-contained enough that a user can inspect a foreign key,
including composite key order and referential actions, without joining to
`sys.table-keys`.

## View Contract

`sys.foreign-keys`

| Column | Aura | Meaning |
| --- | --- | --- |
| `parent-namespace` | `@tas` | Namespace of the referenced parent table. |
| `parent-table` | `@tas` | Referenced parent table. |
| `child-namespace` | `@tas` | Namespace of the constrained child table. |
| `child-table` | `@tas` | Constrained child table. |
| `ordinal` | `@ud` | One-based column ordinal within the foreign key. |
| `parent-column` | `@tas` | Parent/referenced primary-key column at `ordinal`. |
| `child-column` | `@tas` | Child/source column at `ordinal`. |
| `on-delete` | `@tas` | Delete action: `%restrict`, `%cascade`, or `%set-default`. |
| `on-update` | `@tas` | Update action: `%restrict`, `%cascade`, or `%set-default`. |

Default ordering:

1. `parent-namespace`
2. `parent-table`
3. `child-namespace`
4. `child-table`
5. `ordinal`

Expected row shape:

- One row per parent/child column pair in a declared FK.
- Composite FKs produce multiple rows sharing the same parent/child table
  identity and ordered by `ordinal`.
- Empty tables still emit declared FK rows.
- Dropped FKs, dropped tables, and dropped namespaces do not appear in current
  view queries, but historical `AS OF` queries can see prior schema states.

The canonical source of truth is `foreign-constraints` on each parent `file`.
`outbound-fk-index` is a derived child-side lookup and should not be used as the
primary source for the view.

## Work Slices

### Slice 1: User Documentation

Update `desk/doc/usr/users-guide.md`.

- Add `sys.foreign-keys` to the Appendix: System Views section.
- Document the column list, auras, row semantics, and default ordering.
- State explicitly that the view is schema-only and does not expose current
  referencing row counts or key values.
- Mention that `parent-column` is included even though foreign keys reference
  the complete parent primary key, so composite FK order is directly visible.

Exit criteria:

- Users can learn the view contract from the users guide without reading
  implementation comments.
- The documentation distinguishes FK definitions from runtime RI state.

### Slice 2: View Definition

Add the static view definition in `desk/lib/sys-views.hoon`.

- Add a `++ sys-foreign-keys-view` arm following the style of
  `sys-table-keys-view` and `sys-columns-view`.
- Define the nine columns from the view contract with the correct auras.
- Define the default ordering listed above.
- Add the view to database creation and database rename setup paths in
  `desk/lib/main.hoon`, wherever the existing user-database system views are
  installed.

Exit criteria:

- Newly created databases include `sys.foreign-keys`.
- Renamed databases preserve/rebuild the view like the other user-database
  system views.
- Query planning can resolve `FROM sys.foreign-keys SELECT *`.

### Slice 3: View Population Runtime

Populate `sys.foreign-keys` from canonical parent-side metadata.

- Add a `++ sys-view-foreign-keys` helper in `desk/lib/sys-views.hoon`.
- Walk `files.data` entries so only tables present at the selected content time
  participate.
- For each parent table/file, enumerate `foreign-constraints.parent-file`.
- For each `foreign-constraint`, emit one row per paired
  `constrained-columns` and parent primary-key column.
- Derive parent columns from `key.pri-indx.parent-table`, preserving primary-key
  order.
- Emit `actions.on-delete` and `actions.on-update` as `@tas`.
- Add a `%foreign-keys` case to `populate-system-view`.
- Keep ordering deterministic through the normal system-view ordering path.

Exit criteria:

- The view reports FK definitions created by both `CREATE TABLE` and
  `ALTER TABLE ADD FOREIGN KEY`.
- Composite FKs emit correctly ordered column-pair rows.
- Empty child tables still show declared FKs.

### Slice 4: Cache Invalidation And Lifecycle Wiring

Wire `sys.foreign-keys` into system-view cache updates.

- Add `[%sys %foreign-keys]` to `upd-view-caches` entries for all operations
  that can create, remove, or rewrite FK metadata:
  - `CREATE TABLE`
  - `ALTER TABLE`
  - `DROP TABLE`
  - `ALTER NAMESPACE`
  - `DROP NAMESPACE`
- Review `CREATE NAMESPACE`, `DROP NAMESPACE`, and database-level setup paths
  so the view exists and invalidates consistently with `sys.tables`,
  `sys.table-keys`, and `sys.columns`.
- Do not invalidate the view for child-side DML that only changes
  `constrained-values`; this view is schema-only.

Exit criteria:

- Current queries after FK schema changes see fresh rows.
- Pure data changes do not unnecessarily refresh `sys.foreign-keys`.
- Historical `AS OF` queries continue to resolve the correct schema snapshot.

### Slice 5: Runtime Tests

Add tests in `desk/tests/lib/sys-views.hoon`, unless local organization makes
`desk/tests/lib/foreign-key.hoon` more appropriate for a focused FK view group.

Passing test coverage:

- `CREATE TABLE` with single-column FK appears in `sys.foreign-keys`.
- `CREATE TABLE` with composite FK emits one row per column in ordinal order.
- `ALTER TABLE ADD FOREIGN KEY` appears in the view.
- `ALTER TABLE DROP FOREIGN KEY` removes rows from the current view.
- Empty child tables still emit FK rows.
- `ON DELETE` and `ON UPDATE` actions are exposed as `%restrict`, `%cascade`,
  or `%set-default`.
- Multiple FKs in one database are all present and sorted deterministically.
- Self-referential FK appears with the same parent and child table identity.

Historical/lifecycle coverage:

- `AS OF` before an FK exists returns no rows for it.
- `AS OF` after `ADD FOREIGN KEY` but before `DROP FOREIGN KEY` returns rows.
- `DROP TABLE FORCE` removes incoming/outgoing FK rows from the current view.
- `ALTER NAMESPACE ... TRANSFER TABLE` rewrites parent and/or child namespace
  values in the current view and preserves old rows under prior `AS OF`.
- `DROP NAMESPACE` removes FK rows for dropped tables in the current view and
  preserves old rows under prior `AS OF`.

Negative/regression coverage:

- Child `INSERT`, `UPDATE`, and `DELETE` do not change the schema-only view
  rows except for ordinary result metadata timestamps.
- Composite FK order remains stable after unrelated schema changes.

Exit criteria:

- The new tests fail before runtime implementation and pass after it.
- Tests prove both current-state behavior and `AS OF` behavior.

### Slice 6: Users Guide Example Polish

After runtime tests pass, add a short users-guide example if the Appendix entry
feels too abstract.

Suggested example:

```urql
FROM sys.foreign-keys
SELECT parent-namespace, parent-table, child-namespace, child-table,
       ordinal, parent-column, child-column, on-delete, on-update;
```

Exit criteria:

- The example matches actual output semantics from the implemented view.
- The users guide remains concise and does not duplicate the DDL reference.

## Implementation Notes

- Prefer parent-side `foreign-constraints` as the authoritative source.
- Use `outbound-fk-index` only for cross-checking during development, not as the
  view source.
- The view should not expose or depend on `constrained-values`.
- The view should not create a new FK identifier unless a later schema change
  introduces named constraints or permits multiple distinguishable FKs between
  the same parent/child identity.
- Column names should avoid overloading `key`: use `child-column`, not
  `child-key-column`, because FK source columns are not necessarily child
  primary-key columns.

## Open Questions

None currently.
