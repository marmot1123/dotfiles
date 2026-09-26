# dotfiles

macOS の研究・執筆・開発環境を、既存の作業を保ちながら段階的に整理する。

- [新しい Mac の SSH 鍵作成・GitHub 認証](docs/git-ssh.md)
- [シェルの構成・確認・復旧手順](docs/shells.md)

Ghostty・Apple のターミナルともに Apple の zsh で起動する。
普段の作業では必要に応じて `fish` と入力し、手動で切り替える。
Nix / Home Manager による管理と安全な汎用配置処理はまだ未実装。
現行 Makefile の install / deploy / clean は使わない。
