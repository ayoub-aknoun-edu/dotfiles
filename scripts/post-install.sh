#!/usr/bin/env bash
# Run once after stow.sh on a fresh machine.
# Handles things that can't be expressed as static dotfiles.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m✓\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m!\033[0m  %s\n' "$*"; }

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

UNITS=(
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

# ── 3. Oh-My-Zsh ─────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ] && [ ! -d "$HOME/dotfiles/vendor/oh-my-zsh" ]; then
    info "Installing Oh-My-Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended --keep-zshrc
    ok "Oh-My-Zsh installed"
else
    ok "Oh-My-Zsh already present — skipping"
fi

# ── 4. Powerlevel10k ─────────────────────────────────────────────────────────
P10K_DEST="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DEST" ]; then
    info "Cloning Powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DEST"
    ok "Powerlevel10k cloned — run 'p10k configure' to set up your prompt"
else
    ok "Powerlevel10k already present — skipping"
fi

# ── 5. logind lid-switch ──────────────────────────────────────────────────────
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

# ── 6. lock-before-sleep system hook ─────────────────────────────────────────
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

# ── 7. Replace hypridle-git with stable extra/hypridle ───────────────────────
if pacman -Q hypridle-git &>/dev/null; then
    info "Replacing hypridle-git (segfaults with sdbus-cpp 2.3.x) with stable hypridle"
    sudo pacman -Rs --noconfirm hypridle-git 2>/dev/null || true
    sudo pacman -S --noconfirm hypridle
    ok "hypridle replaced with stable version"
else
    ok "hypridle-git not installed — skipping"
fi

echo ""
info "Post-install complete."
warn "If this is a fresh shell, restart it or run: exec zsh"
