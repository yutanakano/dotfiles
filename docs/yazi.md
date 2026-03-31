## 概要

Yaziはターミナルファイルマネージャーです。`.zshrc`に定義された`y`コマンドで起動すると、終了時にYaziで最後にいたディレクトリにシェルのカレントディレクトリが移動します（cd-on-exit）。

## キーバインド

### カスタムキーバインド（`keymap.toml`で定義）

| キー | 動作 | プラグイン |
|------|------|-----------|
| `l` | ファイルを開く / ディレクトリに入る | smart-enter |
| `g` `i` | lazygitを起動 | lazygit |
| `b` `d` | fd + fzfでファイル検索 | fazif |
| `b` `r` | ripgrep + fzfでテキスト検索 | fazif |

### デフォルトキーバインド（よく使うもの）

| キー | 動作 |
|------|------|
| `q` | 終了（cd-on-exit） |
| `Q` | 終了（cdしない） |
| `j` / `k` | カーソル上下移動 |
| `h` / `l` | 親ディレクトリ / 子に入る |
| `.` | 隠しファイル表示切替 |
| `/` | 検索 |
| `Space` | 選択 |
| `y` | コピー（yank） |
| `p` | 貼り付け |
| `d` | 削除 |
| `r` | リネーム |
| `Tab` | タブ切替 |

## プラグイン

| プラグイン | 用途 |
|-----------|------|
| git | ファイル一覧にgit status表示 |
| smart-enter | ファイルopen / ディレクトリenterを1キーで統一 |
| full-border | 角丸ボーダーで見た目を改善 |
| starship | ヘッダーにStarshipプロンプトを表示 |
| lazygit | Yazi内からlazygitを起動 |
| fazif | fzf + fd + ripgrepでファイル検索・grep |

## テーマ

Tokyo Night（`BennyOe/tokyo-night`）を使用。

## プラグインの運用

### 新環境でのセットアップ

`sh init.sh` を実行すれば `ya pkg install` が自動で走り、`package.toml` に記録された全プラグイン・テーマがインストールされます。

### プラグインの追加

```sh
ya pkg add owner/repo
```

`package.toml` が更新されるので、変更をコミットしてください。

### プラグインのアップグレード

```sh
ya pkg upgrade
```

`package.toml` のリビジョンが更新されるので、差分を確認してコミットしてください。Brewfileの`brew bundle dump`と同じ運用パターンです。

### プラグインの削除

```sh
ya pkg delete owner/repo
```

## 設定ファイル構成

```
~/.config/yazi/
├── yazi.toml      # 基本設定（ソート、プレビュー等）
├── keymap.toml    # カスタムキーバインド
├── theme.toml     # テーマ設定
├── init.lua       # プラグインのセットアップ
├── package.toml   # プラグイン・テーマの依存定義
├── plugins/       # ya pkg installで展開（.gitignore対象）
└── flavors/       # ya pkg installで展開（.gitignore対象）
```
