#!/bin/bash
# Home Manager の衝突確認に加え、書き込み先の親ディレクトリを確認する。
set -eu

if [ "$#" -ne 1 ] || [ ! -d "$1" ]; then
    printf '%s\n' 'Usage: bash scripts/preflight-home.sh EXISTING_HOME_DIRECTORY' >&2
    exit 2
fi
target_home=$1
failures=0
if [ -L "$target_home" ]; then
    printf 'REVIEW home directory symlink before applying: %s\n' "$target_home" >&2
    exit 1
fi

for relative in .config .config/fish .config/fish/conf.d .config/fish/functions .config/git .config/ghostty .ssh; do
    target="$target_home/$relative"
    if [ -L "$target" ] || { [ -e "$target" ] && [ ! -d "$target" ]; }; then
        printf 'REVIEW parent path before applying: %s\n' "$target" >&2
        failures=$((failures + 1))
    fi
done

# この構成と重なって読み込まれる既存ファイルを、自動では統合しない。
for relative in .gitconfig .config/ghostty/config \
    'Library/Application Support/com.mitchellh.ghostty/config' \
    'Library/Application Support/com.mitchellh.ghostty/config.ghostty'; do
    target="$target_home/$relative"
    if [ -e "$target" ] || [ -L "$target" ]; then
        printf 'REVIEW overlapping configuration: %s\n' "$target" >&2
        failures=$((failures + 1))
    fi
done

if [ "$failures" -ne 0 ]; then
    printf '%s\n' 'No files were changed. Preserve and review these paths; do not force replacement.' >&2
    exit 1
fi
printf '%s\n' 'Parent paths checked. Home Manager will check individual destination files before activation.'
