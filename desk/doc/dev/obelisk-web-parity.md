# Native Sail Front End: Baseline and Parity Matrix

This document completes work unit 1 of
`native-sail-frontend-plan.md`. It records the Hawk baseline, the current
Obelisk protocol, the selected web architecture, and the acceptance mapping
for every requirement in `native-sail-frontend.md`.

## Baseline

- Repository revision: `846bf0d`
- Hawk template: `templates/obelisk-template.hoon`
- Hawk template SHA-256:
  `8d30e1684fbe59be64928ab55bde842ce1c091997b9399e03d5f088f34fe0868`
- Native Sail prompt SHA-256:
  `b578471b2fb968646a89275ce7816615d9d235862a248a6fb9a61fd973a8913e`
- Work plan SHA-256:
  `6d953678051f74bd2acf95796b721d04124ad4b518221f6a0f5dc26774bf26e7`

The implementation baseline is the current desk, not assumptions embedded in
the older Hawk template. Where they differ, the current `%obelisk` agent and
surfaces are authoritative.

## Architecture Decisions

### Direct Eyre routing

Use direct Eyre routing in `desk/app/obelisk-web.hoon`, not Rudder.

Reasons:

- The desk has no Rudder dependency or established Rudder route pattern.
- The required route surface is small and fixed.
- Direct Eyre routing follows the existing native Sail pattern used by the
  sibling `%graph-viz` desk.
- Routing, request decoding, and response construction can remain isolated in
  pure helper gates, preserving a later migration path.

All HTTP responses will use the standard server response constructors,
including `give-simple-payload:app:server` for ordinary payloads.

### Module boundaries

| Module | Responsibility |
| --- | --- |
| `desk/app/obelisk-web.hoon` | Gall state, Eyre binding, HTTP dispatch, async coordination, Clay and `%obelisk` effects |
| `desk/lib/obelisk-web.hoon` | Sail page, embedded assets, pure JSON codecs, DTO conversion, validation and rendering helpers |
| `desk/sur/obelisk-web.hoon` | Web state, request, response, schema-tree, file and coordinator molds |
| `desk/tests/lib/obelisk-web.hoon` | Every automated test introduced by this project |

The browser uses the generated Sail document plus embedded vanilla JavaScript
and CSS. It has no Hawk, React, npm, or external runtime dependency.

### State and authority

The `%obelisk` agent remains the sole authority for parsing, executing, and
committing database operations. `%obelisk-web` does not duplicate database
state or write database state directly.

The web agent uses versioned saved state and reconstructs transient state on
load. Eyre bindings, request queues, timers, and in-flight jobs are transient.
Loading an old or empty state must never crash the agent.

Hawk installation and removal are outside the new agent. The existing Hawk
installation path remains until native parity has passed its final acceptance
check.

### `%obelisk` request coordination

Current `/server` replies contain no request identifier. Therefore the web
agent will serialize `%obelisk-action` requests through one bounded FIFO:

1. Accept and validate a local authenticated HTTP request.
2. Enqueue one typed job, subject to a queue limit.
3. Watch `/server`, poke `%obelisk`, and start a Behn timeout for the head job.
4. Match the next `/server` fact or kick only to that head job.
5. Respond exactly once, clean up the watch and timer, then start the next job.

Timeout, malformed fact, kick, missing `%obelisk`, and queue overflow paths
must all produce a terminal HTTP response and leave the coordinator ready for
the next job. This avoids changing the public `%obelisk` protocol solely for
the UI.

### Authoritative schema invalidation

For Run, the coordinator first sends the current `%parse` action and inspects
the returned typed commands. It then sends the current `%script` action. A
successful script response carries `schemaChanged=true` only when the parsed
commands contain schema-changing DDL. The browser then reloads the schema and
restores expansion state by stable node identity.

This deliberately avoids client-side urQL regular expressions and avoids a
schema reload after every read-only query. `%obelisk` still parses again during
execution; correctness is preferred over adding an alternate execution API.

### Clay file namespace

Saved scripts and result exports use Clay under `/data/obelisk/ui` with `%txt`
content. API paths are relative to that root. Empty components, `.` and `..`,
absolute paths, control characters, and invalid Clay components are rejected.

The file browser is recursive. Save distinguishes create from overwrite;
overwrite requires an explicit flag. Save As uses the same endpoint with a new
path. New unsaved editor tabs use browser-only names such as `script-1` until
saved. Result exports default to names such as `results-1`.

