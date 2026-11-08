# Ace editor keys

The default keybindings of the vendored Ace editor, on Windows and
Linux. **Generated** from `tests/browser/ace-win-linux-shortcuts.json`
by `bin/keyboard-docs.js`, which is the same manifest the cross-app
conflict gate reads — so this page and the gate cannot disagree about
what Ace binds. Do not edit it by hand.

Pinned at Ace 1.44.0, revision
`da98d501d58b`. Selecting **Vim** under
Settings → Keybindings replaces this keymap wholesale; those bindings
are pinned separately in `tests/browser/vim-chords.json`.

An application chord that displaces one of these is recorded in the
app's `tests/browser/shortcut-exceptions.json`, with what it displaces
and how that stays reachable. See `key-policy.md`.

## Line Operations

| Windows/Linux | Action |
|:----|:-------|
| Ctrl-D | Remove line |
| Alt-Shift-Down | Copy lines down |
| Alt-Shift-Up | Copy lines up |
| Alt-Down | Move lines down |
| Alt-Up | Move lines up |
| Alt-Delete | Remove to line end |
| Alt-Backspace | Remove to linestart |
| Ctrl-Backspace | Remove word left |
| Ctrl-Delete | Remove word right |
| — | Split line |

## Selection

| Windows/Linux | Action |
|:----|:-------|
| Ctrl-A | Select all |
| Shift-Left | Select left |
| Shift-Right | Select right |
| Ctrl-Shift-Left | Select word left |
| Ctrl-Shift-Right | Select word right |
| Shift-Home | Select line start |
| Shift-End | Select line end |
| Alt-Shift-Right | Select to line end |
| Alt-Shift-Left | Select to line start |
| Shift-Up | Select up |
| Shift-Down | Select down |
| Shift-PageUp | Select page up |
| Shift-PageDown | Select page down |
| Ctrl-Shift-Home | Select to start |
| Ctrl-Shift-End | Select to end |
| Ctrl-Shift-D | Duplicate selection |
| Ctrl-Shift-P | Select to matching bracket |
| Ctrl-Shift-M | Expand to matching |
| Ctrl-\, Ctrl-P | Jump to matching |
| Ctrl-Shift-\, Ctrl-Shift-P | Select to matching |
| Ctrl-Shift-L | Expand to line |

## Multicursor

| Windows/Linux | Action |
|:----|:-------|
| Ctrl-Alt-Up | Add cursor above |
| Ctrl-Alt-Down | Add cursor below |
| Ctrl-Alt-Right | Add next occurrence to multi-selection |
| Ctrl-Alt-Left | Add previous occurrence to multi-selection |
| Ctrl-Alt-Shift-Up | Move multicursor from current line to the line above |
| Ctrl-Alt-Shift-Down | Move multicursor from current line to the line below |
| Ctrl-Alt-Shift-Right | Remove current occurrence from multi-selection and move to next |
| Ctrl-Alt-Shift-Left | Remove current occurrence from multi-selection and move to previous |
| Ctrl-Shift-L | Select all from multi-selection |
| Ctrl-Alt-A | Align cursors |

## Go to

| Windows/Linux | Action |
|:----|:-------|
| Left | Go to left |
| Right | Go to right |
| Ctrl-Left | Go to word left |
| Ctrl-Right | Go to word right |
| Up | Go line up |
| Down | Go line down |
| Alt-Left, Home | Go to line start |
| Alt-Right, End | Go to line end |
| PageUp | Go to page up |
| PageDown | Go to page down |
| Ctrl-Home | Go to start |
| Ctrl-End | Go to end |
| Ctrl-L | Go to line... |
| Ctrl-Down | Scroll line down |
| Ctrl-Up | Scroll line up |
| Ctrl-P | Go to matching bracket |
| — | Scroll page down |
| — | Scroll page up |
| Alt-E | Go to next error |
| Alt-Shift-E | Go to previous error |

## Find/Replace

| Windows/Linux | Action |
|:----|:-------|
| Ctrl-F | Find |
| Ctrl-H | Replace |
| Ctrl-K | Find next |
| Ctrl-Shift-K | Find previous |
| Ctrl-Alt-K | Find all |
| Alt-K | Select or find next |
| Alt-Shift-K | Select or find previous |

## Folding

| Windows/Linux | Action |
|:----|:-------|
| F2 | Toggle fold widget |
| Alt-F2 | Toggle parent fold widget |
| Alt-L, Ctrl-F1 | Fold selection |
| Alt-Shift-L, Ctrl-Shift-F1 | Unfold |
| Alt-0 | Fold all |
| Alt-Shift-0 | Unfold all |
| — | Fold all comments |

## Other

| Windows/Linux | Action |
|:----|:-------|
| F1 | Open command palette |
| Tab | Indent |
| Ctrl-] | Block indent |
| Shift-Tab | Outdent |
| Ctrl-[ | Block outdent |
| Ctrl-Z | Undo |
| Ctrl-Shift-Z, Ctrl-Y | Redo |
| Ctrl-, | Show the settings menu |
| Ctrl-/ | Toggle comment |
| Ctrl-Shift-/ | Toggle block comment |
| Ctrl-T | Transpose letters |
| Ctrl-Enter | Enter full screen |
| Ctrl-Shift-U | Change to lower case |
| Ctrl-U | Change to upper case |
| Insert | Overwrite |
| Ctrl-Shift-E | Macros replay |
| Ctrl-Alt-E | Macros recording |
| Delete | Delete |
| — | Center selection |
| Ctrl-U | To uppercase |
| Ctrl-Shift-U | To lowercase |
| Ctrl-Alt-S | Sort lines |
| Ctrl-Shift-Up | Modify number up |
| Ctrl-Shift-Down | Modify number down |
| Ctrl-Shift-B | Format selection (Beautify) |

## Unbound on Windows and Linux

These rows have a Mac binding only, so nothing here claims them:

- Line Operations: Split line
- Go to: Scroll page down
- Go to: Scroll page up
- Folding: Fold all comments
- Other: Center selection
