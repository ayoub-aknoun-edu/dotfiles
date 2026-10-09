-- Shell actions
-- The desktop shell layer is Noctalia; binds call shell.action(name) so the
-- commands live in one place.

local M = {}

local ACTIONS = {
    launcher       = "noctalia msg panel-toggle launcher",
    control_center = "noctalia msg panel-toggle control-center",
    notifications  = "noctalia msg panel-toggle control-center",
    do_not_disturb = "noctalia msg notification-dnd-toggle",
    clipboard      = "noctalia msg panel-toggle clipboard",
    power_menu     = "noctalia msg panel-toggle session",
    eye_comfort    = "noctalia msg nightlight-toggle",
    settings       = "noctalia msg settings-toggle",
    wallpaper      = "noctalia msg panel-toggle wallpaper",
    reload         = "systemctl --user restart noctalia.service",
}

-- Alt+Tab: Noctalia's window switcher (previews, MRU; it handles Shift+Tab
-- and Alt release itself).
function M.window_switcher()
    return function()
        hl.exec_cmd("noctalia msg window-switcher hold")
    end
end

function M.action(name)
    local cmd = assert(ACTIONS[name], "unknown shell action: " .. name)
    return function() hl.exec_cmd(cmd) end
end

return M
