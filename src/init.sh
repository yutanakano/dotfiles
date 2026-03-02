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

# ロールバック用の記録ファイル
ROLLBACK_LOG=""
if [ $DRY_RUN -eq 0 ]; then
    ROLLBACK_LOG=$(mktemp)
fi

# クリーンアップ関数（エラー時のロールバック）
cleanup() {
    exit_code=$?
    if [ $exit_code -ne 0 ] && [ -n "$ROLLBACK_LOG" ] && [ -f "$ROLLBACK_LOG" ]; then
        echo ""
        echo "エラーが発生しました。変更をロールバックしています..."

        # 記録を逆順で読んで削除（後で作ったものから削除）
        if [ -s "$ROLLBACK_LOG" ]; then
            # tac がない環境用に tail -r も試す
            if command -v tac >/dev/null 2>&1; then
                tac "$ROLLBACK_LOG" | while IFS=: read -r type path; do
                    case "$type" in
                        LINK)
                            if [ -L "$path" ]; then
                                rm -f "$path"
                                echo "  削除: $path (シンボリックリンク)"
                            fi
                            ;;
                        DIR)
                            if [ -d "$path" ] && [ -z "$(ls -A "$path" 2>/dev/null)" ]; then
                                rmdir "$path" 2>/dev/null || true
                                echo "  削除: $path (空ディレクトリ)"
                            fi
                            ;;
                    esac
                done
            else
                tail -r "$ROLLBACK_LOG" 2>/dev/null | while IFS=: read -r type path; do
                    case "$type" in
                        LINK)
                            if [ -L "$path" ]; then
                                rm -f "$path"
                                echo "  削除: $path (シンボリックリンク)"
                            fi
                            ;;
                        DIR)
                            if [ -d "$path" ] && [ -z "$(ls -A "$path" 2>/dev/null)" ]; then
                                rmdir "$path" 2>/dev/null || true
                                echo "  削除: $path (空ディレクトリ)"
                            fi
                            ;;
                    esac
                done
            fi
        fi

        echo "ロールバックが完了しました"
    fi

    # 一時ファイルを削除
    if [ -n "$ROLLBACK_LOG" ] && [ -f "$ROLLBACK_LOG" ]; then
        rm -f "$ROLLBACK_LOG"
    fi
}

# エラー時とスクリプト終了時にクリーンアップを実行
trap cleanup EXIT

# 記録関数
record_dir() {
    if [ $DRY_RUN -eq 0 ] && [ -n "$ROLLBACK_LOG" ]; then
        echo "DIR:$1" >> "$ROLLBACK_LOG"
    fi
}

record_link() {
    if [ $DRY_RUN -eq 0 ] && [ -n "$ROLLBACK_LOG" ]; then
        echo "LINK:$1" >> "$ROLLBACK_LOG"
    fi
}

# 検証関数
validate_not_empty() {
    [ -n "$1" ]
}

validate_email() {
    echo "$1" | grep -q "@"
}

