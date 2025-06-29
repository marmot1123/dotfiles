# パス
export PATH=~/.npm-global/bin:$PATH
export PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/local/texlive/2024/bin/universal-darwin
export PATH=$PATH:/usr/local/texlive/2024/bin/x86_64-linux
export PATH=$PATH:$HOME/.opam/default/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:/opt/homebrew/opt/postgresql@17/bin:$PATH
export MANPATH=$MANPATH:/usr/local/texlive/2024/texmf-dist/doc/man
export INFOPATH=$INFOPATH:/usr/local/texlive/2024/texmf-dist/doc/info

export XDG_CONFIG_HOME=$HOME/.config

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
%{${fg[yellow]}%}%n@%m$ %{${reset_color}%}"

# 履歴
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups
setopt share_history

# Emacs風キーバインド
bindkey -e

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
alias ls='ls -F --color'
alias ll='ls -laFh --color'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export LANG="en_US.UTF-8"

# ssh-add
eval "$(ssh-agent)"
if command -v ssh-add >/dev/null 2>&1; then
  if [[ -n "$SSH_AUTH_SOCK" ]] && [[ $(ssh-add -l 2>/dev/null | wc -l) -eq 0 ]]; then
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null
  fi
fi


. "$HOME/.cargo/env"

# pnpm
export PNPM_HOME="/Users/motoki/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
