# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="$HOME/.local/bin:$PATH"

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls --human-readable --size -1 -S --classify'
alias c='clear'
alias h='history'



# virtual env
alias cv="virtualenv venv"
alias av=". venv/bin/activate"
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



# kubectl
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


# terraform
alias tf='terraform'

# argo
alias ag='argo'
alias ags='argo submit'
alias agl='argo list'
alias agg='argo get'
alias agd='argo delete'


# work directories
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



