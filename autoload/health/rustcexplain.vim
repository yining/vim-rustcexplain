let s:saved_cpo = &cpoptions
set cpoptions&vim


function! health#rustcexplain#check() abort
  call health#report_start('checking dependency - rustc')

  let l:rustc_bin = get(g:, 'rustcexplain_rustc_bin', 'rustc')
  call health#report_info('rustc is: ' . l:rustc_bin)
  " NOTE: rustc --version exit with 0, unlike many other with non-zero
  let l:cmd = l:rustc_bin . ' --version'
  let l:output = systemlist(l:cmd)
  call health#report_info(join(l:output, "\n"))

  let l:looks_good = v:shell_error ? 0 : 1

  if l:looks_good
    call health#report_ok('found required dependencies')
  else
    call health#report_error("cannot find '".l:rustc_bin . "'",
          \ ['check if rust is installed'])
  endif

endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
