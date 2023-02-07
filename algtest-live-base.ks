%include /usr/share/spin-kickstarts/fedora-live-base.ks

# part /mnt/algtest --label algtest_results --size 250 --fstype vfat
# selinux --disabled

repo --install --name=tpm2-algtest --baseurl=https://copr-be.cloud.fedoraproject.org/results/dzatovic/tpm2-algtest/fedora-$releasever-$basearch/
timezone Europe/Prague

%packages

# networking TUI
NetworkManager-tui

# grub2-mkconfig
# grub2-tools

# TPM2 stuff
tpm2-abrmd
tpm2-tools
tpm2-algtest
tpm2_algtest_ui
libyui-ncurses

vim
# add MilanCommander
mc
openssl
%end

%post
sed -i -E "s/(^\%wheel.*)/\# \1/" /etc/sudoers
sed -i -E "s/^\# (\%wheel[^N]*NOPASSWD.*)/\1/" /etc/sudoers

cat >> /etc/rc.d/init.d/livesys << EOF
usermod -aG tss liveuser > /dev/null
EOF

cat >> /etc/rc.d/init.d/livesys << EOF
sed -i "s/agetty/agetty --autologin root/" /usr/lib/systemd/system/getty@.service
systemctl daemon-reload
systemctl restart getty
systemctl mask tpm2-abrmd.service

echo "Please setup networking e.g. by running the 'nmtui' command (if not set up already) and then run 'tpm2-algtest-ui'" > /etc/motd
echo "algtest-live" > /etc/hostname

if [ -e /dev/disk/by-label/ALGTEST_RES ]; then
	mkdir -p /mnt/algtest
	mount -o rw,umask=0000 /dev/disk/by-label/ALGTEST_RES /mnt/algtest
fi

EOF

chmod 755 /etc/rc.d/init.d/livesys
/sbin/restorecon /etc/rc.d/init.d/livesys
/sbin/chkconfig --add livesys

#systemctl disable multipathd.service

%end
