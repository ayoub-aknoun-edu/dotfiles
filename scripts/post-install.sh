#!/usr/bin/env bash
# Run by stow.sh (and so by install.sh) after linking the dotfiles.
# User-level steps that can't be expressed as static dotfiles; re-runnable.
# System-level setup (services, greeter, network, logind) lives in
# scripts/setup-system.sh.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"

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

# All bound to graphical-session.target (started by UWSM), see hypr/autostart.lua.
UNITS=(
    noctalia.service
    hypridle.service
    hypridle-power-watcher.service
    battery-alert.timer
    dots-autosync.timer
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

# ── 5. Replace known-problem hypridle-git packages ───────────────────────────
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

# ── 6. Warn about foreign Hyprland git support packages ──────────────────────
if command -v pacman >/dev/null 2>&1; then
    HYPR_GIT_PKGS="$(pacman -Qqm 2>/dev/null | grep -E '^hypr.*-git(-debug)?$' || true)"
    if [ -n "$HYPR_GIT_PKGS" ]; then
        warn "Foreign Hyprland git packages are installed; prefer stable repo packages for this setup:"
        printf '%s\n' "$HYPR_GIT_PKGS" | sed 's/^/  - /'
    fi
fi

# ── 7. Wallpapers + generated palette ──────────────────────────────────────
info "Fetching wallpaper pack into ~/Pictures/Wallpapers"
bash "$SCRIPT_DIR/fetch-wallpapers.sh" || warn "Some wallpapers failed to download"
"$HOME/.local/bin/rice-wall" init && ok "Palette ready (theme/generated)"

# ── 8. VS Code theme that follows the wallpaper (Noctalia "vscode" template) ─
if command -v code >/dev/null 2>&1; then
    code --install-extension Noctalia.noctaliatheme >/dev/null 2>&1 \
        && ok "VS Code NoctaliaTheme installed (select it: Ctrl+K Ctrl+T)" \
        || warn "Could not install the VS Code NoctaliaTheme extension"
fi

# ── 9. User avatar for the greeter / lock screen (AccountsService) ──────────
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

# ── 10. Git hooks (gitleaks pre-commit) for auto-sync ───────────────────────
if [[ -d "$REPO_DIR/.githooks" ]]; then
    git -C "$REPO_DIR" config core.hooksPath .githooks && ok "Git hooks: .githooks (gitleaks pre-commit)"
fi

echo ""
info "Post-install complete."
warn "If this is a fresh shell, restart it or run: exec zsh"
