scriptencoding utf-8

if exists('g:loaded_rustcexplain')
  finish
endif
let g:loaded_rustcexplain = 1

let s:saved_cpo = &cpoptions
set cpoptions&vim

let g:rustcexplain_rustc_path = get(g:, 'rustcexplain_rustc_path', 'rustc')
let g:rustcexplain_rustc_options = get(g:, 'rustcexplain_rustc_options', '')

"
" Options
"
let g:rustcexplain_rustc_bin = get(g:, 'rustcexplain_rustc_bin', 'rustc')
let g:rustcexplain_rustc_options = get(g:, 'rustcexplain_rustc_options', '')

let g:rustcexplain_borderchars = get(g:, 'rustcexplain_borderchars', [])
      " \ ['-', '|', '-', '|', '┌', '┐', '┘', '└'])

"
" Define commands
"
command! -nargs=?  RustcExplain :call rustcexplain#OpenExplainPopup(<f-args>)

nnoremap <Plug>(rustcexplain_open) :call rustcexplain#OpenExplainPopup()<CR>


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
