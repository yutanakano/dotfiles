#!/bin/sh
# dotfiles テストランナー
# すべてのテストを実行します

# カラーコード
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 現在のディレクトリ（dotfilesルート）
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
printf "${BLUE}=== dotfiles テスト ===${NC}\n"
echo ""

# テスト結果カウンター
TOTAL_PASSED=0
TOTAL_FAILED=0

# -------------------------------------------------
# 1. init.sh の基本チェック
# -------------------------------------------------
echo "[init.sh の基本チェック]"

# init.shが存在するか
if [ -f "$ROOT_DIR/init.sh" ]; then
    printf "${GREEN}✓${NC} init.shが存在する\n"
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
else
    printf "${RED}✗${NC} init.shが存在しない\n"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi

# init.shの構文チェック
if sh -n "$ROOT_DIR/init.sh" 2>/dev/null; then
    printf "${GREEN}✓${NC} init.shの構文が正しい\n"
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
else
    printf "${RED}✗${NC} init.shの構文にエラーがある\n"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi

# init.shが3つのサブスクリプトを呼び出しているか
for subscript in "scripts/homebrew/init.sh" "scripts/dotfiles/init.sh" "scripts/mise/init.sh"; do
    if grep -q "$subscript" "$ROOT_DIR/init.sh" 2>/dev/null; then
        printf "${GREEN}✓${NC} ${subscript}を呼び出している\n"
        TOTAL_PASSED=$((TOTAL_PASSED + 1))
    else
        printf "${RED}✗${NC} ${subscript}を呼び出していない\n"
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
done

echo ""

# -------------------------------------------------
# 2. サブスクリプトの存在・構文チェック
# -------------------------------------------------
echo "[サブスクリプトチェック]"

for script in "scripts/homebrew/init.sh" "scripts/dotfiles/init.sh" "scripts/mise/init.sh"; do
    if [ -f "$ROOT_DIR/$script" ]; then
        printf "${GREEN}✓${NC} ${script}が存在する\n"
        TOTAL_PASSED=$((TOTAL_PASSED + 1))
    else
        printf "${RED}✗${NC} ${script}が存在しない\n"
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi

    if sh -n "$ROOT_DIR/$script" 2>/dev/null; then
        printf "${GREEN}✓${NC} ${script}の構文が正しい\n"
        TOTAL_PASSED=$((TOTAL_PASSED + 1))
    else
        printf "${RED}✗${NC} ${script}の構文にエラーがある\n"
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
done

# homebrew/init.shがsrc/.Brewfileを参照しているか
if grep -q "src/.Brewfile" "$ROOT_DIR/scripts/homebrew/init.sh" 2>/dev/null; then
    printf "${GREEN}✓${NC} homebrew/init.shがsrc/.Brewfileを参照している\n"
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
else
    printf "${RED}✗${NC} homebrew/init.shがsrc/.Brewfileを参照していない\n"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi

echo ""

# -------------------------------------------------
# 3. scripts/dotfiles/init.test.sh を実行
# -------------------------------------------------
if [ -f "$ROOT_DIR/scripts/dotfiles/init.test.sh" ]; then
    sh "$ROOT_DIR/scripts/dotfiles/init.test.sh"
    SRC_TEST_EXIT=$?
else
    printf "${RED}✗${NC} scripts/dotfiles/init.test.shが見つかりません\n"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    SRC_TEST_EXIT=1
fi

# -------------------------------------------------
# 最終結果
# -------------------------------------------------
echo ""
printf "${BLUE}=== テスト完了 ===${NC}\n"

if [ $TOTAL_FAILED -eq 0 ] && [ $SRC_TEST_EXIT -eq 0 ]; then
    printf "${GREEN}すべてのテストが成功しました！${NC}\n"
    echo ""
    exit 0
else
    printf "${RED}一部のテストが失敗しました${NC}\n"
    echo ""
    exit 1
fi
