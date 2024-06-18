let s:saved_cpo = &cpoptions
set cpoptions&vim


function! rustcexplain#popup#OpenPopupWindow(rustc_cmd, err_code) abort
  let l:message = systemlist(a:rustc_cmd)
  let l:message = s:mark_code_blocks_as_rust(l:message)

  let l:winid = popup_create(
        \ l:message,
        \ { 'title': '  Explain [' . a:err_code . ']  ',
        \  'close': 'button',
        \  'pos': 'center',
        \  'mapping': v:false,
        \  'filter': funcref('s:popup_filter'),
        \  'filtermode': 'n',
        \  'border': [1,1,1,1],
        \  'borderhighlight': [],
        \  'borderchars': g:rustcexplain_borderchars,
        \  'padding': [1,1,1,1],
        \  'maxheight': &lines - 10,
        \  'maxwidth': &columns - 10,
        \  'drag': 1,
        \  'scrollbar': 1,
        \  'resize': 1})
  call setbufvar(winbufnr(l:winid),  '&filetype',  'markdown')
endfunction


function! rustcexplain#popup#OpenNeovimFloatWindow(rustc_cmd, err_code) abort
  let l:message = systemlist(a:rustc_cmd)
  let l:message = ['# Explain [' . a:err_code .']', ''] + l:message
  let l:message = s:mark_code_blocks_as_rust(l:message)

  let l:uis = nvim_list_uis()
  if len(l:uis) > 0
    let l:ui = l:uis[0]
  else
    " HACK: this is to cheat neovim when testing with vader.
    "       Without this, vader test with neovim will get an empty list
    "       from `nvim_list_uis`. the numbers here are arbiturary, the
    "       purpose is to trick neovim into generating a window
    let l:ui = {'width': 320, 'height': 240}
  endif
  let l:max_line_length = max(map(copy(l:message), {k, v -> len(v)}))
  let l:width = min([l:max_line_length, l:ui.width - 4])
  let l:height = min([len(l:message), l:ui.height - 4])
  let l:buf = nvim_create_buf(v:false, v:true)
  let l:opts = {
        \ 'relative': 'editor',
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
  call nvim_set_option_value('conceallevel', 2, {'win': l:winid, 'scope': 'local'})
  call nvim_buf_set_var(l:buf, 'ale_enabled', 0)

  call setbufvar(winbufnr(l:winid),  '&filetype',  'markdown')
  call nvim_buf_set_lines(l:buf, 0, -1, v:true, l:message)

  let l:closingKeys = ['<Esc>', 'q']
  for l:key in l:closingKeys
    call nvim_buf_set_keymap(l:buf, 'n', l:key, ':close<CR>',
          \ {'silent': v:true, 'nowait': v:true, 'noremap': v:true})
  endfor
endfunction

" to mark code blocks in `rustc --explain` as `rust` as requested in
" https://github.com/yining/vim-rustcexplain/issues/2
function! s:mark_code_blocks_as_rust(lines) abort
  let l:lines = []
  " only change the opening '```' to '```rust'
  let l:opening_flag = v:true
  for l:line in a:lines
    if match(l:line, '^\s*```\s*$') >= 0
      let l:line = l:opening_flag ? '```rust' : l:line
      let l:opening_flag = !l:opening_flag
    endif
    let l:lines = l:lines + [l:line]
  endfor
  return l:lines
endfunction

" ref: https://github.com/prabirshrestha/vim-lsp/issues/975#issuecomment-751658462
function! s:popup_filter(winid, key) abort
  let l:navi_keys = get(g:, 'rustcexplain_keymaps', {
        \ 'q':      'QUIT',
        \ "\<c-k>": 'UP',
        \ "\<c-j>": 'DOWN',
        \ "\<c-u>": 'PAGEUP',
        \ "\<c-d>": 'PAGEDOWN',
        \ "\<c-t>": 'TOP',
        \ "\<c-g>": 'BOTTOM',
        \})
  let l:navi_key_map = {
        \ 'UP':       "\<c-y>",
        \ 'DOWN':     "\<c-e>",
        \ 'PAGEUP':   "\<c-u>",
        \ 'PAGEDOWN': "\<c-d>",
        \ 'TOP':      'gg',
        \ 'BOTTOM':   'G',
        \}
  if ! has_key(l:navi_keys, a:key)
    return 0
  endif
  let l:action = l:navi_keys[a:key]
  if l:action ==# 'QUIT'
    call popup_close(a:winid)
  else
    if ! has_key(l:navi_key_map, l:action)
      return 0
    endif
    let l:cmd = 'normal! '. l:navi_key_map[l:action]
    call win_execute(a:winid, l:cmd)
  endif
  return 1
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
