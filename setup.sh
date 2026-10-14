#!/usr/bin/env bash
# Top-level entry point.
#
#   bash ~/.dotfiles/setup.sh           # core install
#   bash ~/.dotfiles/setup.sh k8s       # core + kubernetes client toolchain
#   bash ~/.dotfiles/setup.sh all       # core + kubernetes client toolchain
#   bash ~/.dotfiles/setup.sh node      # core + join this VM to a k3s cluster
#                                          over Tailscale (needs TS_AUTHKEY,
#                                          K3S_URL, K3S_TOKEN — see readme.md)
#
# All sub-scripts are idempotent — safe to re-run after pulling repo updates.

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

bash "$DOTFILES/shell/install.sh"

case "${1:-core}" in
  core)
    ;;
  k8s|kubernetes|all)
    bash "$DOTFILES/shell/k8s-setup.sh"
    ;;
  node)
    bash "$DOTFILES/shell/tailscale-setup.sh"
    bash "$DOTFILES/shell/k3s-agent-setup.sh"
    ;;
  *)
    echo "Unknown target: $1" >&2
    echo "Usage: $0 [core|k8s|all|node]" >&2
    exit 2
    ;;
esac
