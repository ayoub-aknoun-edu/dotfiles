#!/usr/bin/env bash
# System-level (/etc, /var) parts of the rice that stow can't link.
# Run with sudo from the repo:
#
#   sudo scripts/setup-system.sh services          enable NetworkManager, iwd, bluetooth, fstrim + paccache timers
#   sudo scripts/setup-system.sh network           NetworkManager on iwd + systemd-resolved (stub resolv.conf)
#   sudo scripts/setup-system.sh logind            lid close suspends; lock every session before sleep
#   sudo scripts/setup-system.sh bluetooth         don't power Bluetooth on at every boot
#   sudo scripts/setup-system.sh charge-limit      battery care: charge 75→80 % (skipped if unsupported)
#   sudo scripts/setup-system.sh battery-cleanup   remove the old battery-threshold plugin's udev rule + group
#   sudo scripts/setup-system.sh greeter           login screen: greetd + Noctalia Greeter
#   sudo scripts/setup-system.sh greeter-config    reinstall only greeter.toml (login screen look)
#   sudo scripts/setup-system.sh greeter-fallback  greetd with the plain tuigreet (if the greeter breaks)
#   sudo scripts/setup-system.sh docker            enable Docker + add you to the docker group
#   sudo scripts/setup-system.sh vm                enable libvirtd + libvirt group + IPv4 forwarding
#
# Idempotent; every replaced file is backed up as <file>.bak-<date>.
# Display-manager changes apply on the next boot (never --now: that would kill
# the running session). Recovery from a broken login: Ctrl+Alt+F2, log in,
# run `sudo ~/dotfiles/scripts/setup-system.sh greeter-fallback`, reboot.

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

# The charge cap now comes from Noctalia's Control Center (UPower); undo
# what the battery-threshold plugin setup installed.
cmd_battery_cleanup() {
    rm -f /etc/udev/rules.d/99-battery-threshold.rules
    udevadm control --reload-rules
    if getent group battery_ctl >/dev/null; then
        groupdel battery_ctl
        ok "removed group battery_ctl"
    fi
    ok "battery-threshold udev rule removed"
}

cmd_charge_limit() {
    local bat="" b
    for b in /sys/class/power_supply/BAT*; do
        [[ -w "$b/charge_control_end_threshold" ]] && { bat="$b"; break; }
    done
    if [[ -z "$bat" ]]; then
        info "charge-limit: no battery with charge_control_*_threshold here — skipped"
        return 0
    fi
    install_file "$SYS/udev/90-charge-limit.rules" /etc/udev/rules.d/90-charge-limit.rules
    udevadm control --reload-rules
    udevadm trigger --action=change --subsystem-match=power_supply
    sleep 1
    systemctl restart upower.service
    sleep 1
    ok "$(basename "$bat") now: start=$(cat "$bat/charge_control_start_threshold" 2>/dev/null || echo ?)% end=$(cat "$bat/charge_control_end_threshold")%"
}

# enable_units <unit...>: enable for next boot (never --now: safe from a live session).
enable_units() {
    local u
    for u in "$@"; do
        if systemctl list-unit-files "$u" >/dev/null 2>&1; then
            systemctl enable "$u" >/dev/null 2>&1 && ok "enabled $u" || info "could not enable $u"
        else
            info "$u not installed — skipped"
        fi
    done
}

cmd_services() {
    enable_units NetworkManager.service iwd.service bluetooth.service \
                 systemd-timesyncd.service fstrim.timer paccache.timer
    # iwd is NetworkManager's Wi-Fi backend (see `network`); wpa_supplicant must not compete.
    systemctl disable wpa_supplicant.service >/dev/null 2>&1 || true
}

