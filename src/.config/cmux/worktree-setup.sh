#!/bin/sh
# cmux worktree setup: worktreeを作成してB〜Eパネルに配置しCC起動
#
# 使い方:
#   worktree-setup.sh <branch1> [branch2] [branch3] [branch4]
#   worktree-setup.sh feature/auth feature/api feature/ui fix/bug-123
#
# 前提: 5パネルレイアウトが適用済みであること
#
# ┌──────────────┬──────┬──────┐
# │              │  B   │  C   │
# │  A (管理)    │ CC+WT│ CC+WT│
# │              ├──────┼──────┤
# │              │  D   │  E   │
# │              │ CC+WT│ CC+WT│
# └──────────────┴──────┴──────┘

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_BASE="${REPO_ROOT}/.worktrees"

if [ $# -lt 1 ]; then
    echo "使い方: $0 <branch1> [branch2] [branch3] [branch4]"
    echo "  各ブランチに対してworktreeを作成し、対応するパネルで開きます"
    exit 1
fi

# パネルを取得（list-panesの順序: A, B, D, C, E）
# B→C→D→Eの順（上段左→右、下段左→右）に並べ替え
PANES=$(cmux list-panes | awk '{for(i=1;i<=NF;i++) if($i~/^pane:/) print $i}')
PANE_B=$(echo "$PANES" | sed -n '2p')
PANE_D=$(echo "$PANES" | sed -n '3p')
PANE_C=$(echo "$PANES" | sed -n '4p')
PANE_E=$(echo "$PANES" | sed -n '5p')
PANELS="$PANE_B
$PANE_C
$PANE_D
$PANE_E"

mkdir -p "$WORKTREE_BASE"

i=0
for branch in "$@"; do
    [ $i -ge 4 ] && break

    # ブランチ名からディレクトリ名を生成（/を-に変換）
    dir_name=$(echo "$branch" | tr '/' '-')
    wt_path="${WORKTREE_BASE}/${dir_name}"

    # worktree作成（既存なら作成スキップ）
    if [ ! -d "$wt_path" ]; then
        if git show-ref --verify --quiet "refs/heads/$branch"; then
            git worktree add "$wt_path" "$branch"
        else
            git worktree add -b "$branch" "$wt_path"
        fi
    fi

    # 対応するパネルのsurfaceを取得してコマンド送信
    pane=$(echo "$PANELS" | sed -n "$((i+1))p")
    if [ -n "$pane" ]; then
        surface=$(cmux list-pane-surfaces --pane "$pane" | awk '{for(i=1;i<=NF;i++) if($i~/^surface:/) {print $i; exit}}')
        if [ -n "$surface" ]; then
            cmux send --surface "$surface" "cd $wt_path && clear && claude"
            cmux send-key --surface "$surface" Enter
            sleep 0.5
        fi
    fi

    i=$((i + 1))
done

echo "セットアップ完了: $i 個のworktreeをパネルに配置し、Claude Codeを起動しました"
