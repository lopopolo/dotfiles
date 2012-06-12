" Start NERDTree automatically.
" autocmd VimEnter * NERDTree

let s:uname = system("echo -n \"$(uname)\"")
if s:uname == "Darwin"
  set guifont=Inconsolata:h16
else
  set guifont="Inconsolata 16"
endif

" Get rid of the macvim and gvim toolbars
set go-=T
set go-=m

" disable middle click pasting (I accidentally do this all the time)
nnoremap <MiddleMouse>   <Nop>
nnoremap <2-MiddleMouse> <Nop>
nnoremap <3-MiddleMouse> <Nop>
nnoremap <4-MiddleMouse> <Nop>

inoremap <MiddleMouse>   <Nop>
inoremap <2-MiddleMouse> <Nop>
inoremap <3-MiddleMouse> <Nop>
inoremap <4-MiddleMouse> <Nop>

" tab switching like in iTerm for MacVim
if s:uname == "Darwin"
  macm Window.Select\ Previous\ Tab  key=<D-Left>
  macm Window.Select\ Next\ Tab	     key=<D-Right>
endif

