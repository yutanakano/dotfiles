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

autoload -Uz add-zsh-hook
add-zsh-hook precmd _cmux_auto_layout
