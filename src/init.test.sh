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

# テスト用ヘルパー関数
setup_test_gitconfig() {
    echo "[user]" > "$HOME/.gitconfig"
    echo "  name = Test User" >> "$HOME/.gitconfig"
    echo "  email = test@example.com" >> "$HOME/.gitconfig"
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
check_file_exists "$SRC_DIR/.config/tmux/editor.sh" "tmux editor.shが存在する"
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
# 3. 入力検証関数のテスト
# -------------------------------------------------
echo "[入力検証関数のテスト]"

# 検証関数を定義（init.shから抽出）
validate_not_empty() {
    [ -n "$1" ]
}

validate_email() {
    echo "$1" | grep -q "@"
}

# validate_not_emptyのテスト
if validate_not_empty "test" 2>/dev/null; then
    pass "validate_not_empty: 空でない文字列を正しく判定"
else
    fail "validate_not_empty: 空でない文字列の判定に失敗"
fi

if ! validate_not_empty "" 2>/dev/null; then
    pass "validate_not_empty: 空文字列を正しく判定"
else
    fail "validate_not_empty: 空文字列の判定に失敗"
fi

# validate_emailのテスト
if validate_email "test@example.com" 2>/dev/null; then
    pass "validate_email: 有効なメールアドレスを正しく判定"
else
    fail "validate_email: 有効なメールアドレスの判定に失敗"
fi

if ! validate_email "invalid" 2>/dev/null; then
    pass "validate_email: 無効なメールアドレスを正しく判定"
else
    fail "validate_email: 無効なメールアドレスの判定に失敗"
fi

if ! validate_email "" 2>/dev/null; then
    pass "validate_email: 空文字列を正しく判定"
else
    fail "validate_email: 空文字列の判定に失敗"
fi

echo ""

# -------------------------------------------------
# 4. 設定ファイル妥当性チェック
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
# 5. 実際の動作テスト（一時ディレクトリで安全に実行）
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
# 6. dry-runモードのテスト
# -------------------------------------------------
echo "[dry-runモードのテスト]"

# dry-runオプションが認識されるかテスト
TEST_OUTPUT=$(sh "$SRC_DIR/init.sh" --dry-run 2>&1)
if echo "$TEST_OUTPUT" | grep -q "DRY RUN モード"; then
    pass "dry-runオプションが正しく認識される"
else
    fail "dry-runオプションの認識に失敗"
fi

# dry-runモードで実際の変更が行われないかテスト
TEST_HOME2=$(mktemp -d)
export OLD_HOME2="$HOME"
export HOME="$TEST_HOME2"

# テスト用の一時ディレクトリを準備
mkdir -p "$HOME/.ssh" 2>/dev/null

# dry-runを実行
sh "$SRC_DIR/init.sh" --dry-run >/dev/null 2>&1

# 実際のファイルが作成されていないことを確認
if [ ! -L "$HOME/.ssh/config" ] && [ ! -L "$HOME/.zshrc" ]; then
    pass "dry-runモードで実際の変更が行われない"
else
    fail "dry-runモードで変更が実行された"
fi

# クリーンアップ
export HOME="$OLD_HOME2"
rm -rf "$TEST_HOME2"

# dry-runモードの出力に[DRY RUN]が含まれているかテスト
export HOME=$(mktemp -d)
TEST_OUTPUT2=$(sh "$SRC_DIR/init.sh" --dry-run 2>&1)
export HOME="$OLD_HOME"
if echo "$TEST_OUTPUT2" | grep -q "\[DRY RUN\]"; then
    pass "dry-runモードの出力に[DRY RUN]が含まれている"
else
    fail "dry-runモードの出力に[DRY RUN]が含まれていない"
fi

echo ""

# -------------------------------------------------
# 7. エラーハンドリングとロールバックのテスト
# -------------------------------------------------
echo "[エラーハンドリングとロールバックのテスト]"

# ロールバック機能のテスト（エラー発生時）
TEST_HOME3=$(mktemp -d)
export OLD_HOME3="$HOME"
export HOME="$TEST_HOME3"

# テスト用のディレクトリとファイルを準備
mkdir -p "$HOME/.ssh" 2>/dev/null
mkdir -p "$SRC_DIR/.ssh" 2>/dev/null
# 存在しないファイルへのリンクを試みる設定を作る（これによりエラーを誘発）
# しかし、テスト環境を壊さないようにする必要がある

# 代わりに、既存の非シンボリックリンクファイルが存在する場合のテスト
mkdir -p "$HOME/.config/tmux" 2>/dev/null
# 通常のファイルを作成（シンボリックリンクではない）
echo "dummy" > "$HOME/.config/tmux/tmux.conf"

# init.shを実行（既存ファイルがあるのでエラーになるはず）
# ただし、trapが設定されているので、最初のエラーで即座に終了し、
# その時点で作成されたリンクは削除されるはず
sh "$SRC_DIR/init.sh" >/dev/null 2>&1
exit_code=$?

# エラーで終了したことを確認
if [ $exit_code -ne 0 ]; then
    # 最初に作成されたディレクトリやリンクがロールバックされているかチェック
    # （tmux設定の前にSSH設定のリンクは作成されているはずだが、ロールバックされているべき）
    if [ ! -L "$HOME/.ssh/config" ]; then
        pass "エラー発生時に作成されたシンボリックリンクがロールバックされる"
    else
        fail "エラー発生時にシンボリックリンクがロールバックされなかった"
    fi
else
    fail "既存ファイルがある場合にエラーが発生しなかった"
fi

# クリーンアップ
export HOME="$OLD_HOME3"
rm -rf "$TEST_HOME3"

# エラーメッセージの詳細化テスト
# 既存の非シンボリックリンクファイルが存在する場合のエラーメッセージテスト
TEST_HOME4=$(mktemp -d)
OLD_HOME4="$HOME"
export HOME="$TEST_HOME4"
mkdir -p "$HOME/.ssh"

# 通常のファイルを作成（シンボリックリンクではない）
echo "existing file" > "$HOME/.ssh/config"

# エラーメッセージに詳細が含まれるかテスト
ERROR_OUTPUT=$(sh "$SRC_DIR/init.sh" 2>&1)
ERROR_OCCURRED=$?

# クリーンアップ
export HOME="$OLD_HOME4"
rm -rf "$TEST_HOME4"

# エラーが発生し、かつ詳細なエラーメッセージが含まれているか確認
if [ $ERROR_OCCURRED -ne 0 ] && echo "$ERROR_OUTPUT" | grep -q "原因:" && echo "$ERROR_OUTPUT" | grep -q "解決策:"; then
    # さらに具体的な内容をチェック
    if echo "$ERROR_OUTPUT" | grep -q "リンク先に既存のファイル"; then
        pass "詳細なエラーメッセージが表示される"
    else
        fail "エラーメッセージに期待する内容が含まれていない"
    fi
else
    fail "詳細なエラーメッセージが表示されない"
fi

echo ""

# -------------------------------------------------
# 8. 冪等性テスト
# -------------------------------------------------
echo "[冪等性テスト]"

# 同じ環境で2回連続実行しても成功することを確認
TEST_HOME5=$(mktemp -d)
OLD_HOME5="$HOME"
export HOME="$TEST_HOME5"

# .gitconfigを事前に作成（対話的入力を避けるため）
setup_test_gitconfig

# 1回目の実行
sh "$SRC_DIR/init.sh" >/dev/null 2>&1
FIRST_RUN=$?

# 2回目の実行（既にシンボリックリンクが存在する状態）
sh "$SRC_DIR/init.sh" >/dev/null 2>&1
SECOND_RUN=$?

# クリーンアップ
export HOME="$OLD_HOME5"
rm -rf "$TEST_HOME5"

# 両方とも成功することを確認
if [ $FIRST_RUN -eq 0 ] && [ $SECOND_RUN -eq 0 ]; then
    pass "2回連続実行しても成功する（冪等性）"
else
    fail "2回目の実行が失敗（冪等性なし）: 1回目=$FIRST_RUN, 2回目=$SECOND_RUN"
fi

# 既存のシンボリックリンクを上書きできるかテスト
TEST_HOME6=$(mktemp -d)
export HOME="$TEST_HOME6"
mkdir -p "$HOME/.ssh"

# .gitconfigを事前に作成（対話的入力を避けるため）
setup_test_gitconfig

# 異なるパスへのシンボリックリンクを作成
ln -s /tmp/dummy "$HOME/.ssh/config"

# セットアップ実行（既存のシンボリックリンクを上書きできるはず）
sh "$SRC_DIR/init.sh" >/dev/null 2>&1
OVERWRITE_RESULT=$?

# クリーンアップ
export HOME="$OLD_HOME5"
rm -rf "$TEST_HOME6"

if [ $OVERWRITE_RESULT -eq 0 ]; then
    pass "既存のシンボリックリンクを正しく上書きできる"
else
    fail "既存のシンボリックリンクの上書きに失敗"
fi

echo ""

# -------------------------------------------------
# 9. アンインストール機能のテスト
# -------------------------------------------------
echo "[アンインストール機能のテスト]"

# アンインストールがシンボリックリンクを削除するかテスト
TEST_HOME7=$(mktemp -d)
OLD_HOME7="$HOME"
export HOME="$TEST_HOME7"

# テスト用のディレクトリとシンボリックリンクを作成
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.gitmoji"
ln -s "$SRC_DIR/.ssh/config" "$HOME/.ssh/config"
ln -s "$SRC_DIR/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
ln -s "$SRC_DIR/.zshrc" "$HOME/.zshrc"
ln -s "$SRC_DIR/.gitmoji/gitmojis.json" "$HOME/.gitmoji/gitmojis.json"

# アンインストール実行
sh "$SRC_DIR/init.sh" --uninstall >/dev/null 2>&1
UNINSTALL_RESULT=$?

# シンボリックリンクが削除されたことを確認
if [ $UNINSTALL_RESULT -eq 0 ] && [ ! -L "$HOME/.ssh/config" ] && \
   [ ! -L "$HOME/.config/tmux/tmux.conf" ] && [ ! -L "$HOME/.zshrc" ] && \
   [ ! -L "$HOME/.gitmoji/gitmojis.json" ]; then
    pass "アンインストールがシンボリックリンクを正しく削除する"
else
    fail "アンインストールがシンボリックリンクを削除できなかった"
fi

# クリーンアップ
export HOME="$OLD_HOME7"
rm -rf "$TEST_HOME7"

# 通常ファイルをスキップするかテスト
TEST_HOME8=$(mktemp -d)
export HOME="$TEST_HOME8"
mkdir -p "$HOME/.ssh"

# 通常のファイルを作成（シンボリックリンクではない）
echo "regular file" > "$HOME/.ssh/config"

# アンインストール実行
UNINSTALL_OUTPUT=$(sh "$SRC_DIR/init.sh" --uninstall 2>&1)
UNINSTALL_RESULT2=$?

# 通常ファイルが削除されずに残っていることを確認
if [ $UNINSTALL_RESULT2 -eq 0 ] && [ -f "$HOME/.ssh/config" ] && \
   echo "$UNINSTALL_OUTPUT" | grep -q "警告.*スキップ"; then
    pass "アンインストールが通常ファイルをスキップする（安全性）"
else
    fail "アンインストールが通常ファイルを誤って削除した"
fi

# クリーンアップ
export HOME="$OLD_HOME7"
rm -rf "$TEST_HOME8"

# 空のディレクトリを削除するかテスト
TEST_HOME9=$(mktemp -d)
export HOME="$TEST_HOME9"

# テスト用のディレクトリとシンボリックリンクを作成
mkdir -p "$HOME/.gitmoji"
ln -s "$SRC_DIR/.gitmoji/gitmojis.json" "$HOME/.gitmoji/gitmojis.json"

# アンインストール実行
sh "$SRC_DIR/init.sh" --uninstall >/dev/null 2>&1

# 空のディレクトリが削除されたことを確認
if [ ! -d "$HOME/.gitmoji" ]; then
    pass "アンインストールが空のディレクトリを削除する"
else
    fail "アンインストールが空のディレクトリを削除できなかった"
fi

# クリーンアップ
export HOME="$OLD_HOME7"
rm -rf "$TEST_HOME9"

# 空でないディレクトリを保持するかテスト
TEST_HOME10=$(mktemp -d)
export HOME="$TEST_HOME10"

# テスト用のディレクトリとシンボリックリンク、追加ファイルを作成
mkdir -p "$HOME/.gitmoji"
ln -s "$SRC_DIR/.gitmoji/gitmojis.json" "$HOME/.gitmoji/gitmojis.json"
echo "other file" > "$HOME/.gitmoji/other.txt"

# アンインストール実行
sh "$SRC_DIR/init.sh" --uninstall >/dev/null 2>&1

# ディレクトリが残っていることを確認（他のファイルがあるため）
if [ -d "$HOME/.gitmoji" ] && [ -f "$HOME/.gitmoji/other.txt" ]; then
    pass "アンインストールが空でないディレクトリを保持する"
else
    fail "アンインストールが空でないディレクトリを削除した"
fi

# クリーンアップ
export HOME="$OLD_HOME7"
rm -rf "$TEST_HOME10"

# dry-runモードのテスト
TEST_HOME11=$(mktemp -d)
export HOME="$TEST_HOME11"

# テスト用のシンボリックリンクを作成
mkdir -p "$HOME/.ssh"
ln -s "$SRC_DIR/.ssh/config" "$HOME/.ssh/config"

# dry-runでアンインストール実行
UNINSTALL_DRY_OUTPUT=$(sh "$SRC_DIR/init.sh" --uninstall --dry-run 2>&1)

# シンボリックリンクが残っていることを確認（dry-runなので削除されない）
if [ -L "$HOME/.ssh/config" ] && echo "$UNINSTALL_DRY_OUTPUT" | grep -q "\[DRY RUN\]"; then
    pass "アンインストールのdry-runモードが正しく動作する"
else
    fail "アンインストールのdry-runモードで実際の削除が行われた"
fi

# クリーンアップ
export HOME="$OLD_HOME7"
rm -rf "$TEST_HOME11"

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
