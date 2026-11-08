# Keyboard shortcuts

## Workbench

These shortcuts work inside and outside the editor. An open dialog suppresses
workbench shortcuts; Escape closes the dialog. Parse and Run remain disabled
while a request is running or a saved result is selected.

<!-- generated: app-chords -->

| Key | Action | Where |
|:----|:-------|:------|
| F1 | Help (displaces Ace’s Open command palette) | Everywhere |
| F2 | Settings (displaces Ace’s Toggle fold widget) | Everywhere |
| F3 | Parse without running | Everywhere |
| F5 | Run | Everywhere |
| Ctrl-S | Save the script | Everywhere |
| Ctrl-Shift-S | Save the script as | Everywhere |
| Alt-O | Open a saved script | Outside the editor |
| Alt-C | Copy the script | Outside the editor |
| Ctrl-Alt-V | Source or preview | Outside the editor |

<!-- /generated -->

F1 and F2 override Ace's command palette and fold-widget bindings. The
palette's commands remain reachable through **Ctrl-,**, Ace's own settings
menu; folding keeps `Alt-F2`, `Alt-L`, `Alt-Shift-L`, `Alt-0` and
`Alt-Shift-0`. The remaining default Ace keybindings apply in the urQL
Editor pane.

Alt-O and Alt-C, rather than Ctrl-O and Ctrl-Shift-C: **Ctrl-O** is free in
Ace's own keymap but is a Vim binding in both insert and normal mode, and
the editor can be switched to Vim in Settings; **Ctrl-Shift-C** is
Chromium's element inspector. The last three apply outside the editor only,
so Ctrl-C and its neighbours keep their ordinary meaning while editing.

## File rows

In the explorer, with a file row focused:

| Key | Action |
|:----|:-------|
| Enter or Space | Open the file |
| Delete | Delete the file, after confirming |
| Alt-Enter, Shift-F10, or the context-menu key | Open the row's actions |

## Ace editor

The editor pane uses the vendored Ace editor. Its full default keymap is
in **[Ace editor keys](ace-keys.md)**, generated from the same manifest
the cross-app conflict gate reads. **Settings → Keybindings** selects the
default or the Vim keymap.

## Dialogs

Help and Settings navigate the same way in every app on this shell; see
**[Dialog keyboard contract](modal-keys.md)**.

## Policy

Why a chord is or is not available, and what it may displace:
**[Key policy](key-policy.md)**.
