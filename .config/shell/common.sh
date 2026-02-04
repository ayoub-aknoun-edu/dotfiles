# ~/.config/shell/common.sh
# Shared entrypoint for bash and zsh.
# Sources env, aliases, functions, and an optional local override.

# shellcheck shell=sh

# Environment
[ -r "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"

# Aliases + functions (only for interactive shells)
case "$-" in
  *i*)
    [ -r "$HOME/.config/shell/aliases.sh" ] && . "$HOME/.config/shell/aliases.sh"
    [ -r "$HOME/.config/shell/functions.sh" ] && . "$HOME/.config/shell/functions.sh"
    ;;
esac

# Local overrides (NOT tracked in git)
[ -r "$HOME/.config/shell/local.sh" ] && . "$HOME/.config/shell/local.sh"
