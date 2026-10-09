-- Autostart (exec-once equivalent)
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- Under UWSM, daemons that ship a systemd user unit are enabled on
-- graphical-session.target instead of being started here, so they restart on
-- crash and stop cleanly on logout (see scripts/post-install.sh):
--   noctalia (shell, polkit agent, night light), hypridle,
--   hypridle-power-watcher, battery-alert.timer

local UWSM = os.getenv("UWSM_FINALIZE_VARNAMES") ~= nil

local SESSION_UNITS = {
    "noctalia.service",
    "hypridle.service",
    "hypridle-power-watcher.service",
    "battery-alert.timer",
}

hl.on("hyprland.start", function()
    if not UWSM then
        -- Direct launch fallback: export the environment and start the units
        -- ourselves, since nothing reaches graphical-session.target.
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_DESKTOP=Hyprland")
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP GTK_THEME QT_QPA_PLATFORMTHEME")
        hl.exec_cmd("systemctl --user start " .. table.concat(SESSION_UNITS, " "))
    end

    -- Wallpaper palette: seed theme/generated, then adopt Noctalia's wallpaper
    -- once it is up (Noctalia keeps its own clipboard history).
    hl.exec_cmd("~/.local/bin/rice-wall init; setsid -f ~/.local/bin/rice-wall restore")
end)
