-- Keybindings
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "thunar"
local browser     = os.getenv("HOME") .. "/.local/bin/browser"
local menu        = "rofi -show drun"
local locker      = "pidof hyprlock >/dev/null 2>&1 || hyprlock -c ~/.config/hypr/hyprlock.conf"


-- ─── Lock / Session ───────────────────────────────────────────────────────────
hl.bind(mainMod .. " + L",        hl.dsp.exec_cmd(locker))
hl.bind(mainMod .. " + SHIFT + E",hl.dsp.exec_cmd("~/.config/wlogout/launch.sh"))
hl.bind("XF86PowerOff",           hl.dsp.exec_cmd(locker), { locked = true })


-- ─── Applications ─────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + RETURN",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + F",     hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + B",     hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + ALT + SPACE",   hl.dsp.exec_cmd(menu))


-- ─── Notifications / Control Center ─────────────────────────────────────────
hl.bind(mainMod .. " + N",        hl.dsp.exec_cmd("~/.config/eww/scripts/toggle-control-center"))
hl.bind(mainMod .. " + SHIFT + N",hl.dsp.exec_cmd("swaync-client --toggle-dnd --skip-wait"))

-- ESC closes the CC (passes through so apps still get ESC).
hl.bind("escape", hl.dsp.exec_cmd("~/.config/eww/scripts/close-control-center"),
        { non_consuming = true })

-- Left-click closes the CC when clicking outside it (passes through to the clicked app).
hl.bind("mouse:272", hl.dsp.exec_cmd("~/.config/eww/scripts/cc-click-outside"),
        { non_consuming = true, mouse = true })


-- ─── Screenshot ───────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename -"))


-- ─── Window lifecycle ─────────────────────────────────────────────────────────
hl.bind(mainMod .. " + W",            hl.dsp.window.close())
hl.bind(mainMod .. " + J",            hl.dsp.layout("togglesplit"))  -- dwindle
hl.bind(mainMod .. " + P",            hl.dsp.window.pseudo())        -- dwindle pseudo-tile
hl.bind(mainMod .. " + T",            hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",            hl.dsp.window.fullscreen())    -- true fullscreen
hl.bind(mainMod .. " + CTRL + F",     hl.dsp.exec_cmd("hyprctl dispatch fullscreenstate 0 2"))  -- tiled fullscreen
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
hl.bind("ALT + TAB",         hl.dsp.exec_cmd("hyprctl --batch 'dispatch cyclenext ; dispatch bringactivetotop'"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.exec_cmd("hyprctl --batch 'dispatch cyclenext prev ; dispatch alterzorder top'"))


-- ─── Resize ───────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + minus",         hl.dsp.window.resize({ x = -100, y =    0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + equal",         hl.dsp.window.resize({ x =  100, y =    0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x =    0, y = -100, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x =    0, y =  100, relative = true }), { repeating = true })


-- ─── Drag / Resize with mouse ─────────────────────────────────────────────────
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


-- ─── Groups ───────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + G",          hl.dsp.exec_cmd("hyprctl dispatch togglegroup"))
hl.bind(mainMod .. " + ALT + G",    hl.dsp.exec_cmd("hyprctl dispatch moveoutofgroup"))
hl.bind(mainMod .. " + ALT + left", hl.dsp.exec_cmd("hyprctl dispatch moveintogroup l"))
hl.bind(mainMod .. " + ALT + right",hl.dsp.exec_cmd("hyprctl dispatch moveintogroup r"))
hl.bind(mainMod .. " + ALT + up",   hl.dsp.exec_cmd("hyprctl dispatch moveintogroup u"))
hl.bind(mainMod .. " + ALT + down", hl.dsp.exec_cmd("hyprctl dispatch moveintogroup d"))
for i = 1, 5 do
    hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.exec_cmd("hyprctl dispatch changegroupactive " .. i))
end


-- ─── Clipboard ────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprctl dispatch sendshortcut CTRL,C,,"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/rofi/rofi-clipboard"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("hyprctl dispatch sendshortcut CTRL,X,,"))


-- ─── Scratchpad (special workspace) ──────────────────────────────────────────
hl.bind(mainMod .. " + S",        hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S",hl.dsp.window.move({ workspace = "special:magic" }))


-- ─── Media / Brightness ───────────────────────────────────────────────────────
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })


-- ─── Reload Waybar ────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("~/.config/waybar/launch.sh"))
