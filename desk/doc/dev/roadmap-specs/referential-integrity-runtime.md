# Referential Integrity Runtime Plan

This plan implements the runtime behavior specified in:

- `desk/doc/usr/reference/ddl-table.md`
- `desk/doc/usr/reference/dml-truncate-table.md`
- `desk/sur/server-state-1.hoon` FK metadata comments

Do not address `DROP NAMESPACE` in this plan.

## Scope

Preserve the documented schema molds.

`foreign-constraints` on `file` is the authoritative incoming dependency structure. `outbound-fk-index` on `table` is a derived child-side lookup. Every canonical incoming FK has outbound entries for each source column included in that FK, and every outbound entry corresponds to exactly one canonical incoming FK.

`foreign-constraint.constrained-values` is a maintained reverse index:

- map key: complete referenced parent primary-key value tuple, equal to the child FK value tuple
- set value: child row primary-key tuples currently referencing that parent key

Runtime must maintain `constrained-values` as part of child-side DML:

- `INSERT`: for each outbound FK, add the inserted child PK tuple under the inserted child FK value tuple.
- `UPDATE`: when FK source columns change, move old child PK from the old FK tuple to the new child PK under the new FK tuple; when only child PK changes, replace old child PK with new child PK under the same FK tuple; when both change, do both as one logical move.
- `DELETE`: remove the deleted child PK tuple from the deleted row's FK value tuple and prune empty child-key sets.
- Self-referential FKs follow the same rule on one file.

State migration is out of scope for this plan.

## Current Status

Completed:

- FK metadata molds, construction helpers, and `CREATE TABLE` FK validation/registration.
- `ALTER TABLE ADD FOREIGN KEY`, including existing child-row validation, `constrained-values` seeding, and referenced parent data-time advancement.
- All runtime `constrained-values` mutations advance the referenced parent file data time.
- `ALTER TABLE DROP FOREIGN KEY`, including incoming and outbound metadata removal.
- Child-side DML checks for `INSERT` and child FK-column `UPDATE`, including `AS OF` content-time lookup.
- Parent `DELETE RESTRICT`, `CASCADE`, and `SET DEFAULT`.
- Parent primary-key `UPDATE RESTRICT`, `CASCADE`, and `SET DEFAULT`.
- `TRUNCATE TABLE` `ON DELETE RESTRICT`, `CASCADE`, and `SET DEFAULT`.
- `DROP TABLE` FK guards and `DROP TABLE FORCE` FK metadata cleanup.
- `ALTER TABLE RENAME TO` FK metadata rewrite.
- Column lifecycle FK handling: `RENAME COLUMN` rewrites metadata; `DROP COLUMN` and `ALTER COLUMN` reject FK columns.
- Primary-key alteration rejects referenced tables.
- Namespace table transfer preserves FK metadata within the same database and rejects cross-database transfer involving FKs.
- `DROP FOREIGN KEY` regression coverage distinguishes same source columns referencing different parent tables.

Known gaps:

- None currently tracked in this plan.

## Implementation Milestones

