# Created by newuser for 5.0.8

# パス
#export PATH=/usr/local/sbin:$PATH
#export PATH=$NODEBREW_ROOT/current/bin:$PATH
#export PATH=$HOME/.nodebrew/current/bin:$PATH
#export PATH=$HOME/anaconda/bin:$PATH
export PATH=/usr/local/opt/openssl/bin:$PATH

export XDG_CONFIG_HOME=$HOME/dotfiles

# 補完
autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 色
autoload -Uz colors
colors
export LSCOLORS=exfxcxdxbxegedabagacad
zstyle ':completion:*' list-colors ''

# 言語設定
export LANG=ja_JP.UTF-8

# プロンプト （いろいろ試してみる）
PROMPT="%{${fg[cyan]}%}%~ %{${reset_color}%}
%{${fg[yellow]}%}mbp2015$ %{${reset_color}%}"

# 履歴
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups
setopt share_history

# Emacs風キーバインド
bindkey -e

# 履歴検索キーバインド
#autoload history-search-end
#zle -N history-beginning-search-backward-end history-search-end
#zle -N history-beginning-search-forward-end history-end
#bindkey "^P" history-beginning-search-backward-end
#bindkey "^N" history-beginning-search-forward-end

# cd周り
setopt auto_cd
setopt auto_pushd

# 修正
setopt correct

# 詰めて表示
setopt list_packed

# ビープ音を鳴らさない
setopt nolistbeep

# エイリアス
alias ols='ls'
alias ls='gls -F --color'
alias ll='gls -laFh --color'
alias git=hub

# nodebrew
export NODEBFREW_ROOT=/usr/local/var/nodebrew

fpath=(/usr/local/share/zsh-completions $fpath)
