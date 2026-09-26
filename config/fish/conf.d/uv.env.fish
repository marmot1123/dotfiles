# 既存ファイル名を維持。ここで読むのは rustup の初期化ファイル。
if test -r "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end
