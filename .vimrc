" .vimrc
" Motoki SEKI

" jjをEscにリマップ
inoremap <silent> jj <ESC>

" カラーシンタックス
"syntax on
"source $VIMRUNTIME/syntax/syntax.vim
colorscheme elflord

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
set guifont=Ricty_Discord:h15
set guifontwide=Ricty_Discord:h15
set linespace=4

" マルチバイト文字
set ambiwidth=double

" TeXの設定
" 折りたたみを無効にする
:let g:Tex_Auto_Folding=0
:let b:Imap_FreezeImap=1

" HTMLなどの対応する括弧移動の拡張
" %で対応する括弧へ移動
:source $VIMRUNTIME/macros/matchit.vim

" dein settings {{{
" via http://qiita.com/okamos/items/2259d5c770d51b88d75b
if &compatible
  set nocompatible
endif
" dein.vimのディレクトリ
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" なければgit clone
if !isdirectory(s:dein_repo_dir)
  execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
endif
execute 'set runtimepath^=' . s:dein_repo_dir

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " 管理するプラグインを記述したファイル
  let s:toml = '~/.dein.toml'
  let s:lazy_toml = '~/.dein_lazy.toml'
  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif
 
" vimprocだけ最初にインストール
if dein#check_install(['vimproc'])
  call dein#install(['vimproc'])
endif
" その他インストールしていないものをインストール
if dein#check_install()
  call dein#install()
endif
" }}}
