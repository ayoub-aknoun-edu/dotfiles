# ~/.bashrc
# Minimal bash config to share most stuff with zsh.
# (Even if you switch to zsh as your main shell, keeping this helps for rescue shells.)

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return ;;
esac

# Shared config (env, aliases, functions)
if [ -r "$HOME/.config/shell/common.sh" ]; then
  . "$HOME/.config/shell/common.sh"
fi

# Bash-specific niceties
export HISTCONTROL=ignoreboth
shopt -s histappend 2>/dev/null || true
export PROMPT_DIRTRIM=3

# Enable bash completion if available
if [ -r /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

# Angular CLI completion. `ng completion script` boots node (~0.2s), so cache it
# and regenerate only when the ng binary is newer than the cache.
if command -v ng >/dev/null 2>&1; then
  _ng_cache="${XDG_CACHE_HOME:-$HOME/.cache}/ng-completion.bash"
  if [ ! -s "$_ng_cache" ] || [ "$(command -v ng)" -nt "$_ng_cache" ]; then
    mkdir -p "${_ng_cache%/*}" && SHELL=/bin/bash ng completion script >"$_ng_cache" 2>/dev/null
  fi
  [ -s "$_ng_cache" ] && . "$_ng_cache"
  unset _ng_cache
fi
