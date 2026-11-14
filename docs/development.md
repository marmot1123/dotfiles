# Node.js・Python・Rust の開発環境

fnm・pnpm・uv・rustup 自体は `home/default.nix` の `home.packages` で管理する。
Homebrew・npm・standalone installer では重複導入しない。
Node.js・Python・Rust の言語本体は各管理ツールで導入し、プロジェクトごとに版を指定する。

| 対象 | 管理元 | プロジェクトで保存するもの |
| --- | --- | --- |
| fnm・pnpm・uv・rustup | Nix / standalone Home Manager | dotfiles の `flake.nix`・`flake.lock` |
| Node.js | fnm | `.node-version` または `.nvmrc`、`package.json`、npm / pnpm の lock |
| Python | uv | `.python-version`、`pyproject.toml`、`uv.lock` |
| Rust toolchain | rustup | `rust-toolchain.toml`、`Cargo.toml`、`Cargo.lock` |

`flake.lock` が固定するのは Nix 側の管理ツールとその依存。
fnm・uv・rustup が後からダウンロードする言語本体や、npm・PyPI・Cargo の依存まで自動で固定するものではない。
言語の実体、`.venv`、キャッシュ等は書き込み可能なユーザー領域に置き、dotfiles や Nix store に取り込まない。
既存プロジェクトの版指定と共同開発の手順を優先し、Nix を共同開発者の必須条件にしない。

## 新しい Mac への適用

既存の `fnm`・`pnpm`・`uv`・`rustup` と言語本体の解決先、Homebrew の導入状況を確認してから実行する。
追跡済みの lock を使い、入力の更新は行わない。

```sh
make check
make build
make apply
```

新しいターミナルを開く。ログインシェルは Apple の zsh のまま、fish は手動で起動する。

```sh
command -v fnm pnpm uv rustup cargo rustc
fnm --version
pnpm --version
uv --version
rustup --version
```

Nix の rustup パッケージには `cargo`・`rustc` 等のプロキシが付属する。
`rustup-init` や公式インストーラーを追加実行する必要はない。
toolchain 導入前は、プロキシがあってもコンパイルできない。

zsh は `.zshrc`、fish は `home/default.nix` で fnm を初期化する。
ディレクトリ移動時に `.node-version` / `.nvmrc` に合わせて切り替える。
未導入の版は明示的に `fnm install` で導入する。
uv の tool / Python 実行ファイル用の `~/.local/bin` と、`cargo install` 用の `~/.cargo/bin` は、
存在する場合に既存のシェル設定が PATH に加える。初めて作成した後は新しいシェルを開く。

## 言語本体の初回導入と版指定

以下は初回導入の例で、`make apply` やシェル起動時には自動実行しない。
既存プロジェクトでは、そのプロジェクトが指定する版を使う。

### Node.js

```sh
fnm install --lts
fnm use --lts
node --version
npm --version
```

既定版を明示する場合は `fnm default <導入済みの版>` を使う。
新規プロジェクトでは `node --version > .node-version` で実際の版を記録できる。
既存の版指定ファイルは確認なしに上書きしない。
npm / pnpm の依存はプロジェクト内で管理し、必要な pnpm の版もプロジェクトで指定する。

### pnpm

`pnpm.override { withNode = false; }` で導入し、実行時には PATH 上の Node.js を使う。
先に fnm で Node.js を選び、新しい対話 zsh / fish で利用する。
Nix のビルド時には Node.js が依存として使われるが、通常環境の Node.js の管理元は fnm のままにする。

```sh
pnpm --version
pnpm install --frozen-lockfile
pnpm run build
```

後の2行は既存の `pnpm-lock.yaml` と build スクリプトがあるプロジェクトで実行する。
新規プロジェクトでは `package.json` の `packageManager` に使用する版（例: `pnpm@11.27.0`）を記録し、
`pnpm install` で生成した `pnpm-lock.yaml` も保存する。
既存プロジェクトの指定や lock は確認なしに更新しない。
グローバルな入口は Nix で管理するため、`npm install -g pnpm`、`corepack enable pnpm`、
`pnpm setup`、`pnpm self-update` による別の入口の作成・置き換えは行わない。

### Python

```sh
uv python install
uv python list --only-installed
```

引数なしでは、その uv が選ぶ既定の安定版を導入する。最新版への追従を保証する指定ではない。
新規プロジェクトでは `uv init` の後、`uv python pin <使用する版>` で版を記録し、
`uv add <依存>`、`uv run <コマンド>` を使う。環境はプロジェクトの `.venv` に置く。
復元は `uv sync --locked` で行う。OS / Command Line Tools 付属の Python は残し、そこへ pip install しない。

### Rust

```sh
rustup default stable
rustc --version
cargo --version
```

