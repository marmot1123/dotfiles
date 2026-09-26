# macOS のシェル構成

アカウントのログインシェルと Ghostty の起動シェルは Apple の `/bin/zsh`。
普段の作業では `fish` と入力して手動で切り替える。fish の自動起動は行わない。
メッセージの基本言語は英語（`LANG=en_US.UTF-8`）とする。
`LC_ALL` は固定しないため、明示的に渡された `LC_*` の指定は優先される。

## 起動と復旧

- Ghostty の `command = /bin/zsh` で Apple 標準の zsh を起動する。
  アカウントのログインシェルも `/bin/zsh` のまま維持する。
- Apple の「ターミナル」は「設定 → 一般 → 開くシェル」を
  「デフォルトのログインシェル」にしておくと zsh を使える。
- 起動後に `fish` と入力すると、zsh の子プロセスとして fish が起動する。
  fish は現在 Homebrew 管理。fish で `exit` すると元の zsh に戻る。
- その zsh でもう一度 `exit` すると、ターミナルのセッションが終了する。
- ユーザー設定が壊れた場合は、Apple のターミナルの「シェル → 新規コマンド」
  などから `/bin/zsh -f` を起動する。
  `-f` はユーザーの起動設定を省略するが、親の PATH 等は引き継ぐ。

Ghostty のシェル自動連携は起動時の zsh が対象になる。
手動で起動する fish での連携機能は、実際の GUI 操作で確認する。
既存の Ghostty セッションはそのまま残し、設定を再読込して新しいタブで確認する。
macOS の既定の再読込キーは `⌘⇧,`。

## 管理するファイル

| リポジトリ | 配置先 | 役割 |
| --- | --- | --- |
| `.zprofile` | `~/.zprofile` | zsh の環境変数・PATH |
| `.zshrc` | `~/.zshrc` | zsh の補完・履歴・キー・プロンプト |
| `config/fish/` | `~/.config/fish` | fish の環境と既存の表示設定 |
| `config/ghostty/config.ghostty` | `~/.config/ghostty/config.ghostty` | zsh の選択と既存の表示設定 |

zsh のログイン起動では `.zprofile` が読み込まれる。
非ログインの対話起動では `.zshrc` が `.zprofile` を読み、環境を用意する。
fish は `config.fish` で環境を用意し、zsh の実行に依存しない。

新しい Mac への配置前には、表の配置先の実体とリンク先を確認する。
既に正しいリンクなら作業は不要。別のファイル・リンクがある場合は停止して内容を確認し、
上書きしない場所へバックアップしてから配置する。
**現行 Makefile の install/deploy/clean は使わない。**
この段階では汎用の配置スクリプトや Nix/Home Manager は導入していない。

Ghostty は XDG 配下と
`~/Library/Application Support/com.mitchellh.ghostty/` 配下の設定を両方読み込む。
今回、以前の `~/.config/ghostty/config` と macOS 側の `config.ghostty` を
バックアップへ移し、表の1ファイルへまとめた。
新しい Mac でもこれらの旧ファイルによる追加設定・上書きに注意する。

## PATH と維持した環境

- 既存 Homebrew を検出する。シェル起動ではインストール・更新を行わない。
- 存在するディレクトリだけを追加し、PATH の重複を取り除く。
- pnpm、rustup、GNU coreutils、npm のユーザー領域、elan の参照を維持する。
  既存の OPAM default と PostgreSQL 17 も、ディレクトリがある場合だけ参照する。
- Rust は `~/.cargo/bin` を優先する。rustup の初期化ファイルは存在確認して読む。
- zsh の `ls` / `ll` は GNU `gls` があればそれを使い、
  なければ Apple の `/bin/ls` を使う。
- fish の既存の配色と zsh の従来の操作設定を維持する。
  fish のプロンプトと検索用のキー設定は、次の節のとおり。
- `ssh-agent` の新規起動と起動時の `ssh-add` は行わず、
  macOS が渡した `SSH_AUTH_SOCK` を引き継ぐ。
  鍵の登録と Git/SSH 認証は別途実際に確認する。

TeX は、整理前に実際に参照されていた
`/usr/local/texlive/2026/bin/universal-darwin` を**意図的な暫定指定**として維持する。
Linux 用パスの追加は取り除いた。年度の自動選択や TeX の更新は行わない。
別の年度を使う場合は、起動前の環境変数 `TEXLIVE_ROOT` でインストール先を指定できる。
この上書きは親から既に継承した他の TeX の PATH を削除するものではないため、
クリーンな新しい起動環境でコマンドの参照先を確認する。

