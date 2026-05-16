.PHONY: help install k8s all link clean

help:
	@echo 'Dotfiles install targets:'
	@echo '  make install   - core: zsh, p10k, symlinks, fonts, apt deps'
	@echo '  make k8s       - kubernetes toolchain (kubectl, helm, kubectx, k9s, krew)'
	@echo '  make all       - install + k8s'
	@echo '  make link      - only refresh dotfile symlinks (no apt)'

install:
	bash ./shell/install.sh

k8s:
	bash ./shell/k8s-setup.sh

all: install k8s

link:
	@ln -sfn $(CURDIR)/zsh/.zshrc    $$HOME/.zshrc
	@ln -sfn $(CURDIR)/zsh/.p10k.zsh $$HOME/.p10k.zsh
	@mkdir -p $$HOME/.config
	@ln -sfn $(CURDIR)/nvim          $$HOME/.config/nvim
	@echo 'Symlinks refreshed.'
