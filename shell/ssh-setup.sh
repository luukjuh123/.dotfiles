ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub

mkdir -p ~/.ssh
echo public_key_string >> ~/.ssh/authorized_keys

chmod -R go= ~/.ssh
whoami
chown -R sammy:sammy ~/.ssh

sudo -T ssh git@github.com