-- Autostart (exec-once equivalent)
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- Under UWSM, daemons that ship a systemd user unit are enabled on
-- graphical-session.target instead of being started here, so they restart on
-- crash and stop cleanly on logout (see scripts/post-install.sh):
--   hyprpolkitagent, waybar, swaync, hyprsunset, hypridle,
--   hypridle-power-watcher, battery-alert.timer

local UWSM = os.getenv("UWSM_FINALIZE_VARNAMES") ~= nil

local SESSION_UNITS = {
    "hyprpolkitagent.service",
    "waybar.service",
    "swaync.service",
    "hyprsunset.service",
    "hypridle.service",
    "hypridle-power-watcher.service",
    "battery-alert.timer",
}

-- `uwsm app` gives each daemon its own systemd scope (logs + cgroup).
local function app(cmd)
    hl.exec_cmd(UWSM and ("uwsm app -- " .. cmd) or cmd)
end

hl.on("hyprland.start", function()
    if not UWSM then
        -- Direct launch fallback: export the environment and start the units
        -- ourselves, since nothing reaches graphical-session.target.
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_DESKTOP=Hyprland")
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP GTK_THEME QT_QPA_PLATFORMTHEME")
        hl.exec_cmd("systemctl --user start " .. table.concat(SESSION_UNITS, " "))
    end

    -- eww widget daemon + notification logger (control center)
    app("eww daemon")
    app("~/.config/eww/scripts/notification-daemon")

    -- Wallpaper: the daemon restores its cached image by itself; set the
    -- default explicitly once it is up (covers a fresh machine with no cache).
    app("awww-daemon")
    hl.exec_cmd("timeout 5 sh -c 'until awww query >/dev/null 2>&1; do sleep 0.1; done' && awww img ~/.config/hypr/wallpaper/wallhaven-3lrdyv_1920x1080.png --transition-type simple")

    -- Clipboard history (both text and images)
    app("wl-paste --type text  --watch cliphist store")
    app("wl-paste --type image --watch cliphist store")
end)
