-- Autostart (exec-once equivalent)
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- Under UWSM, daemons that ship a systemd user unit are enabled on
-- graphical-session.target instead of being started here, so they restart on
-- crash and stop cleanly on logout (see scripts/post-install.sh):
--   hyprpolkitagent, hyprsunset, hypridle, hypridle-power-watcher,
--   battery-alert.timer
-- The shell layer (Noctalia, or the classic waybar/eww/swaync fallback) is
-- started by ~/.local/bin/rice-shell from the saved choice (Super+Alt+S).

local UWSM = os.getenv("UWSM_FINALIZE_VARNAMES") ~= nil

local SESSION_UNITS = {
    "hyprpolkitagent.service",
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

    -- Shell layer + wallpaper, from the saved choice (rice-shell / rice-wall)
    hl.exec_cmd("~/.local/bin/rice-shell apply")

    -- Clipboard history (both text and images)
    app("wl-paste --type text  --watch cliphist store")
    app("wl-paste --type image --watch cliphist store")
end)
