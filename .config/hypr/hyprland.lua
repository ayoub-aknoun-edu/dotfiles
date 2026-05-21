-- Hyprland 0.55+ Lua configuration
-- https://wiki.hypr.land/Configuring/Start/
--
-- Load order matters:
--   colors  → defines palette globals used by looknfeel
--   envs    → set before any app is launched
--   monitors→ physical output setup
--   looknfeel, input → visual + input config
--   autostart → exec-once equivalents
--   binding, windowrules → keybinds and rules

-- Keep runtime logging quiet by default. Use `hyprctl configerrors` for
-- config issues, or temporarily flip this while debugging.
hl.config({ debug = { disable_logs = true } })

require("colors")
require("monitors")
-- UWSM sources ~/.config/uwsm/env before Hyprland starts. Keep envs.lua as a
-- direct-launch fallback so the config remains usable without UWSM.
if not os.getenv("UWSM_FINALIZE_VARNAMES") then
    require("envs")
end
require("looknfeel")
require("input")
require("autostart")
require("permissions")
require("binding")
require("windowrules")
