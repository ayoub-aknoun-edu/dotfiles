-- Shell-aware actions
-- The desktop shell layer is switchable (~/.local/bin/rice-shell): Noctalia
-- (everyday) or the classic waybar/eww/swaync/rofi stack (fallback). Binds
-- call shell.action(name), which runs the command for the active shell.

local M = {}

local STATE_FILE = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"))
                   .. "/rice/shell"

local ACTIONS = {
    launcher = {
        classic  = "rofi -show drun",
        noctalia = "noctalia msg panel-toggle launcher",
    },
    control_center = {
        classic  = "~/.config/eww/scripts/toggle-control-center",
        noctalia = "noctalia msg panel-toggle control-center",
    },
    notifications = {
        classic  = "swaync-client --toggle-panel --skip-wait",
        noctalia = "noctalia msg panel-toggle control-center",
    },
    do_not_disturb = {
        classic  = "swaync-client --toggle-dnd --skip-wait",
        noctalia = "noctalia msg notification-dnd-toggle",
    },
    clipboard = {
        classic  = "~/.config/rofi/rofi-clipboard",
        noctalia = "noctalia msg panel-toggle clipboard",
    },
    power_menu = {
        classic  = "~/.config/wlogout/launch.sh",
        noctalia = "noctalia msg panel-toggle session",
    },
    eye_comfort = {
        classic  = "~/.local/bin/eyecare-toggle",
        noctalia = "noctalia msg nightlight-toggle",
    },
    settings = {
        noctalia = "noctalia msg settings-toggle",
    },
    reload = {
        classic  = "~/.config/waybar/launch.sh",
        noctalia = "systemctl --user restart noctalia.service",
    },
}

function M.current()
    local file = io.open(STATE_FILE, "r")
    if not file then return "noctalia" end
    local name = file:read("l")
    file:close()
    return name == "classic" and "classic" or "noctalia"
end

-- Alt+Tab: Noctalia's window switcher (previews, MRU; it handles Shift+Tab
-- and Alt release itself). Classic: cycle windows directly.
function M.window_switcher(backwards)
    return function()
        if M.current() == "noctalia" then
            hl.exec_cmd("noctalia msg window-switcher hold")
            return
        end
        hl.dispatch(hl.dsp.window.cycle_next({ next = not backwards }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end
end

-- Returns a bind callback; the shell is resolved at keypress time.
function M.action(name)
    local commands = assert(ACTIONS[name], "unknown shell action: " .. name)
    return function()
        local cmd = commands[M.current()]
        if cmd then hl.exec_cmd(cmd) end
    end
end

return M
