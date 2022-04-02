let s:saved_cpo = &cpoptions
set cpoptions&vim


function! rustcexplain#OpenExplainPopup(...) abort
  if a:0 > 0
    let l:matches = matchlist(split(a:1)[0], '\v(\d{1,4})')
    let l:errcode = (len(l:matches) > 0) ? l:matches[0] : 0
  else
    let l:errcode = rustcexplain#GuessErrCode()
  endif
  if l:errcode == 0
    echom 'RustcExplain: no error code found'
    return
  endif

  let l:errcode = printf('E%04s', l:errcode)

  let l:cmd = rustcexplain#BuildRustcExplainCmd(l:errcode)

  if has('nvim')
    call rustcexplain#popup#OpenNeovimFloatWindow(l:cmd, l:errcode)
  else
    call rustcexplain#popup#OpenPopupWindow(l:cmd, l:errcode)
  endif
endfunction


function! rustcexplain#GetErrCodeFromString(s) abort
  let l:matches = matchlist(a:s, '\vE(\d{4})')
  return len(l:matches) > 0 ? l:matches[0] : 0
endfunction

function! rustcexplain#GuessErrCode() abort
  let l:errcode = rustcexplain#GetErrCodeFromCursorLine()
  if l:errcode > 0
    return l:errcode
  endif
  let l:errcode = rustcexplain#GetErrCodeFromLocList()
  if l:errcode > 0
    return l:errcode
  endif
  return 0
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
  if len(l:loclist_items) == 0
    return 0
  endif
  for l:item in l:loclist_items
    if l:item['lnum'] ==# line('.') && l:item['type'] ==# 'E'
      if l:item['nr'] > 0
        return l:item['nr']
      endif
      let l:errcode = rustcexplain#GetErrCodeFromString(l:item['text'])
      if l:errcode > 0
        return l:errcode
      endif
    endif
  endfor
  return 0
endfunction


function! rustcexplain#GetErrCodeFromLocList() abort
  let l:loclist_idx = getloclist(0, {'idx': 0})
  if len(l:loclist_idx) == 0
    return 0
  endif
  let l:loclist_items = getloclist(0)
  if len(l:loclist_items) == 0
    return 0
  endif
  if l:loclist_idx['idx'] <= len(l:loclist_items)
    let l:item = l:loclist_items[ l:loclist_idx['idx']-1]
    if l:item['nr'] > 0
      return l:item['nr']
    endif
    let l:errcode = rustcexplain#GetErrCodeFromString(l:item['text'])
    if l:errcode != 0
      return l:errcode
    endif
  endif
  return 0
endfunction


function! rustcexplain#BuildRustcExplainCmd(err_code) abort
  let l:rustc_bin = get(g:, 'rsutcexplain_rustc_bin', 'rustc')
  let l:rustc_options = get(g:, 'rustcexplain_rustc_options', '')
  let l:cmd = printf('%s %s --explain %s',
        \ l:rustc_bin, l:rustc_options, a:err_code)
  return l:cmd
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
