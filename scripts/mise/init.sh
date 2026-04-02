#!/bin/sh
set -e

if ! command -v mise >/dev/null 2>&1; then
    echo "エラー: miseがインストールされていません"
    exit 1
fi

echo "miseランタイムをインストールしています..."
mise install || { echo "エラー: miseランタイムのインストールに失敗しました"; exit 1; }

echo "miseのセットアップが完了しました"
