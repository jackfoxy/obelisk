# Dialog keyboard contract

Help, Settings, and any dialog a consumer puts on urui's controller
navigate the same way in every application on this shell.

| Key | What it does |
|:----|:-------------|
| Esc | Close, and give focus back to what opened it |
| Tab / Shift-Tab | Cycle the dialog's controls, trapped inside it |
| Enter / Space | Activate the focused control |
| Up / Down / Left / Right | Move within Theme, Keybindings, Screen format |
| Home / End | First and last option in a group |
| PageUp / PageDown | Page the dialog's content |
| The chord that opened it | Close it again |

Most of that is the browser's own behaviour, and urui's job is only to
stop getting in its way. Two arrangements make it work:

**The card is the scroll container, and it takes focus on open.** A
dialog's `.help-card` is height-bounded and scrolls; it carries
`tabindex="-1"` so it can be focused by script without entering the tab
order. Opening a dialog focuses the card, which is what gives PageUp,
PageDown, Home and End something to act on. The close button is the
first control a Tab reaches from there.

**Every group is a real group.** Theme is a `<select>` and Keybindings
are `<input type="radio">`, both of which the browser arrows natively.
Screen format is a `role="radiogroup"` of `role="radio"` buttons with a
roving `tabindex`: Tab reaches the group once, the arrows move within it
on both axes, and moving selects — a radiogroup has nothing to confirm
afterwards.

Two rules urui implements itself:

**A dialog is never a way to reach the application behind it.** While a
dialog is open the dispatcher swallows every bound application chord,
so a half-visible workbench cannot be driven by the keyboard.

**The chord that opened a dialog closes it.** The one exception to the
rule above: a dialog records the command that owns it, and that chord
toggles. Without it F2 opened Settings and then did nothing, leaving
Escape as the only way out.

Focus restoration prefers whatever held focus before the dialog opened.
A dialog opened by its chord had no opener focused, so the fallback is
the control the dialog belongs to — its toolbar button — rather than the
document body.

## Moving a dialog

**Every dialog can be dragged** — Settings, Help, the file dialog that
Open and Save As share, the confirmations, and a consumer's own. Each of
them covers the thing it is about: a file list, a tree, the row being
deleted, the editor behind it. That is exactly what a user may need to
see while answering.

A dialog with a header is dragged by it. One without — the confirmation
is a message and two buttons — is dragged by its card. Either way the
controls inside are never handles, so a click on Close, Cancel or OK is
never swallowed by the drag.

Double-clicking the handle returns the dialog to the middle, and so does
closing it: a remembered position can end up off-screen after a window
resize, and a dialog that opens where it cannot be seen is worse than one
that always opens centred, so no position is persisted. A dialog cannot
be dragged out of reach either — it is held against the viewport as it
moves, and again if the window is resized.

The card moves by a transform rather than by a change of layout, so
everything else about it is unaffected: it is still the scroll
container, still height-bounded, and still traps Tab.

**Dragging is pointer-only.** There is no keyboard equivalent, because
every obvious chord for one is taken — `Alt`+arrows are the browser's
history navigation, and the arrows themselves move within the dialog's
own groups. A dialog never has to be moved to be used, so this costs
reach rather than function, but it is a gap.

## Adding a dialog

`runtime.dialogs.modal(element, {close, fallback, command})` puts a
consumer's dialog on the same controller, ranked above Settings and
below the file and confirm dialogs. `close` runs on Escape, `fallback()`
names what takes focus when what held it is gone, and `command` names
the chord that owns it, if it has one.

A consumer's dialog is draggable too, by its header if it has one and by
its card otherwise. Pass `drag: false` for one that should not move — a
dialog pinned to something behind it, say.
