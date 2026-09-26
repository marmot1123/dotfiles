function fish_prompt --description 'Directory and Git branch'
    set --local last_status $status
    set --local normal (set_color normal)
    set --local cwd_color $fish_color_cwd
    set --local suffix '>'

    if fish_is_root_user
        set cwd_color $fish_color_cwd_root
        set suffix '#'
    end
    if test -z "$cwd_color"
        set cwd_color green
    end

    printf '%s%s%s' (set_color $cwd_color) (prompt_pwd) "$normal"
    if command --query git
        fish_git_prompt ' (%s)'
    end
    printf '%s ' "$normal"
    if test "$last_status" -ne 0
        set_color red
    end
    printf '%s%s ' "$suffix" "$normal"
end
