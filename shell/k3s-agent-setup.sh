#!/usr/bin/env bash
# Join this VM to an existing k3s cluster as an agent (worker) node, over Tailscale.
#
#   K3S_URL=https://100.73.58.37:6443 K3S_TOKEN=xxxx \
#     bash ~/.dotfiles/shell/k3s-agent-setup.sh
#
# Required env vars:
#   K3S_URL    - https://<server-tailscale-ip>:6443
#                (the server must have this IP in its --tls-san list — see readme.md)
#   K3S_TOKEN  - join token from the server:
#                sudo cat /var/lib/rancher/k3s/server/node-token
#
# Optional env vars:
#   NODE_IP        - override the node IP k3s advertises (default: this host's
#                    tailscale IPv4, via `tailscale ip -4`)
#   FLANNEL_IFACE  - interface flannel binds to (default: tailscale0, so pod
#                    traffic is tunneled over the tailnet)
#
# Idempotent. Never put K3S_TOKEN in this repo — pass it as an env var at
# bootstrap time (shell export, cloud-init user-data, or a secrets manager).

set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mXX\033[0m %s\n' "$*" >&2; exit 1; }

[[ -n "${K3S_URL:-}" ]]   || die "K3S_URL is required, e.g. https://100.73.58.37:6443"
[[ -n "${K3S_TOKEN:-}" ]] || die "K3S_TOKEN is required (sudo cat /var/lib/rancher/k3s/server/node-token on the server)"

command -v tailscale >/dev/null 2>&1 || die "tailscale is not installed — run shell/tailscale-setup.sh first"
tailscale status >/dev/null 2>&1 || die "tailscale is not up — run shell/tailscale-setup.sh first"

NODE_IP="${NODE_IP:-$(tailscale ip -4)}"
FLANNEL_IFACE="${FLANNEL_IFACE:-tailscale0}"

main() {
  if systemctl is-active --quiet k3s-agent 2>/dev/null; then
    log "k3s-agent already running on this node (IP $NODE_IP)"
    return
  fi

  log "Joining $K3S_URL as an agent, node-ip=$NODE_IP, flannel-iface=$FLANNEL_IFACE"
  curl -sfL https://get.k3s.io | \
    K3S_URL="$K3S_URL" \
    K3S_TOKEN="$K3S_TOKEN" \
    INSTALL_K3S_EXEC="agent --node-ip=${NODE_IP} --flannel-iface=${FLANNEL_IFACE}" \
    sh -

  cat <<EOF

  ╭─────────────────────────────────────────────────────────────────╮
  │  k3s-agent installed and joining the cluster.                    │
  │  Verify from the control-plane node with: kubectl get nodes      │
  ╰─────────────────────────────────────────────────────────────────╯
EOF
}

main "$@"
