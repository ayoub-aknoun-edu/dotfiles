# ~/.config/shell/functions.sh
# Shared functions for bash and zsh.

# Make a directory and cd into it
mkcd() {
  mkdir -p -- "" && cd -- "" || return
}

# Extract almost anything
extract() {
  if [ -f "" ]; then
    case "" in
      *.tar.bz2) tar xjf "" ;;
      *.tar.gz)  tar xzf "" ;;
      *.bz2)     bunzip2 "" ;;
      *.rar)     unrar x "" ;;
      *.gz)      gunzip "" ;;
      *.tar)     tar xf "" ;;
      *.tbz2)    tar xjf "" ;;
      *.tgz)     tar xzf "" ;;
      *.zip)     unzip "" ;;
      *.Z)       uncompress "" ;;
      *.7z)      7z x "" ;;
      *)         printf '%s
' "extract: don't know how to extract ''" ;;
    esac
  else
    printf '%s
' "extract: '' is not a valid file"
  fi
}

# Quick grep (prefers ripgrep)
rgrep() {
  if command -v rg >/dev/null 2>&1; then
    rg ""
  else
    grep -R --line-number --color=auto ""
  fi
}
