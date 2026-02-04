#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"

PACMAN_FILE="$REPO_DIR/packages/pacman.txt"
AUR_FILE="$REPO_DIR/packages/aur.txt"

read_pkg_file() {
  local file="$1"
  local -n out="$2"

  if [[ ! -f "$file" ]]; then
    return 0
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Strip comments and trim whitespace
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    out+=("$line")
  done < "$file"
}

ensure_sudo() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    sudo -v
  fi
}

install_pacman() {
  local -a pkgs=()
  read_pkg_file "$PACMAN_FILE" pkgs
  if (( ${#pkgs[@]} == 0 )); then
    return 0
  fi

  ensure_sudo
  sudo pacman -S --needed "${pkgs[@]}"
}

ensure_aur_helper() {
  if command -v yay >/dev/null 2>&1; then
    echo "yay"
    return 0
  fi
  if command -v paru >/dev/null 2>&1; then
    echo "paru"
    return 0
  fi

  read -rp "No AUR helper found. Install yay now? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    ensure_sudo
    sudo pacman -S --needed git base-devel
    tmpdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si)
    rm -rf "$tmpdir"
    echo "yay"
    return 0
  fi

  return 1
}

install_aur() {
  local -a pkgs=()
  read_pkg_file "$AUR_FILE" pkgs
  if (( ${#pkgs[@]} == 0 )); then
    return 0
  fi

  local helper
  if ! helper="$(ensure_aur_helper)"; then
    echo "Skipping AUR packages (no helper installed)." >&2
    return 0
  fi

  "$helper" -S --needed "${pkgs[@]}"
}

install_pacman
install_aur
