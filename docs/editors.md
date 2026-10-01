# Vim・Neovim

## 使い分け

- Vim: 復旧時や短い編集に使う最小構成。Apple 標準の `/usr/bin/vim` で動き、外部プラグインに依存しない。
- Neovim: 普段の編集用。用途に合わせて Lua 設定と必要な機能を段階的に追加する。

Neovim の整備は次の優先順で進める。

新 Mac の初回セットアップは [Chrome・Slack と共通 CLI](macos-setup.md)を優先する。
その最小 Home Manager 構成は Vim の設定までを対象とし、以下の Neovim 環境は次の段階で移す。

1. Python の読み書き
2. Markdown・設定ファイルの編集
3. HTML/CSS の編集
4. LaTeX の論文執筆（主に VSCode・Zed を使う）
5. Rust（主に LLM が書き、Zed 等で読む）

現在の拡張は Python の編集支援、言語共通のファイル名・本文検索、
Markdown の表示設定。設定ファイルは標準機能を基本にする。
HTML/CSS 専用の編集支援は、次の段階で検討する。

| 設定 | 配置先 | 内容 |
| --- | --- | --- |
| `.vimrc` | `~/.vimrc` | Vim の基本設定 |
| `config/nvim/init.lua` | `~/.config/nvim/init.lua` | Lua 設定の読み込み |
| `config/nvim/lua/options.lua` | 同じ構造で配置 | Neovim のオプション |
| `config/nvim/lua/keymaps.lua` | 同じ構造で配置 | Neovim のキー操作 |
| `config/nvim/lua/plugins.lua` | 同じ構造で配置 | fzf-lua の管理と検索操作 |
| `config/nvim/lua/theme.lua` | 同じ構造で配置 | Kanagawa Wave の配色 |
| `config/nvim/lua/highlight.lua` | 同じ構造で配置 | 構文ハイライトとパーサー一覧 |
| `config/nvim/after/ftplugin/markdown.lua` | 同じ構造で配置 | Markdown の記号表示と画面上の折り返し |
| `config/nvim/lua/lsp.lua` | 同じ構造で配置 | 補完・診断・LSP の共通操作 |
| `config/nvim/lsp/` | 同じ構造で配置 | Python の言語サーバー設定 |
| `config/nvim/nvim-pack-lock.json` | 同じ構造で配置 | プラグインの検証済み revision |

この Mac では `~/.vimrc` と `~/.config/nvim` はリポジトリへのリンクになっている。
新しい Mac では配置先の実体・リンク先を確認し、既存設定があればバックアップしてから統合する。
現行 Makefile による配置は行わない。

## 共通の操作とインデント

挿入モードで `jk` と続けて入力するとノーマルモードに戻る。通常の Esc も使える。
既定では Tab キーでスペース4個を入力し、インデントも4桁にする。
`tabstop`・`shiftwidth`・`softtabstop` を4にし、`expandtab` を有効にする。

