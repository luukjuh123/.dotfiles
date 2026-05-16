#!/usr/bin/env bash
# Install the Kubernetes toolchain: kubectl, helm, kubectx/kubens, k9s, krew.
#
#   bash ~/.dotfiles/shell/k8s-setup.sh
#
# Idempotent. Uses the modern pkgs.k8s.io apt repo (the old
# apt.kubernetes.io/kubernetes-xenial repo was retired in 2023).

set -euo pipefail

KUBE_VERSION="${KUBE_VERSION:-v1.30}"
KREW_ROOT="${KREW_ROOT:-$HOME/.krew}"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

require_sudo() {
  if ! sudo -n true 2>/dev/null; then sudo -v; fi
}

# ---------------------------------------------------------------------------
# kubectl — official pkgs.k8s.io repo
# ---------------------------------------------------------------------------
install_kubectl() {
  if command -v kubectl >/dev/null 2>&1; then
    log "kubectl already installed: $(kubectl version --client --output=yaml 2>/dev/null | grep gitVersion | head -1)"
    return
  fi
  log "Installing kubectl ($KUBE_VERSION channel)"
  require_sudo
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION}/deb/Release.key" \
    | sudo gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION}/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
  sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update -y
  sudo apt-get install -y kubectl
}

# ---------------------------------------------------------------------------
# helm — official Helm apt repo
# ---------------------------------------------------------------------------
install_helm() {
  if command -v helm >/dev/null 2>&1; then
    log "helm already installed: $(helm version --short 2>/dev/null)"
    return
  fi
  log "Installing helm"
  require_sudo
  curl -fsSL https://baltocdn.com/helm/signing.asc \
    | sudo gpg --dearmor --yes -o /usr/share/keyrings/helm.gpg
  sudo chmod 644 /usr/share/keyrings/helm.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" \
    | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y helm
}

# ---------------------------------------------------------------------------
# kubectx + kubens — pull binaries straight from GitHub releases
# (the apt package lags badly; the git clone trick the old script used
#  needs ~/.dotfiles to update by hand).
# ---------------------------------------------------------------------------
install_kubectx() {
  local bin_dir=/usr/local/bin
  if command -v kubectx >/dev/null 2>&1 && command -v kubens >/dev/null 2>&1; then
    log "kubectx/kubens already installed"
    return
  fi
  log "Installing kubectx + kubens"
  require_sudo
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  local arch
  case "$(uname -m)" in
    x86_64) arch=x86_64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) warn "Unknown arch $(uname -m); skipping kubectx"; return ;;
  esac
  local kver=v0.9.5
  curl -fsSL -o "$tmp/kubectx.tgz" \
    "https://github.com/ahmetb/kubectx/releases/download/${kver}/kubectx_${kver}_linux_${arch}.tar.gz"
  curl -fsSL -o "$tmp/kubens.tgz" \
    "https://github.com/ahmetb/kubectx/releases/download/${kver}/kubens_${kver}_linux_${arch}.tar.gz"
  tar -xzf "$tmp/kubectx.tgz" -C "$tmp" kubectx
  tar -xzf "$tmp/kubens.tgz"  -C "$tmp" kubens
  sudo install -m 0755 "$tmp/kubectx" "$bin_dir/kubectx"
  sudo install -m 0755 "$tmp/kubens"  "$bin_dir/kubens"
}

# ---------------------------------------------------------------------------
# k9s — TUI for kubernetes
# ---------------------------------------------------------------------------
install_k9s() {
  if command -v k9s >/dev/null 2>&1; then
    log "k9s already installed: $(k9s version -s 2>/dev/null | head -1)"
    return
  fi
  log "Installing k9s"
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  local arch
  case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) warn "Unknown arch $(uname -m); skipping k9s"; return ;;
  esac
  local kver=v0.32.5
  curl -fsSL -o "$tmp/k9s.tgz" \
    "https://github.com/derailed/k9s/releases/download/${kver}/k9s_Linux_${arch}.tar.gz"
  tar -xzf "$tmp/k9s.tgz" -C "$tmp" k9s
  require_sudo
  sudo install -m 0755 "$tmp/k9s" /usr/local/bin/k9s
}

# ---------------------------------------------------------------------------
# krew — kubectl plugin manager
# ---------------------------------------------------------------------------
install_krew() {
  if [[ -x "$KREW_ROOT/bin/kubectl-krew" ]]; then
    log "krew already installed at $KREW_ROOT"
    return
  fi
  log "Installing krew"
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  local arch
  case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) warn "Unknown arch $(uname -m); skipping krew"; return ;;
  esac
  (
    cd "$tmp"
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_${arch}.tar.gz"
    tar zxvf "krew-linux_${arch}.tar.gz" >/dev/null
    "./krew-linux_${arch}" install krew
  )
}

main() {
  install_kubectl
  install_helm
  install_kubectx
  install_k9s
  install_krew

  cat <<EOF

  ╭─────────────────────────────────────────────────────────────────╮
  │  Kubernetes toolchain installed.                                 │
  │                                                                  │
  │  In a new shell you'll have:                                     │
  │    k / kubectl / helm / kubectx / kubens / k9s / kubectl-krew    │
  │                                                                  │
  │  Drop kubeconfigs in ~/.kube/   (use \`kubectx\` to switch).       │
  ╰─────────────────────────────────────────────────────────────────╯
EOF
}

main "$@"