1. Add pure helpers for `constrained-values` maintenance.
   Keep this milestone free of runtime DML rewiring. It should produce small,
   reviewable helpers that operate on `foreign-constraints`,
   `constrained-values`, row maps, key-column lists, and `outbound-fk-entry`
   values. Runtime callers are added in milestone 2.

   1.1. Locate the canonical incoming constraint.
      - Inputs: parent `foreign-constraints`, child table key, and source-column list.
      - Return the matching `foreign-constraint` or fail with an internal invariant error.
      - Match the same identity already used by `fk-canonical-exists` and `remove-incoming-fk`: `constrained-table` plus ordered `constrained-columns`.
      - Exit criteria: handles multiple FKs with the same source columns pointing at different parent tables by relying on the parent-file context, not only source columns; fails if zero or more than one matching canonical incoming constraint exists, so corrupt metadata cannot be silently repaired by picking the first match.

   1.2. Add one child reference to one constraint.
      - Inputs: one `foreign-constraint`, parent FK value tuple, and child primary-key tuple.
      - Insert the child PK into the set at `constrained-values[parent-key]`.
      - Preserve existing child PKs already stored for that parent key.
      - Exit criteria: adding the first reference creates the map entry; adding another reference to the same parent key expands the set; adding a duplicate is idempotent.

   1.3. Remove one child reference from one constraint.
      - Inputs: one `foreign-constraint`, parent FK value tuple, and child primary-key tuple.
      - Remove the child PK from the set at `constrained-values[parent-key]`.
      - Prune the parent-key map entry when the resulting child-key set is empty.
      - Exit criteria: removing a missing reference is treated as an invariant failure, not a silent no-op, so runtime bugs surface during development.

   1.4. Move one child reference within one constraint.
      - Inputs: one `foreign-constraint`, old FK tuple, new FK tuple, old child PK tuple, and new child PK tuple.
      - Implement as one pure helper that removes the old reference and adds the new reference to the returned constraint.
      - Cover the three documented cases: FK tuple changed, child PK tuple changed, and both changed.
      - Exit criteria: same-key moves replace old child PK with new child PK; cross-key moves prune the old key when empty and create/extend the new key.

   1.5. Apply a constrained-value edit back to a parent file.
      - Inputs: parent `file`, child table key, source-column list, and an edit operation from slices 1.2-1.4.
      - Rewrite exactly one matching `foreign-constraint` in `foreign-constraints.parent-file`.
      - Preserve constraint order and all unrelated incoming constraints.
      - Exit criteria: returns an updated parent file and fails if zero or more than one canonical incoming constraint matches.

   1.6. Add row/key tuple extraction adapters.
      - Reuse existing `fk-row-values` behavior for FK tuples and child primary-key tuples.
      - Add a thin helper, if needed, that derives `{old,new}` FK and child-PK tuples from old/new child rows plus an `outbound-fk-entry`.
      - Include an adapter for child primary-key-only updates, where the outbound FK source columns are unchanged but every outbound FK for the child table still needs the old child PK tuple replaced with the new child PK tuple.
      - Exit criteria: no ad-hoc tuple-building is duplicated in future `INSERT`, `UPDATE`, or `DELETE` runtime code.

   1.7. Build an initial `constrained-values` map from existing child rows.
      - Inputs: one validated `foreign-constraint`, child `file`, and source-column list.
      - Reuse the add-reference helper from slice 1.2 for each existing child row.
      - Use this when `ALTER TABLE ADD FOREIGN KEY` registers a constraint over rows that already exist.
      - Exit criteria: adding an FK over existing valid rows produces the same reverse index that would have existed if the FK had been present before those rows were inserted.

   1.8. Add focused helper tests or assertions before runtime integration.
      - Prefer direct helper tests if the local test style supports them; otherwise add the first runtime-state assertions with milestone 2.
      - Cover add, remove-and-prune, same-key PK move, cross-key FK move, seed-from-existing-rows, and the missing/duplicate-constraint invariant failures.
      - Exit criteria: helper behavior is proven independently enough that milestone 2 only wires known operations into DML paths.

2. Maintain `constrained-values` for child-side DML.
   2.1. `INSERT`: update parent files after child rows are accepted.
      - Reuse the validated outbound FK list from child FK enforcement.
      - Add one reverse-index reference for each inserted child row and outbound FK.
      - Handle self-referential FKs by updating the in-flight child file before it is persisted.
      - Exit criteria: inserting child rows maintains parent `constrained-values`, including multi-row self-referential inserts.

   2.2. `UPDATE`: move reverse-index references for changed FK source columns and changed child primary keys.
      - Update FKs whose source columns changed.
      - When child primary-key columns change, update every outbound FK for that child table even if no FK source column changed.
      - Handle self-referential FKs without losing same-file changes.
      - Exit criteria: every child row update leaves parent `constrained-values` pointing at the new child primary key and/or new parent key.

   2.3. `DELETE`: remove reverse-index references for deleted child rows.
      - Remove one reverse-index reference for each deleted child row and outbound FK.
      - Prune empty parent-key entries via the shared helper.
      - Handle self-referential FKs while preserving delete-time parent-side behavior.
      - Exit criteria: deleting child rows removes stale parent `constrained-values` entries before the mutation is committed.

3. Maintain `constrained-values` through parent-side actions.
   3.1. `DELETE CASCADE`: remove cascaded child rows from all reverse indexes.
      - Identify the child rows deleted by each cascading incoming constraint before mutating the child file.
      - Reuse the child-side delete constrained-value remover for every outbound FK on the child table, including the FK that caused the cascade.
      - Handle self-referential cascades without losing same-file metadata edits.
      - Exit criteria: deleting parent rows with `ON DELETE CASCADE` leaves no stale `constrained-values` entries for any deleted child row.

   3.2. `DELETE SET DEFAULT`: move affected child references from the deleted parent key to the bunt key.
      - For the incoming constraint that triggered `SET DEFAULT`, move each matching child PK from the deleted parent key to the default parent key.
      - If the default update changes the child primary key, update every outbound FK reverse index for that child row.
      - Preserve existing validation that the bunt parent key exists and is not itself being deleted.
      - Exit criteria: deleting parent rows with `ON DELETE SET DEFAULT` leaves `constrained-values` pointing at the default parent key and the final child PK tuple.

   3.3. `UPDATE CASCADE`: move affected child references from the old parent key to the new parent key.
      - For the incoming constraint that triggered `CASCADE`, move each matching child PK from the old parent key to the new parent key.
      - If the cascaded FK update changes the child primary key, update every outbound FK reverse index for that child row.
      - Preserve existing duplicate-key and parent-side restrict behavior.
      - Exit criteria: updating parent primary keys with `ON UPDATE CASCADE` leaves `constrained-values` pointing at the new parent key and the final child PK tuple.

   3.4. `UPDATE SET DEFAULT`: move affected child references from the old parent key to the bunt key.
      - For the incoming constraint that triggered `SET DEFAULT`, move each matching child PK from the old parent key to the default parent key.
      - If the default update changes the child primary key, update every outbound FK reverse index for that child row.
      - Preserve existing validation that the bunt parent key exists.
      - Exit criteria: updating parent primary keys with `ON UPDATE SET DEFAULT` leaves `constrained-values` pointing at the default parent key and the final child PK tuple.

   3.5. `TRUNCATE TABLE`: apply parent delete semantics to reverse indexes.
      - Bulk-clear constrained values for outbound FKs on any table whose full row set is removed.
      - Bulk-clear incoming constrained values on the truncated parent table after restrict/cascade/set-default checks pass.
      - Keep `SET DEFAULT` guarded: do not shortcut moves when matching child rows exist, since the bunt key is deleted by the truncate.
      - Exit criteria: truncating parent rows leaves no stale reverse-index entries without walking each deleted row.

