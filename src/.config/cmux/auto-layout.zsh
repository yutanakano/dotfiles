# cmux新規ワークスペース作成時に5パネルレイアウトを自動適用する

_CMUX_KNOWN_WORKSPACES_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/cmux/known-workspaces"

_cmux_auto_layout() {
  # cmux環境でない場合はスキップ
  [[ -z "$CMUX_WORKSPACE_ID" ]] && return

  # 未知のワークスペースならレイアウトを適用
  if ! grep -qF "$CMUX_WORKSPACE_ID" "$_CMUX_KNOWN_WORKSPACES_FILE" 2>/dev/null; then
    mkdir -p "$(dirname "$_CMUX_KNOWN_WORKSPACES_FILE")"
    echo "$CMUX_WORKSPACE_ID" >> "$_CMUX_KNOWN_WORKSPACES_FILE"
    sh ~/.config/cmux/5pane.sh
  fi
}

# cmux new-splitがPTYサイズを更新しないバグの回避策
# ANSIエスケープシーケンスで実サイズを取得しsttyで設定する
_cmux_fix_pty_size() {
  add-zsh-hook -d precmd _cmux_fix_pty_size
  local rows cols
  printf '\e7\e[9999;9999H\e[6n\e8' > /dev/tty
  IFS='[;' read -sdR _ rows cols < /dev/tty
  if [[ -n "$cols" && -n "$rows" && "$cols" != "$COLUMNS" ]]; then
    command stty rows "$rows" columns "$cols" < /dev/tty
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _cmux_auto_layout
add-zsh-hook precmd _cmux_fix_pty_size
