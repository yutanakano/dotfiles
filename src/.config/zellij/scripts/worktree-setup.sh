#!/bin/sh
# zellij worktree setup: worktreeを作成してB〜Eパネルに配置しCC起動
#
# 使い方:
#   worktree-setup.sh <branch1> [branch2] [branch3] [branch4]
#   worktree-setup.sh feature/auth feature/api feature/ui fix/bug-123
#
# 前提: 5pane.kdl レイアウトで起動済みであること
#       パネルAで実行すること
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
    echo "  各ブランチに対してworktreeを作成し、対応するパネルでClaude Codeを起動します"
    exit 1
fi

# フォーカス移動のシーケンス
# パネルA(左)から右に移動するとB(右上左)に到達
# そこから右→C、左+下→D、右→E
# レイアウト: A | B C
#             A | D E
#
# A→B: right
# B→C: right
# C→D: left, down  (Cから左でBに戻り、下でDへ)
# D→E: right
FOCUS_SEQUENCE="right right:right left,down right"

mkdir -p "$WORKTREE_BASE"

# パネルBへ移動（Aから右）
_focus_pane_b() {
    zellij action move-focus right
}

# パネルCへ移動（Bから右）
_focus_pane_c() {
    zellij action move-focus right
}

# パネルDへ移動（Cから左→下）
_focus_pane_d() {
    zellij action move-focus left
    zellij action move-focus down
}

# パネルEへ移動（Dから右）
_focus_pane_e() {
    zellij action move-focus right
}

# 現在フォーカス中のペインにコマンドを送信
_send_command() {
    zellij action write-chars "$1"
    # Enterキーを送信（改行コード）
    zellij action write 10
}

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

    # 対応するパネルにフォーカスを移動
    case $i in
        0) _focus_pane_b ;;
        1) _focus_pane_c ;;
        2) _focus_pane_d ;;
        3) _focus_pane_e ;;
    esac

    # コマンド送信
    _send_command "cd $wt_path && clear && claude"
    sleep 0.5

    i=$((i + 1))
done

# パネルAにフォーカスを戻す
# 現在位置からAに戻るには左に移動
zellij action move-focus left
# 上段にいない場合に備えて上にも移動
zellij action move-focus up
zellij action move-focus left

echo "セットアップ完了: $i 個のworktreeをパネルに配置し、Claude Codeを起動しました"
