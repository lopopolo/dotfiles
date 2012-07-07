" ================================== Pathogen =================================
filetype off
source ~/.vim/bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

" =============================== Basic settings ==============================

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

" Allow for modelines
set modeline

let mapleader = ","

" searching
set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch
set gdefault
nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

" status lines
set laststatus=2
set statusline=%<%F%h%m%r%h%w%y\ %{fugitive#statusline()}\ %{&ff}\ lin:%l\,%L\ col:%c%V\ pos:%o\ %P
set cursorline

" text wrapping
set wrap
set textwidth=110
let &wrapmargin= &textwidth
set formatoptions=tcroql

set autochdir

" ============================== Command mappings =============================

" save a buffer I don't have the perms for
cmap w!! :w !sudo tee %<CR>

" set shiftwidth to 4
map <leader>s4 :set shiftwidth=4<CR>

" cd to the directory containing the file in the buffer
nmap <silent> <leader>cd :lcd %:h<CR>

" ================================ Color scheme ===============================

" solarized
if &t_Co >= 256 || has("gui_running")
  set background=dark
  colorscheme solarized
endif

" highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+\%#\@<!$/
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red

" =============================== Auto commands ===============================

" strip trailing whitespace on save
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" save on lose focus, but don't complain if you can't
au FocusLost * silent! wa

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
au!

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif

" Automatically load .vimrc source when saved
autocmd BufWritePost .vimrc source $MYVIMRC

augroup END

" ==================== Typo prevention and other vim remaps ===================

nnoremap ; :

" let me type :W to save, cuz that always happens
cnoreabbrev W w

" ============================== Split shortcuts ==============================

" window
nmap <leader>sw<left>  :topleft  vnew<CR>
nmap <leader>sw<right> :botright vnew<CR>
nmap <leader>sw<up>    :topleft  new<CR>
nmap <leader>sw<down>  :botright new<CR>
" buffer
nmap <leader>s<left>   :leftabove  vnew<CR>
nmap <leader>s<right>  :rightbelow vnew<CR>
nmap <leader>s<up>     :leftabove  new<CR>
nmap <leader>s<down>   :rightbelow new<CR>

" navigating
nmap <leader><left>    <C-W>h
nmap <leader><right>   <C-W>l
nmap <leader><down>    <C-W>j
nmap <leader><up>      <C-W>k

" =============================== Plugin stuff  ===============================

" Quickly display a markdown preview of the current buffer
map <leader>m :%w ! markdown.rb > temp.html && open temp.html<CR><CR>

" nerdtree shortcut
map <leader>n :NERDTree
map <leader>nt :NERDTreeToggle<CR>
" nerdtree settings
let g:NERDTreeChDirMode=1

" supertab
let g:SuperTabDefaultCompletionType = "context"

" ack
map <leader>a :Ack

" syntastic
set statusline+=%=%{SyntasticStatuslineFlag()}

" load the macruby syntax checker for syntastic if the shebang
" has macruby in it
autocmd BufRead *
  \ if getline(1) =~ 'macruby' |
  \   let g:syntastic_ruby_checker = "macruby" |
  \ endif

