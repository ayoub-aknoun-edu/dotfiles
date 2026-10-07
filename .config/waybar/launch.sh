#!/usr/bin/env bash
# (Re)start the bar. Under a systemd-managed session (UWSM) waybar runs as
# waybar.service; otherwise it is spawned directly.
set -euo pipefail

if systemctl --user is-active --quiet graphical-session.target 2>/dev/null; then
    exec systemctl --user restart waybar.service
fi

# Stop any running bar and wait for it to exit (a fixed sleep races on slow exits).
pkill -x waybar 2>/dev/null || true
for _ in {1..20}; do
    pgrep -x waybar >/dev/null || break
    sleep 0.1
done
waybar &
