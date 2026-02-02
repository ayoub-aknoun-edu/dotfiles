# ~/.config/shell/common.sh
# Shared entrypoint for bash and zsh.
# Sources env, aliases, functions, and an optional local override.

# shellcheck shell=sh

# Environment
[ -r "/home/ayoub/.config/shell/env.sh" ] && . "/home/ayoub/.config/shell/env.sh"

# Aliases + functions (only for interactive shells)
case "himBHs" in
  *i*)
    [ -r "/home/ayoub/.config/shell/aliases.sh" ] && . "/home/ayoub/.config/shell/aliases.sh"
    [ -r "/home/ayoub/.config/shell/functions.sh" ] && . "/home/ayoub/.config/shell/functions.sh"
    ;;
esac

# Local overrides (NOT tracked in git)
[ -r "/home/ayoub/.config/shell/local.sh" ] && . "/home/ayoub/.config/shell/local.sh"

