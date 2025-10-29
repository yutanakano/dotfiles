#!/bin/sh
set -e

CURRENT="$(cd "$(dirname "$0")" && pwd)"

echo "dotfilesをセットアップしています"

# 必要なディレクトリを作成
echo "必要なディレクトリを作成しています"
mkdir -p ~/.ssh
mkdir -p ~/.config/tmux
mkdir -p ~/.config/zellij
mkdir -p ~/.gitmoji

# ssh
echo "SSH設定をリンクしています"
ln -nfs "$CURRENT"/.ssh/config ~/.ssh/config || { echo "エラー: SSH設定のリンクに失敗しました"; exit 1; }

# tmux
echo "tmux設定をリンクしています"
ln -nfs "$CURRENT"/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf || { echo "エラー: tmux設定のリンクに失敗しました"; exit 1; }
ln -nfs "$CURRENT"/.config/tmux/quad.sh ~/.config/tmux/quad.sh || { echo "エラー: tmux quad.shのリンクに失敗しました"; exit 1; }
ln -nfs "$CURRENT"/.config/tmux/editer.sh ~/.config/tmux/editer.sh || { echo "エラー: tmux editer.shのリンクに失敗しました"; exit 1; }

# zellij
echo "zellijレイアウトをリンクしています"
ln -nfs "$CURRENT"/.config/zellij/layouts ~/.config/zellij/layouts || { echo "エラー: zellijレイアウトのリンクに失敗しました"; exit 1; }

# starship
echo "starship設定をリンクしています"
ln -nfs "$CURRENT"/.config/starship.toml ~/.config/starship.toml || { echo "エラー: starship設定のリンクに失敗しました"; exit 1; }

# mise
echo "mise設定をリンクしています"
ln -nfs "$CURRENT"/.config/mise ~/.config/mise || { echo "エラー: mise設定のリンクに失敗しました"; exit 1; }

# .zshrc
echo ".zshrcをリンクしています"
ln -nfs "$CURRENT"/.zshrc ~/.zshrc || { echo "エラー: .zshrcのリンクに失敗しました"; exit 1; }

# .Brewfile
echo ".Brewfileをリンクしています"
ln -nfs "$CURRENT"/.Brewfile ~/.Brewfile || { echo "エラー: .Brewfileのリンクに失敗しました"; exit 1; }

# .gitconfig
if [ ! -f ~/.gitconfig ]; then
    echo ".gitconfigをセットアップしています"
    cp "$CURRENT"/.gitconfig.template ~/.gitconfig || { echo "エラー: .gitconfigテンプレートのコピーに失敗しました"; exit 1; }
    read -p "名前を入力してください: " git_name
    read -p "メールアドレスを入力してください: " git_email
    sed -i.bak "s/YOUR_NAME/$git_name/" ~/.gitconfig || { echo "エラー: 名前の更新に失敗しました"; exit 1; }
    sed -i.bak "s/YOUR_EMAIL/$git_email/" ~/.gitconfig || { echo "エラー: メールアドレスの更新に失敗しました"; exit 1; }
    rm ~/.gitconfig.bak
    echo ".gitconfigを作成しました"
else
    echo ".gitconfigは既に存在します。スキップします"
fi

# .gitmoji
echo "gitmoji設定をリンクしています"
ln -nfs "$CURRENT"/.gitmoji/gitmojis.json ~/.gitmoji/gitmojis.json || { echo "エラー: gitmoji設定のリンクに失敗しました"; exit 1; }

echo "dotfilesのセットアップが完了しました"
