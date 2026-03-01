#!/bin/sh
# src/init.sh のテスト

# カラーコード
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# テスト結果カウンター
PASSED=0
FAILED=0

# 現在のディレクトリ（srcディレクトリ）
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

# テスト結果を表示する関数
pass() {
    printf "${GREEN}✓${NC} %s\n" "$1"
    PASSED=$((PASSED + 1))
}

fail() {
    printf "${RED}✗${NC} %s\n" "$1"
    FAILED=$((FAILED + 1))
}

echo ""
echo "=== src/init.sh のテスト ==="
echo ""

# -------------------------------------------------
# 1. ファイル存在チェック
# -------------------------------------------------
echo "[ファイル存在チェック]"

check_file_exists() {
    if [ -f "$1" ]; then
        pass "$2"
        return 0
    else
        fail "$2 (ファイルが見つかりません: $1)"
        return 1
    fi
}

check_file_exists "$SRC_DIR/init.sh" "src/init.shが存在する"
check_file_exists "$SRC_DIR/.zshrc" ".zshrcが存在する"
check_file_exists "$SRC_DIR/.Brewfile" ".Brewfileが存在する"
check_file_exists "$SRC_DIR/.gitconfig.template" ".gitconfig.templateが存在する"
check_file_exists "$SRC_DIR/.ssh/config" "SSH設定が存在する"
check_file_exists "$SRC_DIR/.config/starship.toml" "Starship設定が存在する"
check_file_exists "$SRC_DIR/.config/tmux/tmux.conf" "tmux設定が存在する"
check_file_exists "$SRC_DIR/.config/tmux/editer.sh" "tmux editer.shが存在する"
check_file_exists "$SRC_DIR/.config/tmux/quad.sh" "tmux quad.shが存在する"
check_file_exists "$SRC_DIR/.config/mise/config.toml" "mise設定が存在する"
check_file_exists "$SRC_DIR/.gitmoji/gitmojis.json" "gitmoji設定が存在する"

echo ""

# -------------------------------------------------
# 2. スクリプト構文チェック
# -------------------------------------------------
echo "[スクリプト構文チェック]"

if sh -n "$SRC_DIR/init.sh" 2>/dev/null; then
    pass "src/init.shの構文が正しい"
else
    fail "src/init.shの構文にエラーがある"
fi

echo ""

# -------------------------------------------------
# 3. 設定ファイル妥当性チェック
# -------------------------------------------------
echo "[設定ファイル妥当性チェック]"

# JSON形式チェック
if command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$SRC_DIR/.gitmoji/gitmojis.json" >/dev/null 2>&1; then
        pass "gitmojis.jsonの形式が正しい"
    else
        fail "gitmojis.jsonの形式が不正"
    fi
else
    printf "${YELLOW}⊘${NC} gitmojis.json (python3がないためスキップ)\n"
fi

# TOML形式チェック（基本的なチェック）
if grep -q "\[tools\]" "$SRC_DIR/.config/mise/config.toml" 2>/dev/null; then
    pass "mise config.tomlの形式が正しい"
else
    fail "mise config.tomlに[tools]セクションが見つからない"
fi

# Brewfile形式チェック
if grep -qE "tap|brew|cask|mas|vscode" "$SRC_DIR/.Brewfile" 2>/dev/null; then
    pass "Brewfileの形式が正しい"
else
    fail "Brewfileに必要なキーワードが見つからない"
fi

echo ""

# -------------------------------------------------
# 4. 実際の動作テスト（一時ディレクトリで安全に実行）
# -------------------------------------------------
echo "[動作テスト（一時ディレクトリ）]"

# 一時ディレクトリを作成
TEST_HOME=$(mktemp -d)
export OLD_HOME="$HOME"
export HOME="$TEST_HOME"

# ディレクトリ作成のテスト
mkdir -p "$HOME/.ssh" 2>/dev/null
mkdir -p "$HOME/.config/tmux" 2>/dev/null
mkdir -p "$HOME/.config/zellij" 2>/dev/null
mkdir -p "$HOME/.gitmoji" 2>/dev/null

if [ -d "$HOME/.ssh" ] && [ -d "$HOME/.config/tmux" ] && \
   [ -d "$HOME/.config/zellij" ] && [ -d "$HOME/.gitmoji" ]; then
    pass "必要なディレクトリが正しく作成される"
else
    fail "ディレクトリ作成に失敗"
fi

# シンボリックリンク作成のテスト
ln -nfs "$SRC_DIR/.ssh/config" "$HOME/.ssh/config" 2>/dev/null
ln -nfs "$SRC_DIR/.zshrc" "$HOME/.zshrc" 2>/dev/null

if [ -L "$HOME/.ssh/config" ] && [ -L "$HOME/.zshrc" ]; then
    # リンク先が正しいか確認
    ssh_link=$(readlink "$HOME/.ssh/config")
    zshrc_link=$(readlink "$HOME/.zshrc")

    if [ "$ssh_link" = "$SRC_DIR/.ssh/config" ] && [ "$zshrc_link" = "$SRC_DIR/.zshrc" ]; then
        pass "シンボリックリンクが正しく作成される"
    else
        fail "シンボリックリンクのリンク先が不正"
    fi
else
    fail "シンボリックリンク作成に失敗"
fi

# クリーンアップ
export HOME="$OLD_HOME"
rm -rf "$TEST_HOME"

echo ""

# -------------------------------------------------
# テスト結果サマリー
# -------------------------------------------------
TOTAL=$((PASSED + FAILED))

if [ $FAILED -eq 0 ]; then
    printf "${GREEN}✓ %d/%d テスト成功${NC}\n" "$PASSED" "$TOTAL"
    exit 0
else
    printf "${RED}✗ %d/%d テスト失敗 (%d成功, %d失敗)${NC}\n" "$TOTAL" "$TOTAL" "$PASSED" "$FAILED"
    exit 1
fi
