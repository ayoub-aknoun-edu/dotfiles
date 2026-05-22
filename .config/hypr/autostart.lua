-- Autostart (exec-once equivalent)
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- 1. D-Bus / systemd environment propagation for direct Hyprland launches.
    -- UWSM already handles this when the session starts through hyprland-uwsm.
    if not os.getenv("UWSM_FINALIZE_VARNAMES") then
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_DESKTOP=Hyprland")
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP GTK_THEME QT_QPA_PLATFORMTHEME")
    end

    -- 2. PolicyKit agent (needed for Thunar mount dialogs, etc.)
    hl.exec_cmd("bash -lc 'systemctl --user start hyprpolkitagent.service 2>/dev/null || /usr/lib/hyprpolkitagent/hyprpolkitagent'")

    -- 3. Status bar
    hl.exec_cmd("~/.config/waybar/launch.sh")

    -- 4. Notification daemon
    hl.exec_cmd("env GSK_RENDERER=gl swaync")

    -- 5. eww widget daemon + notification logger
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("~/.config/eww/scripts/notification-daemon")

    -- 6. Wallpaper (awww-daemon for smooth transitions)
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("awww img ~/.config/hypr/wallpaper/wallhaven-3lrdyv_1920x1080.png --transition-type simple")

    -- 7. Idle / lock daemon (AC-aware: hypridle-launch picks the right config)
    hl.exec_cmd("bash -lc 'systemctl --user start hypridle.service 2>/dev/null || ~/.local/bin/hypridle-launch'")
    hl.exec_cmd("bash -lc 'systemctl --user start hypridle-power-watcher.service 2>/dev/null'")

    -- 8. Battery alerts
    hl.exec_cmd("bash -lc 'systemctl --user start battery-alert.timer 2>/dev/null || true'")

    -- 9. Clipboard history (both text and images)
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- 10. Blue-light filter
    hl.exec_cmd("hyprsunset --temperature 5000")
end)
