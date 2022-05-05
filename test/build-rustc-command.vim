let s:saved_cpo = &cpoptions
set cpoptions&vim

let s:suite = themis#suite('test building rustc command')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
endfunction

function! s:suite.after_each()
endfunction

function! s:suite.test_build_rustc_cmd_default()
  let l:got = rustcexplain#BuildRustcExplainCmd('E0703')
  let l:got = split(l:got)
  let l:expected = ['rustc', '--explain', 'E0703']
  call s:assert.equals(l:got, l:expected)
endfunction

function! s:suite.test_build_rustc_cmd_custom()
  let g:rustcexplain_rustc_bin = 'rustup run nightly rustc'
  let g:rustcexplain_rustc_options = '--edition 2018'
  let l:got = rustcexplain#BuildRustcExplainCmd('E0703')
  let l:got = split(l:got)
  let l:expected = ['rustup', 'run', 'nightly', 'rustc', '--edition', '2018', '--explain', 'E0703']
  call s:assert.equals(l:got, l:expected)
endfunction

let &cpoptions = s:saved_cpo
unlet s:saved_cpo
