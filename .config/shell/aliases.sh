# ~/.config/shell/aliases.sh
# Shared aliases for bash and zsh.

# Safer defaults
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I --preserve-root'

# clear
alias cls='clear'
alias c='clear'

# Common shortcuts
alias ..='z ..'
alias ...='z ../..'
alias ....='z ../../..'

# Git shortcuts
alias g='git'
alias gs='git status'
alias gl='git log --oneline --graph --decorate --all'

# ssh
alias ssh='kitten ssh'

# Prefer Neovim if installed
command -v nvim >/dev/null 2>&1 && alias vim='nvim'

# Use eza/bat if installed (optional)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -a --group-directories-first --icons'
  alias ll='eza -la --group-directories-first --icons'
  alias tree='eza --tree --icons'
fi

# Prefer ripgrep if installed
if command -v rg >/dev/null 2>&1; then
  alias grep='rg --smart-case'
fi

# Pacman helpers
alias pacup='sudo pacman -Syu'
alias pacs='pacman -Ss'
alias paci='sudo pacman -S'
alias pacr='sudo pacman -Rns'

command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