`rustfmt`・Clippy を含む通常の stable toolchain を使う。
プロジェクトの `rust-toolchain.toml` の `channel` に実際の版（例: `1.x.y`）を記録し、
必要な `components` や `targets` もそこへ指定する。
`stable` は更新される名前なので、同じ版を再現したいプロジェクトでは具体的な版番号を使う。
macOS のネイティブビルドには Apple の Command Line Tools を利用する。

## 更新と復旧

- 管理ツールの更新は dotfiles の明示的な Nix 更新として行う。`make update` は他の Nix 依存も更新するため、lock 差分と build を確認してから適用する。
- `uv self update`・`rustup self update` や別のインストーラーで Nix 管理の実行ファイルを置き換えない。
- Node.js・Python の別バージョン導入、`rustup update`、プロジェクトの依存更新は、それぞれ明示的な別操作にする。
- Home Manager の旧世代を残す。設定を戻しても、言語本体・`.venv`・プロジェクトのデータまで巻き戻るわけではない。

## 2026-10-30 の新 Mac での確認

既存のコマンドと Homebrew の導入一覧を確認し、fnm・uv・rustup の重複がない状態で追加した。
既存 `flake.lock` は変更していない。

| Nix 管理ツール | 導入した言語本体 |
| --- | --- |
| fnm 1.39.0 | Node.js 26.13.0（導入時の LTS、fnm の既定版）。付属 npm は 11.20.0 |
| uv 0.11.21 | CPython 3.14.6（この uv が提供する既定の安定版） |
| rustup 1.29.0 | Rust / Cargo 1.99.1（導入時の最新 stable、aarch64-apple-darwin） |

Rust は rustfmt・Clippy を含む default profile を導入した。
Python は `uv python install` で導入し、`python3.14` または `uv run python` で利用する。
`python3` は Apple Command Line Tools 付属のものを引き続き指す。
各プロジェクトでは上の既定版より、そのプロジェクトの版指定を優先する。

実施した確認:

- 実際の `make check`・`make build`・`make apply`、zsh / fish / Bash の対象設定の構文検査。
- `make apply` の再実行で同じ世代を再利用すること、対話 zsh からの `make doctor` が成功すること。
- 新しい zsh / fish で、3つの管理ツールと Rust プロキシが Nix プロファイルを指すこと、補完が使えること。
- 一時ディレクトリで両シェルの fnm を system に切り替えてから `.node-version` のあるディレクトリへ移動し、指定版に切り替わることと Node のテスト実行。
- 一時 Python プロジェクトで `uv lock --offline`、`uv sync --locked --offline`、`.venv` 内の Python による計算・SQLite・SSL モジュール読み込み。
- 一時 Rust プロジェクトで `cargo fmt --check`、`cargo test --offline`、`cargo clippy --offline -- -D warnings`、ビルドした実行ファイルの起動。
- 既存の操作スクリプトの10件のテスト。これは仮の Nix / Homebrew によるテストで、上記の実機確認とは別。

検証用の一時プロジェクトは終了時に削除した。既存の研究プロジェクト、外部の npm / PyPI / Cargo 依存、
GUI エディタからの起動・連携はこの作業では検証していない。

同日、pnpm 11.27.0 を Nix / Home Manager に追加して適用した。
`withNode = false` による生成物の shebang は `#!/usr/bin/env node` で、
実行時依存に Nix の Node.js が含まれず、プロファイルにも `node` を追加しないことを確認した。
`make check`・`make build`・`make apply`・`make doctor` が成功し、zsh / fish の起動・補完も確認した。
一時プロジェクトではローカルの file 依存を `pnpm install --offline` で導入し、
`--frozen-lockfile` で再導入して lock が変化しないこと、`pnpm run` と `pnpm exec node` が
fnm の Node.js 26.13.0 を使うことを両シェルで確認した。
検証用のプロジェクトと専用 store は削除済み。外部レジストリからの依存取得と既存プロジェクトは未検証。

## 公式資料

- [fnm のシェル設定](https://github.com/Schniz/fnm#shell-setup)
- [pnpm の導入と Node.js 互換性](https://pnpm.io/installation)
- [Nixpkgs の pnpm 定義（使用中の revision）](https://github.com/NixOS/nixpkgs/blob/78e9c786dc08cd4f3420c2395cd977206a9b1da2/pkgs/development/tools/pnpm/generic.nix)
- [uv の Python 導入](https://docs.astral.sh/uv/guides/install-python/)
- [uv のプロジェクト管理](https://docs.astral.sh/uv/guides/projects/)
- [rustup をパッケージマネージャーで導入する場合](https://rust-lang.github.io/rustup/installation/other.html#using-a-package-manager)
- [rust-toolchain.toml](https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file)
