
function! rustcexplain#OpenExplainPopup(...) abort
  if a:0 > 0
    let l:errcode = a:1
  else
    let l:errcode = rustcexplain#GuessErrCode()
  endif
  if l:errcode ==# v:false
    echom 'RustcExplain: no error code found'
    return v:false
  endif
  let l:cmd = rustcexplain#BuildRustcExplainCmd(l:errcode)

  if has('nvim')
    call rustcexplain#OpenNvimFloatWindow(l:cmd, l:errcode)
  else
    call rustcexplain#OpenPopupWindow(l:cmd, l:errcode)
  endif
endfunction

function! rustcexplain#OpenNvimFloatWindow(rustc_cmd, err_code) abort
  let l:message = systemlist(a:rustc_cmd)
  let l:message = ['Explain [' . a:err_code .']', ''] + l:message
  let l:message = map(l:message, {k, v -> ' ' . v . ' '})

  let l:ui = nvim_list_uis()[0]
  let l:max_line_length = max(map(copy(l:message), {k, v -> len(v)}))
  let l:width = min([l:max_line_length, l:ui.width - 8])
  let l:height = min([len(l:message), l:ui.height - 8])
  let l:buf = nvim_create_buf(v:false, v:true)
  let l:opts = {'relative': 'editor',
        \ 'anchor': 'NW',
        \ 'width': l:width,
        \ 'height': l:height,
        \ 'col': floor((l:ui.width - l:width) / 2),
        \ 'row': floor((l:ui.height - l:height) / 2),
        \ 'focusable': v:true,
        \ 'style': 'minimal',
        \ 'border': 'single',
        \ 'noautocmd': v:true,
        \ }
  let l:winid = nvim_open_win(l:buf, 1, l:opts)
  call nvim_win_set_option(l:winid, 'winhl', 'Normal:Cursorline')
  call nvim_buf_set_var(l:buf, 'ale_enabled', 0)

  call setbufvar(winbufnr(l:winid),  '&filetype',  'markdown')
  call nvim_buf_set_lines(l:buf, 0, -1, v:true, l:message)

  let l:closingKeys = ['<Esc>', 'q']
  for l:key in l:closingKeys
    call nvim_buf_set_keymap(l:buf, 'n', l:key, ':close<CR>',
          \ {'silent': v:true, 'nowait': v:true, 'noremap': v:true})
  endfor
endfunction

function! rustcexplain#OpenPopupWindow(rustc_cmd, err_code) abort
  let l:winid = popup_create(
        \ systemlist(a:rustc_cmd),
        \ { 'title': '  Explain [' . a:err_code . ']  ',
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
  let l:rustc_bin = get(g:, 'rsutcexplain_rustc_bin', 'rustc')
  let l:rustc_options = get(g:, 'rustcexplain_rustc_options', '')
  let l:cmd = l:rustc_bin .
        \ ' ' . l:rustc_options .
        \ ' --explain ' . a:err_code
  return l:cmd
endfunction
