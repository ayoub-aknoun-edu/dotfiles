#!/usr/bin/env bash
# One-shot setup of this rice on a fresh Arch install (re-runnable).
#
#   git clone https://github.com/ayoub-aknoun-edu/dotfiles.git ~/dotfiles
#   ~/dotfiles/install.sh [options]
#
# Options:
#   --profiles a,b,...  optional profiles to install (dev,docker,vm,flutter,apps)
#   --all               install every optional profile
#   --yes, -y           no prompts (unselected profiles are skipped)
#   --dry-run           print every action, change nothing
#   -h, --help          this help
#
# Always installed: core + the GPU profile detected from lspci (hw-intel,
# hw-amd, hw-nvidia) + intel-ucode/amd-ucode for the CPU. Without --profiles
# or --all you are asked about each optional profile.
set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd -P)"
OPTIONAL_PROFILES=(dev docker vm flutter apps)

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m  %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m  %s\n' "$*"; }
die()  { printf '\033[1;31m✗\033[0m  %s\n' "$*" >&2; exit 1; }

DRY_RUN=0
YES=0
ALL=0
REQUESTED=""
while (( $# )); do
    case "$1" in
        --profiles)   REQUESTED="${2:?--profiles needs a list}"; shift ;;
        --profiles=*) REQUESTED="${1#*=}" ;;
        --all)        ALL=1 ;;
        --yes|-y)     YES=1 ;;
        --dry-run)    DRY_RUN=1 ;;
        -h|--help)    sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)            die "unknown option: $1 (see --help)" ;;
    esac
    shift
done

# run <cmd...>: execute, or just print it under --dry-run.
run() {
    if (( DRY_RUN )); then
        printf '[dry-run] %s\n' "$*"
    else
        "$@"
    fi
}

ask() {  # ask <question>: y/N prompt; --yes answers no (use --all/--profiles)
    (( YES )) && return 1
    local ans
    read -rp "$1 [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

# ── 1. Sanity ─────────────────────────────────────────────────────────────────
[[ -f /etc/arch-release ]] || die "this installer targets Arch Linux"
[[ $EUID -ne 0 ]] || die "run as your normal user (sudo is used where needed)"
# Noctalia's tracked settings.toml stores absolute /home/ayoub paths, and
# auto-sync shares it between machines: every machine must use that home.
[[ "$HOME" == /home/ayoub ]] \
    || die "use the same username on every machine (expected HOME=/home/ayoub, got $HOME)"
command -v sudo >/dev/null || die "install sudo and add yourself to wheel first"
(( DRY_RUN )) && warn "dry run: nothing will be changed"

# ── 2. Profiles ───────────────────────────────────────────────────────────────
PROFILES=(core)

gpu="$(lspci 2>/dev/null | grep -Ei 'vga|3d|display' || true)"
# Match vendor names only ("compatible" contains "ati").
grep -qw Intel <<<"$gpu" && PROFILES+=(hw-intel)
grep -qwE 'AMD|ATI|Radeon' <<<"$gpu" && PROFILES+=(hw-amd)
grep -qwi nvidia <<<"$gpu" && PROFILES+=(hw-nvidia)

CHOSEN=()
if (( ALL )); then
    CHOSEN=("${OPTIONAL_PROFILES[@]}")
elif [[ -n "$REQUESTED" ]]; then
    IFS=',' read -ra CHOSEN <<<"$REQUESTED"
    for p in "${CHOSEN[@]}"; do
        [[ " ${OPTIONAL_PROFILES[*]} core " == *" $p "* ]] || die "unknown profile: $p"
    done
else
    for p in "${OPTIONAL_PROFILES[@]}"; do
        ask "Install profile '$p'? ($(grep -m1 '^#' "$REPO/packages/$p.txt" | sed 's/^# *//'))" && CHOSEN+=("$p")
    done
fi
for p in "${CHOSEN[@]}"; do
    [[ " ${PROFILES[*]} " == *" $p "* ]] || PROFILES+=("$p")
done
has_profile() { [[ " ${PROFILES[*]} " == *" $1 "* ]]; }
info "Profiles: ${PROFILES[*]}"

# ── 3. Packages ───────────────────────────────────────────────────────────────
PKG_FLAGS=()
(( DRY_RUN )) && PKG_FLAGS+=(--dry-run)
(( YES )) && PKG_FLAGS+=(--yes)
SYU=(sudo pacman -Syu)
(( YES )) && SYU+=(--noconfirm)
run "${SYU[@]}"
bash "$REPO/scripts/install-packages.sh" "${PKG_FLAGS[@]}" "${PROFILES[@]}"

case "$(grep -m1 vendor_id /proc/cpuinfo 2>/dev/null)" in
    *GenuineIntel*) run sudo pacman -S --needed --noconfirm intel-ucode ;;
    *AuthenticAMD*) run sudo pacman -S --needed --noconfirm amd-ucode ;;
