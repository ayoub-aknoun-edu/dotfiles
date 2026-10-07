-- Shell-aware actions
-- The desktop shell layer is switchable (~/.local/bin/rice-shell): the classic
-- waybar/eww/swaync/rofi stack, DankMaterialShell or Noctalia. Binds call
-- shell.action(name), which runs the command for whichever shell is active.

local M = {}

local STATE_FILE = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"))
                   .. "/rice/shell"

local ACTIONS = {
    launcher = {
        classic  = "rofi -show drun",
        dms      = "dms ipc call spotlight toggle",
        noctalia = "noctalia msg panel-toggle launcher",
    },
    control_center = {
        classic  = "~/.config/eww/scripts/toggle-control-center",
        dms      = "dms ipc call control-center toggle",
        noctalia = "noctalia msg panel-toggle control-center",
    },
    notifications = {
        classic  = "swaync-client --toggle-panel --skip-wait",
        dms      = "dms ipc call notifications toggle",
        noctalia = "noctalia msg panel-toggle control-center",
    },
    do_not_disturb = {
        classic  = "swaync-client --toggle-dnd --skip-wait",
        dms      = "dms ipc call notifications toggleDoNotDisturb",
        noctalia = "noctalia msg notification-dnd-toggle",
    },
    clipboard = {
        classic  = "~/.config/rofi/rofi-clipboard",
        dms      = "dms ipc call clipboard toggle",
        noctalia = "noctalia msg panel-toggle clipboard",
    },
    power_menu = {
        classic  = "~/.config/wlogout/launch.sh",
        dms      = "dms ipc call powermenu toggle",
        noctalia = "noctalia msg panel-toggle session",
    },
    settings = {
        dms      = "dms ipc call settings toggle",
        noctalia = "noctalia msg settings-toggle",
    },
    reload = {
        classic  = "~/.config/waybar/launch.sh",
        dms      = "systemctl --user restart rice-dms-shell.service",
        noctalia = "systemctl --user restart noctalia.service",
    },
}

function M.current()
    local file = io.open(STATE_FILE, "r")
    if not file then return "classic" end
    local name = file:read("l")
    file:close()
    return (name == "dms" or name == "noctalia") and name or "classic"
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
