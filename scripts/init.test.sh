#!/bin/sh
# scripts/init.sh のテスト

# カラーコード
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# テスト結果カウンター
PASSED=0
FAILED=0

# ディレクトリ
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
SRC_DIR="$DOTFILES_DIR/src"

# テスト結果を表示する関数
pass() {
    printf "${GREEN}✓${NC} %s\n" "$1"
    PASSED=$((PASSED + 1))
}

fail() {
    printf "${RED}✗${NC} %s\n" "$1"
    FAILED=$((FAILED + 1))
}

# 実環境に近いテスト用HOMEを構築する
# 実際のHOMEには~/.configや他アプリの設定が既に存在する
setup_test_home() {
    TEST_HOME=$(mktemp -d)
    mkdir -p "$TEST_HOME/.config/alacritty"
    echo "font_size: 14" > "$TEST_HOME/.config/alacritty/alacritty.yml"
    mkdir -p "$TEST_HOME/.config/Code/User"
    echo '{"editor.fontSize": 14}' > "$TEST_HOME/.config/Code/User/settings.json"
    echo "[user]" > "$TEST_HOME/.gitconfig"
    echo "  name = Test User" >> "$TEST_HOME/.gitconfig"
    echo "  email = test@example.com" >> "$TEST_HOME/.gitconfig"
    echo "$TEST_HOME"
}

# テスト用HOMEをクリーンアップする
cleanup_test_home() {
    test_home="$1"
    if [ -n "$test_home" ] && [ -d "$test_home" ]; then
        stow -D -t "$test_home" -d "$DOTFILES_DIR" src 2>/dev/null
        rm -rf "$test_home"
    fi
}

echo ""
echo "=== scripts/init.sh のテスト ==="
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

check_file_exists "$SCRIPTS_DIR/init.sh" "scripts/init.shが存在する"
check_file_exists "$DOTFILES_DIR/templates/.gitconfig" "templates/.gitconfigが存在する"
check_file_exists "$SRC_DIR/.zshrc" ".zshrcが存在する"
check_file_exists "$SRC_DIR/.Brewfile" ".Brewfileが存在する"
check_file_exists "$SRC_DIR/.ssh/config" "SSH設定が存在する"
check_file_exists "$SRC_DIR/.config/starship.toml" "Starship設定が存在する"
check_file_exists "$SRC_DIR/.config/tmux/tmux.conf" "tmux設定が存在する"
check_file_exists "$SRC_DIR/.config/tmux/editor.sh" "tmux editor.shが存在する"
check_file_exists "$SRC_DIR/.config/tmux/quad.sh" "tmux quad.shが存在する"
check_file_exists "$SRC_DIR/.config/ghostty/config" "Ghostty設定が存在する"
check_file_exists "$SRC_DIR/.config/mise/config.toml" "mise設定が存在する"
check_file_exists "$SRC_DIR/.config/nvim/init.lua" "Neovim設定(LazyVim)が存在する"
check_file_exists "$SRC_DIR/.gitmoji/gitmojis.json" "gitmoji設定が存在する"

echo ""

# -------------------------------------------------
# 2. スクリプト構文チェック
# -------------------------------------------------
echo "[スクリプト構文チェック]"

if sh -n "$SCRIPTS_DIR/init.sh" 2>/dev/null; then
    pass "scripts/init.shの構文が正しい"
else
    fail "scripts/init.shの構文にエラーがある"
fi

echo ""

# -------------------------------------------------
# 3. stowの存在チェック
# -------------------------------------------------
echo "[依存ツールチェック]"

if command -v stow >/dev/null 2>&1; then
    pass "stowがインストールされている"
else
    fail "stowがインストールされていない (brew install stow)"
fi

echo ""

# -------------------------------------------------
# 4. 入力検証関数のテスト
# -------------------------------------------------
echo "[入力検証関数のテスト]"

# 検証関数を定義（init.shから抽出）
validate_not_empty() {
    [ -n "$1" ]
}

validate_email() {
    echo "$1" | grep -q "@"
}

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
# 5. 設定ファイル妥当性チェック
# -------------------------------------------------
echo "[設定ファイル妥当性チェック]"

if command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$SRC_DIR/.gitmoji/gitmojis.json" >/dev/null 2>&1; then
        pass "gitmojis.jsonの形式が正しい"
    else
        fail "gitmojis.jsonの形式が不正"
    fi
else
    printf "${YELLOW}⊘${NC} gitmojis.json (python3がないためスキップ)\n"
fi

if grep -q "\[tools\]" "$SRC_DIR/.config/mise/config.toml" 2>/dev/null; then
    pass "mise config.tomlの形式が正しい"
else
    fail "mise config.tomlに[tools]セクションが見つからない"
