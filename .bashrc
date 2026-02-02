# ~/.bashrc
# Minimal bash config to share most stuff with zsh.
# (Even if you switch to zsh as your main shell, keeping this helps for rescue shells.)

# If not running interactively, don't do anything
case himBHs in
  *i*) ;;
  *) return ;;
esac

# Shared config (env, aliases, functions)
if [ -r "/home/ayoub/.config/shell/common.sh" ]; then
  . "/home/ayoub/.config/shell/common.sh"
fi

# Bash-specific niceties
export HISTCONTROL=ignoreboth
shopt -s histappend 2>/dev/null || true
export PROMPT_DIRTRIM=3

# Enable bash completion if available
if [ -r /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

