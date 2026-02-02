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

exec stow --dir="$REPO_DIR" --target="$HOME" --restow .
