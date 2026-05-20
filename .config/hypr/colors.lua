-- Catppuccin Macchiato color palette
-- RGBA string format ("rgba(RRGGBBAA)") for borders and Hyprland color fields
-- ARGB hex format (0xAARRGGBB) for shadow/overlay where Hyprland expects it

local C = {}

-- Base palette
C.base       = "rgba(24273aff)"
C.mantle     = "rgba(1e2030ff)"
C.crust_str  = "rgba(181926ff)"
C.crust_hex  = 0xff181926   -- for shadow color (ARGB hex)

C.surface0   = "rgba(363a4fff)"
C.surface1   = "rgba(494d64ff)"
C.surface2   = "rgba(5b6078ff)"

C.overlay0   = "rgba(6e738dff)"
C.overlay1   = "rgba(8087a2ff)"
C.overlay2   = "rgba(939ab7ff)"

C.text       = "rgba(cad3f5ff)"
C.subtext1   = "rgba(b8c0e0ff)"
C.subtext0   = "rgba(a5adcbff)"

C.red        = "rgba(ed8796ff)"
C.maroon     = "rgba(ee99a0ff)"
C.peach      = "rgba(f5a97fff)"
C.yellow     = "rgba(eed49fff)"
C.green      = "rgba(a6da95ff)"
C.teal       = "rgba(8bd5caff)"
C.sky        = "rgba(91d7e3ff)"
C.sapphire   = "rgba(7dc4e4ff)"
C.blue       = "rgba(8aadf4ff)"
C.lavender   = "rgba(b7bdf8ff)"
C.mauve      = "rgba(c6a0f6ff)"
C.pink       = "rgba(f5bde6ff)"
C.flamingo   = "rgba(f0c6c6ff)"
C.rosewater  = "rgba(f4dbd6ff)"

-- Semantic tokens used across configs
C.accent          = C.mauve
C.accent2         = C.teal
C.inactive_border = C.overlay0
C.shadow_color    = C.crust_hex

return C