4. Add multi-table cycle detection.
   4.1. Build a foreign-key graph view from schema metadata.
      - Represent each FK as a directed edge from child table key to parent table key.
      - Carry both `on-delete` and `on-update` actions on the edge.
      - Include the candidate FK being validated without mutating schema/data first.
      - Exit criteria: validation code can ask one helper whether adding a candidate FK would introduce a disallowed cycle.

   4.2. Detect cycles reachable from a candidate child/parent edge.
      - Walk the graph from the candidate parent back toward the candidate child.
      - Track the path actions so the helper can classify the resulting cycle.
      - Treat a cycle as allowed only when every FK action in the cycle is `RESTRICT` for both delete and update.
      - Exit criteria: RESTRICT-only cycles return success; any cycle containing `CASCADE` or `SET DEFAULT` returns a failure.

   4.3. Integrate cycle detection into `CREATE TABLE`.
      - Check all FKs declared on the new table against existing schema plus earlier FKs in the same statement.
      - Preserve the existing self-referential cascade rejection behavior while replacing it with the shared helper.
      - Keep the current error text: `CREATE TABLE: cascading foreign-key cycle not allowed`.
      - Exit criteria: `CREATE TABLE` allows RESTRICT-only self/multi-table cycles and rejects cascading cycles before metadata registration.

   4.4. Integrate cycle detection into `ALTER TABLE ADD FOREIGN KEY`.
      - Check the candidate FK against the current schema before existing-row validation/metadata registration.
      - Keep the current error text: `ALTER TABLE: cascading foreign-key cycle not allowed`.
      - Exit criteria: `ALTER TABLE ADD FOREIGN KEY` allows RESTRICT-only cycles and rejects any cycle containing `CASCADE` or `SET DEFAULT`.

   4.5. Add focused cycle detection tests.
      - Cover RESTRICT-only two-table and three-table cycles.
      - Cover two-table and three-table cycles containing `CASCADE` and `SET DEFAULT`.
      - Cover self-referential RESTRICT allowed and self-referential cascade/set-default rejected through both create and alter where applicable.
      - Exit criteria: cycle behavior is proven without relying on later runtime failures.

5. Add tests without changing existing tests.

## Test Plan

Add passing tests in `desk/tests/lib/foreign-key.hoon`, continuing `test-foreign-key-13+`:

- RESTRICT-only two-table cycle allowed.
- Self-referential multi-row insert can reference rows from the same statement.
- Self-referential RESTRICT behavior works for valid insert and protected delete/update.
- Parent non-primary-key update does not trigger RI action.
- `constrained-values` invariant after `ALTER TABLE ADD FOREIGN KEY` over existing child rows.
- `constrained-values` invariant after child `INSERT`.
- `constrained-values` invariant after child FK-column `UPDATE`.
- `constrained-values` invariant after child primary-key-only `UPDATE`.
- `constrained-values` invariant after child `DELETE`.
- Optional: invariant after cascade and set-default parent actions.

Add fail-on-message tests, continuing `test-fail-foreign-key-25+`:

- cascading two-table cycle rejected with `ALTER TABLE: cascading foreign-key cycle not allowed`
- cascading three-table cycle rejected with `ALTER TABLE: cascading foreign-key cycle not allowed`
- self-referential cascade rejected with `CREATE TABLE: cascading foreign-key cycle not allowed`
- self-referential orphan insert rejected with `INSERT: FOREIGN KEY parent key not found`
- self-referential RESTRICT delete/update rejected with existing restrict messages

The metadata tests should establish the invariant by executing ordinary SQL and then inspecting `server.state`; they should not introduce runtime-only test hooks.
