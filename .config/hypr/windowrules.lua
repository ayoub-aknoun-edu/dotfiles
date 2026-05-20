-- Window & Layer Rules
-- See https://wiki.hypr.land/Configuring/Window-Rules/
-- See https://wiki.hypr.land/Configuring/Layer-Rules/


-- ─── General ──────────────────────────────────────────────────────────────────

-- Prevent apps from forcing maximize (they can still ask for it via the button)
hl.window_rule({
    name           = "ignore-maximize-requests",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- XWayland drag-and-drop ghost-window fix
hl.window_rule({
    name             = "xwayland-drag-nofocus",
    match            = { class = "^$", title = "^$", xwayland = true,
                         float = true, fullscreen = false, pin = false },
    no_initial_focus = true,
    no_focus         = true,
})


-- ─── Layer Rules ──────────────────────────────────────────────────────────────

-- SwayNC control center blur
hl.layer_rule({
    name        = "swaync-control-center-effects",
    match       = { namespace = "swaync-control-center" },
    blur        = true,
    ignore_alpha = 0.2,
})

-- SwayNC notification popup blur
hl.layer_rule({
    name         = "swaync-notification-effects",
    match        = { namespace = "swaync-notification-window" },
    blur         = true,
    ignore_alpha = 0.2,
})

-- Wlogout blur
hl.layer_rule({
    name         = "wlogout-blur-logout_dialog",
    match        = { namespace = "logout_dialog" },
    blur         = true,
    ignore_alpha = 0.2,
})
hl.layer_rule({
    name         = "wlogout-blur-wlogout",
    match        = { namespace = "wlogout" },
    blur         = true,
    ignore_alpha = 0.2,
})

-- Rofi blur
hl.layer_rule({
    name         = "rofi-blur",
    match        = { namespace = "rofi" },
    blur         = true,
    ignore_alpha = 0.5,
})

-- eww control center blur
hl.layer_rule({
    name         = "eww-control-center-blur",
    match        = { namespace = "eww-control-center" },
    blur         = true,
    ignore_alpha = 0.05,
})


-- ─── Picture-in-Picture ───────────────────────────────────────────────────────
-- Covers Firefox ("Picture-in-Picture") and Chromium-based ("Picture in Picture")
hl.window_rule({
    name  = "pip-float",
    match = { title = "^[Pp]icture.in.[Pp]icture$" },
    float           = true,
    pin             = true,
    size            = "400 300",
    move            = "100%-410 100%-310",  -- bottom-right, 10px from edge
})


-- ─── Permission / Auth Dialogs ────────────────────────────────────────────────
hl.window_rule({
    name              = "browser-permission-dialogs",
    match             = { class = "thorium-browser",
                          title = "^(Open|Save|Select|.*[Pp]ermission.*|.*Use your.*|.*Access.*|.*wants to.*)$" },
    float             = true,
    center            = true,
    pin               = true,
    focus_on_activate = true,
    size              = "600 400",
})


-- ─── Calls (WhatsApp / browser-based VOIP) ───────────────────────────────────
-- Floating call window – keeps WebRTC handshake alive by keeping focus
hl.window_rule({
    name              = "whatsapp-call-window",
    match             = { class = "thorium-browser", title = "^WhatsApp.*$" },
    float             = true,
    center            = true,
    pin               = true,
    focus_on_activate = true,
    size              = "600 800",
    min_size          = "400 400",
})

-- Extra stability for active call states (ringing, video, etc.)
hl.window_rule({
    name              = "whatsapp-call-stability",
    match             = { class = "thorium-browser",
                          title = "WhatsApp.*(Call|call|Video|Voice|Ringing|Connecting).*" },
    focus_on_activate = true,
    idle_inhibit      = "focus",
})


-- ─── Screen Sharing Indicators ───────────────────────────────────────────────
-- Browser "is sharing your screen" bar – move it out of the way
hl.window_rule({
    name              = "browser-sharing-indicator",
    match             = { class = "^$", title = ".*[Ss]haring.*" },
    float             = true,
    pin               = true,
    move              = "50%-200 100%-50",  -- bottom-center
})


-- ─── xwaylandvideobridge ─────────────────────────────────────────────────────
-- Makes the bridge window completely invisible so it doesn't obscure content
-- while still allowing screen capture to work correctly
hl.window_rule({
    name             = "xwaylandvideobridge-invisible",
    match            = { class = "xwaylandvideobridge" },
    no_anim          = true,
    no_shadow        = true,
    no_blur          = true,
    no_focus         = true,
    no_initial_focus = true,
    opacity          = "0.0 0.0",
    -- Shrink to 1×1 and move off-screen
    size             = "1 1",
    move             = "-1 -1",
})


-- ─── Zoom ────────────────────────────────────────────────────────────────────
-- Main meeting window – tiled, suppress maximize requests
hl.window_rule({
    name           = "zoom-meeting",
    match          = { class = "zoom", title = "Zoom Meeting" },
    float          = false,
    suppress_event = "maximize",
})

-- Zoom popups and side panels – float them
hl.window_rule({
    name   = "zoom-popups",
    match  = { class = "zoom",
               title = "^(zoom|Chat|Participants|Settings|Poll|Q&A|Closed Caption|Virtual Background|Reactions).*$" },
    float  = true,
    center = true,
})

-- Zoom screen-sharing toolbar
hl.window_rule({
    name  = "zoom-share-toolbar",
    match = { class = "zoom", title = ".*[Ss]haring.*" },
    float = true,
    pin   = true,
})


-- ─── Microsoft Teams ─────────────────────────────────────────────────────────
hl.window_rule({
    name  = "teams-screenshare",
    match = { class = "^[Mm]icrosoft-[Ee]dge.*", title = ".*[Ss]haring.*" },
    float = true,
    pin   = true,
})

-- Teams auth / permission popup
hl.window_rule({
    name   = "teams-auth-dialogs",
    match  = { class = "^[Mm]icrosoft-[Ee]dge.*",
               title = "^(Sign in|Grant permission|.*wants to.*|Pick an account).*$" },
    float  = true,
    center = true,
})


-- ─── Thorium misc ─────────────────────────────────────────────────────────────
hl.window_rule({
    name   = "thorium-misc-dialogs",
    match  = { class = "thorium-browser", title = "^(Terms of Service|about:blank)$" },
    float  = true,
    center = true,
})
