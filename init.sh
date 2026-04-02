#!/bin/sh
set -e

echo "環境のセットアップを開始します"

CURRENT="$(cd "$(dirname "$0")" && pwd)"

# 1. Homebrew + パッケージインストール
sh "$CURRENT/scripts/homebrew/init.sh" || { echo "エラー: Homebrewのセットアップに失敗しました"; exit 1; }

# Homebrew のPATHを引き継ぐ（サブシェルで設定されたPATHは親に伝播しないため）
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. dotfiles (stow + yazi + gitconfig)
sh "$CURRENT/scripts/dotfiles/init.sh" || { echo "エラー: dotfilesの設定に失敗しました"; exit 1; }

# 3. mise runtimes（失敗しても続行 — 後で手動実行可能）
sh "$CURRENT/scripts/mise/init.sh" || echo "警告: miseのセットアップに失敗しました（後で手動実行可能）"

echo "すべてのセットアップが完了しました！"
