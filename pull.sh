#!/bin/bash

set -e

DEBIAN_NONINTERACTIVE=true

export PATH="$HOME/.local/bin:$PATH"


log() {
	echo '>>> ' $@
}


if [[ "$(whoami)" != "root" ]]; then
	echo Run as root >&2
	exit 1
fi


log Get vault password
if [ -n "$VAULT_PASSWORD" ]; then
	log Using password from environmental variable
	echo "$VAULT_PASSWORD" > vault-password.secret
fi
if ! [ -f vault-password.secret ]; then
	log Get password from user
	read -p "vault password> " -t 600 vault_password || log "Timed out waiting for password"
	if [[ -n "$vault_password" ]]; then
		log Using password from user
		echo -n $vault_password > vault-password.secret
	fi
fi

log Update system packages
apt update -y
log Install setup dependencies
apt install --no-install-recommends --no-install-suggests -q -y python3-pip python3-venv git

log Install ansible
python3 -m venv /tmp/ansible-venv
source /tmp/ansible-venv/bin/activate
pip3 install ansible


if [ -f vault-password.secret ]; then
	log Download collections requirements.yml
	rm -rf requirements.yml
	wget "https://git.example.com/username/ansible-proxmox-server/raw/branch/main/collections/requirements.yml"
	log Install required collections
	ansible-galaxy collection install -r requirements.yml
	log Run ansible-pull
	ansible-pull \
		-U https://git.example.com/username/ansible-proxmox-server.git \
		--vault-password-file vault-password.secret \
		$@
fi

log Shred vault password
test -f vault-password.secret && shred -ux vault-password.secret

log Purge ansible
rm -rf /tmp/ansible-venv
rm -rf /home/*/.ansible

log Purge git
apt purge -y --auto-remove git
