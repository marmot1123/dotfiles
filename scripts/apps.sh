#!/bin/bash
set -eu
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
brew_executable=$(command -v brew || true)
if [ -z "$brew_executable" ] && [ -x /opt/homebrew/bin/brew ]; then
    brew_executable=/opt/homebrew/bin/brew
fi
if [ -z "$brew_executable" ]; then
    printf '%s\n' 'Homebrew is not installed. See docs/macos-setup.md.' >&2
    exit 1
fi
HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 \
    "$brew_executable" bundle --file="$repo_root/Brewfile.macos" --no-upgrade
