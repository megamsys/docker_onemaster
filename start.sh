#!/bin/bash

su - oneadmin -c "one start"
	su - oneadmin -c "sunstone-server start"
	su - oneadmin -c "oneflow-server start"
	cat /var/lib/one/.one/one_auth
	mkdir -p /var/run/sshd
	sed -i "s/^Port 22$/Port 2222/" /etc/ssh/sshd_config
	sed -i "s/UsePAM yes/UsePAM no/" /etc/ssh/sshd_config
	dpkg-reconfigure openssh-server
	/usr/sbin/sshd -E /var/log/sshd.log
	if [ ! -e /READY ]; then
		su - oneadmin -c "mkdir -p .ssh"
                su - oneadmin -c "ssh-keygen -q -f .ssh/id_ed25519 -N \"\" -t ed25519 -C \"\$USER@\$HOSTNAME\""
		su - oneadmin -c "touch /var/lib/one/.ssh/config"
		cat >> /var/lib/one/.ssh/config<<EOF
Host *
port 2222
user oneadmin
StrictHostKeyChecking no
EOF
		cat /var/lib/one/.ssh/id_ed25519.pub
		cat /var/lib/one/.ssh/id_ed25519.pub > /var/lib/one/.ssh/authorized_keys2
		chown oneadmin. /var/lib/one/.ssh/authorized_keys2
		touch /READY
	fi
echo "$ssh_public" > /var/lib/one/.ssh/test1
rm -rf /var/lib/one/.ssh/id_rsa*
echo "$ssh_private" > /var/lib/one/.ssh/id_rsa
echo "$ssh_public" > /var/lib/one/.ssh/id_rsa.pub

mkdir -p /var/lib/megam
cd  /var/lib/megam
git clone https://github.com/megamsys/abcdsh.git

  tail -f /var/log/one/*.{log,error} /var/log/sshd.log
