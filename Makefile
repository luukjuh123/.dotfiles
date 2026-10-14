.PHONY: help install k8s node all link clean

help:
	@echo 'Dotfiles install targets:'
	@echo '  make install   - core: zsh, p10k, symlinks, fonts, apt deps'
	@echo '  make k8s       - kubernetes client toolchain (kubectl, helm, kubectx, k9s, krew)'
	@echo '  make node      - tailscale + join this VM to a k3s cluster as an agent'
	@echo '                   (needs TS_AUTHKEY, K3S_URL, K3S_TOKEN env vars — see readme.md)'
	@echo '  make all       - install + k8s'
	@echo '  make link      - only refresh dotfile symlinks (no apt)'

install:
	bash ./shell/install.sh

k8s:
	bash ./shell/k8s-setup.sh

node:
	bash ./shell/tailscale-setup.sh
	bash ./shell/k3s-agent-setup.sh

all: install k8s

link:
	@ln -sfn $(CURDIR)/zsh/.zshrc    $$HOME/.zshrc
	@ln -sfn $(CURDIR)/zsh/.p10k.zsh $$HOME/.p10k.zsh
	@mkdir -p $$HOME/.config
	@ln -sfn $(CURDIR)/nvim          $$HOME/.config/nvim
	@echo 'Symlinks refreshed.'
