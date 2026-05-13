# Referential Integrity Runtime Plan

This plan implements the runtime behavior specified in `desk/doc/usr/reference/ddl-table.md` and `desk/doc/usr/reference/dml-truncate-table.md`.

## Scope

The implementation preserves the documented schema molds except for making the already-documented foreign-key metadata fields real:

- `foreign-constraints` on `file` is the authoritative incoming dependency structure.
- `outbound-fk-index` on `table` is a derived child-side lookup.
- Every canonical incoming foreign key has outbound entries for each source column included in that foreign key.
- Every outbound entry corresponds to exactly one canonical incoming foreign key.

State migration is out of scope for this slice.

## Milestones

1. Make FK metadata real, add metadata construction helpers, and implement `CREATE TABLE` FK validation/registration. Complete.
2. Implement `ALTER TABLE ADD FOREIGN KEY` and `ALTER TABLE DROP FOREIGN KEY`. Complete.
3. Enforce child-side DML checks for `INSERT` and child FK-column `UPDATE`. Complete.
4. Enforce parent-side `DELETE` and primary-key `UPDATE` actions: `RESTRICT`, `CASCADE`, and `SET DEFAULT`. Current.
5. Apply RI semantics to `TRUNCATE TABLE`.
6. Apply FK lifecycle behavior for `DROP TABLE`, `ALTER TABLE RENAME TO`, column rename/drop/alter guards, primary-key alteration guards, and namespace table transfer.

## Status

Completed:

- FK metadata molds, construction helpers, and `CREATE TABLE` FK validation/registration.
- `ALTER TABLE ADD FOREIGN KEY`, including existing child-row validation.
- `ALTER TABLE DROP FOREIGN KEY`, including incoming and outbound metadata removal.
- Child-side DML checks for `INSERT` and child FK-column `UPDATE`, including `AS OF` content-time lookup.
- Parent `DELETE RESTRICT`.
- Parent `DELETE CASCADE`.
- Parent `DELETE SET DEFAULT`.
- Parent primary-key `UPDATE RESTRICT`.
- Parent primary-key `UPDATE CASCADE`.

Current milestone:

- Enforce parent-side `DELETE` and primary-key `UPDATE` actions: `RESTRICT`, `CASCADE`, and `SET DEFAULT`.

Remaining milestones:

- Apply RI semantics to `TRUNCATE TABLE`.
- Apply FK lifecycle behavior for `DROP TABLE`, `ALTER TABLE RENAME TO`, column rename/drop/alter guards, primary-key alteration guards, and namespace table transfer.

## Current Slice Plan

Implement parent-side `DELETE` and primary-key `UPDATE` in small testable slices:

1. Parent primary-key `UPDATE SET DEFAULT`
   - Set constrained child columns to bunt/default values.
   - Verify the default FK value references an existing parent key.
   - Rebuild child primary indexes when child primary-key columns are affected.

## Milestone 4 Test Activation

Unskip tests only as their slice lands:

- `test-foreign-key-06` for parent PK `UPDATE SET DEFAULT`.
- Keep parent non-PK update coverage as a low-cost regression once parent update logic exists.
