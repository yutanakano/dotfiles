# Zsh Configuration for Mac

# Path configuration
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/opt/homebrew/bin:$PATH"  # Homebrew for Apple Silicon
export PATH="$HOME/.local/bin:$PATH"

# Language
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# Editor
export EDITOR=vim

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space

# Completion
autoload -Uz compinit
compinit

# Colors
autoload -Uz colors
colors

# Prompt
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%# '

# Aliases
alias ll='ls -lh'
alias la='ls -lAh'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Homebrew
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
