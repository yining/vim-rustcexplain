# README

Rust compiler provides very helpful information, make it even easier to get the most of it.

While editing Rust source code in `Vim`, LSP client or linter emits diagnostic messages and populates them in location list.

- When focus in location list
    - `<leader>E` will jump to the line and show `rustc --explain` text of the cursorline
    - `<Enter>` will jump to the line (focus in the code window), see blow
- When focus is in source code window and cursor line has corresponding message in location list window
    - `<leader>E` will show explanation text of the cursorline
    - `:RustcExplain` will display explanation text of the cursorline
- When focus is in source code window and cursor line has no corresponding message in location list window
    - `<leader>E` will show text of the currently selected line in location list window
    - `:RustcExplain` will display text of the currently selected line in location list window

Just want to know the explanation of an error code? In command mode, enter `RustcExplain <Error Code>`.

## Depedency

- requires `Vim` version >= 8.2 for [popup window](https://vimhelp.org/popup.txt.html )
- Development
    - themis and Vader for testing

## Known Limitation/Issues

- only tested with `vim-lsp` and `ALE`
- only works when there is an error code in the form of `E` followed by four digits like `E0106`, `E0432`;
- when there are more than one error on the same line, the first error that has the closest position to the curosr is picked, sometimes rustc reports multiple errors on the same position, so it also depends on the order the lsp client or linter populates the location list, thus not predicatable.

## Configuration

- PATH to `rustc`
- `rustc` options e.g. `--edition`
- shortcut key (default `<leader>E`)
- shortcut key for move in the popup windwo and close the popup window

