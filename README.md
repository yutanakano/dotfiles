# dotfiles

macOS用のdotfile管理リポジトリ / Dotfiles management repository for macOS

## 📝 概要 / Overview

このリポジトリは、macOSで使用する設定ファイル（dotfiles）を管理するためのものです。シェル、Git、Vimなどの基本的な設定が含まれています。

This repository manages configuration files (dotfiles) for macOS. It includes basic configurations for shell, Git, Vim, and more.

## 📦 含まれるファイル / Included Files

- `.zshrc` - Zsh設定ファイル / Zsh configuration
- `.bash_profile` - Bash設定ファイル / Bash configuration
- `.gitconfig` - Git設定ファイル / Git configuration
- `.gitignore_global` - グローバルgitignoreファイル / Global gitignore
- `.vimrc` - Vim設定ファイル / Vim configuration

## 🚀 インストール / Installation

### 前提条件 / Prerequisites

- macOS
- Git

### インストール手順 / Installation Steps

1. このリポジトリをクローンします / Clone this repository:

```bash
git clone https://github.com/yutanakano/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. インストールスクリプトを実行します / Run the installation script:

```bash
./install.sh
```

3. `.gitconfig`を編集して、名前とメールアドレスを設定します / Edit `.gitconfig` to set your name and email:

```bash
vim ~/.gitconfig
```

4. ターミナルを再起動するか、設定を再読み込みします / Restart your terminal or reload the configuration:

```bash
# Zshを使用している場合 / If using Zsh:
source ~/.zshrc

# Bashを使用している場合 / If using Bash:
source ~/.bash_profile
```

## ✨ 機能 / Features

### シェル設定 / Shell Configuration

- 日本語環境の設定 / Japanese language support
- Homebrewのパス設定（Apple Silicon対応） / Homebrew path configuration (Apple Silicon support)
- 便利なエイリアス / Useful aliases
- コマンド履歴の設定 / Command history configuration
- カラフルなプロンプト / Colorful prompt

### Git設定 / Git Configuration

- グローバルgitignore / Global gitignore
- 便利なGitエイリアス / Useful Git aliases
- カラー表示 / Color output
- デフォルトブランチ名を`main`に設定 / Default branch name set to `main`

### Vim設定 / Vim Configuration

- シンタックスハイライト / Syntax highlighting
- 行番号表示 / Line numbers
- インデント設定 / Indentation settings
- クリップボード連携（macOS） / Clipboard integration (macOS)
- ファイルタイプ別の設定 / File type specific settings

## 🔧 カスタマイズ / Customization

必要に応じて、各dotfileを直接編集してカスタマイズできます。

You can customize each dotfile by editing them directly as needed.

```bash
cd ~/dotfiles
vim .zshrc
```

変更を適用するには、ターミナルを再起動するか、設定ファイルを再読み込みしてください。

To apply changes, restart your terminal or reload the configuration file.

## 📚 主なエイリアス / Common Aliases

### ファイル操作 / File Operations

- `ll` - `ls -lh` (詳細リスト表示)
- `la` - `ls -lAh` (隠しファイルを含む詳細リスト表示)
- `..` - `cd ..` (親ディレクトリへ移動)
- `...` - `cd ../..` (2階層上へ移動)

### Gitコマンド / Git Commands

- `gs` - `git status`
- `ga` - `git add`
- `gc` - `git commit`
- `gp` - `git push`
- `gl` - `git log --oneline`
- `gd` - `git diff`

## 🛠️ トラブルシューティング / Troubleshooting

### 既存の設定ファイルがある場合 / If you have existing configuration files

インストールスクリプトは、既存のファイルがある場合にバックアップを作成します。バックアップファイルには `.backup.YYYYMMDD_HHMMSS` という拡張子が付きます。

The installation script will create backups if existing files are found. Backup files will have the extension `.backup.YYYYMMDD_HHMMSS`.

### シンボリックリンクを削除したい場合 / To remove symlinks

```bash
rm ~/.zshrc ~/.bash_profile ~/.gitconfig ~/.gitignore_global ~/.vimrc
```

## 📄 ライセンス / License

MIT License - 詳細は[LICENSE](LICENSE)ファイルを参照してください / See [LICENSE](LICENSE) file for details.

## 🤝 コントリビューション / Contributing

プルリクエストを歓迎します！ / Pull requests are welcome!

## 📮 連絡先 / Contact

問題や質問がある場合は、GitHubのIssuesで報告してください。

If you have any issues or questions, please report them on GitHub Issues.