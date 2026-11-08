# Key policy

Every application chord declares what it costs, as `policy` on its row
in the app's `++shortcuts` arm. The cross-app conflict gate —
`tests/browser/shortcut-conflicts.test.js` — checks the declaration
against two pinned keymaps and the browser, and fails the build rather
than let a collision reach a user whose editor was in the wrong mode.

## The three policies

**`%free`** — the binding appears in neither pinned keymap. Nothing is
displaced. This is where a new chord should land.

**`%override`** — a deliberate conflict. The gate requires an entry in
the app's `tests/browser/shortcut-exceptions.json` naming what the chord
displaces and how that stays reachable, which is the evidence the
collision was a decision. An override that displaces nothing is
mislabelled and should be `%free`.

**`%gated`** — an editing chord, admitted only outside the editor. Its
`when` may not be `always`; the gate rejects that as a contradiction.

`when` says *where* a chord fires — `always`, `no-editor`, `editor`, or
`preview`. `policy` says what firing there costs. They are different
questions and the gate checks both.

## Two keymaps, not one

`ace-win-linux-shortcuts.json` pins Ace's own keymap and `ace-keys.md`
is generated from it. **Settings → Keybindings swaps in the Vim keymap
wholesale**, so a chord free against Ace may still be taken;
`vim-chords.json` pins that one, generated from the vendored bundle by
`bin/vim-chords.js`.

Checking only Ace is how `Ctrl-O` was nearly taken for Open in all three
apps: it is Mac-only in Ace's Windows/Linux table and therefore looked
free, while Vim binds it in both insert and normal mode. `Alt-O` is free
in both.

A Vim sequence is recorded by its leading key, as `prefix`. `f` is not a
complete Vim binding, but `f<character>` means Vim claims the `f`
keydown and then waits — so an app that bound bare `f` would swallow the
motion.

## Never bind these

The browser keeps them, and will not always hand them over:

- `Ctrl-1` through `Ctrl-8` — tab switching
- `Ctrl-T`, `Ctrl-N`, `Ctrl-W` — new tab, new window, close
- `F11` — fullscreen

The gate requires a `reserved` entry in the exceptions file for any of
these, with a reason. `Ctrl-1` has one where it is used: it is delivered
and cancelable in Chromium, and an app binding it declares a free alias
alongside, for any engine that keeps it.

And never bind these *globally*, because they are the editor's:
`Ctrl-Z`, `Ctrl-Y`, `Ctrl-A`, `Ctrl-C`, `Ctrl-X`, `Ctrl-V`. Where an
application needs them they must be `%gated` or `%preview`.

## Delivery is a separate question

No manifest says whether the browser hands a chord to the page, or
whether `preventDefault` stops its own action.
`tests/browser/real/chord-delivery.spec.js` presses each candidate and
records both. A chord that is never delivered cannot be bound whatever
the manifests say; a chord that is delivered but not cancelable is
worse than useless, because the app's command runs *and* the browser
acts.

Only Chromium is installed in this checkout. The spec runs under
whatever projects the Playwright config declares, so adding a firefox
project widens it.

## Row keys are not chords

Delete and Alt-Enter on a focused file row are handled by the row, not
by the chord table: they mean something only there, and the dispatcher
gates on editor focus rather than on which control has focus. Shift-F10
and the context-menu key work the same way — the browser raises
`contextmenu` on the focused element and the row answers it.

## Dialogs

See `modal-keys.md`. In short: while a dialog is open every bound chord
is swallowed, except the one that opened it, which closes it.
