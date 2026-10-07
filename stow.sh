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
mkdir -p "$HOME/.local/bin" "$HOME/.config/systemd/user"

stow --dir="$REPO_DIR" --target="$HOME" --restow .

echo ""
echo "Stow complete. Running post-install steps..."
bash "$REPO_DIR/scripts/post-install.sh"
