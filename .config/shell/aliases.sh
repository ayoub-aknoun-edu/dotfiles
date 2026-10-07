# ~/.config/shell/aliases.sh
# Shared aliases for bash and zsh.

# Safer defaults
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I --preserve-root'

# fastfetch
alias ff='fastfetch'

# lazydocker
alias lzd="lazydocker"

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

# ssh: kitten ssh copies kitty's terminfo/shell integration to the host, but only
# works when talking to kitty directly (not inside tmux, a TTY or another terminal).
if [ -n "${KITTY_WINDOW_ID:-}" ] && [ -z "${TMUX:-}" ]; then
  alias ssh='kitten ssh'
fi

# Prefer Neovim if installed
command -v nvim >/dev/null 2>&1 && alias vim='nvim'

# Use eza/bat if installed (optional)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -a --group-directories-first --icons'
  alias ll='eza -la --group-directories-first --icons'
  alias tree='eza --tree --icons'
fi

# ripgrep with smart case. grep stays real grep: rg's flags differ (-E is
# --encoding in rg), so aliasing grep broke pasted commands like `grep -E`.
if command -v rg >/dev/null 2>&1; then
  alias rg='rg --smart-case'
fi
alias grep='grep --color=auto'

# Pacman helpers
alias pacup='sudo pacman -Syu'
alias pacs='pacman -Ss'
alias paci='sudo pacman -S'
alias pacr='sudo pacman -Rns'

command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
