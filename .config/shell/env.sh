# ~/.config/shell/env.sh
# Shared environment variables for bash and zsh.
# Keep this file POSIX-ish so both shells can source it.

export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"

# XDG base dirs (used by several tools)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Android SDK (Flutter / adb / sdks)
export ANDROID_HOME="$HOME/.local/share/sdk/android"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

path_prepend() {
  case ":$PATH:" in
  *":$1:"*) ;;
  *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

path_append() {
  case ":$PATH:" in
  *":$1:"*) ;;
  *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

# Make sure ~/.local/bin is in PATH (helper scripts)
path_prepend "$HOME/.local/bin"

path_prepend "$ANDROID_HOME/cmdline-tools/latest/bin"
path_prepend "$ANDROID_HOME/platform-tools"

# Android ships QEMU-related tools inside the emulator directory.
# Keep the emulator available, but never let it shadow Arch QEMU.
# Standard POSIX append ensures it goes to the end of the line.
path_append "$ANDROID_HOME/emulator"

export PATH

# Use your browser wrapper if present
if [ -x "$HOME/.local/bin/browser" ]; then
  export BROWSER="$HOME/.local/bin/browser"
fi

# Nicer pager output (works with bat too, if you use it)
export LESS="-R"
