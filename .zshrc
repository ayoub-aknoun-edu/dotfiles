# ~/.zshrc
#
# This config is meant to be beginner-friendly:
# - works even if Oh My Zsh is not installed yet
# - keeps defaults sane (history, completion)

# ---- Basics ----
export EDITOR="nvim"
export VISUAL="nvim"

# ---- Oh My Zsh ----
export ZSH="/home/ayoub/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git sudo)

if [ -r "/oh-my-zsh.sh" ]; then
  source "/oh-my-zsh.sh"
else
  autoload -Uz compinit && compinit
fi

# ---- History ----
HISTFILE="/home/ayoub/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# ---- QoL ----
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# ---- Optional extras ----
# Enable these if installed:
#   sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting
if [ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Print system info on startup (uncomment if you want it)
# command -v fastfetch >/dev/null && fastfetch

