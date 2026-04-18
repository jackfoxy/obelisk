# CLAUDE.md

Project-specific guidance for Obelisk, an RDBMS Gall agent implementing urQL (a SQL dialect with no NULLs, set-based results, and atomic scripts).

## Style

Minimize tokens. Keep correctness.
Start with answer. No filler, no preamble, no postamble, no meta-commentary, no sign-off.
If code asked: give code.
If fix asked: give fix.
If plan asked: give shortest useful complete plan.
Explain only if asked.
Do not narrate code or tools.
Ask one short question only if blocked. If asked if there are any questions, respond with all relevant concise questions. Else assume and proceed.
Use tiny heartbeat only for long tasks: `checking`, `patching`, `testing`.


## Skills

Invoke these skills proactively when relevant:

| Skill | When to use |
|-------|-------------|
| `/hoon-basics` | Hoon syntax questions or common idioms |
| `/hoon-fundamentals` | Subject-oriented programming, noun model, compilation |
| `/hoon-expert-assistant` | Idiomatic patterns, type system, performance |
| `/hoon-style-guide` | Naming, formatting, comments, anti-patterns |
| `/obelisk-test` | Writing or modifying tests |
| `/obelisk-urql` | Writing urQL scripts or queries |

## Critical types

### `data-row` (in `sur/obelisk.hoon`)

Union type for single vs. multi-table rows:
```hoon
+$  data-row  $%(joined-row indexed-row)
```
- `indexed-row` — single-table: `[%indexed-row key=(list @) data=(map @tas @)]`
- `joined-row` — multi-table: `[%joined-row key=(list @) data=(mip qualified-table @tas @)]`

Code must handle both cases; `indexed-row.data` is flat; `joined-row.data` is nested by table.

### `map-meta` variants

- `unqualified-map-meta` — single-relation only; column name → `typ-addr`
- `qualified-map-meta` — required for joins; `[qualified-table column-name]` → `typ-addr`

### `set-table` lifecycle

Built dynamically during query execution, discarded when complete. Accumulates rows and metadata through FROM, JOIN, WHERE, SELECT phases.

## Team idioms

- Use `turn` to map/extract fields from lists — never `|-` recursion.
  Example: `%+  turn  cases  |=(cwt=case-when-then:ast when.cwt)`
- Import AST types with `/-  ast`; they're the shared vocabulary across libs
- `lib/parse.hoon` is a door — build with default-database before calling arms
