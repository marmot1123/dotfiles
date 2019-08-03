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


"""" Dein """"
if &compatible
  set nocompatible
endif
" Add the dein installation directory into runtimepath
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
  call dein#begin('~/.cache/dein')

  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
  call dein#add('Shougo/deoplete.nvim')
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif

  "" begin package
  call dein#add('vim-latex/vim-latex')
  "" end package

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable
