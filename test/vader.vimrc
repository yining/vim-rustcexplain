" this vimrc is used for testing with Vader

set nobackup
set noswapfile

"
" Get an isolated Vim environment, with only Vader and the plugin to test.

set packpath=
" set runtimepath=
set runtimepath+=~/.vim/bundle/vader.vim
let &runtimepath .= ','.expand('<sfile>:p:h:h')

filetype on
filetype plugin on
filetype indent on
syntax enable

