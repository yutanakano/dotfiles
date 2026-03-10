#!/bin/sh
set -e

CURRENT="$(cd "$(dirname "$0")" && pwd)"

# フラグのチェック
DRY_RUN=0
UNINSTALL=0

# 引数を処理
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=1
            ;;
        --uninstall)
            UNINSTALL=1
            ;;
        --help|-h)
            echo "使用方法: $0 [--dry-run] [--uninstall] [--help]"
            echo ""
            echo "オプション:"
            echo "  --dry-run     実際には変更を行わず、実行内容のみを表示します"
            echo "  --uninstall   dotfilesのシンボリックリンクを削除します"
            echo "  --help, -h    このヘルプメッセージを表示します"
            exit 0
            ;;
        *)
            echo "不明なオプション: $arg"
            echo "使用方法: $0 [--dry-run] [--uninstall] [--help]"
            exit 1
            ;;
    esac
done

# モードの表示
if [ $DRY_RUN -eq 1 ]; then
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

# シンボリックリンク設定のリストを処理
# $1: action (install/uninstall)
process_symlink_configs() {
    action="$1"
    removed_count=0
    skipped_count=0

    # パイプ区切りで設定を定義: source|target|description|post_command
    while IFS='|' read -r source target desc post_cmd; do
        # 空行やコメントをスキップ
        case "$source" in
            ''|'#'*) continue ;;
        esac

        if [ "$action" = "install" ]; then
            if [ $DRY_RUN -eq 1 ]; then
                echo "  [DRY RUN] ln -nfs $source $target"
                [ -n "$post_cmd" ] && echo "  [DRY RUN] $post_cmd"
            else
                check_before_symlink "$source" "$target" "$desc"
                ln -nfs "$source" "$target" || error_symlink "$source" "$target" "$desc"
                record_link "$target"
                [ -n "$post_cmd" ] && eval "$post_cmd"
            fi
        elif [ "$action" = "uninstall" ]; then
            if [ -L "$target" ]; then
                if [ $DRY_RUN -eq 1 ]; then
                    echo "  [DRY RUN] rm -f $target ($desc)"
                else
                    rm -f "$target"
                    echo "  削除: $target ($desc)"
                fi
                removed_count=$((removed_count + 1))
            elif [ -e "$target" ]; then
                echo "  警告: $target はシンボリックリンクではありません。スキップします"
                skipped_count=$((skipped_count + 1))
            fi
        fi
    done <<SYMLINK_LIST
$CURRENT/.ssh/config|$HOME/.ssh/config|SSH設定|chmod 600 "$HOME/.ssh/config"
$CURRENT/.config/tmux/tmux.conf|$HOME/.config/tmux/tmux.conf|tmux設定|
$CURRENT/.config/tmux/quad.sh|$HOME/.config/tmux/quad.sh|tmux quad.sh|
$CURRENT/.config/tmux/editor.sh|$HOME/.config/tmux/editor.sh|tmux editor.sh|
$CURRENT/.config/zellij/layouts|$HOME/.config/zellij/layouts|zellijレイアウト|
$CURRENT/.config/starship.toml|$HOME/.config/starship.toml|starship設定|
$CURRENT/.config/ghostty/config|$HOME/.config/ghostty/config|Ghostty設定|
$CURRENT/.config/mise|$HOME/.config/mise|mise設定|
$CURRENT/.config/nvim|$HOME/.config/nvim|Neovim設定(LazyVim)|
$CURRENT/.zshrc|$HOME/.zshrc|.zshrc|
$CURRENT/.Brewfile|$HOME/.Brewfile|.Brewfile|
$CURRENT/.gitmoji/gitmojis.json|$HOME/.gitmoji/gitmojis.json|gitmoji設定|
SYMLINK_LIST

    # アンインストール時のサマリー
    if [ "$action" = "uninstall" ]; then
        if [ $removed_count -eq 0 ] && [ $skipped_count -eq 0 ]; then
            echo "  削除するシンボリックリンクが見つかりませんでした"
        fi
    fi
}

