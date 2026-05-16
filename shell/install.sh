#!/usr/bin/env bash
# Bootstrap a fresh VM with the dotfiles core setup.
#
#   bash ~/.dotfiles/shell/install.sh
#
# Idempotent: safe to re-run. Each step skips if its target is already
# present. After this finishes, run shell/k8s-setup.sh for kubectl/helm/etc.

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
P10K_DIR="$HOME/.powerlevel10k"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

require_sudo() {
  if ! sudo -n true 2>/dev/null; then
    log "Caching sudo credentials..."
    sudo -v
  fi
}

# ---------------------------------------------------------------------------
# apt update + core packages
# ---------------------------------------------------------------------------
install_core_packages() {
  log "Installing core apt packages"
  require_sudo
  sudo apt-get update -y
  sudo apt-get install -y \
    zsh git curl wget gpg ca-certificates \
    jq unzip tar \
    ripgrep fzf \
    neovim \
    build-essential \
    apt-transport-https lsb-release
}

# ---------------------------------------------------------------------------
# zsh as default shell
# ---------------------------------------------------------------------------
set_zsh_default() {
  if [[ "$SHELL" == *"/zsh" ]]; then
    log "zsh is already the default shell"
    return
  fi
  log "Changing default shell to zsh for $USER"
  local zsh_bin
  zsh_bin="$(command -v zsh)"
  if ! grep -qx "$zsh_bin" /etc/shells; then
    echo "$zsh_bin" | sudo tee -a /etc/shells >/dev/null
  fi
  sudo chsh -s "$zsh_bin" "$USER"
}

# ---------------------------------------------------------------------------
# powerlevel10k
# ---------------------------------------------------------------------------
install_p10k() {
  if [[ -d "$P10K_DIR/.git" ]]; then
    log "Updating powerlevel10k at $P10K_DIR"
    git -C "$P10K_DIR" pull --ff-only
  else
    log "Cloning powerlevel10k to $P10K_DIR"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  fi
}

# ---------------------------------------------------------------------------
# symlink dotfiles into $HOME
# ---------------------------------------------------------------------------
link_dotfile() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    [[ "$current" == "$src" ]] && return
  fi
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local backup="${dst}.backup.$(date +%Y%m%d-%H%M%S)"
    warn "Backing up existing $dst -> $backup"
    mv "$dst" "$backup"
  fi
  ln -sfn "$src" "$dst"
  log "Linked $dst -> $src"
}

link_dotfiles() {
  log "Linking dotfiles from $DOTFILES"
  link_dotfile "$DOTFILES/zsh/.zshrc"  "$HOME/.zshrc"
  link_dotfile "$DOTFILES/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
  mkdir -p "$HOME/.config"
  link_dotfile "$DOTFILES/nvim" "$HOME/.config/nvim"
}

# ---------------------------------------------------------------------------
# JetBrains Mono font
# ---------------------------------------------------------------------------
install_fonts() {
  local font_zip="$DOTFILES/fonts/JetBrainsMono-2.242.zip"
  local font_dir="/usr/share/fonts/JetBrainsMono"
  if [[ -d "$font_dir" ]]; then
    log "JetBrains Mono already installed"
    return
  fi
  if [[ ! -f "$font_zip" ]]; then
    warn "Font zip not found at $font_zip — skipping font install"
    return
  fi
  log "Installing JetBrains Mono"
  require_sudo
  sudo mkdir -p "$font_dir"
  sudo unzip -o "$font_zip" -d "$font_dir" >/dev/null
  sudo fc-cache -f >/dev/null 2>&1 || true
}

# ---------------------------------------------------------------------------
# scaffold a per-machine override file (not tracked in the repo)
# ---------------------------------------------------------------------------
seed_machine_label() {
  local local_rc="$HOME/.zshrc.local"
  if [[ -f "$local_rc" ]]; then
    log "$local_rc already exists — leaving it untouched"
    return
  fi
  log "Seeding $local_rc with a default MACHINE_LABEL (edit to rename)"
  cat > "$local_rc" <<EOF
# Per-machine zsh overrides. NOT tracked in the dotfiles repo.
# This file is sourced at the end of ~/.zshrc.

# Friendly name shown in the prompt — change per machine.
export MACHINE_LABEL="$(hostname -s)"
EOF
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
  if [[ ! -d "$DOTFILES" ]]; then
    warn "Dotfiles repo not found at $DOTFILES"
    exit 1
  fi

  install_core_packages
  install_p10k
  link_dotfiles
  install_fonts
  seed_machine_label
  set_zsh_default

  cat <<'EOF'

  ╭─────────────────────────────────────────────────────────────────╮
  │  Core setup done.                                                │
  │                                                                  │
  │  Next steps:                                                     │
  │    1. Start a new shell or run:  exec zsh                        │
  │    2. Install Kubernetes tools:  bash ~/.dotfiles/shell/k8s-setup.sh
  │    3. Edit ~/.zshrc.local to set MACHINE_LABEL per machine.      │
  ╰─────────────────────────────────────────────────────────────────╯
EOF
}

main "$@"
