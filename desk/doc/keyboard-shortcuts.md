# Keyboard shortcuts

Default Ace editor keybindings for urQL Editor pane.

## Line Operations

| Windows/Linux                  | Mac                            | Action                         |
|:-------------------------------|:-------------------------------|:-------------------------------|
| Ctrl-D                         | Command-D                      | Remove line                    |
| Alt-Shift-Down                 | Command-Option-Down            | Copy lines down                |
| Alt-Shift-Up                   | Command-Option-Up              | Copy lines up                  |
| Alt-Down                       | Option-Down                    | Move lines down                |
| Alt-Up                         | Option-Up                      | Move lines up                  |
| Alt-Delete                     | Ctrl-K                         | Remove to line end             |
| Alt-Backspace                  | Command-Backspace              | Remove to linestart            |
| Ctrl-Backspace                 | Option-Backspace, Ctrl-Option-Backspace | Remove word left               |
| Ctrl-Delete                    | Option-Delete                  | Remove word right              |
| ---                            | Ctrl-O                         | Split line                     |

## Selection

| Windows/Linux                  | Mac                            | Action                         |
|:-------------------------------|:-------------------------------|:-------------------------------|
| Ctrl-A                         | Command-A                      | Select all                     |
| Shift-Left                     | Shift-Left                     | Select left                    |
| Shift-Right                    | Shift-Right                    | Select right                   |
| Ctrl-Shift-Left                | Option-Shift-Left              | Select word left               |
| Ctrl-Shift-Right               | Option-Shift-Right             | Select word right               |
| Shift-Home                     | Shift-Home                     | Select line start              |
| Shift-End                      | Shift-End                      | Select line end                |
| Alt-Shift-Right                | Command-Shift-Right            | Select to line end             |
| Alt-Shift-Left                 | Command-Shift-Left             | Select to line start           |
| Shift-Up                       | Shift-Up                       | Select up                      |
| Shift-Down                     | Shift-Down                     | Select down                    |
| Shift-PageUp                   | Shift-PageUp                   | Select page up                 |
| Shift-PageDown                 | Shift-PageDown                 | Select page down               |
| Ctrl-Shift-Home                | Command-Shift-Up               | Select to start                |
| Ctrl-Shift-End                 | Command-Shift-Down             | Select to end                  |
| Ctrl-Shift-D                   | Command-Shift-D                | Duplicate selection            |
| Ctrl-Shift-P                   | ---                            | Select to matching bracket     |
| Ctrl-Shift-M                   | Ctrl-Shift-M                   | Expand to matching             |
| Ctrl-\, Ctrl-P                 | Command-\                      | Jump to matching               |
| Ctrl-Shift-\, Ctrl-Shift-P     | Command-Shift-\                | Select to matching             |
| Ctrl-Shift-L                   | Command-Shift-L                | Expand to line                 |

## Multicursor

| Windows/Linux                  | Mac                            | Action                         |
|:-------------------------------|:-------------------------------|:-------------------------------|
| Ctrl-Alt-Up                    | Ctrl-Option-Up                 | Add cursor above               |
| Ctrl-Alt-Down                  | Ctrl-Option-Down               | Add cursor below               |
| Ctrl-Alt-Right                 | Ctrl-Option-Right              | Add next occurrence to multi-selection |
| Ctrl-Alt-Left                  | Ctrl-Option-Left               | Add previous occurrence to multi-selection |
| Ctrl-Alt-Shift-Up              | Ctrl-Option-Shift-Up           | Move multicursor from current line to the line above |
| Ctrl-Alt-Shift-Down            | Ctrl-Option-Shift-Down         | Move multicursor from current line to the line below |
| Ctrl-Alt-Shift-Right           | Ctrl-Option-Shift-Right        | Remove current occurrence from multi-selection and move to next |
| Ctrl-Alt-Shift-Left            | Ctrl-Option-Shift-Left         | Remove current occurrence from multi-selection and move to previous |
| Ctrl-Shift-L                   | Ctrl-Shift-L                   | Select all from multi-selection |
| Ctrl-Alt-A                     | Ctrl-Alt-A                     | Align cursors                  |

## Go to

