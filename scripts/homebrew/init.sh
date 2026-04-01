#!/bin/sh
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
BREWFILE_PATH="$DOTFILES_DIR/src/.Brewfile"

# -------------------------------------------------
# Homebrew のインストール
# -------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrewをインストールしています..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "エラー: Homebrewのインストールに失敗しました"; exit 1; }

    # Apple Silicon / Intel Mac 対応
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrewはインストール済みです"
fi

# Homebrew が正しくインストールされたか確認
if ! command -v brew >/dev/null 2>&1; then
    echo "エラー: Homebrewのインストール後にbrewコマンドが見つかりません"
    exit 1
fi

# -------------------------------------------------
# Brewfile の存在確認
# -------------------------------------------------
if [ ! -f "$BREWFILE_PATH" ]; then
    echo "エラー: Brewfileが見つかりません: $BREWFILE_PATH"
    exit 1
fi

# -------------------------------------------------
# Homebrew のメンテナンス
# -------------------------------------------------
echo "brew updateを実行しています..."
brew update || { echo "エラー: brew updateに失敗しました"; exit 1; }

# -------------------------------------------------
# Brewfile からパッケージをインストール
# -------------------------------------------------
echo "Brewfileからパッケージをインストールしています..."
brew bundle --no-upgrade --file="$BREWFILE_PATH" || { echo "エラー: brew bundleに失敗しました"; exit 1; }
rm -f "${BREWFILE_PATH}.lock.json"

echo "brew doctorを実行しています..."
brew doctor || echo "警告: brew doctorが問題を検出しました（致命的ではありません）"

echo "Homebrewのセットアップが完了しました"
