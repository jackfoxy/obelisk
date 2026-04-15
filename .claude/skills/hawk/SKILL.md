---
name: hawk
description: Build, refactor, and debug Hawk pages, templates, cards, and Hawk-500 code. Use when working with Hawk's page/file/card/load model, Sail/manx UI, `%twin`/`%call`/`%view`/`%lens` composition, Feather styling, Spine components, or Hawk metadata such as `/peek/public` and `/poke/public`.
user-invocable: true
disable-model-invocation: false
validated: safe
---

# hawk skill

Use this skill when editing Hawk applications or explaining Hawk behavior.

## Quick workflow

1. Identify the page path, expected card shape, and whether this is a plain page, a template, or a composed page.
2. Prefer simple `manx` output first. Only reach for richer `load` composition when behavior clearly needs it.
3. Read card data through `c` and file/tree data through `f`.
4. Use Feather classes and semantic Sail before adding custom CSS or JS.
5. Check metadata early, especially `/title`, `/pulse`, `/peek/public`, and `/poke/public`.
6. Put `!:` at the top of Hawk-500 pages while debugging.

## Read These References As Needed

- For Hawk's types, compile subject, loads, forms, event loop, and utility doors, read [references/core-model.md](references/core-model.md).
- For Feather, Spine, templates, auth/public access, URL behavior, configuration, and debugging guidance, read [references/ui-and-ops.md](references/ui-and-ops.md).

## Default Working Rules

- Treat Hawk as a tree of programmable pages: `file -> page -> {meta, code, data}`.
- Keep the root dime at `/` as the command kind for non-empty cards.
- Prefer `%manx` for straightforward pages.
- Use `%twin` for shared code, `%call` for shared code with initialization data, `%view` for mirroring another page's data, `%lens` for subtree reductions, and `%shed` only as a final asynchronous load.
- Do not hand-walk `info` or `file` trees unless the utility doors are insufficient.
- Do not put secrets in public page code. A public page exposes its `code.page` too.

## Practical Checks

- If a form behaves oddly, verify card path names and whether values are being parsed as dimes instead of plain strings.
- If a page does not update as expected, check whether it depends on the changed subtree through `%view`, `%twin`, `%call`, or `%lens`.
- If a page is meant to be internet-visible or form-submittable, verify `/peek/public` and `/poke/public`.
- If styling drifts, prefer Feather classes or `head-extras` overrides before custom one-off CSS.

## Manual And Source Pointers

- Manual root: `https://hawk.computer/~~/~/manual/`
- Some utilities are underdocumented in the manual. Inspect `/lib/hawk/hoon` and `/lib/html-utils/hoon` when needed.
