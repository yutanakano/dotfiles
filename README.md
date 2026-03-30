# dotfiles

個人用のdotfiles管理リポジトリです。zsh、tmux、zellij、starship、miseなどの設定ファイルを一元管理します。

## 要件

- POSIX互換のシェル（sh, bash, zsh等）
- 対応OS: macOS, Linux
- Git
- [GNU Stow](https://www.gnu.org/software/stow/) (`brew install stow`)

## インストール

```sh
# リポジトリをクローン
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# セットアップを実行
sh init.sh
```

初回実行時にGit設定（名前とメールアドレス）の入力を求められます。

## 管理している設定ファイル

- **zsh** (`.zshrc`) - シェル設定
- **tmux** - ターミナルマルチプレクサ設定
- **zellij** - モダンなターミナルワークスペース
- **starship** - クロスシェルプロンプト
- **mise** - ランタイムバージョンマネージャー
- **SSH** - SSH設定
- **Homebrew** (`.Brewfile`) - パッケージ管理
- **gitmoji** - Gitコミット絵文字設定

## 使い方

### セットアップ
```sh
sh init.sh
```

### アンインストール
```sh
cd ~/dotfiles
stow -D -t "$HOME" src
```

### Dry-Run（実行内容の確認）
```sh
cd ~/dotfiles
stow -t "$HOME" --simulate -v src
```

## 既存ファイルがある場合

リンク先に通常のファイルやディレクトリが既に存在する場合、stowがコンフリクトを検出してエラーになります。既存ファイルを削除またはバックアップしてから再実行してください。

既存ファイルをリポジトリに取り込みたい場合は `stow --adopt` が使えます（詳細は `man stow` を参照）。

## テスト

```sh
sh init.test.sh
```

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。