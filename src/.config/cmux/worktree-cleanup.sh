#!/bin/sh
# cmux worktree cleanup: worktreeを削除
#
# 使い方:
#   worktree-cleanup.sh [--force] [branch ...]
#
#   --force    未コミットの変更があっても強制削除
#   branch     指定したworktreeのみ削除（省略時は全worktree）
#
# 注意: CC作業中のworktreeには未コミットの変更が残るため、
#       CCを終了してから実行するか、--force を使用してください

set -e

FORCE=""
BRANCHES=""

for arg in "$@"; do
    case "$arg" in
        --force) FORCE="--force" ;;
        *) BRANCHES="$BRANCHES $arg" ;;
    esac
done

REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_BASE="${REPO_ROOT}/.worktrees"

if [ ! -d "$WORKTREE_BASE" ]; then
    echo "worktreeディレクトリが見つかりません"
    exit 0
fi

if [ -n "$BRANCHES" ]; then
    for branch in $BRANCHES; do
        dir_name=$(echo "$branch" | tr '/' '-')
        wt_path="${WORKTREE_BASE}/${dir_name}"
        if [ -d "$wt_path" ]; then
            git worktree remove $FORCE "$wt_path"
            echo "削除: $wt_path ($branch)"
        fi
    done
else
    echo "全worktreeを削除しますか？ (y/N)"
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        for wt in "$WORKTREE_BASE"/*/; do
            [ -d "$wt" ] && git worktree remove $FORCE "$wt" && echo "削除: $wt"
        done
        git worktree prune
        echo "クリーンアップ完了"
    fi
fi
