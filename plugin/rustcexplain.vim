if exists('g:loaded_rustcexplain')
  finish
endif
let g:loaded_rustcexplain = 1

let g:rustcexplain_rustc_path = get(g:, 'rustcexplain_rustc_path', 'rustc')
let g:rustcexplain_rustc_options = get(g:, 'rustcexplain_rustc_options', '')

"
" Options
"
let g:rustcexplain_rustc_bin = get(g:, 'rustcexplain_rustc_bin', 'rustc')
let g:rustcexplain_rustc_options = get(g:, 'rustcexplain_rustc_options', '')

"
" Define commands
"
command! -nargs=*  RustcExplain :call rustcexplain#OpenExplainPopup(<f-args>)

nnoremap <Plug>(rustcexplain_open) :call rustcexplain#OpenExplainPopup()<CR>

