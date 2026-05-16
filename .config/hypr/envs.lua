-- Environment variables
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Cursor
hl.env("XCURSOR_SIZE",   "24")
hl.env("HYPRCURSOR_SIZE","24")

-- Theming
hl.env("GTK_THEME",           "Adwaita:dark")
hl.env("QT_STYLE_OVERRIDE",   "kvantum")
hl.env("QT_QPA_PLATFORMTHEME","qt6ct")
hl.env("XDG_ICON_THEME",      "Papirus-Dark")
hl.env("XDG_MENU_PREFIX",     "arch-")

-- Desktop / session type
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")

-- Backend hints for toolkits
hl.env("GDK_BACKEND",                   "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",               "wayland;xcb")
hl.env("SDL_VIDEODRIVER",               "wayland")
hl.env("MOZ_ENABLE_WAYLAND",            "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT",  "wayland")
hl.env("OZONE_PLATFORM",                "wayland")

-- Pipewire / screen-sharing
hl.env("PIPEWIRE_RUNTIME_DIR", os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000")
