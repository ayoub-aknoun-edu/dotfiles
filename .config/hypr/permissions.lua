-- Dynamic permissions
-- Requires a Hyprland restart to take effect.

hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})

hl.permission({ binary = "/usr/(bin|local/bin)/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })

-- Lock screens capture the screen for their background / lock transition.
-- Without these, Hyprland asks on every login ("Remember" only lasts until
-- Hyprland restarts). hyprlock = classic shell, noctalia = everyday shell.
hl.permission({ binary = "/usr/(bin|local/bin)/hyprlock", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(bin|local/bin)/noctalia", type = "screencopy", mode = "allow" })
-- ~/.local/bin/second-screen streams a virtual monitor to a phone.
hl.permission({ binary = "/usr/(bin|local/bin)/wayvnc", type = "screencopy", mode = "allow" })
