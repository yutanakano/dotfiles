#!/bin/sh
# zellij worktree status: 全worktreeの状態を表示

REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_BASE="${REPO_ROOT}/.worktrees"

echo "=== Git Worktree Status ==="
echo ""
git worktree list
echo ""

if [ -d "$WORKTREE_BASE" ]; then
    for wt in "$WORKTREE_BASE"/*/; do
        [ ! -d "$wt" ] && continue
        branch=$(git -C "$wt" branch --show-current 2>/dev/null || echo "detached")
        changes=$(git -C "$wt" status --short 2>/dev/null | wc -l | tr -d ' ')
        echo "[$branch] $(basename "$wt") - ${changes} changes"
    done
fi
