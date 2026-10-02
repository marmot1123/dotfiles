# 新しい Mac の最小セットアップ

最初の完了条件は、Chrome と Slack で連絡を取れ、1Password・ChatGPT・Dropbox と、Ghostty 上の zsh・fish・Git を使えること。
新 Mac は未起動の状態から始める。Nix Flakes と standalone Home Manager で共通 CLI と設定を管理し、
GUI アプリ・Google 日本語入力・Codex CLI は Homebrew に分ける。Python・TeX・研究データ・LumenCite・Neovim の移行は次の段階にする。

## 準備済みの構成と検証状況

| 管理元 | 今回の対象 |
| --- | --- |
| Apple | ログインシェル `/bin/zsh`、SSH、Vim、Command Line Tools |
| Nix / Home Manager | Git、Git LFS、gh、fish、fzf、fd、ripgrep と以下の設定 |
| Homebrew の `Brewfile.macos` | 1Password、Chrome、Slack、Ghostty、ChatGPT、Dropbox、Google 日本語入力、Codex CLI |
| Homebrew の個別 Office cask（同じ `Brewfile.macos`） | Word、Excel、PowerPoint、Outlook。OneDrive・OneNote は対象外 |
| 公式配布から手動導入 | Bizin Gothic 通常版 |

`flake.nix` は nixpkgs の `nixos-26.05` と Home Manager の `release-26.05` を入力にする。
対象は Apple Silicon の `aarch64-darwin`、構成名は `macbook`。
短いアカウント名は暫定で `motoki`。異なる名前を作った場合は `home/macos.nix` の `home.username` を変更する。
`home.stateVersion` は互換性の基準なので、更新に合わせて変更しない。

この変更を準備した旧 Mac には Nix がない。
**flake.lock の生成、Nix の評価・build、Home Manager の実適用は未検証**。
lock の revision や hash を手で作らず、新 Mac で生成して検証する。
lock がない状態では `make apply` は停止する。シェルスクリプトの検査と仮の実行環境での停止条件の確認は、実機の適用とは別に扱う。

## 1 初回起動とアカウント

1. macOS の案内に従い、ネットワーク・アカウント・Apple Account を設定する。システム言語は English。
2. 自分の短いアカウント名を確認する。設定とデータは必要なものから移すため、今回は移行アシスタントで旧環境を一括コピーすることを前提にしない。
3. Apple の Terminal を開き、`id -un` と `echo "$SHELL"` を確認する。ログインシェルは `/bin/zsh` のままにする。
4. 1Password・GitHub・Slack・Google・ChatGPT・Dropbox・Microsoft のログインと二要素認証に使う手段を手元に用意する。Office の利用権があるアカウントも確認する。パスワードやコードを dotfiles に保存しない。

以下のコマンドは zsh で実行する。

## 2 SSH と Apple の開発ツール

[SSH 鍵の作成と GitHub 認証](git-ssh.md)の手順で、新 Mac 専用のパスフレーズ付き Ed25519 鍵を作成・登録する。
秘密鍵を旧 Mac からコピーする必要はない。GitHub のホスト鍵を公式の指紋と照合し、接続を確認する。

Command Line Tools は有無を確認して、不足する場合に導入する。

```zsh
xcode-select -p
# 未導入の場合だけ実行し、画面の案内でインストールを完了する。
xcode-select --install
```

この段階で Git が使えるようになる。旧 Mac の変更をコミット・push してから、新 Mac で取得する。
既に `~/dotfiles` がある場合は、上書き clone せず中身を確認する。

```zsh
git clone git@github.com:marmot1123/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
```

SSH 未設定でも、公開リポジトリは `https://github.com/marmot1123/dotfiles.git` から取得できる。
SSH の設定後に origin を SSH URL へ変更する。
取得した版に `flake.nix`・`home/`・`scripts/`・`Brewfile.macos` があることを確認する。
このチャットで作成した未コミット・未 push のファイルは、clone には含まれない。
この構成を使う場合、SSH 設定のリンクは Home Manager が配置するので、git-ssh.md の手動 `ln -s` は省略する。

## 3 Nix の導入と最初の lock

