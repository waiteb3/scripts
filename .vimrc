call plug#begin('~/.vim/plugged')

Plug 'vim-scripts/CycleColor'
Plug 'flazz/vim-colorschemes'

Plug 'editorconfig/editorconfig-vim'
Plug 'airblade/vim-gitgutter'

" Plug 'scrooloose/syntastic'
" Plug 'fatih/vim-go'
" Plug 'Valloric/YouCompleteMe'

call plug#end()

set t_Co=256
set backspace=2
colorscheme flatlandia
nmap <space> :
set tabstop=4 expandtab
set shiftwidth=4
