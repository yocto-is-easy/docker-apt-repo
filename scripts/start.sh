#!/bin/sh

# pre-fill with SSH keys
echo "Pre-loading SSH keys from /docker/keys"
mkdir -p /home/user/.ssh
rm -f /home/user/.ssh/authorized_keys
for key in /docker/keys/*.pub ; do
	echo "- adding key $key"
	cat $key >> /home/user/.ssh/authorized_keys
	printf \\\n >> /home/user/.ssh/authorized_keys
done
chown -R user /home/user/.ssh

# load crontab for root
crontab <<EOF
* * * * * /usr/local/sbin/reprepro-import >> /var/log/reprepro.log
EOF

supervisord -n
