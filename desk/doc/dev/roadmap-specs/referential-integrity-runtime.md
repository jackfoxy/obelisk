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
4. Enforce parent-side `DELETE` and primary-key `UPDATE` actions: `RESTRICT`, `CASCADE`, and `SET DEFAULT`. Complete.
5. Apply RI semantics to `TRUNCATE TABLE`. Complete.
6. Apply FK lifecycle behavior for `DROP TABLE`, `ALTER TABLE RENAME TO`, column rename/drop/alter guards, primary-key alteration guards, and namespace table transfer. Current.

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
- Parent primary-key `UPDATE SET DEFAULT`.
- `TRUNCATE TABLE` `ON DELETE RESTRICT`, `CASCADE`, and `SET DEFAULT`.
- `DROP TABLE` FK guards and `DROP TABLE FORCE` FK metadata cleanup.
- `ALTER TABLE RENAME TO` FK metadata rewrite.
- Column lifecycle FK handling: `RENAME COLUMN` rewrites metadata; `DROP COLUMN` and `ALTER COLUMN` reject FK columns.
- Primary-key alteration rejects referenced tables.
- Namespace table transfer preserves FK metadata within the same database and rejects cross-database transfer involving FKs.
- `DROP FOREIGN KEY` regression coverage distinguishes the same source columns referencing different parent tables.

Current milestone:

- Milestone 6 residual FK drop coverage slice complete, pending user build/test confirmation.

Remaining work:

- Review remaining skipped FK tests/TODO coverage and close any residual lifecycle gaps.

## Current Slice Plan

Continue Milestone 6: FK lifecycle behavior.

Completed lifecycle slices:

- `DROP TABLE` without `FORCE` rejects outgoing FKs.
- `DROP TABLE` without `FORCE` rejects incoming FKs even with zero child rows.
- `DROP TABLE FORCE` removes incoming and outgoing FK metadata.
- Self-referential table drop behavior.
- `ALTER TABLE RENAME TO` preserves FK metadata by rewriting incoming and outbound structures.
- `RENAME COLUMN` rewrites FK metadata for source columns and referenced primary-key columns.
- `DROP COLUMN` and `ALTER COLUMN` reject FK source columns and referenced primary-key columns.
- Primary-key alteration rejects referenced tables.
- Namespace table transfer preserves FK metadata within the same database and rejects cross-database transfer involving FKs.

Next slices:

- Clean up remaining FK test skips/TODOs and confirm milestone closure.

## Milestone 5 Test Activation

Enabled the TRUNCATE FK tests for `RESTRICT`, `CASCADE`, `SET DEFAULT`, and the no-referencing-rows success case.
