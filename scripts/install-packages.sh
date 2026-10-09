#!/usr/bin/env bash
# Install package profiles from packages/<profile>.txt.
#
#   scripts/install-packages.sh [--dry-run] [--yes] <profile>...
#   e.g. scripts/install-packages.sh core hw-intel dev
#
# One package per line; `#` starts a comment; `aur:` marks an AUR package
# (installed with yay, which is bootstrapped when missing). Re-runnable:
# everything uses --needed. install.sh calls this with the chosen profiles.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PKG_DIR="$(cd -- "$SCRIPT_DIR/../packages" && pwd -P)"

DRY_RUN=0
YES=0
PROFILES=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y)  YES=1 ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)        echo "unknown option: $arg" >&2; exit 1 ;;
    *)         PROFILES+=("$arg") ;;
  esac
done
(( ${#PROFILES[@]} )) || { echo "usage: $0 [--dry-run] [--yes] <profile>..." >&2; exit 1; }

run() {
  if (( DRY_RUN )); then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

NOCONFIRM=()
(( YES )) && NOCONFIRM=(--noconfirm)

NATIVE=()
AUR=()
for profile in "${PROFILES[@]}"; do
  file="$PKG_DIR/$profile.txt"
  [[ -f "$file" ]] || { echo "no such profile: $profile ($file)" >&2; exit 1; }
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [[ -z "$line" ]] && continue
    if [[ "$line" == aur:* ]]; then
      AUR+=("${line#aur:}")
    else
      NATIVE+=("$line")
    fi
  done < "$file"
done

ensure_yay() {
  command -v yay >/dev/null 2>&1 && return 0
  echo ":: Bootstrapping yay (AUR helper)"
  run sudo pacman -S --needed "${NOCONFIRM[@]}" git base-devel
  local tmp
  tmp="$(mktemp -d)"
  run git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  if (( DRY_RUN )); then
    printf '[dry-run] (cd %s && makepkg -si %s)\n' "$tmp/yay-bin" "${NOCONFIRM[*]}"
  else
    (cd "$tmp/yay-bin" && makepkg -si "${NOCONFIRM[@]}")
  fi
  rm -rf "$tmp"
}

if (( ${#NATIVE[@]} )); then
  echo ":: Installing ${#NATIVE[@]} repo packages (${PROFILES[*]})"
  run sudo pacman -S --needed "${NOCONFIRM[@]}" "${NATIVE[@]}"
fi

if (( ${#AUR[@]} )); then
  ensure_yay
  echo ":: Installing ${#AUR[@]} AUR packages: ${AUR[*]}"
  run yay -S --needed "${NOCONFIRM[@]}" "${AUR[@]}"
fi