ファイルタイプ別の標準設定を優先する。例えば Makefile ではタブを使う。
Neovim は標準の [EditorConfig 対応](https://neovim.io/doc/user/plugins/#editorconfig)も利用するため、
プロジェクトに `.editorconfig` があれば、その指定が適用される。
Vim には EditorConfig 用の外部プラグインを追加していない。
プロジェクト独自の指定があるファイルでは、必要に応じて `:setlocal` で合わせる。

Vim の既存の行番号・検索ハイライト・構文色付け・`elflord` 配色を維持する。
Neovim の既存の行番号と、大文字を含む検索語だけ大文字・小文字を区別する検索設定を維持する。

## シンタックスハイライトと配色

最終構成では、主に扱う言語のシンタックスハイライトを必須とする。
Vim は標準の構文色付けと `elflord` を維持する。
Neovim はダークテーマの Kanagawa Wave を使う。背景は濃紺、本文は白すぎない色とし、
テーマ標準の色を使う。true color を有効にし、コメント・キーワードの斜体は無効にする。
Ghostty の配色設定は変更しない。

Python、Markdown、HTML/CSS、JSON、YAML、TOML、Lua、シェル（sh/bash）、Rust、LaTeX は
Tree-sitter による構文ハイライトを使う。
Markdown 内の Python コードブロックや、HTML の style 要素内の CSS も対象になる。
JSONC はコメント対応の標準の構文色付けを使う。末尾カンマなどの警告表示も標準の判定に従う。
インデント・折り畳みの方式は、このハイライト設定では変更しない。
パーサー未導入の言語は標準の構文色付けに戻り、通常起動ではパーサーを自動取得・更新しない。

配色は新しい `nvim` で確認する。Kanagawa に同梱された別の暗色版も、一時的に試せる。

```vim
:colorscheme kanagawa-dragon
:colorscheme kanagawa-wave
```

設定を書き換えなければ、次回起動時には Wave に戻る。
見やすさは実際の Ghostty 上で確認し、必要なら本文やコメントの明るさを調整する。

## Neovim の補完・Python・検索

補完候補は入力中に表示し、自動選択・自動確定しない。
ノーマルモードの Space を追加操作の起点（leader）として使う。
Space と続く文字は同時押しではなく、順番に入力する。

| 操作 | キー |
| --- | --- |
| 補完候補の次・前を選ぶ（挿入モード） | `Ctrl+n` / `Ctrl+p` |
| 選んだ補完候補を確定／補完を中止 | `Ctrl+y` / `Ctrl+e` |
| 補完候補を手動でも呼び出す | `Ctrl+x` の後に `Ctrl+o` |
| 定義へ移動／移動前へ戻る | `gd` / `Ctrl+o` |
| 型や関数の説明 | `K` |
| 参照箇所の一覧／名前変更 | `grr` / `grn` |
| 修正候補などのコードアクション | `gra` |
| 次・前の診断へ移動 | `]d` / `[d` |
| 現在行の診断の詳細 | `Space c d` |
| Python のバッファ全体を整形 | `Space c f` |
| ファイル名で検索 | `Space f f` |
| 本文を検索 | `Space f g` |
| 開いているバッファを選ぶ | `Space f b` |

Python の定義ジャンプ・補完・型の診断は basedpyright、lint と整形は Ruff が担当する。
Neovim 標準の LSP クライアントと補完機能を使う。
型検査は既定で `standard` とし、プロジェクトの `pyproject.toml` / `pyrightconfig.json` の指定を優先する。
Ruff もプロジェクトの `pyproject.toml` / `ruff.toml` / `.ruff.toml` を読む。
保存時の自動整形は行わない。`Space c f` はバッファを整形し、保存は通常の `:write` で行う。

basedpyright はプロジェクト直下の `.venv` を認識する。
既存の Conda 等を使う場合は、その環境を有効にしてから `nvim` を起動する。
プロジェクトに Ruff 自体の版指定がある場合も、指定された環境を有効にして、
`command -v ruff` と `ruff --version` を確認してから起動する。
この dotfiles はプロジェクトの依存ライブラリや仮想環境を作成・更新しない。

検索は fzf-lua と既存の fzf・fd・ripgrep を使う。
範囲は Neovim の現在の作業ディレクトリ。通常はプロジェクトのディレクトリから `nvim` を起動する。
ドットファイルも対象にし、`.git`・`.venv`・`__pycache__`・`node_modules` は除外する。
通常の ignore 設定も尊重する。Bizin Gothic 通常版に合わせ、ファイル種別のアイコンは表示しない。

## Markdown・設定ファイルの編集

Markdown は `#`・`**`・リンク先などの記号や文字を隠さず、構文ハイライトで読みやすくする。
長い行は画面の幅で折り返し、英語の単語は可能な範囲で区切りを保つ。
インデントした行は、折り返し部分もインデントして表示する。
これらは表示だけの設定で、ファイルに改行を追加しない。
入力中の自動改行・段落の自動整形も無効にする。
プロジェクトの `.editorconfig` にあるインデント指定などは引き続き適用する。

| 操作 | 標準のキー |
| --- | --- |
| 折り返した画面上の行で下・上へ移動 | `gj` / `gk` |
| ファイル上の行で下・上へ移動 | `j` / `k` |
| ファイル内などの単語から補完（挿入モード） | `Ctrl+x` の後に `Ctrl+n` |
| ファイル名・パスを補完（挿入モード） | `Ctrl+x` の後に `Ctrl+f` |

`gq` は実際に改行を入れる文章整形なので、画面上の折り返しには使わない。
Markdown のプレビューや記号を置き換える描画プラグインは使わない。
dotfiles では保存時の自動整形や末尾空白の一括削除を設定しない。
Markdown の行末スペース2個による改行も、そのまま編集できる。
ただし、プロジェクトの `.editorconfig` に空白削除等の指定があれば、その指定を優先する。

設定ファイルは、まず次の範囲を標準のファイルタイプ判定・補完・インデントと、
既存の構文ハイライトで編集する。

| 形式 | 主な用途 | 現在の扱い |
| --- | --- | --- |
| JSON / JSONC | アプリ設定・プロジェクト設定 | JSONC のコメントも表示する。JSONC の色付けは標準の構文機能 |
| YAML | GitHub Actions など | 標準の YAML 設定に従いスペース2個。プロジェクトの指定を優先 |
| TOML | `pyproject.toml` など | 標準のファイルタイプ設定と構文ハイライト |
| Lua | Neovim 設定 | 標準のファイルタイプ設定と構文ハイライト |

設定項目の自動補完・スキーマ検証・専用フォーマッターは、この段階では追加しない。
`Space c f` による整形は引き続き Python が対象。
外部ツールの依存は増やさず、必要な編集支援が具体化したら形式ごとに追加する。

## 依存ツールの管理と新しい Mac

Neovim 0.12 以上、Git、fzf、fd、ripgrep が必要。
新しい Mac では各コマンドの有無と管理元を確認してから、不足分を導入する。
現在の Neovim・fzf・fd・ripgrep は Homebrew 側にあり、Nix 側との二重管理は行わない。

Python の編集支援ツールは当面 uv の tool 環境で管理する。
既存のインストールがないことを確認した新しい Mac での導入例:

```sh
uv tool install basedpyright==1.40.1
uv tool install ruff
command -v basedpyright-langserver ruff
basedpyright --version
ruff --version
```

現在の Mac では basedpyright 1.40.1 を新規導入し、既存の Ruff 0.6.2 を使って連携を確認した。
Ruff の既存環境には `uv tool list` で管理状態の警告が出る。
Ruff の更新・管理状態の修復は、既存環境をバックアップしてから別の変更として行う。
上記の新規導入例では Ruff の版は固定していないため、新しい Mac でも動作確認する。

fzf-lua、Kanagawa、nvim-treesitter は Neovim 標準の `vim.pack` で管理する。
初回起動時はネットワークからインストールするため、完了を待つ。
`nvim-pack-lock.json` があれば記録された revision を使い、通常の起動では更新しない。
lock file は Neovim が生成したものを dotfiles で追跡する。
以前の lazy.nvim・Mason の保存データは今回の構成では読み込まない。

プラグインの更新は明示的に `:lua vim.pack.update()` で行う。
表示された変更を確認し、反映する場合はその確認バッファで `:write`、中止する場合は `:quit` とする。
更新後は新しい Neovim で動作確認し、lock file の差分も確認する。
nvim-treesitter を更新した場合は、下記のパーサー更新も行う。
`vim.pack` は現時点で実験的 API のため、Neovim 本体の更新時にも確認する。

### Tree-sitter の導入と更新

パーサーのビルドには C コンパイラー、curl、tar と `tree-sitter` CLI が必要。
この Mac では Apple Command Line Tools のコンパイラーと、
Homebrew の `tree-sitter-cli` 0.27.0 を使って確認した。
CLI は Brewfile に記録する。現在の nvim-treesitter が要求する CLI は 0.26.1 以上。
新しい Mac ではコマンドの有無を確認し、不足する場合に導入する。

```sh
xcrun --find clang
command -v tree-sitter
brew install tree-sitter-cli
```

初回のプラグイン取得が終わった Neovim で、次を実行してパーサーを導入する。
処理は非同期なので、完了通知を待ってから Neovim を開き直す。

```vim
:lua require('nvim-treesitter').install(require('highlight').parsers)
```

パーサー一覧は `lua/highlight.lua` を正本とする。
取得する版は、lock file で固定した nvim-treesitter 内の定義に従う。
生成したパーサー・クエリは `~/.local/share/nvim/site/` に置き、Git には追加しない。
これはコンパイラーや OS の版まで固定するものではない。

nvim-treesitter 自体を更新したら、新しくファイルを指定せずに Neovim を起動し、
次を実行する。完了後に開き直して構文ハイライトを確認する。

```vim
:lua require('nvim-treesitter').update(require('highlight').parsers)
```

## 反映・確認・復旧

新しく `vim` または `nvim` を起動して確認する。
空のテキストバッファで `i`、Tab、`jk` と入力し、スペース4個が入ってノーマルモードへ戻るか確かめる。
保存せず終了するには `:q!` を使う。

設定の影響を外して起動する場合:

```sh
/usr/bin/vim -Nu NONE
nvim --clean
```

非対話の検証では起動とインデントの挙動を確認し、見た目・キー操作はターミナルでも確認する。
Python ファイルで `:checkhealth vim.lsp` を実行すると、言語サーバーの状態を確認できる。
プロジェクトのライブラリが見つからない場合は、使用中の仮想環境とプロジェクト設定を確認する。

## Neovim の管理状態

`config/nvim/` の設定ファイルは親の dotfiles リポジトリで追跡しているが、
同ディレクトリ内には古い独立リポジトリの `.git` も残っている。
内側のリポジトリには以前から差分があるため、親の状態と区別する。
独立リポジトリの削除や履歴の整理は別の作業として扱う。

## 参考

- [Neovim: LSP と標準の補完・キー操作](https://neovim.io/doc/user/lsp/)
- [Neovim: パッケージ管理](https://neovim.io/doc/user/pack/)
- [Neovim: 表示・折り返しオプション](https://neovim.io/doc/user/options/)
- [Neovim: 文章整形と formatoptions](https://neovim.io/doc/user/change/#fo-table)
- [basedpyright: 導入](https://docs.basedpyright.com/latest/installation/command-line-and-language-server/)
- [basedpyright: Python 環境の選択](https://docs.basedpyright.com/latest/usage/import-resolution/)
- [Ruff: Neovim との連携](https://docs.astral.sh/ruff/editors/setup/)
- [fzf-lua](https://github.com/ibhagwan/fzf-lua)
- [Kanagawa](https://github.com/rebelot/kanagawa.nvim)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [Homebrew: tree-sitter-cli](https://formulae.brew.sh/formula/tree-sitter-cli)
