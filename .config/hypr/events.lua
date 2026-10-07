-- Event hooks
-- Push compositor state changes to the bar instead of having it poll.

-- custom/ws-* modules in waybar/config.jsonc listen on SIGRTMIN+9.
local WAYBAR_WORKSPACE_SIGNAL = 9
-- Opening a window fires several events at once; coalesce them into one refresh.
local DEBOUNCE_MS = 50

local pending_refresh = nil

local function refresh_waybar_workspaces()
    if pending_refresh then return end
    pending_refresh = hl.timer(function()
        pending_refresh = nil
        hl.exec_cmd("pkill -RTMIN+" .. WAYBAR_WORKSPACE_SIGNAL .. " -x waybar")
    end, { timeout = DEBOUNCE_MS, type = "oneshot" })
end

for _, event in ipairs({
    "workspace.active",
    "workspace.created",
    "workspace.removed",
    "window.open",
    "window.close",
    "window.move_to_workspace",
    "monitor.focused",
}) do
    hl.on(event, refresh_waybar_workspaces)
end
