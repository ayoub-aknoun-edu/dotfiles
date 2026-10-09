# Dotfiles

Arch Linux + Hyprland (Lua config) rice with the [Noctalia](https://github.com/noctalia-dev) shell.

- One command turns a fresh Arch install into this desktop
- Every config is a stow symlink into this repo, so edits land here immediately
- Edits are auto-committed and pushed (after a gitleaks secret scan)

---

## Fresh install (Arch Linux)

Start from a minimal Arch install (archinstall is fine) with a user in `wheel`, networking and `git`:

```bash
git clone https://github.com/ayoub-aknoun-edu/dotfiles.git ~/dotfiles
~/dotfiles/install.sh            # asks about each optional profile
```

Then reboot and log in through Noctalia Greeter.

| Option                | Effect                                                         |
| --------------------- | -------------------------------------------------------------- |
| `--profiles dev,apps` | install these optional profiles, no questions                  |
| `--all`               | install every optional profile                                 |
| `--yes`               | no prompts (skips unselected profiles, `--noconfirm` installs) |
| `--dry-run`           | print every action without changing anything                   |

`install.sh` is re-runnable. Its steps, in order:

1. Checks that this is Arch and that you aren't root.
2. Picks the profiles.
3. Installs packages. yay is bootstrapped if it's missing, and `intel-ucode`/`amd-ucode` is added for your CPU.
4. Runs `stow.sh`. It moves files that would conflict to `~/.dotfiles-backup/<date>/`, links everything, then runs `scripts/post-install.sh`.
5. Runs `sudo scripts/setup-system.sh` for the system files and services.
6. Sets zsh as the login shell.
7. Clones the tmux plugins.
8. Runs `xdg-user-dirs-update` and enables the repo's git hooks.
9. Enables the Noctalia plugins, or prints the command to run after the first login.

### Profiles (`packages/*.txt`)

| Profile     | When              | Contents                                                                  |
| ----------- | ----------------- | ------------------------------------------------------------------------- |
| `core`      | always            | Hyprland/UWSM, Noctalia + greeter, greetd, NetworkManager+iwd, PipeWire, kitty, zsh, tmux, neovim, CLI tools, Thunar, fonts, theming |
| `hw-intel`  | auto (lspci)      | Intel VA-API/Vulkan/VPL, SOF audio firmware                               |
| `hw-amd`    | auto (lspci)      | Radeon Vulkan                                                             |
| `hw-nvidia` | auto (lspci)      | `nvidia-open` (Turing and newer)                                          |
| `dev`       | optional          | node, npm, uv, rust, cmake, plantuml, ngrok, …                            |
| `docker`    | optional          | docker + compose/buildx, ctop; daemon enabled, user added to `docker`     |
| `vm`        | optional          | QEMU/KVM, libvirt, virt-manager; libvirtd enabled, user added to `libvirt` |
| `flutter`   | optional          | flutter-bin, JDK 17, android-udev; user added to `flutter`                |
| `apps`      | optional          | Thorium, VS Code, Obsidian, Discord, Spotify, LibreOffice, OBS, …         |

One package per line, `#` for comments, and an `aur:` prefix marks AUR packages. To add a package, put it in a profile. `scripts/install-packages.sh <profile>...` installs one profile on its own.

---

## Keeping machines in sync

- **Edits are already in git.** Everything under `~/.config`, `~/.local/bin`, etc. is a symlink into `~/dotfiles`, so saving a config changes the repo working tree.
  - Noctalia's Settings-window state (`.local/state/noctalia/settings.toml`) is tracked too.
- **Auto-sync.** `dots-autosync.timer` (systemd user timer) commits and pushes pending changes every few minutes.
  - The `.githooks/pre-commit` gitleaks scan runs first. If it finds a secret, the commit is blocked and you get a notification.
- **`dots` helper:**

  | Command | What it does |
  | --- | --- |
  | `dots status` | show pending changes |
  | `dots sync` | sync now |
  | `dots log` | show the sync history |
  | `dots diff` | show uncommitted changes |
  | `dots pause` / `dots resume` | stop / restart auto-sync |
- **On the other laptop**, run `git -C ~/dotfiles pull` (or `dots sync`) to pick up changes. Re-run `install.sh` when new packages were added to a profile.
- **Secrets never go in the repo.** The repo is public. Keep tokens in untracked files such as `~/.config/wayvnc/`, `gh` auth and `.env` files.

---

## System-level setup (`scripts/setup-system.sh`, sudo)

Files under `system/` are copied into `/etc`. Every command is idempotent and backs up any file it replaces as `<file>.bak-<date>`. `install.sh` runs `services network logind bluetooth charge-limit greeter` (plus `docker` and `vm` with those profiles).

| Command            | Effect                                                                  |
| ------------------ | ----------------------------------------------------------------------- |
| `services`         | enable NetworkManager, iwd, bluetooth, timesyncd, fstrim + paccache timers |
| `network`          | NetworkManager on the iwd backend, Wi-Fi powersave off, systemd-resolved stub `resolv.conf` |
| `logind`           | lid close suspends; every session is locked before sleep               |
| `bluetooth`        | don't power Bluetooth on at boot                                        |
| `charge-limit`     | battery care 75→80 % via udev (skipped when the battery has no thresholds) |
| `greeter`          | greetd + Noctalia Greeter, gnome-keyring unlock at login                |
| `greeter-config`   | reinstall only the greeter look (`system/noctalia-greeter/greeter.toml`) |
| `greeter-fallback` | plain tuigreet. Use it if the greeter breaks: Ctrl+Alt+F2, log in, run it, reboot |
| `docker` / `vm`    | enable the daemon and add you to its group (`vm` also enables IPv4 forwarding) |
| `battery-cleanup`  | remove the old battery-threshold plugin's udev rule + group             |

```bash
sudo ~/dotfiles/scripts/setup-system.sh greeter-config
```

---

## Desktop

| Piece                | Config                                     | Notes                                                              |
| -------------------- | ------------------------------------------ | ------------------------------------------------------------------ |
| **Hyprland**         | `.config/hypr/`                            | Lua config split by concern; started by UWSM from Noctalia Greeter |
| **Noctalia**         | `.config/noctalia/config.toml`             | Bar, launcher, notifications, control center, lock screen, wallpaper, polkit agent, night light |
| **Noctalia GUI state** | `.local/state/noctalia/settings.toml`    | Overrides `config.toml`; written by the Settings window            |
| **Hypridle**         | `.config/hypr/hypridle-{ac,battery}.conf`  | AC/battery-aware timeouts; locks via `hypr/scripts/lock`           |
| **Lock**             | `hypr/scripts/lock`                        | Noctalia lock screen; hyprlock only if Noctalia is down            |
| **Colors**           | `.config/theme/matugen/`                   | `rice-wall` → matugen palette for kitty, tmux, nvim, hyprlock, Hyprland borders |
| **Kitty / tmux / Neovim** | `.config/{kitty,tmux,nvim}/`          | tmux sessions persist across reboots (resurrect + continuum)       |
| **Shell**            | `.zshrc`, `.config/shell/`                 | Oh-My-Zsh + Powerlevel10k, shared aliases/functions                |

The Noctalia plugins come from `[plugins]` in `config.toml`. Run this inside a session to fetch them:

```bash
noctalia msg plugins enable rxtsel/portctl yuuto/arch-updater
```

### Keys

| Key                         | Action                                   |
| --------------------------- | ---------------------------------------- |
| `Super+Alt+Space`           | Launcher                                 |
| `Super+N` / `Super+Ctrl+N`  | Control center / notifications           |
| `Super+Shift+N`             | Do not disturb                           |
| `Super+V`                   | Clipboard history                        |
| `Super+Shift+E`             | Session menu                             |
| `Super+L`                   | Lock                                     |
| `Super+,`                   | Noctalia settings                        |
| `Super+Alt+N`               | Night light                              |
| `Super+Shift+W` / `Super+Alt+W` | Wallpaper panel / random wallpaper   |
| `Super+Shift+A`             | Region screenshot → satty                |
| `Super+Shift+Space`         | Restart Noctalia                         |

Wallpapers live in `~/Pictures/Wallpapers`. `scripts/fetch-wallpapers.sh` downloads the pack listed in `packages/wallpapers.txt`, and `post-install.sh` runs it.

### Customization

| What                      | Where                                        |
| ------------------------- | -------------------------------------------- |
| Keybindings               | `.config/hypr/binding.lua`                   |
| Gaps, borders, animations | `.config/hypr/looknfeel.lua`                 |
| Monitor layout            | `.config/hypr/monitors.lua`                  |
| Bar / widgets / panels    | Noctalia Settings (`Super+,`)                |
| Idle timeouts             | `.config/hypr/hypridle-{ac,battery}.conf`    |
| Neovim plugins            | `.config/nvim/lua/plugins/`                  |
| Shell aliases / functions | `.config/shell/aliases.sh`, `functions.sh`   |

---

## Repository layout

```text
dotfiles/
├── install.sh        # entry point: packages → stow → system → services
├── stow.sh           # links the repo into $HOME, then runs post-install.sh
├── packages/         # profile package lists + wallpapers.txt
├── scripts/          # install-packages, post-install, setup-system, fetch-wallpapers
├── system/           # /etc files installed by setup-system.sh
├── .githooks/        # gitleaks pre-commit (used by auto-sync)
├── .config/  .local/ # stowed into $HOME
└── .config/windows11/ # PowerShell / Windows Terminal (not stowed)
```

### Windows 11

`.config/windows11/` holds a PowerShell 7 profile with an Oh My Posh theme and Windows Terminal settings. Update the hard-coded paths in the profile to match your Windows username.

### Machine-specific notes

- `settings.toml` stores absolute paths under `/home/ayoub` and is shared by auto-sync, so every machine must use the username `ayoub` (`install.sh` refuses otherwise). The lock-screen widgets target `eDP-1`, the usual laptop panel name.
- The lock-screen widgets in `settings.toml` are pinned to the `eDP-1` output.
- `charge-limit` only applies to batteries that expose `charge_control_*_threshold` (e.g. ThinkPads).

> **First zsh launch:** if `~/.p10k.zsh` is missing, run `p10k configure`.
> **Neovim:** plugins install on first launch (Lazy.nvim); run `:Copilot auth` once.
