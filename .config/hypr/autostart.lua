-- Autostart (exec-once equivalent)
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- 1. D-Bus / systemd environment propagation (must be first)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_DESKTOP=Hyprland")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP GTK_THEME QT_QPA_PLATFORMTHEME")

    -- 2. PolicyKit agent (needed for Thunar mount dialogs, etc.)
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- 3. Status bar
    hl.exec_cmd("killall waybar; sleep 0.5 && waybar")

    -- 4. Notification daemon
    hl.exec_cmd("env GSK_RENDERER=gl swaync")

    -- 5. Wallpaper (awww-daemon for smooth transitions)
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("awww img ~/.config/hypr/wallpaper/wallhaven-3lrdyv_1920x1080.png --transition-type simple")

    -- 6. Idle / lock daemon
    hl.exec_cmd("bash -lc 'systemctl --user start hypridle.service 2>/dev/null || hypridle'")

    -- 7. Battery alerts
    hl.exec_cmd("bash -lc 'systemctl --user start battery-alert.timer 2>/dev/null || true'")

    -- 8. Clipboard history (both text and images)
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- 9. Blue-light filter
    hl.exec_cmd("hyprsunset --temperature 5000")
end)