cmd_network() {
    require_pkgs networkmanager iwd
    local f
    for f in "$SYS"/networkmanager/*.conf; do
        install_file "$f" "/etc/NetworkManager/conf.d/$(basename "$f")"
    done
    systemctl enable --now systemd-resolved.service
    if [[ "$(readlink /etc/resolv.conf)" != /run/systemd/resolve/stub-resolv.conf ]]; then
        [[ -e /etc/resolv.conf && ! -L /etc/resolv.conf ]] && cp -a /etc/resolv.conf "/etc/resolv.conf.bak-$STAMP"
        ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
        ok "/etc/resolv.conf → systemd-resolved stub"
    else
        ok "/etc/resolv.conf already uses systemd-resolved"
    fi
    info "NetworkManager picks up the iwd backend after a reboot."
}

cmd_logind() {
    install_file "$SYS/logind/lid.conf" /etc/systemd/logind.conf.d/lid.conf
    install_file "$SYS/system-sleep/lock-before-sleep.sh" /etc/systemd/system-sleep/lock-before-sleep.sh 755
    systemctl kill -s HUP systemd-logind
    ok "logind reloaded"
}

cmd_docker() {
    require_pkgs docker
    enable_units docker.service
    usermod -aG docker "$TARGET_USER"
    ok "$TARGET_USER added to docker (log out/in to apply)"
}

cmd_vm() {
    require_pkgs libvirt qemu-desktop
    install_file "$SYS/sysctl/30-ipforward.conf" /etc/sysctl.d/30-ipforward.conf
    sysctl -q --system
    enable_units libvirtd.service
    usermod -aG libvirt "$TARGET_USER"
    ok "$TARGET_USER added to libvirt (log out/in to apply)"
}

# BlueZ powers every adapter on when it appears (AutoEnable defaults to true).
# Off at boot; turn it on from the bar when needed.
cmd_bluetooth() {
    local conf=/etc/bluetooth/main.conf
    [[ -f "$conf" ]] || die "$conf missing (is bluez installed?)"
    if grep -qE '^AutoEnable=false' "$conf"; then
        ok "Bluetooth AutoEnable already off"
        return
    fi
    cp -a "$conf" "$conf.bak-$STAMP"
    if grep -qE '^#?AutoEnable=' "$conf"; then
        sed -i -E 's/^#?AutoEnable=.*/AutoEnable=false/' "$conf"
    else
        sed -i '/^\[Policy\]/a AutoEnable=false' "$conf"
    fi
    grep -qE '^AutoEnable=false' "$conf" || die "could not set AutoEnable=false"
    ok "Bluetooth no longer powers on at boot (applies after restart of bluetooth.service)"
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
    local dm
    for dm in sddm gdm lightdm ly; do
        systemctl disable "$dm.service" >/dev/null 2>&1 || true
    done
    systemctl enable greetd.service
    ok "greetd enabled for next boot"
}

cmd_greeter_config() {
    local tmp
    tmp="$(mktemp)"
    sed "s/@USER@/$TARGET_USER/" "$SYS/noctalia-greeter/greeter.toml" > "$tmp"
    install_file "$tmp" /var/lib/noctalia-greeter/greeter.toml
    rm -f "$tmp"
}

cmd_greeter() {
    require_pkgs greetd noctalia-greeter greetd-tuigreet accountsservice
    [[ -x /usr/bin/noctalia-greeter-session ]] || die "/usr/bin/noctalia-greeter-session not found"

    install_file "$SYS/greetd/config.toml" /etc/greetd/config.toml
    ensure_keyring_pam

    cmd_greeter_config

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

[[ $# -gt 0 ]] || { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
for cmd in "$@"; do
    case "$cmd" in
        services)         cmd_services ;;
        network)          cmd_network ;;
        logind)           cmd_logind ;;
        docker)           cmd_docker ;;
        vm)               cmd_vm ;;
        bluetooth)        cmd_bluetooth ;;
        charge-limit)     cmd_charge_limit ;;
        battery-cleanup)  cmd_battery_cleanup ;;
        greeter)          cmd_greeter ;;
        greeter-config)   cmd_greeter_config ;;
        greeter-fallback) cmd_greeter_fallback ;;
        *) die "unknown command: $cmd" ;;
    esac
done
