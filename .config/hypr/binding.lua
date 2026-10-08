-- Keybindings
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "thunar"
local browser     = os.getenv("HOME") .. "/.local/bin/browser"
local shell       = require("shell")  -- routes to the active shell (rice-shell)
local locker      = "~/.config/hypr/scripts/lock"


-- ─── Lock / Session ───────────────────────────────────────────────────────────
hl.bind(mainMod .. " + L",        hl.dsp.exec_cmd(locker))
hl.bind(mainMod .. " + SHIFT + E",shell.action("power_menu"))
hl.bind("XF86PowerOff",           hl.dsp.exec_cmd(locker), { locked = true })


-- ─── Applications ─────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + RETURN",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + F",     hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + B",     hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + ALT + SPACE",   shell.action("launcher"))


-- ─── Notifications / Control Center ─────────────────────────────────────────
hl.bind(mainMod .. " + N",        shell.action("control_center"))
hl.bind(mainMod .. " + SHIFT + N",shell.action("do_not_disturb"))
hl.bind(mainMod .. " + CTRL + N", shell.action("notifications"))

-- These binds fire on every Esc / left-click, so they check the CC layer
-- in-process and only spawn the close script when the panel is actually open.
-- eww sometimes maps its first window before applying :namespace, leaving
-- gtk-layer-shell's default name; eww is the only gtk-layer-shell client here.
local CONTROL_CENTER_NAMESPACES = { ["eww-control-center"] = true, ["gtk-layer-shell"] = true }

local function control_center_layer()
    for _, layer in ipairs(hl.get_layers()) do
        if CONTROL_CENTER_NAMESPACES[layer.namespace] then return layer end
    end
end

local function close_control_center()
    hl.exec_cmd("~/.config/eww/scripts/close-control-center")
end

-- ESC closes the CC (passes through so apps still get ESC).
hl.bind("escape", function()
    if control_center_layer() then close_control_center() end
end, { non_consuming = true })

-- Left-click outside the CC closes it (passes through to the clicked app).
hl.bind("mouse:272", function()
    local cc = control_center_layer()
    if not cc then return end
    local pos = hl.get_cursor_pos()
    local inside = pos and pos.x >= cc.x and pos.x <= cc.x + cc.w
                       and pos.y >= cc.y and pos.y <= cc.y + cc.h
    if not inside then close_control_center() end
end, { non_consuming = true, mouse = true })


-- ─── Screenshot ───────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename -"))


-- ─── Window lifecycle ─────────────────────────────────────────────────────────
hl.bind(mainMod .. " + W",            hl.dsp.window.close())
hl.bind(mainMod .. " + J",            hl.dsp.layout("togglesplit"))  -- dwindle
hl.bind(mainMod .. " + P",            hl.dsp.window.pseudo())        -- dwindle pseudo-tile
hl.bind(mainMod .. " + T",            hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",            hl.dsp.window.fullscreen())    -- true fullscreen
hl.bind(mainMod .. " + CTRL + F",     hl.dsp.window.fullscreen_state({ internal = 0, client = 2, action = "toggle" }))  -- tiled fullscreen
hl.bind(mainMod .. " + ALT + F",      hl.dsp.window.fullscreen({ mode = 1 }))  -- maximize


-- ─── Focus ────────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))


-- ─── Workspaces ───────────────────────────────────────────────────────────────
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end
-- 0 = workspace 10
hl.bind(mainMod .. " + 0",        hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0",hl.dsp.window.move({ workspace = 10 }))

-- Workspace cycling
hl.bind(mainMod .. " + TAB",            hl.dsp.focus({ workspace = "e+1"      }))
hl.bind(mainMod .. " + SHIFT + TAB",    hl.dsp.focus({ workspace = "e-1"      }))
hl.bind(mainMod .. " + CTRL + TAB",     hl.dsp.focus({ workspace = "previous" }))

-- Scroll through workspaces with mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))


-- ─── Swap windows ─────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "d" }))


-- ─── Alt-Tab ──────────────────────────────────────────────────────────────────
hl.bind("ALT + TAB",         shell.window_switcher(false))
hl.bind("ALT + SHIFT + TAB", shell.window_switcher(true))


-- ─── Resize ───────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + minus",         hl.dsp.window.resize({ x = -100, y =    0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + equal",         hl.dsp.window.resize({ x =  100, y =    0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x =    0, y = -100, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x =    0, y =  100, relative = true }), { repeating = true })


-- ─── Drag / Resize with mouse ─────────────────────────────────────────────────
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


-- ─── Groups ───────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + G",          hl.dsp.group.toggle())
hl.bind(mainMod .. " + ALT + G",    hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.move({ into_group = "l" }))
hl.bind(mainMod .. " + ALT + right",hl.dsp.window.move({ into_group = "r" }))
hl.bind(mainMod .. " + ALT + up",   hl.dsp.window.move({ into_group = "u" }))
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.move({ into_group = "d" }))
for i = 1, 5 do
    hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.group.active({ index = i }))
end


-- ─── Clipboard ────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "C" }))
hl.bind(mainMod .. " + V", shell.action("clipboard"))
hl.bind(mainMod .. " + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }))


-- ─── Scratchpad (special workspace) ──────────────────────────────────────────
hl.bind(mainMod .. " + S",        hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S",hl.dsp.window.move({ workspace = "special:magic" }))


-- ─── Media / Brightness ───────────────────────────────────────────────────────
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })


-- ─── Reload Waybar ────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + SPACE", shell.action("reload"))


-- ─── Desktop shell & wallpaper ──────────────────────────────────────────────
-- ThinkPad: without Fn-lock the F-row sends media keys, so Super+F12 only
-- works with Fn; Super+Alt+S ("shell") always does.
hl.bind(mainMod .. " + ALT + S",      hl.dsp.exec_cmd("~/.local/bin/rice-shell next"))
hl.bind(mainMod .. " + F12",          hl.dsp.exec_cmd("~/.local/bin/rice-shell next"))
hl.bind(mainMod .. " + comma",        shell.action("settings"))
hl.bind(mainMod .. " + ALT + N",      shell.action("eye_comfort"))  -- Eye Comfort Shield
hl.bind(mainMod .. " + SHIFT + W",    hl.dsp.exec_cmd("~/.local/bin/rice-wall pick"))
hl.bind(mainMod .. " + ALT + W",      hl.dsp.exec_cmd("~/.local/bin/rice-wall random"))
