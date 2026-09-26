# fish の標準キー設定が読み込まれた後に呼ばれる。
function fish_user_key_bindings --description 'fzf history search'
    if not command --query fzf
        return
    end

    # 現在の管理元は Homebrew。付属のキーバインドだけを利用する。
    # fzf --fish は Shift+Tab も変更するため、ここでは読み込まない。
    set --local bindings "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.fish"
    if test -r "$bindings"
        # fzf は Ctrl+R の履歴検索だけに使い、他のキーは fish 標準を維持する。
        set --local --export FZF_CTRL_T_COMMAND ""
        set --local --export FZF_ALT_C_COMMAND ""
        source "$bindings"
    end
end
