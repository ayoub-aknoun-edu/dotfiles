-- Catppuccin Macchiato color palette
-- RGBA string format ("rgba(RRGGBBAA)") for borders and Hyprland color fields
-- ARGB hex format (0xAARRGGBB) for shadow/overlay where Hyprland expects it

-- Base palette
base       = "rgba(24273aff)"
mantle     = "rgba(1e2030ff)"
crust_str  = "rgba(181926ff)"
crust_hex  = 0xff181926   -- for shadow color (ARGB hex)

surface0   = "rgba(363a4fff)"
surface1   = "rgba(494d64ff)"
surface2   = "rgba(5b6078ff)"

overlay0   = "rgba(6e738dff)"
overlay1   = "rgba(8087a2ff)"
overlay2   = "rgba(939ab7ff)"

text       = "rgba(cad3f5ff)"
subtext1   = "rgba(b8c0e0ff)"
subtext0   = "rgba(a5adcbff)"

red        = "rgba(ed8796ff)"
maroon     = "rgba(ee99a0ff)"
peach      = "rgba(f5a97fff)"
yellow     = "rgba(eed49fff)"
green      = "rgba(a6da95ff)"
teal       = "rgba(8bd5caff)"
sky        = "rgba(91d7e3ff)"
sapphire   = "rgba(7dc4e4ff)"
blue       = "rgba(8aadf4ff)"
lavender   = "rgba(b7bdf8ff)"
mauve      = "rgba(c6a0f6ff)"
pink       = "rgba(f5bde6ff)"
flamingo   = "rgba(f0c6c6ff)"
rosewater  = "rgba(f4dbd6ff)"

-- Semantic tokens used across configs
accent          = mauve
accent2         = teal
inactive_border = overlay0
shadow_color    = crust_hex
