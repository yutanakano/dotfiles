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

# src/init.shを呼び出しているか
if grep -q "src/init.sh" "$ROOT_DIR/init.sh" 2>/dev/null; then
    printf "${GREEN}✓${NC} src/init.shを呼び出している\n"
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
else
    printf "${RED}✗${NC} src/init.shを呼び出していない\n"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi

echo ""

# -------------------------------------------------
# 2. src/init.test.sh を実行
# -------------------------------------------------
if [ -f "$ROOT_DIR/src/init.test.sh" ]; then
    # src/init.test.shを実行
    sh "$ROOT_DIR/src/init.test.sh"
    SRC_TEST_EXIT=$?

    # 終了コードに基づいて結果を集計
    # src/init.test.shは成功時に0、失敗時に1を返す
    # 詳細な成功/失敗数はsrc/init.test.sh内で表示される
else
    printf "${RED}✗${NC} src/init.test.shが見つかりません\n"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    SRC_TEST_EXIT=1
fi

# -------------------------------------------------
# 最終結果
# -------------------------------------------------
echo ""
printf "${BLUE}=== テスト完了 ===${NC}\n"

# src/init.test.shの終了コードをそのまま返す
# これにより、どこかでテストが失敗していれば全体も失敗扱いになる
if [ $TOTAL_FAILED -eq 0 ] && [ $SRC_TEST_EXIT -eq 0 ]; then
    printf "${GREEN}すべてのテストが成功しました！${NC}\n"
    echo ""
    exit 0
else
    printf "${RED}一部のテストが失敗しました${NC}\n"
    echo ""
    exit 1
fi