### Browser state

Open tabs, active tab, unsaved text, selections, pane sizes, active output tab,
schema expansion, default database, and pagination live in `sessionStorage`.
Clay is used only for explicitly saved scripts and result exports.

### HTTP and JSON contract

All API routes require an authenticated Eyre request and `src.bowl == our`.
Asset routes are served only beneath the application prefix. API bodies and
responses use typed JSON encoding and decoding; user text is never assembled
by string interpolation into JSON or HTML.

Provisional route contract:

| Method | Route | Purpose | Success |
| --- | --- | --- | --- |
| `GET` | `/apps/obelisk` | Sail application page | `200 text/html` |
| `GET` | `/apps/obelisk/` | Sail application page | `200 text/html` |
| `GET` | `/apps/obelisk/app.js` | Embedded browser code | `200 text/javascript` |
| `GET` | `/apps/obelisk/app.css` | Embedded styles | `200 text/css` |
| `POST` | `/apps/obelisk/api/run` | Parse, run selected/full urQL, return all results | `200 application/json` |
| `POST` | `/apps/obelisk/api/parse` | Parse selected/full urQL | `200 application/json` |
| `POST` | `/apps/obelisk/api/schema` | Load the complete schema tree | `200 application/json` |
| `POST` | `/apps/obelisk/api/files/browse` | Recursively list the UI Clay namespace | `200 application/json` |
| `POST` | `/apps/obelisk/api/files/load` | Load one saved text file | `200 application/json` |
| `POST` | `/apps/obelisk/api/files/save` | Create or explicitly overwrite one text file | `200 application/json` |

Status policy:

| Status | Meaning |
| --- | --- |
| `400` | Malformed route input, JSON, path, or request shape |
| `401` | Missing or invalid authenticated Eyre session |
| `404` | Unknown route or missing Clay file |
| `409` | Save would overwrite without explicit permission |
| `422` | Valid request rejected by urQL parse or execution |
| `429` | Coordinator queue is full |
| `500` | Internal invariant or unexpected response failure |
| `503` | `%obelisk` is unavailable |
| `504` | `%obelisk` or Clay operation timed out |

Unknown routes and methods are terminal responses; no request may hang.

## Current `%obelisk` Contract

The web agent must construct the current actions from
`desk/sur/obelisk-ast.hoon`:

```hoon
[%script default-database=@tas format=result-format urql=tape]
[%parse default-database=@tas urql=tape]
```

Run uses `%vector`, not the template's deprecated `%tape` format. Replies on
`/server` are:

```hoon
(each (list cmd-result:ast) tang)
(each (list command:ast) tang)
```

The current result variants that must be converted without silent loss are:

- `%action`
- `%relation-name`
- `%message`
- `%vector-count`
- `%server-time`
- `%security-time`
- `%schema-time`
- `%data-time`
- `%result-set`
- `%relations`
- `%select-relation`

`%result-set` contains ordered `%vector` rows. Each cell contains the column
name and a typed `dime`; the JSON DTO must preserve order, name, aura, and a
display value. Browser paging is a view over the full returned data so Copy and
Save Results can include every row and every result set.

## Hawk Behavior Inventory

### Layout and session state

- Header across the top.
- Resizable schema sidebar on the left.
- Tabbed editor in the center.
- Resizable output pane at the bottom.
- Current ship identity in the workspace.
- Pane sizes, editor tabs, selection, output mode, and schema expansion survive
  refresh for the browser session.

### Header controls

- File menu: New, Open, Save, Save As, Close.
- Run button and `F5` shortcut.
- Parse button.
- Save Results menu.
- Documentation link.
- Default database selector.
- Developer links.

### Editor behavior

- Multiple tabs with one active tab.
- New drafts receive incrementing `script-N` names.
- Opening an already open saved path activates it rather than duplicating it.
- Run and Parse use selected text when the selection is nonempty; otherwise
  they use the full active buffer.
- Copy exposes the active output text or table data.

### Schema tree

The tree is built with these system-view queries:

```text
FROM sys.sys.databases SELECT database;
FROM <db>.sys.namespaces SELECT namespace;
FROM <db>.sys.tables SELECT namespace, name;
FROM <db>.sys.table-keys
  SELECT namespace, name, key-ordinal, key, key-ascending;
FROM <db>.sys.columns
  SELECT namespace, name, col-ordinal, col-name, col-type;
```