fi

if grep -qE "tap|brew|cask|mas|vscode" "$SRC_DIR/.Brewfile" 2>/dev/null; then
    pass "Brewfileの形式が正しい"
else
    fail "Brewfileに必要なキーワードが見つからない"
fi

if grep -q 'brew "stow"' "$SRC_DIR/.Brewfile" 2>/dev/null; then
    pass "Brewfileにstowが含まれている"
else
    fail "Brewfileにstowが含まれていない"
fi

echo ""

# -------------------------------------------------
# 6. 実際の動作テスト（実環境に近い条件）
# -------------------------------------------------
echo "[動作テスト]"

if ! command -v stow >/dev/null 2>&1; then
    printf "${YELLOW}⊘${NC} stowがないため動作テストをスキップ\n"
else
    REAL_HOME="$HOME"
    TEST_HOME=$(setup_test_home)
    export HOME="$TEST_HOME"
    trap 'export HOME="$REAL_HOME"; cleanup_test_home "$TEST_HOME"' EXIT

    # セットアップ実行
    sh "$SCRIPTS_DIR/init.sh" >/dev/null 2>&1
    INSTALL_RESULT=$?

    if [ $INSTALL_RESULT -eq 0 ]; then
        pass "stowによるセットアップが成功する"
    else
        fail "stowによるセットアップが失敗した"
    fi

    # dotfilesのシンボリックリンクが作成されたか
    if [ -L "$HOME/.zshrc" ] && [ -f "$HOME/.ssh/config" ] && [ -L "$HOME/.config/nvim" ]; then
        pass "dotfilesのシンボリックリンクが正しく作成される"
    else
        fail "dotfilesのシンボリックリンクの作成に失敗"
    fi

    # ~/.configが丸ごとリンクされていないこと（tree folding防止）
    if [ -d "$HOME/.config" ] && [ ! -L "$HOME/.config" ]; then
        pass "~/.configがディレクトリのまま保持されている（tree folding防止）"
    else
        fail "~/.configがシンボリックリンクになっている（tree foldingが発生）"
    fi

    # ~/.sshが丸ごとリンクされていないこと（秘密鍵がリポジトリに入るリスク防止）
    if [ -d "$HOME/.ssh" ] && [ ! -L "$HOME/.ssh" ]; then
        pass "~/.sshがディレクトリのまま保持されている（tree folding防止）"
    else
        fail "~/.sshがシンボリックリンクになっている（tree foldingが発生）"
    fi

    # 既存の設定ファイルが破壊されていないこと
    if [ -f "$HOME/.config/alacritty/alacritty.yml" ] && [ -f "$HOME/.config/Code/User/settings.json" ]; then
        pass "既存の設定ファイルが保持されている"
    else
        fail "既存の設定ファイルが破壊された"
    fi

    # クリーンアップ（trapで行うが、次のテストのために手動でも実行）
    stow -D -t "$HOME" -d "$DOTFILES_DIR" src 2>/dev/null
    export HOME="$REAL_HOME"
    rm -rf "$TEST_HOME"
    trap - EXIT
fi

echo ""

# -------------------------------------------------
# 7. 冪等性テスト
# -------------------------------------------------
echo "[冪等性テスト]"

if ! command -v stow >/dev/null 2>&1; then
    printf "${YELLOW}⊘${NC} stowがないため冪等性テストをスキップ\n"
else
    REAL_HOME="$HOME"
    TEST_HOME=$(setup_test_home)
    export HOME="$TEST_HOME"
    trap 'export HOME="$REAL_HOME"; cleanup_test_home "$TEST_HOME"' EXIT

    # 1回目の実行
    sh "$SCRIPTS_DIR/init.sh" >/dev/null 2>&1
    FIRST_RUN=$?

    # 2回目の実行
    sh "$SCRIPTS_DIR/init.sh" >/dev/null 2>&1
    SECOND_RUN=$?

    if [ $FIRST_RUN -eq 0 ] && [ $SECOND_RUN -eq 0 ]; then
        pass "2回連続実行しても成功する（冪等性）"
    else
        fail "2回目の実行が失敗（冪等性なし）: 1回目=$FIRST_RUN, 2回目=$SECOND_RUN"
    fi

    # 既存ファイルが2回実行後も保持されているか
    if [ -f "$HOME/.config/alacritty/alacritty.yml" ]; then
        pass "冪等性テスト後も既存ファイルが保持されている"
    else
        fail "冪等性テスト後に既存ファイルが失われた"
    fi

    # クリーンアップ
    stow -D -t "$HOME" -d "$DOTFILES_DIR" src 2>/dev/null
    export HOME="$REAL_HOME"
    rm -rf "$TEST_HOME"
    trap - EXIT
fi

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
