#!/usr/bin/env bash
# Lock all sessions before suspend/hibernate so the screen is always locked
# on lid close, regardless of whether hypridle is running.
case "$1" in
    pre) loginctl lock-sessions; sleep 1 ;;
esac
