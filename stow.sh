#!/usr/bin/env bash
set -euo pipefail

# Resolve the real path of this script (follows symlinks)
SRC="${BASH_SOURCE[0]}"

if command -v realpath >/dev/null 2>&1; then
  SCRIPT_PATH="$(realpath "$SRC")"
else
  SCRIPT_PATH="$(readlink -f "$SRC")"
fi

REPO_DIR="$(cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd -P)"

if [[ -z "$REPO_DIR" || ! -d "$REPO_DIR" ]]; then
  echo "ERROR: Could not determine repo directory for stow."
  echo "REPO_DIR='$REPO_DIR' SCRIPT_PATH='$SCRIPT_PATH' SRC='$SRC'"
  exit 1
fi

# Directories that other tools also install into must exist as real dirs
# first, otherwise stow "folds" them into a single symlink to the repo and
# everything installed there (uv, claude, ...) lands in git.
mkdir -p "$HOME/.local/bin" "$HOME/.config/systemd/user" "$HOME/.local/state/noctalia" "$HOME/.config/autostart"

# A fresh machine has default files (.bashrc, .zshrc, ...) where the repo wants
# symlinks; stow refuses to overwrite them. Move each conflict aside first.
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
mapfile -t CONFLICTS < <(
  stow --dir="$REPO_DIR" --target="$HOME" --restow --no . 2>&1 \
    | sed -nE 's/.*over existing target ([^ ]+) since.*/\1/p;
              s/.*existing target is (neither a link nor a directory|not owned by stow): ([^ ]+).*/\2/p' \
    | sort -u
)
for rel in "${CONFLICTS[@]}"; do
  [[ -n "$rel" && -e "$HOME/$rel" && ! -L "$HOME/$rel" ]] || continue
  mkdir -p "$BACKUP_DIR/$(dirname -- "$rel")"
  mv -- "$HOME/$rel" "$BACKUP_DIR/$rel"
  echo "Moved existing ~/$rel → $BACKUP_DIR/$rel"
done

stow --dir="$REPO_DIR" --target="$HOME" --restow .

echo ""
echo "Stow complete. Running post-install steps..."
bash "$REPO_DIR/scripts/post-install.sh"