# エラーハンドリング関数
error_symlink() {
    source_file="$1"
    target_path="$2"
    operation="$3"

    echo ""
    echo "エラー: ${operation}のリンクに失敗しました"
    echo "  リンク元: $source_file"
    echo "  リンク先: $target_path"

    # エラーの原因を診断
    if [ ! -e "$source_file" ] && [ ! -L "$source_file" ]; then
        echo "  原因: リンク元ファイルが存在しません"
        echo "  解決策: リポジトリが正しくクローンされているか確認してください"
    elif [ ! -d "$(dirname "$target_path")" ]; then
        echo "  原因: リンク先のディレクトリが存在しません"
        echo "  解決策: ディレクトリを作成してから再実行してください"
    elif [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
        # ファイルの種類を判定
        if [ -d "$target_path" ]; then
            echo "  原因: リンク先に既存のディレクトリが存在します"
        else
            echo "  原因: リンク先に既存のファイル（通常ファイル）が存在します"
        fi
        echo "  解決策: 既存ファイルを削除またはバックアップしてから再実行してください"
    else
        echo "  原因: 不明（権限の問題の可能性があります）"
        echo "  解決策: ディレクトリの書き込み権限を確認してください"
    fi
    echo ""

    exit 1
}

# シンボリックリンク作成前チェック（既存の非シンボリックリンクファイルを検出）
check_before_symlink() {
    source_file="$1"
    target_path="$2"
    operation="$3"

    # ターゲットが存在し、かつシンボリックリンクでない場合はエラー
    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
        error_symlink "$source_file" "$target_path" "$operation"
    fi
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
    # 既存かどうか確認してから作成・記録
    [ ! -d ~/.ssh ] && mkdir -p ~/.ssh && record_dir "$HOME/.ssh"
    [ ! -d ~/.config/tmux ] && mkdir -p ~/.config/tmux && record_dir "$HOME/.config/tmux"
    [ ! -d ~/.config/zellij ] && mkdir -p ~/.config/zellij && record_dir "$HOME/.config/zellij"
    [ ! -d ~/.gitmoji ] && mkdir -p ~/.gitmoji && record_dir "$HOME/.gitmoji"
fi

# ssh
echo "SSH設定をリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.ssh/config ~/.ssh/config"
    echo "  [DRY RUN] chmod 600 ~/.ssh/config"
else
    check_before_symlink "$CURRENT/.ssh/config" "$HOME/.ssh/config" "SSH設定"
    ln -nfs "$CURRENT"/.ssh/config ~/.ssh/config || error_symlink "$CURRENT/.ssh/config" "$HOME/.ssh/config" "SSH設定"
    record_link "$HOME/.ssh/config"
    chmod 600 ~/.ssh/config
fi

# tmux
echo "tmux設定をリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf"
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/tmux/quad.sh ~/.config/tmux/quad.sh"
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/tmux/editer.sh ~/.config/tmux/editer.sh"
else
    check_before_symlink "$CURRENT/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf" "tmux設定"
    ln -nfs "$CURRENT"/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf || error_symlink "$CURRENT/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf" "tmux設定"
    record_link "$HOME/.config/tmux/tmux.conf"
    check_before_symlink "$CURRENT/.config/tmux/quad.sh" "$HOME/.config/tmux/quad.sh" "tmux quad.sh"
    ln -nfs "$CURRENT"/.config/tmux/quad.sh ~/.config/tmux/quad.sh || error_symlink "$CURRENT/.config/tmux/quad.sh" "$HOME/.config/tmux/quad.sh" "tmux quad.sh"
    record_link "$HOME/.config/tmux/quad.sh"
    check_before_symlink "$CURRENT/.config/tmux/editer.sh" "$HOME/.config/tmux/editer.sh" "tmux editer.sh"
    ln -nfs "$CURRENT"/.config/tmux/editer.sh ~/.config/tmux/editer.sh || error_symlink "$CURRENT/.config/tmux/editer.sh" "$HOME/.config/tmux/editer.sh" "tmux editer.sh"
    record_link "$HOME/.config/tmux/editer.sh"
fi

# zellij
echo "zellijレイアウトをリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/zellij/layouts ~/.config/zellij/layouts"
else
    check_before_symlink "$CURRENT/.config/zellij/layouts" "$HOME/.config/zellij/layouts" "zellijレイアウト"
    ln -nfs "$CURRENT"/.config/zellij/layouts ~/.config/zellij/layouts || error_symlink "$CURRENT/.config/zellij/layouts" "$HOME/.config/zellij/layouts" "zellijレイアウト"
    record_link "$HOME/.config/zellij/layouts"
fi

# starship
echo "starship設定をリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/starship.toml ~/.config/starship.toml"
else
    check_before_symlink "$CURRENT/.config/starship.toml" "$HOME/.config/starship.toml" "starship設定"
    ln -nfs "$CURRENT"/.config/starship.toml ~/.config/starship.toml || error_symlink "$CURRENT/.config/starship.toml" "$HOME/.config/starship.toml" "starship設定"
    record_link "$HOME/.config/starship.toml"
fi

# mise
echo "mise設定をリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.config/mise ~/.config/mise"
else
    check_before_symlink "$CURRENT/.config/mise" "$HOME/.config/mise" "mise設定"
    ln -nfs "$CURRENT"/.config/mise ~/.config/mise || error_symlink "$CURRENT/.config/mise" "$HOME/.config/mise" "mise設定"
    record_link "$HOME/.config/mise"
fi

# .zshrc
echo ".zshrcをリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.zshrc ~/.zshrc"
else
    check_before_symlink "$CURRENT/.zshrc" "$HOME/.zshrc" ".zshrc"
    ln -nfs "$CURRENT"/.zshrc ~/.zshrc || error_symlink "$CURRENT/.zshrc" "$HOME/.zshrc" ".zshrc"
    record_link "$HOME/.zshrc"
fi

# .Brewfile
echo ".Brewfileをリンクしています"
if [ $DRY_RUN -eq 1 ]; then
    echo "  [DRY RUN] ln -nfs $CURRENT/.Brewfile ~/.Brewfile"
else
    check_before_symlink "$CURRENT/.Brewfile" "$HOME/.Brewfile" ".Brewfile"
    ln -nfs "$CURRENT"/.Brewfile ~/.Brewfile || error_symlink "$CURRENT/.Brewfile" "$HOME/.Brewfile" ".Brewfile"
    record_link "$HOME/.Brewfile"
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
    check_before_symlink "$CURRENT/.gitmoji/gitmojis.json" "$HOME/.gitmoji/gitmojis.json" "gitmoji設定"
    ln -nfs "$CURRENT"/.gitmoji/gitmojis.json ~/.gitmoji/gitmojis.json || error_symlink "$CURRENT/.gitmoji/gitmojis.json" "$HOME/.gitmoji/gitmojis.json" "gitmoji設定"
    record_link "$HOME/.gitmoji/gitmojis.json"
fi

echo "dotfilesのセットアップが完了しました"
