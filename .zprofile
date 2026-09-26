# ログイン時の環境。非ログインの対話 zsh からも .zshrc 経由で読む。
# Ghostty 用 fish の環境設定は config/fish/config.fish に対応する。
export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# PATH は最初に現れた要素を残して重複を取り除く。
typeset -gU path PATH

() {
  local brew_executable dir tex_root tex_bin tex_man tex_info
  local -a preferred_paths existing_paths

  # 既存の Homebrew を利用する。インストールや更新は行わない。
  if [[ ! -x "${HOMEBREW_PREFIX:-}/bin/brew" ]]; then
    if (( $+commands[brew] )); then
      brew_executable=$commands[brew]
    elif [[ -x /opt/homebrew/bin/brew ]]; then
      brew_executable=/opt/homebrew/bin/brew
    elif [[ -x /usr/local/bin/brew ]]; then
      brew_executable=/usr/local/bin/brew
    fi
    if [[ -n $brew_executable ]]; then
      eval "$("$brew_executable" shellenv zsh)"
    fi
  fi

  if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
    for dir in "$HOMEBREW_PREFIX/sbin" "$HOMEBREW_PREFIX/bin"; do
      if [[ -d $dir ]] && (( ! ${path[(Ie)$dir]} )); then
        path=("$dir" $path)
      fi
    done
  fi

  # rustup の任意ファイルは、存在する場合だけ読む。
  [[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
  export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"

  preferred_paths=("$PNPM_HOME" "$HOME/.cargo/bin")
  if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
    preferred_paths+=("$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin")
  fi
  preferred_paths+=("$HOME/.npm-global/bin" "$HOME/.elan/bin")
  for dir in "${preferred_paths[@]}"; do
    [[ -d $dir ]] && existing_paths+=("$dir")
  done
  path=("${existing_paths[@]}" $path)

  for dir in "$HOME/.local/bin" /usr/local/sbin; do
    [[ -d $dir ]] && path+=("$dir")
  done

  # 既存の TeX Live 2026 を維持する移行中の指定。
  # 自動で最新版を選ばない。別の版は TEXLIVE_ROOT で明示する。
  tex_root="${TEXLIVE_ROOT:-/usr/local/texlive/2026}"
  tex_bin="$tex_root/bin/universal-darwin"
  [[ -d $tex_bin ]] && path+=("$tex_bin")
  tex_man="$tex_root/texmf-dist/doc/man"
  tex_info="$tex_root/texmf-dist/doc/info"
  if [[ -d $tex_man && :${MANPATH:-}: != *:${tex_man}:* ]]; then
    export MANPATH="${MANPATH:-}:$tex_man"
  fi
  if [[ -d $tex_info && :${INFOPATH:-}: != *:${tex_info}:* ]]; then
    export INFOPATH="${INFOPATH:-}:$tex_info"
  fi

  for dir in "$HOME/.opam/default/bin" "${HOMEBREW_PREFIX:-}/opt/postgresql@17/bin"; do
    [[ -d $dir ]] && path+=("$dir")
  done
}

# macOS の既存 SSH_AUTH_SOCK を引き継ぐ。
# ssh-agent の作成や ssh-add による鍵の読み込みはここでは行わない。
true