新しい Mac では TeX の実際の配置を確認して、この暫定指定を見直す。
TeX の移行時に標準の `/Library/TeX/texbin` の利用も検討する。
今回のシェル整理は文書ビルドの検証を代替しない。

## fish の普段の操作

プロンプトは `~/dotfiles (master) > ` のように、ディレクトリと
Git ブランチを中心に表示する。親ディレクトリは fish 標準の方法で短縮し、
通常のユーザー名・ホスト名は省略する。直前のコマンドが失敗した場合は
`>` を赤くし、root では `#` を表示する。

Homebrew 管理の fzf がある場合は、付属の履歴検索を `Ctrl+R` に割り当てる。

| キー | 操作 |
| --- | --- |
| `Ctrl+R` | 履歴を絞り込み、選んだコマンドを入力欄へ戻す |
| 検索中の `Esc` | 選択を取り消す |

履歴から選んだだけではコマンドは実行しない。入力欄で確認してから実行する。
fzf の `Alt+C` によるディレクトリ選択は割り当てない。Ghostty の Option キー設定は変更しない。

`Tab` / `Shift+Tab` の補完と `Ctrl+T` の文字入れ替えは fish 標準を維持する。
fzf または Homebrew の連携ファイルがない場合は、fish 標準のキー設定を使う。
将来 fzf の管理元を Nix などへ変更する場合は、
`functions/fish_user_key_bindings.fish` の連携ファイルの参照先も見直す。

GitHub 固有の操作には、既に Homebrew 管理で入っている GitHub CLI の `gh` を使う。
`gh` は Git の代替ではないため、`git` のエイリアスにはしない。
通常の操作は `git status` / `git commit` 等、
GitHub 上の操作は `gh pr list` / `gh repo view` 等と使い分ける。
hub のエイリアスや追加インストールは行わない。

変更後は新しい fish を起動して確認する。実際の履歴ファイルは Git に追加しない。

## 確認する操作

Ghostty の新しいタブで、まず zsh が起動したことを確認して fish に入る:

```zsh
echo $ZSH_VERSION
echo $LANG
whence -p fish cargo rustc pnpm node platex latexmk
fish
```

fish で:

```fish
status is-interactive
echo $LANG
command --search fish cargo rustc pnpm node platex latexmk
exit
```

`exit` 後に zsh のプロンプトへ戻ることも確認する。
`$SHELL` はログインシェルの情報なので、fish 内でも `/bin/zsh` で構わない。
Apple のターミナルでも新しいウィンドウで zsh が起動することを確認する。
Ghostty の補完・日本語入力・フォント・新規タブの作業ディレクトリ継承は GUI で確認する。

構文検査は `zsh -f -n`、各ファイルへの `fish --no-config --no-execute`、
Ghostty 設定検査は `ghostty +validate-config` で行える。
構文検査とコマンド参照先の確認は、認証・研究計算・TeX ビルドの成功を保証しない。

## 今回のバックアップと戻し方

この Mac への反映前の設定は
`~/.local/state/dotfiles/backups/shell-*` に保存する。
各ディレクトリの `manifest.json` に元のパス・バックアップ先・反映後の状態を、
`RESTORE.md` に復元コマンドを記録する。

付属の `restore.py` は反映後に別の編集がないことを確認してから元へ戻す。
後から変更があれば停止するため、その差分を先に確認する。
復元後も、実行中のシェルの環境は巻き戻らない。新しいウィンドウで確認する。

## 参考

- [Ghostty の設定ファイル](https://ghostty.org/docs/config)
- [Ghostty のシェル連携](https://ghostty.org/docs/features/shell-integration)
- [zsh の起動ファイル](https://zsh.sourceforge.io/Doc/Release/Files.html)
- [fish_add_path](https://fishshell.com/docs/current/cmds/fish_add_path.html)
- [fzf のキー操作](https://github.com/junegunn/fzf#key-bindings-for-command-line)
- [fish のプロンプト](https://fishshell.com/docs/current/cmds/fish_prompt.html)
- [GitHub CLI](https://cli.github.com/manual/gh)
