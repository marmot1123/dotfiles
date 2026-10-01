# このリポジトリで作業するエージェントへ

## 目的と前提

個人用dotfilesを整理し、新しいMacBook Proで研究・執筆・開発環境を再構築できるようにする。長期間十分に管理されていなかったため、既存ファイルをそのまま正解や完全なインストール一覧として扱わない。

方針の参考資料は、2026-09-26作成の `~/Downloads/macos-setup-plan.md`。これは設計案であり、Nix構成の実装・実機検証済み手順ではない。本ファイルに作業上の主要方針をまとめているため、参考資料が新Macに存在することを前提にしない。ユーザーの最新の指示と実際のローカル状態を優先する。

- 説明・ドキュメント・作業報告は原則日本語にする。
- 目的はすべてをNixに移すことではなく、各ツールの管理元と復元手順を明確にすること。
- 小さな変更単位で整理し、既存の操作上の好みと研究の継続性を保つ。
- この方針だけを根拠に、依頼範囲外の移行やソフトのインストールを一括実行しない。

## 作業前の確認と既存状態の保護

- 最初に `git status --short` と対象ファイルの差分を確認する。ユーザーの未コミット変更を上書き・巻き戻ししない。
- 本ファイル作成時には `.bash_profile` と `config/git/config` に既存の変更があった。以後もその時点の状態を確認する。
- 計画書の記述は現状と照合する。例えば計画書のGit認証設定はWSL向けだったが、作成時のローカル設定は `osxkeychain` に変更されている。
- 設定があることと、ツールがインストール済み・使用中であることを区別する。Brewfileだけから環境全体を推定しない。
- `config/nvim/` には独立した `.git` ディレクトリも存在する。親リポジトリの追跡状態と併せて確認し、勝手に削除したりサブモジュール化したりしない。
- 秘密鍵、APIキー、トークン、証明書、アプリDB、論文・添付ファイル、棚卸しレポートを公開Gitに追加しない。秘密情報をNix式や生成ファイルにも埋め込まない。

## 現行Makefileの扱い

旧 Makefile の一括リンク・削除・Git pull は廃止した。
現在は引数なしの `make` / `make all` がヘルプ、`make list` が追跡ファイルの一覧を表示するだけ。
`install` / `deploy` / `clean` は変更せずにエラー終了する。`bootstrap` は手順を案内するだけ。
`init-lock` / `check` / `build` / `apply` / `update` は `scripts/home.sh`、`apps` は最小 GUI 一覧の `Brewfile.macos` を使う。
`doctor` は読み取り専用の確認。旧 Mac には Nix がないため、flake.lock の生成・Nix の評価と build・Home Manager の実適用は未検証。
実行ラッパーの停止条件等は仮のコマンドで検証するが、Nix 本体の検証済みとは扱わない。

旧版には次の問題があったため、そのまま復活させない。

- `EXCLUDIONS` の定義と `EXCLUSIONS` の参照が不一致で、`.git` 等の除外が効かなかった。
- `deploy` はバックアップなしの `ln -sfnv`、`clean` はホーム側の対象の `rm -vrf` を行っていた。
- `install` は `git pull` を含み、更新と適用が混ざっていた。
- 対象はルートの `.??*` のみで、`config/` 以下を `~/.config/` に配置できなかった。

ホーム側の `.git` や既存設定を、dotfiles由来と推測して削除しない。リンク先・実体・所有する管理方式を確認する。Makefileの検証が必要なら一時ディレクトリと仮の配置先を用い、実ホームへ適用しない。

## 目標とする管理分担

| 対象 | 方針 |
| --- | --- |
| 共通CLI・ユーザー設定 | Nix Flakes + standalone Home Managerを中心に、必要なものから導入 |
| GUIアプリ・macOS固有の例外 | Brewfileまたは公式配布。実際に使うものを棚卸しして選ぶ |
| Xcode Command Line Tools・Xcode | Appleの配布経路を使い、必要な手動工程を記録 |
| 言語環境・プロジェクト依存 | 各プロジェクトの版指定とlock fileを正本にする |
| TeX | 当面は現在に近いTeX Live/MacTeXを維持し、Nix移行と分離 |
| macOSのシステム設定 | 必要な設定が具体化してから最小限のnix-darwinを検討 |
| データ・認証 | dotfilesとは別のバックアップと移行チェックリストで管理 |

