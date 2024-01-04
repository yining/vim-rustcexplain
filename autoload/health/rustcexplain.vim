let s:saved_cpo = &cpoptions
set cpoptions&vim


function! health#rustcexplain#check() abort
  call v:lua.vim.health.start('checking dependency - rustc')

  let l:rustc_bin = get(g:, 'rustcexplain_rustc_bin', 'rustc')
  call v:lua.vim.health.info('rustc is: ' . l:rustc_bin)
  let l:cmd = l:rustc_bin . ' --version'
  let l:output = systemlist(l:cmd)
  call v:lua.vim.health.info(join(l:output, "\n"))

  if v:shell_error == 0
    call v:lua.vim.health.ok('found required dependencies')
  else
    call v:lua.vim.health.error("cannot find '".l:rustc_bin . "'",
          \ ['ensure rust is installed and rustc is available in $PATH or g:rustcexplain_rustc_bin is set'])
  endif
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
