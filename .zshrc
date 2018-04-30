# Created by newuser for 5.0.8

# パス
#export PATH=/usr/local/sbin:$PATH
#export PATH=$NODEBREW_ROOT/current/bin:$PATH
#export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH=/usr/local/opt/openssl/bin:$PATH
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:/anaconda3/bin

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

# hocxom用エイリアス（IPAexを埋め込むTeXタイプセット）
alias hocsom="ptex2pdf -e -l -ot '-synctex=1' -od '-f ptex-ipaex.map'"

# nodebrew
export NODEBFREW_ROOT=/usr/local/var/nodebrew

fpath=(/usr/local/share/zsh-completions $fpath)

# OPAM configuration
export PATH="$PATH:/opt/chefdk/bin:/Users/motoki/.chefdk/gem/ruby/2.4.0/bin:/opt/chefdk/embedded/bin:/opt/chefdk/gitbin"
export GEM_ROOT="/opt/chefdk/embedded/lib/ruby/gems/2.4.0"
export GEM_HOME="/Users/motoki/.chefdk/gem/ruby/2.4.0"
export GEM_PATH="/Users/motoki/.chefdk/gem/ruby/2.4.0:/opt/chefdk/embedded/lib/ruby/gems/2.4.0"
function _chef() {

  local -a _1st_arguments
  _1st_arguments=(
      'exec:Runs the command in context of the embedded ruby'
      'env:Prints environment variables used by ChefDK'
      'gem:Runs the `gem` command in context of the embedded ruby'
      'generate:Generate a new app, cookbook, or component'
      'shell-init:Initialize your shell to use ChefDK as your primary ruby'
      'install:Install cookbooks from a Policyfile and generate a locked cookbook set'
      'update:Updates a Policyfile.lock.json with latest run_list and cookbooks'
      'push:Push a local policy lock to a policy group on the server'
      'push-archive:Push a policy archive to a policy group on the server'
      'show-policy:Show policyfile objects on your Chef Server'
      'diff:Generate an itemized diff of two Policyfile lock documents'
      'provision:Provision VMs and clusters via cookbook'
      'export:Export a policy lock as a Chef Zero code repo'
      'clean-policy-revisions:Delete unused policy revisions on the server'
      'clean-policy-cookbooks:Delete unused policyfile cookbooks on the server'
      'delete-policy-group:Delete a policy group on the server'
      'delete-policy:Delete all revisions of a policy on the server'
      'undelete:Undo a delete command'
      'verify:Test the embedded ChefDK applications'
    )

  _arguments \
    '(-v --version)'{-v,--version}'[version information]' \
    '*:: :->subcmds' && return 0

  if (( CURRENT == 1 )); then
    _describe -t commands "chef subcommand" _1st_arguments
    return
  fi
}

compdef _chef chef
