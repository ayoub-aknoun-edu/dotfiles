# Dotfiles

Personal configuration files for my daily development environment.

- Version-controlled and portable across machines
- Full Arch Linux / Hyprland / Wayland setup
- One-command bootstrap on a fresh install

---

## What's included

### Linux (Wayland / Hyprland)

| App            | Config                                     | Notes                                                                               |
| -------------- | ------------------------------------------ | ----------------------------------------------------------------------------------- |
| **Hyprland**   | `.config/hypr/`                            | Lua-based config split by concern (monitors, bindings, rules, look&feel, autostart) |
| **Hypridle**   | `.config/hypr/hypridle-{ac,battery}.conf`  | AC/battery-aware idle timeouts, lid-close locking                                   |
| **Hyprlock**   | `.config/hypr/hyprlock/`                   | Custom lock screen with clock, avatar, power buttons                                |
| **Waybar**     | `.config/waybar/`                          | Top bar with taskbar, clock, battery, updates, power menu                           |
| **EWW**        | `.config/eww/`                             | Control center (quick settings, MPRIS, notifications)                               |
| **Rofi**       | `.config/rofi/`                            | App launcher + clipboard picker                                                     |
| **SwayNC**     | `.config/swaync/`                          | Notification center                                                                 |
| **Kitty**      | `.config/kitty/`                           | Terminal — JetBrainsMono NF, 0.7 opacity                                            |
| **Neovim**     | `.config/nvim/`                            | LazyVim-based, Go/Java/Angular/Flutter LSP                                          |
| **Theme**      | `.config/theme/`                           | Catppuccin Macchiato across all apps                                                |
| **Shell**      | `.bashrc`, `.zshrc`, `.config/shell/`      | Shared aliases/functions, Oh-My-Zsh + Powerlevel10k                                 |

### Windows 11

| File                                                          | Notes                                    |
| ------------------------------------------------------------- | ---------------------------------------- |
| `.config/windows11/Microsoft.PowerShell_profile.ps1`          | PowerShell 7+ profile with Oh My Posh    |
| `.config/windows11/akanoun.omp.json`                          | Custom Oh My Posh theme                  |

> Update the hard-coded paths inside the PowerShell profile to match your Windows username.

---

## Repository layout

```text
dotfiles/
├── .config/          # All app configs (stowed to ~/.config/)
├── .local/bin/       # Custom scripts (stowed to ~/.local/bin/)
├── packages/
│   ├── pacman.txt    # Official repo packages
│   └── aur.txt       # AUR packages
├── scripts/
│   ├── install-packages.sh   # Installs everything from packages/
│   └── post-install.sh       # Post-stow steps (GTK bookmarks, systemd, Oh-My-Zsh, p10k)
├── .bashrc
├── .zshrc
├── .zprofile
├── stow.sh           # Symlinks repo into $HOME, then runs post-install.sh
└── Readme.md
```

---

## Fresh install (Arch Linux)

```bash
# 1. Clone
git clone https://github.com/ayoub-aknoun-edu/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install all packages (offers to install yay if needed)
./scripts/install-packages.sh

# 3. Stow + post-install in one step
./stow.sh
```

`stow.sh` symlinks every config into `$HOME`, then automatically runs `scripts/post-install.sh` which:

- Writes `~/.config/gtk-3.0/bookmarks` with the correct `$HOME` for this machine
- Enables `hypridle.service`, `hypridle-power-watcher.service`, `battery-alert.timer` via systemd
- Installs Oh-My-Zsh if not already present
- Clones Powerlevel10k if not already present
- Writes `/etc/systemd/logind.conf.d/lid.conf` so lid close locks before suspend

After that, log out and back in (or start a fresh Hyprland session).

> **First zsh launch:** run `p10k configure` to generate your prompt theme.
> **Neovim:** plugins install automatically on first launch via Lazy.nvim.
> **GitHub Copilot:** run `:Copilot auth` inside Neovim.

---

## Customization

| What                      | Where                                              |
| ------------------------- | -------------------------------------------------- |
| Keybindings               | `.config/hypr/binding.lua`                         |
| Gaps, borders, animations | `.config/hypr/looknfeel.lua`                       |
| Colors / theme            | `.config/theme/hypr-colors.conf`                   |
| Monitor layout            | `.config/hypr/monitors.lua`                        |
| Bar modules & style       | `.config/waybar/config.jsonc`, `style.css`         |
| Lock screen layout        | `.config/hypr/hyprlock/widgets.conf`               |
| Idle timeouts (AC)        | `.config/hypr/hypridle-ac.conf`                    |
| Idle timeouts (battery)   | `.config/hypr/hypridle-battery.conf`               |
| Neovim plugins            | `.config/nvim/lua/plugins/`                        |
| Shell aliases / functions | `.config/shell/aliases.sh`, `functions.sh`         |
