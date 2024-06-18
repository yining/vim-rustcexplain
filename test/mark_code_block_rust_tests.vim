scriptencoding utf8

let s:suite = themis#suite('tests code blocks are properly marked as rust')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')

function! s:suite.before_each()
  let s:funcs = s:scope.funcs('autoload/rustcexplain/popup.vim')
endfunction

function! s:suite.after_each()
endfunction

function! s:suite.test_empty()
  let l:input = []
  let l:expected = []
  let l:result = s:funcs.mark_code_blocks_as_rust(l:input)
  call s:assert.equals(l:expected, l:result)
endfunction

function! s:suite.test_one_block()
  let l:input = [
        \ '```',
        \ 'code',
        \ '```',
        \]
  let l:expected = [
        \ '```rust',
        \ 'code',
        \ '```',
        \]
  let l:result = s:funcs.mark_code_blocks_as_rust(l:input)
  call s:assert.equals(l:expected, l:result)
endfunction

function! s:suite.test_one_and_half_block()
  let l:input = [
        \ '```',
        \ 'code',
        \ '```',
        \ '```',
        \ 'code',
        \]
  let l:expected = [
        \ '```rust',
        \ 'code',
        \ '```',
        \ '```rust',
        \ 'code',
        \]
  let l:result = s:funcs.mark_code_blocks_as_rust(l:input)
  call s:assert.equals(l:expected, l:result)
endfunction

function! s:suite.test_simple()
  let l:input = [
        \ '```',
        \ '```',
        \ '```',
        \ '```',
        \ '```',
        \ '```',
        \]
  let l:expected = [
        \ '```rust',
        \ '```',
        \ '```rust',
        \ '```',
        \ '```rust',
        \ '```',
        \]
  let l:result = s:funcs.mark_code_blocks_as_rust(l:input)
  call s:assert.equals(l:expected, l:result)
endfunction
