# ~/.config/shell/aliases.sh
# Shared aliases for bash and zsh.

# Safer defaults
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Listing helpers
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias c='clear'
# Common shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts
alias g='git'
alias gs='git status'
alias gl='git log --oneline --graph --decorate --all'

# Prefer Neovim if installed
command -v nvim >/dev/null 2>&1 && alias vim='nvim'

# Use eza/bat if installed (optional)
command -v eza >/dev/null 2>&1 && alias ls='eza --group-directories-first --icons'
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
