# fish を単独で起動した場合も、必要な環境変数を用意する。
# zsh 側の対応する設定は ~/.zprofile。
set --global --export LANG en_US.UTF-8
if not set --query XDG_CONFIG_HOME
    set --global --export XDG_CONFIG_HOME "$HOME/.config"
end
set --global --export LSCOLORS exfxcxdxbxegedabagacad

begin
    set --local brew_executable
    if not test -x "$HOMEBREW_PREFIX/bin/brew"
        set brew_executable (command --search brew)
        if test -z "$brew_executable"
            if test -x /opt/homebrew/bin/brew
                set brew_executable /opt/homebrew/bin/brew
            else if test -x /usr/local/bin/brew
                set brew_executable /usr/local/bin/brew
            end
        end
        if test -n "$brew_executable"
            "$brew_executable" shellenv fish | source
        end
    end

    if set --query HOMEBREW_PREFIX
        fish_add_path --path "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
    end
    if not set --query PNPM_HOME
        set --global --export PNPM_HOME "$HOME/Library/pnpm"
    end

    # --path により universal 変数への書き込みを避ける。
    set --local preferred_paths "$PNPM_HOME" "$HOME/.cargo/bin"
    if set --query HOMEBREW_PREFIX
        set --append preferred_paths "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"
    end
    set --append preferred_paths "$HOME/.npm-global/bin" "$HOME/.elan/bin"
    fish_add_path --path --prepend --move $preferred_paths
    fish_add_path --path --append "$HOME/.local/bin" /usr/local/sbin

    # 研究環境を維持する暫定指定。自動で TeX の年度を更新しない。
    set --local tex_root /usr/local/texlive/2026
    if set --query TEXLIVE_ROOT; and test -n "$TEXLIVE_ROOT"
        set tex_root "$TEXLIVE_ROOT"
    end
    set --local tex_bin "$tex_root/bin/universal-darwin"
    fish_add_path --path --append "$tex_bin"
    set --local tex_man "$tex_root/texmf-dist/doc/man"
    set --local tex_info "$tex_root/texmf-dist/doc/info"
    if test -d "$tex_man"; and not contains -- "$tex_man" $MANPATH
        if not set --query MANPATH
            set --global --export MANPATH ""
        end
        set --global --export --path MANPATH $MANPATH "$tex_man"
    end
    if test -d "$tex_info"; and not contains -- "$tex_info" $INFOPATH
        if not set --query INFOPATH
            set --global --export INFOPATH ""
        end
        set --global --export --path INFOPATH $INFOPATH "$tex_info"
    end
    fish_add_path --path --append "$HOME/.opam/default/bin"
    if set --query HOMEBREW_PREFIX
        fish_add_path --path --append "$HOMEBREW_PREFIX/opt/postgresql@17/bin"
    end

    # 古い親シェルから引き継いだ PATH の重複も取り除く。
    set --local unique_path
    for entry in $PATH
        if not contains -- "$entry" $unique_path
            set --append unique_path "$entry"
        end
    end
    set --global --export PATH $unique_path
end

# 色・キーバインドは既存の conf.d の設定を維持する。
# ssh-agent は起動せず、macOS の SSH_AUTH_SOCK を引き継ぐ。
