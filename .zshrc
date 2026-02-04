# ~/.zshrc
#
# Goals:
# - Works even before Oh My Zsh is installed
# - Keeps config mostly in shared files so you can migrate from bash gradually
# - Uses XDG-friendly locations when possible

# ----------------------------
# Shared config (bash + zsh)
# ----------------------------
# env.sh / aliases.sh / functions.sh / local.sh
if [ -r "$HOME/.config/shell/common.sh" ]; then
  source "$HOME/.config/shell/common.sh"
fi

# ----------------------------
# Zsh options
# ----------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# History (good defaults)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# ----------------------------
# Completion (works with or without OMZ)
# ----------------------------
autoload -Uz compinit

# Put compdump in cache
_cache_dir="$HOME/.cache/zsh"
mkdir -p "$HOME/.cache/zsh" 2>/dev/null
compinit -d "$HOME/.cache/zsh/zcompdump-5.9" 2>/dev/null

# Nicer completion menu
zmodload zsh/complist 2>/dev/null || true
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.jxl=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:"

# ----------------------------
# Oh My Zsh (optional)
# ----------------------------
# Manual install (no remote installer script):
#   git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
# Then open a new terminal.
if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"
elif [ -d "$HOME/dotfiles/vendor/oh-my-zsh" ]; then
  export ZSH="$HOME/dotfiles/vendor/oh-my-zsh"
fi

ZSH_THEME="robbyrussell"
plugins=(git sudo archlinux)

if [ -n "${ZSH:-}" ] && [ -r "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"

  # Re-apply your shared aliases/functions after OMZ so your preferences win.
  if [ -r "$HOME/.config/shell/common.sh" ]; then
    source "$HOME/.config/shell/common.sh"
  fi
fi

# ----------------------------
# Keybindings
# ----------------------------
bindkey -e  # Emacs-like keys (Ctrl+A, Ctrl+E, etc.)

# ----------------------------
# Optional extras (pacman)
# ----------------------------
# Install on Arch:
#   sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting
if [ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ----------------------------
# Optional tools (nice-to-have)
# ----------------------------
# zoxide: smarter directory jumping (safe init; no eval)
# Install on Arch: sudo pacman -S zoxide
if whence -p zoxide >/dev/null 2>&1; then
  # Validate generated init code before loading it.
  if command zoxide init zsh 2>/dev/null | zsh -n /dev/stdin 2>/dev/null; then
    # Load using process substitution (avoids eval and avoids writing files).
    source <(command zoxide init zsh 2>/dev/null)
  else
    print -r -- "zsh: zoxide init script has syntax errors; skipping" >&2
    precmd_functions=(_omz_async_request omz_termsupport_precmd _zsh_autosuggest_start _zsh_highlight_main__precmd_hook) 2>/dev/null || true
    unfunction __zoxide_pwd 2>/dev/null || true
  fi
fi

# fzf: fuzzy finder (binds Ctrl+R, etc.)
# Install on Arch: sudo pacman -S fzf
if [ -r /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
fi
if [ -r /usr/share/fzf/completion.zsh ]; then
  source /usr/share/fzf/completion.zsh
fi
