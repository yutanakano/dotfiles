## 概要

cmuxの5パネルレイアウトとGit worktreeを組み合わせて、複数機能を並行開発するためのスクリプト群です。

> **Note**: cmux環境がない場合は、Zellijでも同じワークフローが利用できます。
> → [`docs/zellij.md`](zellij.md)

```
┌──────────────┬──────┬──────┐
│              │  B   │  C   │
│  A (管理)    │ CC+WT│ CC+WT│
│              ├──────┼──────┤
│              │  D   │  E   │
│              │ CC+WT│ CC+WT│
└──────────────┴──────┴──────┘
```

- **パネルA**: 管理用（worktree操作、git status、PR管理）
- **パネルB〜E**: 各worktree + Claude Codeで並行作業

## 使い方

すべてのコマンドはパネルA（管理パネル）で実行します。

### worktreeのセットアップ

ブランチを指定すると、worktree作成 → パネルへの配置 → Claude Code起動を自動で行います。

```sh
# 4ブランチを並行開発
sh ~/.config/cmux/worktree-setup.sh feature/auth feature/api feature/ui fix/bug-123

# 1〜3ブランチでもOK（使わないパネルはそのまま）
sh ~/.config/cmux/worktree-setup.sh feature/auth feature/api
```

- 既存のブランチはそのままチェックアウトされます
- 存在しないブランチは新規作成されます
- worktreeは `<リポジトリ>/.worktrees/` 以下に作成されます

### 状態の確認

```sh
sh ~/.config/cmux/worktree-status.sh
```

出力例:
```
=== Git Worktree Status ===

/path/to/repo         abc1234 [main]
/path/to/.worktrees/feature-auth  def5678 [feature/auth]
/path/to/.worktrees/feature-api   ghi9012 [feature/api]

[feature/auth] feature-auth - 3 changes
[feature/api] feature-api - 0 changes
```

### クリーンアップ

各パネルのClaude Codeを終了してから実行してください。

```sh
# 特定のworktreeを削除
sh ~/.config/cmux/worktree-cleanup.sh feature/auth

# 全worktreeを削除（確認あり）
sh ~/.config/cmux/worktree-cleanup.sh

# 未コミットの変更があっても強制削除
sh ~/.config/cmux/worktree-cleanup.sh --force feature/auth
```

未コミットの変更やuntrackedファイルがあると通常の削除は失敗します。CCが作業途中の場合は `--force` を使うか、先にCCを終了してください。

## 注意事項

- 5パネルレイアウトが適用済みであることが前提です
- `.worktrees/` ディレクトリは各プロジェクトの `.gitignore` に追加してください
- 最大4ブランチまで（パネルB〜Eに対応）
- ブランチとパネルの紐づけは引数の順番（1番目→B、2番目→C、3番目→D、4番目→E）で決まります
