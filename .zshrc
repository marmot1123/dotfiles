# Ghostty・復旧用ともに zsh で起動する。fish は手動で起動する。
# zsh -i で直接起動した場合も環境変数を用意する。
if [[ ! -o login && -r "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# 補完
# Nix パッケージに同梱された fnm・uv・rustup 等の補完を使う。
typeset -gU fpath
if [[ -d "$HOME/.nix-profile/share/zsh/site-functions" ]]; then
  fpath=("$HOME/.nix-profile/share/zsh/site-functions" $fpath)
fi
autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 色とプロンプト
autoload -Uz colors
colors
export LSCOLORS=exfxcxdxbxegedabagacad
zstyle ':completion:*' list-colors ''
PROMPT="%{${fg[cyan]}%}%~ %{${reset_color}%}
%{${fg[yellow]}%}%n@%m$ %{${reset_color}%}"

# 履歴
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups share_history

# 従来の操作を維持
bindkey -e
setopt auto_cd auto_pushd correct list_packed nolistbeep

# GNU ls がない復旧環境でも動くようにする。
if (( $+commands[gls] )); then
  alias ls='gls -F --color=auto'
  alias ll='gls -laFh --color=auto'
else
  alias ls='/bin/ls -FG'
  alias ll='/bin/ls -laFGh'
fi

[[ -r "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# .node-version / .nvmrc に合わせて Node.js を切り替える。
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# 任意ファイルがない場合も、初期化は正常終了する。
true