同じ役割のツールをNixとHomebrewで重複管理しない。ただしOS標準ツールやcaskの依存formulaを機械的に削除しない。実際に解決されるコマンドとPATHを確認する。

Home Managerを後からnix-darwinへ統合する場合は、standaloneと同じ設定を二重にactivateしない。Brewfileとnix-darwinでもcask一覧を二重管理しない。

## 構成と実装方針

現在の主な設定は、ルートの `.zshrc`、`.bash_profile`、`.vimrc`、`.tmux.conf`、`.latexmkrc` と、`config/git/`、`config/nvim/`、`config/fish/` にある。READMEはまだ最小限で、共通のテスト基盤はない。

現在 `flake.nix`、`home/default.nix`、`home/macos.nix`、操作別の `scripts/`、`docs/macos-setup.md` に最小構成を用意している。
`flake.lock` は Nix がある環境で実際に生成・検証する。以下は最終形の候補であり、すべて実装済みという意味ではない:

```text
flake.nix / flake.lock
home/default.nix
home/macos.nix
config/{git,nvim,fish,zsh,tmux}/
Brewfile
scripts/bootstrap-macos.sh
scripts/doctor.sh
docs/macos-setup.md
docs/manual-steps.md
Makefile
```

- `home/linux.nix` や `darwin/` は、具体的な対象・必要性ができてから追加する。
- NeovimのLua等は元の形式を保ち、Home Managerで配置と依存を管理する。不要なNix DSLへの全面翻訳は避ける。
- OS共通設定とOS固有設定を分ける。個人の絶対パスや特定のTeX年度・CPU構成を不用意に新設定へ引き継がない。
- ログインシェルとGhosttyの起動シェルはApple標準の `/bin/zsh`。普段の作業ではユーザーが `fish` を手動で起動する。fishの自動起動は設定しない。基本言語は英語（`LANG=en_US.UTF-8`）。これらとキーバインド、Finder/Dock等の好みを勝手に変更しない。
- Nix/Home Managerの互換性、パッケージ名、インストーラーの手順は実装時に公式資料で確認する。計画書のバージョン候補や推奨インストーラーを永続的な決定として扱わない。
- `flake.lock` は実際に生成し、`flake.nix` とともに追跡する。revisionやhashを捏造しない。
- NixのlockがOS・SDK・GUIアプリ・研究データ・数値結果まで固定すると説明しない。既存の `Brewfile.lock.json` も過去版を完全復元する保証として扱わない。

## 適用・更新・診断の分離

操作の契約は次のとおり。最小構成の具体的なコマンドと未検証事項は `docs/macos-setup.md` を参照する。

- `apply`: 検証済みlockから適用する。Git pull、flake update、brew upgrade、自動cleanupを含めない。
- `update`: 明示的に依存の版を更新し、build・doctor・代表的な実作業を確認する。設定適用と混同しない。
- `doctor`: 不足、競合、コマンドの解決先、残る手動作業を表示する。勝手に修復・インストールしない。
- `bootstrap`: 既存のNix/Homebrewと前提条件を検出し、再インストールを避ける。SSH鍵なしでもHTTPSから開始できるようにする。

当面の bootstrap は手動手順の案内のみ。初回の lock 生成は `init-lock`、GUI アプリの導入は `apps` として、通常の `apply` から分離する。
最初の新 Mac 構成は 1Password・Chrome・Slack・Ghostty・ChatGPT・Dropbox と共通 CLI・設定に絞り、Neovim・Python・TeX・研究データは次の段階で移す。

配置処理は冪等にし、既存ファイルとの衝突時には停止して対象を示す。バックアップは元のパスと復元方法を記録し、再実行で上書きしない。通常適用で自動削除やGCを行わず、移行が安定するまで旧世代を残す。