esac

# ── 4. Dotfiles (stow) + user setup (post-install.sh) ────────────────────────
run bash "$REPO/stow.sh"

# ── 5. System files + services ───────────────────────────────────────────────
SYSTEM_CMDS=(services network logind bluetooth charge-limit greeter)
has_profile docker && SYSTEM_CMDS+=(docker)
has_profile vm && SYSTEM_CMDS+=(vm)
run sudo "$REPO/scripts/setup-system.sh" "${SYSTEM_CMDS[@]}"
if has_profile flutter && getent group flutter >/dev/null; then
    run sudo usermod -aG flutter "$USER"
fi

# ── 6. Login shell ────────────────────────────────────────────────────────────
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/zsh ]]; then
    run chsh -s /usr/bin/zsh
else
    ok "login shell is already zsh"
fi

# ── 7. tmux plugins (resurrect + continuum, see tmux.conf) ───────────────────
TMUX_PLUGINS="$HOME/.local/share/tmux/plugins"
for plugin in tmux-resurrect tmux-continuum; do
    if [[ -d "$TMUX_PLUGINS/$plugin/.git" ]]; then
        run git -C "$TMUX_PLUGINS/$plugin" pull --ff-only -q
    else
        run git clone --depth=1 "https://github.com/tmux-plugins/$plugin" "$TMUX_PLUGINS/$plugin"
    fi
done

# ── 8. XDG dirs + dotfiles git hooks ─────────────────────────────────────────
run xdg-user-dirs-update
[[ -d "$REPO/.githooks" ]] && run git -C "$REPO" config core.hooksPath .githooks

# ── 9. Noctalia plugins (need a running Noctalia) ────────────────────────────
mapfile -t NOCTALIA_PLUGINS < <(
    sed -n '/^\[plugins\]/,/^\[/{s/^enabled *= *\[\(.*\)\].*/\1/p}' "$REPO/.config/noctalia/config.toml" \
        | tr ',' '\n' | tr -d ' "' | grep .
)
PLUGIN_CMD="noctalia msg plugins enable ${NOCTALIA_PLUGINS[*]}"
if (( ${#NOCTALIA_PLUGINS[@]} )); then
    if pgrep -x noctalia >/dev/null 2>&1; then
        run $PLUGIN_CMD
    else
        warn "Noctalia isn't running; after your first login run: $PLUGIN_CMD"
    fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo
ok "Done. Profiles: ${PROFILES[*]}"
info "Reboot, then log in with Noctalia Greeter (Hyprland via UWSM)."
info "After the first login:"
echo "     • $PLUGIN_CMD"
echo "     • Noctalia: Settings → Security → Noctalia Greeter → Sync Now"
echo "     • p10k configure (only if the prompt wizard appears), :Copilot auth in nvim"
echo "     • gh auth login (dotfiles auto-sync pushes over the gh credential helper)"
