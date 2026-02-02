#~/.config / shell / env.sh
#Shared environment variables for bash and zsh.
#Keep this file POSIX - ish so both shells can source it.

export EDITOR="nvim"
export VISUAL="nvim"

#XDG base dirs(used by several tools)
export XDG_CONFIG_HOME="/home/ayoub/.config"
export XDG_CACHE_HOME="/home/ayoub/.cache"
export XDG_DATA_HOME="/home/ayoub/.local/share"

#-- - Android SDK(Flutter / adb / sdks) -- -
export ANDROID_HOME="$HOME/.local/share/sdk/android"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
#-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

#Make sure ~/.local / bin is in PATH(where your helper scripts live)
case ":/home/ayoub/.local/share/sdk/android/cmdline-tools/latest/bin:/home/ayoub/.local/share/sdk/android/platform-tools:/home/ayoub/.local/share/sdk/android/emulator:/home/ayoub/.local/share/sdk/android/cmdline-tools/latest/bin:/home/ayoub/.local/share/sdk/android/platform-tools:/home/ayoub/.local/share/sdk/android/emulator:/home/ayoub/.local/share/sdk/android/cmdline-tools/latest/bin:/home/ayoub/.local/share/sdk/android/platform-tools:/home/ayoub/.local/share/sdk/android/emulator:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:" in
  *":/home/ayoub/.local/bin:"*) ;;
  *) PATH="/home/ayoub/.local/bin:/home/ayoub/.local/share/sdk/android/cmdline-tools/latest/bin:/home/ayoub/.local/share/sdk/android/platform-tools:/home/ayoub/.local/share/sdk/android/emulator:/home/ayoub/.local/share/sdk/android/cmdline-tools/latest/bin:/home/ayoub/.local/share/sdk/android/platform-tools:/home/ayoub/.local/share/sdk/android/emulator:/home/ayoub/.local/share/sdk/android/cmdline-tools/latest/bin:/home/ayoub/.local/share/sdk/android/platform-tools:/home/ayoub/.local/share/sdk/android/emulator:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl" ;;
esac
export PATH

#Use your browser wrapper if present
if [ -x "/home/ayoub/.local/bin/browser" ]; then
  export BROWSER="/home/ayoub/.local/bin/browser"
fi

#Nicer pager output(works with bat too, if you use it)
export LESS="-R"
