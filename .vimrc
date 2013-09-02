"
" VIMRC by Marco Kretz <zantekk@gmail.com>
"
" ** rxvt-unicode-color256 with solarized colors
" 
" 2013-09-02
"
"
"-> ENVIRONMENT <-----------"
set nocompatible
set encoding=utf-8
setglobal fileencoding=utf-8

"-> TABBING <---------------"
set smartindent 
set tabstop=4 
set shiftwidth=4 
set expandtab

"-> VUNDLE <----------------" 
set rtp+=~/.vim/bundle/vundle/
filetype off
call vundle#rc()
Bundle 'gmarik/vundle'

"-> VUNDLE.BUNDLES <--------"
Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'itchyny/lightline.vim'
Bundle 'altercation/vim-colors-solarized'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'klen/python-mode'
Bundle 'hail2u/vim-css3-syntax'
Bundle 'amirh/HTML-AutoCloseTag'


"-> LIGHTLINE <-------------"
filetype plugin indent on
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'component': {
      \   'readonly': '%{&readonly?"x":""}',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }

"-> COLORSCHEME <-----------"
if !has('gui_running')
    set t_Co=256
endif
syntax enable
set background=dark
colorscheme solarized

"-> PYTHON MODE <-----------"
let g:pymode_folding = 0

