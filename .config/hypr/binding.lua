-- Keybindings
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- Every bind carries a description "Group: what it does". `keybinds`
-- (Super+/) lists them live from Hyprland, so keep descriptions up to date.

local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "thunar"
local browser     = os.getenv("HOME") .. "/.local/bin/browser"
local shell       = require("shell")  -- Noctalia actions (shell.lua)
local locker      = "~/.config/hypr/scripts/lock"

-- bind(keys, action, "Group: description", { extra options })
local function bind(keys, action, desc, opts)
    local o = {}
    for k, v in pairs(opts or {}) do o[k] = v end
    o.description = desc
    hl.bind(keys, action, o)
end


-- ─── Lock / Session ───────────────────────────────────────────────────────────
bind(mainMod .. " + L",         hl.dsp.exec_cmd(locker),     "Session: lock the screen")
bind(mainMod .. " + SHIFT + E", shell.action("power_menu"),  "Session: power menu (logout, reboot, shutdown)")
bind("XF86PowerOff",            hl.dsp.exec_cmd(locker),     "Session: lock (power button)", { locked = true })


-- ─── Applications ─────────────────────────────────────────────────────────────
bind(mainMod .. " + RETURN",      hl.dsp.exec_cmd(terminal),    "Apps: terminal (kitty)")
bind(mainMod .. " + SHIFT + F",   hl.dsp.exec_cmd(fileManager), "Apps: file manager (Thunar)")
bind(mainMod .. " + SHIFT + B",   hl.dsp.exec_cmd(browser),     "Apps: browser (Thorium)")
bind(mainMod .. " + ALT + SPACE", shell.action("launcher"),     "Apps: app launcher")


-- ─── Notifications / Control Center ─────────────────────────────────────────
bind(mainMod .. " + N",         shell.action("control_center"), "Shell: control center")
bind(mainMod .. " + SHIFT + N", shell.action("do_not_disturb"), "Shell: do not disturb on/off")
bind(mainMod .. " + CTRL + N",  shell.action("notifications"),  "Shell: notifications")


-- ─── Screenshot ───────────────────────────────────────────────────────────────
bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename -"),
     "Screenshot: select a region, then annotate")


-- ─── Window lifecycle ─────────────────────────────────────────────────────────
bind(mainMod .. " + W",        hl.dsp.window.close(),                         "Windows: close window")
bind(mainMod .. " + J",        hl.dsp.layout("togglesplit"),                  "Windows: switch split direction")
bind(mainMod .. " + P",        hl.dsp.window.pseudo(),                        "Windows: pseudo-tile (keep its own size)")
bind(mainMod .. " + T",        hl.dsp.window.float({ action = "toggle" }),    "Windows: float / tile")
bind(mainMod .. " + F",        hl.dsp.window.fullscreen(),                    "Windows: fullscreen")
bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2, action = "toggle" }),
     "Windows: fullscreen inside its tile (app thinks it's fullscreen)")
bind(mainMod .. " + ALT + F",  hl.dsp.window.fullscreen({ mode = 1 }),        "Windows: maximize (keeps bar and gaps)")


-- ─── Focus ────────────────────────────────────────────────────────────────────
bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }), "Focus: window to the left (crosses screens)")
bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), "Focus: window to the right (crosses screens)")
bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }), "Focus: window above")
bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }), "Focus: window below")


-- ─── Workspaces ───────────────────────────────────────────────────────────────
-- 1-5 live on the MSI, 6-10 on the laptop (monitors.lua). 0 = workspace 10.
for i = 1, 10 do
    local key = tostring(i % 10)
    bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }),       "Workspaces: go to workspace " .. i)
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Workspaces: move window to workspace " .. i)
end

bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "e+1"      }), "Workspaces: next (with windows)")
bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1"      }), "Workspaces: previous (with windows)")
bind(mainMod .. " + CTRL + TAB",  hl.dsp.focus({ workspace = "previous" }), "Workspaces: back to the last one")
bind(mainMod .. " + mouse_down",  hl.dsp.focus({ workspace = "e+1" }),      "Workspaces: next (scroll)")
bind(mainMod .. " + mouse_up",    hl.dsp.focus({ workspace = "e-1" }),      "Workspaces: previous (scroll)")


-- ─── Monitors ─────────────────────────────────────────────────────────────────
bind(mainMod .. " + period",         hl.dsp.focus({ monitor = "+1" }),          "Screens: jump to the other screen")
bind(mainMod .. " + SHIFT + period", hl.dsp.window.move({ monitor = "+1" }),    "Screens: send window to the other screen")
bind(mainMod .. " + CTRL + period",  hl.dsp.workspace.move({ monitor = "+1" }), "Screens: send whole workspace to the other screen")


