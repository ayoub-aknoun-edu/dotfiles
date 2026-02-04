#!/usr/bin/env bash
set -euo pipefail

# Use layer-shell so Hyprland can apply blur layer rules.
# --no-span helps multi-monitor setups.
#exec wlogout   --protocol layer-shell   --no-span   --buttons-per-row 5   --margin 120   --column-spacing 12   --row-spacing 12
exec wlogout
