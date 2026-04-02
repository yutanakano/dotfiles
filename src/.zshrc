
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# -------------------------------------------------
# homebrewのパス
# -------------------------------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"

# -------------------------------------------------
# miseのパス
# -------------------------------------------------
eval "$(mise activate zsh)"

# -------------------------------------------------
# エディタ
# -------------------------------------------------
export EDITOR="nvim"
export VISUAL="nvim"

# -------------------------------------------------
# AndroidStudioのパス
# -------------------------------------------------
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools

# -------------------------------------------------
# Starshipのパス
# -------------------------------------------------
eval "$(starship init zsh)"

# -------------------------------------------------
# Zinit
# -------------------------------------------------
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

### End of Zinit's installer chunk

# -------------------------------------------------
# コマンドの履歴の設定
# -------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_expire_dups_first

# -------------------------------------------------
# ディレクトリ移動
# -------------------------------------------------
setopt auto_cd            # ディレクトリ名だけで cd
setopt auto_pushd         # cd で自動的にスタックに積む
setopt pushd_ignore_dups  # スタックの重複を除去

# -------------------------------------------------
# シェルの挙動
# -------------------------------------------------
setopt correct              # コマンドのタイポを自動提案
setopt no_beep              # ビープ音を無効化
setopt interactive_comments # シェル上で # 以降をコメントとして扱う
setopt print_eight_bit      # 日本語ファイル名を正しく表示

# -------------------------------------------------
# 補完の強化
# -------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # 小文字で大文字もマッチ
zstyle ':completion:*' menu select                     # TAB で候補をハイライト選択

# -------------------------------------------------
# プラグイン
# -------------------------------------------------

# 補完定義の拡充
zinit ice depth=1
zinit light zsh-users/zsh-completions

# 補完
zinit ice depth=1
zinit light zsh-users/zsh-autosuggestions

# 過去に移動したことのあるディレクトリ名を指定して移動
zinit ice depth=1
zinit load agkozak/zsh-z

# 親ディレクトリへ移動
zinit ice depth=1
zinit load Tarrasch/zsh-bd

# シンタックスハイライト（他のプラグインの後に読み込む）
zinit ice depth=1
zinit light zdharma-continuum/fast-syntax-highlighting

# 入力途中の文字列で履歴を↑↓検索
zinit ice depth=1
zinit light zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# 補完システムの初期化
autoload -Uz compinit && compinit

# TAB補完をfzfのUIで表示
zinit ice depth=1
zinit light Aloxaf/fzf-tab

# -------------------------------------------------
# fzf
# -------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -------------------------------------------------
# Yazi (cd-on-exit wrapper)
# -------------------------------------------------
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# -------------------------------------------------
# cmux自動レイアウト
# -------------------------------------------------
[[ -n "$CMUX_WORKSPACE_ID" || -n "$CMUX_PANEL_ID" ]] && source ~/.config/cmux/auto-layout.zsh

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
