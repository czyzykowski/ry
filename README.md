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
  - <kbd>q</kbd> Quits editor (`save-buffers-kill-ry`)
  - <kbd>i</kbd> Enters insert-mode (`enter-insert-mode`)
  - <kbd>h</kbd> Moves cursor left (`backward-char`)
  - <kbd>j</kbd> Moves cursor down (`next-line`)
  - <kbd>k</kbd> Moves cursor up (`previous-line`)
  - <kbd>l</kbd> Moves cursor right (`forward-char`)
  - <kbd>d</kbd><kbd>d</kbd> Deletes current line (`kill-whole-line`)
  - <kbd>d</kbd><kbd>h</kbd> or <kbd>d</kbd><kbd>j</kbd> Deletes char left of cursor  (`delete-backward-char`)
  - <kbd>d</kbd><kbd>k</kbd> or <kbd>d</kbd><kbd>l</kbd> Deletes char right of cursor  (`delete-forward-char`)
  - <kbd>:</kbd> Asks for a command in the minibuffer and eval's it (`smex`)
  - <kbd>x</kbd> Deletes char under cursor (`delete-char`)
- Insert mode
  - <kbd>any visible chars</kbd> Inserts charater at cursor's position (`self-insert-char`)
  - <kbd>backspace</kbd> Deletes character to the left
  - <kbd>esc</kbd> Enters normal mode  (`enter-normal-mode`)

### license

MIT