| Windows/Linux                  | Mac                            | Action                         |
|:-------------------------------|:-------------------------------|:-------------------------------|
| Left                           | Left, Ctrl-B                   | Go to left                     |
| Right                          | Right, Ctrl-F                  | Go to right                    |
| Ctrl-Left                      | Option-Left                    | Go to word left                |
| Ctrl-Right                     | Option-Right                   | Go to word right                |
| Up                             | Up, Ctrl-P                     | Go line up                     |
| Down                           | Down, Ctrl-N                   | Go line down                   |
| Alt-Left, Home                 | Command-Left, Home, Ctrl-A     | Go to line start               |
| Alt-Right, End                 | Command-Right, End, Ctrl-E     | Go to line end                 |
| PageUp                         | Option-PageUp                  | Go to page up                  |
| PageDown                       | Option-PageDown, Ctrl-V        | Go to page down                |
| Ctrl-Home                      | Command-Home, Command-Up       | Go to start                    |
| Ctrl-End                       | Command-End, Command-Down      | Go to end                      |
| Ctrl-L                         | Command-L                      | Go to line...                  |
| Ctrl-Down                      | Command-Down                   | Scroll line down               |
| Ctrl-Up                        | ---                            | Scroll line up                 |
| Ctrl-P                         | ---                            | Go to matching bracket         |
| ---                            | Option-PageDown                | Scroll page down               |
| ---                            | Option-PageUp                  | Scroll page up                 |
| Alt-E                          | F4                             | Go to next error                |
| Alt-Shift-E                    | Shift-F4                       | Go to previous error            |

## Find/Replace

| Windows/Linux                  | Mac                            | Action                         |
|:-------------------------------|:-------------------------------|:-------------------------------|
| Ctrl-F                         | Command-F                      | Find                            |
| Ctrl-H                         | Command-Option-F               | Replace                         |
| Ctrl-K                         | Command-G                      | Find next                       |
| Ctrl-Shift-K                   | Command-Shift-G                | Find previous                   |
| Ctrl-Alt-K                     | Ctrl-Alt-G                     | Find all                        |
| Alt-K                          | Ctrl-G                         | Select or find next              |
| Alt-Shift-K                    | Ctrl-Shift-G                   | Select or find previous          |

## Folding

| Windows/Linux                  | Mac                            | Action                         |
|:-------------------------------|:-------------------------------|:-------------------------------|
| F2                             | F2                             | Toggle fold widget              |
| Alt-F2                         | Alt-F2                         | Toggle parent fold widget        |
| Alt-L, Ctrl-F1                 | Command-Option-L, Command-F1   | Fold selection                  |
| Alt-Shift-L, Ctrl-Shift-F1     | Command-Option-Shift-L, Command-Shift-F1 | Unfold                |
| Alt-0                          | Command-Option-0               | Fold all                        |
| Alt-Shift-0                    | Command-Option-Shift-0         | Unfold all                       |
| ---                            | Ctrl-Command-Option-0          | Fold all comments                |

## Other

| Windows/Linux                  | Mac                            | Action                         |
|:-------------------------------|:-------------------------------|:-------------------------------|
| F1                             | F1                              | Open command palette            |
| Tab                            | Tab                             | Indent                          |
| Ctrl-]                         | Ctrl-]                          | Block indent                    |
| Shift-Tab                      | Shift-Tab                       | Outdent                         |
| Ctrl-[                         | Ctrl-[                           | Block outdent                   |
| Ctrl-Z                         | Command-Z                       | Undo                            |
| Ctrl-Shift-Z, Ctrl-Y           | Command-Shift-Z, Command-Y      | Redo                            |
| Ctrl-,                         | Command-,                       | Show the settings menu          |
| Ctrl-/                         | Command-/                       | Toggle comment                  |
| Ctrl-Shift-/                   | Command-Shift-/                 | Toggle block comment            |
| Ctrl-T                         | Ctrl-T                          | Transpose letters                |
| Ctrl-Enter                     | Command-Enter                   | Enter full screen                |
| Ctrl-Shift-U                   | Ctrl-Shift-U                     | Change to lower case             |
| Ctrl-U                         | Ctrl-U                          | Change to upper case             |
| Insert                         | Insert                          | Overwrite                        |
| Ctrl-Shift-E                   | Command-Shift-E                 | Macros replay                    |
| Ctrl-Alt-E                     | ---                             | Macros recording                 |
| Delete                         | ---                             | Delete                          |
| ---                            | Ctrl-L                          | Center selection                 |
| Ctrl-Alt-S                     | Command-Alt-S                   | Sort lines                       |
| Ctrl-Shift-Up                  | Alt-Shift-Up                    | Modify number up                 |
| Ctrl-Shift-Down                | Alt-Shift-Down                  | Modify number down               |
| Ctrl-Shift-B                   | Ctrl-Shift-B                    | Format selection (Beautify)      |

</details>
