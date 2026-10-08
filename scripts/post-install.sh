#!/usr/bin/env bash
# Run once after stow.sh on a fresh machine.
# Handles things that can't be expressed as static dotfiles.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m✓\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m!\033[0m  %s\n' "$*"; }

unit_exists() {
    systemctl list-unit-files "$1" >/dev/null 2>&1
}

# ── 1. GTK bookmarks ──────────────────────────────────────────────────────────
info "Writing GTK bookmarks for $HOME"
BOOKMARKS_DIR="$HOME/.config/gtk-3.0"
mkdir -p "$BOOKMARKS_DIR"
cat > "$BOOKMARKS_DIR/bookmarks" <<EOF
file://$HOME/Downloads
file://$HOME/Documents
file://$HOME/Pictures
file://$HOME/Public
file://$HOME/Templates
file://$HOME/Dev
EOF
ok "GTK bookmarks written"

# ── 2. Systemd user services ──────────────────────────────────────────────────
info "Enabling systemd user services"
systemctl --user daemon-reload

# All bound to graphical-session.target (started by UWSM), see hypr/autostart.lua.
UNITS=(
    hyprpolkitagent.service
    hyprsunset.service
    hypridle.service
    hypridle-power-watcher.service
    battery-alert.timer
)

for unit in "${UNITS[@]}"; do
    if systemctl --user enable "$unit" 2>/dev/null; then
        ok "Enabled $unit"
    else
        warn "Could not enable $unit (already enabled or missing)"
    fi
done

if systemctl --user is-active --quiet graphical-session.target 2>/dev/null || [ -n "${WAYLAND_DISPLAY:-}" ]; then
    info "Starting user services for the current session"
    for unit in "${UNITS[@]}"; do
        if systemctl --user start "$unit" 2>/dev/null; then
            ok "Started $unit"
        else
            warn "Could not start $unit now; it should start on next login if enabled"
        fi
    done
else
    warn "No graphical user session detected; user services will start on next login"
fi

# ── 3. System services ────────────────────────────────────────────────────────
info "Enabling system services"
SYSTEM_UNITS=(
    NetworkManager.service
    bluetooth.service
    sddm.service
)

for unit in "${SYSTEM_UNITS[@]}"; do
    if unit_exists "$unit"; then
        case "$unit" in
            sddm.service)
                if sudo systemctl enable "$unit" 2>/dev/null; then
                    ok "Enabled $unit"
                else
                    warn "Could not enable $unit"
                fi
                ;;
            *)
                if sudo systemctl enable --now "$unit" 2>/dev/null; then
                    ok "Enabled and started $unit"
                else
                    warn "Could not enable/start $unit"
                fi
                ;;
        esac
    else
        warn "$unit not found; install its package first"
    fi
done

# ── 4. Oh-My-Zsh ─────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ] && [ ! -d "$HOME/dotfiles/vendor/oh-my-zsh" ]; then
    info "Installing Oh-My-Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended --keep-zshrc
    ok "Oh-My-Zsh installed"
else
    ok "Oh-My-Zsh already present — skipping"
fi

# ── 5. Powerlevel10k ─────────────────────────────────────────────────────────
P10K_DEST="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DEST" ]; then
    info "Cloning Powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DEST"
    ok "Powerlevel10k cloned — run 'p10k configure' to set up your prompt"
else
    ok "Powerlevel10k already present — skipping"
fi

# ── 6. logind lid-switch ──────────────────────────────────────────────────────
LOGIND_DROP="/etc/systemd/logind.conf.d/lid.conf"
if [ ! -f "$LOGIND_DROP" ]; then
    info "Configuring logind lid-switch (requires sudo)"
    sudo mkdir -p /etc/systemd/logind.conf.d
    sudo tee "$LOGIND_DROP" > /dev/null <<'LOGIND'
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
LOGIND
    sudo systemctl kill -s HUP systemd-logind
    ok "logind lid.conf written and reloaded"
else
    ok "logind lid.conf already present — skipping"
fi

