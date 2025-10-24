#!/bin/sh
set -e

echo "dotfilesのセットアップを開始します"

CURRENT="$(cd "$(dirname "$0")" && pwd)"

# dotfiles
echo "設定ファイルをリンクしています"
sh "$CURRENT/src/init.sh" || { echo "エラー: dotfilesの設定に失敗しました"; exit 1; }

echo "すべてのセットアップが完了しました！"
