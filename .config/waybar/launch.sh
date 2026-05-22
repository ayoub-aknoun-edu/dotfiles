#!/usr/bin/env bash
set -euo pipefail

pkill -x waybar 2>/dev/null || true
sleep 0.1

if command -v uwsm >/dev/null 2>&1 && [[ -n "${UWSM_FINALIZE_VARNAMES:-}" ]]; then
    uwsm app -- waybar >/dev/null 2>&1 &
else
    waybar >/dev/null 2>&1 &
fi
