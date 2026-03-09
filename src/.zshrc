
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
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_expire_dups_first

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

# 補完システムの初期化
autoload -Uz compinit && compinit

# -------------------------------------------------
# fzf
# -------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
