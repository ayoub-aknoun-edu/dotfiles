-- Look and Feel
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

local C = require("colors")

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            -- Mauve → Teal gradient on active windows
            active_border   = { colors = { C.accent, C.accent2 }, angle = 45 },
            inactive_border = C.inactive_border,
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 8,
        rounding_power = 2,

        shadow = {
            enabled      = true,
            range        = 6,
            render_power = 2,
            color        = C.shadow_color,
        },

        blur = {
            enabled  = true,
            size     = 4,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
    dwindle = {
        preserve_split = true,
        force_split    = 2,  -- always split on the right side
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,
    },

    cursor = {
        hide_on_key_press = true,
    },
})


-- ─── Bezier curves ────────────────────────────────────────────────────────────
hl.curve("md3_decel",  { type = "bezier", points = { {0.05, 0.7 }, {0.1,  1    } } })
hl.curve("md3_accel",  { type = "bezier", points = { {0.3,  0   }, {0.8,  0.15 } } })
hl.curve("menu_decel", { type = "bezier", points = { {0.1,  1   }, {0,    1    } } })
hl.curve("menu_accel", { type = "bezier", points = { {0.38, 0.04}, {1,    0.07 } } })


-- ─── Animations ───────────────────────────────────────────────────────────────
hl.animation({ leaf = "windows",          enabled = true, speed = 3,   bezier = "md3_decel",  style = "popin 60%" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 3,   bezier = "md3_decel",  style = "popin 60%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 3,   bezier = "md3_accel",  style = "popin 60%" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 3,   bezier = "md3_decel" })
hl.animation({ leaf = "border",           enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3,   bezier = "md3_decel" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 3,   bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.6, bezier = "menu_accel" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 2,   bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 4.5, bezier = "menu_accel" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 7,   bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,   bezier = "md3_decel",  style = "slidevert" })
