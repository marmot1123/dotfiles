# GitHub の SSH 認証と新しい Mac の初期設定

GitHub の Git 操作は SSH 公開鍵認証を基本とする。
新しい Mac では、その Mac 専用のパスフレーズ付き Ed25519 鍵を新しく作る。
鍵の作成・登録は、Homebrew、Nix、fish の導入より先に行える。
旧 Mac の秘密鍵をコピーすることは前提にしない。

## 管理する設定

| 対象 | 管理方法 |
| --- | --- |
| SSH の接続設定 | `config/ssh/config` を `~/.ssh/config` に配置 |
| SSH 秘密鍵・公開鍵 | 各 Mac の `~/.ssh/`。dotfiles に追加しない |
| 鍵のパスフレーズ | 本人が入力し、macOS Keychain に保存 |
| GitHub の公開鍵登録 | ブラウザで本人が登録・確認 |
| `gh` の Git 接続方式 | `gh config set git_protocol ssh --host github.com` |
| `gh` の API 認証 | `gh auth login` で各 Mac の資格情報ストアに保存 |

GitHub では `~/.ssh/id_ed25519` を明示し、`IdentitiesOnly yes` で
エージェント内の無関係な鍵を試さないようにする。
`PreferredAuthentications publickey` で公開鍵認証を使う。
`UseKeychain yes` と `AddKeysToAgent yes` で既存の macOS のエージェントを利用し、
シェル起動のたびに `ssh-agent` を増やさない。

Git の HTTPS 用 `credential.helper = osxkeychain` と SSH 認証は別の仕組み。
HTTPS が必要な接続を壊さないように、認証ヘルパーを一括削除したり、
すべての HTTPS URL を SSH へ自動変換したりはしない。
Git LFS の通信・認証も通常の Git の SSH 認証とは分けて確認する。

## 新しい Mac で最初に行うこと

以下は Apple のターミナルで `/bin/zsh` を使って行う。
鍵を作る前に、GitHub へブラウザでログインできることを確認する。
パスフレーズはターミナルの対話入力にのみ入力し、チャット・設定ファイル・コマンド引数には書かない。

### 1. その Mac 専用の鍵を作る

次の処理は同名の鍵やリンクがあれば作成を止める。
既存の鍵が見つかった場合は、その用途を確認してから進める。
コメントの `github-new-macbook` は、後で端末を区別できる名前にしてよい。

```zsh
(
umask 077
mkdir -p "$HOME/.ssh"
if [[ -e "$HOME/.ssh/id_ed25519" || -L "$HOME/.ssh/id_ed25519" ||
      -e "$HOME/.ssh/id_ed25519.pub" || -L "$HOME/.ssh/id_ed25519.pub" ]]; then
  print -u2 '既存の鍵があります。上書きせず、用途を確認してください。'
else
  /usr/bin/ssh-keygen -t ed25519 -C "github-new-macbook" -f "$HOME/.ssh/id_ed25519"
fi
)
```

新規作成時はパスフレーズを設定する。秘密鍵は `id_ed25519`、公開鍵は `id_ed25519.pub`。
新しい鍵を作成できたことを確認してから次に進む。

### 2. macOS のエージェントと Keychain に登録する

```zsh
/usr/bin/ssh-add -l
/usr/bin/ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
```

最初のコマンドで「鍵がない」と表示されても、エージェントには接続できている。
エージェント自体に接続できない場合は、通常の GUI ログインから開いたターミナルで
`SSH_AUTH_SOCK` を確認する。シェル設定に `eval "$(ssh-agent)"` は追加しない。
Apple 標準の `/usr/bin/ssh-add` を使う。

### 3. 公開鍵を GitHub に登録する

```zsh
pbcopy < "$HOME/.ssh/id_ed25519.pub"
```

