-- Look and Feel
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

require("colors")

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            -- Mauve → Teal gradient on active windows
            active_border   = { colors = { accent, accent2 }, angle = 45 },
            inactive_border = inactive_border,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 8,   -- Rounded corners
        rounding_power = 2,

        -- active_opacity   = 1.0,
        -- inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = shadow_color,
        },

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
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
        focus_on_activate       = true,
        disable_hyprland_logo   = true,
    },

    cursor = {
        hide_on_key_press = true,
    },
})


-- ─── Bezier curves ────────────────────────────────────────────────────────────
hl.curve("linear",        { type = "bezier", points = { {0,    0   }, {1,    1    } } })
hl.curve("md3_standard",  { type = "bezier", points = { {0.2,  0   }, {0,    1    } } })
hl.curve("md3_decel",     { type = "bezier", points = { {0.05, 0.7 }, {0.1,  1    } } })
hl.curve("md3_accel",     { type = "bezier", points = { {0.3,  0   }, {0.8,  0.15 } } })
hl.curve("overshot",      { type = "bezier", points = { {0.05, 0.9 }, {0.1,  1.1  } } })
hl.curve("crazyshot",     { type = "bezier", points = { {0.1,  1.5 }, {0.76, 0.92 } } })
hl.curve("hyprnostretch", { type = "bezier", points = { {0.05, 0.9 }, {0.1,  1.0  } } })
hl.curve("menu_decel",    { type = "bezier", points = { {0.1,  1   }, {0,    1    } } })
hl.curve("menu_accel",    { type = "bezier", points = { {0.38, 0.04}, {1,    0.07 } } })
hl.curve("easeInOutCirc", { type = "bezier", points = { {0.85, 0   }, {0.15, 1    } } })
hl.curve("easeOutCirc",   { type = "bezier", points = { {0,    0.55}, {0.45, 1    } } })
hl.curve("easeOutExpo",   { type = "bezier", points = { {0.16, 1   }, {0.3,  1    } } })
hl.curve("softAcDecel",   { type = "bezier", points = { {0.26, 0.26}, {0.15, 1    } } })
hl.curve("md2",           { type = "bezier", points = { {0.4,  0   }, {0.2,  1    } } })


-- ─── Animations ───────────────────────────────────────────────────────────────
hl.animation({ leaf = "windows",          enabled = true, speed = 3,   bezier = "md3_decel",  style = "popin 60%" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 3,   bezier = "md3_decel",  style = "popin 60%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 3,   bezier = "md3_accel",  style = "popin 60%" })
hl.animation({ leaf = "border",           enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3,   bezier = "md3_decel" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 3,   bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.6, bezier = "menu_accel" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 2,   bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 4.5, bezier = "menu_accel" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 7,   bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,   bezier = "md3_decel",  style = "slidevert" })