The native implementation must use the same views and qualify dynamic
identifiers through typed server-side construction. It must sort databases,
namespaces, relations, keys, and columns deterministically.

The `sys` database contains these known system views:

- `namespaces`
- `tables`
- `table-keys`
- `foreign-keys`
- `columns`
- `sys-log`
- `data-log`

Database, namespace, relation, key, and column nodes are collapsible. Relation
nodes show key order and direction plus column auras. The current default
database is visibly marked.

Relation context actions insert templates for SELECT, INSERT, and CREATE.
Known read-only system views offer SELECT only. Inserted identifiers must be
qualified and escaped correctly.

### Query and parse output

- Command results are displayed in original order.
- Metadata variants are readable labeled messages.
- Result sets are tables with headers and row numbers.
- Large tables page at 800 rows with pages of 500 rows.
- Result and Messages tabs separate ordinary results from diagnostics.
- Parse output displays the parsed command noun in readable form.
- Tang output includes a concise summary and expandable full details.
- Multiple result sets remain distinct.
- Save Results supports comma, space, and tab delimiters and separates result
  sets with a blank line.

## Known Baseline Drift and Risks

| Drift or risk | Resolution |
| --- | --- |
| The Hawk template sends deprecated `%tape` output. | Native Run sends `%script` with `%vector`. |
| The template renderer expects `%relation`; the current AST defines `%relation-name`. | Implement and test the current `%relation-name` tag. |
| The current AST includes `%security-time`, which the template does not render. | Add an explicit readable renderer and fixture. |
| The template duplicates system-view metadata in JavaScript and disagrees with its Hoon metadata for one `sys-log` column. | Treat current Hoon/system query data as authoritative; keep only the relation allowlist client-side. |
| `/server` facts are uncorrelated. | Use the bounded single-flight FIFO coordinator. |
| The template detects schema DDL with browser regular expressions. | Inspect typed `%parse` results before successful `%script` invalidation. |
| Hawk child-file APIs are not available to the native app. | Use the validated Clay namespace and typed file API. |
| The template's unavailable view assumes Hawk can refresh installation. | Return `503` with a retryable native unavailable state. |
| `%relations` and `%select-relation` may be uncommon under `%vector`. | Convert or explicitly represent them; never drop an unknown current variant. |
| There is no npm/browser test harness in this desk. | Test pure Hoon behavior and asset hooks automatically; verify browser interaction on a fake ship in final acceptance. |

## Requirement-to-Work Matrix

Every row identifies the later work-plan unit and its acceptance evidence.

