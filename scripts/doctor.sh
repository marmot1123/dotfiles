#!/bin/bash
# 読み取り専用。認証情報を表示せず、インストール・修復・通信を行わない。
set -eu
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
missing=0
printf '%s\n' 'Command resolution in this shell:'
for tool in nix home-manager brew git git-lfs gh fish fzf fd rg codex; do
    resolved=$(command -v "$tool" || true)
    if [ -n "$resolved" ]; then
        printf '  %-14s %s\n' "$tool" "$resolved"
    else
        printf '  %-14s MISSING\n' "$tool"
        missing=$((missing + 1))
    fi
done
printf '\n%s\n' 'Applications:'
for app in 1Password 'Google Chrome' Slack Discord LINE zoom.us Ghostty ChatGPT Dropbox \
    'Microsoft Word' 'Microsoft Excel' 'Microsoft PowerPoint' 'Microsoft Outlook'; do
    if [ -d "/Applications/$app.app" ] || [ -d "$HOME/Applications/$app.app" ]; then
        printf '  %s: present (launch and sign-in are not checked)\n' "$app"
    else
        printf '  %s: MISSING\n' "$app"
        missing=$((missing + 1))
    fi
done
printf '\n%s\n' 'Input methods:'
if [ -d '/Library/Input Methods/GoogleJapaneseInput.app' ] || [ -d "$HOME/Library/Input Methods/GoogleJapaneseInput.app" ]; then
    printf '%s\n' '  Google Japanese Input: present (activation, dictionary, and key settings are not checked)'
else
    printf '%s\n' '  Google Japanese Input: MISSING'
    missing=$((missing + 1))
fi
if [ ! -f "$repo_root/flake.lock" ]; then
    printf '\n%s\n' 'flake.lock: MISSING; generate and build-check it before applying.'
    missing=$((missing + 1))
fi
if ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
    printf '%s\n' 'Apple developer tools: MISSING'
    missing=$((missing + 1))
fi
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    printf '%s\n' 'SSH public key: present (GitHub registration/authentication are not checked)'
else
    printf '%s\n' 'SSH public key: missing; follow docs/git-ssh.md.'
    missing=$((missing + 1))
fi
printf '\n%s\n' 'Configuration parent paths and overlapping files:'
if ! /bin/bash "$repo_root/scripts/preflight-home.sh" "$HOME"; then
    missing=$((missing + 1))
fi
printf '\n%s\n' 'Manually verify Bizin Gothic, 1Password/Chrome/Slack/ChatGPT/Dropbox sign-in, Dropbox sync, GitHub SSH authentication, and English UI.'
printf '%s\n' 'Manually verify Google Japanese Input activation, user dictionary migration, and Ctrl+J / Ctrl+K conversion.'
printf '%s\n' 'Manually verify that codex resolves to Homebrew and that Codex CLI sign-in works.'
printf '%s\n' 'Manually verify Office activation, Word/Excel/PowerPoint document editing, and Outlook account setup.'
printf '%s\n' 'Install LINE manually from the Mac App Store; verify Discord/LINE/Zoom sign-in and required audio/video/screen-sharing permissions.'
printf '%s\n' 'Run this in the new Mac terminal: paths in an agent process may differ from your interactive shell.'
if [ "$missing" -ne 0 ]; then exit 1; fi
