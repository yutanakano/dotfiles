#!/bin/sh
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# stowがインストールされているか確認
if ! command -v stow >/dev/null 2>&1; then
    echo "エラー: stowがインストールされていません"
    echo "  brew install stow でインストールしてください"
    exit 1
fi

# stowのtree foldingで丸ごとリンクされるのを防ぐ
# ~/.sshがリンクになるとssh-keygenの秘密鍵がリポジトリに入るリスクがある
[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"
[ ! -d "$HOME/.ssh" ] && mkdir -p "$HOME/.ssh"
[ ! -d "$HOME/.config/yazi" ] && mkdir -p "$HOME/.config/yazi"

# stowでシンボリックリンクを作成
echo "dotfilesをセットアップしています"
stow -t "$HOME" -d "$DOTFILES_DIR" src

# Yaziプラグイン・テーマのインストール
if command -v ya >/dev/null 2>&1; then
    echo "Yaziプラグインをインストールしています"
    ya pkg install || echo "警告: Yaziプラグインのインストールに失敗しました"
else
    echo "yaziがインストールされていません。Yaziプラグインのインストールをスキップします"
fi

# .gitconfig
validate_not_empty() {
    [ -n "$1" ]
}

validate_email() {
    echo "$1" | grep -q "@"
}

if [ ! -f ~/.gitconfig ]; then
    echo ".gitconfigをセットアップしています"
    cp "$DOTFILES_DIR/templates/.gitconfig" ~/.gitconfig || { echo "エラー: .gitconfigテンプレートのコピーに失敗しました"; exit 1; }

    # 名前の入力（空でないことを検証）
    git_name=""
    while ! validate_not_empty "$git_name"; do
        read -p "名前を入力してください: " git_name
        if ! validate_not_empty "$git_name"; then
            echo "エラー: 名前を入力してください"
        fi
    done

    # メールアドレスの入力（形式を検証）
    git_email=""
    while ! validate_not_empty "$git_email" || ! validate_email "$git_email"; do
        read -p "メールアドレスを入力してください: " git_email
        if ! validate_not_empty "$git_email"; then
            echo "エラー: メールアドレスを入力してください"
        elif ! validate_email "$git_email"; then
            echo "エラー: 有効なメールアドレスを入力してください（@を含む必要があります）"
        fi
    done

    sed -i.bak "s|YOUR_NAME|$git_name|" ~/.gitconfig || { echo "エラー: 名前の更新に失敗しました"; exit 1; }
    sed -i.bak "s|YOUR_EMAIL|$git_email|" ~/.gitconfig || { echo "エラー: メールアドレスの更新に失敗しました"; exit 1; }
    rm ~/.gitconfig.bak
    echo ".gitconfigを作成しました"
else
    echo ".gitconfigは既に存在します。スキップします"
fi

echo "dotfilesのセットアップが完了しました"
