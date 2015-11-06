# ry

_A basic modal text editor, written in Chicken Scheme_

### installing

To build and install `ry` on your computer simply run `chicken-install` from the
project's root directory.

### features

`ry` is a text editor aiming to provide an editing environment similar to `vim`
in terms of key bindings while being as easily extended as `emacs`.

It is easy to extend in scheme, and, as emacs, the core being written in the same
language, you can change virtually everything in your plugins.

**Currently implemented keybindings:**

- Normal Mode
  - [q] Quits editor (`save-buffers-kill-ry`)
  - [i] Enters insert-mode (`enter-insert-mode`)
  - [h] Moves cursor left (`backward-char`)
  - [j] Moves cursor down (`next-line`)
  - [k] Moves cursor up (`previous-line`)
  - [l] Moves cursor right (`forward-char`)
  - [d][d] Deletes current line (`kill-whole-line`)
  - [d][h] or [d][j] Deletes char left of cursor  (`delete-backward-char`)
  - [d][k] or [d][l] Deletes char right of cursor  (`delete-forward-char`)
  - [:] Asks for a command in the minibuffer and eval's it (`smex`)
  - [x] Deletes char under cursor (`delete-char`)
- Insert mode
  - [any visible chars] Inserts charater at cursor's position (`self-insert-char`)
  - [backspace] Deletes character to the left
  - [esc] Enters normal mode  (`enter-normal-mode`)

### license

MIT
