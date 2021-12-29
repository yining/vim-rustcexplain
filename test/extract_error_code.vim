let s:suite = themis#suite('extract error code')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
endfunction

function! s:suite.after_each()
endfunction

function! s:suite.lsp_analyzer_output_1()
  let l:input = 'rustc:Error:E0432:unresolved import `super::List` no `List` in `first`'
  let l:got = rustcexplain#GetErrCodeFromString(l:input)
  let l:expected = 'E0432'
  call s:assert.equals(l:got, l:expected)
endfunction

function! s:suite.lsp_analyzer_output_2()
  let l:input = 'rustc:Hint:E0072:insert some indirection (e.g., a `Box`, `Rc`, or `&`) to make `Node` representable: `Box<`, `>`'
  let l:got = rustcexplain#GetErrCodeFromString(l:input)
  let l:expected = 'E0072'
  call s:assert.equals(l:got, l:expected)
endfunction

function! s:suite.ale_output()
  let l:input = "[analyzer] consider borrowing the `Result`'s content: `.as_ref()` [E0507]"
  let l:got = rustcexplain#GetErrCodeFromString(l:input)
  let l:expected = 'E0507'
  call s:assert.equals(l:got, l:expected)
endfunction
