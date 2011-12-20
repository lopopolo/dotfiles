" pathogen stuff
filetype off
source ~/.vim/bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

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
set statusline=%<%F%h%m%r%h%w%y\ %{fugitive#statusline()}\ %{&ff}\ lin:%l\,%L\ col:%c%V\ pos:%o\ %P

autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929

set wrap
set textwidth=79
set formatoptions=qrn1
highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

" highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+\%#\@<!$/

" strip trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

set cursorline

nnoremap ; :

" save on lose focus
au FocusLost * :wa

if &t_Co >= 256 || has("gui_running")
  set background=dark
  colorscheme solarized
endif

" Quickly display a markdown preview of the current buffer
:map <leader>m :%w ! bundle exec markdown_doctor \| bundle exec bcat<CR><CR>

" disable middle click pasting (I accidentall do this all the time)
nnoremap <MiddleMouse> <Nop>
nnoremap <2-MiddleMouse> <Nop>
nnoremap <3-MiddleMouse> <Nop>
nnoremap <4-MiddleMouse> <Nop>

inoremap <MiddleMouse> <Nop>
inoremap <2-MiddleMouse> <Nop>
inoremap <3-MiddleMouse> <Nop>
inoremap <4-MiddleMouse> <Nop>
