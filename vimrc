" pathogen stuff
filetype off
source ~/.vim/bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

syntax on
filetype plugin indent on

set nocompatible
set noswapfile

set expandtab
set smarttab
set tabstop=2
set shiftwidth=2
set autoindent
set smartindent
set number
set ruler
set backspace=indent,eol,start

let mapleader = ","

set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch
set gdefault
nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

set laststatus=2 
set statusline=%<%F%h%m%r%h%w%y\ %{&ff}\ lin:%l\,%L\ col:%c%V\ pos:%o\ %P

set wrap
set textwidth=79
set formatoptions=qrn1
highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

nnoremap ; :

" save on lose focus
au FocusLost * :wa

if &t_Co >= 256 || has("gui_running")
  colorscheme mustang
endif

" rainbow parentheses setup
call rainbow_parenthsis#LoadRound()
call rainbow_parenthsis#LoadSquare()
call rainbow_parenthsis#LoadBraces()
call rainbow_parenthsis#Activate()