ログイン、二要素認証、鍵・証明書の取り込み、macOSの権限付与、クラウド同期確認は手動工程として記録する。設定のロールバックでデータやアプリの状態まで戻せると扱わない。

## 個別環境で守ること

- **シェル**: PATHの重複とOS混在を整理し、任意の初期化ファイルは存在確認して読む。シェルごとに `ssh-agent` を増やさず、macOSの既存エージェントを基本にする。GNU向け `ls` エイリアスは解決先と整合させる。
- **Vim / Neovim**: VimはApple標準のVimで使える、外部プラグインに依存しない最小構成にする。Neovimは主用途に合わせて段階的に拡張する。両方とも挿入モードの `jk` → Escを維持し、既定のインデントはスペース4個とする。ファイルタイプ・プロジェクト固有の指定を尊重する。構成と復旧方法は `docs/editors.md` に記録する。
- **Git**: 認証ヘルパーをOS別に扱う。参照される `.gitignore_global` の配置とGit LFSの依存を確認する。 GitHubのGit操作はSSH公開鍵認証を基本とし、新しいMacでは端末専用のパスフレーズ付きEd25519鍵を早期に新規作成する。鍵生成・公開鍵登録は本人の手動工程として `docs/git-ssh.md` に記録する。SSH設定は `config/ssh/config` で管理し、秘密鍵・ghの認証情報はGitに追加しない。
- **tmux**: 旧式の色・属性指定を `*-style` 形式へ整理する際も、`C-k` プレフィックス、分割・移動キー等の好みを保つ。
- **Rust / Node**: Rustはまずrustupを管理元とする案を基本にし、HomebrewのRustやNixのrustc/cargoと通常環境で重ねない。toolchain・Node・pnpmの版とlockはプロジェクトで管理し、共同開発者にNixを必須化しない。
- **Python**: 新規プロジェクトはuv・`pyproject.toml`・`uv.lock`・`.venv`を基本案とする。既存のConda環境は研究の移行が済むまで保持し、共同研究の指定を尊重する。
- **TeX**: 現行のpLaTeX + dvipdfmxによる文書をまず再現する。移行とエンジン変更を同時に行わない。フォントと個人のtexmfも棚卸しし、エンジン指定は可能な限りプロジェクト側へ置く。
- **LumenCite**: 本体の配布・開発環境と、DB・添付PDF・MCP接続・キーチェーン等の移行を分ける。アプリが起動するだけで移行完了としない。

## 進め方と検証

1. 旧Macの実態を読み取り中心で棚卸しし、データのバックアップを別途確保する。計画書にある `inventory-mac.sh` は存在と内容を確認してから使い、実行結果を自動コミットしない。
2. 危険なMakefileの動作を置き換え、小さなHome Manager構成でGit・シェル・Neovim・tmuxを検証する。
3. 言語環境、TeX、GUIアプリ、データ・認証を段階的に移す。実装した手順と手動工程をREADMEや `docs/` に反映する。
4. 移行先で代表的な実作業ができることを確認するまで、旧Macのデータ・必要な環境を保持する。

検証は変更範囲に合わせて選ぶ。シェルは対象インタープリターで構文検査し、macOS標準の `/bin/bash` を使うならBash 3.2互換性を保つ。配置処理は一時ディレクトリで衝突・バックアップ・再実行を確認する。Nix導入後はcheck/buildを行い、実環境への適用と区別する。tmuxやNeovimの起動確認で既存セッションを操作しない。

移行の完了条件は、ターミナル初期化、意図したコマンドの解決、Git認証とLFS、エディタ・tmux起動、日本語文書・英語論文のビルド、代表的なPython計算、LumenCiteの必要なビルド・データ・MCP連携、およびbootstrap/apply再実行の安全性。関係する項目を実機で確認する。

作業報告では変更内容、実行した検証、未検証事項と残る手動工程を明確にする。構文検査・CI・モックの成功を、macOS実機、GUI、権限、同期、研究結果の検証済みと読み替えない。
