cd ~ 
if [ ! -d "~/.config" ]; then
    echo "Directory /path/to/dir DOES NOT exists."
    mkdir -p ~/.config
ln -sf ~/.dotfiles/nvim/ ~/.config/nvim
yes | cp -rf ~/.dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
yes | cp -rf ~/.dotfiles/zsh/.zshrc ~/.zshrc

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k || (cd ~/powerlevel10k ; git pull)

git clone --depth=1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

