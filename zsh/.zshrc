# ~/.zshrc — managed via ~/.dotfiles
# Reload after edits:  source ~/.zshrc

# ---------------------------------------------------------------------------
# Powerlevel10k instant prompt — keep near the top.
# Initialization code that may require console input must go above this block.
# ---------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---------------------------------------------------------------------------
# Powerlevel10k theme
# ---------------------------------------------------------------------------
if [[ -r ~/.powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source ~/.powerlevel10k/powerlevel10k.zsh-theme
elif [[ -r ~/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source ~/powerlevel10k/powerlevel10k.zsh-theme
fi

# ---------------------------------------------------------------------------
# Machine identifier
#   The p10k prompt shows user@hostname on the right so you can always tell
#   which machine you're on. Override the displayed name per-machine with:
#       echo 'export MACHINE_LABEL=my-vm' >> ~/.zshrc.local
#   Anything in ~/.zshrc.local is sourced at the end of this file and is NOT
#   tracked in the dotfiles repo.
# ---------------------------------------------------------------------------
export MACHINE_LABEL="${MACHINE_LABEL:-$(hostname -s)}"

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# ---------------------------------------------------------------------------
# General aliases
# ---------------------------------------------------------------------------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls --human-readable --size -1 -S --classify'
alias c='clear'
alias h='history'

# Python virtual env
alias cv="virtualenv .venv"
alias av=". .venv/bin/activate"
alias dv="deactivate"
alias v="cv; av"

# pip
alias pi="pip install -r requirements.txt&&pip install -r requirements-dev.txt"

# git
alias gca='git add .&&git commit -m'
alias gpl='git pull'
alias gph='git push'
alias gcp='git checkout production'
alias gc='git checkout'
alias gsh='git stash'
alias gshp='git stash pop'
alias gmp='git merge production'
alias grmc='gcp&&gpl&&gc -&&gmp&&gph'

# ---------------------------------------------------------------------------
# Kubernetes
# ---------------------------------------------------------------------------
alias k='kubectl'
alias kd='kubectl describe pods'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgap='k get pods --all-namespaces'
alias ksc='k config set-context --current --namespace='
alias kverbs='kubectl api-resources --verbs=list'
alias krd='kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh'
alias busyshell='k exec -it busybox -- /bin/sh'
alias m8k='microk8s kubectl'
alias m8='microk8s'
alias kx='kubectx'
alias kn='kubens'

# kubectl + helm completion (loaded lazily; safe if the binaries are absent)
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  compdef __start_kubectl k
fi
if command -v helm >/dev/null 2>&1; then
  source <(helm completion zsh)
fi

# krew on PATH (kubectl plugin manager)
[[ -d "${KREW_ROOT:-$HOME/.krew}/bin" ]] && export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# terraform
alias tf='terraform'

# argo
alias ag='argo'
alias ags='argo submit'
alias agl='argo list'
alias agg='argo get'
alias agd='argo delete'

# Work directories
alias cxdir='cd ~/al/cxf/'
alias mskdir='cd ~/al/maskphotos/'
alias bsdir='cd ~/al/backstage/'

# Home directories
alias rdir='cd ~/code/rust'
alias pydir='cd ~/code/python'
alias njdir='cd ~/code/nextjs'
alias nodedir='cd ~/code/nodejs'
alias tutdir='cd ~/code/tutorials'

# Commitizen
alias cza='cz add .&&cz commit -m'
alias czc='cz commit'
alias czv='cz version -p'
alias czb='cz bump --changelog'

# Docker
alias dcu='docker compose up'
alias dcub='docker compose up --build'
alias dcd='docker compose down'

# ---------------------------------------------------------------------------
# PATH and tool init
# ---------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Rust
[ -s "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"

# ---------------------------------------------------------------------------
# p10k prompt config — edit ~/.p10k.zsh or run `p10k configure`.
# ---------------------------------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---------------------------------------------------------------------------
# Per-machine overrides (NOT tracked in the dotfiles repo).
# Put MACHINE_LABEL, secrets, machine-specific PATH entries here.
# ---------------------------------------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
