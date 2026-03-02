#!/bin/sh
set -e

CURRENT="$(cd "$(dirname "$0")" && pwd)"

# dry-runモードのチェック
DRY_RUN=0
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=1
    echo ""
    echo "=== DRY RUN モード ==="
    echo "実際には変更を行わず、実行内容のみを表示します"
    echo ""
fi

# 検証関数
validate_not_empty() {
    [ -n "$1" ]
}

validate_email() {
    echo "$1" | grep -q "@"
}

echo "dotfilesをセットアップしています"

# 必要なディレクトリを作成
echo "必要なディレクトリを作成しています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] mkdir -p ~/.ssh"
    echo "  [DRY RUN] mkdir -p ~/.config/tmux"
    echo "  [DRY RUN] mkdir -p ~/.config/zellij"
    echo "  [DRY RUN] mkdir -p ~/.gitmoji"
else
    mkdir -p ~/.ssh
    mkdir -p ~/.config/tmux
    mkdir -p ~/.config/zellij
    mkdir -p ~/.gitmoji
fi

# ssh
echo "SSH設定をリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.ssh/config ~/.ssh/config"
    echo "  [DRY RUN] chmod 600 ~/.ssh/config"
else
    ln -nfs "$CURRENT"/.ssh/config ~/.ssh/config || { echo "エラー: SSH設定のリンクに失敗しました"; exit 1; }
    chmod 600 ~/.ssh/config
fi

# tmux
echo "tmux設定をリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf"
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/tmux/quad.sh ~/.config/tmux/quad.sh"
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/tmux/editer.sh ~/.config/tmux/editer.sh"
else
    ln -nfs "$CURRENT"/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf || { echo "エラー: tmux設定のリンクに失敗しました"; exit 1; }
    ln -nfs "$CURRENT"/.config/tmux/quad.sh ~/.config/tmux/quad.sh || { echo "エラー: tmux quad.shのリンクに失敗しました"; exit 1; }
    ln -nfs "$CURRENT"/.config/tmux/editer.sh ~/.config/tmux/editer.sh || { echo "エラー: tmux editer.shのリンクに失敗しました"; exit 1; }
fi

# zellij
echo "zellijレイアウトをリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/zellij/layouts ~/.config/zellij/layouts"
else
    ln -nfs "$CURRENT"/.config/zellij/layouts ~/.config/zellij/layouts || { echo "エラー: zellijレイアウトのリンクに失敗しました"; exit 1; }
fi

# starship
echo "starship設定をリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/starship.toml ~/.config/starship.toml"
else
    ln -nfs "$CURRENT"/.config/starship.toml ~/.config/starship.toml || { echo "エラー: starship設定のリンクに失敗しました"; exit 1; }
fi

# mise
echo "mise設定をリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/mise ~/.config/mise"
else
    ln -nfs "$CURRENT"/.config/mise ~/.config/mise || { echo "エラー: mise設定のリンクに失敗しました"; exit 1; }
fi

# .zshrc
echo ".zshrcをリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.zshrc ~/.zshrc"
else
    ln -nfs "$CURRENT"/.zshrc ~/.zshrc || { echo "エラー: .zshrcのリンクに失敗しました"; exit 1; }
fi

# .Brewfile
echo ".Brewfileをリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.Brewfile ~/.Brewfile"
else
    ln -nfs "$CURRENT"/.Brewfile ~/.Brewfile || { echo "エラー: .Brewfileのリンクに失敗しました"; exit 1; }
fi

# .gitconfig
if [ $DRY_RUN -eq 1 ]; then
    if [ ! -f ~/.gitconfig ]; then
        echo ".gitconfigをセットアップしています"
        echo "  [DRY RUN] cp $CURRENT/.gitconfig.template ~/.gitconfig"
        echo "  [DRY RUN] 名前とメールアドレスの入力をスキップ"
        echo "  [DRY RUN] sed -i.bak 's/YOUR_NAME/<入力された名前>/' ~/.gitconfig"
        echo "  [DRY RUN] sed -i.bak 's/YOUR_EMAIL/<入力されたメール>/' ~/.gitconfig"
        echo "  [DRY RUN] rm ~/.gitconfig.bak"
    else
        echo ".gitconfigは既に存在します。スキップします"
    fi
else
    if [ ! -f ~/.gitconfig ]; then
        echo ".gitconfigをセットアップしています"
        cp "$CURRENT"/.gitconfig.template ~/.gitconfig || { echo "エラー: .gitconfigテンプレートのコピーに失敗しました"; exit 1; }

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

        sed -i.bak "s/YOUR_NAME/$git_name/" ~/.gitconfig || { echo "エラー: 名前の更新に失敗しました"; exit 1; }
        sed -i.bak "s/YOUR_EMAIL/$git_email/" ~/.gitconfig || { echo "エラー: メールアドレスの更新に失敗しました"; exit 1; }
        rm ~/.gitconfig.bak
        echo ".gitconfigを作成しました"
    else
        echo ".gitconfigは既に存在します。スキップします"
    fi
fi

# .gitmoji
echo "gitmoji設定をリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.gitmoji/gitmojis.json ~/.gitmoji/gitmojis.json"
else
    ln -nfs "$CURRENT"/.gitmoji/gitmojis.json ~/.gitmoji/gitmojis.json || { echo "エラー: gitmoji設定のリンクに失敗しました"; exit 1; }
fi

echo "dotfilesのセットアップが完了しました"