# ディレクトリ設定のリストを処理
# $1: action (create/remove)
process_directory_configs() {
    action="$1"
    removed_count=0

    # パイプ区切りで設定を定義: path|description
    while IFS='|' read -r dir_path desc; do
        # 空行やコメントをスキップ
        case "$dir_path" in
            ''|'#'*) continue ;;
        esac

        if [ "$action" = "create" ]; then
            if [ $DRY_RUN -eq 1 ]; then
                echo "  [DRY RUN] mkdir -p $dir_path"
            else
                [ ! -d "$dir_path" ] && mkdir -p "$dir_path" && record_dir "$dir_path"
            fi
        elif [ "$action" = "remove" ]; then
            if [ -d "$dir_path" ] && [ -z "$(ls -A "$dir_path" 2>/dev/null)" ]; then
                if [ $DRY_RUN -eq 1 ]; then
                    echo "  [DRY RUN] rmdir $dir_path ($desc)"
                else
                    rmdir "$dir_path" 2>/dev/null && echo "  削除: $dir_path ($desc)" || true
                fi
                removed_count=$((removed_count + 1))
            elif [ -d "$dir_path" ] && [ -n "$(ls -A "$dir_path" 2>/dev/null)" ]; then
                echo "  情報: $dir_path は空でないためスキップします"
            fi
        fi
    done <<DIR_LIST
$HOME/.ssh|.sshディレクトリ
$HOME/.config/tmux|tmuxディレクトリ
$HOME/.config/zellij|zellijディレクトリ
$HOME/.config/ghostty|ghosttyディレクトリ
$HOME/.gitmoji|.gitmojiディレクトリ
DIR_LIST

    # アンインストール時のサマリー
    if [ "$action" = "remove" ] && [ $removed_count -eq 0 ]; then
        echo "  削除する空のディレクトリが見つかりませんでした"
    fi
}

# アンインストール関数
uninstall_dotfiles() {
    if [ $DRY_RUN -eq 1 ]; then
        echo ""
        echo "=== アンインストール (DRY RUN) ==="
        echo ""
    else
        echo ""
        echo "dotfilesをアンインストールしています"
        echo ""
    fi

    # シンボリックリンクの削除
    echo "シンボリックリンクを削除しています"
    process_symlink_configs uninstall

    echo ""

    # 空のディレクトリを削除
    echo "空のディレクトリを削除しています"
    process_directory_configs remove

    echo ""
    echo "dotfilesのアンインストールが完了しました"

    exit 0
}

# アンインストールモードの場合はアンインストールして終了
if [ $UNINSTALL -eq 1 ]; then
    uninstall_dotfiles
fi

echo "dotfilesをセットアップしています"

# 必要なディレクトリを作成
echo "必要なディレクトリを作成しています"
process_directory_configs create

# シンボリックリンクの作成
echo "シンボリックリンクを作成しています"
process_symlink_configs install

# .gitconfig
if [ $DRY_RUN -eq 1 ]; then
    if [ ! -f ~/.gitconfig ]; then
        echo ".gitconfigをセットアップしています"
        echo "  [DRY RUN] cp $CURRENT/.gitconfig.template ~/.gitconfig"
        echo "  [DRY RUN] 名前とメールアドレスの入力をスキップ"
        echo "  [DRY RUN] sed -i.bak 's|YOUR_NAME|<入力された名前>|' ~/.gitconfig"
        echo "  [DRY RUN] sed -i.bak 's|YOUR_EMAIL|<入力されたメール>|' ~/.gitconfig"
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

        sed -i.bak "s|YOUR_NAME|$git_name|" ~/.gitconfig || { echo "エラー: 名前の更新に失敗しました"; exit 1; }
        sed -i.bak "s|YOUR_EMAIL|$git_email|" ~/.gitconfig || { echo "エラー: メールアドレスの更新に失敗しました"; exit 1; }
        rm ~/.gitconfig.bak
        echo ".gitconfigを作成しました"
    else
        echo ".gitconfigは既に存在します。スキップします"
    fi
fi

echo "dotfilesのセットアップが完了しました"
