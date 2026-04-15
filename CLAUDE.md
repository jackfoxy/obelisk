# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Skills

Invoke these skills proactively when relevant:

| Skill | When to use |
|-------|-------------|
| `/hoon-basics` | Any Hoon syntax questions or common idioms |
| `/hoon-fundamentals` | Subject-oriented programming, noun model, compilation |
| `/hoon-expert-assistant` | Idiomatic patterns, type system, performance |
| `/hoon-style-guide` | Naming, formatting, comments, anti-patterns |
| `/obelisk-test` | Whenever writing or modifying tests |
| `/obelisk-urql` | Whenever writing urQL scripts or queries |

## What is Obelisk

Obelisk is an RDBMS Gall agent for Urbit, written in Hoon. It implements **urQL**, a dialect of SQL with no NULLs, set-based results, time-indexed states, and atomic scripts. The single agent is `%obelisk`.

## Running Tests

Tests run inside a mounted Urbit ship via the `-test` thread. From dojo:

```
-test %/tests/lib/parse ~
-test %/tests/lib/queries ~
-test %/tests/lib/selections ~
```

Run all tests in a directory:
```
-test /=obelisk=/tests/lib ~
```

## Architecture

### Data flow

urQL tape → `parse.hoon` (parser) → AST (`sur/ast.hoon`) → execution libs → `sur/server-state.hoon` (agent state)

The Gall agent (`app/obelisk.hoon`) handles pokes with `%obelisk-action` marks containing `[%tape2 database=@tas script=tape]`.

### Core sur files — read at the start of every session, subject to change

| File | Role |
|------|------|
| `sur/ast.hoon` | All urQL AST types — the lingua franca between parser and executor |
| `sur/obelisk.hoon` | Runtime types: `action`, `set-table`, `data-row`, `joined-row`, `map-meta`, `named-ctes`, `resolved-scalar`, `txn-meta` |
| `sur/server-state.hoon` | Agent state: `server`, `database`, `schema`, `data`, `table`, `file`, `indexed-row` |

#### Critical type: `data-row`

`data-row` (in `sur/obelisk.hoon`) is a union type:
```hoon
+$  data-row  $%(joined-row indexed-row)
```
- `indexed-row` — single-table row: `[%indexed-row key=(list @) data=(map @tas @)]`
- `joined-row` — multi-table row: `[%joined-row key=(list @) data=(mip qualified-table @tas @)]`

`indexed-row.data` is a flat `(map @tas @)` (column name → value).
`joined-row.data` is a `(mip qualified-table @tas @)` — map-of-maps keyed by source table then column name.
Code operating on `data-row` must handle both cases.

#### `set-table` lifecycle

`set-table` is built dynamically during query execution and discarded when execution completes — it is not persisted. It accumulates rows and metadata as the query progresses through FROM, JOIN, WHERE, and SELECT phases.

#### `map-meta` — when each variant applies

- `unqualified-map-meta` — single-relation queries only; maps column name directly to `typ-addr`
- `qualified-map-meta` — required for joins; maps `[qualified-table column-name]` to `typ-addr`; may also be used for single-relation queries

### Other key files

| File | Role |
|------|------|
| `lib/parse.hoon` | urQL parser; door with `default-database=@tas`; entry: `(parse:parse(default-database '<db>') "<script>")` |
| `lib/selections.hoon` | SELECT / query execution including joins and set operations |
| `lib/ddl.hoon` | DDL execution (CREATE/ALTER/DROP) |
| `lib/crud.hoon` | INSERT / UPDATE / DELETE execution |
| `lib/predicate.hoon` | WHERE clause and predicate evaluation |
| `lib/scalars.hoon` | Scalar function evaluation |
| `lib/sys-views.hoon` | System metadata views (`sys.sys.*`) |
| `lib/utils.hoon` | Shared utilities |
| `lib/test-helpers.hoon` | Test infrastructure (see Testing section below) |

### Testing patterns

Test files live in `desk/tests/lib/`. Each file imports `*test-helpers` and defines arms named `test-<feature>-<nn>` (success) or `test-fail-<feature>-<nn>` (expected failures).

Test helpers are named `exec-<actions>-<resolves>`:
- **actions** = number of setup/mutation pokes after init
- **resolves** suffix: `r` = single `cmd-result`, `l` = `(list cmd-result)`, `1`/`2`/... = that many `cmd-result` comparisons

Common helpers:

| Helper | Use case |
|--------|----------|
| `exec-0-r` | DDL-only (CREATE TABLE, etc.) |
| `exec-0-1` | Schema setup then query |
| `exec-1-1` | Setup → mutate → verify |
| `exec-1-2` | Setup → mutate → verify two things |

Each helper takes `run=@ud`, an `init` poke `[tmsp=@da db=@tas uql=tape]`, optional action/resolve pokes in the same shape, and an `expect` value.

### urQL key properties

- No NULLs anywhere
- All table/query results are proper sets (no duplicate rows)
- Scripts are atomic (all-or-nothing)
- Every database state is time-indexed; queries can resolve at a past timestamp
- Namespace hierarchy: `database.namespace.table`

### Hoon idioms in this codebase

- Use `turn` to map/extract fields from a list — never `|-` recursion for this.
  Example: `%+  turn  cases  |=(cwt=case-when-then:ast when.cwt)`
- Types from `sur/ast.hoon` are the shared vocabulary across all libs; import with `/-  ast`
- The parser (`lib/parse.hoon`) is a door — build with default-database before calling arms