`command -v nix` と `/nix/var/nix/profiles/default/bin/nix` の有無を確認する。
既存の Nix があれば再インストールせず、版と管理方式を確認する。
未導入なら [Nix 公式の macOS 導入手順](https://nixos.org/download/#nix-install-macos)を使う。
インストーラーはシステムの変更と管理者認証を伴うため、新 Mac の本人のターミナルで実行する。
今回は公式 Nix を基本とし、別の Nix 実装の導入手順を混ぜない。

導入後は Terminal を開き直して `nix --version` を確認する。
ラッパーが `nix-command flakes` を有効にするので、まずは Nix の追加設定ファイルを手で作らなくてよい。

```zsh
cd "$HOME/dotfiles"
# home/macos.nix のアカウント名が id -un と一致することを確認する。
make init-lock
make check
```

共有された `flake.lock` が既にある場合、`make init-lock` は省略して `make check` から始める。
`make init-lock` は既存 lock を上書きしない。Nix は Git 未追跡のソースファイルを除外するため、
構成を追加したら Git に含まれる状態にしてから実行する。
生成した `flake.lock` は実際の評価・build 結果と差分を確認してコミットする。

## 4 設定を適用する

`make check` が成功したら実行する。

```zsh
make apply
```

この操作は既存 lock から build し、Home Manager の生成した設定を適用する。
Git pull、入力の自動更新、Homebrew の更新、GC は行わない。
アカウント名・ホーム・独自の XDG_CONFIG_HOME / ZDOTDIR を確認し、
設定先の親ディレクトリが symlink の場合や重複する Git / Ghostty 設定がある場合は停止する。
さらに Home Manager が各設定ファイルの衝突を確認し、既存ファイルを強制上書きしない。

衝突したファイルは、元のパスを控えた個別のバックアップと復元手順を用意してから統合する。
原因を確認せず削除したり、`force` を指定したりしない。旧 Mac の配置をこの操作で一括置き換えない。

適用後に新しい Terminal を開き、`command -v git gh fish` が Nix のプロファイルを指すことを確認する。
`fish` を手動で起動して、短いプロンプトと Ctrl+R の履歴検索を確認する。
Apple の zsh と Vim は引き続き利用できる。

| 配置先 | 内容 |
| --- | --- |
| `~/.zprofile`、`~/.zshrc` | zsh の初期化と Home Manager の PATH |
| `~/.config/fish/` の設定・関数 | 英語表示、プロンプト、Ctrl+R、色 |
| `~/.config/git/config`、`~/.gitignore_global` | Git の基本設定と共通の除外指定 |
| `~/.ssh/config` | GitHub の接続設定。鍵は管理対象外 |
| `~/.vimrc` | Apple Vim の最小設定 |
| `~/.config/ghostty/config.ghostty` | zsh 起動、フォント、行間、タブ・ペイン操作 |

設定は Nix store からの読み取り専用リンクになる。編集はリポジトリ側で行い、`make check` と `make apply` で反映する。
fish の履歴や `fish_variables` は Home Manager の配置対象にしない。
SSH 鍵や gh の認証情報はリポジトリに置かず、Nix store にも入れない。
既存シェル設定中の TeX・言語環境への任意 PATH はディレクトリが存在するときだけ有効になり、初回導入ではそれらのツールはインストールしない。

## 5 GUI アプリ・日本語入力・Codex CLI・フォント

Homebrew の有無を確認し、未導入の場合だけ [公式インストール手順](https://docs.brew.sh/Installation)を実行する。
インストーラーが表示する PATH の案内を確認し、新しい Terminal で `brew --version` が動くことを確認する。
既存の Home Manager 管理ファイルに案内を追記する必要がある場合は、直接リンク先を書き換えずリポジトリ側を編集する。
今回の zprofile は既存 Homebrew の配置を検出する。

Codex CLI は単独で更新できるよう Homebrew 管理の例外とし、`codex` cask を使う。
既に導入済みの場合は `type -a codex` で解決先を確認する。npm・Nix・standalone installer 由来のものがある場合は、管理元の整理を先に行い、重複導入しない。

```zsh
cd "$HOME/dotfiles"
make apps
```

対象は `Brewfile.macos` に記載した GUI アプリ・日本語 IME・Codex CLI のみ。既存のパッケージの upgrade と自動 cleanup は行わない。
旧 `Brewfile` を指定した `brew bundle` は実行しない。
すでに公式配布などでアプリを入れた場合は、その管理元を確認してから進め、強制的に置き換えない。

Office は `microsoft-word`・`microsoft-excel`・`microsoft-powerpoint`・`microsoft-outlook` の4つを個別に導入する。
個別版と競合する一括版 `microsoft-office` / `microsoft-office-businesspro` は使わない。OneDrive は導入せず、OneNote も今回は対象外とする。
初回起動時に Office の利用権がある Microsoft アカウントまたは大学・職場アカウントでサインインし、ライセンス認証を確認する。
Word・Excel・PowerPoint では新規ファイルの作成・保存・再読込を確認する。OneDrive 同期アプリは不要で、保存先にはローカルフォルダや既存の Dropbox フォルダを選べる。
Outlook のメールアカウント追加と認証は本人が行う。Outlook 導入だけで macOS の既定のメール・カレンダーアプリは変更しない。

Codex CLI の導入後は、新しいターミナルで次を確認する。

```zsh
command -v codex
codex --version
cd "$HOME/dotfiles"
codex
```

`codex` が Homebrew の `bin` を指すことを確認し、初回起動時に **Sign in with ChatGPT** を選んで本人がログインする。
認証情報・セッション履歴は dotfiles や Nix store に含めない。Home Manager で `~/.codex` 全体を配置しない。

Google 日本語入力は `google-japanese-ime` cask が公式のパッケージインストーラーを実行する。
管理者認証や再ログインを求められた場合は、画面の案内に従う。
導入後は「システム設定」→「キーボード」→「テキスト入力」の「編集」で、Google 日本語入力が有効になっているか確認する。
入力メニューで「ひらがな（Google）」を選び、未確定の文字を Ctrl+J でひらがな、Ctrl+K でカタカナに変換できることを確認する。
キー設定は「ことえり」を基本に、旧 Mac で独自設定を使っていた場合は設定画面からエクスポート・インポートする。
ユーザー辞書も辞書ツールから書き出して新 Mac に取り込み、よく使う語を確認する。
辞書・学習履歴は個人データとして別途保管し、公開 Git や Nix store に追加しない。

Bizin Gothic は [公式 Releases](https://github.com/yuru7/bizin-gothic/releases) から通常版を取得し、Font Book でインストールする。
Ghostty が指定するファミリー名は `Bizin Gothic`。配色・ブロックカーソル・16pt・行高40%追加・リガチャ無効の既存設定を使う。

まず 1Password にログインし、必要な保管庫を開けることを確認する。
Chrome で必要な Google アカウントへ、Slack で必要なワークスペースへ、ChatGPT で利用するアカウントへログインする。
Dropbox にログインし、必要なフォルダの同期設定と同期状態を確認する。
同期や通知の許可は、画面を確認して本人が設定する。その他のアプリは必要になってから追加する。

## 6 最初の完了確認

```zsh
cd "$HOME/dotfiles"
make doctor
```

doctor はコマンドの解決先・アプリと Google 日本語入力の実体の存在・lock・公開鍵・開発ツールの有無、設定先の親パスと重複設定を確認する。
Google 日本語入力は `/Library/Input Methods/` または `~/Library/Input Methods/` の実体だけを調べ、入力ソースの有効化や変換動作は手動で確認する。
修復や認証テストはしない。配置先の個々のファイルの衝突は Home Manager の適用前チェックで確認する。
エージェント内の PATH は通常のターミナルと異なることがあるため、新 Mac の Terminal または Ghostty で実行する。

- Chrome で必要なサイトを開ける。
- Slack の目的のワークスペースを開き、既存の会話を読める。
- 1Password で必要な保管庫を開ける。
- ChatGPT アプリを開き、利用するアカウントでログインできる。
- Word・Excel・PowerPoint のライセンス認証が済み、選んだ保存先でファイルを作成・保存・再読込できる。
- Outlook を起動し、必要なメールアカウントを追加して既存メールを読める。
- `codex` が Homebrew の `bin` を指し、Codex CLI を起動して ChatGPT アカウントでログインできる。
- Dropbox にログインし、必要なフォルダの同期状態を確認できる。インストール完了とデータの同期完了は分けて確認する。
- Google 日本語入力で入力でき、Ctrl+J / Ctrl+K の変換と必要なユーザー辞書を使える。
- Ghostty が zsh で起動し、手動の `fish`、フォント、日本語表示、Cmd+T が使える。
- `ssh -T git@github.com` で自分のアカウントの認証成功を確認できる。
- [git-ssh.md](git-ssh.md)の gh ログイン手順を完了し、`gh auth status` を確認できる。
- `git lfs version` が動く。LFS を使うリポジトリのデータ取得は、そのプロジェクトの移行時に別途確認する。
- `make apply` をもう一度実行して、衝突や不要な更新なしに終了する。

## 更新と復旧

普段の設定変更は `make check` → `make apply`。
依存を更新する場合だけ `make update` を実行する。これは lock を更新し build を確認するが、自動では適用しない。
build に失敗した場合も lock の差分が残り得るので、確認してから採用・修正する。
適用後は `make doctor` と上の実操作を確認し、lock と構成を一緒にコミットする。

Codex CLI の更新は、必要なときに `brew upgrade --cask codex` を明示的に実行し、`codex --version` と起動を確認する。
`make update` は Nix の依存だけを更新する。Homebrew 管理の Codex CLI の版は `flake.lock` には固定されない。

以前の Home Manager 世代は `home-manager generations` で確認し、戻す世代の `activate` を実行する。
これは Home Manager の管理する設定・パッケージの復旧であり、GUI アプリやデータ・認証を巻き戻すものではない。
シェルに問題があれば Apple の Terminal で `/bin/zsh -f`、編集には `/usr/bin/vim -Nu NONE` を使う。

## 次の段階

連絡環境が使えるようになってから、整備済みの [Neovim](editors.md)、Python、HTML/CSS、TeX、Rust・Node、
GUI エディタ、研究データ・LumenCite を必要な順で移す。
Neovim のプラグイン lock など、アプリが書き換えるファイルは Nix store の読み取り専用設定と分けて設計する。
旧 Mac のデータ・研究環境は、移行先で実作業を確認するまで残す。

## 公式資料

- [Home Manager の standalone flake テンプレート](https://github.com/nix-community/home-manager/blob/release-26.05/templates/standalone/flake.nix)
- [Homebrew Bundle と更新を抑えるオプション](https://docs.brew.sh/Brew-Bundle-and-Brewfile)
- [Chrome の cask](https://formulae.brew.sh/cask/google-chrome)
- [Slack の cask](https://formulae.brew.sh/cask/slack)
- [Ghostty の cask](https://formulae.brew.sh/cask/ghostty)
- [1Password の cask](https://formulae.brew.sh/cask/1password)
- [ChatGPT の cask](https://formulae.brew.sh/cask/chatgpt)
- [Dropbox の cask](https://formulae.brew.sh/cask/dropbox)
- [Google 日本語入力の cask](https://formulae.brew.sh/cask/google-japanese-ime)
- [Google 日本語入力のキー設定](https://support.google.com/ime/japanese/answer/166764?hl=ja)
- [macOS の入力ソース設定](https://support.apple.com/ja-jp/guide/mac-help/mchlp1406/mac)
- [OpenAI 公式の Codex CLI 導入・更新手順](https://learn.chatgpt.com/docs/codex/cli)
- [Word の cask](https://formulae.brew.sh/cask/microsoft-word)
- [Excel の cask](https://formulae.brew.sh/cask/microsoft-excel)
- [PowerPoint の cask](https://formulae.brew.sh/cask/microsoft-powerpoint)
- [Outlook の cask](https://formulae.brew.sh/cask/microsoft-outlook)
- [Office for Mac のライセンス認証](https://support.microsoft.com/ja-jp/microsoft-365-activation-licensing/office-install/activate-office-for-mac)
