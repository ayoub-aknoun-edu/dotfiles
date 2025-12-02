# 🧰 Dotfiles

Personal configuration files for my daily development environment.

This repo is meant to:

- Keep my configs version-controlled and portable
- Reproduce my setup quickly on a fresh system (Linux + Windows)
- Serve as a reference for my Hyprland / Waybar / Neovim setup
- Share ideas with anyone looking for a similar workflow

---

## ✨ What’s included

### 🖥️ Linux (Wayland / Hyprland)

All Linux configs live under `~/.config`:

- **Hyprland** (`.config/hypr/`)
  - Split into logical files: `monitors.conf`, `looknfeel.conf`, `input.conf`, `binding.conf`, `windowrules.conf`, etc.
  - Tiling layout with gaps, rounded corners and animations
  - Per-monitor configuration
  - Wallpaper + hyprpaper integration
  - Window rules and permissions tuned for daily dev use

- **Waybar** (`.config/waybar/`)
  - Top bar with:
    - App launcher (Rofi)
    - Taskbar, clock, Hyprland window title
    - Idle toggle, power menu, screen recorder, updates indicator
  - Custom scripts in `scripts/`:
    - `power` – lock / suspend / reboot / shutdown via Rofi
    - `screenrec` – screen recording helper
    - `updates` / `update-now` – system update status & trigger
    - `idle-toggle` – control idle behavior
  - Styled via `style.css` with margins and spacing for a clean look

- **Rofi** (`.config/rofi/`)
  - Custom theme with:
    - Accent colors
    - Consistent background/foreground palette
  - `rofi-clipboard` helper script for clipboard selection

- **Kitty** (`.config/kitty/kitty.conf`)
  - Uses **JetBrainsMono Nerd Font**
  - Transparent background and padded window
  - Clipboard integration (`copy_on_select`, keymaps)
  - Opens URLs with `thorium-browser`
  - Small QoL tweaks (no audio bell, URL detection, etc.)

- **Neovim** (`.config/nvim/`)
  - LazyVim-based setup with custom modules:
    - `lua/config/` – core config (options, keymaps, autocmds, lazy.nvim)
    - `lua/plugins/` – plugin definitions & per-language extras:
      - `go.lua` – `gopls` config with analyses, staticcheck, placeholders
      - `java.lua` – Java LSP tooling
      - `angular.lua`, `flutter.lua` – framework-specific helpers
      - `lsp.lua`, `linting.lua`, `formatting.lua`, `conform.lua`
      - `copilot.lua` – GitHub Copilot integration
      - `surround.lua` – text surrounding helpers
      - `codesnap.lua` – code snapshot plugin config
      - `windsurf.lua` – extra editor-related config
  - `stylua.toml` for consistent Lua formatting
  - `lazy-lock.json` to pin plugin versions

- **Theming**  
  - **GTK 3 / 4**: `.config/gtk-3.0/settings.ini`, `.config/gtk-4.0/settings.ini`
  - **Kvantum**: `.config/Kvantum/kvantum.kvconfig` for Qt app theming

---

### 🪟 Windows 11

Windows-specific configs live in `.config/windows11/`:

- `Microsoft.PowerShell_profile.ps1`
  - Sets up **PowerShell 7+** profile
  - Integrates **Oh My Posh** with a custom theme

- `akanoun.omp.json`
  - Oh My Posh prompt theme used by the profile
  - You may need to adjust the path inside the PowerShell profile to match your user directory and installation path.

---

## 📁 Repository layout

```text
dotfiles/
├── .config/
│   ├── Kvantum/
│   ├── gtk-3.0/
│   ├── gtk-4.0/
│   ├── hypr/
│   ├── kitty/
│   ├── nvim/
│   ├── rofi/
│   ├── waybar/
│   └── windows11/
├── .gitignore
├── .stow-global-ignore
└── stow.sh
````

* `stow.sh` – helper script to apply the dotfiles using GNU Stow
* `.stow-global-ignore` – excludes files from being symlinked (e.g. `.git`)

---

## 🔧 Requirements

On **Linux** (Wayland / Hyprland setup), you’ll typically want:

* `hyprland`, `hyprpaper`
* `waybar`
* `rofi`
* `kitty`
* `neovim`
* `git`, `stow` (GNU Stow)
* JetBrainsMono Nerd Font (or adjust the font in `kitty.conf`)
* A Wayland-compatible notification/lock solution (e.g. `hyprlock` if referenced)

On **Windows**:

* PowerShell 7+
* [Oh My Posh](https://ohmyposh.dev/) installed
* Fonts with Nerd Font glyphs (for the prompt theme)

> Note: exact packages and install commands depend on your distro / OS; adjust accordingly.

---

## 🚀 Installation (Linux)

1. **Install dependencies**
   Use your distro’s package manager to install Hyprland, Waybar, Rofi, Kitty, Neovim, GNU Stow, etc.

2. **Clone the repo**

   ```bash
   cd ~
   git clone https://github.com/ayoub-aknoun-edu/dotfiles.git
   cd ~/dotfiles
   ```

3. **Apply configs with Stow**

   The provided script assumes the repo lives in `~/dotfiles`:

   ```bash
   ./stow.sh
   ```

   Internally this runs:

   ```bash
   stow -d ~/dotfiles/ -t ~/ .
   ```

   which symlinks the contents of the repo into your home directory.

4. **Log out / restart Hyprland**
   After applying, restart your Hyprland session to load the new configs.

---

## 🪟 Setup (Windows)

1. Copy or link the PowerShell profile:

   * Find your PowerShell profile path:

     ```powershell
     echo $PROFILE
     ```

   * Copy or symlink `.config/windows11/Microsoft.PowerShell_profile.ps1` to that path.

2. Update any hard-coded paths inside the profile (e.g. the location of `oh-my-posh` and `akanoun.omp.json`) to match your Windows username and installation directories.

3. Install **Oh My Posh** and set the font in your terminal to a Nerd Font for full glyph support.

---

## 🧩 Customization

* **Keybindings** – adjust in `.config/hypr/binding.conf`
* **Gaps, borders, animations** – tweak in `.config/hypr/looknfeel.conf`
* **Bar modules & styling** – edit `.config/waybar/config.jsonc` and `style.css`
* **Launcher theme** – modify `.config/rofi/config.rasi`
* **Neovim behavior** – use:

  * `lua/config/*` for core settings
  * `lua/plugins/*` to enable/disable or extend plugins

Feel free to fork and adapt these dotfiles to your own taste.
