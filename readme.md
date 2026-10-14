# .dotfiles

Personal dotfiles for a portable zsh + Powerlevel10k + Kubernetes setup.
Works on Ubuntu/Debian (WSL, bare VMs, cloud VMs).

## Bootstrap a fresh machine

```bash
git clone https://github.com/luukjuh123/.dotfiles.git ~/.dotfiles

# Core: zsh, p10k, symlinks, fonts, base apt deps
bash ~/.dotfiles/setup.sh

# Or: core + Kubernetes toolchain in one go
bash ~/.dotfiles/setup.sh all
```

Then start a new shell (or `exec zsh`).

## Adding a new VM to the k3s cluster (over Tailscale)

For a VM that isn't on the same LAN as the control-plane node — e.g. a fresh
cloud box — bring it onto the tailnet and join it as a k3s agent in one go:

```bash
git clone https://github.com/luukjuh123/.dotfiles.git ~/.dotfiles

TS_AUTHKEY=tskey-auth-xxxx \
K3S_URL=https://<server-tailscale-ip>:6443 \
K3S_TOKEN=xxxx \
  bash ~/.dotfiles/setup.sh node
```

- `TS_AUTHKEY` — generate at https://login.tailscale.com/admin/settings/keys.
- `K3S_TOKEN` — from the control-plane node: `sudo cat /var/lib/rancher/k3s/server/node-token`.
- `K3S_URL` — the control-plane node's **Tailscale** IP (`tailscale ip -4` on
  that node), not its LAN IP.

Never commit either secret to this repo — pass them as env vars at bootstrap
time (shell export, cloud-init user-data, or a secrets manager). The same
three vars work unattended in cloud-init `user-data`, e.g.:

```yaml
runcmd:
  - git clone https://github.com/luukjuh123/.dotfiles.git /home/ubuntu/.dotfiles
  - su - ubuntu -c "TS_AUTHKEY=... K3S_URL=... K3S_TOKEN=... bash /home/ubuntu/.dotfiles/setup.sh node"
```

### One-time prerequisite on the existing control-plane node

k3s's server cert only covers the SANs it was started with. If the server
was bootstrapped with a LAN-only `--node-ip`/`--advertise-address` (check
`ExecStart` in `/etc/systemd/system/k3s.service`), a remote agent connecting
over Tailscale needs the server's Tailscale IP added as an extra SAN:

```bash
sudo sed -i "/ExecStart=/,/^$/ s/$/ '--tls-san=$(tailscale ip -4)'/" /etc/systemd/system/k3s.service  # review before running
sudo systemctl daemon-reload
sudo systemctl restart k3s
```

This restarts the control plane — do it deliberately, not as part of an
unattended script, and confirm `kubectl get nodes` still shows the existing
node Ready afterward. Also make sure the agent can reach the server's pod
network: either advertise the server's LAN subnet via `tailscale up
--advertise-routes=192.168.50.0/24` and accept it on the agent
(`--accept-routes`), or keep `--flannel-iface=tailscale0` on **every** node
(agents already default to this; the server would need the same flag added
and restarted) so all inter-pod traffic rides the tailnet.

## What's in here

| Path | What |
|------|------|
| `zsh/.zshrc`        | The zshrc that gets symlinked to `~/.zshrc` |
| `zsh/.p10k.zsh`     | Powerlevel10k config (Pure style, hostname always visible) |
| `shell/install.sh`  | Core bootstrap — idempotent, safe to re-run |
| `shell/k8s-setup.sh`| kubectl + helm + kubectx + kubens + k9s + krew (client toolchain) |
| `shell/tailscale-setup.sh` | Install Tailscale and join the tailnet (`TS_AUTHKEY`) |
| `shell/k3s-agent-setup.sh` | Join this VM to an existing k3s cluster as an agent (`K3S_URL`, `K3S_TOKEN`) |
| `nvim/`             | Neovim config (symlinked to `~/.config/nvim`) |
| `fonts/`            | JetBrains Mono zip |
| `vscode/`           | VSCode settings and extension list |

## Knowing which machine you're on

The prompt always shows `user@host` on the right side. To use a friendly
label instead of the system hostname (e.g. `prod-bastion` instead of
`ip-10-0-1-42`), set `MACHINE_LABEL` in `~/.zshrc.local`:

```bash
echo 'export MACHINE_LABEL=prod-bastion' >> ~/.zshrc.local
exec zsh
```

`~/.zshrc.local` is sourced at the end of `~/.zshrc` and is **not** tracked
in this repo — it's the right place for per-machine secrets and overrides.
`install.sh` seeds it with `MACHINE_LABEL=$(hostname -s)` on first run.

## Re-syncing after updates

```bash
cd ~/.dotfiles && git pull
make link         # refresh symlinks only
# or
make install      # re-run the full core install (idempotent)
```

## CLI tools assumed present

zsh · p10k · git · curl · jq · ripgrep · fzf · neovim · unzip

## VSCode

Font: **JetBrains Mono**. Settings live in `vscode/settings.json`. Extension
install list is in `shell/extension-setup.sh` (run only if `code` is on PATH).
