#!/bin/sh
# base-x86_64 post-assembly hook (runs on the fully staged rootfs).
# Rebuild the C.UTF-8/en_US locale archive with the TARGET localedef:
# chroot into the staged rootfs so the x86_64 glibc does the work.
chroot "$ROOTFS" /usr/bin/localedef -i en_US -c -f UTF-8 en_US.UTF-8 2>/dev/null || true

# LXTaz login manager instead of slim (live autologin: bootopts.sh).
sed -i 's/^LOGIN_MANAGER=.*/LOGIN_MANAGER="lxtaz-dm"/' "$ROOTFS/etc/rcS.conf"
