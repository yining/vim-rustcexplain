let s:saved_cpo = &cpoptions
set cpoptions&vim


function! rustcexplain#OpenExplainPopup(...) abort
  if a:0 > 0
    " command line input can be 'E0123', '0123', or '123'
    let l:matches = matchlist(split(a:1)[0], '\v(\d{1,4})')
    let l:errcode = (len(l:matches) > 0) ? l:matches[0] : ''
  else
    let l:errcode = rustcexplain#GetErrCodeFromCursorLine()
    if empty(l:errcode)
      let l:errcode = rustcexplain#GetErrCodeFromLocList()
    endif
  endif

  if empty(l:errcode)
    echom 'RustcExplain: no error code found'
    return
  endif

  " to have uniform label in the popup window
  let l:errcode = printf('E%04s', l:errcode)

  let l:cmd = rustcexplain#BuildRustcExplainCmd(l:errcode)

  if has('nvim')
    call rustcexplain#popup#OpenNeovimFloatWindow(l:cmd, l:errcode)
  else
    call rustcexplain#popup#OpenPopupWindow(l:cmd, l:errcode)
  endif
endfunction


" NOTE: different linter/lsp clients put error code in different places
"
" vim-lsp:
"   { ... 'nr': 0, ... 'type': 'E', ...
"     'text': 'rustc:Error:E0433:failed to resolve: use of undeclared ...' }
" ALE:
"   { ... 'nr': -1, ... 'type': 'E', ...
"     'text': '[analyzer] failed to resolve: ...  not found in this scope [E0433]'}
" Neomake:
"   { ... 'nr': 433, ... 'type': 'E', ...
"     'text': 'failed to resolve: use of undeclared ... not found in this scope'}

function! rustcexplain#GetErrCodeFromCursorLine() abort
  let l:loclist_items = getloclist(0)
  if len(l:loclist_items) == 0 | return 0 | endif

  for l:item in l:loclist_items
    if l:item['lnum'] ==# line('.') && l:item['type'] ==# 'E'
      if l:item['nr'] > 0
        return l:item['nr']
      endif
      let l:errcode = rustcexplain#GetErrCodeFromString(l:item['text'])
      if !empty(l:errcode)
        return l:errcode
      endif
    endif
  endfor
  return 0
endfunction


function! rustcexplain#GetErrCodeFromLocList() abort
  let l:loclist_items = getloclist(0)
  if len(l:loclist_items) == 0 | return 0 | endif

  " get the index of selected item in the list
  let l:loclist_idx = getloclist(0, {'idx': 0})
  if len(l:loclist_idx) == 0 | return 0 | endif

  if l:loclist_idx['idx'] <= len(l:loclist_items)
    let l:item = l:loclist_items[ l:loclist_idx['idx']-1 ]
    if l:item['nr'] > 0
      return l:item['nr']
    endif
    let l:errcode = rustcexplain#GetErrCodeFromString(l:item['text'])
    if !empty(l:errcode)
      return l:errcode
    endif
  endif
  return 0
endfunction


function! rustcexplain#GetErrCodeFromString(s) abort
  let l:errcode_pattern = get(g:,
        \ 'rustcexplain_errcode_pattern', '\vE(\d{4})')
  let l:matches = matchlist(a:s, l:errcode_pattern)
  return len(l:matches) > 0 ? l:matches[1] : 0
endfunction


function! rustcexplain#BuildRustcExplainCmd(err_code) abort
  let l:rustc_bin = get(g:, 'rustcexplain_rustc_bin', 'rustc')
  let l:rustc_options = get(g:, 'rustcexplain_rustc_options', '')
  let l:cmd = printf('%s %s --explain %s',
        \ l:rustc_bin, l:rustc_options, a:err_code)
  return l:cmd
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
