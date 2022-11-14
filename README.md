[![CI](../../actions/workflows/ci.yml/badge.svg)](../../actions/workflows/ci.yml)

# README

## What

To view `rustc --explain` output in a popup window inside `Vim`.

## Why

`rustc` provides detailed and helpful information, it will be nice to be able to access it without leaving `Vim`, and even better with only a key mapping at an error/diagnostic message entry.

## How

In command mode, execute `:RustcExplain E0308`, or without `E` as `:RustcExplain 0433`, or even `:RustcExplain 433`, a popup/float window will appear with `rustc --explain` output in it.

It can be easier with a key mapping if linter/maker engine like [`ALE`](https://github.com/dense-analysis/ale), [`Neomake`](https://github.com/neomake/neomake), or `LSP` client like [`vim-lsp`](https://github.com/prabirshrestha/vim-lsp) is used. First, put the following snippet in the `Vim` config file to set the mapping, in this example `<leader>E`, to your liking.

```vim
augroup rustcexplain
  autocmd!
  autocmd Filetype qf
        \ nmap <silent> <buffer> <leader>E <CR><Plug>(rustcexplain_open)
  autocmd Filetype rust
        \ nmap <silent> <buffer> <leader>E <Plug>(rustcexplain_open)
augroup END
```

After diagnostic messages are populated in the location list, move to the line with error, and `<leader>E` will bring up the popup window.

**Note:** the preceeding `<CR>` in the above `autocmd` for `Filetype qf` is to select the entry in the location list because moving cursor up or down does **not** select the line, `<CR>` does that.

## How in more detail

Under the hood, what this plugin does is run the `rustc --explain` command and pipe the output from `stdout`/`stderr` and put it in a popup/float window.

Some more details:

- When focus is on an error entry in location list
    - `<leader>E` will jump to the line and show `rustc` explain output of the error at the line.
    - `:RustcExplain` will show `rustc` explain output of that error, focus stays at the location entry.
- When focus is in source code window and cursor line has corresponding error message in location list
    - `<leader>E` and `:RustcExplain` will show `rustc` explain output of that error.
- When focus is in source code window and cursor line has no corresponding error message in location list window
    - `<leader>E` and `:RustcExplain` will show `rustc` explain output of error at the currently selected entry in location list.

## Install

This is a regular `Vim` plugin, install with your choice of plugin manager as you normally do with any plugin.

## Depedency

- `Vim`: [popup window](https://vimhelp.org/popup.txt.html) is used, so `Vim` of version `>= 8.2` with `+popupwin` enabled is required.
- `Neovim`: version `>= 0.6.0` should work.
- Development dependencies:
    - [vader.vim](https://github.com/junegunn/vader.vim) and [vim-themis](https://github.com/thinca/vim-themis/blob/master/doc/themis.txt ) for unit test;
    - [poetry](https://python-poetry.org/ ) for managing tools built with `Python`


## Known Limitation/Issues

- only tested with `ALE`, `Neomake`, and `vim-lsp`;
- only works on diagnostic message reported to `Vim` as `error`, other levels are ignored;

## Configuration

### `g:rustcexplain_rustc_bin`

the `rustc` binary used to generate `--explain` output, for example:

```vim
let g:rustcexplain_rustc_bin = 'rustup run nightly rustc'
```

default is `'rustc'`, assuming it is available from the `$PATH`

### `g:rustcexplain_rustc_options`

add extra options to the rustc command, for example:

```vim
let g:rustcexplain_rustc_options = '--edition 2015'
```

default is `''`

### `g:rustcexplain_keymaps`

customize the key mapping to your finger muscle habits for navigating in the popup window.

default is:

```vim
let g:rustcexplain_keymaps = {
        \ 'q':      'QUIT',
        \ "\<c-y>": 'UP',
        \ "\<c-e">: 'DOWN',
        \ "\<c-u>": 'PAGEUP',
        \ "\<c-d>": 'PAGEDOWN',
        \ "\<c-t>": 'TOP',
        \ "\<c-g>": 'BOTTOM',
        \}
```

[Vim's popup-filter](https://vimhelp.org/popup.txt.html#popup-filter) has detailed info (for example the issue on using `ESC`) on setting keys on popup window.

**Note:** This setting is for `Vim` only. I have not been able to find information on such customization for `Neovim`'s float window.

## Acknowledgement

- [rustc](https://doc.rust-lang.org/rustc/) for friendly and useful compiler messages
- [vader.vim](https://github.com/junegunn/vader.vim) and [vim-themis](https://github.com/thinca/vim-themis/blob/master/doc/themis.txt ) for ease of writing tests for `Vim` plugins.
- [rhysd/action-setup-vim](https://github.com/rhysd/action-setup-vim) for GitHub Action to setup `Vim`/`Neovim`.
