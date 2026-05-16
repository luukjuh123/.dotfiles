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

## What's in here

| Path | What |
|------|------|
| `zsh/.zshrc`        | The zshrc that gets symlinked to `~/.zshrc` |
| `zsh/.p10k.zsh`     | Powerlevel10k config (Pure style, hostname always visible) |
| `shell/install.sh`  | Core bootstrap — idempotent, safe to re-run |
| `shell/k8s-setup.sh`| kubectl + helm + kubectx + kubens + k9s + krew |
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
