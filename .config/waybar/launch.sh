#!/usr/bin/env bash
set -euo pipefail

# Stop any running bar and wait for it to exit (a fixed sleep races on slow exits).
pkill -x waybar 2>/dev/null || true
for _ in {1..20}; do
    pgrep -x waybar >/dev/null || break
    sleep 0.1
done

# Output is left attached so warnings land in the journal instead of /dev/null.
if command -v uwsm >/dev/null 2>&1 && [[ -n "${UWSM_FINALIZE_VARNAMES:-}" ]]; then
    uwsm app -- waybar &
else
    waybar &
fi
