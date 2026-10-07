#!/usr/bin/env bash
# Download the curated wallpaper pack (packages/wallpapers.txt) into
# ~/Pictures/Wallpapers. Images aren't stored in git; existing files are kept.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LIST="${WALLPAPER_LIST:-$SCRIPT_DIR/../packages/wallpapers.txt}"
DEST="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"

mkdir -p "$DEST"
# The original wallpaper ships with the repo.
cp -n "$SCRIPT_DIR/../.config/hypr/wallpaper/wallhaven-3lrdyv_1920x1080.png" "$DEST/original-3lrdyv.png"

while read -r url name; do
    [[ -z "$url" || "$url" == \#* ]] && continue
    [[ -s "$DEST/$name" ]] && continue
    echo "fetching $name"
    if curl -sfL --max-time 120 -o "$DEST/$name.part" "$url" \
        && file -b --mime-type "$DEST/$name.part" | grep -q '^image/'; then
        mv "$DEST/$name.part" "$DEST/$name"
    else
        echo "  failed: $url" >&2
        rm -f "$DEST/$name.part"
    fi
done < "$LIST"