# ── 7. lock-before-sleep system hook ─────────────────────────────────────────
SLEEP_HOOK="/etc/systemd/system-sleep/lock-before-sleep.sh"
if [ ! -f "$SLEEP_HOOK" ]; then
    info "Installing lock-before-sleep hook (requires sudo)"
    sudo mkdir -p /etc/systemd/system-sleep
    sudo tee "$SLEEP_HOOK" > /dev/null <<'HOOK'
#!/usr/bin/env bash
# Lock all sessions before suspend/hibernate so the screen is always locked
# on lid close, regardless of whether hypridle is running.
case "$1" in
    pre) loginctl lock-sessions; sleep 1 ;;
esac
HOOK
    sudo chmod +x "$SLEEP_HOOK"
    ok "lock-before-sleep hook installed"
else
    ok "lock-before-sleep hook already present — skipping"
fi

# ── 8. Replace known-problem hypridle-git packages ───────────────────────────
HYPRIDLE_GIT_PKGS=()
for pkg in hypridle-git hypridle-git-debug; do
    if pacman -Qq "$pkg" &>/dev/null; then
        HYPRIDLE_GIT_PKGS+=("$pkg")
    fi
done

if (( ${#HYPRIDLE_GIT_PKGS[@]} > 0 )); then
    info "Replacing hypridle-git packages with stable hypridle"
    sudo pacman -Rs --noconfirm "${HYPRIDLE_GIT_PKGS[@]}" 2>/dev/null || true
    sudo pacman -S --noconfirm hypridle
    ok "hypridle replaced with stable version"
else
    ok "hypridle-git not installed — skipping"
fi

# ── 9. Warn about foreign Hyprland git support packages ──────────────────────
if command -v pacman >/dev/null 2>&1; then
    HYPR_GIT_PKGS="$(pacman -Qqm 2>/dev/null | grep -E '^hypr.*-git(-debug)?$' || true)"
    if [ -n "$HYPR_GIT_PKGS" ]; then
        warn "Foreign Hyprland git packages are installed; prefer stable repo packages for this setup:"
        printf '%s\n' "$HYPR_GIT_PKGS" | sed 's/^/  - /'
    fi
fi

# ── 10. Wallpapers + generated palette ──────────────────────────────────────
info "Fetching wallpaper pack into ~/Pictures/Wallpapers"
bash "$SCRIPT_DIR/fetch-wallpapers.sh" || warn "Some wallpapers failed to download"
"$HOME/.local/bin/rice-wall" init && ok "Palette ready (theme/generated)"

# ── 11. VS Code theme that follows the wallpaper (Noctalia "vscode" template) ─
if command -v code >/dev/null 2>&1; then
    code --install-extension Noctalia.noctaliatheme >/dev/null 2>&1 \
        && ok "VS Code NoctaliaTheme installed (select it: Ctrl+K Ctrl+T)" \
        || warn "Could not install the VS Code NoctaliaTheme extension"
fi

# ── 12. User avatar for the greeter / lock screen (AccountsService) ──────────
# AccountsService rejects icons over 1 MB and the greeter can't read $HOME, so
# register a 512px copy; it gets stored in /var/lib/AccountsService/icons.
if [[ -f "$HOME/.face.icon" ]] && command -v vipsthumbnail >/dev/null 2>&1; then
    vipsthumbnail "$HOME/.face.icon" -s 512x512 -o "$HOME/.face.png" 2>/dev/null \
        && mv "$HOME/.face.png" "$HOME/.face" \
        && busctl call --system org.freedesktop.Accounts "/org/freedesktop/Accounts/User$(id -u)" \
               org.freedesktop.Accounts.User SetIconFile s "$HOME/.face" \
        && ok "Avatar registered with AccountsService" \
        || warn "Could not register the avatar"
    # Round copy for the Noctalia lock screen (sticker widget in settings.toml)
    mkdir -p "$HOME/.local/share/rice"
    ffmpeg -loglevel error -y -i "$HOME/.face" \
        -vf "scale=256:256,format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='if(lte(hypot(X-127.5,Y-127.5),127.5),255,0)'" \
        "$HOME/.local/share/rice/avatar-round.png" && ok "Round lock-screen avatar created"
fi

echo ""
info "Post-install complete."
warn "If this is a fresh shell, restart it or run: exec zsh"
