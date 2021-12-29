scriptencoding utf8

function! rustcexplain#OpenExplainPopup(...) abort
  if a:0 > 0
    let l:err_code = a:1
  else
    let l:err_code = rustcexplain#GuessErrCode()
  endif
  if l:err_code ==# v:false
    echom 'RustcExplain: no error code found'
    return v:false
  endif
  let l:rustc_cmd = rustcexplain#BuildRustcExplainCmd(l:err_code)

  let l:winid = popup_create(
        \ systemlist(l:rustc_cmd),
        \ { 'title': '  Explain [' . l:err_code . ']  ',
        \  'close': 'button',
        \  'pos': 'center',
        \  'mapping': v:false,
        \  'filter': funcref('s:popup_filter'),
        \  'filtermode': 'n',
        \  'border': [1,1,1,1],
        \  'padding': [1,1,1,1],
        \  'maxheight': &lines - 10,
        \  'maxwidth': &columns - 10,
        \  'drag': 1,
        \  'scrollbar': 1,
        \  'resize': 1})

  call setbufvar(winbufnr(l:winid),  '&filetype',  'markdown')
endfunction

" TODO: allow setting shortcut key in options
" ref: https://github.com/prabirshrestha/vim-lsp/issues/975#issuecomment-751658462
function! s:popup_filter(winid, key) abort
  if a:key ==# "\<c-j>"
    call win_execute(a:winid, "normal! \<c-e>")
  elseif a:key ==# "\<c-k>"
    call win_execute(a:winid, "normal! \<c-y>")
  elseif a:key ==# "\<c-u>"
    call win_execute(a:winid, "normal! \<c-u>")
  elseif a:key ==# "\<c-d>"
    call win_execute(a:winid, "normal! \<c-d>")
  elseif a:key ==# "\<c-g>"
    call win_execute(a:winid, 'normal! G')
  elseif a:key ==# "\<c-t>"
    call win_execute(a:winid, 'normal! gg')
  elseif a:key ==# 'q'
    call popup_close(a:winid)
  else
    return v:false
  endif
  return v:true
endfunction

function! rustcexplain#GetErrCodeFromString(s) abort
  let l:regex = '\v(E\d{4})'
  let l:matches = matchlist(a:s, l:regex)
  if len(l:matches) > 0
    return l:matches[0]
  endif
  return v:false
endfunction

function! rustcexplain#GuessErrCode() abort
  let l:errcode = rustcexplain#GetErrCodeFromCursorLine()
  " echom 'error code is '. l:errcode
  if l:errcode != v:false
    return l:errcode
  endif
  let l:errcode = rustcexplain#GetErrCodeFromLocList()
  if l:errcode != v:false
    return l:errcode
  endif
  return v:false
endfunction

" TODO: handle multiple error codes in one line
function! rustcexplain#GetErrCodeFromCursorLine() abort
  let l:loclist_items = getloclist(0)
  if len(l:loclist_items) ==# 0
    return v:false
  endif
  for l:item in l:loclist_items
    if l:item['lnum'] ==# line('.')
      return rustcexplain#GetErrCodeFromString(l:item['text'])
    endif
  endfor
  return v:false
endfunction

function! rustcexplain#GetErrCodeFromLocList() abort
  let l:loclist_idx = getloclist(0, {'idx': 0})
  if len(l:loclist_idx) ==# 0
    return v:false
  endif
  let l:loclist_items = getloclist(0)
  if len(l:loclist_items) ==# 0
    return v:false
  endif
  if l:loclist_idx['idx'] <= len(l:loclist_items)
    let l:item = l:loclist_items[ l:loclist_idx['idx']-1]
    return rustcexplain#GetErrCodeFromString(l:item['text'])
  endif
  return v:false
endfunction

function! rustcexplain#BuildRustcExplainCmd(err_code) abort
  let l:rustc_path = 'rustc'
  let l:rustc_cmd = l:rustc_path . ' --explain ' . a:err_code
  return l:rustc_cmd
endfunction