-- ─── Swap windows ─────────────────────────────────────────────────────────────
bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "l" }), "Move windows: swap with the left one")
bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }), "Move windows: swap with the right one")
bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "u" }), "Move windows: swap with the one above")
bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "d" }), "Move windows: swap with the one below")


-- ─── Alt-Tab ──────────────────────────────────────────────────────────────────
bind("ALT + TAB",         shell.window_switcher(), "Focus: window switcher (hold Alt)")
bind("ALT + SHIFT + TAB", shell.window_switcher(), "Focus: window switcher, backwards")


-- ─── Resize ───────────────────────────────────────────────────────────────────
bind(mainMod .. " + minus",         hl.dsp.window.resize({ x = -100, y =    0, relative = true }), "Resize: narrower", { repeating = true })
bind(mainMod .. " + equal",         hl.dsp.window.resize({ x =  100, y =    0, relative = true }), "Resize: wider",    { repeating = true })
bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x =    0, y = -100, relative = true }), "Resize: shorter",  { repeating = true })
bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x =    0, y =  100, relative = true }), "Resize: taller",   { repeating = true })


-- ─── Drag / Resize with mouse ─────────────────────────────────────────────────
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   "Mouse: drag window (hold left button)",    { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "Mouse: resize window (hold right button)", { mouse = true })


-- ─── Groups ───────────────────────────────────────────────────────────────────
bind(mainMod .. " + G",           hl.dsp.group.toggle(),                         "Groups: make / undo a tab group")
bind(mainMod .. " + ALT + G",     hl.dsp.window.move({ out_of_group = true }),   "Groups: take window out of its group")
bind(mainMod .. " + ALT + left",  hl.dsp.window.move({ into_group = "l" }),      "Groups: join the group on the left")
bind(mainMod .. " + ALT + right", hl.dsp.window.move({ into_group = "r" }),      "Groups: join the group on the right")
bind(mainMod .. " + ALT + up",    hl.dsp.window.move({ into_group = "u" }),      "Groups: join the group above")
bind(mainMod .. " + ALT + down",  hl.dsp.window.move({ into_group = "d" }),      "Groups: join the group below")
for i = 1, 5 do
    bind(mainMod .. " + ALT + " .. i, hl.dsp.group.active({ index = i }), "Groups: show tab " .. i)
end


-- ─── Clipboard ────────────────────────────────────────────────────────────────
bind(mainMod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "C" }), "Clipboard: copy (sends Ctrl+C)")
bind(mainMod .. " + V", shell.action("clipboard"),                          "Clipboard: history")
bind(mainMod .. " + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }), "Clipboard: cut (sends Ctrl+X)")


-- ─── Scratchpad (special workspace) ──────────────────────────────────────────
bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"),            "Scratchpad: show / hide")
bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), "Scratchpad: send window there")


-- ─── Media / Brightness ───────────────────────────────────────────────────────
bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), "Media: volume up",          { locked = true, repeating = true })
bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      "Media: volume down",        { locked = true, repeating = true })
bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     "Media: mute",               { locked = true })
bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   "Media: mute microphone",    { locked = true })
bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  "Media: laptop brightness up",   { locked = true, repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  "Media: laptop brightness down", { locked = true, repeating = true })
bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       "Media: next track",     { locked = true })
bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   "Media: previous track", { locked = true })
bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), "Media: play / pause",   { locked = true })
bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), "Media: play / pause",   { locked = true })


-- ─── Reload shell ─────────────────────────────────────────────────────────────
bind(mainMod .. " + SHIFT + SPACE", shell.action("reload"), "Shell: restart Noctalia (bar)")


-- ─── Desktop shell & wallpaper ──────────────────────────────────────────────
bind(mainMod .. " + comma",     shell.action("settings"),    "Shell: Noctalia settings")
bind(mainMod .. " + ALT + N",   shell.action("eye_comfort"), "Appearance: Eye Comfort (warm colors) on/off")
bind(mainMod .. " + SHIFT + W", shell.action("wallpaper"),   "Appearance: pick a wallpaper")
bind(mainMod .. " + ALT + W",   hl.dsp.exec_cmd("~/.local/bin/rice-wall random"), "Appearance: random wallpaper")


-- ─── Help ─────────────────────────────────────────────────────────────────────
bind(mainMod .. " + slash",
     hl.dsp.exec_cmd("kitty --class keybinds --title 'Keyboard shortcuts' -e ~/.local/bin/keybinds"),
     "Help: this shortcut list (type to search, Esc to close)")