| ID | Requirement | Unit | Acceptance check |
| --- | --- | --- | --- |
| A1 | Dedicated `%obelisk-web` agent and versioned, crash-safe state | 2 | Load empty/current state and assert transient state is reconstructed |
| A2 | Direct Eyre bind under `/apps/obelisk` | 3 | Root and trailing-slash route tests return HTML |
| A3 | Explicit content types and terminal route responses | 3 | Asset, unknown-route, and wrong-method route tests |
| A4 | Local source and authenticated API enforcement | 3 | Foreign-source and unauthenticated requests are rejected |
| A5 | Typed, injection-safe JSON codecs | 4 | Round trips include quotes, slashes, newlines, Unicode, and empty values |
| A6 | Browser/backend contract covers run, parse, schema, and files | 4 | Codec fixtures cover every request and response type |
| A7 | Current `%script %vector` and `%parse` action construction | 5 | Exact action noun assertions |
| A8 | Current success and tang reply decoding | 5 | Success, failure, malformed fact, and kick fixtures |
| A9 | Bounded FIFO for overlapping requests | 6 | Ordering, queue-limit, and exactly-once response tests |
| A10 | Cleanup after timeout, kick, and malformed reply | 6 | Each failure permits the following queued job to run |
| A11 | `%obelisk` availability and retryable unavailable response | 6 | Missing-agent fixture returns `503` without wedging |
| A12 | `%obelisk` remains sole database authority | 7 | Run path uses only typed `%obelisk-action` effects |
| A13 | Hawk-independent native operation | 7 | Run/parse integration works without Hawk watch or file APIs |
| S1 | Schema uses the required system-view queries | 8 | Query-generation fixtures match all five query shapes |
| S2 | Complete deterministic database tree | 8 | Shuffled fixtures yield stable database/namespace/relation ordering |
| S3 | Keys, direction, columns, and auras | 8 | Schema DTO fixture retains ordinal and direction metadata |
| S4 | Known `sys` system views | 8 | All seven views appear with correct read-only classification |
| S5 | Default database loading, selection, and marker | 8, 15 | Selector and tree marker update together |
| S6 | Authoritative schema mutation detection | 8 | Typed DDL/non-DDL command fixtures set the flag correctly |
| S7 | Refresh schema after successful schema change only | 8, 15 | UI reloads after successful DDL, not parse/error/read-only runs |
| S8 | Preserve schema expansion across refresh | 8, 15 | Expanded stable node identities remain expanded |
| O1 | Convert every current `cmd-result` variant | 9 | Fixture and assertion for all eleven variants |
| O2 | Preserve ordered cells, names, auras, and display text | 9 | Vector DTO fixture asserts exact order and types |
| O3 | Tang summary and expandable full details | 9, 16 | Tang fixture renders both summary and complete trace |
| O4 | Multiple result sets and full-data exports | 9, 16 | Export fixture contains all sets separated by a blank line |
| O5 | Comma, space, and tab delimiters | 9, 16 | Exact export fixtures for all three delimiters |
| F1 | Recursive Clay browsing under one validated root | 10 | Nested listing and path-rejection tests |
| F2 | Load saved text into tabs | 10, 14 | Load round trip preserves arbitrary script text |
| F3 | Create, explicit overwrite, Save, and Save As | 10, 14 | Create succeeds; implicit overwrite is `409`; explicit overwrite succeeds |
| F4 | Draft `script-N` and export `results-N` names | 10, 14, 16 | New-name allocation fixtures are stable and collision-aware |
| F5 | Clay failures and timeouts are terminal | 10 | Error fixtures respond once and leave subsequent operations usable |
| L1 | Header, left schema, center editor, bottom output | 11 | Sail structure assertions and fake-ship visual check |
| L2 | Resizable panes and responsive narrow layout | 11, 12 | CSS hooks plus desktop and narrow fake-ship checks |
| L3 | Keyboard and accessibility basics | 11, 12 | Semantic controls, labels, focus order, and visible focus check |
| H1 | File menu with New/Open/Save/Save As/Close | 12, 14 | Each menu command has a browser handler and manual flow check |
| H2 | Run, Parse, Save Results, docs, default DB, dev links | 12, 15, 16 | Control hook assertions and fake-ship interaction check |
| E1 | Multiple tabs, active tab, and no duplicate open path | 13 | Session reducer fixtures cover create/open/activate/close |
| E2 | Selection-or-buffer execution | 13 | Empty and nonempty selection fixtures |
| E3 | Run on `F5` and Copy behavior | 13, 16 | Keyboard hook and clipboard payload checks |
| E4 | Refresh-surviving session state | 13 | Serialize/restore fixtures plus browser refresh check |
| B1 | Schema relation SELECT/INSERT/CREATE templates | 15 | Exact template fixtures use qualified escaped identifiers |
| B2 | System views expose SELECT only | 15 | Context-menu classification fixture |
| R1 | Run and Parse controls use HTTP API | 15 | Fake-ship integration returns output for both operations |
| R2 | Results/Messages tabs and ordered command output | 16 | Mixed result fixture retains command order and categorization |
| R3 | Tables include headers and row numbers | 16 | DOM rendering fixture hooks and fake-ship check |
| R4 | Paging threshold 800 and page size 500 | 16 | Boundary fixtures at 799, 800, 801, and page transitions |
| R5 | Parse noun is readable | 16 | Parse response renders a nonempty command representation |
| R6 | Copy and Save Results include all rows and result sets | 16 | Paged multi-set fixture exports complete data |
| P1 | Desk packaging includes new app, lib, sur, tests, and assets | 17 | Desk build resolves every mark and import |
| P2 | Existing Hawk removal only after native parity | 17 | Removal is the final packaging change after acceptance passes |
| P3 | Setup, route, Clay, and migration documentation | 17 | Documentation review against actual paths and state version |
| T1 | All new automated tests live in one required file | 2-18 | Only `desk/tests/lib/obelisk-web.hoon` contains project tests |
| T2 | Full build, automated suite, and fake-ship workflow | 18 | Manual command transcript and completed parity checklist |

## Step 1 Exit Check

- Hawk routes, controls, state, schema behavior, result rendering, and file
  behavior are inventoried.
- Current `%obelisk-action`, result format, and reply molds are recorded.
- Direct Eyre was selected over Rudder with a documented rationale.
- Every prompt requirement maps to a work unit and an acceptance check.

