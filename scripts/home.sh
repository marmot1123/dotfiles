#!/bin/bash
# lock の生成・検証・適用・更新を分離する。Bash 3.2 対応。
set -eu
set -o pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
operation=${1:-help}
case "$operation" in
    init-lock|check|build|apply|update) ;;
    *) printf '%s\n' 'Usage: bash scripts/home.sh {init-lock|check|build|apply|update}'; exit 2 ;;
esac
if [ "$#" -ne 1 ]; then
    printf '%s\n' 'Pass exactly one operation.' >&2
    exit 2
fi
if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
    printf '%s\n' 'This profile targets native Apple Silicon macOS.' >&2
    exit 1
fi

nix_executable=$(command -v nix || true)
if [ -z "$nix_executable" ] && [ -x /nix/var/nix/profiles/default/bin/nix ]; then
    nix_executable=/nix/var/nix/profiles/default/bin/nix
fi
if [ -z "$nix_executable" ]; then
    printf '%s\n' 'Nix is not installed or not on PATH. See docs/macos-setup.md.' >&2
    exit 1
fi
cd "$repo_root"
nix_command() {
    "$nix_executable" --extra-experimental-features 'nix-command flakes' "$@"
}

if [ "$operation" = init-lock ]; then
    if [ -e flake.lock ] || [ -L flake.lock ]; then
        printf '%s\n' 'flake.lock already exists. Use check/apply, or update explicitly.' >&2
        exit 1
    fi
    nix_command flake lock
    printf '%s\n' 'Lock generated. Run make check, review flake.lock, and commit it before sharing this setup.'
    exit 0
fi
if [ ! -f flake.lock ]; then
    printf '%s\n' 'flake.lock is missing. Generate it with make init-lock and validate it with make check first.' >&2
    exit 1
fi
if [ "$operation" = update ]; then
    nix_command flake update
    nix_command flake check --no-update-lock-file --no-write-lock-file
    printf '%s\n' 'Inputs updated and build checked; no home configuration was activated. Review the lock diff before applying.'
    exit 0
fi
if [ "$operation" = check ]; then
    nix_command flake check --no-update-lock-file --no-write-lock-file
    exit 0
fi

if [ "$operation" = apply ]; then
    expected_user=$(nix_command eval --raw --no-update-lock-file --no-write-lock-file '.#homeConfigurations.macbook.config.home.username')
    expected_home=$(nix_command eval --raw --no-update-lock-file --no-write-lock-file '.#homeConfigurations.macbook.config.home.homeDirectory')
    if [ "$(id -un)" != "$expected_user" ] || [ "$HOME" != "$expected_home" ]; then
        printf '%s\n' 'Account does not match home/macos.nix. Adjust that file before applying.' >&2
        exit 1
    fi
    if [ "${XDG_CONFIG_HOME:-$HOME/.config}" != "$HOME/.config" ] || [ -n "${ZDOTDIR:-}" ]; then
        printf '%s\n' 'Custom XDG_CONFIG_HOME or ZDOTDIR requires review before applying this profile.' >&2
        exit 1
    fi
    /bin/bash "$repo_root/scripts/preflight-home.sh" "$expected_home"
fi

built_home=$(nix_command build --no-link --print-out-paths --no-update-lock-file --no-write-lock-file '.#homeConfigurations.macbook.activationPackage')
if [ "$operation" = build ]; then
    printf '%s\n' "$built_home"
    exit 0
fi
case "$built_home" in
    /nix/store/*) ;;
    *) printf '%s\n' 'Unexpected activation package path; stopping.' >&2; exit 1 ;;
esac
if [ ! -x "$built_home/activate" ]; then
    printf '%s\n' 'Activation executable is missing; stopping.' >&2
    exit 1
fi
# Home Manager は既存ファイルとの衝突時に停止する。force や自動バックアップ上書きは使わない。
unset HOME_MANAGER_BACKUP_EXT HOME_MANAGER_BACKUP_COMMAND HOME_MANAGER_BACKUP_OVERWRITE
"$built_home/activate"
