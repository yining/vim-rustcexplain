" this vimrc file is for testing with github workflow

filetype off

let s:repo_root = fnamemodify(expand('<sfile>'), ':h:h')

" manually add this plugin to the runtimepath
execute 'set runtimepath+=' . s:repo_root
execute 'set runtimepath+=' . s:repo_root . '/after'

" manually add dependency to the runtimepath
let &runtimepath .= ',' . expand('<sfile>:p:h:h') . '/vader.vim'

filetype on
filetype plugin on
filetype indent on
syntax enable
