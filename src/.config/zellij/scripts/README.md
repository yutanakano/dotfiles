## 概要

Zellijの5パネルレイアウトとGit worktreeを組み合わせて、複数機能を並行開発するためのスクリプト群です。

> **Note**: cmux環境では自動レイアウトが適用されるため、そちらを優先して利用できます。
> → [`~/.config/cmux/README.md`](../../cmux/README.md)

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

## セッションの操作

```sh
# 新規セッションを5パネルレイアウトで起動
zellij -n ~/.config/zellij/layouts/5pane.kdl -s <session-name>

# 既存セッションにアタッチ
zellij attach <session-name>

# セッション一覧
zellij list-sessions

# デタッチ（セッション内で）
# Ctrl+o → d

# セッション削除（デタッチ後に実行）
zellij delete-session <session-name>
```

## 使い方

すべてのコマンドはパネルA（管理パネル）で実行します。

### worktreeのセットアップ

ブランチを指定すると、worktree作成 → パネルへの配置 → Claude Code起動を自動で行います。

```sh
# 4ブランチを並行開発
sh ~/.config/zellij/scripts/worktree-setup.sh feature/auth feature/api feature/ui fix/bug-123

# 1〜3ブランチでもOK（使わないパネルはそのまま）
sh ~/.config/zellij/scripts/worktree-setup.sh feature/auth feature/api
```

- 既存のブランチはそのままチェックアウトされます
- 存在しないブランチは新規作成されます
- worktreeは `<リポジトリ>/.worktrees/` 以下に作成されます

### 状態の確認

```sh
sh ~/.config/zellij/scripts/worktree-status.sh
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
sh ~/.config/zellij/scripts/worktree-cleanup.sh feature/auth

# 全worktreeを削除（確認あり）
sh ~/.config/zellij/scripts/worktree-cleanup.sh

# 未コミットの変更があっても強制削除
sh ~/.config/zellij/scripts/worktree-cleanup.sh --force feature/auth
```

## cmux版との違い

- cmux版では `cmux send` でペインIDを指定してコマンドを送信していましたが、Zellij版では `move-focus` + `write-chars` で順番にフォーカスを移動して送信します
- レイアウトはKDLファイルで宣言的に定義されるため、スクリプトでの分割操作は不要です
- セッション起動時に `-n` オプションでレイアウトを指定するだけで5パネル構成が適用されます

## 注意事項

- 5パネルレイアウトで起動済みであることが前提です
- `.worktrees/` ディレクトリは各プロジェクトの `.gitignore` に追加してください
- 最大4ブランチまで（パネルB〜Eに対応）
- ブランチとパネルの紐づけは引数の順番（1番目→B、2番目→C、3番目→D、4番目→E）で決まります
- worktree-setup.sh は必ずパネルA（左端のペイン）から実行してください
