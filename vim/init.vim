set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

if has('gui_vimr')
  nnoremap <D-Left>       :tabp<CR>
  vnoremap <D-Left>       :tabp<CR>
  inoremap <D-Left>  <C-O>:tabp<CR>
  nnoremap <D-Right>      :tabn<CR>
  vnoremap <D-Right>      :tabn<CR>
  inoremap <D-Right> <C-O>:tabn<CR>
endif
