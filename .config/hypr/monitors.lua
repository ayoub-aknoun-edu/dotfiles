-- Monitor configuration
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Desk layout:  [ MSI MAG 274QF E20 (27" 1440p) ][ laptop eDP-1 (14" 1080p) ]
-- The MSI is matched by description (model + serial), so the rule keeps working
-- whichever port/cable it uses (HDMI-A-1 today, DP-x via USB-C later).

local MSI    = "desc:Micro-Star Int'l Co. Ltd. MAG 274QF E20 CE4H676700128"
local LAPTOP = "eDP-1"

-- Fallback for any other screen (projector, TV…): best mode, placed automatically.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- MSI: highest resolution at the highest refresh rate the link allows
-- (laptop HDMI 1.4b → 1440p@60; DisplayPort via USB-C → 1440p@200).
-- vrr = 2: FreeSync only for fullscreen apps (games/video); avoids desktop flicker.
-- (Intel only does VRR over DisplayPort, so it is inactive on HDMI.)
hl.monitor({
    output   = MSI,
    mode     = "highres",
    position = "0x0",
    scale    = 1,
    vrr      = 2,
})

-- ─── Laptop panel + clamshell mode ─────────────────────────────────────────
-- Right of the MSI, bottom edges aligned (1440 - 1080 = 360).
-- Lid closed while an external screen is on → laptop panel off (its workspaces
-- move to the MSI). Lid open, or last external screen gone → panel back on.
-- (logind ignores the lid while docked, so the laptop keeps running.)
local LID_STATE = "/proc/acpi/button/lid/LID/state"

local function lid_closed()
    local f = io.open(LID_STATE, "r")
    if not f then return false end
    local state = f:read("*a") or ""
    f:close()
    return state:find("closed") ~= nil
end

local function external_connected()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= LAPTOP and m.enabled then return true end
    end
    return false
end

local function apply_laptop_panel()
    hl.monitor({
        output   = LAPTOP,
        mode     = "preferred",
        position = "2560x360",
        scale    = 1,
        disabled = lid_closed() and external_connected(),
    })
end

apply_laptop_panel()
hl.bind("switch:on:Lid Switch",  apply_laptop_panel, { locked = true })
hl.bind("switch:off:Lid Switch", apply_laptop_panel, { locked = true })
hl.on("monitor.added",   apply_laptop_panel)
hl.on("monitor.removed", apply_laptop_panel)

-- Warn when a monitor is plugged into a port too weak for its native
-- resolution (e.g. the cheap USB-C hub's HDMI). Delay: let modes settle.
local CHECK = "sleep 3; ~/.local/bin/monitor-check --notify"
hl.on("monitor.added",  function() hl.exec_cmd(CHECK) end)
hl.on("hyprland.start", function() hl.exec_cmd(CHECK) end)

-- Workspaces: 1-5 live on the MSI, 6-10 on the laptop.
-- Unplugged MSI → its workspaces simply open on the laptop.
for i = 1, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = (i <= 5) and MSI or LAPTOP,
        default   = (i == 1 or i == 6),
    })
end
