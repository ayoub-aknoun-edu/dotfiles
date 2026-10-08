#!/usr/bin/env bash
# System-level (/etc, /var) parts of the rice that stow can't link.
# Run with sudo from the repo:
#
#   sudo scripts/setup-system.sh battery           charge-cap permissions (udev + group)
#   sudo scripts/setup-system.sh greeter           switch login screen SDDM → greetd + Noctalia Greeter
#   sudo scripts/setup-system.sh greeter-fallback  greetd with the plain tuigreet (if the greeter breaks)
#   sudo scripts/setup-system.sh greeter-rollback  back to SDDM
#
# Idempotent; every replaced file is backed up as <file>.bak-<date>.
# Display-manager changes apply on the next boot (never --now: that would kill
# the running session). Recovery from a broken login: Ctrl+Alt+F2, log in,
# run `sudo ~/dotfiles/scripts/setup-system.sh greeter-rollback`, reboot.

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
SYS="$REPO/system"
TARGET_USER="${SUDO_USER:-}"
STAMP="$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m  %s\n' "$*"; }
die()  { printf '\033[1;31m✗\033[0m  %s\n' "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "run with sudo"
[[ -n "$TARGET_USER" && "$TARGET_USER" != root ]] || die "run via sudo from your user account"

# install_file <src> <dest> [mode]: back up a differing existing file, then copy.
install_file() {
    local src="$1" dest="$2" mode="${3:-644}"
    if [[ -e "$dest" ]] && ! cmp -s "$src" "$dest"; then
        cp -a "$dest" "$dest.bak-$STAMP"
        info "backed up $dest → $dest.bak-$STAMP"
    fi
    install -Dm"$mode" "$src" "$dest"
    ok "installed $dest"
}

require_pkgs() {
    local missing=()
    local p
    for p in "$@"; do pacman -Q "$p" >/dev/null 2>&1 || missing+=("$p"); done
    (( ${#missing[@]} == 0 )) || die "install first: yay -S --needed ${missing[*]}"
}

cmd_battery() {
    getent group battery_ctl >/dev/null || { groupadd battery_ctl; ok "created group battery_ctl"; }
    usermod -aG battery_ctl "$TARGET_USER"
    ok "$TARGET_USER is in battery_ctl (takes effect after re-login)"
    install_file "$SYS/udev/99-battery-threshold.rules" /etc/udev/rules.d/99-battery-threshold.rules
    udevadm control --reload-rules
    udevadm trigger --subsystem-match=power_supply
    ok "udev rule active"
}

# greetd's PAM file lacks gnome-keyring: without it the login keyring stays
# locked after logging in (SDDM had these lines).
ensure_keyring_pam() {
    local pam=/etc/pam.d/greetd
    [[ -f "$pam" ]] || die "$pam missing (is greetd installed?)"
    grep -q pam_gnome_keyring "$pam" && { ok "keyring already in $pam"; return; }
    cp -a "$pam" "$pam.bak-$STAMP"
    sed -i '/^auth[[:space:]]\+include/a -auth       optional     pam_gnome_keyring.so' "$pam"
    sed -i '/^session[[:space:]]\+include/a -session    optional     pam_gnome_keyring.so auto_start' "$pam"
    grep -q pam_gnome_keyring "$pam" || die "could not add keyring lines to $pam"
    ok "added gnome-keyring unlock to $pam"
}

switch_dm_to_greetd() {
    systemctl disable sddm.service 2>/dev/null || true
    systemctl enable greetd.service
    ok "greetd enabled for next boot (SDDM disabled, still installed)"
}

cmd_greeter() {
    require_pkgs greetd noctalia-greeter greetd-tuigreet accountsservice
    [[ -x /usr/bin/noctalia-greeter-session ]] || die "/usr/bin/noctalia-greeter-session not found"

    install_file "$SYS/greetd/config.toml" /etc/greetd/config.toml
    ensure_keyring_pam

    local tmp
    tmp="$(mktemp)"
    sed "s/@USER@/$TARGET_USER/" "$SYS/noctalia-greeter/greeter.toml" > "$tmp"
    install_file "$tmp" /var/lib/noctalia-greeter/greeter.toml
    rm -f "$tmp"

    systemctl enable accounts-daemon.service
    switch_dm_to_greetd
    echo
    info "Reboot to see the new login screen."
    info "Then in Noctalia: Settings → Security → Noctalia Greeter → Sync Now (and Auto-Sync)."
}

cmd_greeter_fallback() {
    require_pkgs greetd greetd-tuigreet
    local tmp
    tmp="$(mktemp)"
    cat > "$tmp" <<'EOF'
# /etc/greetd/config.toml — fallback (scripts/setup-system.sh greeter-fallback)
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-session --asterisks --sessions /usr/share/wayland-sessions"
user = "greeter"
EOF
    install_file "$tmp" /etc/greetd/config.toml
    rm -f "$tmp"
    switch_dm_to_greetd
    info "Reboot (or: systemctl restart greetd from a TTY) for the text login."
}

cmd_greeter_rollback() {
    systemctl disable greetd.service 2>/dev/null || true
    systemctl enable sddm.service
    ok "SDDM re-enabled for next boot"
}

[[ $# -gt 0 ]] || { sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
for cmd in "$@"; do
    case "$cmd" in
        battery)          cmd_battery ;;
        greeter)          cmd_greeter ;;
        greeter-fallback) cmd_greeter_fallback ;;
        greeter-rollback) cmd_greeter_rollback ;;
        *) die "unknown command: $cmd" ;;
    esac
done
