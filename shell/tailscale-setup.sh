#!/usr/bin/env bash
# Install Tailscale and bring this machine onto the tailnet.
#
#   TS_AUTHKEY=tskey-auth-xxxx bash ~/.dotfiles/shell/tailscale-setup.sh
#
# Optional env vars:
#   TS_AUTHKEY     - auth key from https://login.tailscale.com/admin/settings/keys
#                    (required to auto-join; omit to install only and run
#                    `tailscale up` interactively yourself)
#   TS_HOSTNAME    - hostname to advertise on the tailnet (default: system hostname)
#   TS_EXTRA_ARGS  - extra flags appended to `tailscale up`, e.g.
#                    "--advertise-tags=tag:k8s --accept-routes"
#
# Idempotent. Never put TS_AUTHKEY in this repo — pass it as an env var at
# bootstrap time (shell export, cloud-init user-data, or a secrets manager).

set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

require_sudo() {
  if ! sudo -n true 2>/dev/null; then sudo -v; fi
}

install_tailscale() {
  if command -v tailscale >/dev/null 2>&1; then
    log "tailscale already installed: $(tailscale version | head -1)"
    return
  fi
  log "Installing tailscale"
  require_sudo
  curl -fsSL https://tailscale.com/install.sh | sh
}

bring_up() {
  if tailscale status >/dev/null 2>&1 && [[ "$(tailscale status --json | grep -o '"BackendState":"[A-Za-z]*"')" == '"BackendState":"Running"' ]]; then
    log "tailscale is already up: $(tailscale ip -4 2>/dev/null)"
    return
  fi

  if [[ -z "${TS_AUTHKEY:-}" ]]; then
    warn "TS_AUTHKEY not set — skipping 'tailscale up'. Run it yourself:"
    warn "  sudo tailscale up --hostname=\$(hostname -s)"
    return
  fi

  local hostname_arg="${TS_HOSTNAME:-$(hostname -s)}"
  log "Bringing up tailscale as '$hostname_arg'"
  require_sudo
  # shellcheck disable=SC2086
  sudo tailscale up --authkey="$TS_AUTHKEY" --hostname="$hostname_arg" ${TS_EXTRA_ARGS:-}
}

main() {
  install_tailscale
  bring_up

  cat <<EOF

  ╭─────────────────────────────────────────────────────────────────╮
  │  Tailscale ready. IP: $(tailscale ip -4 2>/dev/null || echo 'not up yet')
  ╰─────────────────────────────────────────────────────────────────╯
EOF
}

main "$@"
