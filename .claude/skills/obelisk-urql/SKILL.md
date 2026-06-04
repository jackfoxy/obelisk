---
name: obelisk-urql
description: Write, review, debug, parse, or generate Obelisk urQL — the SQL dialect of the Obelisk RDBMS Gall agent. Covers clause ordering, object qualification, naming/literal rules, scripts/atomicity, DDL, DML, queries, joins, set operations, scalar functions, time travel, system views, and the Hoon API. Use whenever working with urQL scripts or the %obelisk agent.
user-invocable: true
disable-model-invocation: false
---

# Obelisk urQL

urQL is the scripting/query language of Obelisk, an Urbit-native RDBMS Gall agent. It is derived from SQL but differs deliberately for readability, composability, and set/relational theory. **When this skill conflicts with `desk/doc/usr/reference/` or `desk/doc/usr/users-guide.md`, the docs win.**

## First, the differences that bite

- **Clause order is evaluation order:** `FROM .. WHERE .. SELECT ..`, never SELECT-first.
- **`SCALARS` placement:** in a query it sits after the joins and **before `WHERE`**; in `UPDATE`/`DELETE` it sits **before** the verb.
- **Results are always sets** (no dup rows, no `DISTINCT`). **No nulls** — columns are non-nullable typed atoms.
- **Auras, not SQL types.** Literals follow hoon aura notation (`'cord'`, `~2024.1.1`, `--20`, `.~3.14`, `Y`/`N`). `@rd` floats need the `.~` prefix.
- **No inlined sub-queries** — use CTEs (`WITH`) / joins, referenced by alias.
- `INNER` keyword does not exist (`JOIN` is inner). `DELETE` **requires** `WHERE`. SQL "schema" → `NAMESPACE`.
- Comments are `::` and `/* */` (delimiters in columns 1–2), not `--`.
- Object names are hoon terms (`@tas`: lower-case, hyphens, leading letter); aliases may be mixed case and are case-agnostic.
- `AND` has precedence over `OR`; use parentheses for clarity.
- Scripts (`;`-separated) are **atomic** and share one timestamp; once a query appears, no later command may mutate.

## Workflow

**Writing / generating:** confirm clause order (`syntax.md` → Clause ordering), qualify objects (`<db>.<ns>.<obj>`, `dbo`/current-db defaults), use aura-correct literals, list columns explicitly (avoid `SELECT *` in saved scripts), end arithmetic scalars with `END`.

**Reviewing:** check for SQL-isms that are invalid urQL — SELECT-first order, `--` comments, `INNER JOIN`, `DISTINCT`, nulls, `NULL`, inlined sub-selects, `DELETE` with no `WHERE`, qualified table names inside predicates (only unqualified names or aliases allowed), bare `3.14` where `@rd` is meant. Verify joins actually share a name+aura column (natural join crashes otherwise).

**Debugging:** parser errors are terse — inspect the script structurally (clause order, parentheses, `END` on arithmetic, comma vs. no-comma in `VALUES` rows). Use the `%parse` action to inspect the AST without executing (`system-views-and-api.md`). Confirm a feature is actually executed and not parse-only (see status tables).

## Reference map

| Topic | File |
|:--|:--|
| Clause order, qualification, naming, literals, comments, scripts/atomicity | [references/syntax.md](references/syntax.md) |
| `CREATE/ALTER/DROP DATABASE·NAMESPACE·TABLE`, foreign keys | [references/ddl.md](references/ddl.md) |
| `INSERT`, `UPSERT`, `UPDATE`, `DELETE`, `TRUNCATE TABLE` | [references/dml.md](references/dml.md) |
| `SELECT`, joins, CTEs, predicates, set operations, status tables | [references/queries.md](references/queries.md) |
| Scalar functions (control flow, arithmetic, datetime, math, string) | [references/scalars.md](references/scalars.md) |
| `AS OF` / time-travel rules and warnings | [references/time-travel.md](references/time-travel.md) |
| System views, `cmd-result`/`vector` molds, Hoon `%obelisk-action` API | [references/system-views-and-api.md](references/system-views-and-api.md) |

Canonical worked examples: [examples/sample.md](examples/sample.md).

## Implementation status (frequent traps)

Parsed but **not yet executed**: `LEFT/RIGHT/OUTER JOIN`, `GROUP BY`, `HAVING`, `ORDER BY`, `TOP`, aggregates, `DIVIDED BY`, `EQUIV`, `EXISTS`, `ALL`, `ANY`, `INSERT` from SELECT, `CREATE/ALTER/DROP INDEX`, `CREATE/DROP VIEW`. Executed: DDL on databases/namespaces/tables, `INSERT`/`UPSERT`/`UPDATE`/`DELETE`/`TRUNCATE`, `JOIN`/`JOIN ON`/`CROSS JOIN`, `UNION`/`EXCEPT`/`INTERSECT`, scalar functions, `AS OF`.
