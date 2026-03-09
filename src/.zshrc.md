# .zshrc 設定ガイド

## 設定の構成

```
.zshrc
├── パス設定（Homebrew, mise, Android, Starship）
├── プラグインマネージャ（Zinit）
├── 履歴設定
├── ディレクトリ移動設定
├── シェルの挙動設定
├── 補完の強化
├── プラグイン
│   ├── zsh-completions      # 補完定義の拡充
│   ├── zsh-autosuggestions   # コマンド候補の自動表示
│   ├── zsh-z                 # ディレクトリジャンプ
│   ├── zsh-bd                # 親ディレクトリへ移動
│   ├── fast-syntax-highlighting  # シンタックスハイライト
│   ├── history-substring-search  # 履歴の部分一致検索
│   └── fzf-tab               # TAB補完のfzf化
└── fzf
```

## 履歴

| 設定 | 説明 |
|------|------|
| `HISTFILE=~/.zsh_history` | 履歴の保存先を明示指定 |
| `HISTSIZE=10000` | メモリ上の履歴保持数 |
| `SAVEHIST=10000` | ファイルへの履歴保存数 |
| `share_history` | 複数ターミナル間で履歴を即時共有 |
| `hist_ignore_all_dups` | 重複する履歴を削除 |
| `hist_ignore_space` | スペースで始めたコマンドを履歴に残さない |
| `hist_reduce_blanks` | 余分な空白を除去して保存 |
| `hist_expire_dups_first` | 履歴が上限に達したとき重複から削除 |

```sh
# スペースで始めると履歴に残らない（パスワード入力時などに便利）
 export SECRET=abc123

# 複数ターミナルで作業中、別タブで打ったコマンドが即座に↑で出てくる
```

## ディレクトリ移動

| 設定 | 説明 |
|------|------|
| `auto_cd` | ディレクトリ名だけで移動（`cd` 不要） |
| `auto_pushd` | `cd` するたびにスタックに積む |
| `pushd_ignore_dups` | スタック内の重複を除去 |

```sh
# auto_cd: cd を省略できる
~/projects/myapp        # cd ~/projects/myapp と同じ
..                      # cd .. と同じ
/tmp                    # cd /tmp と同じ

# auto_pushd: 過去のディレクトリに戻れる
cd ~/projects
cd /tmp
cd ~/Desktop
cd -<TAB>               # 履歴一覧が表示される
# 1 -- ~/Desktop
# 2 -- /tmp
# 3 -- ~/projects
cd -2                   # /tmp に戻る
```

## シェルの挙動

| 設定 | 説明 |
|------|------|
| `correct` | コマンドのタイポを検知して修正候補を提案 |
| `no_beep` | ビープ音を無効化 |
| `interactive_comments` | シェル上で `#` 以降をコメントとして扱う |
| `print_eight_bit` | 日本語ファイル名を正しく表示 |

```sh
# correct: タイポを自動検知
$ gti status
# zsh: correct 'gti' to 'git' [nyae]?
# y を押すと git status が実行される

# interactive_comments: コマンドの横にメモを残せる
$ docker ps # 起動中のコンテナ確認
```

## 補完

| 設定 | 説明 |
|------|------|
| `matcher-list 'm:{a-z}={A-Z}'` | 小文字で大文字にもマッチ |
| `menu select` | TABで候補をハイライト選択 |

```sh
# 小文字で大文字もマッチ
$ cd doc<TAB>           # Documents/ にもマッチする

# menu select: TABを押すと候補がハイライトされ、矢印キーで選択できる
$ git <TAB>
# add    branch    checkout    commit    ...
# ↑↓←→ で選択して Enter
```

## プラグイン

### zsh-autosuggestions

過去の履歴から候補をグレーで表示。`→` で確定。

```sh
$ git com                # git commit -m "..." がグレーで表示される
# → を押すと確定
# Ctrl+E でも確定できる
```

### zsh-z

過去に訪れたディレクトリにキーワードでジャンプ。

```sh
$ z myapp               # 過去に cd した ~/projects/myapp へジャンプ
$ z proj                # ~/projects にジャンプ（部分一致）
$ z -l                  # 記録されたディレクトリ一覧を表示
$ z -l proj             # "proj" を含むディレクトリ一覧
```

### zsh-bd

現在のパスの親ディレクトリ名を指定して移動。

```sh
# 現在地: ~/projects/myapp/src/components/Button
$ bd components         # ~/projects/myapp/src/components へ移動
$ bd src                # ~/projects/myapp/src へ移動
$ bd myapp              # ~/projects/myapp へ移動
$ bd projects           # ~/projects へ移動

# 現在のパスに含まれる上位ディレクトリ名を指定する
# cd ../../../.. と打つより直感的
```

### history-substring-search

入力途中の文字列で履歴を↑↓検索。

```sh
$ docker                # と入力した状態で
# ↑ を押すと "docker" を含む過去のコマンドだけを順に表示
# docker compose up -d
# docker ps -a
# docker build -t myapp .
```

### fzf-tab

TAB補完の候補をfzfのUIで表示。

```sh
$ cd <TAB>              # fzfのインタラクティブUIで候補を絞り込める
$ git checkout <TAB>    # ブランチ一覧をfzfで検索
$ kill <TAB>            # プロセス一覧をfzfで検索
```

### fast-syntax-highlighting

コマンド入力中にリアルタイムで色分け。

```
$ echo "hello"          # 有効なコマンドは緑
$ echooo "hello"        # 存在しないコマンドは赤
$ cat ~/.zshrc           # 存在するファイルは下線付き
```

### zsh-completions

標準では提供されていないコマンドの補完定義を追加（docker, cargo, rustup, yarn など）。設定不要で自動的に有効になる。

## fzf キーバインド

| キー | 動作 |
|------|------|
| `Ctrl+R` | 履歴をfzfで検索 |
| `Ctrl+T` | カレントディレクトリ以下のファイルをfzfで検索 |
| `Alt+C` | カレントディレクトリ以下のディレクトリをfzfで検索して移動 |
