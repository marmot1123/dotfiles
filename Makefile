# Home Manager の適用・更新と Homebrew による導入は、それぞれ明示的に実行する。
.DEFAULT_GOAL := help
.PHONY: help all list doctor init-lock check build apply update apps bootstrap install deploy clean

help:
	@printf '%s\n' \
	  'dotfiles: minimal Apple Silicon macOS setup.' \
	  '  make help  Show this help.' \
	  '  make doctor     Report prerequisites and command paths without changing anything.' \
	  '  make init-lock  Generate the first flake.lock (requires Nix).' \
	  '  make check      Evaluate and build the locked Home Manager profile.' \
	  '  make build      Build the locked activation package without applying it.' \
	  '  make apply      Build and activate the locked profile, checking for conflicts.' \
	  '  make update     Update Nix inputs and build-check; do not activate.' \
	  '  make apps       Install missing entries from Brewfile.macos; do not upgrade.' \
	  '  make list       List Git-tracked files.' \
	  'Start with docs/macos-setup.md. No installation occurs with make or make all.'

all: help

list:
	@git ls-files

doctor:
	@/bin/bash scripts/doctor.sh

init-lock check build apply update:
	@/bin/bash scripts/home.sh $@

apps:
	@/bin/bash scripts/apps.sh

bootstrap:
	@printf '%s\n' 'Complete the manual prerequisites in docs/macos-setup.md first.' 'Then use init-lock, check, apply, and apps separately.'

install deploy clean:
	@printf '%s\n' 'This legacy target is disabled. See docs/macos-setup.md.' >&2
	@exit 2
