if exists('g:loaded_rustcexplain')
  finish
endif
let g:loaded_rustcexplain = 1

"
" Define commands
"
command! -nargs=*  RustcExplain :call rustcexplain#OpenExplainPopup(<f-args>)

augroup rustcexplain
  autocmd!

  autocmd Filetype qf nnoremap <silent> <buffer>
        \ <leader>E <CR>:call rustcexplain#OpenExplainPopup()<CR>

  autocmd Filetype rust nnoremap <silent> <buffer>
        \ <leader>E     :call rustcexplain#OpenExplainPopup()<CR>

augroup END

