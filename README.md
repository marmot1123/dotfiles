# dotfiles

macOS の研究・執筆・開発環境を、既存の作業を保ちながら段階的に整理する。

- [新しい Mac の SSH 鍵作成・GitHub 認証](docs/git-ssh.md)
- [シェルの構成・確認・復旧手順](docs/shells.md)
- [Vim・Neovim の使い分けと基本設定](docs/editors.md)
- [新しい Mac の最小セットアップ](docs/macos-setup.md)

Ghostty・Apple のターミナルともに Apple の zsh で起動する。
普段の作業では必要に応じて `fish` と入力し、手動で切り替える。
Nix / standalone Home Manager の最小構成と、検証・適用を分けるスクリプトを用意した。
旧 Mac に Nix がないため、lock の生成・Nix の評価と build・新 Mac への実適用は未検証。
新 Mac で `make init-lock` → `make check` → `make apply` と進める。lock が既にある場合は `init-lock` を省略する。
`make` / `make all` はヘルプ表示のみ。古い一括リンク・削除・Git pull は廃止し、`install` / `deploy` / `clean` は停止する。

## 新しい Mac に向けた優先順位

最初の目標は **Chrome・Slack で連絡が取れ、1Password・ChatGPT・Dropbox・ターミナル・Git が使える状態**。
細かな操作や追加プラグインの調整は後に回す。

1. **初期設定と認証**: 新 Mac の既存設定・データの移行状況を確認し、端末専用の SSH 鍵を作成・登録する。
2. **設定の配置と管理元**: Nix / Home Manager で共通 CLI と設定を管理し、生成した lock を build で検証して適用する。
3. **連絡と基本操作**: `Brewfile.macos` で 1Password・Chrome・Slack・Ghostty・ChatGPT・Dropbox を導入し、フォント、ログイン、同期、GitHub 認証を確認する。
4. **開発と研究環境**: Neovim・Python・TeX・その他の GUI アプリ・LumenCite のデータと認証を必要な順で移す。

シェル・Ghostty・Git/SSH・エディタの基本設定は、このリポジトリで整備中。
旧 Mac での検証と、新 Mac での動作確認は区別する。
移行前に必要な変更をコミット・公開し、新 Mac で取得した版に設定と lock file が含まれることを確認する。

旧 `Brewfile` は履歴用に残し、新 Mac の一括導入には使わない。
GUI アプリは確認済みの最小一覧 `Brewfile.macos` を `make apps` で導入する。
旧 Mac の研究データ・既存環境は、新 Mac で代表的な作業を確認するまで保持する。

スクリプトの検証は `python3 tests/test_setup.py`。これは Nix / Homebrew を仮のコマンドに置き換える検証で、実機の build・適用・ログインを保証するものではない。
