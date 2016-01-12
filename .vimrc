" .vimrc
" Motoki SEKI

" jjをEscにリマップ
inoremap <silent> jj <ESC>

" カラーシンタックス
syntax enable
" 行番号

set nu

" 行・列番号
set ruler

" タブを4桁に
set tabstop=4

" 閉じ括弧対応
set showmatch

" インクリメンタルサーチ
set incsearch

" 検索結果をハイライト
set hlsearch

" エンコーディングをutf8に
set encoding=utf8

" 右端で折り返す
set wrap

" 編集中のタイトルを表示
set title

" タブ、インデントを4桁に
set tabstop=4
set shiftwidth=4
set noexpandtab

" フォント設定
set guifont=Ricty_Discord:h14
set guifontwide=Ricty_Discord:h14
set linespace=4


"" NeoBundle
 " Note: Skip initialization for vim-tiny or vim-small.
 if 0 | endif

 if has('vim_starting')
   if &compatible
     set nocompatible               " Be iMproved
   endif

   " Required:
   set runtimepath+=~/.vim/bundle/neobundle.vim/
 endif

 " Required:
 call neobundle#begin(expand('~/.vim/bundle/'))

 " Let NeoBundle manage NeoBundle
 " Required:
 NeoBundleFetch 'Shougo/neobundle.vim'

 " My Bundles here:
 " Refer to |:NeoBundle-examples|.
 " Note: You don't set neobundle setting in .gvimrc!
 NeoBundle 'https://github.com/Shougo/neobundle.vim.git'
 NeoBundle 'https://github.com/tpope/vim-pathogen.git'
 NeoBundle 'https://github.com/Shougo/vimfiler.git'
 NeoBundle 'https://github.com/Shougo/unite.vim.git'
 NeoBundle 'https://github.com/Shougo/vimproc.git'
 NeoBundle 'https://github.com/Shougo/vimshell.git'
 NeoBundle 'plasticboy/vim-markdown'
 NeoBundle 'kannokanno/previm'
 NeoBundle 'tyru/open-browser.vim'
 NeoBundle 'vim-latex/vim-latex'

 call neobundle#end()

 " Required:
 filetype plugin indent on

 " If there are uninstalled bundles found on startup,
 " this will conveniently prompt you to install them.
 NeoBundleCheck


 
