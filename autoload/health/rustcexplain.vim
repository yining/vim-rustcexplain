let s:saved_cpo = &cpoptions
set cpoptions&vim


function! health#rustcexplain#check() abort
  call health#report_start('checking dependency - rustc')

  let l:rustc_bin = get(g:, 'rustcexplain_rustc_bin', 'rustc')
  call health#report_info('rustc is: ' . l:rustc_bin)
  let l:cmd = l:rustc_bin . ' --version'
  let l:output = systemlist(l:cmd)
  call health#report_info(join(l:output, "\n"))

  if v:shell_error == 0
    call health#report_ok('found required dependencies')
  else
    call health#report_error("cannot find '".l:rustc_bin . "'",
          \ ['ensure rust is installed and rustc is available in $PATH or g:rustcexplain_rustc_bin is set'])
  endif
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
