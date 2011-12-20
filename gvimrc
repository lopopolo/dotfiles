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

