" plugins for vim dev
silent! packadd vim-textobj-user
silent! packadd vim-textobj-function
silent! packadd vim-textobj-function-vim-extra
silent! packadd vader.vim
silent! packadd vim-vimhelplint
silent! packadd yadk

" make this development version of plugin higher in &rtp and higher priority
" than the public version I might have installed under ~/.vim
let s:repo_root = expand('<sfile>:p:h')
let &runtimepath =  s:repo_root . ',' . &runtimepath
unlet s:repo_root
