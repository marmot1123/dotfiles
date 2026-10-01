" Apple 標準の Vim で使う最小構成。外部プラグインには依存しない。
set nocompatible
set encoding=utf-8
filetype plugin indent on
syntax enable

" 表示と検索
set number
set ruler
set wrap
set title
set showmatch
set incsearch
set hlsearch
set ambiwidth=double
colorscheme elflord

" 既定はスペース4個。ファイルタイプ別のインデント設定を優先する。
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" 標準の補完とキー操作
set wildmode=list:longest
set backspace=indent,eol,start
inoremap <silent> jk <ESC>