[GitHub の SSH keys 設定](https://github.com/settings/keys) で「New SSH key」を選び、
Key type は「Authentication Key」とする。端末名・作成時期が分かる Title を付け、
コピーした公開鍵を登録する。
旧 Mac を使っている間は、旧 Mac の鍵を削除しない。

### 4. SSH 接続を確認する

dotfiles の配置前でも、使用する鍵を直接指定して確認できる。

```zsh
/usr/bin/ssh -T -o IdentitiesOnly=yes -i "$HOME/.ssh/id_ed25519" git@github.com
```

初回接続で表示されるホスト鍵の指紋は、
[GitHub 公式の SSH key fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
と照合してから承認する。ホスト鍵の確認を無効にはしない。
認証成功の表示に、自分の GitHub ユーザー名が出ることを確認する。
GitHub はシェルを提供しないため、`ssh -T` は認証成功でも終了コード1を返す。

### 5. dotfiles の取得と SSH 設定の配置

ここからは Git が必要。Apple の Command Line Tools が未導入なら、Apple の手順で導入する。
まだ `~/dotfiles` がない場合に取得する。

```zsh
git clone git@github.com:marmot1123/dotfiles.git "$HOME/dotfiles"
```

`~/.ssh/config` の実体・リンク先を確認する。
配置先が存在しない場合だけ、次でリンクを作れる。
既存の設定がある場合は上書きせず、元のパスを記録したバックアップを作り、
他の接続先の設定を保持してから統合する。`ln -sf` や現行 Makefile は使わない。

```zsh
ln -s "$HOME/dotfiles/config/ssh/config" "$HOME/.ssh/config"
/usr/bin/ssh -G git@github.com
/usr/bin/ssh -T git@github.com
git -C "$HOME/dotfiles" ls-remote origin HEAD
```

`ssh -G` では `user git`、`identitiesonly yes`、
`preferredauthentications publickey`、`identityfile ~/.ssh/id_ed25519` を確認する。
SSH クライアントの参照先は `command -v ssh` で確認し、macOS では `/usr/bin/ssh` を基本とする。

### 6. GitHub CLI 導入後の設定

`gh` を導入したら、ブラウザで API 利用の認証を行う。
公開鍵は登録済みなので、`gh` による新規生成・アップロードは省略する。

```zsh
gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key
gh config set git_protocol ssh --host github.com
gh config get git_protocol --host github.com
gh auth status --hostname github.com
```

`gh repo clone OWNER/REPO` では SSH を使う。
PR・Issue などの GitHub API 操作には別途 OAuth トークンが必要で、
`git_protocol = ssh` にしても API 認証が SSH 鍵に置き換わるわけではない。
`~/.config/gh/hosts.yml` や資格情報ストアは dotfiles に追加しない。

## 既存リポジトリの接続方式

既存リポジトリの URL は `gh` の設定変更だけでは切り替わらない。
各リポジトリで `git remote -v` を確認し、GitHub の HTTPS URL を変更する必要がある場合のみ、
対応する SSH URL に変更する。

```zsh
git remote set-url origin git@github.com:OWNER/REPO.git
git ls-remote origin HEAD
```

この dotfiles の origin は既に SSH URL。その他のリポジトリは一括変更していない。
SSH 認証確認・`ls-remote` は、Git LFS の取得、push 権限、コミット署名の検証とは別。
コミット署名は必要性を決めてから別の設定として扱う。

## 鍵の方式

GitHub 公式が案内する通常の Ed25519 鍵を採用する。
物理セキュリティキーを導入する場合は `ed25519-sk` などを改めて検討する。
Web ログイン用のパスキーと、Git の SSH 公開鍵認証は用途が異なる。
OpenSSH の耐量子鍵交換も、ユーザー認証用の Ed25519 鍵とは別の機能。

## 参考

- [GitHub: SSH 鍵の作成と macOS Keychain](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=mac)
- [GitHub: SSH 接続の確認](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection)
- [GitHub CLI: 認証](https://cli.github.com/manual/gh_auth_login)
- [GitHub CLI: 設定](https://cli.github.com/manual/gh_config_set)
- [GitHub: パスキー](https://docs.github.com/en/authentication/authenticating-with-a-passkey/about-passkeys)
- [OpenSSH: 耐量子暗号と鍵交換](https://www.openssh.org/pq.html)
