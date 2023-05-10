sudo apt update
sudo apt upgrade

# sh ~/.dotfiles/shell/coding-setup.sh
sh ~/.dotfiles/shell/terminal-setup.sh
# check if running in ssh -> if not then install software programs
if [ ! "$(ps h -o comm -p "$PPID")" != "sshd" ] ; then
    # sh ~/.dotfiles/shell/software-setup.sh
    sh ~/.dotfiles/shell/extension-setup.sh
    exit 1
fi
