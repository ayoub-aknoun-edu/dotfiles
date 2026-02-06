# ~/.config/shell/functions.sh
# Shared functions for bash and zsh.

# Make a directory and cd into it
mkcd() {
  [ -n "$1" ] || { printf '%s\n' "mkcd: missing directory name"; return 2; }
  mkdir -p -- "$1" && cd -- "$1" || return
}

# Extract almost anything
extract() {
  [ -f "$1" ] || { printf '%s\n' "extract: '$1' is not a file"; return 2; }
  dest="${2:-.}"
  mkdir -p -- "$dest" || return

  if command -v bsdtar >/dev/null 2>&1; then
    bsdtar -xf "$1" -C "$dest"
    return $?
  fi

  # Fallbacks if bsdtar isn't available
  case "$1" in
    *.tar.bz2) tar xjf "$1" -C "$dest" ;;
    *.tar.gz)  tar xzf "$1" -C "$dest" ;;
    *.tar.xz)  tar xJf "$1" -C "$dest" ;;
    *.tar.zst) tar -I zstd -xf "$1" -C "$dest" ;;
    *.tar)     tar xf "$1" -C "$dest" ;;
    *.zip)     unzip "$1" -d "$dest" ;;
    *.7z)      7z x "$1" "-o$dest" ;;
    *.rar)     unrar x "$1" "$dest" ;;
    *.gz)      (cd "$dest" && gunzip -k "../$1") ;;
    *.bz2)     (cd "$dest" && bunzip2 -k "../$1") ;;
    *.xz)      (cd "$dest" && unxz -k "../$1") ;;
    *.zst)     (cd "$dest" && zstd -d -k "../$1") ;;
    *)         printf '%s\n' "extract: don't know how to extract '$1'" ; return 3 ;;
  esac
}

mkarchive() {
  [ -n "$1" ] || { printf '%s\n' "mkarchive: missing output filename"; return 2; }
  [ $# -ge 2 ] || { printf '%s\n' "mkarchive: provide files/folders to archive"; return 2; }

  out="$1"; shift

  case "$out" in
    *.tar.zst|*.tar.zstd)
      tar -I 'zstd -T0 -10' -cf "$out" "$@"
      ;;
    *.tar.gz|*.tgz)
      tar -czf "$out" "$@"
      ;;
    *.tar.xz|*.txz)
      tar -cJf "$out" "$@"
      ;;
    *.tar)
      tar -cf "$out" "$@"
      ;;
    *.zip)
      if command -v bsdtar >/dev/null 2>&1; then
        bsdtar -a -cf "$out" "$@"
      elif command -v 7z >/dev/null 2>&1; then
        7z a "$out" "$@"
      else
        printf '%s\n' "mkarchive: install bsdtar (libarchive) or 7z (7zip)"; return 3
      fi
      ;;
    *.7z)
      command -v 7z >/dev/null 2>&1 || { printf '%s\n' "mkarchive: install 7z (7zip)"; return 3; }
      7z a "$out" "$@"
      ;;
    *)
      printf '%s\n' "mkarchive: unknown format for '$out' (try .tar.zst, .zip, .7z)"
      return 3
      ;;
  esac
}

# Quick grep (prefers ripgrep)
rgrep() {
  if command -v rg >/dev/null 2>&1; then
    rg --smart-case "$@"
  else
    grep -R --line-number --color=auto "$@"
  fi
}


serve() {
  port="${1:-8000}"
  if command -v python >/dev/null 2>&1; then
    python -m http.server "$port"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -m http.server "$port"
  else
    printf '%s\n' "serve: python not found"
    return 127
  fi
}
