" .vimrc
" Motoki SEKI

"""" Core """"
set encoding=utf8


"""" Editor """"
set nu
set ruler
set wrap
set title
set showmatch

set incsearch
set hlsearch

set tabstop=4
set shiftwidth=4
set noexpandtab
set ambiwidth=double

set wildmode=list:longest
set backspace=indent,eol,start


"""" Coloring """"
syntax on
colorscheme elflord


"""" Key Bindings """"
inoremap <silent> jj <ESC>


filetype plugin indent on
filetype plugin on
syntax enable
