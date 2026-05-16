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

-- Enable logging so errors show in the log file
hl.config({ debug = { disable_logs = false } })

require("colors")
require("monitors")
require("envs")
require("looknfeel")
require("input")
require("autostart")
require("binding")
require("windowrules")
