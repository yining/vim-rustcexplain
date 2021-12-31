# README

Rust compiler provides very helpful information, make it even easier to get the most of it.

While editing Rust source code in `Vim`, LSP client or linter emits diagnostic messages and populates them in location list.

```vim
augroup rustcexplain
  autocmd!
  autocmd Filetype qf
        \ nmap <silent> <buffer> <leader>E <CR><Plug>(rustcexplain_open)
  autocmd Filetype rust
        \ nmap <silent> <buffer> <leader>E <Plug>(rustcexplain_open)
augroup END
```

Note the preceeding `<CR>` in autocmd for `Filetype qf`. It is there because moving cursor up or down does not select the line, `<CR>` does.

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

- [popup window](https://vimhelp.org/popup.txt.html ) is used to show `rustc --explain` content, so `Vim` version >= 8.2 with `+popupwin` enabled is required to use this plugin.
- Development
    - themis and Vader for testing

## Known Limitation/Issues

- only tested with `vim-lsp` and `ALE`
- only works when there is an error code in the form of `E` followed by four digits like `E0106`, `E0432`;
- when there are more than one error on the same line, the first error that has the closest position to the curosr is picked, sometimes rustc reports multiple errors on the same position, so it also depends on the order the lsp client or linter populates the location list, thus not predicatable.

## Configuration

### `g:rustcexplain_rustc_bin`

```vim
let g:rustcexplain_rustc_bin = 'rustup run nightly rustc'
```

default is `rustc` assuming it is available from the `$PATH`

### `g:rustcexplain_rustc_options`

add extra options to the rustc command, not sure if at all useful.

```vim
let g:rustcexplain_rustc_options = '--edition 2015'
```

## Todo

- shortcut key for move in the popup windwo and close the popup window


